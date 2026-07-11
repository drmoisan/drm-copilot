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

  it("rejects a concurrency cap outside the bounded range", () => {
    const state = buildValidEpicState();
    state["max_parallel_features"] = 9;

    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));

    expect(
      errors.some((error) => error.includes("max_parallel_features")),
    ).toBe(true);
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
    for (const feature of features) {
      const folder = String(feature["feature_folder"]);
      const issueNum = feature["issue_num"];
      const delegationId = `delegate-${String(issueNum)}`;
      const agent = "orchestrator-c3-elevated";
      feature["branch_name"] = `feature/${folder}`;
      feature["delegation_receipt"] = {
        delegation_id: delegationId,
        feature_folder: folder,
        issue_num: issueNum,
        agent_name: agent,
      };
      feature["model_routing_receipt"] = {
        delegation_id: delegationId,
        deployment_agent: agent,
        execution_context: "epic_execution_child",
      };
      feature["launch_receipt_path"] =
        `artifacts/orchestration/epic-child-launches/${folder}.receipt.json`;
      feature["launch_status_path"] =
        `artifacts/orchestration/epic-child-launches/${folder}.status.json`;
    }
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

/**
 * Return a valid epic checkpoint carrying the supplied intent value.
 *
 * Mirrors the Python test helper `_state_with_intent`.
 *
 * @param intent The intent value to attach to the checkpoint.
 * @returns The checkpoint payload with `intent` set.
 */
function stateWithIntent(intent: unknown): Record<string, unknown> {
  const state = buildValidEpicState();
  state["intent"] = intent;
  return state;
}

describe("validateEpicOrchestratorStateText issue_num-keyed DAG", () => {
  it("resolves a depends_on entry expressed by issue_num", () => {
    // Arrange: child-b depends on child-a via its issue_num (300).
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["depends_on"] = [300];
    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    // Assert
    expect(errors).toEqual([]);
  });

  it("reports an unresolved issue_num reference, byte-identical to Python", () => {
    // Arrange: 999 is not a defined issue_num.
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["depends_on"] = [999];
    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    // Assert
    expect(errors).toContain(
      "Epic checkpoint feature '2026-07-02-child-b-301' depends_on unresolved feature_folder: 999",
    );
  });

  it("resolves a depends_on hint that points into completed/", () => {
    // Arrange
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["depends_on"] = [
      "docs/features/completed/2026-07-02-child-a-300",
    ];
    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    // Assert
    expect(errors).toEqual([]);
  });

  it("resolves a depends_on hint that points into active/", () => {
    // Arrange
    const state = buildValidEpicState();
    const features = state["features"] as Record<string, unknown>[];
    features[1]["depends_on"] = ["active/2026-07-02-child-a-300"];
    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(state));
    // Assert
    expect(errors).toEqual([]);
  });
});

describe("validateEpicOrchestratorStateText presence-gated intent block", () => {
  it("accepts a valid intent block", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(
        stateWithIntent({
          epic_type: "business",
          business_outcome_hypothesis: "reduce store lockups by 90%",
          leading_indicators: ["lockup rate", "retry rate"],
          nfrs: ["p99 < 200ms"],
        }),
      ),
    );
    expect(errors).toEqual([]);
  });

  it("adds no errors when the intent block is absent", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(buildValidEpicState()),
    );
    expect(errors).toEqual([]);
  });

  it("rejects a non-object intent, byte-identical to Python", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(stateWithIntent("not-an-object")),
    );
    expect(errors).toEqual(["Epic checkpoint intent must be an object."]);
  });

  it("rejects a bad epic_type, byte-identical to Python", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(
        stateWithIntent({
          epic_type: "marketing",
          business_outcome_hypothesis: "some outcome",
        }),
      ),
    );
    expect(errors).toContain(
      "Epic checkpoint intent.epic_type must be 'business' or 'enabler', found: 'marketing'",
    );
  });

  it("rejects an empty business_outcome_hypothesis, byte-identical to Python", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(
        stateWithIntent({
          epic_type: "enabler",
          business_outcome_hypothesis: "   ",
        }),
      ),
    );
    expect(errors).toContain(
      "Epic checkpoint intent.business_outcome_hypothesis must be a non-empty string.",
    );
  });

  it("rejects a non-list leading_indicators, byte-identical to Python", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(
        stateWithIntent({
          epic_type: "business",
          business_outcome_hypothesis: "some outcome",
          leading_indicators: "not-a-list",
        }),
      ),
    );
    expect(errors).toContain(
      "Epic checkpoint intent.leading_indicators must be a list of strings.",
    );
  });

  it("rejects a non-string element in nfrs, byte-identical to Python", () => {
    const errors = validateEpicOrchestratorStateText(
      JSON.stringify(
        stateWithIntent({
          epic_type: "business",
          business_outcome_hypothesis: "some outcome",
          nfrs: ["ok", 5],
        }),
      ),
    );
    expect(errors).toContain(
      "Epic checkpoint intent.nfrs must be a list of strings.",
    );
  });
});
