/**
 * In-memory live-truth reconciliation tests for parallel child resume.
 */

import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";
import {
  buildValidParallelState,
  type JsonRecord,
} from "./parallel-state-test-support";

const HEAD_A = "a".repeat(40);
const HEAD_B = "b".repeat(40);
const SPEC_A = "c".repeat(64);
const SPEC_B = "d".repeat(64);
const CHECKPOINT_A = "e".repeat(64);
const CHECKPOINT_B = "f".repeat(64);

function items(state: JsonRecord): JsonRecord[] {
  const value = state["items"];
  if (!Array.isArray(value)) {
    throw new TypeError("fixture items must be an array");
  }
  return value as JsonRecord[];
}

function bindItem(
  item: JsonRecord,
  batch: number,
  head: string,
  specHash: string,
  checkpointHash: string,
): void {
  const key = item["issue_num"];
  if (typeof key !== "number") {
    throw new TypeError("fixture issue_num must be a number");
  }
  const branch = "feature/parallel-item-" + String(key);
  const prefix = "artifacts/orchestration/parallel/" + String(key);
  Object.assign(item, {
    state: batch === 0 ? "in_flight" : "scheduled",
    merge_status: batch === 0 ? "ci_green" : "not_started",
    cohort: 0,
    batch,
    repository: "owner/repository",
    origin_main_head: HEAD_A,
    worktree_path: "C:/worktrees/parallel-item-" + String(key),
    branch_name: branch,
    checked_head: head,
    launch_id: "parallel-" + String(key),
    spec_sha256: specHash,
    checkpoint_sha256: checkpointHash,
    pr_number: key,
    pr_base_branch: "main",
    pr_head_branch: branch,
    pr_head_sha: head,
    pr_state: "OPEN",
    checks_head_sha: head,
    checks_conclusion: "success",
    authority_receipt_path: prefix + "-authority.json",
    delegation_receipt_path: prefix + "-delegation.json",
    topology_receipt_path: prefix + "-topology.json",
    model_routing_receipt_path: prefix + "-model-routing.json",
    deployment_agent: "orchestrator-c3-elevated",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "high",
    permissions: "orchestrator-workspace",
    child_status_path: prefix + "-status.json",
    child_status_pid: 3210 + batch,
  });
}

function resumeState(): JsonRecord {
  const state = buildValidParallelState();
  const [first, second] = items(state);
  if (first === undefined || second === undefined) {
    throw new TypeError("fixture requires two items");
  }
  bindItem(first, 0, HEAD_A, SPEC_A, CHECKPOINT_A);
  bindItem(second, 1, HEAD_B, SPEC_B, CHECKPOINT_B);
  state["resume_required"] = true;
  state["resume_truth"] = {
    schema_version: 1,
    selected_issue_num: first["issue_num"],
    repository: first["repository"],
    origin_main_head: first["origin_main_head"],
    worktree_path: first["worktree_path"],
    branch_name: first["branch_name"],
    worktree_head: first["checked_head"],
    pr_number: first["pr_number"],
    pr_base_branch: first["pr_base_branch"],
    pr_head_branch: first["pr_head_branch"],
    pr_head_sha: first["pr_head_sha"],
    pr_state: first["pr_state"],
    checks_head_sha: first["checks_head_sha"],
    checks_conclusion: first["checks_conclusion"],
    launch_id: first["launch_id"],
    spec_sha256: first["spec_sha256"],
    checkpoint_sha256: first["checkpoint_sha256"],
    latest_mutation_sequence: 0,
    recolor_generation: state["recolor_generation"],
    drift_resolution_generation: state["recolor_generation"],
    unresolved_drift: false,
    authority_receipt_path: first["authority_receipt_path"],
    delegation_receipt_path: first["delegation_receipt_path"],
    topology_receipt_path: first["topology_receipt_path"],
    model_routing_receipt_path: first["model_routing_receipt_path"],
    deployment_agent: first["deployment_agent"],
    model: first["model"],
    model_reasoning_effort: first["model_reasoning_effort"],
    permissions: first["permissions"],
    child_status_path: first["child_status_path"],
    child_status_launch_id: first["launch_id"],
    child_status_pid: first["child_status_pid"],
    live_process_pid: first["child_status_pid"],
    live_process_running: false,
    cached_child_status_state: "running",
    should_relaunch: true,
  };
  return state;
}

function truth(state: JsonRecord): JsonRecord {
  const value = state["resume_truth"];
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new TypeError("fixture resume_truth must be an object");
  }
  return value as JsonRecord;
}

function resumeErrors(state: JsonRecord): string[] {
  return validateParallelOrchestratorStateText(JSON.stringify(state)).filter(
    (error) => error.startsWith("PARALLEL_RESUME_"),
  );
}

describe("parallel orchestrator resume live truth", () => {
  it("preserves legacy checkpoints without an explicit resume gate", () => {
    expect(resumeErrors(buildValidParallelState())).toEqual([]);
  });

  it("accepts matching truth without mutating the input", () => {
    const state = resumeState();
    const snapshot = JSON.stringify(state);

    expect(resumeErrors(state)).toEqual([]);
    expect(JSON.stringify(state)).toBe(snapshot);
  });

  it.each([
    ["origin_main_head", HEAD_B, "PARALLEL_RESUME_GIT_MISMATCH"],
    [
      "worktree_path",
      "C:/worktrees/wrong",
      "PARALLEL_RESUME_WORKTREE_MISMATCH",
    ],
    ["pr_head_sha", HEAD_B, "PARALLEL_RESUME_GITHUB_MISMATCH"],
    ["spec_sha256", SPEC_B, "PARALLEL_RESUME_LAUNCH_MISMATCH"],
    ["latest_mutation_sequence", 1, "PARALLEL_RESUME_MUTATION_MISMATCH"],
    ["unresolved_drift", true, "PARALLEL_RESUME_DRIFT_UNRESOLVED"],
    ["model", "gpt-5.6-terra", "PARALLEL_RESUME_ROUTING_MISMATCH"],
    ["child_status_pid", 9999, "PARALLEL_RESUME_CHILD_STATUS_MISMATCH"],
    ["selected_issue_num", 445, "PARALLEL_RESUME_ORDER_MISMATCH"],
  ])("assigns a stable reason code to %s", (field, value, reasonCode) => {
    const state = resumeState();
    truth(state)[field] = value;

    expect(resumeErrors(state)).toContain(reasonCode);
  });

  it.each(["launch_id", "worktree_path", "branch_name", "pr_number"])(
    "rejects duplicate %s identity",
    (field) => {
      const state = resumeState();
      const [first, second] = items(state);
      if (first === undefined || second === undefined) {
        throw new TypeError("fixture requires two items");
      }
      second[field] = first[field];

      expect(resumeErrors(state)).toContain(
        "PARALLEL_RESUME_IDENTITY_DUPLICATE",
      );
    },
  );

  it("fails closed when explicit truth is missing or contains fan-in state", () => {
    const missing = resumeState();
    delete missing["resume_truth"];
    expect(resumeErrors(missing)).toEqual(["PARALLEL_RESUME_TRUTH_REQUIRED"]);

    const fanIn = resumeState();
    truth(fanIn)["fan_in_pr"] = 9001;
    expect(resumeErrors(fanIn)).toContain("PARALLEL_RESUME_FAN_IN_FORBIDDEN");
  });

  it("uses live process truth instead of cached child status", () => {
    const state = resumeState();
    expect(truth(state)["cached_child_status_state"]).toBe("running");
    expect(resumeErrors(state)).toEqual([]);

    truth(state)["live_process_running"] = true;
    expect(resumeErrors(state)).toContain("PARALLEL_RESUME_PROCESS_RUNNING");
  });
});
