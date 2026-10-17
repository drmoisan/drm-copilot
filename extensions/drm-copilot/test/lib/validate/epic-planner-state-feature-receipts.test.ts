import { describe, expect, it } from "@jest/globals";

import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";
import type { ValidateEpicPlannerStateOptions } from "../../../src/lib/validate/epic-planner-state-core";

const REPOSITORY_CONTEXT_ERROR =
  "Execution-ready planner validation requires repository context.";
const MODEL_RECEIPT_OBJECT_ERROR =
  "Epic planner checkpoint features[0].model_routing_receipt must be an object.";
const TOPOLOGY_RECEIPT_OBJECT_ERROR =
  "Epic planner checkpoint features[0].topology_receipt must be an object.";
const LOGICAL_AGENT_ERROR =
  "Epic planner checkpoint features[0].model_routing_receipt.logical_agent must be 'orchestrator'.";
const SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR =
  "Epic planner checkpoint features[1].topology_receipt must be an object.";
const FEATURE0_TOPOLOGY_TOKEN = "features[0].topology_receipt";
const FEATURE0_MODEL_TOKEN = "features[0].model_routing_receipt";

type CodexFlags = Pick<
  ValidateEpicPlannerStateOptions,
  "requireCodexModelRouting" | "requireCodexTopology"
>;

const codexFlagCases: readonly CodexFlags[] = [
  { requireCodexModelRouting: true },
  { requireCodexTopology: true },
];

const presentNullCases: ReadonlyArray<readonly [string, string]> = [
  ["model_routing_receipt", MODEL_RECEIPT_OBJECT_ERROR],
  ["topology_receipt", TOPOLOGY_RECEIPT_OBJECT_ERROR],
];

/** Build a resolved orchestrator model routing receipt. */
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
    model: "gpt-6-astra",
    model_reasoning_effort: "high",
    ...overrides,
  };
}

/** Build a resolved epic-preparation child topology receipt. */
function topologyReceipt(): Record<string, unknown> {
  return {
    ...resolveCodexTopology(["python"], 1, 1, "epic_preparation_child"),
    phase: "preparation",
  };
}

/** Attach both per-feature receipts to one feature. */
function withReceipts(item: Record<string, unknown>): Record<string, unknown> {
  return {
    ...item,
    model_routing_receipt: modelReceipt(),
    topology_receipt: topologyReceipt(),
  };
}

/** Build one prepared feature carrying only the required feature keys. */
function claudeFeature(
  issueNum: number,
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
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
    ...overrides,
  };
}

/** Build a Claude-shaped ready checkpoint with no Codex-only evidence. */
function claudeState(
  features: ReadonlyArray<Record<string, unknown>>,
): Record<string, unknown> {
  return {
    objective: "prepare two related features",
    epic_feature_folder: "sample-epic",
    epic_manifest_path: "docs/features/epics/sample-epic/epic.md",
    integration_branch: "epic/sample-epic-integration",
    max_parallel_features: 4,
    epic_worthiness: { verdict: "epic", rationale: "two features" },
    features: [...features],
    kickoff_prompt_path: "artifacts/orchestration/epic-kickoff-sample-epic.md",
    completed_steps: ["decomposition", "preparation", "fan-in"],
    next_step: "EPIC_EXECUTION_READY",
    last_updated: "2026-07-10T10:00:00Z",
  };
}

describe("validateEpicPlannerStateText per-feature receipt key gate", () => {
  it("skips the per-feature receipts when the keys are absent without a Codex flag", () => {
    const state = claudeState([
      claudeFeature(101),
      claudeFeature(102, { depends_on: [101], wave: 1 }),
    ]);

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toEqual([REPOSITORY_CONTEXT_ERROR]);
  });

  it.each(codexFlagCases)(
    "keeps the per-feature receipts unconditional under %p",
    (flags) => {
      const first = claudeFeature(101);
      const second = withReceipts(
        claudeFeature(102, { depends_on: [101], wave: 1 }),
      );

      const errors = validateEpicPlannerStateText(
        JSON.stringify(claudeState([first, second])),
        { requireReadyForExecution: true, ...flags },
      );

      expect(errors).toContain(MODEL_RECEIPT_OBJECT_ERROR);
      expect(errors).toContain(TOPOLOGY_RECEIPT_OBJECT_ERROR);
    },
  );

  it.each(presentNullCases)(
    "validates a present null %s without a Codex flag",
    (key, expected) => {
      const first = withReceipts(claudeFeature(101));
      first[key] = null;
      const second = withReceipts(
        claudeFeature(102, { depends_on: [101], wave: 1 }),
      );

      const errors = validateEpicPlannerStateText(
        JSON.stringify(claudeState([first, second])),
        { requireReadyForExecution: true },
      );

      expect(errors).toContain(expected);
    },
  );

  it("gates each per-feature receipt independently", () => {
    const first = withReceipts(claudeFeature(101));
    delete first["topology_receipt"];
    first["model_routing_receipt"] = modelReceipt({ logical_agent: "planner" });
    const second = withReceipts(
      claudeFeature(102, { depends_on: [101], wave: 1 }),
    );

    const errors = validateEpicPlannerStateText(
      JSON.stringify(claudeState([first, second])),
      { requireReadyForExecution: true },
    );

    expect(errors).toContain(LOGICAL_AGENT_ERROR);
    expect(
      errors.filter((error) => error.includes(FEATURE0_TOPOLOGY_TOKEN)),
    ).toEqual([]);
  });

  it("preserves the feature index when receipts are skipped", () => {
    const first = claudeFeature(101);
    const second = withReceipts(
      claudeFeature(102, { depends_on: [101], wave: 1 }),
    );
    second["topology_receipt"] = null;

    const errors = validateEpicPlannerStateText(
      JSON.stringify(claudeState([first, second])),
      { requireReadyForExecution: true },
    );

    expect(errors).toContain(SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR);
    expect(
      errors.filter(
        (error) =>
          error.includes(FEATURE0_TOPOLOGY_TOKEN) ||
          error.includes(FEATURE0_MODEL_TOKEN),
      ),
    ).toEqual([]);
  });
});
