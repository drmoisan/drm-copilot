/**
 * Rendering orchestrator for PR context collection.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/render.py` `build_pr_context` and
 *     `resolve_feature_dir`. Build the full PR context payload from git/gh state
 *     and references, reproducing the exact section ordering, base/merge-base
 *     resolution, classification, and failure-path behavior of the source.
 *
 * Responsibilities:
 *     - `buildPrContext`: assemble the combined context text and the
 *       {@link PrContextResult} record.
 *     - `resolveFeatureDir`: the render-module feature-dir resolver.
 *     - Re-export the render-pr-helpers and render-feature-excerpts symbols, as
 *       the Python `render.py` `__all__` does.
 */

import {
  type PrContextResult,
  type PullRequestDetails,
  normalizeReference,
  section,
} from "./models";
import { type GitClient } from "./git-client";
import {
  convertNumstat,
  extensionSummary,
  extractIssueReferences,
  extractMergePrNumbers,
  selectDefaultBase,
  summarizeConventionalCommits,
} from "./render-pr-helpers";
import {
  directoryExists,
  resolveFeatureDir as resolveFeatureDirRender,
} from "./render-feature-excerpts";
import { type FileSystem } from "../file-system";

// Re-export the render-pr-helpers and render-feature-excerpts symbols so this
// module presents the same surface as the Python `render.py` `__all__`.
export {
  buildCloseCandidatesSection,
  convertNumstat,
  extensionSummary,
  extractChangedPaths,
  extractIssueReferences,
  extractMergePrNumbers,
  formatDiffPath,
  formatIssueDetails,
  formatPrDetails,
  selectDefaultBase,
  summarizeConventionalCommits,
} from "./render-pr-helpers";
export {
  buildExcerptText,
  completedPlanTasks,
  directoryExists,
  extractFeaturesFromPaths,
  extractPlanSections,
  extractSpecParts,
  extractStoryParts,
  gatherFeatureExcerpts,
  parseSection,
  readTextFile,
} from "./render-feature-excerpts";

/** Structural type for the gh dependency used by {@link buildPrContext}. */
export interface GhLike {
  ensureAvailable(): void;
  classifyEntity(numberRef: string): "issue" | "pull" | null;
  readonly available: boolean;
}

/** Options for {@link buildPrContext}. */
export interface BuildPrContextOptions {
  git: GitClient;
  gh: GhLike;
  baseRef: string | null;
  headRef: string | null;
  includeUntracked: boolean;
  featureIssueRefs?: Iterable<string>;
  currentPr?: PullRequestDetails | null;
  ghAvailable?: boolean | null;
}

/**
 * Resolve a feature directory by exact, strong-pattern, then weak match.
 *
 * Mirrors Python `render.resolve_feature_dir`, delegating the matching logic to
 * the render-feature-excerpts variant.
 *
 * @param fs Injected filesystem.
 * @param baseDir Base directory.
 * @param feature Feature identifier.
 * @returns The resolved directory path, or `null`.
 */
export function resolveFeatureDir(
  fs: FileSystem,
  baseDir: string,
  feature: string,
): string | null {
  // The Python render variant first checks the direct child, then guards on the
  // base directory existing; delegate to the shared render resolver which does
  // exactly that.
  if (directoryExists(fs, `${baseDir}/${feature}`)) {
    return `${baseDir}/${feature}`;
  }
  return resolveFeatureDirRender(fs, baseDir, feature);
}

/**
 * Build the full PR context payload from git/gh state and references.
 *
 * Mirrors Python `build_pr_context` exactly: gh-available defaulting, base
 * resolution and the `origin/<base>` remote-probe with the stale-base warning,
 * rev-parse/merge-base/range, the log invocations, author sorted-set,
 * numstat/extension/merge-PR summaries, issue/PR classification with the
 * gh-unavailable fallback, the `===== PR Comparison =====` block ordering, the
 * catch-all failure block with reset fields, the PR Intent block, and the final
 * combined-text section ordering ending in the staged/unstaged diffs and
 * `prBlock`.
 *
 * @param options Git/gh clients, refs, and reference inputs.
 * @returns The assembled {@link PrContextResult}.
 */
export function buildPrContext(
  options: BuildPrContextOptions,
): PrContextResult {
  const { git, gh, baseRef, headRef, includeUntracked } = options;

  // gh-available defaulting: prefer the explicit flag, else the gh property,
  // else True (matching the Python precedence chain).
  let ghAvailable: boolean;
  if (options.ghAvailable === undefined || options.ghAvailable === null) {
    ghAvailable = typeof gh.available === "boolean" ? gh.available : true;
  } else {
    ghAvailable = options.ghAvailable;
  }
  if (ghAvailable) {
    gh.ensureAvailable();
  }

  const branchName = git.branchName();
  const upstream = git.upstream() || "(none)";

  const remotes = git.remoteVerbose();
  const statusShort = git.statusShort();
  const untracked = includeUntracked ? git.untracked() : "";
  const untrackedDisplay = untracked.trim() ? untracked : "(none)";

  const featureIssueList = [...(options.featureIssueRefs ?? [])];
  let referencedIssues: string[];
  let referencedPrs: string[];
  const currentPr = options.currentPr ?? null;
  let verifiedClosing: string[] =
    currentPr && ghAvailable ? currentPr.closingIssues : [];
  let invalidReferences: string[] = [];

  let resolvedBase: string | null;
  let baseSha: string | null;
  let headSha: string | null;
  let headRefResolved: string | null;
  let mergeBase: string | null;
  let revRange: string | null;

  let prBlock: string;
  try {
    const requestedBase = baseRef;
    resolvedBase = baseRef || selectDefaultBase(git);
    if (!resolvedBase) {
      throw new Error("Failed to resolve base ref (tried common defaults)");
    }

    let baseWarning: string | null = null;
    // Probe origin/<base> for a local base ref; warn when the requested base is
    // local and a remote counterpart could not be confirmed.
    if (!resolvedBase.startsWith("origin/")) {
      const remoteCandidate = `origin/${resolvedBase}`;
      const remoteProbe = git.run(
        ["rev-parse", "--verify", "--quiet", remoteCandidate],
        { allowError: true },
      );
      if (remoteProbe.code === 0 && remoteProbe.stdout.trim()) {
        resolvedBase = remoteCandidate;
      } else if (requestedBase) {
        baseWarning =
          "WARNING: Requested base is local and may be stale; prefer " +
          `origin/${requestedBase}`;
      }
    }

    baseSha = git.revParse(resolvedBase);
    headRefResolved = headRef || branchName;
    headSha = git.revParse(headRefResolved || "HEAD");
    mergeBase = git.mergeBase(baseSha, headSha);
    revRange = `${mergeBase}..${headSha}`;

    const oneline = git.log("--pretty=format:%h %ad %an %s", revRange);
    const subjects = git.log("--pretty=%s", revRange);
    const authors = git.log("--format=%an <%ae>", revRange);
    const authorsList = sortedSet(
      splitLines(authors)
        .map((line) => line.trim())
        .filter((line) => line),
    );

    const nameStatus = git.diffRange(["--name-status", mergeBase, headSha]);
    const numstat = git.diffRange(["--numstat", mergeBase, headSha]);
    const shortstat = git.diffRange(["--shortstat", mergeBase, headSha]);
    const stat = git.diffRange(["--stat", mergeBase, headSha]);

    const [additions, deletions, files] = convertNumstat(numstat);
    const extSummary = extensionSummary(files);
    const mergePrs = extractMergePrNumbers(splitLines(oneline));

    const issueCandidates = extractIssueReferences(
      oneline + "\n" + subjects,
    ).filter((ref) => !mergePrs.includes(ref));
    const issues: string[] = [];
    const prs: string[] = [];
    // Classify each candidate reference, falling back to "issue" when gh is
    // unavailable so references are still surfaced.
    for (const ref of issueCandidates) {
      const numberRef = normalizeReference(ref);
      const entity = ghAvailable ? gh.classifyEntity(numberRef) : null;
      const formattedRef = ref.startsWith("#") ? ref : `#${ref}`;
      if (entity === "issue") {
        issues.push(formattedRef);
      } else if (entity === "pull") {
        prs.push(formattedRef);
      } else if (ghAvailable) {
        invalidReferences.push(formattedRef);
      } else {
        issues.push(formattedRef);
      }
    }
    referencedIssues = sortedSet(issues);
    referencedPrs = sortedSet([...prs, ...mergePrs]);

    let issuesDisplay = sortedSet([
      ...referencedIssues,
      ...featureIssueList,
    ]).join(", ");
    if (!issuesDisplay) {
      issuesDisplay = "(none)";
    }
    const prsDisplay =
      referencedPrs.length > 0 ? referencedPrs.join(", ") : "(none)";

    const onelineDisplay = oneline.trim() ? oneline : "(none)";
    const authorsDisplay =
      authorsList.length > 0 ? authorsList.join("\n") : "(none)";
    const nameStatusDisplay = nameStatus.trim() ? nameStatus : "(none)";
    const shortDisplay = shortstat.trim() ? shortstat : "(none)";
    const extDisplay = extSummary ? extSummary : "(none)";
    const statDisplay = stat.trim() ? stat : "(none)";

    const blockLines = [
      section("PR Comparison"),
      `Base ref (requested): ${requestedBase || "(default)"}`,
      `Base ref (resolved): ${resolvedBase} @ ${baseSha}`,
      `Head ref (resolved): ${headRefResolved} @ ${headSha}`,
      `Merge-base: ${mergeBase}`,
    ];
    if (baseWarning) {
      blockLines.push(`Base warning: ${baseWarning}`);
    }
    blockLines.push(
      `Range: ${revRange}\n`,
      section("Commits in range"),
      onelineDisplay,
      "",
      section("Conventional commit type summary"),
      summarizeConventionalCommits(subjects),
      "",
      section("Authors"),
      authorsDisplay,
      "",
      section("Changed files (name-status)"),
      nameStatusDisplay,
      "",
      section("Diff shortstat"),
      shortDisplay,
      "",
      section("Additions/Deletions totals (from numstat)"),
      `Additions: ${additions}\nDeletions: ${deletions}\n`,
      section("Files by extension"),
      extDisplay,
      "",
      section("Referenced issues (detected)"),
      issuesDisplay,
      "",
      section("PRs in range"),
      prsDisplay,
      "",
      section("Diff stat"),
      statDisplay,
    );
    prBlock = blockLines.join("\n");
  } catch (exc) {
    // On any failure, emit the failure block and reset all derived fields,
    // matching the Python catch-all.
    prBlock =
      section("PR Comparison") +
      `(FAILED to compute PR context: ${errorMessage(exc)})\n`;
    referencedIssues = [];
    referencedPrs = [];
    verifiedClosing = [];
    invalidReferences = [];
    resolvedBase = null;
    baseSha = null;
    headSha = null;
    headRefResolved = headRef || branchName;
    mergeBase = null;
    revRange = null;
  }

  const intent = [
    section("PR Intent (edit before generating PR body)"),
    "Primary outcome:",
    "Impact (user/developer):",
    "Risks:",
    "Author-asserted autoclose issues:",
  ].join("\n");

  const combinedText = [
    intent,
    section("Repository remotes"),
    remotes,
    "",
    section("Current branch"),
    branchName,
    "",
    section("Upstream"),
    upstream,
    "",
    section("Status (short)"),
    statusShort,
    "",
    section("Untracked files"),
    untrackedDisplay,
    "",
    section("Working tree diff (staged)"),
    git.diffNameStatus({ staged: true }),
    git.diffPatch({ staged: true }),
    "",
    section("Working tree diff (unstaged)"),
    git.diffNameStatus({ staged: false }),
    git.diffPatch({ staged: false }),
    prBlock,
  ].join("\n");

  return {
    text: combinedText,
    referencedIssues,
    referencedPrs,
    verifiedClosing: sortedSet(verifiedClosing),
    invalidReferences: sortedSet(invalidReferences),
    baseRef,
    resolvedBase,
    baseSha,
    headRef: headRefResolved,
    headSha,
    mergeBase,
    revRange,
    ghAvailable,
  };
}

/** Extract a message from a thrown value, matching Python `str(exc)`. */
function errorMessage(exc: unknown): string {
  return exc instanceof Error ? exc.message : String(exc);
}

/** Sort a deduplicated set of strings by Unicode code point. */
function sortedSet(values: Iterable<string>): string[] {
  return [...new Set(values)].sort(compareCodePoint);
}

/** Compare two strings by Unicode code point (Python `sorted` semantics). */
function compareCodePoint(left: string, right: string): number {
  if (left < right) {
    return -1;
  }
  if (left > right) {
    return 1;
  }
  return 0;
}

/**
 * Split text into lines the way Python `str.splitlines()` does.
 *
 * @param value Text to split.
 * @returns Lines without terminators.
 */
function splitLines(value: string): string[] {
  if (value === "") {
    return [];
  }
  const lines = value.split(/\r\n|\r|\n/u);
  if (
    lines.length > 0 &&
    lines[lines.length - 1] === "" &&
    /(\r\n|\r|\n)$/u.test(value)
  ) {
    lines.pop();
  }
  return lines;
}
