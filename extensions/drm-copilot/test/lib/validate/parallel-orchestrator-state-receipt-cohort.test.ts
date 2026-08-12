import { describe, expect, it } from "@jest/globals";

import {
  RECEIPT_COHORT_VIOLATION_PREFIX,
  validateReceiptBoundCohortAdmission,
} from "../../../src/lib/validate/parallel-orchestrator-state-receipt-cohort";

type JsonRecord = Record<string, unknown>;

const CONTEXT = "Parallel checkpoint";
const UNRESOLVED_ERROR =
  "Parallel checkpoint unresolved drift for items [101] blocks admission and completion.";
const REQUEUE_ORDER_ERROR =
  "Parallel checkpoint requeue mutation item order must be ascending; found: [203, 202].";

function radius(path: string, resolved = false): JsonRecord {
  return {
    paths: [path],
    modules: [],
    shared_surfaces: [],
    contracts: [],
    source: resolved ? "observed" : "declared",
    computed_at: resolved ? "2026-08-10T22-00" : "2026-08-10T20-00",
  };
}

function item(
  key: number,
  state: string,
  mergeStatus: string,
  path: string,
): JsonRecord {
  return {
    issue_num: key,
    feature_folder: `2026-08-10-parallel-item-${String(key)}`,
    state,
    merge_status: mergeStatus,
    blast_radius: radius(path),
    launch_receipt_path: `artifacts/orchestration/item-${String(key)}.launch.json`,
    launch_status_path: `artifacts/orchestration/item-${String(key)}.status.json`,
  };
}

function baseState(items: readonly JsonRecord[]): JsonRecord {
  return {
    parallel_slug: "receipt-bound-runtime",
    current_cohort: 1,
    recolor_generation: 0,
    items: [...items],
    cohorts: [
      { index: 0, generation: 0, item_keys: [101] },
      { index: 1, generation: 0, item_keys: [202] },
    ],
    conflict_edges: [{ a: 101, b: 202, reason: "path_overlap" }],
    mutations: [],
    drift_events: [],
  };
}

function receiptBoundState(predecessorStatus: string): JsonRecord {
  const predecessor = item(101, "merged", predecessorStatus, "scripts/**");
  predecessor["merge_receipt_path"] =
    "artifacts/orchestration/item-101.merge.json";
  if (predecessorStatus === "worktree_removed") {
    predecessor["worktree_removal_receipt_path"] =
      "artifacts/orchestration/item-101.worktree-removal.json";
  }
  const later = item(202, "in_flight", "worktree_created", "scripts/**");
  later["worktree_created_at"] = "2026-08-10T21-00";
  return baseState([predecessor, later]);
}

function resolvedHaltState(peerKeys: readonly number[] = [202]): JsonRecord {
  const drifting = item(101, "in_flight", "pr_open", "packages/**");
  drifting["blast_radius"] = radius("packages/**", true);
  const peers = peerKeys.map((key) =>
    item(key, "blocked", "blocked_drift", "packages/**"),
  );
  const unstarted = [
    item(301, "scheduled", "not_started", "docs/**"),
    item(302, "scheduled", "not_started", "docs/**"),
  ];
  const state = baseState([drifting, ...peers, ...unstarted]);
  state["current_cohort"] = 0;
  state["recolor_generation"] = 1;
  state["cohorts"] = [
    { index: 1, generation: 1, item_keys: [301] },
    { index: 2, generation: 1, item_keys: [302] },
  ];
  state["conflict_edges"] = [
    { a: 101, b: 301, reason: "path_overlap" },
    { a: 301, b: 302, reason: "path_overlap" },
  ];
  state["drift_events"] = [
    {
      item_key: 101,
      declared: ["scripts/**"],
      observed: ["packages/service.ts"],
      escaped_paths: ["packages/service.ts"],
      at: "2026-08-10T21-00",
      action: "halted_later_started_item",
    },
  ];
  state["mutations"] = peerKeys.map((key, index) => ({
    sequence: index + 1,
    op: "requeue",
    item_key: key,
    at: "2026-08-10T21-00",
    prior_state: "in_flight",
    new_state: "blocked",
    disposition: null,
    recolor_generation: 1,
  }));
  return state;
}

function records(state: JsonRecord, field: string): JsonRecord[] {
  const value = state[field];
  if (!Array.isArray(value)) {
    throw new Error(`${field} must be an array in this test fixture.`);
  }
  return value as JsonRecord[];
}

describe("receipt-bound cohort admission", () => {
  it("requires merged and removed predecessor receipts before later admission", () => {
    const errors = validateReceiptBoundCohortAdmission(
      receiptBoundState("merged"),
      CONTEXT,
    );

    expect(errors).toEqual([
      "PARALLEL_COHORT_BARRIER_VIOLATION: 101 ran concurrently with conflicting 202",
      `${RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item 202 started before conflicting predecessor 101 was both merged and worktree-removed.`,
      `${RECEIPT_COHORT_VIOLATION_PREFIX} predecessor 101 must bind merge_receipt_path and worktree_removal_receipt_path before later-cohort item 202 admission.`,
    ]);
  });

  it("releases admission after both predecessor receipts are persisted", () => {
    expect(
      validateReceiptBoundCohortAdmission(
        receiptBoundState("worktree_removed"),
        CONTEXT,
      ),
    ).toEqual([]);
  });

  it("requires both launch references on the started later item", () => {
    const state = receiptBoundState("worktree_removed");
    delete records(state, "items")[1]?.["launch_status_path"];

    expect(validateReceiptBoundCohortAdmission(state, CONTEXT)).toEqual([
      `${RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item 202 must bind launch_receipt_path and launch_status_path before admission.`,
    ]);
  });

  it("quiesces admission and completion while drift remains unresolved", () => {
    const state = resolvedHaltState();
    records(state, "items")[0]!["blast_radius"] = radius("scripts/**");

    expect(validateReceiptBoundCohortAdmission(state, CONTEXT)).toContain(
      UNRESOLVED_ERROR,
    );
  });

  it("pins every running item during a persisted recolor", () => {
    const state = resolvedHaltState();
    records(state, "cohorts").push({
      index: 0,
      generation: 1,
      item_keys: [101],
    });

    expect(validateReceiptBoundCohortAdmission(state, CONTEXT)).toContain(
      "Parallel checkpoint drift recolor must pin running items [101].",
    );
  });

  it("requires a persisted requeue for a later-started conflict halt", () => {
    const state = resolvedHaltState();
    const peer = records(state, "items")[1]!;
    peer["state"] = "in_flight";
    peer["merge_status"] = "pr_open";
    state["mutations"] = [];

    expect(validateReceiptBoundCohortAdmission(state, CONTEXT)).toContain(
      "Parallel checkpoint drift_events[0] halted_later_started_item action requires a persisted requeue mutation.",
    );
  });

  it("validates deterministic recoloring over unstarted items only", () => {
    const state = resolvedHaltState();
    state["cohorts"] = [{ index: 1, generation: 1, item_keys: [301, 302] }];

    expect(validateReceiptBoundCohortAdmission(state, CONTEXT)).toContain(
      "Parallel checkpoint recomputed cohort assignments do not match deterministic unstarted recoloring.",
    );
  });

  it("requires ascending persisted requeue order", () => {
    const state = resolvedHaltState([202, 203]);
    state["mutations"] = [...records(state, "mutations")].reverse();

    expect(validateReceiptBoundCohortAdmission(state, CONTEXT)).toContain(
      REQUEUE_ORDER_ERROR,
    );
  });

  it("preserves deterministic error order and input immutability", () => {
    const state = resolvedHaltState([202, 203]);
    state["mutations"] = [...records(state, "mutations")].reverse();
    records(state, "items")[0]!["blast_radius"] = radius("scripts/**");
    const snapshot = JSON.stringify(state);

    const first = validateReceiptBoundCohortAdmission(state, CONTEXT);
    const second = validateReceiptBoundCohortAdmission(state, CONTEXT);

    expect(first).toEqual(second);
    expect(first.indexOf(UNRESOLVED_ERROR)).toBeLessThan(
      first.indexOf(REQUEUE_ORDER_ERROR),
    );
    expect(JSON.stringify(state)).toBe(snapshot);
  });
});
