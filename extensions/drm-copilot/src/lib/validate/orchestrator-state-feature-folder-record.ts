/**
 * Feature-folder adoption record validation for orchestrator checkpoints.
 *
 * Purpose:
 *     Validate the optional `issue_adoption.feature_folder_record` object, which
 *     declares that an adopted feature folder already existed and was committed
 *     before the finishing run started. A valid record lets the adoption waive
 *     the `new_active_feature_folder` receipt (issue #992). This module mirrors
 *     the Python authority `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`
 *     and the PowerShell module `OrchestratorStateFeatureFolderRecord.psm1`,
 *     with byte-identical error strings.
 *
 * Invariants:
 *     - Rule 10: waiving `new_active_feature_folder` requires an object record.
 *     - Rules 11a to 11e run whenever the record is an object, waived or not;
 *       rule 11b runs only when `path` passed rule 11a.
 *     - Every comparison is ordinal and case-sensitive; the path pattern is a
 *       full match.
 *     - The record is a declaration; the Claude `SubagentStop` hook performs the
 *       git probe separately.
 *
 * Boundaries:
 *     Pure logic only. No I/O, no clock, no randomness, no input mutation.
 */

/** MCP tool that creates the active feature folder. */
export const FEATURE_FOLDER_TOOL = "new_active_feature_folder";

/** The `issue_adoption` member that carries the record. */
export const FEATURE_FOLDER_RECORD_KEY = "feature_folder_record";

const CHECKPOINT_FEATURE_FOLDER_KEY = "feature-folder";

/**
 * A repository-relative folder under `docs/features/active/`. Applied without
 * the multiline flag, so the anchors match only at the ends of the value.
 */
export const FEATURE_FOLDER_PATH_PATTERN =
  /^docs\/features\/active\/[A-Za-z0-9][A-Za-z0-9._-]*(\/[A-Za-z0-9][A-Za-z0-9._-]*)*$/;

/** Accepted values of `feature_folder_record.verified_via`. */
export const FEATURE_FOLDER_VERIFIED_VIA: readonly string[] = [
  "git_cat_file_head",
  "git_ls_tree_head",
];

export const ERROR_FEATURE_FOLDER_RECORD_NOT_OBJECT =
  "Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.";
export const ERROR_FEATURE_FOLDER_PATH_FORMAT =
  "Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.";
export const ERROR_FEATURE_FOLDER_PATH_EQUAL =
  "Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.";
export const ERROR_FEATURE_FOLDER_VERIFIED_VIA =
  "Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.";
export const ERROR_FEATURE_FOLDER_VERIFIED_AT =
  "Checkpoint issue_adoption.feature_folder_record.verified_at must be present.";
export const ERROR_FEATURE_FOLDER_EVIDENCE =
  "Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.";

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Report whether a value is a valid adopted feature-folder path.
 *
 * @param value - The deserialized JSON value to inspect.
 * @returns True when the value is a string that fully matches the pattern.
 */
export function isFeatureFolderPath(value: unknown): value is string {
  return typeof value === "string" && FEATURE_FOLDER_PATH_PATTERN.test(value);
}

function recordFieldErrors(
  record: Record<string, unknown>,
  state: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  const recordPath = record["path"];
  // Rule 11b compares a well-formed path only; a malformed path is reported
  // once by rule 11a.
  if (!isFeatureFolderPath(recordPath)) {
    errors.push(ERROR_FEATURE_FOLDER_PATH_FORMAT);
  } else if (state[CHECKPOINT_FEATURE_FOLDER_KEY] !== recordPath) {
    errors.push(ERROR_FEATURE_FOLDER_PATH_EQUAL);
  }

  const verifiedVia = record["verified_via"];
  if (
    typeof verifiedVia !== "string" ||
    !FEATURE_FOLDER_VERIFIED_VIA.includes(verifiedVia)
  ) {
    errors.push(ERROR_FEATURE_FOLDER_VERIFIED_VIA);
  }

  // Presence-only, matching the adoption-level verified_at rule.
  const verifiedAt = record["verified_at"];
  if (
    verifiedAt === undefined ||
    verifiedAt === null ||
    (typeof verifiedAt === "string" && verifiedAt.trim().length === 0)
  ) {
    errors.push(ERROR_FEATURE_FOLDER_VERIFIED_AT);
  }

  const evidence = record["evidence"];
  if (typeof evidence !== "string" || evidence.trim().length === 0) {
    errors.push(ERROR_FEATURE_FOLDER_EVIDENCE);
  }
  return errors;
}

/**
 * Validate `issue_adoption.feature_folder_record` (rules 10 and 11a-11e).
 *
 * @param adoption - The `issue_adoption` object; not mutated.
 * @param state - The parsed checkpoint, read for its `feature-folder` key.
 * @param waivedTools - The well-formed `waived_tools` list in checkpoint order.
 * @returns Zero or more errors in rule order.
 */
export function featureFolderRecordErrors(
  adoption: Record<string, unknown>,
  state: Record<string, unknown>,
  waivedTools: readonly string[],
): string[] {
  const record = adoption[FEATURE_FOLDER_RECORD_KEY];
  // An object record is always validated; a missing or non-object record
  // matters only when the tool is waived.
  if (isPlainObject(record)) {
    return recordFieldErrors(record, state);
  }
  if (waivedTools.includes(FEATURE_FOLDER_TOOL)) {
    return [ERROR_FEATURE_FOLDER_RECORD_NOT_OBJECT];
  }
  return [];
}
