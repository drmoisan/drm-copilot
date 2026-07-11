import { describe, expect, it } from "@jest/globals";

import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

function record(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error("test fixture value must be an object");
  }
  return value;
}

function feature(issueNum: number): Record<string, unknown> {
  const folder = `docs/features/active/feature-${issueNum}`;
  const delegationId = `prepare-${issueNum}`;
  const deploymentAgent = "orchestrator-c3-elevated";
  return {
    issue_num: issueNum,
    feature_folder: folder,
    depends_on: [],
    wave: 0,
    complexity_band: "C3",
    preparation_status: "prepared",
    research_path: `artifacts/research/feature-${issueNum}.md`,
    plan_path: `${folder}/plan.md`,
    preflight_status: "PREFLIGHT: ALL CLEAR",
    branch_name: `feature/feature-${issueNum}`,
    worktree_path: `/removed/worktrees/feature-${issueNum}`,
    delegation_receipt: {
      delegation_id: delegationId,
      feature_folder: folder,
      issue_num: issueNum,
      agent_name: deploymentAgent,
    },
    model_routing_receipt: {
      logical_agent: "orchestrator",
      deployment_agent: deploymentAgent,
      phase: "preparation",
      complexity_band: "C3",
      execution_context: "epic_preparation_child",
      orchestration_complexity_ceiling: "C3",
      c3_overlay_applied: true,
      c3_overlay_reason: "epic_context",
      model: "gpt-5.6-sol",
      model_reasoning_effort: "high",
      delegation_id: delegationId,
    },
    launch_receipt_path: `artifacts/orchestration/epic-child-launches/preparation/feature-${issueNum}.receipt.json`,
    launch_status_path:
      "artifacts/orchestration/epic-child-launches/preparation/wave.status.json",
    topology_receipt: {
      ...resolveCodexTopology([], 0, 0, "epic_preparation_child"),
      phase: "preparation",
    },
  };
}

function state(): Record<string, unknown> {
  return {
    objective: "prepare an epic",
    epic_feature_folder: "sample-epic",
    epic_manifest_path: "docs/features/epics/sample-epic/epic.md",
    integration_branch: "epic/sample-epic-integration",
    max_parallel_features: 4,
    epic_worthiness: { verdict: "epic", rationale: "two features" },
    features: [feature(101), feature(102)],
    kickoff_prompt_path: "artifacts/orchestration/epic-kickoff-sample-epic.md",
    completed_steps: ["preparation"],
    next_step: "EPIC_EXECUTION_READY",
    last_updated: "2026-07-10T10:00:00Z",
    topology_receipt: {
      ...resolveCodexTopology([], 0, 0, "standalone", {
        rootPersona: "epic-planner",
      }),
      phase: "epic_planning",
    },
  };
}

function readyErrors(value: Record<string, unknown>): string[] {
  return validateEpicPlannerStateText(JSON.stringify(value), {
    requireReadyForExecution: true,
  });
}

describe("epic planner child launch binding", () => {
  it("accepts complete evidence for a removed worktree", () => {
    expect(readyErrors(state())).toEqual([
      "Execution-ready planner validation requires repository context.",
    ]);
  });

  it("activates only for execution readiness", () => {
    const value = state();
    const item = (value["features"] as Record<string, unknown>[])[0]!;
    for (const key of [
      "branch_name",
      "worktree_path",
      "delegation_receipt",
      "launch_receipt_path",
      "launch_status_path",
    ]) {
      delete item[key];
    }

    expect(validateEpicPlannerStateText(JSON.stringify(value))).toEqual([]);
    const errors = readyErrors(value);
    expect(
      errors.some((error) =>
        error.includes("features[0] launch binding.branch_name"),
      ),
    ).toBe(true);
    expect(
      errors.some((error) =>
        error.includes(
          "features[0] launch binding.delegation_receipt must be an object",
        ),
      ),
    ).toBe(true);
  });

  it.each([
    ["branch_name", " ", ".branch_name must be a non-empty unique string."],
    [
      "worktree_path",
      "removed/worktrees/feature-101",
      ".worktree_path must be a non-empty canonical absolute path.",
    ],
    [
      "worktree_path",
      "/removed/worktrees/../feature-101",
      ".worktree_path must be a non-empty canonical absolute path.",
    ],
    [
      "launch_receipt_path",
      "artifacts/orchestration/other/receipt.json",
      ".launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.",
    ],
    [
      "launch_status_path",
      "artifacts/orchestration/epic-child-launches/../status.json",
      ".launch_status_path must be under artifacts/orchestration/epic-child-launches/.",
    ],
  ])("rejects invalid %s", (field, invalid, expected) => {
    const value = state();
    const item = (value["features"] as Record<string, unknown>[])[0]!;
    item[field] = invalid;

    expect(readyErrors(value).some((error) => error.endsWith(expected))).toBe(
      true,
    );
  });

  it.each([
    ["feature_folder", "other", ".feature_folder must match the feature."],
    ["issue_num", 999, ".issue_num must match the feature."],
    [
      "agent_name",
      "atomic-planner-c3-elevated",
      ".agent_name must name a generated orchestrator agent.",
    ],
  ])("rejects delegation %s mismatch", (field, invalid, expected) => {
    const value = state();
    const item = (value["features"] as Record<string, unknown>[])[0]!;
    record(item["delegation_receipt"])[field] = invalid;

    expect(readyErrors(value).some((error) => error.endsWith(expected))).toBe(
      true,
    );
  });

  it.each([
    [
      "delegation_id",
      "other",
      ".delegation_id must match delegation_receipt.delegation_id.",
    ],
    [
      "deployment_agent",
      "orchestrator-c2",
      ".deployment_agent must match delegation_receipt.agent_name.",
    ],
    [
      "execution_context",
      "epic_execution_child",
      ".execution_context must be 'epic_preparation_child'.",
    ],
  ])("rejects model receipt %s mismatch", (field, invalid, expected) => {
    const value = state();
    const item = (value["features"] as Record<string, unknown>[])[0]!;
    record(item["model_routing_receipt"])[field] = invalid;

    expect(readyErrors(value).some((error) => error.endsWith(expected))).toBe(
      true,
    );
  });

  it("requires unique branch and delegation identifiers", () => {
    const value = state();
    const [first, second] = value["features"] as Record<string, unknown>[];
    second!["branch_name"] = first!["branch_name"];
    const delegationId = record(first!["delegation_receipt"])["delegation_id"];
    record(second!["delegation_receipt"])["delegation_id"] = delegationId;
    record(second!["model_routing_receipt"])["delegation_id"] = delegationId;

    const errors = readyErrors(value);
    expect(
      errors.some((error) =>
        error.includes("features[1] launch binding.branch_name"),
      ),
    ).toBe(true);
    expect(
      errors.some((error) =>
        error.includes(
          "features[1] launch binding.delegation_receipt.delegation_id",
        ),
      ),
    ).toBe(true);
  });
});
