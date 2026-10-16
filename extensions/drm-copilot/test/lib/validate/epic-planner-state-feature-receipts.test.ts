import { describe, expect, it } from "@jest/globals";

import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

const REPOSITORY_CONTEXT_ERROR =
  "Execution-ready planner validation requires repository context.";

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
});
