import { describe, expect, it } from "@jest/globals";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";

function record(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error("test fixture value must be an object");
  }
  return value;
}

function feature(
  issueNum = 101,
  folder = "child-a",
  mergeStatus = "worktree_created",
): Record<string, unknown> {
  const delegationId = `delegate-${folder}`;
  const deploymentAgent = "orchestrator-c3-elevated";
  const artifactRoot = `artifacts/orchestration/epic-child-launches/wave-0/${folder}`;
  return {
    issue_num: issueNum,
    feature_folder: folder,
    depends_on: [],
    wave_number: 0,
    merge_status: mergeStatus,
    branch_name: `feature/${folder}`,
    worktree_path: `/repo/worktrees/${folder}`,
    delegation_receipt: {
      delegation_id: delegationId,
      feature_folder: folder,
      issue_num: issueNum,
      agent_name: deploymentAgent,
    },
    model_routing_receipt: {
      delegation_id: delegationId,
      deployment_agent: deploymentAgent,
      execution_context: "epic_execution_child",
    },
    launch_receipt_path: `${artifactRoot}.receipt.json`,
    launch_status_path: `${artifactRoot}.status.json`,
  };
}

function state(
  ...features: Record<string, unknown>[]
): Record<string, unknown> {
  return {
    objective: "execute prepared epic",
    route_id: "epic",
    epic_feature_folder: "sample-epic",
    integration_branch: "epic/sample-epic-integration",
    max_parallel_features: 4,
    completed_steps: ["manifest_parsed"],
    next_step: "wave_0",
    last_updated: "2026-07-10T10:00:00Z",
    waves: [
      {
        wave_number: 0,
        feature_folders: features.map((item) => item["feature_folder"]),
      },
    ],
    features,
  };
}

function launchErrors(errors: string[]): string[] {
  return errors.filter((error) => error.includes(" launch binding"));
}

describe("epic child launch binding", () => {
  it("accepts complete evidence under the model-routing gate", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(feature())),
      { requireCodexModelRouting: true },
    );

    expect(errors).toEqual([]);
  });

  it("activates under the topology gate", () => {
    const item = feature();
    delete item["delegation_receipt"];

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(item)),
      { requireCodexTopology: true },
    );

    expect(errors).toContain(
      "Epic checkpoint feature 'child-a' launch binding.delegation_receipt must be an object.",
    );
  });

  it("does not require evidence before the feature launches", () => {
    const item = feature(101, "child-a", "not_started");
    for (const key of [
      "branch_name",
      "worktree_path",
      "delegation_receipt",
      "model_routing_receipt",
      "launch_receipt_path",
      "launch_status_path",
    ]) {
      delete item[key];
    }

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(item)),
      { requireCodexModelRouting: true },
    );

    expect(errors).toEqual([]);
  });

  it("remains dormant without a routing or completion gate", () => {
    const item = feature();
    delete item["delegation_receipt"];

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(item)),
    );

    expect(errors).toEqual([]);
  });

  it("requires evidence for every feature under requireComplete", () => {
    const item = feature(101, "child-a", "not_started");
    delete item["model_routing_receipt"];
    const value = state(item);
    value["epic_merge_pr"] = { merge_commit_sha: "abc123" };

    const errors = validateEpicOrchestratorStateText(JSON.stringify(value), {
      requireComplete: true,
    });

    expect(errors).toContain(
      "Epic checkpoint feature 'child-a' launch binding.model_routing_receipt must be an object.",
    );
  });

  it("accepts complete persisted evidence at completion", () => {
    const value = state(feature(101, "child-a", "merged"));
    value["epic_merge_pr"] = { merge_commit_sha: "abc123" };

    const errors = validateEpicOrchestratorStateText(JSON.stringify(value), {
      requireComplete: true,
    });

    expect(errors).toEqual([]);
  });

  it.each([
    [
      "branch_name",
      " ",
      "Epic checkpoint feature 'child-a' launch binding.branch_name must be a non-empty unique string.",
    ],
    [
      "worktree_path",
      "repo/worktrees/child-a",
      "Epic checkpoint feature 'child-a' launch binding.worktree_path must be a non-empty canonical absolute path.",
    ],
    [
      "worktree_path",
      "/repo/worktrees/../child-a",
      "Epic checkpoint feature 'child-a' launch binding.worktree_path must be a non-empty canonical absolute path.",
    ],
    [
      "launch_receipt_path",
      "artifacts/orchestration/other/child-a.receipt.json",
      "Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.",
    ],
    [
      "launch_status_path",
      "artifacts/orchestration/epic-child-launches/../outside.json",
      "Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.",
    ],
  ])("rejects invalid %s", (field, invalid, expected) => {
    const item = feature();
    item[field] = invalid;

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(item)),
      { requireCodexModelRouting: true },
    );

    expect(errors).toContain(expected);
  });

  it.each([
    ["feature_folder", "other", "feature_folder must match the feature."],
    ["issue_num", 999, "issue_num must match the feature."],
    ["agent_name", "", "agent_name must be a non-empty string."],
  ])(
    "rejects delegation receipt mismatch for %s",
    (field, invalid, expectedSuffix) => {
      const item = feature();
      record(item["delegation_receipt"])[field] = invalid;

      const errors = validateEpicOrchestratorStateText(
        JSON.stringify(state(item)),
        { requireCodexModelRouting: true },
      );

      expect(errors.some((error) => error.endsWith(expectedSuffix))).toBe(true);
    },
  );

  it.each([
    [
      "delegation_id",
      "different",
      "delegation_id must match delegation_receipt.delegation_id.",
    ],
    [
      "deployment_agent",
      "orchestrator-c2",
      "deployment_agent must match delegation_receipt.agent_name.",
    ],
    [
      "execution_context",
      "standalone",
      "execution_context must be 'epic_execution_child'.",
    ],
  ])(
    "rejects model receipt mismatch for %s",
    (field, invalid, expectedSuffix) => {
      const item = feature();
      record(item["model_routing_receipt"])[field] = invalid;

      const errors = validateEpicOrchestratorStateText(
        JSON.stringify(state(item)),
        { requireCodexModelRouting: true },
      );

      expect(errors.some((error) => error.endsWith(expectedSuffix))).toBe(true);
    },
  );

  it("requires singular delegation and model receipts", () => {
    const item = feature();
    item["delegation_receipt"] = [];
    item["model_routing_receipt"] = [];

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(item)),
      { requireCodexModelRouting: true },
    );

    expect(launchErrors(errors)).toEqual([
      "Epic checkpoint feature 'child-a' launch binding.delegation_receipt must be an object.",
      "Epic checkpoint feature 'child-a' launch binding.model_routing_receipt must be an object.",
    ]);
  });

  it("requires unique branch and delegation identifiers", () => {
    const first = feature();
    const second = feature(102, "child-b");
    second["branch_name"] = first["branch_name"];
    const firstDelegation = record(first["delegation_receipt"]);
    const secondDelegation = record(second["delegation_receipt"]);
    const secondModel = record(second["model_routing_receipt"]);
    secondDelegation["delegation_id"] = firstDelegation["delegation_id"];
    secondModel["delegation_id"] = firstDelegation["delegation_id"];

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(first, second)),
      { requireCodexModelRouting: true },
    );

    expect(errors).toContain(
      "Epic checkpoint feature 'child-b' launch binding.branch_name must be a non-empty unique string.",
    );
    expect(errors).toContain(
      "Epic checkpoint feature 'child-b' launch binding.delegation_receipt.delegation_id must be a non-empty unique string.",
    );
  });

  it.each([0, 9, true])("cross-checks max_parallel_features=%p", (maximum) => {
    const value = state(feature());
    value["max_parallel_features"] = maximum;

    const errors = validateEpicOrchestratorStateText(JSON.stringify(value), {
      requireCodexModelRouting: true,
    });

    expect(errors).toContain(
      "Epic checkpoint max_parallel_features must be an integer from 1 through 8.",
    );
  });

  it("accepts canonical Windows worktree and absolute artifact paths", () => {
    const item = feature();
    item["worktree_path"] = "C:\\repo\\worktrees\\child-a";
    item["launch_receipt_path"] =
      "C:\\repo\\artifacts\\orchestration\\epic-child-launches\\wave-0\\child-a.receipt.json";
    item["launch_status_path"] =
      "C:\\repo\\artifacts\\orchestration\\epic-child-launches\\wave-0\\wave.status.json";

    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(state(item)),
      { requireCodexModelRouting: true },
    );

    expect(errors).toEqual([]);
  });
});
