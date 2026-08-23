import { describe, expect, it } from "@jest/globals";

import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

function state(agentName: string | null = "orchestrator-c3-elevated") {
  const value: Record<string, unknown> = {
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
    value["delegation_receipts"] = [{ agent_name: agentName }];
  }
  return value;
}

function topologyReceipt(
  rootPersona?: "epic-orchestrator",
): Record<string, unknown> {
  const receipt =
    rootPersona === undefined
      ? resolveCodexTopology(["python"], 1, 1, "epic_execution_child")
      : resolveCodexTopology([], 0, 0, "standalone", { rootPersona });
  return {
    ...receipt,
    phase: rootPersona === undefined ? "wave_0" : "epic_start",
  };
}

function validState(): Record<string, unknown> {
  const model = {
    ...resolveCodexDeployment(
      "orchestrator",
      "C3",
      "epic_execution_child",
      "C3",
    ),
    phase: "wave_0",
  };
  const value = state(model.deployment_agent);
  value["codex_model_routing_receipts"] = [model];
  value["codex_topology_receipts"] = [
    topologyReceipt("epic-orchestrator"),
    topologyReceipt(),
  ];
  return value;
}

describe("epic Codex topology gate", () => {
  it("accepts forced root and exact generated child evidence", () => {
    expect(
      validateEpicOrchestratorStateText(JSON.stringify(validState()), {
        requireCodexTopology: true,
      }),
    ).toEqual([]);
  });

  it("requires the forced epic-orchestrator receipt", () => {
    const value = validState();
    value["codex_topology_receipts"] = [topologyReceipt()];

    expect(
      validateEpicOrchestratorStateText(JSON.stringify(value), {
        requireCodexTopology: true,
      }),
    ).toContain(
      "ORCH_ROUTING_GATE_CODEX_TOPOLOGY: Checkpoint codex_topology_receipts is missing the forced root persona receipt for epic-orchestrator.",
    );
  });

  it("requires child evidence after delegation", () => {
    const value = validState();
    value["codex_topology_receipts"] = [topologyReceipt("epic-orchestrator")];

    expect(
      validateEpicOrchestratorStateText(JSON.stringify(value), {
        requireCodexTopology: true,
      }),
    ).toContain(
      "ORCH_ROUTING_GATE_CODEX_TOPOLOGY: Checkpoint codex_topology_receipts is missing a child topology receipt for recorded delegations.",
    );
  });

  it("rejects a tampered epic child receipt", () => {
    const value = validState();
    const child = topologyReceipt();
    child["logical_agent"] = "python-typed-engineer";
    value["codex_topology_receipts"] = [
      topologyReceipt("epic-orchestrator"),
      child,
    ];

    expect(validateEpicOrchestratorStateText(JSON.stringify(value))).toContain(
      "Checkpoint codex_topology_receipts[1].logical_agent must be 'orchestrator', found 'python-typed-engineer'.",
    );
  });

  it("validates present root receipts without the enforcement flag", () => {
    const value = state(null);
    const root = topologyReceipt("epic-orchestrator");
    root["route"] = "small";
    value["codex_topology_receipts"] = [root];

    expect(validateEpicOrchestratorStateText(JSON.stringify(value))).toContain(
      "Checkpoint codex_topology_receipts[0].route must be 'epic', found 'small'.",
    );
  });
});
