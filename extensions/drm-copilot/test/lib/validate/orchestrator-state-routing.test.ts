import { describe, expect, it } from "@jest/globals";

import { validateRoutingContract } from "../../../src/lib/validate/orchestrator-state-routing";

/**
 * Routing matrix mirroring the `large` route shape of the real
 * `config/orchestration-routing.json` so the contract test exercises the same
 * required agents/skills/MCP tools without reading from disk.
 */
const REQUIRED_AGENTS = [
  "task-researcher",
  "prd-feature",
  "atomic-planner",
  "atomic-executor",
  "feature-reviewer",
  "commit-steward",
];
const REQUIRED_SKILLS = [
  "orchestrate",
  "orchestrator-workflow",
  "feature-promotion-lifecycle",
  "repo-automation-adapter",
  "atomic-plan-contract",
  "acceptance-criteria-tracking",
  "pr-context-artifacts",
  "pr-base-branch-merge-base",
];
const REQUIRED_MCP_TOOLS = [
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "collect_commit_context",
  "collect_pr_context",
  "validate_orchestration_artifacts",
];

const ROUTING_MATRIX = {
  routes: {
    large: {
      required_agents: REQUIRED_AGENTS,
      required_skills: REQUIRED_SKILLS,
      required_mcp_tools: REQUIRED_MCP_TOOLS,
    },
  },
};

/** Build a completion-safe large-path state object for mutation. */
function buildCompleteLargeState(): Record<string, unknown> {
  return {
    route_id: "large",
    path_selected: "large",
    required_agents: [...REQUIRED_AGENTS],
    required_skills: [...REQUIRED_SKILLS],
    required_mcp_tools: [...REQUIRED_MCP_TOOLS],
    delegation_receipts: REQUIRED_AGENTS.map((agent, index) => ({
      step: `handoff-${index + 1}`,
      agent_name: agent,
    })),
    skill_receipts: REQUIRED_SKILLS.map((skill) => ({
      skill,
      required: true,
      evidence: `artifact:${skill}`,
    })),
    mcp_call_receipts: REQUIRED_MCP_TOOLS.map((tool) => ({
      tool,
      ok: true,
      evidence: `mcp_call:${tool}`,
    })),
    local_execution_overrides: [],
    delegation_bypasses: [],
    lifecycle_operations: REQUIRED_MCP_TOOLS.map((tool) => ({
      name: tool,
      surface: "mcp",
    })),
  };
}

function validate(state: Record<string, unknown>): string[] {
  return validateRoutingContract(state, { routingMatrix: ROUTING_MATRIX });
}

describe("validateRoutingContract", () => {
  it("accepts a checkpoint that proves all mandatory route evidence", () => {
    // Arrange / Act / Assert
    expect(validate(buildCompleteLargeState())).toEqual([]);
  });

  it("reports a missing routes object", () => {
    // Arrange / Act
    const errors = validateRoutingContract(buildCompleteLargeState(), {
      routingMatrix: { version: 1 },
    });

    // Assert
    expect(errors).toEqual(["Routing matrix missing routes object."]);
  });

  it("reports when neither route_id nor path_selected selects a route", () => {
    // Arrange
    const state = buildCompleteLargeState();
    delete state["route_id"];
    delete state["path_selected"];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toEqual([
      "Checkpoint route_id or path_selected must select a route.",
    ]);
  });

  it("falls back to path_selected when route_id is absent", () => {
    // Arrange
    const state = buildCompleteLargeState();
    delete state["route_id"];

    // Act
    const errors = validate(state);

    // Assert: path_selected = large still resolves the route cleanly.
    expect(errors).toEqual([]);
  });

  it("reports an unknown route id", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["route_id"] = "unknown";

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toEqual([
      "Checkpoint selected route has no routing-matrix entry: unknown.",
    ]);
  });

  it("reports a required_agents list mismatch", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["required_agents"] = ["atomic-planner"];

    // Act
    const errors = validate(state);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("required_agents must match routing matrix"),
      ),
    ).toBe(true);
  });

  it("reports a required_skills list mismatch", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["required_skills"] = ["orchestrate"];

    // Act
    const errors = validate(state);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("required_skills must match routing matrix"),
      ),
    ).toBe(true);
  });

  it("reports a required_mcp_tools list mismatch", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["required_mcp_tools"] = ["collect_pr_context"];

    // Act
    const errors = validate(state);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("required_mcp_tools must match routing matrix"),
      ),
    ).toBe(true);
  });

  it("reports a missing required agent receipt", () => {
    // Arrange: drop the first delegation receipt (task-researcher).
    const state = buildCompleteLargeState();
    state["delegation_receipts"] = (
      state["delegation_receipts"] as unknown[]
    ).slice(1);

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint missing required agent receipt: task-researcher.",
    );
  });

  it("reports a missing required skill receipt", () => {
    // Arrange: drop the first skill receipt (orchestrate).
    const state = buildCompleteLargeState();
    state["skill_receipts"] = (state["skill_receipts"] as unknown[]).slice(1);

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint missing required skill receipt: orchestrate.",
    );
  });

  it("reports a missing successful MCP receipt", () => {
    // Arrange: mark the first MCP receipt as not ok.
    const state = buildCompleteLargeState();
    const receipts = state["mcp_call_receipts"] as Record<string, unknown>[];
    receipts[0] = { ...receipts[0], ok: false };

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint missing successful MCP receipt: new_potential_entry.",
    );
  });

  it("reports a non-empty local_execution_overrides list", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["local_execution_overrides"] = [{ step: "S8" }];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint local_execution_overrides must be empty at completion.",
    );
  });

  it("reports a missing (non-list) delegation_bypasses field", () => {
    // Arrange
    const state = buildCompleteLargeState();
    delete state["delegation_bypasses"];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation_bypasses must be an empty list at completion.",
    );
  });

  it("reports a non-MCP lifecycle operation", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["lifecycle_operations"] = [
      { name: "new_active_feature_folder", surface: "cli" },
    ];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint lifecycle_operations #0 did not use MCP surface.",
    );
  });

  it("reports a non-list lifecycle_operations field", () => {
    // Arrange
    const state = buildCompleteLargeState();
    state["lifecycle_operations"] = "nope";

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint lifecycle_operations must be a list when present.",
    );
  });
});
