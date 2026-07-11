import { describe, expect, it } from "@jest/globals";

import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

function topologyReceipt(
  rootPersona?: "epic-planner",
): Record<string, unknown> {
  const resolved =
    rootPersona === undefined
      ? resolveCodexTopology(["python"], 1, 1, "epic_preparation_child")
      : resolveCodexTopology([], 0, 0, "standalone", { rootPersona });
  return { ...resolved, phase: "preparation" };
}

function modelReceipt(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    logical_agent: "orchestrator",
    deployment_agent: "orchestrator-c3-elevated",
    phase: "preparation",
    complexity_band: "C3",
    execution_context: "epic_preparation_child",
    orchestration_complexity_ceiling: "C3",
    c3_overlay_applied: true,
    c3_overlay_reason: "epic_context",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "high",
    ...overrides,
  };
}

function feature(
  issueNum: number,
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  const delegationId = `prepare-feature-${issueNum}`;
  const deploymentAgent = "orchestrator-c3-elevated";
  return {
    issue_num: issueNum,
    feature_folder: `docs/features/active/feature-${issueNum}`,
    depends_on: [],
    wave: 0,
    complexity_band: "C3",
    preparation_status: "prepared",
    research_path: `artifacts/research/feature-${issueNum}.md`,
    plan_path: `docs/features/active/feature-${issueNum}/plan.md`,
    preflight_status: "PREFLIGHT: ALL CLEAR",
    branch_name: `feature/feature-${issueNum}`,
    worktree_path: `/repo/worktrees/feature-${issueNum}`,
    delegation_receipt: {
      delegation_id: delegationId,
      feature_folder: `docs/features/active/feature-${issueNum}`,
      issue_num: issueNum,
      agent_name: deploymentAgent,
    },
    model_routing_receipt: modelReceipt({ delegation_id: delegationId }),
    launch_receipt_path: `artifacts/orchestration/epic-child-launches/preparation/feature-${issueNum}.receipt.json`,
    launch_status_path:
      "artifacts/orchestration/epic-child-launches/preparation/wave.status.json",
    topology_receipt: topologyReceipt(),
    ...overrides,
  };
}

function readyState(): Record<string, unknown> {
  return {
    objective: "prepare two related features",
    epic_feature_folder: "sample-epic",
    epic_manifest_path: "docs/features/epics/sample-epic/epic.md",
    integration_branch: "epic/sample-epic-integration",
    max_parallel_features: 4,
    epic_worthiness: { verdict: "epic", rationale: "two features" },
    features: [feature(101), feature(102, { depends_on: [101], wave: 1 })],
    kickoff_prompt_path: "artifacts/orchestration/epic-kickoff-sample-epic.md",
    completed_steps: ["decomposition", "preparation", "fan-in"],
    next_step: "EPIC_EXECUTION_READY",
    last_updated: "2026-07-10T10:00:00Z",
    topology_receipt: topologyReceipt("epic-planner"),
  };
}

describe("validateEpicPlannerStateText", () => {
  it("accepts a fully prepared multi-feature epic", () => {
    expect(
      validateEpicPlannerStateText(JSON.stringify(readyState()), {
        requireReadyForExecution: true,
      }),
    ).toEqual([
      "Execution-ready planner validation requires repository context.",
    ]);
  });

  it.each([0, 9, true, 1.5, "4"])(
    "rejects invalid max_parallel_features value %p",
    (value) => {
      const state = readyState();
      state["max_parallel_features"] = value;

      expect(validateEpicPlannerStateText(JSON.stringify(state))).toContain(
        "Epic planner checkpoint max_parallel_features must be an integer " +
          "from 1 through 8.",
      );
    },
  );

  it("accepts a non-epic recommendation under structural validation", () => {
    const state = readyState();
    state["epic_worthiness"] = {
      verdict: "non_epic",
      rationale: "one independently mergeable feature",
    };
    state["features"] = [feature(101)];
    state["next_step"] = "NON_EPIC_RECOMMENDED";

    expect(validateEpicPlannerStateText(JSON.stringify(state))).toEqual([]);
  });

  it("reports invalid JSON and a non-object root", () => {
    expect(validateEpicPlannerStateText("{")[0]).toContain(
      "Epic planner checkpoint is not valid JSON:",
    );
    expect(validateEpicPlannerStateText("[]")).toEqual([
      "Epic planner checkpoint root must be a JSON object.",
    ]);
  });

  it("reports required keys and invalid worthiness fields", () => {
    const errors = validateEpicPlannerStateText(
      JSON.stringify({
        epic_worthiness: { verdict: "maybe", rationale: "" },
        features: [],
      }),
    );

    expect(errors).toContain(
      "Epic planner checkpoint missing required key: objective",
    );
    expect(errors).toContain(
      "Epic planner checkpoint epic_worthiness.verdict must be 'epic' or 'non_epic'.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint epic_worthiness.rationale must be non-empty.",
    );
  });

  it("requires worthiness and features to use their object and list shapes", () => {
    const state = readyState();
    state["epic_worthiness"] = null;
    state["features"] = "not-a-list";

    const errors = validateEpicPlannerStateText(JSON.stringify(state));

    expect(errors).toContain(
      "Epic planner checkpoint epic_worthiness must be an object.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features must be a list.",
    );
  });

  it("reports non-object, incomplete, and malformed feature entries", () => {
    const state = readyState();
    state["features"] = [
      null,
      { issue_num: 101 },
      feature(102, {
        depends_on: "none",
        wave: -1,
        complexity_band: "C5",
      }),
    ];

    const errors = validateEpicPlannerStateText(JSON.stringify(state));

    expect(errors).toContain(
      "Epic planner checkpoint features[0] must be an object.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[1] missing required keys: feature_folder, depends_on, wave, complexity_band, preparation_status, research_path, plan_path, preflight_status.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[2].depends_on must be a list.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[2].wave must be a non-negative integer.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[2].complexity_band must be one of ('C1', 'C2', 'C3', 'C4').",
    );
  });

  it("rejects cyclic feature dependencies", () => {
    const state = readyState();
    state["features"] = [
      feature(101, { depends_on: [102] }),
      feature(102, { depends_on: [101] }),
    ];

    expect(
      validateEpicPlannerStateText(JSON.stringify(state)).some((error) =>
        error.toLowerCase().includes("cycle"),
      ),
    ).toBe(true);
  });

  it("requires the canonical non-epic next step", () => {
    const state = readyState();
    state["epic_worthiness"] = {
      verdict: "non_epic",
      rationale: "single feature",
    };

    expect(validateEpicPlannerStateText(JSON.stringify(state))).toContain(
      "Non-epic planner checkpoint next_step must be 'NON_EPIC_RECOMMENDED'.",
    );
  });

  it("rejects a non-epic or undersized checkpoint as execution-ready", () => {
    const state = readyState();
    state["epic_worthiness"] = {
      verdict: "non_epic",
      rationale: "single feature",
    };
    state["features"] = [feature(101)];
    state["next_step"] = "NON_EPIC_RECOMMENDED";

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Execution readiness requires epic_worthiness.verdict 'epic'.",
    );
    expect(errors).toContain(
      "Execution-ready planner checkpoint next_step must be 'EPIC_EXECUTION_READY'.",
    );
    expect(errors).toContain(
      "Execution-ready epic planning requires at least two features.",
    );
  });

  it("reports every unresolved or incomplete ready-feature field", () => {
    const state = readyState();
    state["features"] = [
      feature(101, {
        issue_num: 0,
        feature_folder: " ",
        plan_path: null,
        preparation_status: "pending",
        preflight_status: "PREFLIGHT: REVISIONS REQUIRED",
        model_routing_receipt: null,
      }),
      feature(102),
    ];

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Epic planner checkpoint features[0].issue_num must be a positive integer.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[0].feature_folder must be a non-empty string.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[0].plan_path must be a non-empty string.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[0].preparation_status must be 'prepared'.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[0].preflight_status must be 'PREFLIGHT: ALL CLEAR'.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[0].model_routing_receipt must be an object.",
    );
  });

  it("requires canonical orchestrator routing receipts", () => {
    const state = readyState();
    state["features"] = [
      feature(101, {
        model_routing_receipt: modelReceipt({ model: "gpt-5.6-terra" }),
      }),
      feature(102, {
        model_routing_receipt: modelReceipt({
          logical_agent: "atomic-planner",
          deployment_agent: "atomic-planner-c3-elevated",
        }),
      }),
    ];

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Epic planner checkpoint features[0].model_routing_receipt.model must be 'gpt-5.6-sol', found 'gpt-5.6-terra'.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[1].model_routing_receipt.logical_agent must be 'orchestrator'.",
    );
  });

  it("cross-binds feature complexity and epic preparation model context", () => {
    const state = readyState();
    const features = state["features"] as Record<string, unknown>[];
    features[0]!["complexity_band"] = "C4";
    features[1]!["model_routing_receipt"] = modelReceipt({
      execution_context: "standalone",
    });

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Epic planner checkpoint features[0].model_routing_receipt.complexity_band " +
        "must match feature complexity_band 'C4'.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[1].model_routing_receipt.execution_context " +
        "must be 'epic_preparation_child'.",
    );
  });

  it("requires the forced epic-planner topology receipt", () => {
    const state = readyState();
    const receipt = topologyReceipt("epic-planner");
    receipt["logical_agent"] = "orchestrator";
    state["topology_receipt"] = receipt;

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Epic planner topology_receipt.logical_agent must be 'epic-planner', found 'orchestrator'.",
    );
    expect(errors).toContain(
      "Epic planner topology_receipt.logical_agent must be 'epic-planner'.",
    );
  });

  it("requires each prepared child to route through an orchestrator", () => {
    const state = readyState();
    const features = state["features"] as Record<string, unknown>[];
    features[0]!["topology_receipt"] = {
      ...resolveCodexTopology(["python"], 1, 1, "standalone"),
      phase: "preparation",
    };

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Epic planner checkpoint features[0].topology_receipt.execution_context must be 'epic_preparation_child'.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[0].topology_receipt.logical_agent must be 'orchestrator'.",
    );
  });

  it("rejects unresolved dependencies and recomputes longest-path waves", () => {
    const state = readyState();
    const features = state["features"] as Record<string, unknown>[];
    features[0]!["depends_on"] = [999];
    features[1]!["wave"] = 0;

    const errors = validateEpicPlannerStateText(JSON.stringify(state));

    expect(errors).toContain(
      "Epic planner checkpoint features[0].depends_on contains unresolved reference: 999.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[1].wave must be 1 from the dependency graph, found 0.",
    );
  });

  it("rejects duplicate issue and folder identifiers", () => {
    const state = readyState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]!["issue_num"] = 101;
    features[1]!["feature_folder"] = "docs/features/active/feature-101";

    const errors = validateEpicPlannerStateText(JSON.stringify(state));

    expect(errors).toContain(
      "Epic planner checkpoint features[1].issue_num must be unique: 101.",
    );
    expect(errors).toContain(
      "Epic planner checkpoint features[1].feature_folder must be unique: " +
        "'docs/features/active/feature-101'.",
    );
  });

  it("requires the canonical ignored kickoff path", () => {
    const state = readyState();
    state["kickoff_prompt_path"] = "artifacts/orchestration/other.md";

    expect(
      validateEpicPlannerStateText(JSON.stringify(state), {
        requireReadyForExecution: true,
      }),
    ).toContain(
      "Execution-ready planner checkpoint kickoff_prompt_path must be 'artifacts/orchestration/epic-kickoff-sample-epic.md'.",
    );
  });
});
