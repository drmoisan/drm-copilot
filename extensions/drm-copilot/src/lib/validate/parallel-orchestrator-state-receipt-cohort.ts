/** Compose receipt-bound cohort admission with existing runtime authorities. */

import { validateCohortBarrierOrdering } from "./parallel-orchestrator-state-cohort-barrier";
import { validateDriftProtocol } from "./parallel-orchestrator-state-drift";
import {
  isNonNegativeInteger,
  isObject,
  isPositiveInteger,
  pythonRepr,
} from "./parallel-state-shared";

export const RECEIPT_COHORT_VIOLATION_PREFIX =
  "PARALLEL_RECEIPT_COHORT_VIOLATION:";

const COHORT_VIOLATION_PREFIX = "PARALLEL_COHORT_BARRIER_VIOLATION";
const WORKTREE_REMOVED_MERGE_STATUS = "worktree_removed";
const NOT_STARTED_MERGE_STATUS = "not_started";

interface ItemView {
  readonly key: number;
  readonly state: string;
  readonly mergeStatus: string;
  readonly record: Record<string, unknown>;
}

/** Return well-keyed item records in checkpoint order. */
function itemViews(state: Record<string, unknown>): ItemView[] {
  const rawItems = state["items"];
  if (!Array.isArray(rawItems)) {
    return [];
  }
  const items: ItemView[] = [];
  for (const entry of rawItems) {
    if (
      !isObject(entry) ||
      !isPositiveInteger(entry["issue_num"]) ||
      typeof entry["issue_num"] !== "number"
    ) {
      continue;
    }
    items.push({
      key: entry["issue_num"],
      state: typeof entry["state"] === "string" ? entry["state"] : "",
      mergeStatus:
        typeof entry["merge_status"] === "string"
          ? entry["merge_status"]
          : NOT_STARTED_MERGE_STATUS,
      record: entry,
    });
  }
  return items;
}

/** Project current-generation cohort rows into item assignments. */
function cohortAssignments(
  state: Record<string, unknown>,
  knownKeys: ReadonlySet<number>,
): Map<number, number> {
  const generation = state["recolor_generation"];
  const cohorts = state["cohorts"];
  if (!isNonNegativeInteger(generation) || !Array.isArray(cohorts)) {
    return new Map();
  }
  const assignments = new Map<number, number>();
  for (const entry of cohorts) {
    if (
      !isObject(entry) ||
      entry["generation"] !== generation ||
      !isNonNegativeInteger(entry["index"]) ||
      typeof entry["index"] !== "number" ||
      !Array.isArray(entry["item_keys"])
    ) {
      continue;
    }
    for (const key of entry["item_keys"]) {
      if (
        isPositiveInteger(key) &&
        typeof key === "number" &&
        knownKeys.has(key) &&
        !assignments.has(key)
      ) {
        assignments.set(key, entry["index"]);
      }
    }
  }
  return assignments;
}

/** Return valid persisted conflict endpoints in document order. */
function conflictEdges(state: Record<string, unknown>): [number, number][] {
  const rawEdges = state["conflict_edges"];
  if (!Array.isArray(rawEdges)) {
    return [];
  }
  const edges: [number, number][] = [];
  for (const entry of rawEdges) {
    if (
      !isObject(entry) ||
      !isPositiveInteger(entry["a"]) ||
      typeof entry["a"] !== "number" ||
      !isPositiveInteger(entry["b"]) ||
      typeof entry["b"] !== "number" ||
      entry["a"] === entry["b"]
    ) {
      continue;
    }
    edges.push([entry["a"], entry["b"]]);
  }
  return edges;
}

/** Report whether durable item fields show that execution has begun. */
function hasStarted(item: ItemView): boolean {
  const timestamp = item.record["worktree_created_at"];
  return (
    (typeof timestamp === "string" && timestamp.trim().length > 0) ||
    item.mergeStatus !== NOT_STARTED_MERGE_STATUS
  );
}

/** Report whether a receipt field binds a non-empty repository path. */
function hasPath(item: ItemView, field: string): boolean {
  const value = item.record[field];
  return typeof value === "string" && value.trim().length > 0;
}

/** Preserve legacy checkpoints until an additive receipt field is present. */
function receiptMode(items: readonly ItemView[]): boolean {
  const fields = [
    "launch_receipt_path",
    "launch_status_path",
    "merge_receipt_path",
    "worktree_removal_receipt_path",
  ];
  return items.some((item) =>
    fields.some((field) => Object.hasOwn(item.record, field)),
  );
}

/** Validate receipt bindings for ordered conflicting cohorts. */
function receiptBarrierErrors(
  state: Record<string, unknown>,
  items: readonly ItemView[],
  barrierErrors: readonly string[],
): string[] {
  if (!receiptMode(items)) {
    return [];
  }
  const byKey = new Map(items.map((item) => [item.key, item]));
  const assignments = cohortAssignments(state, new Set(byKey.keys()));
  const errors: string[] = [];
  const launchReported = new Set<number>();
  for (const [first, second] of conflictEdges(state)) {
    const firstIndex = assignments.get(first);
    const secondIndex = assignments.get(second);
    if (
      firstIndex === undefined ||
      secondIndex === undefined ||
      firstIndex === secondIndex
    ) {
      continue;
    }
    const [predecessorKey, laterKey] =
      firstIndex < secondIndex ? [first, second] : [second, first];
    const predecessor = byKey.get(predecessorKey);
    const later = byKey.get(laterKey);
    if (
      predecessor === undefined ||
      later === undefined ||
      !hasStarted(later)
    ) {
      continue;
    }
    if (predecessor.mergeStatus !== WORKTREE_REMOVED_MERGE_STATUS) {
      const barrierError = `${COHORT_VIOLATION_PREFIX}: ${String(
        predecessorKey,
      )} ran concurrently with conflicting ${String(laterKey)}`;
      if (
        !barrierErrors.includes(barrierError) &&
        !errors.includes(barrierError)
      ) {
        errors.push(barrierError);
      }
      errors.push(
        `${RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item ${String(
          laterKey,
        )} started before conflicting predecessor ${String(
          predecessorKey,
        )} was both merged and worktree-removed.`,
      );
    }
    if (
      !hasPath(predecessor, "merge_receipt_path") ||
      !hasPath(predecessor, "worktree_removal_receipt_path")
    ) {
      errors.push(
        `${RECEIPT_COHORT_VIOLATION_PREFIX} predecessor ${String(
          predecessorKey,
        )} must bind merge_receipt_path and worktree_removal_receipt_path before later-cohort item ${String(
          laterKey,
        )} admission.`,
      );
    }
    if (
      !launchReported.has(laterKey) &&
      (!hasPath(later, "launch_receipt_path") ||
        !hasPath(later, "launch_status_path"))
    ) {
      errors.push(
        `${RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item ${String(
          laterKey,
        )} must bind launch_receipt_path and launch_status_path before admission.`,
      );
      launchReported.add(laterKey);
    }
  }
  return errors;
}

/** Validate that a persisted drift recolor never assigns running work. */
function pinningErrors(
  state: Record<string, unknown>,
  items: readonly ItemView[],
  context: string,
): string[] {
  const events = state["drift_events"];
  const mutations = state["mutations"];
  if (
    !Array.isArray(events) ||
    !events.some(
      (entry) =>
        isObject(entry) && entry["action"] === "halted_later_started_item",
    ) ||
    !Array.isArray(mutations) ||
    !mutations.some((entry) => isObject(entry) && entry["op"] === "requeue")
  ) {
    return [];
  }
  const assignments = cohortAssignments(
    state,
    new Set(items.map((item) => item.key)),
  );
  const moved = items
    .filter((item) => item.state === "in_flight" && assignments.has(item.key))
    .map((item) => item.key)
    .sort((left, right) => left - right);
  return moved.length === 0
    ? []
    : [`${context} drift recolor must pin running items ${pythonRepr(moved)}.`];
}

/** Return ordered receipt, drift, halt, and recolor validation errors. */
export function validateReceiptBoundCohortAdmission(
  state: Record<string, unknown>,
  context: string,
): string[] {
  const items = itemViews(state);
  const barrierErrors = validateCohortBarrierOrdering(state);
  const driftErrors = validateDriftProtocol(state, context);
  const pinnedErrors = receiptMode(items)
    ? pinningErrors(state, items, context)
    : [];
  const recolorErrorIndex = driftErrors.findIndex((error) =>
    error.includes("recomputed cohort assignments"),
  );
  const orderedDriftErrors =
    recolorErrorIndex < 0
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
