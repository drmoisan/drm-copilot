"use strict";
/**
 * Retrospective mutation-protocol validation for parallel checkpoints.
 *
 * This module composes the seven-field record shape already owned by
 * `parallel-state-records.ts` with the Python mutation authority's field-set,
 * generation-accounting, operation-order, pinning, and mode rules. It is pure:
 * validation reads the parsed checkpoint and returns ordered error strings.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateMutationProtocol = validateMutationProtocol;
const parallel_state_shared_1 = require("./parallel-state-shared");
const parallel_state_structures_1 = require("./parallel-state-structures");
const parallel_orchestrator_state_mutation_receipts_1 = require("./parallel-orchestrator-state-mutation-receipts");
/** The complete mutation entry field set, in canonical serialization order. */
const MUTATION_ENTRY_FIELDS = [
    "op",
    "item_key",
    "at",
    "prior_state",
    "new_state",
    "disposition",
    "recolor_generation",
];
/** States whose removal changes the unstarted graph and increments generation. */
const UNSTARTED_ITEM_STATES = [
    "proposed",
    "admitted",
    "prepared",
    "scheduled",
];
/** Return the stable entry-scoped validation prefix. */
function entryContext(context, position) {
    return `${context} mutations[${position}]`;
}
/** Return the mutation list when its shape is readable by this additive gate. */
function mutationEntries(state) {
    const value = state["mutations"];
    return Array.isArray(value) ? value : null;
}
/** Require every canonical field and reject an unapproved eighth field. */
function validateEntryFieldSet(entry, context) {
    const errors = [];
    for (const field of MUTATION_ENTRY_FIELDS) {
        if (!(field in entry)) {
            errors.push(`${context} is missing required field: ${field}.`);
        }
    }
    for (const field of Object.keys(entry)) {
        if (!MUTATION_ENTRY_FIELDS.includes(field)) {
            errors.push(`${context} carries unexpected field: ${field}; the mutations[] entry shape is exactly ${MUTATION_ENTRY_FIELDS.join(", ")}.`);
        }
    }
    return errors;
}
/** Require a non-null state wherever the operation's null rule does not apply. */
function validateEntryCompleteness(entry, context) {
    const op = entry["op"];
    if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_structures_1.OPS_REQUIRING_ITEM_KEY, op)) {
        return [];
    }
    const operation = op;
    const requirements = [
        ["prior_state", parallel_state_structures_1.OPS_REQUIRING_NULL_PRIOR_STATE],
        ["new_state", parallel_state_structures_1.OPS_REQUIRING_NULL_NEW_STATE],
    ];
    const errors = [];
    for (const [field, nullOps] of requirements) {
        if (!nullOps.includes(operation) &&
            field in entry &&
            entry[field] === null) {
            errors.push(`${context} ${field} must not be null for op ${(0, parallel_state_shared_1.pythonRepr)(op)}.`);
        }
    }
    return errors;
}
/** Apply the complete seven-field contract to every object-shaped entry. */
function validateEntryShapes(entries, context) {
    const errors = [];
    entries.forEach((entry, position) => {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            return;
        }
        const scoped = entryContext(context, position);
        errors.push(...validateEntryFieldSet(entry, scoped));
        errors.push(...validateEntryCompleteness(entry, scoped));
    });
    return errors;
}
/** Preserve Python's non-decreasing append-order generation invariant. */
function validateGenerationMonotonicity(entries, context) {
    const errors = [];
    let highest = null;
    entries.forEach((entry, position) => {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            return;
        }
        const generation = entry["recolor_generation"];
        if (!(0, parallel_state_shared_1.isNonNegativeInteger)(generation) || typeof generation !== "number") {
            return;
        }
        if (highest !== null && generation < highest) {
            errors.push(`${entryContext(context, position)} recolor_generation ${generation} is below the preceding maximum ${highest}; the mutation log must be monotonically non-decreasing.`);
            return;
        }
        highest = generation;
    });
    return errors;
}
/** Determine whether one operation necessarily recomputes the unstarted graph. */
function requiresRecompute(entry) {
    if (entry["op"] === "requeue") {
        return (entry["prior_state"] === "in_flight" && entry["new_state"] === "blocked");
    }
    return (entry["op"] === "remove" &&
        (0, parallel_state_shared_1.isEnumMember)(UNSTARTED_ITEM_STATES, entry["prior_state"]));
}
/**
 * Validate exact generation accounting from the run's initial generation zero.
 * Recompute operations consume the next generation; non-recompute operations
 * retain the current generation. An add may either retain or increment because
 * its record does not carry the conflict decision that distinguishes the rows.
 */
function validateGenerationAccounting(entries, context) {
    const errors = [];
    let currentGeneration = 0;
    entries.forEach((entry, position) => {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            return;
        }
        const generation = entry["recolor_generation"];
        if (!(0, parallel_state_shared_1.isNonNegativeInteger)(generation) || typeof generation !== "number") {
            return;
        }
        const scoped = entryContext(context, position);
        const op = entry["op"];
        if (generation < currentGeneration) {
            return;
        }
        if (op === "add") {
            if (generation > currentGeneration + 1) {
                errors.push(`${scoped} recolor_generation ${generation} must be ${currentGeneration} or ${currentGeneration + 1} for op 'add'.`);
            }
            currentGeneration = generation;
            return;
        }
        const expected = requiresRecompute(entry)
            ? currentGeneration + 1
            : currentGeneration;
        if (generation !== expected) {
            if (op === "remove" && entry["prior_state"] === "in_flight") {
                errors.push(`${scoped} in-flight remove must preserve recolor_generation ${currentGeneration}; found: ${generation}.`);
            }
            else if (requiresRecompute(entry)) {
                errors.push(`${scoped} recolor_generation ${generation} must equal the expected recompute generation ${expected}.`);
            }
            else {
                errors.push(`${scoped} recolor_generation ${generation} must preserve generation ${expected} for op ${(0, parallel_state_shared_1.pythonRepr)(op)}.`);
            }
        }
        currentGeneration = Math.max(currentGeneration, generation);
    });
    return errors;
}
/** Validate state transitions that the base seven-field shape cannot express. */
function validateOperationOrdering(entries, state, context) {
    const errors = [];
    const addedKeys = new Set();
    const inFlightKeys = Array.isArray(state["items"])
        ? state["items"]
            .filter(parallel_state_shared_1.isObject)
            .filter((item) => item["state"] === "in_flight")
            .map((item) => item["issue_num"])
            .filter((key) => typeof key === "number" && Number.isInteger(key))
            .sort((left, right) => left - right)
        : [];
    entries.forEach((entry, position) => {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            return;
        }
        const scoped = entryContext(context, position);
        const op = entry["op"];
        const itemKey = entry["item_key"];
        if (op === "add" && typeof itemKey === "number") {
            if (addedKeys.has(itemKey)) {
                errors.push(`${scoped} records a duplicate add for item ${itemKey}.`);
            }
            addedKeys.add(itemKey);
        }
        if (op === "remove") {
            if (entry["prior_state"] === "merged") {
                errors.push(`${scoped} cannot remove item ${String(itemKey)} from prior_state 'merged'.`);
            }
            if (entry["new_state"] !== null &&
                entry["new_state"] !== undefined &&
                entry["new_state"] !== "withdrawn") {
                errors.push(`${scoped} new_state must be 'withdrawn' for op 'remove'; found: ${(0, parallel_state_shared_1.pythonRepr)(entry["new_state"])}.`);
            }
        }
        if (op === "close" && inFlightKeys.length > 0) {
            errors.push(`${scoped} close requires no item in flight; still in flight: ${(0, parallel_state_shared_1.pythonRepr)(inFlightKeys)}.`);
        }
    });
    return errors;
}
/** Return every run-close entry position in append order. */
function closePositions(entries) {
    const positions = [];
    entries.forEach((entry, position) => {
        if ((0, parallel_state_shared_1.isObject)(entry) && entry["op"] === "close") {
            positions.push(position);
        }
    });
    return positions;
}
/** Report whether a current-generation cohort still contains schedulable work. */
function hasSchedulableWork(state) {
    const cohorts = state["cohorts"];
    if (!Array.isArray(cohorts)) {
        return true;
    }
    const generation = state["recolor_generation"];
    return cohorts.some((cohort) => (0, parallel_state_shared_1.isObject)(cohort) &&
        cohort["generation"] === generation &&
        Array.isArray(cohort["item_keys"]) &&
        cohort["item_keys"].length > 0);
}
/** Apply open termination and closed two-signal completion semantics. */
function validateModeCompletion(state, entries, context) {
    const mode = state["mode"];
    const items = state["items"];
    if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_MODES, mode) || !Array.isArray(items)) {
        return [];
    }
    const closes = closePositions(entries);
    if (closes.length === 0) {
        return [];
    }
    if (mode === "open") {
        const firstClose = closes[0];
        const errors = [];
        entries.forEach((entry, position) => {
            if (position <= firstClose || !(0, parallel_state_shared_1.isObject)(entry)) {
                return;
            }
            errors.push(`${entryContext(context, position)} records op ${(0, parallel_state_shared_1.pythonRepr)(entry["op"])} after the run-close entry at mutations[${firstClose}]; an open-mode run terminates at the close record and must not auto-complete.`);
        });
        return errors;
    }
    if (hasSchedulableWork(state)) {
        return [];
    }
    const errors = [];
    items.forEach((item, index) => {
        if (!(0, parallel_state_shared_1.isObject)(item) || item["state"] === "withdrawn") {
            return;
        }
        const mergeStatus = item["merge_status"] ?? "not_started";
        if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.MERGED_MERGE_STATUSES, mergeStatus)) {
            errors.push(`${(0, parallel_state_shared_1.itemContext)(context, index)} completion invariant failed: closed mode records a mutations[] op 'close' entry but merge_status is not merged or worktree_removed; found: ${(0, parallel_state_shared_1.pythonRepr)(mergeStatus)}.`);
        }
    });
    return errors;
}
/** Validate all mutation-protocol invariants reachable from checkpoint state. */
function validateMutationProtocol(state, context) {
    const entries = mutationEntries(state);
    if (entries === null) {
        return [];
    }
    return [
        ...validateEntryShapes(entries, context),
        ...validateGenerationMonotonicity(entries, context),
        ...validateGenerationAccounting(entries, context),
        ...validateOperationOrdering(entries, state, context),
        ...validateModeCompletion(state, entries, context),
        ...(0, parallel_orchestrator_state_mutation_receipts_1.validateMutationReceiptBindings)(state, context),
    ];
}
