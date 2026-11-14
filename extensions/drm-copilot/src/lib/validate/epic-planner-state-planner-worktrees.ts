/**
 * Validate the optional `planner_worktrees` records of an epic-planner
 * checkpoint (issue #1161).
 *
 * The error strings are byte-identical to `_validate_planner_worktrees` in
 * `scripts/dev_tools/validate_epic_planner_state.py`; the shared corpus under
 * `tests/fixtures/epic_planner_state_planner_worktrees/` pins both runtimes.
 * Pure: no file, process, clock, or randomness is used.
 */

/** The recordable preparation states, in the order the error string lists them. */
const PLANNER_WORKTREE_STATUSES: readonly string[] = [
  "preparing",
  "prepared",
  "fanned_in",
  "removed",
  "abandoned",
];

/** The accepted branch-name shape before the `..` and suffix checks. */
const PLANNER_BRANCH = /^[A-Za-z0-9][A-Za-z0-9._/-]*$/;

/**
 * A blank `recorded_at`: only space, tab, LF, CR, VT, and FF, or empty. The
 * Python twin `_RECORDED_AT_BLANK_CHARS` uses the same six characters;
 * `trim()` is not used because its whitespace set differs from Python's.
 */
const RECORDED_AT_BLANK = /^[ \t\n\r\v\f]*$/;

/**
 * Narrow a value to a plain JSON object.
 *
 * @param value Any parsed JSON value.
 * @returns True when the value is a non-null, non-array object.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Report whether a value is a valid `planner_worktrees[].branch` name.
 *
 * @param value The recorded branch value.
 * @returns True for a matching string with no `..` and no `/`, `.`, or
 * `.lock` suffix.
 */
function isPlannerBranch(value: unknown): value is string {
  if (typeof value !== "string" || !PLANNER_BRANCH.test(value)) {
    return false;
  }
  return (
    !value.includes("..") &&
    !value.endsWith("/") &&
    !value.endsWith(".") &&
    !value.endsWith(".lock")
  );
}

/**
 * Report whether a value is a non-empty path relative to the main checkout.
 *
 * A drive prefix, a leading `/`, any backslash or colon, and an empty, `.`,
 * or `..` segment each name a location outside the main checkout.
 *
 * @param value The recorded path value.
 * @returns True when the path is safe and relative.
 */
function isPlannerRelativePath(value: unknown): boolean {
  if (typeof value !== "string" || value === "" || value.startsWith("/")) {
    return false;
  }
  if (value.includes("\\") || value.includes(":")) {
    return false;
  }
  return value
    .split("/")
    .every((segment) => segment !== "" && segment !== "." && segment !== "..");
}

/**
 * Validate the fields of one object entry after its branch.
 *
 * @param entry The entry being validated.
 * @param prefix The error prefix naming the entry by index.
 * @param folders The string `features[].feature_folder` values.
 * @returns The path, purpose, status, folder, and recorded-at errors in order.
 */
function validateEntryFields(
  entry: Record<string, unknown>,
  prefix: string,
  folders: ReadonlySet<string>,
): string[] {
  const errors: string[] = [];
  if ("path" in entry && !isPlannerRelativePath(entry["path"])) {
    errors.push(
      `${prefix}.path must be a repository-relative path without a drive, ` +
        "a leading slash, a backslash, or dot segments.",
    );
  }
  if (entry["purpose"] !== "preparation") {
    errors.push(`${prefix}.purpose must be preparation.`);
  }
  const status = entry["preparation_status"];
  if (
    typeof status !== "string" ||
    !PLANNER_WORKTREE_STATUSES.includes(status)
  ) {
    errors.push(
      `${prefix}.preparation_status must be one of: ` +
        `${PLANNER_WORKTREE_STATUSES.join(", ")}.`,
    );
  }
  const folder = entry["feature_folder"];
  if (typeof folder !== "string" || !folders.has(folder)) {
    errors.push(
      `${prefix}.feature_folder must name a features[] feature_folder.`,
    );
  }
  const recordedAt = entry["recorded_at"];
  if (
    "recorded_at" in entry &&
    !(typeof recordedAt === "string" && !RECORDED_AT_BLANK.test(recordedAt))
  ) {
    errors.push(
      `${prefix}.recorded_at must be a non-empty string when present.`,
    );
  }
  return errors;
}

/**
 * Validate the optional `planner_worktrees` array of a parsed checkpoint.
 *
 * @param state The parsed checkpoint object; nothing is checked without the key.
 * @param indexedFeatures The object entries of `features` with their indices.
 * @returns Errors in entry order; within an entry: branch or uniqueness, path,
 * purpose, preparation_status, feature_folder, recorded_at.
 */
export function validatePlannerWorktrees(
  state: Record<string, unknown>,
  indexedFeatures: ReadonlyArray<readonly [number, Record<string, unknown>]>,
): string[] {
  if (!("planner_worktrees" in state)) {
    return [];
  }
  const value = state["planner_worktrees"];
  if (!Array.isArray(value)) {
    return [
      "Epic planner checkpoint planner_worktrees must be a list when present.",
    ];
  }
  const folders = new Set<string>();
  for (const [, feature] of indexedFeatures) {
    const folder = feature["feature_folder"];
    if (typeof folder === "string") {
      folders.add(folder);
    }
  }
  const errors: string[] = [];
  const seen = new Set<string>();
  const entries: unknown[] = value;
  entries.forEach((item, index) => {
    const prefix = `Epic planner checkpoint planner_worktrees[${index}]`;
    if (!isRecord(item)) {
      errors.push(`${prefix} must be an object.`);
      return;
    }
    const branch = item["branch"];
    if (!isPlannerBranch(branch)) {
      errors.push(`${prefix}.branch must be a non-empty branch name.`);
    } else if (seen.has(branch)) {
      errors.push(`${prefix}.branch must be unique: ${branch}.`);
    } else {
      seen.add(branch);
    }
    errors.push(...validateEntryFields(item, prefix, folders));
  });
  return errors;
}
