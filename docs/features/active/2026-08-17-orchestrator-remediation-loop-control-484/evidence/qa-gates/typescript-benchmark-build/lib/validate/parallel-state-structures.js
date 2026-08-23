"use strict";
/**
 * Collection validators for the parallel-orchestration checkpoint structures.
 *
 * TypeScript port of `scripts/dev_tools/_parallel_state_structures.py`. Enforces
 * the shape of the four checkpoint collections that carry scheduling and audit
 * state -- `cohorts[]`, `conflict_edges[]`, `mutations[]`, and `drift_events[]`
 * -- plus the loose receipt-array check, covering spec invariants 12 through 19.
 * Shape, enum membership, and item-key resolution only: cohort assignment is
 * computed by the planner and never recomputed here, and state-transition
 * legality is F6 behavior. Every function is pure and never mutates its input.
 *
 * `issue_num` is the primary key (assumption A4), so every `item_keys` entry,
 * edge endpoint, mutation `item_key`, and drift `item_key` is an integer that
 * must resolve to an `items[].issue_num`. Errors that aggregate across entries
 * (duplicate cohort index, duplicate edge pair) are emitted in ascending key
 * order so the sequence is reproducible and byte-identical to the Python source.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.RECEIPT_ARRAY_KEYS = exports.COHORT_COVERAGE_EXEMPT_STATES = exports.validateMutations = exports.validateDriftEvents = exports.OPS_REQUIRING_NULL_PRIOR_STATE = exports.OPS_REQUIRING_NULL_NEW_STATE = exports.OPS_REQUIRING_ITEM_KEY = void 0;
exports.collectItemKeysAndStates = collectItemKeysAndStates;
exports.collectIssueNumbers = collectIssueNumbers;
exports.validateCohortShapes = validateCohortShapes;
exports.validateCurrentGenerationCohorts = validateCurrentGenerationCohorts;
exports.validateCurrentCohortBound = validateCurrentCohortBound;
exports.validateConflictEdges = validateConflictEdges;
exports.validateReceiptArrays = validateReceiptArrays;
const parallel_state_shared_1 = require("./parallel-state-shared");
// The mutations and drift-event validators live in `parallel-state-records.ts`
// so neither file exceeds the repository's 500-line limit, and are re-exported
// here so callers depend on this one module for every collection validator.
var parallel_state_records_1 = require("./parallel-state-records");
Object.defineProperty(exports, "OPS_REQUIRING_ITEM_KEY", { enumerable: true, get: function () { return parallel_state_records_1.OPS_REQUIRING_ITEM_KEY; } });
Object.defineProperty(exports, "OPS_REQUIRING_NULL_NEW_STATE", { enumerable: true, get: function () { return parallel_state_records_1.OPS_REQUIRING_NULL_NEW_STATE; } });
Object.defineProperty(exports, "OPS_REQUIRING_NULL_PRIOR_STATE", { enumerable: true, get: function () { return parallel_state_records_1.OPS_REQUIRING_NULL_PRIOR_STATE; } });
Object.defineProperty(exports, "validateDriftEvents", { enumerable: true, get: function () { return parallel_state_records_1.validateDriftEvents; } });
Object.defineProperty(exports, "validateMutations", { enumerable: true, get: function () { return parallel_state_records_1.validateMutations; } });
/**
 * Item states exempt from current-generation cohort coverage (invariant 13). A
 * withdrawn item left the run; a merged or blocked item is terminal, so neither
 * is scheduled into the next cohort barrier.
 */
exports.COHORT_COVERAGE_EXEMPT_STATES = "withdrawn merged blocked".split(" ");
/** Optional receipt arrays validated for list type only (invariant 19). */
exports.RECEIPT_ARRAY_KEYS = "delegation_receipts skill_receipts mcp_call_receipts".split(" ");
/**
 * Extract the primary key and state of every well-formed `items[]` entry, in
 * document order. A non-array `items` yields an empty result, because its shape
 * error belongs to the item validator.
 *
 * @param items The candidate `items` value as deserialized.
 * @returns One pair per object-shaped entry with a positive integer key.
 */
function collectItemKeysAndStates(items) {
    const pairs = [];
    if (!Array.isArray(items)) {
        return pairs;
    }
    // Skip entries whose primary key is unusable: without a key they cannot
    // participate in cohort coverage or edge resolution at all.
    for (const entry of items) {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            continue;
        }
        const issueNum = entry["issue_num"];
        if (typeof issueNum === "number" &&
            Number.isInteger(issueNum) &&
            issueNum > 0) {
            pairs.push({ issueNum, state: entry["state"] });
        }
    }
    return pairs;
}
/**
 * Return the set of resolvable `issue_num` primary keys. Membership in this set
 * is what "resolves to an `items[].issue_num`" means throughout invariants 12,
 * 15, 16, and 18.
 *
 * @param items The candidate `items` value as deserialized.
 * @returns Every positive integer `issue_num` on an object-shaped entry.
 */
function collectIssueNumbers(items) {
    return new Set(collectItemKeysAndStates(items).map((pair) => pair.issueNum));
}
/**
 * Validate one `cohorts[]` entry against invariant 12.
 *
 * @param entry One object-shaped cohort record.
 * @param entryContext Context prefix naming this entry.
 * @param issueNums Resolvable primary keys.
 * @param recolorGeneration The validated top-level counter, or null when the
 * counter itself was malformed; the generation-bound check is then skipped so
 * one underlying defect is not reported twice.
 * @returns One error per violated condition on this entry.
 */
function validateCohortEntry(entry, entryContext, issueNums, recolorGeneration) {
    const errors = [];
    const index = entry["index"];
    if (!(0, parallel_state_shared_1.isNonNegativeInteger)(index)) {
        errors.push(`${entryContext} index must be a non-negative integer; found: ${(0, parallel_state_shared_1.pythonRepr)(index)}.`);
    }
    const generation = entry["generation"];
    if (!(0, parallel_state_shared_1.isNonNegativeInteger)(generation)) {
        errors.push(`${entryContext} generation must be a non-negative integer; found: ${(0, parallel_state_shared_1.pythonRepr)(generation)}.`);
    }
    else if (recolorGeneration !== null &&
        typeof generation === "number" &&
        generation > recolorGeneration) {
        errors.push(`${entryContext} generation ${generation} must not exceed recolor_generation ${recolorGeneration}.`);
    }
    const itemKeys = entry["item_keys"];
    if (!Array.isArray(itemKeys)) {
        errors.push(`${entryContext} item_keys must be a list.`);
        return errors;
    }
    // Every member key must name a declared item; an unresolved key would
    // silently schedule work that the run does not track.
    for (const key of itemKeys) {
        if (typeof key !== "number" ||
            !Number.isInteger(key) ||
            !issueNums.has(key)) {
            errors.push(`${entryContext} item_keys entry ${(0, parallel_state_shared_1.pythonRepr)(key)} does not resolve to an items[].issue_num.`);
        }
    }
    return errors;
}
/**
 * Validate `recolor_generation` and `cohorts[]` shape (invariant 12).
 *
 * @param cohorts The candidate `cohorts` value as deserialized.
 * @param issueNums Resolvable primary keys from {@link collectIssueNumbers}.
 * @param recolorGeneration The top-level generation counter, which bounds each
 * cohort's own `generation`.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns One error per violated condition. A non-array `cohorts` yields
 * exactly one collection-level error; an empty array is valid.
 */
function validateCohortShapes(cohorts, issueNums, recolorGeneration, context) {
    const errors = [];
    const generationOk = (0, parallel_state_shared_1.isNonNegativeInteger)(recolorGeneration);
    if (!generationOk) {
        errors.push(`${context} recolor_generation must be a non-negative integer; found: ${(0, parallel_state_shared_1.pythonRepr)(recolorGeneration)}.`);
    }
    if (!Array.isArray(cohorts)) {
        errors.push(`${context} cohorts must be a list.`);
        return errors;
    }
    const bound = generationOk && typeof recolorGeneration === "number"
        ? recolorGeneration
        : null;
    // Validate every entry rather than stopping at the first malformed one, so a
    // single pass reports the whole coloring's defects.
    cohorts.forEach((entry, position) => {
        const entryContext = `${context} cohorts[${position}]`;
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            errors.push(`${entryContext} must be an object.`);
            return;
        }
        errors.push(...validateCohortEntry(entry, entryContext, issueNums, bound));
    });
    return errors;
}
/**
 * Select the `cohorts[]` entries belonging to the current generation, in
 * document order. Empty when the counter is malformed, because no entry can be
 * attributed to a non-numeric generation.
 *
 * @param cohorts The candidate `cohorts` value as deserialized.
 * @param recolorGeneration The top-level generation counter.
 * @returns Object-shaped entries whose `generation` equals the counter.
 */
function currentGenerationCohorts(cohorts, recolorGeneration) {
    if (!(0, parallel_state_shared_1.isNonNegativeInteger)(recolorGeneration) || !Array.isArray(cohorts)) {
        return [];
    }
    // Non-object entries are skipped: their shape error is already reported by
    // validateCohortShapes, and they carry no usable generation.
    return cohorts
        .filter(parallel_state_shared_1.isObject)
        .filter((entry) => entry["generation"] === recolorGeneration);
}
/**
 * Validate current-generation index uniqueness and coverage (invariant 13). The
 * coverage rule is "exactly one" (spec decision, research R5): the coloring is a
 * pure function over the unstarted subgraph, so a partial coloring means the
 * checkpoint was written mid-recompute.
 *
 * @param cohorts The candidate `cohorts` value as deserialized.
 * @param items The candidate `items` value as deserialized.
 * @param recolorGeneration The top-level generation counter.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns Duplicate-index errors in ascending index order, then coverage errors
 * in ascending `issue_num` order. An item absent from every current-generation
 * cohort is accepted only in state `withdrawn`, `merged`, or `blocked`.
 */
function validateCurrentGenerationCohorts(cohorts, items, recolorGeneration, context) {
    const current = currentGenerationCohorts(cohorts, recolorGeneration);
    const errors = [];
    const seenIndices = new Set();
    const duplicateIndices = new Set();
    const membershipCounts = new Map();
    // One pass builds both aggregates: the index multiset for uniqueness and the
    // per-item appearance count for the exactly-one coverage rule.
    for (const entry of current) {
        const index = entry["index"];
        if ((0, parallel_state_shared_1.isNonNegativeInteger)(index) && typeof index === "number") {
            if (seenIndices.has(index)) {
                duplicateIndices.add(index);
            }
            seenIndices.add(index);
        }
        const itemKeys = entry["item_keys"];
        if (!Array.isArray(itemKeys)) {
            continue;
        }
        for (const key of itemKeys) {
            if (typeof key === "number" && Number.isInteger(key)) {
                membershipCounts.set(key, (membershipCounts.get(key) ?? 0) + 1);
            }
        }
    }
    for (const index of [...duplicateIndices].sort((left, right) => left - right)) {
        errors.push(`${context} has duplicate current-generation cohorts[].index: ${index}.`);
    }
    // Compare declared items against the coloring: a non-exempt item must land in
    // exactly one cohort, and no item may land in more than one.
    const pairs = [...collectItemKeysAndStates(items)].sort((left, right) => left.issueNum - right.issueNum);
    for (const { issueNum, state } of pairs) {
        const count = membershipCounts.get(issueNum) ?? 0;
        if (count === 1) {
            continue;
        }
        if (count === 0 && (0, parallel_state_shared_1.isEnumMember)(exports.COHORT_COVERAGE_EXEMPT_STATES, state)) {
            continue;
        }
        errors.push(`${context} item ${issueNum} in state ${(0, parallel_state_shared_1.pythonRepr)(state)} must appear in exactly one current-generation cohort; found ${count}.`);
    }
    return errors;
}
/**
 * Validate the `current_cohort` pointer against invariant 14. The bound check
 * runs only when at least one current-generation cohort carries a usable
 * `index`; with no current-generation coloring there is no maximum to exceed.
 *
 * @param currentCohort The candidate pointer as deserialized.
 * @param cohorts The candidate `cohorts` value as deserialized.
 * @param recolorGeneration The top-level generation counter.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns At most one error.
 */
function validateCurrentCohortBound(currentCohort, cohorts, recolorGeneration, context) {
    if (!(0, parallel_state_shared_1.isNonNegativeInteger)(currentCohort) ||
        typeof currentCohort !== "number") {
        return [
            `${context} current_cohort must be a non-negative integer; found: ${(0, parallel_state_shared_1.pythonRepr)(currentCohort)}.`,
        ];
    }
    const indices = [];
    for (const entry of currentGenerationCohorts(cohorts, recolorGeneration)) {
        const index = entry["index"];
        if ((0, parallel_state_shared_1.isNonNegativeInteger)(index) && typeof index === "number") {
            indices.push(index);
        }
    }
    if (indices.length === 0) {
        return [];
    }
    const highest = Math.max(...indices);
    if (currentCohort > highest) {
        return [
            `${context} current_cohort ${currentCohort} must not exceed the maximum current-generation cohorts[].index ${highest}.`,
        ];
    }
    return [];
}
/**
 * Validate one edge's `a` and `b` endpoints against invariant 15.
 *
 * @param entry One object-shaped `conflict_edges[]` entry.
 * @param entryContext Context prefix naming this entry.
 * @param issueNums Resolvable primary keys.
 * @returns The endpoint errors, and the canonical `[a, b]` pair when both
 * endpoints resolved, are distinct, and are normalized. The pair is null
 * otherwise, so the caller only counts well-formed edges toward duplicates.
 */
function validateEdgeEndpoints(entry, entryContext, issueNums) {
    const errors = [];
    const endpoints = new Map();
    // Resolve both endpoints before comparing them: distinctness and the a < b
    // normalization are only meaningful once each side names a real item.
    for (const field of ["a", "b"]) {
        const value = entry[field];
        if (typeof value === "number" &&
            Number.isInteger(value) &&
            issueNums.has(value)) {
            endpoints.set(field, value);
        }
        else {
            errors.push(`${entryContext} ${field} ${(0, parallel_state_shared_1.pythonRepr)(value)} does not resolve to an items[].issue_num.`);
        }
    }
    if (endpoints.size !== 2) {
        return { errors, pair: null };
    }
    const first = endpoints.get("a") ?? 0;
    const second = endpoints.get("b") ?? 0;
    // A self-edge is reported on its own because the contention relation is
    // defined over distinct items, which is a different defect from ordering.
    if (first === second) {
        errors.push(`${entryContext} endpoints must be distinct; found: ${first}.`);
        return { errors, pair: null };
    }
    if (first > second) {
        errors.push(`${entryContext} must be normalized with a < b; found: (${first}, ${second}).`);
        return { errors, pair: null };
    }
    return { errors, pair: [first, second] };
}
/**
 * Validate `conflict_edges[]` against invariant 15 and schema S7.
 *
 * @param edges The candidate `conflict_edges` value as deserialized.
 * @param issueNums Resolvable primary keys.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns Per-entry errors in positional order, then one duplicate-pair error
 * per repeated canonical pair in ascending pair order. A non-array value yields
 * exactly one error; an empty array is valid.
 */
function validateConflictEdges(edges, issueNums, context) {
    if (!Array.isArray(edges)) {
        return [`${context} conflict_edges must be a list.`];
    }
    const errors = [];
    const seen = new Set();
    const duplicates = new Map();
    // Validate each edge in place and accumulate canonical pairs in the same pass,
    // so edge identity is decided without a second traversal.
    edges.forEach((entry, position) => {
        const entryContext = `${context} conflict_edges[${position}]`;
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            errors.push(`${entryContext} must be an object.`);
            return;
        }
        const { errors: endpointErrors, pair } = validateEdgeEndpoints(entry, entryContext, issueNums);
        errors.push(...endpointErrors);
        const reason = entry["reason"];
        if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_EDGE_REASONS, reason)) {
            errors.push((0, parallel_state_shared_1.enumError)(entryContext, "reason", parallel_state_shared_1.VALID_EDGE_REASONS, reason));
        }
        if (pair === null) {
            return;
        }
        const key = `${pair[0]},${pair[1]}`;
        if (seen.has(key)) {
            duplicates.set(key, pair);
        }
        seen.add(key);
    });
    // Report duplicate pairs in ascending order so the message sequence does not
    // depend on where the repeats appeared in the document.
    const ordered = [...duplicates.values()].sort((left, right) => left[0] - right[0] || left[1] - right[1]);
    for (const pair of ordered) {
        errors.push(`${context} has duplicate conflict_edges[] pair: (${pair[0]}, ${pair[1]}).`);
    }
    return errors;
}
/**
 * Validate the optional receipt arrays against invariant 19. The check is
 * presence-gated: an absent receipt array is the backward compatible shape and
 * contributes no error. Per-receipt content is deliberately not inspected,
 * matching the loose tolerance the standard checkpoint validators apply.
 *
 * @param state The parsed checkpoint object.
 * @param context Surface prefix, for example `Parallel checkpoint`.
 * @returns One error per present receipt key whose value is not an array, in
 * {@link RECEIPT_ARRAY_KEYS} order.
 */
function validateReceiptArrays(state, context) {
    const errors = [];
    // Check each optional array independently so a caller that records only one
    // receipt kind is not penalized for the two it omitted.
    for (const key of exports.RECEIPT_ARRAY_KEYS) {
        if (key in state && !Array.isArray(state[key])) {
            errors.push(`${context} ${key} must be a list when present.`);
        }
    }
    return errors;
}
