/**
 * Append-only audit-record validators for the parallel checkpoint.
 *
 * Purpose:
 *     TypeScript port of `scripts/dev_tools/_parallel_state_records.py`. Enforces
 *     spec invariants 16, 17, and 18 -- the full `mutations[]` shape (schema S5)
 *     including the in-flight-removal disposition rule, and the full
 *     `drift_events[]` shape (schema S6) -- and, presence-gated, the recorded
 *     scheduling estimates, verdicts, access lists, and precedence kinds
 *     (issue #1164).
 *
 * Responsibilities:
 *     Validate shape, enum membership, op-specific null rules, and item-key
 *     resolution. State-transition legality -- which item state may follow which
 *     -- is deliberately NOT checked here: that is F6 behavior, not F3 schema.
 *     This module is an implementation detail of `parallel-state-structures.ts`,
 *     which re-exports both public functions; callers import from that module.
 *     It lives apart only so neither file exceeds the 500-line limit, mirroring
 *     the same split on the Python side.
 *
 * Invariants / Constraints:
 *     - Error strings are byte-identical to the Python source.
 *     - A JSON `null` and an absent key are both Python `None` here, so both are
 *       treated as the null case exactly as `dict.get` does.
 *
 * Side Effects:
 *     None; every function is pure and never mutates its arguments.
 */

import {
  VALID_DISPOSITIONS,
  VALID_DRIFT_ACTIONS,
  VALID_EDGE_REASONS,
  VALID_ITEM_STATES,
  VALID_MUTATION_OPS,
  enumError,
  isEnumMember,
  isNonEmptyString,
  isNonNegativeInteger,
  isObject,
  isStringList,
  itemContext,
  pythonRepr,
} from "./parallel-state-shared";

/** Operations that act on one tracked item and therefore need a resolving key. */
const OPS_REQUIRING_ITEM_KEY: readonly string[] = ["add", "remove", "requeue"];

/**
 * Operations for which `prior_state` must be null: `add` introduces an item that
 * had no prior state, and `close` is a run-level record (schema S5).
 */
const OPS_REQUIRING_NULL_PRIOR_STATE: readonly string[] = ["add", "close"];

/** Operations for which `new_state` must be null; only the run-level close. */
const OPS_REQUIRING_NULL_NEW_STATE: readonly string[] = ["close"];

/**
 * Report whether a value is Python's `None`: JSON null or an absent key.
 *
 * @param value Candidate value.
 * @returns True for `null` or `undefined`.
 */
function isNone(value: unknown): boolean {
  return value === null || value === undefined;
}

/**
 * Report whether a value is an integer naming a declared item.
 *
 * @param value The candidate key as deserialized.
 * @param issueNums Resolvable primary keys.
 * @returns True when the value is an integer present in the set.
 */
function resolves(value: unknown, issueNums: ReadonlySet<number>): boolean {
  return (
    typeof value === "number" && Number.isInteger(value) && issueNums.has(value)
  );
}

/**
 * Validate `item_key` against the op-specific rule in schema S5.
 *
 * @param entry One object-shaped mutation record.
 * @param entryContext Context prefix naming this entry.
 * @param op The entry's `op` value, already read by the caller.
 * @param issueNums Resolvable primary keys.
 * @returns At most one error. An out-of-enum `op` produces none, because the key
 * rule is undefined for an operation that does not exist.
 */
function validateMutationItemKey(
  entry: Record<string, unknown>,
  entryContext: string,
  op: unknown,
  issueNums: ReadonlySet<number>,
): string[] {
  const itemKey = entry["item_key"];
  // The two branches split on whether the operation is item-scoped: close is a
  // run-level record and must carry no key, while add, remove, and requeue each
  // name exactly one tracked item.
  if (op === "close") {
    if (!isNone(itemKey)) {
      return [
        `${entryContext} item_key must be null for op 'close'; found: ${pythonRepr(itemKey)}.`,
      ];
    }
    return [];
  }
  if (
    isEnumMember(OPS_REQUIRING_ITEM_KEY, op) &&
    !resolves(itemKey, issueNums)
  ) {
    return [
      `${entryContext} item_key ${pythonRepr(itemKey)} does not resolve to an items[].issue_num.`,
    ];
  }
  return [];
}

/**
 * Validate `prior_state` or `new_state` against schema S5.
 *
 * @param entry One object-shaped mutation record.
 * @param entryContext Context prefix naming this entry.
 * @param field Either `prior_state` or `new_state`.
 * @param op The entry's `op` value.
 * @param nullOps Operations for which the field must be null.
 * @returns At most one error. Null always satisfies the field's type; the
 * op-specific rule is checked before enum membership so an `add` carrying a
 * valid state reports the rule it actually broke.
 */
function validateMutationStateField(
  entry: Record<string, unknown>,
  entryContext: string,
  field: string,
  op: unknown,
  nullOps: readonly string[],
): string[] {
  const value = entry[field];
  if (isNone(value)) {
    return [];
  }
  if (isEnumMember(nullOps, op)) {
    return [
      `${entryContext} ${field} must be null for op ${pythonRepr(op)}; found: ${pythonRepr(value)}.`,
    ];
  }
  if (!isEnumMember(VALID_ITEM_STATES, value)) {
    return [
      `${entryContext} ${field} must be null or one of ${VALID_ITEM_STATES.join(", ")}; found: ${pythonRepr(value)}.`,
    ];
  }
  return [];
}

/**
 * Validate `disposition` against invariant 17.
 *
 * @param entry One object-shaped mutation record.
 * @param entryContext Context prefix naming this entry.
 * @param op The entry's `op` value.
 * @returns At most one error. An in-flight removal must record how the running
 * work was disposed of; every other entry must leave the field null, so a stray
 * disposition cannot imply a decision never taken.
 */
function validateMutationDisposition(
  entry: Record<string, unknown>,
  entryContext: string,
  op: unknown,
): string[] {
  const disposition = entry["disposition"];
  if (op === "remove" && entry["prior_state"] === "in_flight") {
    if (!isEnumMember(VALID_DISPOSITIONS, disposition)) {
      return [
        `${entryContext} disposition must be one of ${VALID_DISPOSITIONS.join(", ")} for an in-flight removal; found: ${pythonRepr(disposition)}.`,
      ];
    }
    return [];
  }
  if (!isNone(disposition)) {
    return [
      `${entryContext} disposition must be null unless op is 'remove' with prior_state 'in_flight'; found: ${pythonRepr(disposition)}.`,
    ];
  }
  return [];
}

/**
 * Validate a mutation's `recolor_generation` against schema S5.
 *
 * @param entry One object-shaped mutation record.
 * @param entryContext Context prefix naming this entry.
 * @param recolorGeneration The top-level generation counter.
 * @returns At most one error. The upper-bound comparison is skipped when the
 * top-level counter is itself malformed, so one defect is not reported twice.
 */
function validateMutationGeneration(
  entry: Record<string, unknown>,
  entryContext: string,
  recolorGeneration: unknown,
): string[] {
  const generation = entry["recolor_generation"];
  if (!isNonNegativeInteger(generation)) {
    return [
      `${entryContext} recolor_generation must be a non-negative integer; found: ${pythonRepr(generation)}.`,
    ];
  }
  if (
    isNonNegativeInteger(recolorGeneration) &&
    typeof generation === "number" &&
    typeof recolorGeneration === "number" &&
    generation > recolorGeneration
  ) {
    return [
      `${entryContext} recolor_generation ${generation} must not exceed recolor_generation ${recolorGeneration}.`,
    ];
  }
  return [];
}

/**
 * Validate `mutations[]` against invariants 16 and 17 (schema S5).
 *
 * @param mutations The candidate `mutations` value as deserialized.
 * @param issueNums Resolvable primary keys.
 * @param recolorGeneration The top-level generation counter.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns One error per violated condition, in field order per entry. A
 * non-array value yields exactly one error; an empty array is valid.
 */
export function validateMutations(
  mutations: unknown,
  issueNums: ReadonlySet<number>,
  recolorGeneration: unknown,
  context: string,
): string[] {
  if (!Array.isArray(mutations)) {
    return [`${context} mutations must be a list.`];
  }

  const errors: string[] = [];
  // Validate every record: the mutation log is the audit trail for admissions
  // and removals, so a single malformed entry must not mask later ones.
  mutations.forEach((entry: unknown, position: number) => {
    const entryContext = `${context} mutations[${position}]`;
    if (!isObject(entry)) {
      errors.push(`${entryContext} must be an object.`);
      return;
    }

    const op = entry["op"];
    if (!isEnumMember(VALID_MUTATION_OPS, op)) {
      errors.push(enumError(entryContext, "op", VALID_MUTATION_OPS, op));
    }
    errors.push(...validateMutationItemKey(entry, entryContext, op, issueNums));
    if (!isNonEmptyString(entry["at"])) {
      errors.push(`${entryContext} at must be a non-empty string.`);
    }
    errors.push(
      ...validateMutationStateField(
        entry,
        entryContext,
        "prior_state",
        op,
        OPS_REQUIRING_NULL_PRIOR_STATE,
      ),
    );
    errors.push(
      ...validateMutationStateField(
        entry,
        entryContext,
        "new_state",
        op,
        OPS_REQUIRING_NULL_NEW_STATE,
      ),
    );
    errors.push(...validateMutationDisposition(entry, entryContext, op));
    errors.push(
      ...validateMutationGeneration(entry, entryContext, recolorGeneration),
    );
  });
  return errors;
}

/**
 * Validate `drift_events[]` against invariant 18 (schema S6).
 *
 * @param events The candidate `drift_events` value as deserialized.
 * @param issueNums Resolvable primary keys.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns One error per violated condition, in field order per entry. A
 * non-array value yields exactly one error; an empty array is valid.
 */
export function validateDriftEvents(
  events: unknown,
  issueNums: ReadonlySet<number>,
  context: string,
): string[] {
  if (!Array.isArray(events)) {
    return [`${context} drift_events must be a list.`];
  }

  const errors: string[] = [];
  // Validate every event: each one is the evidence behind a blocking finding or
  // a halt, so partial reporting would hide part of the audit trail.
  events.forEach((entry: unknown, position: number) => {
    const entryContext = `${context} drift_events[${position}]`;
    if (!isObject(entry)) {
      errors.push(`${entryContext} must be an object.`);
      return;
    }

    const itemKey = entry["item_key"];
    if (!resolves(itemKey, issueNums)) {
      errors.push(
        `${entryContext} item_key ${pythonRepr(itemKey)} does not resolve to an items[].issue_num.`,
      );
    }
    // declared and observed are the two path sets compared at detection time;
    // both may legitimately be empty, unlike escaped_paths.
    for (const field of ["declared", "observed"]) {
      if (!isStringList(entry[field])) {
        errors.push(
          `${entryContext} ${field} must be a list of non-empty strings.`,
        );
      }
    }

    const escapedPaths = entry["escaped_paths"];
    if (
      !isStringList(escapedPaths) ||
      !Array.isArray(escapedPaths) ||
      escapedPaths.length === 0
    ) {
      errors.push(
        `${entryContext} escaped_paths must be a non-empty list of non-empty strings.`,
      );
    }
    if (!isNonEmptyString(entry["at"])) {
      errors.push(`${entryContext} at must be a non-empty string.`);
    }

    const action = entry["action"];
    if (!isEnumMember(VALID_DRIFT_ACTIONS, action)) {
      errors.push(
        enumError(entryContext, "action", VALID_DRIFT_ACTIONS, action),
      );
    }
  });
  return errors;
}

/**
 * Reason kinds that make a pair an edge at every tolerance (issue #722), so a
 * tolerated overlap never carries one (issue #1164).
 */
const HARD_EDGE_REASONS: readonly string[] = [
  "shared_surface_overlap",
  "contract_dependency",
];

/** The precedence kinds of issue #1164: a re-tested cost ordering, or a correctness ordering. */
const VALID_PRECEDENCE_KINDS: readonly string[] = ["cost", "correctness"];

/** The optional item access lists of issue #1164, recorded beside `blast_radius`. */
const ACCESS_LIST_FIELDS: readonly string[] = ["read_paths", "separable_paths"];

/**
 * A canonical `(a, b)` pair rendered as one key for set membership.
 *
 * @param first The lower issue number of the pair.
 * @param second The higher issue number of the pair.
 * @returns The key `first,second`.
 */
function pairKey(first: number, second: number): string {
  return `${String(first)},${String(second)}`;
}

/**
 * Reject a present `cost` or `benefit` that is not a non-negative integer.
 *
 * @param entry One object-shaped pair record.
 * @param entryContext Context prefix naming this entry.
 * @returns One error per malformed estimate; an absent estimate is valid.
 */
function estimateErrors(
  entry: Record<string, unknown>,
  entryContext: string,
): string[] {
  // Check each estimate field the entry carries; an absent field is not an error.
  return ["cost", "benefit"]
    .filter((field) => field in entry && !isNonNegativeInteger(entry[field]))
    .map(
      (field) =>
        `${entryContext} ${field} must be a non-negative integer; found: ${pythonRepr(entry[field])}.`,
    );
}

/**
 * Return a tolerated overlap's endpoint errors and its canonical pair.
 *
 * @param entry One object-shaped tolerated overlap.
 * @param entryContext Context prefix naming this entry.
 * @param issueNums Resolvable primary keys.
 * @returns The errors and the pair, or `null` when the endpoints are unusable.
 */
function overlapPair(
  entry: Record<string, unknown>,
  entryContext: string,
  issueNums: ReadonlySet<number>,
): { errors: string[]; pair: [number, number] | null } {
  const errors: string[] = [];
  const endpoints: number[] = [];
  // Resolve both endpoints so a bad `a` does not hide a bad `b`.
  for (const field of ["a", "b"]) {
    const value = entry[field];
    if (resolves(value, issueNums)) {
      endpoints.push(value as number);
    } else {
      errors.push(
        `${entryContext} ${field} ${pythonRepr(value)} does not resolve to an items[].issue_num.`,
      );
    }
  }
  const [first, second] = endpoints;
  if (first === undefined || second === undefined) {
    return { errors, pair: null };
  }
  if (first === second) {
    return {
      errors: [
        `${entryContext} endpoints must be distinct; found: ${String(first)}.`,
      ],
      pair: null,
    };
  }
  if (first > second) {
    return {
      errors: [
        `${entryContext} must be normalized with a < b; found: (${String(first)}, ${String(second)}).`,
      ],
      pair: null,
    };
  }
  return { errors, pair: [first, second] };
}

/**
 * Check a tolerated overlap's `reasons`: non-empty, in the enum, never hard.
 *
 * @param reasons The candidate `reasons` value.
 * @param entryContext Context prefix naming this entry.
 * @returns At most one error.
 */
function reasonErrors(reasons: unknown, entryContext: string): string[] {
  const entries: unknown[] = Array.isArray(reasons) ? reasons : [];
  let rule: string;
  // Shape and enum membership are checked first: an unknown reason is reported
  // as such even when a hard reason is also present.
  if (
    entries.length === 0 ||
    entries.some((entry) => !isEnumMember(VALID_EDGE_REASONS, entry))
  ) {
    rule = `must be a non-empty list drawn from ${VALID_EDGE_REASONS.join(", ")}`;
    // A hard reason is always an edge, so it can never be tolerated (issue #722).
  } else if (entries.some((entry) => isEnumMember(HARD_EDGE_REASONS, entry))) {
    rule = "must not contain a hard reason";
  } else {
    return [];
  }
  return [`${entryContext} reasons ${rule}; found: ${pythonRepr(reasons)}.`];
}

/**
 * Validate `tolerated_overlaps[]` and collect its canonical pairs.
 *
 * @param overlaps The candidate `tolerated_overlaps` value.
 * @param issueNums Resolvable primary keys.
 * @param context Surface prefix.
 * @returns The errors in entry and field order, and the canonical pair keys.
 */
function validateToleratedOverlaps(
  overlaps: unknown,
  issueNums: ReadonlySet<number>,
  context: string,
): { errors: string[]; pairs: Set<string> } {
  const pairs = new Set<string>();
  if (!Array.isArray(overlaps)) {
    return { errors: [`${context} tolerated_overlaps must be a list.`], pairs };
  }
  const errors: string[] = [];
  // Validate every entry in field order so one malformed entry hides no other.
  overlaps.forEach((entry: unknown, position: number) => {
    const entryContext = `${context} tolerated_overlaps[${String(position)}]`;
    if (!isObject(entry)) {
      errors.push(`${entryContext} must be an object.`);
      return;
    }
    const endpoint = overlapPair(entry, entryContext, issueNums);
    errors.push(...endpoint.errors);
    errors.push(...reasonErrors(entry["reasons"], entryContext));
    errors.push(...estimateErrors(entry, entryContext));
    if (endpoint.pair !== null) {
      pairs.add(pairKey(endpoint.pair[0], endpoint.pair[1]));
    }
  });
  return { errors, pairs };
}

/**
 * Check the optional edge estimates and collect each edge's unordered pair.
 *
 * @param edges The candidate `conflict_edges` value; its shape is checked elsewhere.
 * @param context Surface prefix.
 * @returns The estimate errors and the unordered pair keys.
 */
function edgeErrors(
  edges: unknown,
  context: string,
): { errors: string[]; pairs: Set<string> } {
  const errors: string[] = [];
  const pairs = new Set<string>();
  const entries: unknown[] = Array.isArray(edges) ? edges : [];
  // validateConflictEdges owns the edge shape; only object entries are read.
  entries.forEach((entry: unknown, position: number) => {
    if (!isObject(entry)) {
      return;
    }
    const entryContext = `${context} conflict_edges[${String(position)}]`;
    if ("hard" in entry && typeof entry["hard"] !== "boolean") {
      errors.push(`${entryContext} hard must be a boolean.`);
    }
    errors.push(...estimateErrors(entry, entryContext));
    const a = entry["a"];
    const b = entry["b"];
    if (isNonNegativeInteger(a) && isNonNegativeInteger(b) && a !== b) {
      const low = Math.min(a as number, b as number);
      const high = Math.max(a as number, b as number);
      pairs.add(pairKey(low, high));
    }
  });
  return { errors, pairs };
}

/**
 * Check each item's optional access lists against its `blast_radius.paths`.
 *
 * @param items The candidate `items` value.
 * @param context Surface prefix.
 * @returns One error per malformed list or out-of-radius entry.
 */
function accessListErrors(items: unknown, context: string): string[] {
  const errors: string[] = [];
  const entries: unknown[] = Array.isArray(items) ? items : [];
  // Check every item; a non-object item reads as an item with no access lists.
  entries.forEach((entry: unknown, index: number) => {
    const record = isObject(entry) ? entry : {};
    const radius = isObject(record["blast_radius"])
      ? record["blast_radius"]
      : {};
    const paths = radius["paths"];
    const declared: unknown[] = Array.isArray(paths) ? paths : [];
    // Visit only the access-list fields the item declares, in canonical order.
    for (const field of ACCESS_LIST_FIELDS.filter((name) => name in record)) {
      const prefix = `${itemContext(context, index)} ${field}`;
      const value = record[field];
      if (!isStringList(value) || !Array.isArray(value)) {
        errors.push(`${prefix} must be a list of non-empty strings.`);
        continue;
      }
      // A declaration never narrows a radius (spec B5.1, B5.4).
      for (const path of value) {
        if (!declared.includes(path)) {
          errors.push(
            `${prefix} entry ${pythonRepr(path)} is not in blast_radius.paths.`,
          );
        }
      }
    }
  });
  return errors;
}

/**
 * Check each precedence entry's optional `kind` and its `reason` rule.
 *
 * @param precedence The candidate `precedence` value.
 * @param context Surface prefix.
 * @returns One error per malformed entry.
 */
function precedenceErrors(precedence: unknown, context: string): string[] {
  const errors: string[] = [];
  const entries: unknown[] = Array.isArray(precedence) ? precedence : [];
  // Only entries that carry `kind` are checked, so legacy entries stay valid.
  entries.forEach((entry: unknown, position: number) => {
    if (!isObject(entry) || !("kind" in entry)) {
      return;
    }
    const entryContext = `${context} precedence[${String(position)}]`;
    const kind = entry["kind"];
    if (!isEnumMember(VALID_PRECEDENCE_KINDS, kind)) {
      errors.push(
        enumError(entryContext, "kind", VALID_PRECEDENCE_KINDS, kind),
      );
    } else if (kind === "correctness" && !isNonEmptyString(entry["reason"])) {
      errors.push(
        `${entryContext} reason must be a non-empty string when kind is 'correctness'.`,
      );
    }
  });
  return errors;
}

/**
 * Validate the recorded scheduling estimates and verdicts (issue #1164, spec
 * B10.1). Port of `validate_scheduling_decisions` with byte-identical errors.
 * Every check is presence-gated, so a checkpoint without the fields yields no
 * error (B10.2).
 *
 * @param state The parsed checkpoint object.
 * @param issueNums Resolvable primary keys.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns Edge estimate errors, tolerated-overlap errors, one both-lists error
 * per shared unordered pair in ascending order, item access-list errors, then
 * precedence `kind` and `reason` errors.
 */
export function validateSchedulingDecisions(
  state: Record<string, unknown>,
  issueNums: ReadonlySet<number>,
  context: string,
): string[] {
  const edges = edgeErrors(state["conflict_edges"], context);
  const errors = [...edges.errors];
  let overlapPairs = new Set<string>();
  if ("tolerated_overlaps" in state) {
    const overlaps = validateToleratedOverlaps(
      state["tolerated_overlaps"],
      issueNums,
      context,
    );
    errors.push(...overlaps.errors);
    overlapPairs = overlaps.pairs;
  }
  // A pair is either an edge or tolerated, never both (spec Data & State).
  const shared = [...edges.pairs]
    .filter((key) => overlapPairs.has(key))
    .map((key) => key.split(",").map(Number) as [number, number])
    .sort((left, right) => left[0] - right[0] || left[1] - right[1]);
  // Report each shared pair once, in ascending pair order.
  for (const [first, second] of shared) {
    errors.push(
      `${context} pair (${String(first)}, ${String(second)}) is in both conflict_edges and tolerated_overlaps.`,
    );
  }
  errors.push(...accessListErrors(state["items"], context));
  errors.push(...precedenceErrors(state["precedence"], context));
  return errors;
}
