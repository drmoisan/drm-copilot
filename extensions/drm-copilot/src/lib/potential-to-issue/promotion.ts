/**
 * Potential-to-issue promotion workflow.
 *
 * Purpose:
 *     In-process TypeScript port of the `promote_potential` workflow in the
 *     bundled `scripts/dev_tools/potential_to_issue.py`. Drives the
 *     end-to-end promotion: validate inputs, check gh auth, parse the potential
 *     file, build the issue body, create the issue (with a single missing-label
 *     recovery), update the potential-file metadata, and move the file into the
 *     promoted folder.
 *
 * Parity:
 *     Every `PromotionError` message, emitted line, constant, and decision
 *     branch is byte-identical to the Python source. The missing-label recovery
 *     only recovers from the specific `could not add label: '<label>' not found`
 *     failure for the selected promotion label.
 *
 * Seams:
 *     The workflow uses a port-local {@link PotentialFileSystem} (NOT the shared
 *     F1 `FileSystem`, which lacks `exists`/`move`/`writeLines`/`resolvePath`)
 *     and the {@link GhClient} seam. Tests inject in-memory fakes; production
 *     defaults to {@link RealPotentialFileSystem} and `RealGhClient`.
 */

import * as nodePath from "node:path";

import {
  ACCEPTED_WORK_MODES,
  normalizeRequestedWorkMode,
} from "../prompt-mode-contract";
import {
  type PotentialFileSystem,
  RealPotentialFileSystem,
} from "./promotion-filesystem";

// Re-export the port-local filesystem seam so consumers can import it from the
// workflow module (the seam was extracted to keep this file under 500 lines).
export {
  type PotentialFileSystem,
  RealPotentialFileSystem,
} from "./promotion-filesystem";
import {
  BUG_SECTION_HEADINGS,
  PLACEHOLDER,
  buildBody,
  buildBugBody,
  buildMinorAuditBody,
  extractLastUpdated,
  getFeatureName,
  getFeaturePath,
  getSection,
  normalizeSmartPunctuation,
  parseIssueReference,
  updateMetadataLines,
} from "./content";
import { type GhClient, RealGhClient } from "./gh-client";

/** Accepted promotion types (byte-identical to the Python tuple). */
export const PROMOTION_TYPES: readonly string[] = [
  "epic",
  "feature",
  "refactor",
  "bug",
];

/** Issue title prefixes keyed by promotion type. */
export const TITLE_PREFIXES: Readonly<Record<string, string>> = {
  epic: "Epic",
  feature: "Feature",
  refactor: "Refactor",
  bug: "Bug",
};

/** Raised when a promotion precondition fails. */
export class PromotionError extends Error {
  /**
   * @param message Byte-identical failure message from the Python source.
   */
  constructor(message: string) {
    super(message);
    this.name = "PromotionError";
  }
}

/**
 * Outcome of a promotion run.
 *
 * - `exitCode`: 0 on success; the gh create exit code on failure.
 * - `messages`: every emitted line, in order, for the service summary/return.
 * - `destination`: the promoted file path on success; absent on failure.
 */
export interface PromotionOutcome {
  exitCode: number;
  messages: string[];
  destination?: string;
}

/** Options for {@link promotePotential}. */
export interface PromotePotentialOptions {
  /** Path to the potential markdown file. */
  readonly potentialPath: string;
  /** Promotion type label; defaults to `feature`. */
  readonly promotionType?: string;
  /** Injected filesystem seam; defaults to {@link RealPotentialFileSystem}. */
  readonly fs?: PotentialFileSystem;
  /** Injected gh client seam; defaults to `RealGhClient`. */
  readonly gh?: GhClient;
  /** Workspace root; defaults to the current working directory. */
  readonly workspace?: string;
  /** Requested work mode; defaults to `full`. */
  readonly workMode?: string;
  /** Optional line sink for emitted progress messages; defaults to a no-op. */
  readonly emit?: (message: string) => void;
}

/**
 * Return whether gh output reports a missing-label create failure.
 *
 * Mirrors Python `_is_missing_label_failure`: any output line (lowercased)
 * containing `could not add label: '<label>' not found`.
 *
 * @param output gh output lines.
 * @param label Promotion label being created.
 * @returns True when the specific missing-label failure is present.
 */
export function isMissingLabelFailure(
  output: readonly string[],
  label: string,
): boolean {
  const expectedFragment = `could not add label: '${label}' not found`;
  return output.some((line) => line.toLowerCase().includes(expectedFragment));
}

/**
 * Compute the POSIX path of `resolved` relative to `workspacePath`.
 *
 * Mirrors Python `Path(os.path.relpath(resolved, workspace)).as_posix()` with a
 * fallback to the resolved path string on a relpath error (e.g. a different
 * drive on Windows raises in Python; `node:path.relative` does not, so the
 * try/catch is preserved for parity even though it rarely triggers).
 *
 * @param resolved Resolved potential-file path.
 * @param workspacePath Workspace root.
 * @returns The POSIX relative path, or the resolved path on failure.
 */
function computeRelativePath(resolved: string, workspacePath: string): string {
  try {
    const relative = nodePath.relative(workspacePath, resolved);
    return relative.split(nodePath.sep).join("/");
  } catch {
    // Mirror the Python ValueError fallback to the resolved path string.
    return resolved;
  }
}

/**
 * Join path segments using forward slashes, collapsing duplicate separators.
 *
 * Keeps the result OS-neutral (forward slashes) so emitted and returned paths
 * match the Python `Path` join behavior on POSIX-style workspace inputs.
 *
 * @param base Base path (may contain either separator form).
 * @param relative Relative path appended to the base.
 * @returns The combined forward-slash path.
 */
function posixJoin(base: string, relative: string): string {
  const normalizedBase = base.replace(/\\/g, "/").replace(/\/+$/, "");
  const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
  return `${normalizedBase}/${normalizedRelative}`;
}

/**
 * Return the final path segment, splitting on either separator form.
 *
 * Mirrors Python `Path(...).name` for the resolved potential-file path.
 *
 * @param pathStr Path to take the basename of.
 * @returns The final path segment.
 */
function posixBasename(pathStr: string): string {
  const normalized = pathStr.replace(/\\/g, "/").replace(/\/+$/, "");
  const lastSlash = normalized.lastIndexOf("/");
  return lastSlash === -1 ? normalized : normalized.slice(lastSlash + 1);
}

/**
 * Build the issue body for the selected mode and promotion type.
 *
 * Routing table (decision order MUST match the Python source):
 * - bug promotion -> {@link buildBugBody} over the canonical bug headings,
 *   regardless of work mode (so a minor-audit bug renders the bug headings).
 * - non-bug minor-audit -> {@link buildMinorAuditBody} (with the default
 *   Evidence Checklist when the section is absent).
 * - otherwise -> {@link buildBody} (standard full-feature body).
 *
 * @param content Potential-file content.
 * @param selectedMode Normalized work mode.
 * @param promotionType Promotion type.
 * @param relativePath POSIX source path for the footer.
 * @returns The composed (un-normalized) issue body.
 */
function buildIssueBody(
  content: string,
  selectedMode: string,
  promotionType: string,
  relativePath: string,
): string {
  // Bug promotions route through the canonical bug-section body FIRST, before
  // the work-mode branch. This ordering is required so a bug potential promoted
  // in minor-audit mode still renders the real bug headings (Summary,
  // Environment, ...) from the bug template rather than the minor-audit/feature
  // sections, which read headings the bug template does not contain. The
  // `- Work Mode:` first line emitted by buildBugBody still records the selected
  // mode, so a minor-audit bug issue records `- Work Mode: minor-audit`.
  if (promotionType === "bug") {
    const bugSections: Record<string, string> = {};
    for (const heading of BUG_SECTION_HEADINGS) {
      bugSections[heading] = getSection(content, heading) || PLACEHOLDER;
    }
    return buildBugBody(selectedMode, bugSections, relativePath);
  }

  // Non-bug minor-audit promotions route to the audit body with audit-specific
  // sections (defaulting the Evidence Checklist when the section is absent).
  if (selectedMode === "minor-audit") {
    const problem = getSection(content, "Problem / Why") || PLACEHOLDER;
    const implementationIntent =
      getSection(content, "Proposed Behavior") || PLACEHOLDER;
    const acceptanceCriteria =
      getSection(content, "Acceptance Criteria (early draft)") || PLACEHOLDER;
    const dependenciesRisks =
      getSection(content, "Constraints & Risks") || PLACEHOLDER;
    const verificationSteps =
      getSection(content, "Test Conditions to Consider") || PLACEHOLDER;
    let evidenceChecklist = getSection(content, "Evidence Checklist");
    // Default the checklist to the canonical three-line block when absent.
    if (!evidenceChecklist) {
      evidenceChecklist =
        "- [ ] Baseline\n- [ ] End-state\n- [ ] Targeted verification";
    }
    return buildMinorAuditBody(
      selectedMode,
      problem,
      implementationIntent,
      acceptanceCriteria,
      dependenciesRisks,
      verificationSteps,
      evidenceChecklist,
      relativePath,
    );
  }

  // Default: the standard full-feature body.
  const problem = getSection(content, "Problem / Why") || PLACEHOLDER;
  const behavior = getSection(content, "Proposed Behavior") || PLACEHOLDER;
  const criteria =
    getSection(content, "Acceptance Criteria (early draft)") || PLACEHOLDER;
  const constraints = getSection(content, "Constraints & Risks") || PLACEHOLDER;
  const tests =
    getSection(content, "Test Conditions to Consider") || PLACEHOLDER;
  return buildBody(
    selectedMode,
    problem,
    behavior,
    criteria,
    constraints,
    tests,
    relativePath,
  );
}

/**
 * Promote a potential feature file to a GitHub issue.
 *
 * Reproduces the Python `promote_potential` control flow, emitted lines, error
 * messages, and decision ordering verbatim. Recovers once from a missing-label
 * create failure for the selected promotion label; all other gh errors fall
 * through to the failure path with their original output.
 *
 * @param options Promotion options (path, promotion type, seams, workspace,
 *   work mode, and an optional emit sink).
 * @returns A {@link PromotionOutcome}: exit code, ordered messages, and the
 *   promoted destination path on success.
 * @throws PromotionError When a precondition fails (invalid type/mode,
 *   unauthenticated gh, missing/empty file, or a re-wrapped work-mode error).
 *
 * Side effects:
 *     Invokes the gh client; reads, writes, and moves files through the injected
 *     filesystem seam.
 */
export function promotePotential(
  options: PromotePotentialOptions,
): PromotionOutcome {
  const promotionType = options.promotionType ?? "feature";
  const workMode = options.workMode ?? "full";

  // Validate the promotion type and work mode before any I/O.
  if (!PROMOTION_TYPES.includes(promotionType)) {
    throw new PromotionError(`Invalid promotion type: ${promotionType}`);
  }
  if (!(ACCEPTED_WORK_MODES as readonly string[]).includes(workMode)) {
    throw new PromotionError(`Invalid work mode: ${workMode}`);
  }

  const filesystem = options.fs ?? new RealPotentialFileSystem();
  const ghClient = options.gh ?? new RealGhClient();
  const workspacePath = options.workspace ?? process.cwd();
  const emit = options.emit ?? ((): void => undefined);

  // Fail fast when gh is not authenticated, before touching the file.
  if (!ghClient.isAuthenticated()) {
    throw new PromotionError(
      "GitHub CLI is not authenticated. Run 'gh auth login' first.",
    );
  }

  const resolved = filesystem.resolvePath(options.potentialPath);
  // The not-found message uses the ORIGINAL path arg (byte-identical to Python).
  if (!filesystem.exists(resolved)) {
    throw new PromotionError(
      `Potential file not found: ${options.potentialPath}`,
    );
  }

  const content = filesystem.readText(resolved);
  // The empty message uses the RESOLVED path (byte-identical to Python).
  if (content.trim() === "") {
    throw new PromotionError(`Potential file is empty: ${resolved}`);
  }

  const featureName = getFeatureName(content, resolved);
  const featurePath = getFeaturePath(featureName);
  const prefix = TITLE_PREFIXES[promotionType] ?? "Feature";
  const issueTitle = normalizeSmartPunctuation(`${prefix}: ${featureName}`);

  const relativePath = computeRelativePath(resolved, workspacePath);

  let selectedMode: string;
  try {
    selectedMode = normalizeRequestedWorkMode(workMode, promotionType);
  } catch (exc) {
    // Re-wrap the work-mode error as a PromotionError with the same message.
    const message = exc instanceof Error ? exc.message : String(exc);
    throw new PromotionError(message);
  }
  // Python initializes fallback_reason = "" and never sets it on this path, so
  // the "Fallback reason:" line is never emitted. The variable is retained for
  // parity but intentionally not emitted while empty.
  const fallbackReason = "";

  let body = buildIssueBody(content, selectedMode, promotionType, relativePath);
  body = normalizeSmartPunctuation(body);

  const messages: string[] = [];
  // Collect every emitted line and forward it to the injected sink, mirroring
  // the Python _emit helper.
  const emitLine = (message: string): void => {
    messages.push(message);
    emit(message);
  };

  emitLine(`Selected mode: ${selectedMode}`);
  if (fallbackReason) {
    emitLine(`Fallback reason: ${fallbackReason}`);
  }
  emitLine(`Creating issue: ${issueTitle} (label: ${promotionType})`);
  let createResult = ghClient.issueCreate(issueTitle, body, promotionType);

  // Recover only from the known missing-label failure for the selected label so
  // other gh errors still fail fast with their original output.
  if (isMissingLabelFailure(createResult.output, promotionType)) {
    emitLine(
      "Missing promotion label detected; ensuring label exists and retrying.",
    );
    const ensureLabelResult = ghClient.ensureLabel(promotionType);
    for (const line of ensureLabelResult.output) {
      emitLine(line);
    }
    // Retry the create only when the label-ensure succeeded.
    if (ensureLabelResult.exitCode === 0) {
      createResult = ghClient.issueCreate(issueTitle, body, promotionType);
    }
  }

  // On a non-zero create exit, emit the output (or a synthetic line) and return
  // without a destination.
  if (createResult.exitCode !== 0) {
    const outputLines =
      createResult.output.length > 0
        ? createResult.output
        : [`gh CLI exited with code ${createResult.exitCode}`];
    for (const line of outputLines) {
      emitLine(line);
    }
    return { exitCode: createResult.exitCode, messages };
  }

  // Success: echo the create output lines.
  for (const line of createResult.output) {
    emitLine(line);
  }

  const [issueUrl, issueNumber] = parseIssueReference(createResult.output);

  let lastUpdated: string | null = null;
  // Refresh the updated date from the created issue when a number was parsed.
  if (issueNumber) {
    const viewResult = ghClient.issueView(issueNumber);
    if (viewResult.exitCode === 0 && viewResult.output.length > 0) {
      lastUpdated = extractLastUpdated(viewResult.output.join("\n"));
    }
  }

  // Update the potential-file metadata only when both number and url resolved.
  if (issueNumber && issueUrl) {
    // Split on all line-ending forms to mirror Python content.splitlines().
    const lines = content.split(/\r\n|\r|\n/);
    const updatedLines = updateMetadataLines(
      lines,
      featureName,
      issueNumber,
      issueUrl,
      lastUpdated,
      featurePath,
    );
    filesystem.writeLines(resolved, updatedLines);
    emitLine(`Updated potential file with issue metadata: ${resolved}`);
  }

  // Build the promoted directory and destination using POSIX joins so the
  // emitted/returned paths keep forward slashes regardless of host OS,
  // matching the Python `Path` join behavior on the test/workspace inputs.
  const promotedDir = posixJoin(
    workspacePath,
    "docs/features/potential/promoted",
  );
  filesystem.ensureDir(promotedDir);
  const destPath = posixJoin(promotedDir, posixBasename(resolved));
  filesystem.move(resolved, destPath);
  emitLine(`Moved potential file to promoted folder: ${destPath}`);

  return { exitCode: 0, messages, destination: destPath };
}
