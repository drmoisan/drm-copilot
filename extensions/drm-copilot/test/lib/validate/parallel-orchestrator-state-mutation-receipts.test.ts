/** Receipt-bound mutation and mode-transition tests for the public validator. */

import {
  buildValidParallelState,
  cohortAt,
  itemAt,
  type JsonRecord,
  validateState,
} from "./parallel-state-test-support";
import { validateMutationReceiptBindings } from "../../../src/lib/validate/parallel-orchestrator-state-mutation-receipts";

const WORKTREE = "C:/worktrees/parallel-item-444";
const CONTEXT = "Parallel checkpoint";

/** Return one mutable object collection from a fixture. */
function recordsAt(state: JsonRecord, key: string): JsonRecord[] {
  const value = state[key];
  if (!Array.isArray(value)) {
    throw new Error(`fixture ${key} is not an array`);
  }
  return value as JsonRecord[];
}

/** Build a valid in-progress checkpoint for receipt-bound mutation tests. */
function buildState(): JsonRecord {
  const state = buildValidParallelState();
  const first = itemAt(state, 0);
  first["state"] = "in_flight";
  first["merge_status"] = "pr_open";
  first["worktree_identity"] = WORKTREE;
  return state;
}

/** Build one complete seven-field remove record. */
function removeMutation(
  disposition: string | null,
  generation = 0,
  priorState = "in_flight",
): JsonRecord {
  return {
    op: "remove",
    item_key: 444,
    at: "2026-08-10T20-34",
    prior_state: priorState,
    new_state: "withdrawn",
    disposition,
    recolor_generation: generation,
  };
}

/** Build one exact operation, item, worktree, and token-bound receipt. */
function mutationReceipt(operation: string): JsonRecord {
  return {
    mutation_index: 0,
    receipt_path: `artifacts/orchestration/mutations/item-444-${operation}.json`,
    operation,
    item_key: 444,
    worktree_identity: WORKTREE,
    confirmation_token: `confirm:${operation}:444:${WORKTREE}`,
  };
}

/** Build a post-removal checkpoint with one matching durable receipt. */
function receiptBoundRemoval(operation: string): JsonRecord {
  const state = buildState();
  itemAt(state, 0)["state"] = "withdrawn";
  cohortAt(state, 0)["item_keys"] = [445];
  state["mutations"] = [removeMutation(operation)];
  state["mutation_receipts"] = [mutationReceipt(operation)];
  return state;
}

/** Run the focused pure receipt validator without core composition. */
function receiptErrors(state: JsonRecord): string[] {
  return validateMutationReceiptBindings(state, CONTEXT);
}

describe("receipt-bound mutation runtime validation", () => {
  it("keeps legacy checkpoints without mutation receipts compatible", () => {
    expect(validateState(buildState())).toEqual([]);
  });

  it.each(["detach", "abandon"])(
    "accepts an exact %s confirmation receipt",
    (operation) => {
      expect(receiptErrors(receiptBoundRemoval(operation))).toEqual([]);
    },
  );

  it.each([
    ["operation", "abandon", "operation must match disposition 'detach'"],
    ["item_key", 445, "item_key must match mutation item 444"],
    ["worktree_identity", "C:/wrong", "worktree_identity must match item 444"],
    ["confirmation_token", "confirm:detach:444:C:/wrong", "token must equal"],
  ] as const)(
    "rejects a mismatched %s confirmation binding",
    (field, value, expected) => {
      const state = receiptBoundRemoval("detach");
      recordsAt(state, "mutation_receipts")[0]![field] = value;

      expect(receiptErrors(state).join("\n")).toContain(expected);
    },
  );

  it("requires a receipt for an in-flight detach or abandon", () => {
    const state = receiptBoundRemoval("detach");
    state["mutation_receipts"] = [];

    expect(receiptErrors(state).join("\n")).toContain(
      "requires one matching mutation_receipts[] entry",
    );
  });

  it("composes receipt binding through the public checkpoint validator", () => {
    const state = receiptBoundRemoval("detach");
    recordsAt(state, "mutation_receipts")[0]!["confirmation_token"] =
      "confirm:detach:444:C:/wrong";

    expect(validateState(state).join("\n")).toContain("token must equal");
  });

  it("rejects removal of an already merged item", () => {
    const state = buildState();
    const first = itemAt(state, 0);
    first["state"] = "merged";
    first["merge_status"] = "merged";
    state["mutations"] = [removeMutation(null, 0, "merged")];

    expect(validateState(state).join("\n")).toContain(
      "cannot remove item 444 from prior_state 'merged'",
    );
  });

  it("pins in-flight removal to the existing recolor generation", () => {
    const state = receiptBoundRemoval("detach");
    state["recolor_generation"] = 1;
    cohortAt(state, 0)["generation"] = 1;
    recordsAt(state, "mutations")[0]!["recolor_generation"] = 1;

    expect(validateState(state).join("\n")).toContain(
      "in-flight remove must preserve recolor_generation 0; found: 1",
    );
  });

  it("rejects close atomically while an item remains in flight", () => {
    const state = buildState();
    state["mutations"] = [
      {
        op: "close",
        item_key: null,
        at: "2026-08-10T20-35",
        prior_state: null,
        new_state: null,
        disposition: null,
        recolor_generation: 0,
      },
    ];

    expect(validateState(state).join("\n")).toContain(
      "close requires no item in flight; still in flight: [444]",
    );
  });

  it("keeps mutation records complete and generation ordered", () => {
    const incomplete = receiptBoundRemoval("detach");
    delete recordsAt(incomplete, "mutations")[0]!["at"];
    expect(validateState(incomplete).join("\n")).toContain(
      "is missing required field: at",
    );

    const outOfOrder = buildState();
    outOfOrder["recolor_generation"] = 1;
    outOfOrder["mutations"] = [
      removeMutation(null, 1),
      removeMutation(null, 0),
    ];
    expect(validateState(outOfOrder).join("\n")).toContain(
      "mutation log must be monotonically non-decreasing",
    );
  });

  it("rejects explicit completion while open mode lacks close", () => {
    const state = buildState();
    state["mode"] = "open";
    state["cohorts"] = [];
    for (const item of recordsAt(state, "items")) {
      item["state"] = "merged";
      item["merge_status"] = "worktree_removed";
    }

    expect(validateState(state, true).join("\n")).toContain(
      "open mode requires a mutations[] entry with op 'close'",
    );
  });

  it("does not mutate the checkpoint while validating receipts", () => {
    const state = receiptBoundRemoval("detach");
    const before = JSON.stringify(state);

    expect(receiptErrors(state)).toEqual(receiptErrors(state));
    expect(JSON.stringify(state)).toBe(before);
  });
});
