import { describe, expect, it } from "@jest/globals";

import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";
import {
  validateCodexTopologyGate,
  validateCodexTopologyReceipt,
  validateCodexTopologyReceipts,
} from "../../../src/lib/validate/orchestrator-state-codex-topology";
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

function baseState(
  agentName: string | null = "python-typed-engineer",
): Record<string, unknown> {
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

function topologyReceipt(
  options: {
    readonly language?: string;
    readonly productionFiles?: number;
    readonly testFiles?: number;
    readonly context?:
      "standalone" | "epic_preparation_child" | "epic_execution_child";
    readonly rootPersona?: "epic-planner" | "epic-orchestrator";
  } = {},
): Record<string, unknown> {
  const receipt = resolveCodexTopology(
    options.rootPersona === undefined ? [options.language ?? "python"] : [],
    options.productionFiles ?? (options.rootPersona === undefined ? 2 : 0),
    options.testFiles ?? (options.rootPersona === undefined ? 2 : 0),
    options.context ?? "standalone",
    { rootPersona: options.rootPersona },
  );
  return { ...receipt, phase: "S5_atomic_execution" };
}

function modelReceipt(): Record<string, unknown> {
  return {
    ...resolveCodexDeployment(
      "python-typed-engineer",
      "C3",
      "standalone",
      "C3",
    ),
    phase: "S5_atomic_execution",
  };
}

function validate(state: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(state), {
    requireCodexTopology: true,
  });
}

describe("Codex topology checkpoint receipts", () => {
  it("accepts an exact typed engineer for a small standalone scope", () => {
    const state = baseState();
    state["codex_topology_receipts"] = [topologyReceipt()];

    expect(validate(state)).toEqual([]);
  });

  it("accepts a generated deployment backed by exact model evidence", () => {
    const model = modelReceipt();
    const state = baseState(String(model["deployment_agent"]));
    state["codex_model_routing_receipts"] = [model];
    state["codex_topology_receipts"] = [topologyReceipt()];

    expect(validate(state)).toEqual([]);
  });

  it("does not trust an invalid model receipt as deployment evidence", () => {
    const model = modelReceipt();
    const state = baseState(String(model["deployment_agent"]));
    model["model"] = "gpt-5.6-sol";
    state["codex_model_routing_receipts"] = [model];
    state["codex_topology_receipts"] = [topologyReceipt()];

    const errors = validate(state);

    expect(errors.some((error) => error.includes(".model must be"))).toBe(true);
    expect(
      errors.some((error) =>
        error.includes("missing the exact resolved topology agent"),
      ),
    ).toBe(true);
  });

  it("requires a receipt once a delegation is recorded", () => {
    expect(validate(baseState())).toContain(
      "Checkpoint codex_topology_receipts must be a list when present.",
    );
  });

  it("rejects an orchestrator delegation for a small receipt", () => {
    const state = baseState("orchestrator");
    state["codex_topology_receipts"] = [topologyReceipt()];

    expect(validate(state)).toContain(
      "Checkpoint delegation_receipts is missing the exact resolved topology " +
        "agent for python-typed-engineer: python-typed-engineer.",
    );
  });

  it("requires the standalone topology route to match path_selected", () => {
    const state = baseState("orchestrator");
    state["codex_topology_receipts"] = [
      topologyReceipt({ productionFiles: 4 }),
    ];

    expect(validate(state)).toContain(
      "Checkpoint path_selected 'small' does not match the resolved Codex topology route 'large'.",
    );
  });

  it("validates present receipts when the gate flag is absent", () => {
    const state = baseState(null);
    const receipt = topologyReceipt();
    receipt["logical_agent"] = "orchestrator";
    state["codex_topology_receipts"] = [receipt];

    expect(validateOrchestratorStateText(JSON.stringify(state))).toContain(
      "Checkpoint codex_topology_receipts[0].logical_agent must be " +
        "'python-typed-engineer', found 'orchestrator'.",
    );
  });

  it("does not require a receipt before delegation", () => {
    expect(validate(baseState(null))).toEqual([]);
  });

  it("reports non-list, non-object, missing-key, and blank-phase data", () => {
    expect(validateCodexTopologyReceipts("invalid")).toEqual([
      "Checkpoint codex_topology_receipts must be a list when present.",
    ]);
    expect(validateCodexTopologyReceipts([null])).toEqual([
      "Checkpoint codex_topology_receipts[0] must be an object.",
    ]);
    expect(validateCodexTopologyReceipts([{}])).toEqual([
      "Checkpoint codex_topology_receipts[0] missing required keys: " +
        "phase, execution_context, languages, production_file_count, " +
        "test_file_count, cross_cutting, root_persona, route, topology, " +
        "logical_agent, routing_reason, max_production_files, max_test_files.",
    ]);
    const receipt = topologyReceipt();
    receipt["phase"] = " ";
    expect(validateCodexTopologyReceipts([receipt])).toContain(
      "Checkpoint codex_topology_receipts[0].phase must be a non-empty string.",
    );
  });

  it("reports all malformed resolver input fields before resolution", () => {
    const receipt = topologyReceipt();
    receipt["languages"] = [1];
    receipt["production_file_count"] = "2";
    receipt["test_file_count"] = true;
    receipt["cross_cutting"] = "false";
    receipt["execution_context"] = 1;
    receipt["root_persona"] = "unknown";

    expect(validateCodexTopologyReceipts([receipt])).toEqual([
      "Checkpoint codex_topology_receipts[0].languages must be a list of non-empty strings.",
      "Checkpoint codex_topology_receipts[0].production_file_count must be an integer.",
      "Checkpoint codex_topology_receipts[0].test_file_count must be an integer.",
      "Checkpoint codex_topology_receipts[0].cross_cutting must be a boolean.",
      "Checkpoint codex_topology_receipts[0].execution_context must be a string.",
      "Checkpoint codex_topology_receipts[0].root_persona must be null or one of ('epic-orchestrator', 'epic-planner').",
    ]);
  });

  it("surfaces semantic context errors from the resolver", () => {
    const receipt = topologyReceipt();
    receipt["execution_context"] = "unknown";

    expect(validateCodexTopologyReceipts([receipt])).toContain(
      "Checkpoint codex_topology_receipts[0] has invalid routing inputs: " +
        "execution_context must be one of ('epic_execution_child', " +
        "'epic_preparation_child', 'standalone'), found 'unknown'.",
    );
  });

  it("exports single-receipt validation with a custom prefix", () => {
    const receipt = topologyReceipt();
    receipt["languages"] = ["PYTHON"];

    expect(
      validateCodexTopologyReceipt(receipt, "Feature topology_receipt"),
    ).toContain(
      "Feature topology_receipt.languages must be ['python'], found ['PYTHON'].",
    );
  });

  it("ignores malformed gate entries while retaining valid evidence", () => {
    const model = modelReceipt();
    const state = baseState(String(model["deployment_agent"]));
    state["delegation_receipts"] = [
      null,
      { agent_name: " " },
      delegationReceipt(String(model["deployment_agent"])),
    ];
    state["codex_model_routing_receipts"] = [null, model];
    state["codex_topology_receipts"] = [null, {}, topologyReceipt()];

    const errors = validateCodexTopologyGate(state);

    expect(errors).toContain(
      "Checkpoint codex_topology_receipts[0] must be an object.",
    );
    expect(
      errors.some((error) =>
        error.includes("missing the exact resolved topology agent"),
      ),
    ).toBe(false);
  });

  it("treats namespaced delegation receipts as delegation-free", () => {
    expect(
      validateCodexTopologyGate({ delegation_receipts: { promotion: {} } }),
    ).toEqual([]);
  });

  it("requires a child receipt after delegation even with root evidence", () => {
    const state = baseState("orchestrator");
    state["codex_topology_receipts"] = [
      topologyReceipt({ rootPersona: "epic-orchestrator" }),
    ];

    expect(validateCodexTopologyGate(state)).toContain(
      "Checkpoint codex_topology_receipts is missing a child topology receipt for recorded delegations.",
    );
  });

  it("requires configured forced root evidence without delegations", () => {
    expect(
      validateCodexTopologyGate(
        { delegation_receipts: [], codex_topology_receipts: [] },
        { requiredRootPersona: "epic-orchestrator" },
      ),
    ).toContain(
      "Checkpoint codex_topology_receipts is missing the forced root persona receipt for epic-orchestrator.",
    );
  });
});
