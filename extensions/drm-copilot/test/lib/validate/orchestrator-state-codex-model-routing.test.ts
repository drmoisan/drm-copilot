import { describe, expect, it } from "@jest/globals";

import {
  resolveCodexDeployment,
  validateCodexModelRoutingGate,
  validateCodexModelRoutingReceipt,
  validateCodexModelRoutingReceipts,
} from "../../../src/lib/validate/orchestrator-state-codex-model-routing";
import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

function delegationReceipt(agentName: string): Record<string, unknown> {
  return {
    step: "S5",
    agent_name: agentName,
    agent_id: "agent-1",
    skill_source: "orchestrate",
    started_at: "2026-07-10T10:00:00Z",
    completed_at: "2026-07-10T10:01:00Z",
    result_signal: "COMPLETE",
    artifact_paths: ["artifacts/orchestration/agent-1.json"],
  };
}

function baseState(agentName: string | null = "atomic-executor") {
  const state: Record<string, unknown> = {
    objective: "execute one feature",
    change_budget_estimate: "small",
    path_selected: "small",
    "promotion-type": "feature",
    "short-name": "sample",
    relativeFile: "docs/features/potential/sample.md",
    "long-name": "sample-1",
    "issue-num": "1",
    "feature-folder": "docs/features/active/sample-1",
    "work-mode": "minor-audit",
    "plan-path": "docs/features/active/sample-1/plan.md",
    completed_steps: [],
    next_step: "S5_atomic_execution",
    last_updated: "2026-07-10T10:00:00Z",
    step5_status: "pending",
    step6_status: "pending",
    step7_status: "pending",
    step8_status: "pending",
    step9_status: "pending",
    step10_status: "pending",
    delegation_receipts: [],
    blocked_reason: "none",
  };
  if (agentName !== null) {
    state["delegation_receipts"] = [delegationReceipt(agentName)];
  }
  return state;
}

function codexReceipt(
  logicalAgent = "atomic-executor",
  context = "standalone",
  ceiling = "C3",
): Record<string, unknown> {
  return {
    ...resolveCodexDeployment(logicalAgent, "C3", context, ceiling),
    phase: "S5_atomic_execution",
  };
}

function validate(state: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(state), {
    requireCodexModelRouting: true,
  });
}

describe("Codex model-routing checkpoint receipts", () => {
  it("accepts an exact receipt for a delegated logical agent", () => {
    // Arrange
    const state = baseState();
    state["codex_model_routing_receipts"] = [codexReceipt()];

    // Act / Assert
    expect(validate(state)).toEqual([]);
  });

  it("accepts a delegation named by its generated deployment agent", () => {
    // Arrange
    const state = baseState("atomic-executor-c3");
    state["codex_model_routing_receipts"] = [codexReceipt()];

    // Act / Assert
    expect(validate(state)).toEqual([]);
  });

  it("matches the feature-review route alias to its reviewer deployment", () => {
    // Arrange
    const state = baseState("feature-reviewer-c2");
    state["codex_model_routing_receipts"] = [
      {
        ...resolveCodexDeployment("feature-review", "C2", "standalone", "C2"),
        phase: "S8_feature_review",
      },
    ];

    // Act / Assert
    expect(validate(state)).toEqual([]);
  });

  it("requires a receipt list after delegation when the gate is enabled", () => {
    // Arrange / Act
    const errors = validate(baseState());

    // Assert
    expect(errors).toContain(
      "Checkpoint codex_model_routing_receipts must be a list when present.",
    );
  });

  it("does not require receipts before a delegation is recorded", () => {
    // Arrange / Act / Assert
    expect(validate(baseState(null))).toEqual([]);
  });

  it("rejects a receipt whose model differs from deterministic routing", () => {
    // Arrange
    const state = baseState();
    const receipt = codexReceipt();
    receipt["model"] = "gpt-5.6-sol";
    state["codex_model_routing_receipts"] = [receipt];

    // Act
    const errors = validate(state);

    // Assert
    expect(
      errors.some((error) => error.includes(".model must be 'gpt-5.6-terra'")),
    ).toBe(true);
  });

  it("rejects a receipt that suppresses the required C3 epic overlay", () => {
    // Arrange
    const state = baseState();
    const receipt = codexReceipt("atomic-executor", "epic_execution_child");
    receipt["deployment_agent"] = "atomic-executor-c3";
    receipt["model"] = "gpt-5.6-terra";
    receipt["c3_overlay_applied"] = false;
    receipt["c3_overlay_reason"] = null;
    state["codex_model_routing_receipts"] = [receipt];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors.some((error) => error.includes("deployment_agent"))).toBe(
      true,
    );
    expect(errors.some((error) => error.includes("c3_overlay_applied"))).toBe(
      true,
    );
  });

  it("requires a receipt for the actual delegated agent", () => {
    // Arrange
    const state = baseState();
    state["codex_model_routing_receipts"] = [codexReceipt("atomic-planner")];

    // Act
    const errors = validate(state);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("missing a receipt for delegated agent"),
      ),
    ).toBe(true);
  });

  it("rejects a decreasing orchestration complexity ceiling", () => {
    // Arrange
    const state = baseState();
    const first = codexReceipt("atomic-executor", "standalone", "C4");
    const second = codexReceipt("atomic-executor", "standalone", "C3");
    second["phase"] = "S6_feature_review";
    state["codex_model_routing_receipts"] = [first, second];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint codex_model_routing_receipts[1]." +
        "orchestration_complexity_ceiling must be monotonic; " +
        "found C3 after C4.",
    );
  });

  it("requires affected delegation evidence when the ceiling rises", () => {
    const state = baseState();
    const first = codexReceipt("atomic-executor", "standalone", "C3");
    const second = codexReceipt("atomic-executor", "standalone", "C4");
    second["phase"] = "S6_feature_review";
    state["codex_model_routing_receipts"] = [first, second];

    expect(
      validate(state).some((error) =>
        error.includes("must record a ceiling increase"),
      ),
    ).toBe(true);

    second["ceiling_transition"] = {
      from: "C3",
      to: "C4",
      affected_delegation_ids: ["agent-1"],
    };
    expect(validate(state)).toEqual([]);
  });

  it("validates a present receipt even when the gate flag is absent", () => {
    // Arrange
    const state = baseState(null);
    const receipt = codexReceipt();
    delete receipt["model"];
    state["codex_model_routing_receipts"] = [receipt];

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint codex_model_routing_receipts[0] missing required keys: model.",
    );
  });

  it("exports single-receipt validation for planner readiness", () => {
    // Arrange
    const receipt = codexReceipt("epic-planner");
    receipt["model_reasoning_effort"] = "low";

    // Act
    const errors = validateCodexModelRoutingReceipt(
      receipt,
      "Epic planner feature 'sample'.model_routing_receipt",
    );

    // Assert
    expect(errors).toContain(
      "Epic planner feature 'sample'.model_routing_receipt.model_reasoning_effort " +
        "must be 'ultra', found 'low'.",
    );
  });

  it("rejects non-list and non-object receipt containers", () => {
    // Arrange / Act / Assert
    expect(validateCodexModelRoutingReceipts("invalid")).toEqual([
      "Checkpoint codex_model_routing_receipts must be a list when present.",
    ]);
    expect(validateCodexModelRoutingReceipts(["invalid"])).toEqual([
      "Checkpoint codex_model_routing_receipts[0] must be an object.",
    ]);
  });

  it("rejects empty phases and invalid routing inputs with exact prefixes", () => {
    // Arrange
    const emptyPhase = codexReceipt();
    emptyPhase["phase"] = " ";
    const invalidBand = codexReceipt();
    invalidBand["complexity_band"] = "C5";

    // Act / Assert
    expect(validateCodexModelRoutingReceipts([emptyPhase])).toContain(
      "Checkpoint codex_model_routing_receipts[0].phase must be a non-empty string.",
    );
    expect(validateCodexModelRoutingReceipts([invalidBand])).toContain(
      "Checkpoint codex_model_routing_receipts[0] has invalid routing inputs: " +
        "complexity_band must be one of ('C1', 'C2', 'C3', 'C4'), found 'C5'.",
    );
  });

  it.each([
    ["logical_agent", 7],
    ["logical_agent", ["invalid"]],
    ["logical_agent", { name: "invalid" }],
    ["execution_context", true],
    ["orchestration_complexity_ceiling", null],
  ])("rejects non-string routing input %s=%p", (key, value) => {
    // Arrange
    const receipt = codexReceipt();
    receipt[key] = value;

    // Act
    const errors = validateCodexModelRoutingReceipts([receipt]);

    // Assert
    expect(
      errors.some((error) => error.includes("has invalid routing inputs")),
    ).toBe(true);
  });

  it("defensively skips malformed delegation and agent-name entries", () => {
    // Arrange
    const state = baseState(null);
    state["delegation_receipts"] = [
      "invalid",
      { agent_name: " " },
      delegationReceipt("atomic-executor"),
    ];
    state["codex_model_routing_receipts"] = [
      "invalid",
      { logical_agent: 7, deployment_agent: false },
      codexReceipt(),
    ];

    // Act
    const errors = validateCodexModelRoutingGate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint codex_model_routing_receipts[0] must be an object.",
    );
    expect(
      errors.some((error) =>
        error.includes("missing a receipt for delegated agent"),
      ),
    ).toBe(false);
  });

  it("treats namespaced delegation receipts as delegation-free", () => {
    // Arrange
    const state = baseState(null);
    state["delegation_receipts"] = { promotion: {} };

    // Act / Assert
    expect(validateCodexModelRoutingGate(state)).toEqual([]);
  });

  it("keeps the legacy model-routing flag independent", () => {
    // Arrange
    const state = baseState(null);

    // Act
    const absent = validateOrchestratorStateText(JSON.stringify(state));
    const explicitFalse = validateOrchestratorStateText(JSON.stringify(state), {
      requireCodexModelRouting: false,
    });

    // Assert
    expect(absent).toEqual(explicitFalse);
  });
});
