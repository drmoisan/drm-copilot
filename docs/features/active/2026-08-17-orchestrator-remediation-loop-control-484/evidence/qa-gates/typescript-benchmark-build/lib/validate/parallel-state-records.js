"use strict";
/**
 * Append-only audit-record validators for the parallel checkpoint.
 *
 * Purpose:
 *     TypeScript port of `scripts/dev_tools/_parallel_state_records.py`. Enforces
 *     spec invariants 16, 17, and 18 -- the full `mutations[]` shape (schema S5)
 *     including the in-flight-removal disposition rule, and the full
 *     `drift_events[]` shape (schema S6).
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.OPS_REQUIRING_NULL_NEW_STATE = exports.OPS_REQUIRING_NULL_PRIOR_STATE = exports.OPS_REQUIRING_ITEM_KEY = void 0;
exports.validateMutations = validateMutations;
exports.validateDriftEvents = validateDriftEvents;
const parallel_state_shared_1 = require("./parallel-state-shared");
/** Operations that act on one tracked item and therefore need a resolving key. */
exports.OPS_REQUIRING_ITEM_KEY = [
    "add",
    "remove",
    "requeue",
];
/**
 * Operations for which `prior_state` must be null: `add` introduces an item that
 * had no prior state, and `close` is a run-level record (schema S5).
 */
exports.OPS_REQUIRING_NULL_PRIOR_STATE = [
    "add",
    "close",
];
/** Operations for which `new_state` must be null; only the run-level close. */
exports.OPS_REQUIRING_NULL_NEW_STATE = ["close"];
/**
 * Report whether a value is Python's `None`: JSON null or an absent key.
 *
 * @param value Candidate value.
 * @returns True for `null` or `undefined`.
 */
function isNone(value) {
    return value === null || value === undefined;
}
/**
 * Report whether a value is an integer naming a declared item.
 *
 * @param value The candidate key as deserialized.
 * @param issueNums Resolvable primary keys.
 * @returns True when the value is an integer present in the set.
 */
function resolves(value, issueNums) {
    return (typeof value === "number" && Number.isInteger(value) && issueNums.has(value));
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
function validateMutationItemKey(entry, entryContext, op, issueNums) {
    const itemKey = entry["item_key"];
    // The two branches split on whether the operation is item-scoped: close is a
    // run-level record and must carry no key, while add, remove, and requeue each
    // name exactly one tracked item.
    if (op === "close") {
        if (!isNone(itemKey)) {
            return [
                `${entryContext} item_key must be null for op 'close'; found: ${(0, parallel_state_shared_1.pythonRepr)(itemKey)}.`,
            ];
        }
        return [];
    }
    if ((0, parallel_state_shared_1.isEnumMember)(exports.OPS_REQUIRING_ITEM_KEY, op) &&
        !resolves(itemKey, issueNums)) {
        return [
            `${entryContext} item_key ${(0, parallel_state_shared_1.pythonRepr)(itemKey)} does not resolve to an items[].issue_num.`,
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
function validateMutationStateField(entry, entryContext, field, op, nullOps) {
    const value = entry[field];
    if (isNone(value)) {
        return [];
    }
    if ((0, parallel_state_shared_1.isEnumMember)(nullOps, op)) {
        return [
            `${entryContext} ${field} must be null for op ${(0, parallel_state_shared_1.pythonRepr)(op)}; found: ${(0, parallel_state_shared_1.pythonRepr)(value)}.`,
        ];
    }
    if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_ITEM_STATES, value)) {
        return [
            `${entryContext} ${field} must be null or one of ${parallel_state_shared_1.VALID_ITEM_STATES.join(", ")}; found: ${(0, parallel_state_shared_1.pythonRepr)(value)}.`,
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
function validateMutationDisposition(entry, entryContext, op) {
    const disposition = entry["disposition"];
    if (op === "remove" && entry["prior_state"] === "in_flight") {
        if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_DISPOSITIONS, disposition)) {
            return [
                `${entryContext} disposition must be one of ${parallel_state_shared_1.VALID_DISPOSITIONS.join(", ")} for an in-flight removal; found: ${(0, parallel_state_shared_1.pythonRepr)(disposition)}.`,
            ];
        }
        return [];
    }
    if (!isNone(disposition)) {
        return [
            `${entryContext} disposition must be null unless op is 'remove' with prior_state 'in_flight'; found: ${(0, parallel_state_shared_1.pythonRepr)(disposition)}.`,
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
function validateMutationGeneration(entry, entryContext, recolorGeneration) {
    const generation = entry["recolor_generation"];
    if (!(0, parallel_state_shared_1.isNonNegativeInteger)(generation)) {
        return [
            `${entryContext} recolor_generation must be a non-negative integer; found: ${(0, parallel_state_shared_1.pythonRepr)(generation)}.`,
        ];
    }
    if ((0, parallel_state_shared_1.isNonNegativeInteger)(recolorGeneration) &&
        typeof generation === "number" &&
        typeof recolorGeneration === "number" &&
        generation > recolorGeneration) {
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
function validateMutations(mutations, issueNums, recolorGeneration, context) {
    if (!Array.isArray(mutations)) {
        return [`${context} mutations must be a list.`];
    }
    const errors = [];
    // Validate every record: the mutation log is the audit trail for admissions
    // and removals, so a single malformed entry must not mask later ones.
    mutations.forEach((entry, position) => {
        const entryContext = `${context} mutations[${position}]`;
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            errors.push(`${entryContext} must be an object.`);
            return;
        }
        const op = entry["op"];
        if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_MUTATION_OPS, op)) {
            errors.push((0, parallel_state_shared_1.enumError)(entryContext, "op", parallel_state_shared_1.VALID_MUTATION_OPS, op));
        }
        errors.push(...validateMutationItemKey(entry, entryContext, op, issueNums));
        if (!(0, parallel_state_shared_1.isNonEmptyString)(entry["at"])) {
            errors.push(`${entryContext} at must be a non-empty string.`);
        }
        errors.push(...validateMutationStateField(entry, entryContext, "prior_state", op, exports.OPS_REQUIRING_NULL_PRIOR_STATE));
        errors.push(...validateMutationStateField(entry, entryContext, "new_state", op, exports.OPS_REQUIRING_NULL_NEW_STATE));
        errors.push(...validateMutationDisposition(entry, entryContext, op));
        errors.push(...validateMutationGeneration(entry, entryContext, recolorGeneration));
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
function validateDriftEvents(events, issueNums, context) {
    if (!Array.isArray(events)) {
        return [`${context} drift_events must be a list.`];
    }
    const errors = [];
    // Validate every event: each one is the evidence behind a blocking finding or
    // a halt, so partial reporting would hide part of the audit trail.
    events.forEach((entry, position) => {
        const entryContext = `${context} drift_events[${position}]`;
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            errors.push(`${entryContext} must be an object.`);
            return;
        }
        const itemKey = entry["item_key"];
        if (!resolves(itemKey, issueNums)) {
            errors.push(`${entryContext} item_key ${(0, parallel_state_shared_1.pythonRepr)(itemKey)} does not resolve to an items[].issue_num.`);
        }
        // declared and observed are the two path sets compared at detection time;
        // both may legitimately be empty, unlike escaped_paths.
        for (const field of ["declared", "observed"]) {
            if (!(0, parallel_state_shared_1.isStringList)(entry[field])) {
                errors.push(`${entryContext} ${field} must be a list of non-empty strings.`);
            }
        }
        const escapedPaths = entry["escaped_paths"];
        if (!(0, parallel_state_shared_1.isStringList)(escapedPaths) ||
            !Array.isArray(escapedPaths) ||
            escapedPaths.length === 0) {
            errors.push(`${entryContext} escaped_paths must be a non-empty list of non-empty strings.`);
        }
        if (!(0, parallel_state_shared_1.isNonEmptyString)(entry["at"])) {
            errors.push(`${entryContext} at must be a non-empty string.`);
        }
        const action = entry["action"];
        if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_DRIFT_ACTIONS, action)) {
            errors.push((0, parallel_state_shared_1.enumError)(entryContext, "action", parallel_state_shared_1.VALID_DRIFT_ACTIONS, action));
        }
    });
    return errors;
}
