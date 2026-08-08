/**
 * Tests for the parallel checkpoint mode-dependent completion gate.
 *
 * Covers spec invariants 20 and 21: the closed-mode per-item terminal merge
 * requirement (pass and fail), the withdrawn-item exemption, the open-mode
 * close-mutation requirement, and the gate-off default. Also covers the
 * non-list receipt-array rejection that completes invariant 19. Every expected
 * string is the byte-identical literal emitted by
 * `scripts/dev_tools/validate_parallel_orchestrator_state.py`.
 */

import {
  buildValidParallelState,
  itemAt,
  validateState,
  type JsonRecord,
} from "./parallel-state-test-support";

/** The run-level close record the open-mode gate looks for. */
function buildCloseMutation(): JsonRecord {
  return {
    op: "close",
    item_key: null,
    at: "2026-08-07T12-00",
    prior_state: null,
    new_state: null,
    disposition: null,
    recolor_generation: 0,
  };
}

/** Return a closed-mode checkpoint in which every item merged and closed. */
function buildCompletedState(): JsonRecord {
  const state = buildValidParallelState();
  for (const index of [0, 1]) {
    itemAt(state, index)["state"] = "merged";
    itemAt(state, index)["merge_status"] = "worktree_removed";
  }
  state["cohorts"] = [];
  return state;
}

describe("invariant 19 present receipt arrays", () => {
  it.each(["delegation_receipts", "skill_receipts", "mcp_call_receipts"])(
    "rejects a non-list %s value",
    (key) => {
      const state = buildValidParallelState();
      state[key] = { agent_name: "atomic-executor" };

      expect(validateState(state)).toContain(
        `Parallel checkpoint ${key} must be a list when present.`,
      );
    },
  );
});

describe("invariants 20-21 completion gate", () => {
  it("is inactive by default", () => {
    expect(validateState(buildValidParallelState())).toEqual([]);
  });

  it("rejects an unmerged item under the closed-mode gate", () => {
    expect(validateState(buildValidParallelState(), true)).toContain(
      "Parallel checkpoint items[0] completion validation failed: merge_status is not merged or worktree_removed; found: None.",
    );
  });

  it.each(["merged", "worktree_removed"])(
    "accepts terminal merge status %s under the closed-mode gate",
    (mergeStatus) => {
      const state = buildCompletedState();
      for (const index of [0, 1]) {
        itemAt(state, index)["merge_status"] = mergeStatus;
      }

      expect(validateState(state, true)).toEqual([]);
    },
  );

  it("still requires a merge for a blocked item", () => {
    const state = buildCompletedState();
    itemAt(state, 1)["state"] = "blocked";
    itemAt(state, 1)["merge_status"] = "blocked_drift";

    expect(validateState(state, true)).toContain(
      "Parallel checkpoint items[1] completion validation failed: merge_status is not merged or worktree_removed; found: 'blocked_drift'.",
    );
  });

  it("exempts a withdrawn item", () => {
    const state = buildCompletedState();
    itemAt(state, 1)["state"] = "withdrawn";
    delete itemAt(state, 1)["merge_status"];

    expect(validateState(state, true)).toEqual([]);
  });

  it("requires a close mutation in open mode", () => {
    const state = buildCompletedState();
    state["mode"] = "open";

    expect(validateState(state, true)).toEqual([
      "Parallel checkpoint completion validation failed: open mode requires a mutations[] entry with op 'close'.",
    ]);
  });

  it("accepts a recorded close mutation in open mode", () => {
    const state = buildCompletedState();
    state["mode"] = "open";
    state["mutations"] = [buildCloseMutation()];

    expect(validateState(state, true)).toEqual([]);
  });

  it("still applies the per-item condition in open mode", () => {
    const state = buildValidParallelState();
    state["mode"] = "open";
    state["mutations"] = [buildCloseMutation()];

    expect(
      validateState(state, true).some((error) =>
        error.includes("completion validation failed: merge_status"),
      ),
    ).toBe(true);
  });
});
