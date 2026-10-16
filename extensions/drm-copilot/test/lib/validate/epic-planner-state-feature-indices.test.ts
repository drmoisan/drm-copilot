import { describe, expect, it } from "@jest/globals";

import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

const REPOSITORY_CONTEXT_ERROR =
  "Execution-ready planner validation requires repository context.";
const NON_OBJECT_ERROR =
  "Epic planner checkpoint features[0] must be an object.";
const SHIFTED_PREPARATION_ERROR =
  "Epic planner checkpoint features[2].preparation_status must be 'prepared'.";
const UNSHIFTED_PREPARATION_ERROR =
  "Epic planner checkpoint features[1].preparation_status must be 'prepared'.";
const SHIFTED_MODEL_RECEIPT_ERROR =
  "Epic planner checkpoint features[2].model_routing_receipt must be an object.";
const SHIFTED_TOPOLOGY_RECEIPT_ERROR =
  "Epic planner checkpoint features[2].topology_receipt must be an object.";
const DUPLICATE_FOLDER_ERROR =
  "Epic planner checkpoint features[2].feature_folder must be unique: 'docs/features/active/feature-101'.";
const DUPLICATE_ISSUE_ERROR =
  "Epic planner checkpoint features[2].issue_num must be unique: 101.";
const UNRESOLVED_DEPENDENCY_ERROR =
  "Epic planner checkpoint features[3].depends_on contains unresolved reference: 999.";
const SHIFTED_WAVE_ERROR =
  "Epic planner checkpoint features[3].wave must be 0 from the dependency graph, found 1.";
const SHIFTED_LAUNCH_BINDING_ERROR =
  "Epic planner checkpoint features[2] launch binding.branch_name must be a non-empty unique string.";

const nonObjectCases: ReadonlyArray<{
  readonly label: string;
  readonly entry: unknown;
}> = [
  { label: "string", entry: "not-a-feature" },
  { label: "null", entry: null },
  { label: "number", entry: 7 },
  { label: "list", entry: ["not-a-feature"] },
];

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

/** Build a Claude-shaped ready checkpoint around the given feature entries. */
function claudeState(features: readonly unknown[]): Record<string, unknown> {
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

describe("validateEpicPlannerStateText original feature index", () => {
  it.each(nonObjectCases)(
    "uses the original feature index after a $label entry",
    ({ entry }) => {
      const state = claudeState([
        entry,
        claudeFeature(101),
        claudeFeature(102, {
          depends_on: [101],
          wave: 1,
          preparation_status: "pending",
        }),
      ]);

      const errors = validateEpicPlannerStateText(JSON.stringify(state), {
        requireReadyForExecution: true,
      });

      expect(errors).toEqual([
        NON_OBJECT_ERROR,
        SHIFTED_PREPARATION_ERROR,
        REPOSITORY_CONTEXT_ERROR,
      ]);
    },
  );

  it("uses the original feature index for receipt prefixes under a Codex flag", () => {
    const state = claudeState([
      "not-a-feature",
      claudeFeature(101),
      claudeFeature(102, { depends_on: [101], wave: 1 }),
    ]);

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
      requireCodexModelRouting: true,
    });

    expect(errors).toContain(SHIFTED_MODEL_RECEIPT_ERROR);
    expect(errors).toContain(SHIFTED_TOPOLOGY_RECEIPT_ERROR);
  });

  it("uses the original feature index for dependency-wave prefixes", () => {
    const state = claudeState([
      "not-a-feature",
      claudeFeature(101),
      claudeFeature(101),
      claudeFeature(102, { depends_on: [999], wave: 1 }),
    ]);

    const errors = validateEpicPlannerStateText(JSON.stringify(state));

    expect(errors).toEqual([
      NON_OBJECT_ERROR,
      DUPLICATE_FOLDER_ERROR,
      DUPLICATE_ISSUE_ERROR,
      UNRESOLVED_DEPENDENCY_ERROR,
      SHIFTED_WAVE_ERROR,
    ]);
  });

  it("uses the original feature index for launch-binding prefixes under a Codex flag", () => {
    const state = claudeState([
      "not-a-feature",
      claudeFeature(101),
      claudeFeature(102, { depends_on: [101], wave: 1 }),
    ]);

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
      requireCodexModelRouting: true,
    });

    expect(errors).toContain(SHIFTED_LAUNCH_BINDING_ERROR);
  });

  it("keeps the feature index unchanged without non-object entries", () => {
    const state = claudeState([
      claudeFeature(101),
      claudeFeature(102, {
        depends_on: [101],
        wave: 1,
        preparation_status: "pending",
      }),
    ]);

    const errors = validateEpicPlannerStateText(JSON.stringify(state), {
      requireReadyForExecution: true,
    });

    expect(errors).toEqual([
      UNSHIFTED_PREPARATION_ERROR,
      REPOSITORY_CONTEXT_ERROR,
    ]);
  });
});
