import { describe, expect, it } from "@jest/globals";

import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

const VERDICT_ERROR =
  "Epic planner checkpoint epic_worthiness.verdict must be 'epic' or 'non_epic'.";
const RATIONALE_ERROR =
  "Epic planner checkpoint epic_worthiness.rationale must be non-empty.";
const MISSING_KEYS_ERROR =
  "Epic planner checkpoint features[0] missing required keys: preflight_status.";
const DEPENDS_ON_ERROR =
  "Epic planner checkpoint features[0].depends_on must be a list.";
const WAVE_SHAPE_ERROR =
  "Epic planner checkpoint features[0].wave must be a non-negative integer.";
const BAND_ERROR =
  "Epic planner checkpoint features[0].complexity_band must be one of ('C1', 'C2', 'C3', 'C4').";
const TWO_FEATURES_ERROR =
  "Execution-ready epic planning requires at least two features.";
const RESEARCH_PATH_ERROR =
  "Epic planner checkpoint features[0].research_path must be a non-empty string.";
const NON_EPIC_NEXT_STEP_ERROR =
  "Non-epic planner checkpoint next_step must be 'NON_EPIC_RECOMMENDED'.";
const NONE_WAVE_ERROR =
  "Epic planner checkpoint features[0].wave must be 0 from the dependency graph, found None.";
const LIST_WAVE_ERROR =
  "Epic planner checkpoint features[0].wave must be 0 from the dependency graph, found [0].";
const BOOL_ISSUE_ERROR =
  "Epic planner checkpoint features[1].issue_num must be unique: True.";

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
function claudeState(
  features: readonly unknown[],
  overrides: Readonly<Record<string, unknown>> = {},
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
    ...overrides,
  };
}

/** Validate the serialized checkpoint, optionally under the ready gate. */
function errorsFor(
  state: Readonly<Record<string, unknown>>,
  ready = false,
): string[] {
  return validateEpicPlannerStateText(JSON.stringify(state), {
    requireReadyForExecution: ready,
  });
}

const reprCases: ReadonlyArray<{
  readonly label: string;
  readonly first: Readonly<Record<string, unknown>>;
  readonly second: Readonly<Record<string, unknown>>;
  readonly expected: string;
}> = [
  {
    label: "none",
    first: { wave: null },
    second: {},
    expected: NONE_WAVE_ERROR,
  },
  {
    label: "list",
    first: { wave: [0] },
    second: {},
    expected: LIST_WAVE_ERROR,
  },
  {
    label: "bool",
    first: { issue_num: true },
    second: { issue_num: true },
    expected: BOOL_ISSUE_ERROR,
  },
];

describe("validateEpicPlannerStateText shape errors", () => {
  it("reports an invalid worthiness verdict and rationale", () => {
    const state = claudeState([claudeFeature(101), claudeFeature(102)], {
      epic_worthiness: { verdict: "maybe", rationale: " " },
    });

    const errors = errorsFor(state);

    expect(errors).toContain(VERDICT_ERROR);
    expect(errors).toContain(RATIONALE_ERROR);
  });

  it("lists missing required feature keys", () => {
    const first = Object.fromEntries(
      Object.entries(claudeFeature(101)).filter(
        ([key]) => key !== "preflight_status",
      ),
    );
    const state = claudeState([first, claudeFeature(102)]);

    const errors = errorsFor(state);

    expect(errors).toContain(MISSING_KEYS_ERROR);
  });

  it("reports invalid depends_on, wave, and complexity_band values", () => {
    const state = claudeState([
      claudeFeature(101, {
        depends_on: "101",
        wave: -1,
        complexity_band: "C9",
      }),
      claudeFeature(102),
    ]);

    const errors = errorsFor(state);

    expect(errors).toContain(DEPENDS_ON_ERROR);
    expect(errors).toContain(WAVE_SHAPE_ERROR);
    expect(errors).toContain(BAND_ERROR);
  });

  it("requires at least two features under the ready gate", () => {
    const state = claudeState([claudeFeature(101)]);

    const errors = errorsFor(state, true);

    expect(errors).toContain(TWO_FEATURES_ERROR);
  });

  it("requires non-empty path fields under the ready gate", () => {
    const state = claudeState([
      claudeFeature(101, { research_path: "" }),
      claudeFeature(102),
    ]);

    const errors = errorsFor(state, true);

    expect(errors).toContain(RESEARCH_PATH_ERROR);
  });

  it("requires the non-epic next step for a non-epic verdict", () => {
    const state = claudeState([claudeFeature(101), claudeFeature(102)], {
      epic_worthiness: {
        verdict: "non_epic",
        rationale: "one feature suffices",
      },
    });

    const errors = errorsFor(state);

    expect(errors).toContain(NON_EPIC_NEXT_STEP_ERROR);
  });

  it.each(reprCases)(
    "renders a $label value with Python repr",
    ({ first, second, expected }) => {
      const state = claudeState([
        claudeFeature(101, first),
        claudeFeature(102, second),
      ]);

      const errors = errorsFor(state);

      expect(errors).toContain(expected);
    },
  );
});
