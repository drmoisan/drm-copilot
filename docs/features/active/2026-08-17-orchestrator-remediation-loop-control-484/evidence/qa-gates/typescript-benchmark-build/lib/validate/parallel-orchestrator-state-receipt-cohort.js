"use strict";
/** Compose receipt-bound cohort admission with existing runtime authorities. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.RECEIPT_COHORT_VIOLATION_PREFIX = void 0;
exports.validateReceiptBoundCohortAdmission = validateReceiptBoundCohortAdmission;
const parallel_orchestrator_state_cohort_barrier_1 = require("./parallel-orchestrator-state-cohort-barrier");
const parallel_orchestrator_state_drift_1 = require("./parallel-orchestrator-state-drift");
const parallel_state_shared_1 = require("./parallel-state-shared");
exports.RECEIPT_COHORT_VIOLATION_PREFIX = "PARALLEL_RECEIPT_COHORT_VIOLATION:";
const COHORT_VIOLATION_PREFIX = "PARALLEL_COHORT_BARRIER_VIOLATION";
const WORKTREE_REMOVED_MERGE_STATUS = "worktree_removed";
const NOT_STARTED_MERGE_STATUS = "not_started";
/** Return well-keyed item records in checkpoint order. */
function itemViews(state) {
    const rawItems = state["items"];
    if (!Array.isArray(rawItems)) {
        return [];
    }
    const items = [];
    for (const entry of rawItems) {
        if (!(0, parallel_state_shared_1.isObject)(entry) ||
            !(0, parallel_state_shared_1.isPositiveInteger)(entry["issue_num"]) ||
            typeof entry["issue_num"] !== "number") {
            continue;
        }
        items.push({
            key: entry["issue_num"],
            state: typeof entry["state"] === "string" ? entry["state"] : "",
            mergeStatus: typeof entry["merge_status"] === "string"
                ? entry["merge_status"]
                : NOT_STARTED_MERGE_STATUS,
            record: entry,
        });
    }
    return items;
}
/** Project current-generation cohort rows into item assignments. */
function cohortAssignments(state, knownKeys) {
    const generation = state["recolor_generation"];
    const cohorts = state["cohorts"];
    if (!(0, parallel_state_shared_1.isNonNegativeInteger)(generation) || !Array.isArray(cohorts)) {
        return new Map();
    }
    const assignments = new Map();
    for (const entry of cohorts) {
        if (!(0, parallel_state_shared_1.isObject)(entry) ||
            entry["generation"] !== generation ||
            !(0, parallel_state_shared_1.isNonNegativeInteger)(entry["index"]) ||
            typeof entry["index"] !== "number" ||
            !Array.isArray(entry["item_keys"])) {
            continue;
        }
        for (const key of entry["item_keys"]) {
            if ((0, parallel_state_shared_1.isPositiveInteger)(key) &&
                typeof key === "number" &&
                knownKeys.has(key) &&
                !assignments.has(key)) {
                assignments.set(key, entry["index"]);
            }
        }
    }
    return assignments;
}
/** Return valid persisted conflict endpoints in document order. */
function conflictEdges(state) {
    const rawEdges = state["conflict_edges"];
    if (!Array.isArray(rawEdges)) {
        return [];
    }
    const edges = [];
    for (const entry of rawEdges) {
        if (!(0, parallel_state_shared_1.isObject)(entry) ||
            !(0, parallel_state_shared_1.isPositiveInteger)(entry["a"]) ||
            typeof entry["a"] !== "number" ||
            !(0, parallel_state_shared_1.isPositiveInteger)(entry["b"]) ||
            typeof entry["b"] !== "number" ||
            entry["a"] === entry["b"]) {
            continue;
        }
        edges.push([entry["a"], entry["b"]]);
    }
    return edges;
}
/** Report whether durable item fields show that execution has begun. */
function hasStarted(item) {
    const timestamp = item.record["worktree_created_at"];
    return ((typeof timestamp === "string" && timestamp.trim().length > 0) ||
        item.mergeStatus !== NOT_STARTED_MERGE_STATUS);
}
/** Report whether a receipt field binds a non-empty repository path. */
function hasPath(item, field) {
    const value = item.record[field];
    return typeof value === "string" && value.trim().length > 0;
}
/** Preserve legacy checkpoints until an additive receipt field is present. */
function receiptMode(items) {
    const fields = [
        "launch_receipt_path",
        "launch_status_path",
        "merge_receipt_path",
        "worktree_removal_receipt_path",
    ];
    return items.some((item) => fields.some((field) => Object.hasOwn(item.record, field)));
}
/** Validate receipt bindings for ordered conflicting cohorts. */
function receiptBarrierErrors(state, items, barrierErrors) {
    if (!receiptMode(items)) {
        return [];
    }
    const byKey = new Map(items.map((item) => [item.key, item]));
    const assignments = cohortAssignments(state, new Set(byKey.keys()));
    const errors = [];
    const launchReported = new Set();
    for (const [first, second] of conflictEdges(state)) {
        const firstIndex = assignments.get(first);
        const secondIndex = assignments.get(second);
        if (firstIndex === undefined ||
            secondIndex === undefined ||
            firstIndex === secondIndex) {
            continue;
        }
        const [predecessorKey, laterKey] = firstIndex < secondIndex ? [first, second] : [second, first];
        const predecessor = byKey.get(predecessorKey);
        const later = byKey.get(laterKey);
        if (predecessor === undefined ||
            later === undefined ||
            !hasStarted(later)) {
            continue;
        }
        if (predecessor.mergeStatus !== WORKTREE_REMOVED_MERGE_STATUS) {
            const barrierError = `${COHORT_VIOLATION_PREFIX}: ${String(predecessorKey)} ran concurrently with conflicting ${String(laterKey)}`;
            if (!barrierErrors.includes(barrierError) &&
                !errors.includes(barrierError)) {
                errors.push(barrierError);
            }
            errors.push(`${exports.RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item ${String(laterKey)} started before conflicting predecessor ${String(predecessorKey)} was both merged and worktree-removed.`);
        }
        if (!hasPath(predecessor, "merge_receipt_path") ||
            !hasPath(predecessor, "worktree_removal_receipt_path")) {
            errors.push(`${exports.RECEIPT_COHORT_VIOLATION_PREFIX} predecessor ${String(predecessorKey)} must bind merge_receipt_path and worktree_removal_receipt_path before later-cohort item ${String(laterKey)} admission.`);
        }
        if (!launchReported.has(laterKey) &&
            (!hasPath(later, "launch_receipt_path") ||
                !hasPath(later, "launch_status_path"))) {
            errors.push(`${exports.RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item ${String(laterKey)} must bind launch_receipt_path and launch_status_path before admission.`);
            launchReported.add(laterKey);
        }
    }
    return errors;
}
/** Validate that a persisted drift recolor never assigns running work. */
function pinningErrors(state, items, context) {
    const events = state["drift_events"];
    const mutations = state["mutations"];
    if (!Array.isArray(events) ||
        !events.some((entry) => (0, parallel_state_shared_1.isObject)(entry) && entry["action"] === "halted_later_started_item") ||
        !Array.isArray(mutations) ||
        !mutations.some((entry) => (0, parallel_state_shared_1.isObject)(entry) && entry["op"] === "requeue")) {
        return [];
    }
    const assignments = cohortAssignments(state, new Set(items.map((item) => item.key)));
    const moved = items
        .filter((item) => item.state === "in_flight" && assignments.has(item.key))
        .map((item) => item.key)
        .sort((left, right) => left - right);
    return moved.length === 0
        ? []
        : [`${context} drift recolor must pin running items ${(0, parallel_state_shared_1.pythonRepr)(moved)}.`];
}
/** Return ordered receipt, drift, halt, and recolor validation errors. */
function validateReceiptBoundCohortAdmission(state, context) {
    const items = itemViews(state);
    const barrierErrors = (0, parallel_orchestrator_state_cohort_barrier_1.validateCohortBarrierOrdering)(state);
    const driftErrors = (0, parallel_orchestrator_state_drift_1.validateDriftProtocol)(state, context);
    const pinnedErrors = receiptMode(items)
        ? pinningErrors(state, items, context)
        : [];
    const recolorErrorIndex = driftErrors.findIndex((error) => error.includes("recomputed cohort assignments"));
    const orderedDriftErrors = recolorErrorIndex < 0
        ? [...driftErrors, ...pinnedErrors]
        : [
            ...driftErrors.slice(0, recolorErrorIndex),
            ...pinnedErrors,
            ...driftErrors.slice(recolorErrorIndex),
        ];
    return [
        ...barrierErrors,
        ...receiptBarrierErrors(state, items, barrierErrors),
        ...orderedDriftErrors,
    ];
}
