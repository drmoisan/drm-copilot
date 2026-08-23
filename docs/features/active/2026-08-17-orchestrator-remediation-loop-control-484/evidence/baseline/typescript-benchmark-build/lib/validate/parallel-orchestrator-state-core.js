"use strict";
/**
 * Parallel-orchestrator checkpoint validator (TypeScript port).
 *
 * Purpose:
 *     Port `scripts/dev_tools/validate_parallel_orchestrator_state.py`'s
 *     `validate_parallel_orchestrator_state_text`. Enforces the repository
 *     contract for `artifacts/orchestration/parallel-orchestrator-state.json` --
 *     spec invariants 1 through 19 unconditionally and invariants 20 and 21 only
 *     under `requireComplete` -- before any resume, scheduling, or
 *     completion-gate workflow relies on its contents.
 *
 * Flow:
 *     Parse the checkpoint JSON, reject a non-object root, check the required-key
 *     set, validate run identity (`route_id`, `mode`, `max_concurrency`), scan
 *     for prohibited keys, then delegate each collection to
 *     `parallel-state-shared.ts` and `parallel-state-structures.ts`. Each
 *     collection check is presence-gated so an absent required key reports
 *     exactly one error.
 *
 * Cache doctrine:
 *     This checkpoint is a CACHE of durable state, not the source of truth. Every
 *     field is re-derivable from `git worktree list --porcelain`, `git branch`,
 *     and `gh pr view --json state,mergedAt,headRefOid`. Validation therefore
 *     checks internal consistency only and never consults a repository.
 *
 * Invariants / Constraints:
 *     - Error strings are byte-identical to the Python source; every one begins
 *       with the literal prefix `Parallel checkpoint` and ends with a period.
 *     - The validator returns an array of error strings and never mutates its
 *       input. No JSON Schema file is authored or imported.
 *
 * Side Effects:
 *     None; pure text-in, errors-out validation.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.REQUIRED_KEYS = void 0;
exports.validateParallelOrchestratorStateText = validateParallelOrchestratorStateText;
const parallel_codex_readiness_1 = require("./parallel-codex-readiness");
const parallel_orchestrator_state_completion_receipts_1 = require("./parallel-orchestrator-state-completion-receipts");
const parallel_orchestrator_state_mutations_1 = require("./parallel-orchestrator-state-mutations");
const parallel_orchestrator_state_receipt_cohort_1 = require("./parallel-orchestrator-state-receipt-cohort");
const parallel_orchestrator_state_resume_truth_1 = require("./parallel-orchestrator-state-resume-truth");
const parallel_state_shared_1 = require("./parallel-state-shared");
const parallel_state_structures_1 = require("./parallel-state-structures");
/** Literal context prefix for every error this module and its helpers emit. */
const CONTEXT = "Parallel checkpoint";
/** The route identity this checkpoint must declare (invariant 2). */
const EXPECTED_ROUTE_ID = "parallel";
/** Inclusive lower bound on `max_concurrency` (invariant 4, assumption A7). */
const MIN_CONCURRENCY = 1;
/** Inclusive upper bound on `max_concurrency` (invariant 4, assumption A7). */
const MAX_CONCURRENCY = 8;
/**
 * Required top-level keys (invariant 1). The first four mirror the epic baseline
 * so the existing structural checkpoint hooks apply unmodified; the rest are the
 * parallel-specific fields of schema S2.
 */
exports.REQUIRED_KEYS = [
    "objective",
    "completed_steps",
    "next_step",
    "last_updated",
    "route_id",
    "parallel_slug",
    "parallel_manifest_path",
    "parallel_status_doc_path",
    "mode",
    "max_concurrency",
    "current_cohort",
    "recolor_generation",
    "cohorts",
    "items",
    "conflict_edges",
    "mutations",
    "drift_events",
];
/**
 * Report every absent required top-level key (invariant 1).
 *
 * @param state The parsed checkpoint object.
 * @returns One error per missing key, in {@link REQUIRED_KEYS} order.
 */
function missingRequiredKeys(state) {
    // Report every missing key rather than the first, so one validation pass tells
    // the author the whole set of fields still to write.
    return exports.REQUIRED_KEYS.filter((key) => !(key in state)).map((key) => `${CONTEXT} missing required key: ${key}.`);
}
/**
 * Validate run identity fields against invariants 2 through 4.
 *
 * Each check is presence-gated: an absent key has already produced its own
 * required-key error, and reporting a second error for the same omission would
 * overstate the number of defects.
 *
 * @param state The parsed checkpoint object.
 * @returns One error per violated identity condition.
 */
function validateIdentity(state) {
    const errors = [];
    const routeId = state["route_id"];
    if ("route_id" in state && routeId !== EXPECTED_ROUTE_ID) {
        errors.push(`${CONTEXT} route_id must be '${EXPECTED_ROUTE_ID}'; found: ${(0, parallel_state_shared_1.pythonRepr)(routeId)}.`);
    }
    const mode = state["mode"];
    if ("mode" in state && !(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.VALID_MODES, mode)) {
        errors.push((0, parallel_state_shared_1.enumError)(CONTEXT, "mode", parallel_state_shared_1.VALID_MODES, mode));
    }
    const concurrency = state["max_concurrency"];
    if ("max_concurrency" in state &&
        !(0, parallel_state_shared_1.inBoundedRange)(concurrency, MIN_CONCURRENCY, MAX_CONCURRENCY)) {
        errors.push(`${CONTEXT} max_concurrency must be an integer from ${MIN_CONCURRENCY} through ${MAX_CONCURRENCY}; found: ${(0, parallel_state_shared_1.pythonRepr)(concurrency)}.`);
    }
    return errors;
}
/**
 * Delegate every checkpoint collection to its helper validator.
 *
 * Covers invariants 5 through 9 (items and blast radii), 12 through 14
 * (cohorts), 15 (conflict edges), 16 and 17 (mutations), 18 (drift events), and
 * 19 (receipt arrays). Cohort assignment is never recomputed here; that is the
 * planner-side parity check assigned to F4.
 *
 * @param state The parsed checkpoint object.
 * @returns The concatenated helper errors, in schema order.
 */
function validateCollections(state) {
    const items = state["items"];
    const issueNums = (0, parallel_state_structures_1.collectIssueNumbers)(items);
    const generation = state["recolor_generation"];
    const cohorts = state["cohorts"];
    const errors = [];
    // Each collection is gated on its own key so a missing required key costs
    // exactly one error, while a present but malformed value is fully checked.
    if ("items" in state) {
        errors.push(...(0, parallel_state_shared_1.validateItems)(items, CONTEXT));
    }
    if ("cohorts" in state) {
        errors.push(...(0, parallel_state_structures_1.validateCohortShapes)(cohorts, issueNums, generation, CONTEXT));
        errors.push(...(0, parallel_state_structures_1.validateCurrentGenerationCohorts)(cohorts, items, generation, CONTEXT));
    }
    if ("current_cohort" in state) {
        errors.push(...(0, parallel_state_structures_1.validateCurrentCohortBound)(state["current_cohort"], cohorts, generation, CONTEXT));
    }
    if ("conflict_edges" in state) {
        errors.push(...(0, parallel_state_structures_1.validateConflictEdges)(state["conflict_edges"], issueNums, CONTEXT));
    }
    if ("mutations" in state) {
        errors.push(...(0, parallel_state_structures_1.validateMutations)(state["mutations"], issueNums, generation, CONTEXT));
    }
    if ("drift_events" in state) {
        errors.push(...(0, parallel_state_structures_1.validateDriftEvents)(state["drift_events"], issueNums, CONTEXT));
    }
    errors.push(...(0, parallel_state_structures_1.validateReceiptArrays)(state, CONTEXT));
    return errors;
}
/**
 * Report whether the mutation log records the run-level close operation.
 *
 * @param state The parsed checkpoint object.
 * @returns True when any object-shaped `mutations[]` entry carries
 * `op === 'close'`. Entry shape is not re-checked here; invariant 16 already
 * reported any malformed record.
 */
function recordsCloseMutation(state) {
    const mutations = state["mutations"];
    if (!Array.isArray(mutations)) {
        return false;
    }
    return mutations.some((entry) => (0, parallel_state_shared_1.isObject)(entry) && entry["op"] === "close");
}
/**
 * Enforce the mode-dependent completion gate (invariants 20 and 21).
 *
 * A withdrawn item is exempt: it left the run before reaching a merge outcome,
 * so requiring a terminal merge status of it would make every run that dropped
 * an item permanently incompletable. Both modes share that per-item condition;
 * open mode adds the `/parallel-close` record, because an open run has no other
 * signal that admissions have stopped.
 *
 * @param state The parsed checkpoint object.
 * @returns One error per non-withdrawn item lacking a terminal merge status, in
 * positional order, followed by the open-mode close-mutation error when that
 * record is absent.
 */
function validateCompletion(state) {
    const errors = [];
    const items = state["items"];
    const entries = Array.isArray(items) ? items : [];
    // Check every item so the gate reports the full remaining work, not just the
    // first item that has not finished merging.
    entries.forEach((entry, index) => {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            return;
        }
        if (entry["state"] === "withdrawn") {
            return;
        }
        const mergeStatus = entry["merge_status"];
        if (!(0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.MERGED_MERGE_STATUSES, mergeStatus)) {
            errors.push(`${(0, parallel_state_shared_1.itemContext)(CONTEXT, index)} completion validation failed: merge_status is not merged or worktree_removed; found: ${(0, parallel_state_shared_1.pythonRepr)(mergeStatus)}.`);
        }
    });
    if (state["mode"] === "open" && !recordsCloseMutation(state)) {
        errors.push(`${CONTEXT} completion validation failed: open mode requires a mutations[] entry with op 'close'.`);
    }
    return errors;
}
/**
 * Validate a parallel-orchestrator checkpoint document.
 *
 * @param text Raw checkpoint JSON text.
 * @param options When `requireComplete` is true, additionally enforce the
 * mode-dependent completion gate (invariants 20 and 21). When false the gate
 * contributes no errors, so an in-progress run validates.
 * @returns Validation errors for a malformed or incomplete checkpoint; an empty
 * array when the checkpoint is valid. Invalid JSON and a non-object root each
 * return a single-element array, because no field check is meaningful without a
 * parsed object.
 */
function validateParallelOrchestratorStateText(text, options = {}) {
    let state;
    try {
        state = JSON.parse(text);
    }
    catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        return [`${CONTEXT} is not valid JSON: ${detail}.`];
    }
    if (!(0, parallel_state_shared_1.isObject)(state)) {
        return [`${CONTEXT} root must be a JSON object.`];
    }
    const errors = [];
    errors.push(...missingRequiredKeys(state));
    errors.push(...validateIdentity(state));
    errors.push(...(0, parallel_state_shared_1.scanProhibitedKeys)(state, CONTEXT));
    errors.push(...(0, parallel_codex_readiness_1.validateParallelStateIsStandalone)(state, CONTEXT));
    errors.push(...validateCollections(state));
    // F6 mutation composition seam: the base collection validator owns record
    // shape, while this additive helper owns cross-record protocol semantics.
    errors.push(...(0, parallel_orchestrator_state_mutations_1.validateMutationProtocol)(state, CONTEXT));
    // BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
    // F7 (parallel enforcement hooks) owns the retrospective cohort-ordering
    // invariant of design section 9 Layer 2. Its entire edit to this module is
    // one appended `errors.push(...<helper>(state, CONTEXT));` call inside this
    // block, plus the helper's import. Nothing else in this function moves, so F7
    // and F3 cannot contend over the same lines (epic wave-4 rule).
    // Add F7 helper invocations below this line, one per line.
    errors.push(...(0, parallel_orchestrator_state_receipt_cohort_1.validateReceiptBoundCohortAdmission)(state, CONTEXT));
    errors.push(...(0, parallel_orchestrator_state_resume_truth_1.validateParallelResumeTruth)(state, CONTEXT));
    // END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
    if (options.requireComplete === true) {
        errors.push(...(0, parallel_codex_readiness_1.validateParallelCodexCheckpointReadiness)(state, CONTEXT, options.readinessContext));
        errors.push(...validateCompletion(state));
        errors.push(...(0, parallel_orchestrator_state_completion_receipts_1.validateCompletionReceipts)(state, CONTEXT));
    }
    return errors;
}
