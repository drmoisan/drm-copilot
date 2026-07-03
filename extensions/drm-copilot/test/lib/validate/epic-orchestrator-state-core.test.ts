import { describe, expect, it } from "@jest/globals";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";

/**
 * Return a minimally valid, wave-barrier-clean epic checkpoint payload.
 *
 * Mirrors the Python test fixture `build_valid_epic_state()` in
 * `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`.
 */
function buildValidEpicState(): Record<string, unknown> {
  return {
    objective: "deliver epic-orchestrate-275",
    route_id: "epic",
    epic_feature_folder: "epic-orchestrate-275",
    epic_manifest_path: "docs/features/epics/epic-orchestrate-275/epic-plan.md",
    integration_branch: "epic/epic-orchestrate-275-integration",
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
        merge_status: "not_started",
        worktree_created_at: "2026-07-02T19-00",
      },
    ],
  };
}

describe("validateEpicOrchestratorStateText", () => {
  it("rejects a JSON root that is not an object", () => {
    // Arrange / Act
    const errors = validateEpicOrchestratorStateText("[]");
    // Assert
    expect(errors).toEqual(["Epic checkpoint root must be a JSON object."]);
  });

  it("rejects invalid JSON", () => {
    const errors = validateEpicOrchestratorStateText("{ broken");
    expect(errors.some((e) => e.includes("not valid JSON"))).toBe(true);
  });

  it("accepts a wave-barrier-clean valid checkpoint", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(buildValidEpicState()),
    );
    expect(errors).toEqual([]);
  });

  it("reports missing baseline fields", () => {
    const state = buildValidEpicState();
    delete state["objective"];
    delete state["completed_steps"];
    delete state["next_step"];
    delete state["last_updated"];

    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));

    expect(
      errors.some((e) => e.includes("missing required key: objective")),
    ).toBe(true);
    expect(
      errors.some((e) => e.includes("missing required key: completed_steps")),
    ).toBe(true);
    expect(
      errors.some((e) => e.includes("missing required key: next_step")),
    ).toBe(true);
    expect(
      errors.some((e) => e.includes("missing required key: last_updated")),
    ).toBe(true);
  });

  it("reports missing route_id / epic_feature_folder / integration_branch / waves / features", () => {
    for (const key of [
      "route_id",
      "epic_feature_folder",
      "integration_branch",
      "waves",
      "features",
    ]) {
      const state = buildValidEpicState();
      delete state[key];
      const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
      expect(
        errors.some((e) => e.includes(`missing required key: ${key}`)),
      ).toBe(true);
    }
  });

  it("rejects a wrong route_id", () => {
    const state = buildValidEpicState();
    state["route_id"] = "large";
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(errors.some((e) => e.includes("route_id must be 'epic'"))).toBe(
      true,
    );
  });

  it("rejects a duplicated feature_folder", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features.push({ ...features[0] });
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(
      errors.some((e) =>
        e.includes(
          "duplicate features[].feature_folder: 2026-07-02-child-a-300",
        ),
      ),
    ).toBe(true);
  });

  it("rejects an unresolved depends_on reference", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["depends_on"] = ["does-not-exist"];
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(errors.some((e) => e.includes("unresolved feature_folder"))).toBe(
      true,
    );
  });

  it("rejects a dependency cycle", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[0]["depends_on"] = ["2026-07-02-child-b-301"];
    features[1]["depends_on"] = ["2026-07-02-child-a-300"];
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(errors.some((e) => e.includes("cycle"))).toBe(true);
  });

  it("accepts every documented merge_status enum value", () => {
    const validStatuses = [
      "not_started",
      "worktree_created",
      "pr_open",
      "ci_green",
      "merge_conflict",
      "blocked_conflict_loop_limit",
      "merged",
      "worktree_removed",
    ];
    for (const status of validStatuses) {
      const state = buildValidEpicState();
      const features = state["features"] as Record<string, unknown>[];
      features[1]["merge_status"] = status;
      const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
      expect(errors.some((e) => e.includes("invalid merge_status"))).toBe(
        false,
      );
    }
  });

  it("rejects an invalid merge_status value", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["merge_status"] = "unknown_status";
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(errors.some((e) => e.includes("invalid merge_status"))).toBe(true);
  });

  it("passes wave-barrier ordering when the dependency merged first", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(buildValidEpicState()),
    );
    expect(errors.some((e) => e.includes("EPIC_WAVE_BARRIER_VIOLATION"))).toBe(
      false,
    );
  });

  it("rejects wave-barrier ordering when a dependency has not yet merged", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[0]["merge_status"] = "pr_open";
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(
      errors.some((e) =>
        e.includes(
          "EPIC_WAVE_BARRIER_VIOLATION: 2026-07-02-child-b-301 started before dependency 2026-07-02-child-a-300 merged",
        ),
      ),
    ).toBe(true);
  });

  it("rejects wave-barrier ordering on out-of-order timestamps", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[0]["merge_confirmed_at"] = "2026-07-02T20-00";
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(errors.some((e) => e.includes("EPIC_WAVE_BARRIER_VIOLATION"))).toBe(
      true,
    );
  });

  it("rejects a waves[]/wave_number inconsistency", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["wave_number"] = 2;
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    expect(
      errors.some((e) =>
        e.includes(
          "waves[] lists '2026-07-02-child-b-301' under wave 1 but its own wave_number is 2",
        ),
      ),
    ).toBe(true);
  });

  it("rejects requireComplete when a feature is not merged/worktree_removed", () => {
    const state = buildValidEpicState();
    state["epic_merge_pr"] = { merge_commit_sha: "abc123" };
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state), {
      requireComplete: true,
    });
    expect(
      errors.some((e) =>
        e.includes(
          "feature '2026-07-02-child-b-301' merge_status is not merged/worktree_removed",
        ),
      ),
    ).toBe(true);
  });

  it("rejects requireComplete when epic_merge_pr.merge_commit_sha is missing", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["merge_status"] = "merged";
    features[1]["merge_confirmed_at"] = "2026-07-02T18-30";
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state), {
      requireComplete: true,
    });
    expect(
      errors.some((e) =>
        e.includes("epic_merge_pr.merge_commit_sha is missing or empty"),
      ),
    ).toBe(true);
  });

  it("accepts a fully complete checkpoint under requireComplete", () => {
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["merge_status"] = "worktree_removed";
    features[1]["merge_confirmed_at"] = "2026-07-02T18-30";
    state["epic_merge_pr"] = { merge_commit_sha: "abc123def456" };
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state), {
      requireComplete: true,
    });
    expect(errors).toEqual([]);
  });

  it("defaults requireComplete to false (backward-compatible)", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(buildValidEpicState()),
    );
    expect(errors).toEqual([]);
  });
});
