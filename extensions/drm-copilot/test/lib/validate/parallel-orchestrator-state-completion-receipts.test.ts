/**
 * Per-item PR, exact-head CI, merge, and worktree-removal receipt tests.
 */

import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";
import {
  buildValidParallelState,
  type JsonRecord,
} from "./parallel-state-test-support";

const CONTEXT = "Parallel checkpoint";
const HEAD_A = "a".repeat(40);
const HEAD_B = "b".repeat(40);
const MERGE_A = "c".repeat(40);
const MERGE_B = "d".repeat(40);

function items(state: JsonRecord): JsonRecord[] {
  const value = state["items"];
  if (!Array.isArray(value)) {
    throw new TypeError("fixture items must be an array");
  }
  return value as JsonRecord[];
}

function completedState(): JsonRecord {
  const state = buildValidParallelState();
  state["cohorts"] = [];
  for (const item of items(state)) {
    item["state"] = "merged";
    item["merge_status"] = "worktree_removed";
  }
  return state;
}

function bindCompletion(
  item: JsonRecord,
  headSha: string,
  mergeSha: string,
): void {
  const key = item["issue_num"];
  if (typeof key !== "number") {
    throw new TypeError("fixture issue_num must be a number");
  }
  const branch = `feature/parallel-item-${key}`;
  const receipt = `artifacts/orchestration/parallel/item-${key}-completion.json`;
  Object.assign(item, {
    branch_name: branch,
    base_branch: "main",
    worktree_path: `C:/worktrees/parallel-item-${key}`,
    checked_head: headSha,
    pr_number: key,
    pr_url: `https://github.example/pull/${key}`,
    pr_base_branch: "main",
    pr_head_branch: branch,
    pr_head_sha: headSha,
    pr_state: "MERGED",
    checks_head_sha: headSha,
    checks_conclusion: "success",
    merged_at: "2026-08-10T21:30:00Z",
    merge_commit_sha: mergeSha,
    merge_receipt_path: receipt,
    worktree_removed_at: "2026-08-10T21:31:00Z",
    worktree_removal_receipt_path: receipt,
    completion_receipt_path: receipt,
  });
}

function receiptState(): JsonRecord {
  const state = completedState();
  const [first, second] = items(state);
  if (first === undefined || second === undefined) {
    throw new TypeError("fixture requires two items");
  }
  bindCompletion(first, HEAD_A, MERGE_A);
  bindCompletion(second, HEAD_B, MERGE_B);
  return state;
}

function newErrors(state: JsonRecord): string[] {
  return validateParallelOrchestratorStateText(JSON.stringify(state), {
    requireComplete: true,
  }).filter(
    (error) => error !== `${CONTEXT} Codex readiness evidence is required.`,
  );
}

describe("parallel orchestrator per-item completion receipts", () => {
  it("preserves legacy completed checkpoints without receipt fields", () => {
    expect(newErrors(completedState())).toEqual([]);
  });

  it("accepts distinct main-only per-item completion receipts", () => {
    expect(newErrors(receiptState())).toEqual([]);
  });

  it("rejects a duplicate PR number across items", () => {
    const state = receiptState();
    const [first, second] = items(state);
    if (first === undefined || second === undefined) {
      throw new TypeError("fixture requires two items");
    }
    second["pr_number"] = first["pr_number"];

    expect(newErrors(state)).toEqual([
      `${CONTEXT} completion receipts assign PR ${String(
        first["pr_number"],
      )} to multiple items.`,
    ]);
  });

  it.each([
    ["pr_number", 0, "pr_number must be positive"],
    ["pr_base_branch", "epic/integration", "PR base branch must be 'main'"],
    [
      "pr_head_branch",
      "feature/wrong",
      "PR head branch must match branch_name",
    ],
    ["pr_head_sha", HEAD_B, "PR head SHA must match checked_head"],
    ["checks_head_sha", HEAD_B, "checks head SHA must match pr_head_sha"],
    [
      "checks_conclusion",
      "failure",
      "required checks conclusion must be 'success'",
    ],
    ["pr_state", "OPEN", "PR state must be 'MERGED'"],
  ])("rejects an exact PR/check mismatch in %s", (field, value, expected) => {
    const state = receiptState();
    const first = items(state)[0];
    if (first === undefined) {
      throw new TypeError("fixture requires one item");
    }
    first[field] = value;

    expect(newErrors(state).join("\n")).toContain(expected);
  });

  it.each([
    ["merge_commit_sha", "merge_commit_sha must be a 40-character SHA"],
    ["merge_receipt_path", "merge_receipt_path must be repository-relative"],
    ["worktree_removed_at", "worktree_removed_at must be a non-empty string"],
    [
      "worktree_removal_receipt_path",
      "worktree_removal_receipt_path must be repository-relative",
    ],
    [
      "completion_receipt_path",
      "completion_receipt_path must be repository-relative",
    ],
  ])("rejects a missing terminal receipt field %s", (field, expected) => {
    const state = receiptState();
    const first = items(state)[0];
    if (first === undefined) {
      throw new TypeError("fixture requires one item");
    }
    delete first[field];

    expect(newErrors(state).join("\n")).toContain(expected);
  });

  it("rejects a residual item worktree status", () => {
    const state = receiptState();
    const first = items(state)[0];
    if (first === undefined) {
      throw new TypeError("fixture requires one item");
    }
    first["merge_status"] = "merged";

    expect(newErrors(state).join("\n")).toContain(
      "merge_status must be 'worktree_removed'",
    );
  });

  it("rejects absolute, traversal, and backslash receipt paths", () => {
    for (const path of [
      "C:/outside.json",
      "../outside.json",
      "artifacts\\outside.json",
    ]) {
      const state = receiptState();
      const first = items(state)[0];
      if (first === undefined) {
        throw new TypeError("fixture requires one item");
      }
      first["completion_receipt_path"] = path;

      expect(newErrors(state).join("\n")).toContain(
        "completion_receipt_path must be repository-relative",
      );
    }
  });

  it("preserves deterministic error order and does not mutate input", () => {
    const state = receiptState();
    const first = items(state)[0];
    if (first === undefined) {
      throw new TypeError("fixture requires one item");
    }
    Object.assign(first, {
      pr_base_branch: "epic/integration",
      checks_head_sha: HEAD_B,
      checks_conclusion: "failure",
      pr_state: "OPEN",
    });
    const snapshot = JSON.stringify(state);

    const firstRun = newErrors(state);
    expect(firstRun).toEqual(newErrors(state));
    expect(JSON.stringify(state)).toBe(snapshot);
    const labels = [
      "PR base branch",
      "checks head SHA",
      "required checks conclusion",
      "PR state",
    ];
    expect(
      firstRun.map((error) => labels.find((label) => error.includes(label))),
    ).toEqual(labels);
  });
});
