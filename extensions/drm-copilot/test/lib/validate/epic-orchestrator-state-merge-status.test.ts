import { describe, expect, it } from "@jest/globals";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";

/**
 * Return the two-feature epic checkpoint payload with the second feature's
 * `merge_status` replaced by `childBMergeStatus`.
 *
 * Mirrors the Python regression fixture in
 * `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py`
 * (issue #793): the TypeScript port already reports a non-string `merge_status`
 * as a validation error, and these cases pin that parity.
 */
function buildEpicState(childBMergeStatus: unknown): Record<string, unknown> {
  return {
    objective: "deliver epic-orchestrate-275",
    route_id: "epic",
    epic_feature_folder: "epic-orchestrate-275",
    epic_manifest_path: "docs/features/epics/epic-orchestrate-275/epic-plan.md",
    integration_branch: "epic/epic-orchestrate-275-integration",
    max_parallel_features: 4,
    completed_steps: ["epic_manifest_parsed"],
    next_step: "wave_1_launch",
    last_updated: "2026-07-02T20-00",
    current_wave: 1,
    waves: [
      { wave_number: 0, feature_folders: ["2026-07-02-child-a-300"] },
      { wave_number: 1, feature_folders: ["2026-07-02-child-b-301"] },
    ],
    features: [
      {
        feature_folder: "2026-07-02-child-a-300",
        issue_num: 300,
        depends_on: [],
        wave_number: 0,
        worktree_path: "/repo/worktrees/child-a",
        merge_status: "merged",
        merge_confirmed_at: "2026-07-02T18-00",
        worktree_created_at: "2026-07-02T17-00",
      },
      {
        feature_folder: "2026-07-02-child-b-301",
        issue_num: 301,
        depends_on: ["2026-07-02-child-a-300"],
        wave_number: 1,
        worktree_path: "/repo/worktrees/child-b",
        merge_status: childBMergeStatus,
        worktree_created_at: "2026-07-02T19-00",
      },
    ],
  };
}

const NON_STRING_ROWS: readonly (readonly [string, unknown])[] = [
  ["list", ["x"]],
  ["dict", { x: 1 }],
  ["number", 5],
  ["boolean", true],
];

const COMPLETION_ERROR =
  "Epic checkpoint completion validation failed: feature '2026-07-02-child-b-301' merge_status is not merged/worktree_removed.";

describe("validateEpicOrchestratorStateText non-string merge_status", () => {
  it.each(NON_STRING_ROWS)(
    "reports a %s merge_status at the enum site without throwing",
    (_label, value) => {
      // Arrange
      const text = JSON.stringify(buildEpicState(value));
      let errors: string[] = [];

      // Act
      const act = (): void => {
        errors = validateEpicOrchestratorStateText(text);
      };

      // Assert
      expect(act).not.toThrow();
      expect(errors.some((e) => e.includes("invalid merge_status"))).toBe(true);
    },
  );

  it.each(NON_STRING_ROWS)(
    "reports a %s merge_status at the completion site without throwing",
    (_label, value) => {
      // Arrange
      const text = JSON.stringify(buildEpicState(value));
      let errors: string[] = [];

      // Act
      const act = (): void => {
        errors = validateEpicOrchestratorStateText(text, {
          requireComplete: true,
        });
      };

      // Assert
      expect(act).not.toThrow();
      expect(errors).toContain(COMPLETION_ERROR);
    },
  );
});
