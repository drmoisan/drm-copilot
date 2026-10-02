/**
 * Issue-adoption record validation and receipt waivers for orchestrator checkpoints.
 *
 * Purpose:
 *     Validate the optional `issue_adoption` checkpoint object, which records
 *     that the orchestration adopted a GitHub issue that already existed before
 *     orchestration started. A valid record waives the successful-receipt
 *     requirement for `potential_to_issue` and, optionally, for the checkpoint's
 *     promotion-entry tool. This module mirrors the Python authority in
 *     `scripts/dev_tools/_orchestrator_state_issue_adoption.py` and the
 *     PowerShell authority `OrchestratorStateIssueAdoption.psm1`, so all three
 *     runtimes produce the same ordered errors.
 *
 * Invariants:
 *     - An absent key produces no error and waives nothing.
 *     - Errors accumulate in the fixed rule order of the feature specification.
 *     - Fail-closed: `waivedTools` is empty whenever `errors` is non-empty.
 *     - Every comparison is ordinal and case-sensitive.
 *
 * Boundaries:
 *     Pure logic only. No I/O, no clock, no randomness, no input mutation.
 */
import {
  BUG_PROMOTION_ENTRY_TOOL,
  FEATURE_PROMOTION_ENTRY_TOOL,
} from "./orchestrator-state-promotion-tools";

/** The checkpoint key that carries the adoption record. */
export const ISSUE_ADOPTION_KEY = "issue_adoption";

/** MCP tool that creates the GitHub issue from a potential entry. */
export const POTENTIAL_TO_ISSUE_TOOL = "potential_to_issue";

/** Accepted values of `issue_adoption.origin`. */
export const ORIGIN_VALUES: ReadonlySet<string> = new Set([
  "transferred",
  "filed_before_orchestration",
  "epic_decomposition",
]);

/** Accepted values of `issue_adoption.verified_via`. */
export const VERIFIED_VIA_VALUES: ReadonlySet<string> = new Set([
  "gh_issue_view",
  "gh_api_get",
  "github_mcp_issue_read",
]);

/**
 * The closed set of tools an adoption record may waive: the issue-creation
 * tool and the two promotion-type-specific promotion-entry tools.
 */
export const WAIVABLE_TOOLS: ReadonlySet<string> = new Set([
  POTENTIAL_TO_ISSUE_TOOL,
  FEATURE_PROMOTION_ENTRY_TOOL,
  BUG_PROMOTION_ENTRY_TOOL,
]);

const PROMOTION_ENTRY_TOOLS: ReadonlySet<string> = new Set([
  FEATURE_PROMOTION_ENTRY_TOOL,
  BUG_PROMOTION_ENTRY_TOOL,
]);
const POTENTIAL_RECORD_PREFIX = "docs/features/potential/";
const POTENTIAL_RECORD_SUFFIX = ".md";
const ISSUE_NUM_PATTERN = /^[1-9][0-9]*$/;

const ERROR_NOT_OBJECT =
  "Checkpoint issue_adoption must be an object when present.";
const ERROR_ISSUE_NUM_FORMAT =
  "Checkpoint issue_adoption.issue_num must be a string of decimal digits without a leading zero.";
const ERROR_ISSUE_NUM_MISMATCH =
  "Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num.";
const ERROR_ISSUE_URL =
  "Checkpoint issue_adoption.issue_url must end with /issues/ followed by issue_num.";
const ERROR_ORIGIN =
  "Checkpoint issue_adoption.origin must be one of transferred, filed_before_orchestration, epic_decomposition.";
const ERROR_VERIFIED_VIA =
  "Checkpoint issue_adoption.verified_via must be one of gh_issue_view, gh_api_get, github_mcp_issue_read.";
const ERROR_VERIFIED_AT =
  "Checkpoint issue_adoption.verified_at must be present.";
const ERROR_EVIDENCE =
  "Checkpoint issue_adoption.evidence must be a non-empty string.";
const ERROR_WAIVED_TOOLS_SHAPE =
  "Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names.";
const ERROR_WAIVED_TOOLS_INCLUDE =
  "Checkpoint issue_adoption.waived_tools must include potential_to_issue.";

/** Outcome of validating a checkpoint's `issue_adoption` record. */
export interface IssueAdoptionResult {
  /** Adoption errors in rule order; empty when absent or valid. */
  errors: string[];
  /** Tools whose receipt requirement is waived; empty whenever errors exist. */
  waivedTools: ReadonlySet<string>;
}

/** Options for {@link resolveIssueAdoption}. */
export interface ResolveIssueAdoptionOptions {
  /** The selected route id, interpolated into route errors. */
  routeId: string;
  /** The route's required MCP tools after promotion-type resolution. */
  requiredMcpTools: readonly string[];
  /** Tools that hold a successful MCP receipt in the checkpoint. */
  successfulTools: ReadonlySet<string>;
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isNonBlankString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function validIssueNum(value: unknown): string | null {
  return typeof value === "string" && ISSUE_NUM_PATTERN.test(value)
    ? value
    : null;
}

function issueIdentityErrors(
  adoption: Record<string, unknown>,
  state: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  const issueNum = validIssueNum(adoption["issue_num"]);
  if (issueNum === null) {
    errors.push(ERROR_ISSUE_NUM_FORMAT);
  } else {
    // The equality check applies only when the checkpoint records its own
    // issue number as a string; other shapes are validated elsewhere.
    const checkpointIssueNum = state["issue-num"];
    if (
      typeof checkpointIssueNum === "string" &&
      checkpointIssueNum !== issueNum
    ) {
      errors.push(ERROR_ISSUE_NUM_MISMATCH);
    }
  }

  const issueUrl = adoption["issue_url"];
  if (
    issueNum === null ||
    typeof issueUrl !== "string" ||
    !issueUrl.endsWith(`/issues/${issueNum}`)
  ) {
    errors.push(ERROR_ISSUE_URL);
  }
  return errors;
}

function provenanceErrors(adoption: Record<string, unknown>): string[] {
  const errors: string[] = [];
  const origin = adoption["origin"];
  if (typeof origin !== "string" || !ORIGIN_VALUES.has(origin)) {
    errors.push(ERROR_ORIGIN);
  }

  const verifiedVia = adoption["verified_via"];
  if (
    typeof verifiedVia !== "string" ||
    !VERIFIED_VIA_VALUES.has(verifiedVia)
  ) {
    errors.push(ERROR_VERIFIED_VIA);
  }

  // Presence-only: any non-null value other than a blank string passes.
  const verifiedAt = adoption["verified_at"];
  if (
    verifiedAt === undefined ||
    verifiedAt === null ||
    (typeof verifiedAt === "string" && verifiedAt.trim().length === 0)
  ) {
    errors.push(ERROR_VERIFIED_AT);
  }

  if (!isNonBlankString(adoption["evidence"])) {
    errors.push(ERROR_EVIDENCE);
  }
  return errors;
}

function waivedToolList(value: unknown): string[] | null {
  if (!Array.isArray(value)) {
    return null;
  }
  const items: unknown[] = value;
  if (items.length === 0 || !items.every((item) => isNonBlankString(item))) {
    return null;
  }
  return items as string[];
}

function waivedToolErrors(
  waived: readonly string[],
  options: ResolveIssueAdoptionOptions,
): string[] {
  const errors: string[] = [];
  const seen = new Set<string>();
  for (const tool of waived) {
    // Each entry receives only the first rule it violates, in rule order.
    if (seen.has(tool)) {
      errors.push(
        `Checkpoint issue_adoption.waived_tools lists a tool more than once: ${tool}.`,
      );
    } else if (!WAIVABLE_TOOLS.has(tool)) {
      errors.push(
        `Checkpoint issue_adoption.waived_tools names a tool that cannot be waived: ${tool}.`,
      );
    } else if (!options.requiredMcpTools.includes(tool)) {
      errors.push(
        `Checkpoint issue_adoption.waived_tools names a tool that is not required by route ${options.routeId}: ${tool}.`,
      );
    } else if (options.successfulTools.has(tool)) {
      errors.push(
        `Checkpoint issue_adoption.waived_tools names a tool that has a successful MCP receipt: ${tool}.`,
      );
    }
    seen.add(tool);
  }

  if (!seen.has(POTENTIAL_TO_ISSUE_TOOL)) {
    errors.push(ERROR_WAIVED_TOOLS_INCLUDE);
  }
  return errors;
}

function potentialRecordErrors(
  waived: readonly string[],
  potentialRecord: unknown,
): string[] {
  if (
    typeof potentialRecord === "string" &&
    potentialRecord.startsWith(POTENTIAL_RECORD_PREFIX) &&
    potentialRecord.endsWith(POTENTIAL_RECORD_SUFFIX)
  ) {
    return [];
  }

  const errors: string[] = [];
  const reported = new Set<string>();
  for (const tool of waived) {
    if (PROMOTION_ENTRY_TOOLS.has(tool) && !reported.has(tool)) {
      errors.push(
        `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving ${tool}.`,
      );
      reported.add(tool);
    }
  }
  return errors;
}

/**
 * Validate the checkpoint's `issue_adoption` record and resolve its waivers.
 *
 * When the key is absent, no error is produced and no tool is waived. A present
 * value that is not an object (including `null`) yields only the not-an-object
 * error. Otherwise the field and waiver rules accumulate errors in order, and
 * the waived-tool set is populated only when no error was found.
 *
 * @param state - The parsed checkpoint object; not mutated.
 * @param options - The route id, resolved required tools, and successful tools.
 * @returns The ordered adoption errors and the waived-tool set.
 */
export function resolveIssueAdoption(
  state: Record<string, unknown>,
  options: ResolveIssueAdoptionOptions,
): IssueAdoptionResult {
  if (!Object.prototype.hasOwnProperty.call(state, ISSUE_ADOPTION_KEY)) {
    return { errors: [], waivedTools: new Set<string>() };
  }

  const adoption = state[ISSUE_ADOPTION_KEY];
  if (!isPlainObject(adoption)) {
    return { errors: [ERROR_NOT_OBJECT], waivedTools: new Set<string>() };
  }

  const errors: string[] = [
    ...issueIdentityErrors(adoption, state),
    ...provenanceErrors(adoption),
  ];

  const waived = waivedToolList(adoption["waived_tools"]);
  if (waived === null) {
    // A malformed list stops rule 8 and skips rule 9 entirely.
    errors.push(ERROR_WAIVED_TOOLS_SHAPE);
    return { errors, waivedTools: new Set<string>() };
  }

  errors.push(...waivedToolErrors(waived, options));
  errors.push(...potentialRecordErrors(waived, adoption["potential_record"]));

  if (errors.length > 0) {
    return { errors, waivedTools: new Set<string>() };
  }
  return { errors: [], waivedTools: new Set<string>(waived) };
}
