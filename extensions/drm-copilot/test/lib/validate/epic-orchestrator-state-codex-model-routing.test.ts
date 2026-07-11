import { describe, expect, it } from "@jest/globals";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

function buildEpicState(
  agentName: string | null = "orchestrator-c3-elevated",
): Record<string, unknown> {
  const state: Record<string, unknown> = {
    objective: "execute prepared epic",
    route_id: "epic",
    epic_feature_folder: "sample-epic",
    integration_branch: "epic/sample-epic-integration",
    max_parallel_features: 4,
    completed_steps: ["manifest_parsed"],
    next_step: "wave_0",
    last_updated: "2026-07-10T10:00:00Z",
    waves: [{ wave_number: 0, feature_folders: ["feature-1"] }],
    features: [
      {
        issue_num: 1,
        feature_folder: "feature-1",
        depends_on: [],
        wave_number: 0,
        merge_status: "not_started",
      },
    ],
    delegation_receipts: [],
  };
  if (agentName !== null) {
    state["delegation_receipts"] = [{ agent_name: agentName }];
  }
  return state;
}

function epicReceipt(): Record<string, unknown> {
  return {
    ...resolveCodexDeployment(
      "orchestrator",
      "C3",
      "epic_execution_child",
      "C3",
    ),
    phase: "wave_0",
  };
}

describe("epic orchestrator Codex model routing", () => {
  it("accepts a matching generated child deployment receipt", () => {
    // Arrange
    const state = buildEpicState();
    state["codex_model_routing_receipts"] = [epicReceipt()];

    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state), {
      requireCodexModelRouting: true,
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("rejects a missing child deployment receipt under the gate", () => {
    // Arrange / Act
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(buildEpicState()),
      { requireCodexModelRouting: true },
    );

    // Assert
    expect(errors.some((error) => error.includes("must be a list"))).toBe(true);
  });

  it("validates a present receipt without enabling the gate", () => {
    // Arrange
    const state = buildEpicState(null);
    const receipt = epicReceipt();
    receipt["model_reasoning_effort"] = "low";
    state["codex_model_routing_receipts"] = [receipt];

    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(
      errors.some((error) => error.includes("model_reasoning_effort")),
    ).toBe(true);
  });
});
