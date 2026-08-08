/**
 * Shared enums and shape helpers for the parallel-orchestration validators.
 *
 * TypeScript port of `scripts/dev_tools/_parallel_state_common.py`. Owns the S4
 * enumerations of the parallel schema together with the shape checks more than
 * one parallel validator needs: the `blast_radius` block, the per-item record,
 * and the prohibited-key scan. Every function is pure: no parsing, no I/O, no
 * entry point, and no mutation of its arguments. Each caller supplies its own
 * literal context prefix (`Parallel checkpoint` or `Parallel planner
 * checkpoint`) and appends the returned array to its own error list.
 *
 * Every enum constant is an ordered array, not a set: member order is
 * load-bearing because `enumError` renders it into the error text, which must
 * stay byte-identical to the Python source. `isInteger` from the Python module
 * is deliberately not ported -- its only consumer is
 * `parallel_manifest_contract.py`, which has no TypeScript surface. JSON erases
 * Python's int/float distinction, so a value serialized as `1.0` parses back as
 * the integer `1` here where Python sees a float; that divergence is inherent to
 * `JSON.parse`.
 */

/**
 * Split a space-separated member list into an ordered enum array, mirroring the
 * Python source's `tuple("a b c".split())` idiom so the two member lists can be
 * diffed line for line.
 *
 * @param text Space-separated member names in canonical order.
 * @returns The member names as an ordered array.
 */
function words(text: string): readonly string[] {
  return text.split(" ");
}

/** Item lifecycle states (spec S4, design sections 8.2 and 11). */
export const VALID_ITEM_STATES = words(
  "proposed admitted prepared scheduled in_flight merged withdrawn blocked",
);

/**
 * Per-item merge lifecycle (spec S4). The parallel surface replaces the epic
 * surface's merge-conflict values with the drift and per-item CI-loop failure
 * modes, because a parallel run has no fan-in merge.
 */
export const VALID_MERGE_STATUS = words(
  "not_started worktree_created pr_open ci_green merged worktree_removed blocked_drift blocked_ci_loop_limit",
);

/** Blast-radius confidence sources (spec S4, design section 5.2). */
export const VALID_SOURCES = words("derived declared observed");

/** Work-item kinds carried by the manifest and the planner checkpoint. */
export const VALID_KINDS = words("feature bug");

/** Run modes (spec S4); `closed` is the default. */
export const VALID_MODES = words("closed open");

/** Mutation operations recorded in `mutations[]` (spec S4). */
export const VALID_MUTATION_OPS = words("add remove close requeue");

/** Dispositions for an in-flight removal; a null disposition is absence. */
export const VALID_DISPOSITIONS = words("detach abandon");

/** Conflict-edge reasons, in design section 5.4 disjunct evaluation order. */
export const VALID_EDGE_REASONS = words(
  "path_overlap module_overlap shared_surface_overlap contract_dependency",
);

/** Drift-response actions (spec S4, assumption A8). */
export const VALID_DRIFT_ACTIONS = words(
  "raised_blocking_finding halted_later_started_item",
);

/** Merge-status values meaning the item reached a terminal merged outcome. */
export const MERGED_MERGE_STATUSES = words("merged worktree_removed");

/** Merge-status values meaning the item is blocked (invariant 8). */
export const BLOCKED_MERGE_STATUSES = words(
  "blocked_drift blocked_ci_loop_limit",
);

/** The four `blast_radius` collection fields in serialization order. */
export const BLAST_RADIUS_LIST_FIELDS = words(
  "paths modules shared_surfaces contracts",
);

/**
 * Keys the checkpoint schemas reject wherever they appear. `depends_on` is
 * rejected because ordering is derived from blast-radius overlap and never
 * declared; the integration-branch keys are rejected because each parallel item
 * opens its own pull request against `main` (spec S8, design section 4).
 */
export const PROHIBITED_ANY_LEVEL_KEYS = words(
  "depends_on integration_branch epic_merge_pr",
);

/** Path label for the document root in prohibited-key error strings. */
export const ROOT_PATH = "<root>";

/** Type guard for a plain object, matching Python's `isinstance(x, dict)`. */
export function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Format a value the way Python `repr` does, for byte-identical error strings.
 *
 * @param value Value to format.
 * @returns `None` for null/undefined, `True`/`False` for booleans, single-quoted
 * escaped text for strings, bracketed/braced forms for arrays and objects, and
 * the plain string form for everything else.
 */
export function pythonRepr(value: unknown): string {
  if (value === null || value === undefined) {
    return "None";
  }
  if (typeof value === "boolean") {
    return value ? "True" : "False";
  }
  if (typeof value === "string") {
    return `'${value.replace(/\\/g, "\\\\").replace(/'/g, "\\'")}'`;
  }
  if (Array.isArray(value)) {
    return `[${value.map(pythonRepr).join(", ")}]`;
  }
  if (isObject(value)) {
    const pairs = Object.entries(value).map(
      ([key, item]) => `${pythonRepr(key)}: ${pythonRepr(item)}`,
    );
    return `{${pairs.join(", ")}}`;
  }
  return String(value);
}

/** Format a value the way Python `str` does (strings unquoted, else `repr`). */
export function pythonStr(value: unknown): string {
  return typeof value === "string" ? value : pythonRepr(value);
}

/**
 * Report whether a value belongs to an ordered enum member list.
 *
 * @param members Accepted values in canonical order.
 * @param value Candidate value of any deserialized type.
 * @returns True when the value is a string present in the list.
 */
export function isEnumMember(
  members: readonly string[],
  value: unknown,
): boolean {
  return typeof value === "string" && members.includes(value);
}

/** Report whether a value is a string carrying a non-space character. */
export function isNonEmptyString(value: unknown): boolean {
  return typeof value === "string" && value.trim().length > 0;
}

/** Report whether a value is an integral number (never a boolean). */
function isIntegral(value: unknown): value is number {
  return typeof value === "number" && Number.isInteger(value);
}

/** Report whether a value is an integer greater than zero (`issue_num`). */
export function isPositiveInteger(value: unknown): boolean {
  return isIntegral(value) && value > 0;
}

/** Report whether a value is an integer of zero or more (indices, generations). */
export function isNonNegativeInteger(value: unknown): boolean {
  return isIntegral(value) && value >= 0;
}

/**
 * Report whether a value is a list whose every entry is a non-empty string. An
 * empty list passes: every blast-radius collection other than `paths` is
 * legitimately empty for an item that touches no module, surface, or contract.
 *
 * @param value Any deserialized JSON value.
 * @returns True when the value is an array of non-empty strings.
 */
export function isStringList(value: unknown): boolean {
  return Array.isArray(value) && value.every(isNonEmptyString);
}

/**
 * Report whether a value is an integer inside an inclusive numeric range.
 *
 * @param value Any deserialized JSON value.
 * @param minimum Inclusive lower bound.
 * @param maximum Inclusive upper bound.
 * @returns True for an integer within the bounds, used for `max_concurrency`.
 */
export function inBoundedRange(
  value: unknown,
  minimum: number,
  maximum: number,
): boolean {
  return isIntegral(value) && value >= minimum && value <= maximum;
}

/**
 * Build the standard out-of-enum error string for a field. All parallel
 * validators render enum violations through this one builder, so the wording
 * cannot drift between surfaces; the rendered member order is load-bearing.
 *
 * @param context Context prefix naming the object under inspection.
 * @param field Dotted field name relative to that context.
 * @param members Accepted values in canonical order.
 * @param value The offending value, rendered with Python `repr` semantics.
 * @returns The complete error string.
 */
export function enumError(
  context: string,
  field: string,
  members: readonly string[],
  value: unknown,
): string {
  return `${context} ${field} must be one of ${members.join(", ")}; found: ${pythonRepr(value)}.`;
}

/**
 * Render the context prefix for one `items[]` entry. The positional index is
 * used rather than `issue_num` because the index exists for every entry,
 * including one whose `issue_num` is missing or malformed.
 *
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @param index Zero-based position of the entry within `items`.
 * @returns The item-scoped prefix, for example `Parallel checkpoint items[0]`.
 */
export function itemContext(context: string, index: number): string {
  return `${context} items[${index}]`;
}

/**
 * Validate one `blast_radius` block against spec invariant 9.
 *
 * @param radius The candidate `blast_radius` value as deserialized.
 * @param context Context prefix naming the owning object.
 * @returns One error per violated condition, in field order: the four list
 * fields, then `source`, then `computed_at`. A non-object block yields exactly
 * one error; an empty array means invariant 9 holds.
 */
export function validateBlastRadiusBlock(
  radius: unknown,
  context: string,
): string[] {
  if (!isObject(radius)) {
    return [`${context} blast_radius must be an object.`];
  }

  const errors: string[] = [];
  // Report every malformed collection field rather than stopping at the first,
  // so one validation pass tells the author everything to fix.
  for (const field of BLAST_RADIUS_LIST_FIELDS) {
    if (!isStringList(radius[field])) {
      errors.push(
        `${context} blast_radius.${field} must be a list of non-empty strings.`,
      );
    }
  }

  const source = radius["source"];
  if (!isEnumMember(VALID_SOURCES, source)) {
    errors.push(
      enumError(context, "blast_radius.source", VALID_SOURCES, source),
    );
  }

  if (!isNonEmptyString(radius["computed_at"])) {
    errors.push(
      `${context} blast_radius.computed_at must be a non-empty string.`,
    );
  }
  return errors;
}

/**
 * Validate `merge_status` membership and its agreement with item state. Absence
 * is the backward-compatible case: an item with no `merge_status` is treated as
 * `not_started` (spec S2) and yields no error.
 *
 * @param record One `items[]` entry.
 * @param context Item-scoped context prefix.
 * @param state The entry's `state` value, already read by the caller.
 * @returns At most one error; an out-of-enum value short-circuits the
 * consistency rule, which is meaningless for a non-merge-status value.
 */
function validateMergeStatus(
  record: Record<string, unknown>,
  context: string,
  state: unknown,
): string[] {
  if (!("merge_status" in record)) {
    return [];
  }
  const mergeStatus = record["merge_status"];
  if (!isEnumMember(VALID_MERGE_STATUS, mergeStatus)) {
    return [
      enumError(context, "merge_status", VALID_MERGE_STATUS, mergeStatus),
    ];
  }

  // Invariant 8 pins the two terminal families to their item states: a merged or
  // removed worktree implies state 'merged', and either blocked status implies
  // state 'blocked'. Every other status places no constraint.
  if (isEnumMember(MERGED_MERGE_STATUSES, mergeStatus) && state !== "merged") {
    return [
      `${context} merge_status ${pythonRepr(mergeStatus)} requires state 'merged'; found: ${pythonRepr(state)}.`,
    ];
  }
  if (
    isEnumMember(BLOCKED_MERGE_STATUSES, mergeStatus) &&
    state !== "blocked"
  ) {
    return [
      `${context} merge_status ${pythonRepr(mergeStatus)} requires state 'blocked'; found: ${pythonRepr(state)}.`,
    ];
  }
  return [];
}

/**
 * Validate one work-item record against spec invariants 5 through 9.
 *
 * @param item One `items[]` entry as deserialized.
 * @param context Item-scoped context prefix from {@link itemContext}.
 * @param requireKind When true, also require `kind` in the S4 kind enum; the
 * manifest and planner surfaces carry `kind`, the orchestrator checkpoint does
 * not.
 * @returns One error per violated condition; a non-object entry yields exactly
 * one error, because no field is readable without a mapping.
 */
export function validateItemRecord(
  item: unknown,
  context: string,
  requireKind = false,
): string[] {
  if (!isObject(item)) {
    return [`${context} must be an object.`];
  }

  const errors: string[] = [];
  const issueNum = item["issue_num"];
  if (!isPositiveInteger(issueNum)) {
    errors.push(
      `${context} issue_num must be a positive integer; found: ${pythonRepr(issueNum)}.`,
    );
  }
  if (!isNonEmptyString(item["feature_folder"])) {
    errors.push(`${context} feature_folder must be a non-empty string.`);
  }

  const state = item["state"];
  if (!isEnumMember(VALID_ITEM_STATES, state)) {
    errors.push(enumError(context, "state", VALID_ITEM_STATES, state));
  }

  if (requireKind) {
    const kind = item["kind"];
    if (!isEnumMember(VALID_KINDS, kind)) {
      errors.push(enumError(context, "kind", VALID_KINDS, kind));
    }
  }

  errors.push(...validateMergeStatus(item, context, state));
  errors.push(...validateBlastRadiusBlock(item["blast_radius"], context));
  return errors;
}

/**
 * Validate the `items` collection, including `issue_num` uniqueness.
 *
 * @param items The candidate `items` value as deserialized.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @param requireKind Forwarded to {@link validateItemRecord}.
 * @returns Per-entry errors in positional order, then one duplicate-key error
 * per repeated `issue_num` in ascending key order. A non-array value yields
 * exactly one error; an empty array is valid.
 */
export function validateItems(
  items: unknown,
  context: string,
  requireKind = false,
): string[] {
  if (!Array.isArray(items)) {
    return [`${context} items must be a list.`];
  }

  const errors: string[] = [];
  const seen = new Set<number>();
  const duplicates = new Set<number>();
  // Validate each entry in place, and in the same pass accumulate the primary
  // keys so uniqueness is decided without a second traversal.
  items.forEach((entry: unknown, index: number) => {
    errors.push(
      ...validateItemRecord(entry, itemContext(context, index), requireKind),
    );
    if (!isObject(entry)) {
      return;
    }
    const issueNum = entry["issue_num"];
    if (typeof issueNum !== "number" || !Number.isInteger(issueNum)) {
      return;
    }
    if (seen.has(issueNum)) {
      duplicates.add(issueNum);
    }
    seen.add(issueNum);
  });

  // Report duplicates in ascending key order so the message sequence is
  // reproducible regardless of the order the entries appeared in.
  for (const issueNum of [...duplicates].sort((left, right) => left - right)) {
    errors.push(`${context} has duplicate items[].issue_num: ${issueNum}.`);
  }
  return errors;
}

/**
 * Walk one deserialized subtree and report prohibited keys inside it.
 *
 * @param value The subtree to inspect; only objects and arrays recurse.
 * @param path Path of `value`, {@link ROOT_PATH} at the document root.
 * @param context Surface prefix used in every emitted error.
 * @param keys Key names rejected anywhere in this subtree.
 * @returns One error per prohibited key found, in document order (depth-first,
 * object keys in insertion order).
 */
function prohibitedKeyErrors(
  value: unknown,
  path: string,
  context: string,
  keys: readonly string[],
): string[] {
  const errors: string[] = [];
  // Objects are the only place a key can appear, and arrays are traversed only
  // to reach the objects nested inside them.
  if (isObject(value)) {
    for (const [key, child] of Object.entries(value)) {
      if (keys.includes(key)) {
        errors.push(`${context} carries prohibited key '${key}' at ${path}.`);
      }
      const childPath = path === ROOT_PATH ? key : `${path}.${key}`;
      errors.push(...prohibitedKeyErrors(child, childPath, context, keys));
    }
  } else if (Array.isArray(value)) {
    value.forEach((entry: unknown, index: number) => {
      errors.push(
        ...prohibitedKeyErrors(entry, `${path}[${index}]`, context, keys),
      );
    });
  }
  return errors;
}

/**
 * Reject prohibited keys per spec invariants 10 and 11 (manifest M7).
 *
 * @param root The whole deserialized artifact.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @param deepKeys Keys rejected at any nesting level.
 * @param topLevelKeys Keys rejected at the document root only; empty for the
 * checkpoint surfaces.
 * @returns One error per prohibited key occurrence: the deep results in document
 * order, then the top-level results in `topLevelKeys` order.
 */
export function scanProhibitedKeys(
  root: unknown,
  context: string,
  deepKeys: readonly string[] = PROHIBITED_ANY_LEVEL_KEYS,
  topLevelKeys: readonly string[] = [],
): string[] {
  const errors = prohibitedKeyErrors(root, ROOT_PATH, context, deepKeys);
  // The shallow pass exists because manifest M7 bans integration_branch at the
  // top level only, where a nested occurrence is legitimate child data.
  if (isObject(root) && topLevelKeys.length > 0) {
    for (const key of topLevelKeys) {
      if (key in root) {
        errors.push(
          `${context} carries prohibited key '${key}' at ${ROOT_PATH}.`,
        );
      }
    }
  }
  return errors;
}
