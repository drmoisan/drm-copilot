"use strict";
/**
 * Retrospective cohort-barrier ordering invariant for the parallel checkpoint.
 *
 * Purpose:
 *     TypeScript port of
 *     `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`. Owns
 *     Layer 2 of the two-layer cohort barrier (design section 9): given a written
 *     `artifacts/orchestration/parallel-orchestrator-state.json`, report every
 *     `conflict_edges[]` pair the checkpoint shows ran concurrently. Layer 1 is
 *     the per-call `PreToolUse` deterrent
 *     `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, which fires once per
 *     tool call and therefore cannot inspect a batch of concurrent `Agent` calls;
 *     this module inspects the recorded batch but only after execution. Neither
 *     layer alone closes the gap, so both are shipped.
 *
 * Flow:
 *     Gate on the presence of `conflict_edges` and `cohorts`; build a union
 *     reference index over `items[]` (primary key `issue_num`, with the
 *     `feature_folder` hint tolerated); project the current-generation cohort
 *     coloring into an item-to-cohort-index map; then test each edge under the
 *     structural and temporal readings and emit one message per violated edge.
 *
 * Responsibilities:
 *     This module adds NO checkpoint schema field. It reads only fields F3
 *     already defines -- `cohorts[]`, `conflict_edges[]`, `items[].merge_status`,
 *     and the two optional lifecycle timestamps named by the constants below --
 *     and consumes F3's enums without extending them. It performs no shape
 *     validation: a malformed cohort, edge, or item is already reported by
 *     `parallel-orchestrator-state-core.ts` and its helpers, so this module
 *     silently skips what it cannot read rather than double-reporting it. The
 *     shared shape guards and the merged-status member list are imported from
 *     `./parallel-state-shared` and reimplemented nowhere.
 *
 * Invariants / Constraints:
 *     The check is key-gated, so a checkpoint written before this invariant
 *     existed validates byte-identically. The temporal reading degrades to the
 *     structural-plus-status checks whenever either timestamp is absent or is not
 *     a string, because F3 neither requires nor validates those fields; no
 *     timestamp is ever inferred, defaulted, or synthesized. Each violated edge
 *     contributes exactly one message in the byte-exact form mandated by design
 *     section 9, which deliberately carries no `Parallel checkpoint` context
 *     prefix and no trailing period -- the only error in this validator family
 *     shaped that way, which is why the seam call passes the state alone with no
 *     context argument. The Python module is the reference and this port conforms
 *     to it; the shared corpus under `tests/fixtures/parallel_cohort_barrier/` is
 *     the single artifact binding the two runtimes, asserted by both
 *     `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` and
 *     `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts`.
 *
 * Side Effects:
 *     None anywhere in this module. Every function is pure: it throws nothing,
 *     performs no I/O, and reads but never mutates its arguments. Individual
 *     doc comments therefore omit the throws-and-side-effects notes that this
 *     module-wide statement already covers.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateCohortBarrierOrdering = validateCohortBarrierOrdering;
const parallel_state_shared_1 = require("./parallel-state-shared");
/**
 * Literal token of the Layer 2 invariant (design section 9). The message form is
 * byte-exact and, unlike every other error this validator family emits, carries
 * no context prefix and no trailing period.
 */
const VIOLATION_PREFIX = "PARALLEL_COHORT_BARRIER_VIOLATION";
/**
 * U9 lifecycle timestamp field names, frozen from the parallel cache doctrine and
 * the parallel-status items projection. Both fields are optional and unvalidated
 * by F3, which is why the temporal reading must degrade rather than require them.
 * There is no F3-guaranteed `in_flight_at` or `started_at`.
 */
const ITEM_START_TIMESTAMP_FIELD = "worktree_created_at";
const MERGE_CONFIRMATION_TIMESTAMP_FIELD = "merged_at";
/**
 * The merge-status value meaning no work has begun. An absent `merge_status` is
 * treated as this value per F3's schema, so absence never evidences a start.
 */
const NOT_STARTED_MERGE_STATUS = "not_started";
/**
 * Top-level keys that gate the whole check. Both are required by F3 invariant 1,
 * so a checkpoint missing either is already being reported as malformed; running
 * the barrier check on it would add noise without adding information.
 */
const GATING_KEYS = ["conflict_edges", "cohorts"];
/**
 * Lifecycle prefixes a `feature_folder` hint may carry, longest first so the
 * repository-rooted form is stripped before the bare lifecycle form.
 */
const FOLDER_HINT_PREFIXES = [
    "docs/features/active/",
    "docs/features/completed/",
    "active/",
    "completed/",
];
/**
 * Strip any lifecycle prefix from a `feature_folder` reference.
 *
 * @param value A raw `feature_folder` value or a reference to one, which may be a
 * bare basename or may point into a lifecycle folder.
 * @returns The basename with the first matching prefix removed, so a hint and the
 * item's own stored value index to the same key.
 */
function normalizeFolderHint(value) {
    // Check each known lifecycle prefix in order; the first match is stripped, so
    // the longest-first constant order decides which one wins.
    for (const prefix of FOLDER_HINT_PREFIXES) {
        if (value.startsWith(prefix)) {
            return value.slice(prefix.length);
        }
    }
    return value;
}
/**
 * Index the checkpoint's items by primary key and by folder hint.
 *
 * @param items The candidate `items` value as deserialized.
 * @returns The `issue_num`-keyed record map and the normalized-folder-hint map
 * onto the same keys. Both are empty when `items` is not an array, which leaves
 * every reference unresolvable and the whole check silent.
 */
function buildReferenceIndex(items) {
    const records = new Map();
    const byFolderHint = new Map();
    if (!Array.isArray(items)) {
        return { records, byFolderHint };
    }
    // Index every well-keyed item under both reference forms so a cohort member or
    // an edge endpoint resolves whether it names the primary key or the hint.
    // First occurrence wins: a duplicate key is invariant 5's error to report.
    for (const entry of items) {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            continue;
        }
        const issueNum = entry["issue_num"];
        if (typeof issueNum !== "number" || !(0, parallel_state_shared_1.isPositiveInteger)(issueNum)) {
            continue;
        }
        if (!records.has(issueNum)) {
            records.set(issueNum, entry);
        }
        const folder = entry["feature_folder"];
        if (typeof folder === "string" && folder.trim().length > 0) {
            const hint = normalizeFolderHint(folder);
            if (!byFolderHint.has(hint)) {
                byFolderHint.set(hint, issueNum);
            }
        }
    }
    return { records, byFolderHint };
}
/**
 * Resolve one cohort member or edge endpoint to its `issue_num`.
 *
 * @param reference A `cohorts[].item_keys` entry or an edge `a`/`b` value as
 * deserialized.
 * @param references The primary-key record map and the folder-hint map.
 * @returns The resolved `issue_num`, or null when the reference names no declared
 * item. A string is read as a `feature_folder` hint and anything else as the
 * primary key itself, mirroring the epic resolver.
 */
function resolveReference(reference, references) {
    // The reference form decides the lookup: F3 requires the integer primary key,
    // while the folder-hint branch exists only so a hint-shaped reference is
    // understood rather than silently treated as an absent item.
    if (typeof reference === "string") {
        return references.byFolderHint.get(normalizeFolderHint(reference)) ?? null;
    }
    if (typeof reference === "number" &&
        (0, parallel_state_shared_1.isPositiveInteger)(reference) &&
        references.records.has(reference)) {
        return reference;
    }
    return null;
}
/**
 * Project the current-generation coloring into a member-to-index map.
 *
 * @param cohorts The candidate `cohorts` value as deserialized.
 * @param recolorGeneration The top-level generation counter.
 * @param references The primary-key record map and the folder-hint map.
 * @returns Each resolvable current-generation cohort member mapped to its cohort
 * `index`. Empty when `cohorts` is not an array or the generation counter is
 * unusable, because no row can then be attributed to the current coloring.
 */
function cohortIndexByItem(cohorts, recolorGeneration, references) {
    const assignments = new Map();
    if (!Array.isArray(cohorts) || !(0, parallel_state_shared_1.isNonNegativeInteger)(recolorGeneration)) {
        return assignments;
    }
    // Only current-generation rows are read: a superseded generation records a
    // coloring that no longer governs scheduling, so it cannot imply ordering.
    for (const entry of cohorts) {
        if (!(0, parallel_state_shared_1.isObject)(entry) || entry["generation"] !== recolorGeneration) {
            continue;
        }
        const cohortIndex = entry["index"];
        const itemKeys = entry["item_keys"];
        if (typeof cohortIndex !== "number" ||
            !(0, parallel_state_shared_1.isNonNegativeInteger)(cohortIndex) ||
            !Array.isArray(itemKeys)) {
            continue;
        }
        // Record the first current-generation cohort each member appears in; a second
        // appearance is invariant 13's error to report, not this one's.
        for (const reference of itemKeys) {
            const key = resolveReference(reference, references);
            if (key !== null && !assignments.has(key)) {
                assignments.set(key, cohortIndex);
            }
        }
    }
    return assignments;
}
/**
 * Report whether an item has begun work, per the recorded evidence.
 *
 * @param record One `items[]` entry.
 * @returns True when the item carries a non-empty start timestamp string or a
 * `merge_status` that has left `not_started`. An absent `merge_status` means
 * `not_started` in F3's schema, so absence never evidences a start.
 */
function hasStarted(record) {
    const start = record[ITEM_START_TIMESTAMP_FIELD];
    if (typeof start === "string" && start.trim().length > 0) {
        return true;
    }
    const mergeStatus = record["merge_status"];
    return (typeof mergeStatus === "string" && mergeStatus !== NOT_STARTED_MERGE_STATUS);
}
/**
 * Report whether an item reached a barrier-satisfying terminal status.
 *
 * @param record One `items[]` entry.
 * @returns True when `merge_status` is `merged` or `worktree_removed`. `ci_green`
 * deliberately does not satisfy the barrier: the next cohort may branch only from
 * durably merged work.
 */
function satisfiesBarrier(record) {
    return (0, parallel_state_shared_1.isEnumMember)(parallel_state_shared_1.MERGED_MERGE_STATUSES, record["merge_status"]);
}
/**
 * Compare the earlier item's merge confirmation to the later item's start.
 *
 * @param earlier The item colored into the earlier cohort.
 * @param later The item colored into the later cohort.
 * @returns True when both timestamps are present as strings and the earlier
 * item's merge confirmation is chronologically after the later item's start,
 * which means the two overlapped. False whenever either value is absent or is not
 * a string, which is the mandated degradation to the structural-plus-status
 * checks; no value is ever synthesized.
 */
function mergeConfirmedAfterStart(earlier, later) {
    const confirmed = earlier[MERGE_CONFIRMATION_TIMESTAMP_FIELD];
    const started = later[ITEM_START_TIMESTAMP_FIELD];
    if (typeof confirmed !== "string" || typeof started !== "string") {
        return false;
    }
    // ISO-8601 timestamps sort correctly as strings, matching the epic
    // wave-barrier precedent's merge_confirmed_at > worktree_created_at compare.
    return confirmed > started;
}
/**
 * Decide whether one conflict edge violates the cohort barrier.
 *
 * @param first The edge's `a` endpoint, already resolved.
 * @param second The edge's `b` endpoint, already resolved.
 * @param assignments Member-to-cohort-index projection.
 * @param records The primary-key record map.
 * @returns The `[earlier, later]` endpoints to name in the message, or null when
 * the edge is clean or cannot be judged.
 */
function violationEndpoints(first, second, assignments, records) {
    const firstIndex = assignments.get(first);
    const secondIndex = assignments.get(second);
    // Structural reading: conflicting items colored into one current-generation
    // cohort run concurrently by construction, so index equality alone is a
    // violation and the edge's own endpoint order names the message.
    if (firstIndex !== undefined && firstIndex === secondIndex) {
        return [first, second];
    }
    // An endpoint outside the current coloring cannot be ordered against the other,
    // so no temporal claim is available and the edge is left unjudged.
    if (firstIndex === undefined || secondIndex === undefined) {
        return null;
    }
    // Temporal reading: order the endpoints by cohort index, then ask whether the
    // later-cohort item overlapped the earlier one. The status disjunct fires
    // whenever the later item started before the earlier reached a terminal merge;
    // the timestamp disjunct additionally catches an overlap the statuses have
    // since moved past.
    const [earlierKey, laterKey] = firstIndex < secondIndex ? [first, second] : [second, first];
    const earlier = records.get(earlierKey);
    const later = records.get(laterKey);
    if (earlier === undefined || later === undefined) {
        return null;
    }
    const statusViolation = hasStarted(later) && !satisfiesBarrier(earlier);
    if (statusViolation || mergeConfirmedAfterStart(earlier, later)) {
        return [earlierKey, laterKey];
    }
    return null;
}
/**
 * Report every conflict edge the checkpoint shows ran concurrently.
 *
 * @param state The parsed parallel-orchestrator checkpoint.
 * @returns One byte-exact
 * `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`
 * message per violated edge, in `conflict_edges[]` document order, with `<a>` the
 * earlier or first endpoint. An empty array when the barrier holds, when either
 * gating key is absent (backward compatibility), or when no edge can be judged.
 */
function validateCohortBarrierOrdering(state) {
    // Key gate: both collections are required by invariant 1, so a checkpoint
    // missing either is already reported malformed and predates this invariant.
    if (GATING_KEYS.some((key) => !(key in state))) {
        return [];
    }
    const edges = state["conflict_edges"];
    if (!Array.isArray(edges)) {
        return [];
    }
    const references = buildReferenceIndex(state["items"]);
    const assignments = cohortIndexByItem(state["cohorts"], state["recolor_generation"], references);
    const errors = [];
    // Judge every edge so one validation pass reports the full set of overlaps, and
    // emit at most one message per edge even when both readings hold.
    for (const entry of edges) {
        if (!(0, parallel_state_shared_1.isObject)(entry)) {
            continue;
        }
        const first = resolveReference(entry["a"], references);
        const second = resolveReference(entry["b"], references);
        // A self-edge or an unresolved endpoint is invariant 15's error; there is no
        // pair of distinct items here whose ordering could be judged.
        if (first === null || second === null || first === second) {
            continue;
        }
        const endpoints = violationEndpoints(first, second, assignments, references.records);
        if (endpoints !== null) {
            errors.push(`${VIOLATION_PREFIX}: ${endpoints[0]} ran concurrently with conflicting ${endpoints[1]}`);
        }
    }
    return errors;
}
