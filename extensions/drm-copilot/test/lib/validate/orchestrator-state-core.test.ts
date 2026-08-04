import { describe, expect, it } from "@jest/globals";

import {
  REQUIRED_STATE_KEYS,
  validateOrchestratorStateText,
} from "../../../src/lib/validate/orchestrator-state-core";

/** Return a minimally valid orchestrator-state payload for mutation. */
function buildValidState(): Record<string, unknown> {
  return {
    objective: "obj",
    change_budget_estimate: "large",
    path_selected: "large",
    "promotion-type": "feature",
    "short-name": "short",
    relativeFile: "docs/features/potential/x.md",
    "long-name": "feature-1",
    "issue-num": "1",
    "feature-folder": "docs/features/active/feature-1",
    "work-mode": "full-feature",
    "plan-path": "docs/features/active/feature-1/plan.md",
    completed_steps: [],
    next_step: "done",
    last_updated: "2026-04-07T10:00:00-04:00",
    step5_status: "not-applicable",
    step6_status: "not-applicable",
    step7_status: "verified",
    step8_status: "not-applicable",
    step9_status: "verified",
    step10_status: "not-applicable",
    delegation_receipts: [
      {
        step: "7",
        agent_name: "atomic-planner",
        agent_id: "a1",
        skill_source: "orchestrator-workflow",
        started_at: "2026-04-07T09:00:00-04:00",
        completed_at: "2026-04-07T09:05:00-04:00",
        result_signal: "PREFLIGHT: ALL CLEAR",
        artifact_paths: ["docs/features/active/feature-1/plan.md"],
      },
    ],
    blocked_reason: "none",
  };
}

/**
 * Per-key additive step-status vocabulary, mirrored from the Python source
 * `scripts/dev_tools/_orchestrator_state_step_status.py`. Each pair is the
 * owning step-status key and a value that is valid only on that key.
 */
const STEP_SPECIFIC_EXTRA_STATUS: ReadonlyArray<readonly [string, string]> = [
  ["step9_status", "passed"],
  ["step9_status", "failed_remediation_required"],
  ["step9_status", "blocked_ci_loop_limit"],
  ["step6_status", "blocked_remediation_loop_limit"],
];

/** Every tracked step-status key, used to prove per-key scoping. */
const STEP_STATUS_KEYS: readonly string[] = [
  "step5_status",
  "step6_status",
  "step7_status",
  "step8_status",
  "step9_status",
  "step10_status",
];

describe("validateOrchestratorStateText parsing and schema", () => {
  it("returns no errors for a minimally valid checkpoint", () => {
    // Arrange / Act / Assert
    expect(
      validateOrchestratorStateText(JSON.stringify(buildValidState())),
    ).toEqual([]);
  });

  it("reports invalid JSON with the explicit parse error prefix", () => {
    // Arrange / Act
    const errors = validateOrchestratorStateText('{"objective":');

    // Assert
    expect(errors).toHaveLength(1);
    expect(errors[0]?.startsWith("Checkpoint is not valid JSON:")).toBe(true);
  });

  it("rejects a non-object root", () => {
    // Arrange / Act
    const errors = validateOrchestratorStateText("[]");

    // Assert
    expect(errors).toEqual(["Checkpoint root must be a JSON object."]);
  });

  it("reports each missing required key", () => {
    // Arrange / Act / Assert: drop one required key at a time.
    for (const key of REQUIRED_STATE_KEYS) {
      const state = buildValidState();
      delete state[key];
      const errors = validateOrchestratorStateText(JSON.stringify(state));
      expect(errors).toContain(`Checkpoint missing required key: ${key}`);
    }
  });

  it("rejects an invalid step status", () => {
    // Arrange
    const state = buildValidState();
    state["step8_status"] = "invalid-status";

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint has invalid step8_status: invalid-status",
    );
  });

  it("rejects an invalid blocked_reason", () => {
    // Arrange
    const state = buildValidState();
    state["blocked_reason"] = "unknown-reason";

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint has invalid blocked_reason: unknown-reason",
    );
  });
});

describe("validateOrchestratorStateText per-step-key status vocabulary", () => {
  it("accepts each per-key extra status on its owning step key", () => {
    // Arrange / Act / Assert: one owning-key placement at a time.
    for (const [owningKey, value] of STEP_SPECIFIC_EXTRA_STATUS) {
      const state = buildValidState();
      state[owningKey] = value;
      expect(validateOrchestratorStateText(JSON.stringify(state))).toEqual([]);
    }
  });

  it("rejects each per-key extra status on every non-owning step key", () => {
    // Arrange / Act / Assert: the same value on a foreign key stays invalid.
    for (const [owningKey, value] of STEP_SPECIFIC_EXTRA_STATUS) {
      for (const key of STEP_STATUS_KEYS) {
        if (key === owningKey) {
          continue;
        }
        const state = buildValidState();
        state[key] = value;
        expect(validateOrchestratorStateText(JSON.stringify(state))).toContain(
          `Checkpoint has invalid ${key}: ${value}`,
        );
      }
    }
  });
});

describe("validateOrchestratorStateText delegation receipts", () => {
  it("reports a non-object legacy receipt entry", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = ["invalid"];

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation receipt #0 must be an object.",
    );
  });

  it("reports a legacy receipt missing a required key", () => {
    // Arrange: omit agent_name from the single receipt.
    const state = buildValidState();
    const receipt = (
      state["delegation_receipts"] as Record<string, unknown>[]
    )[0];
    delete receipt?.["agent_name"];

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation receipt #0 missing key: agent_name",
    );
  });

  it("reports a legacy receipt with a non-list artifact_paths", () => {
    // Arrange
    const state = buildValidState();
    const receipt = (
      state["delegation_receipts"] as Record<string, unknown>[]
    )[0];
    if (receipt) {
      receipt["artifact_paths"] = "not-a-list";
    }

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation receipt #0 artifact_paths must be a list.",
    );
  });

  it("rejects a non-list, non-object delegation_receipts value", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = "nope";

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation_receipts must be a list or object namespace.",
    );
  });

  it("rejects a namespaced receipt with an unsupported top-level key", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = { promotion: {}, unexpected: {} };

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation_receipts object contains unsupported key: unexpected",
    );
  });

  it("rejects a non-object promotion namespace", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = { promotion: "invalid" };

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation_receipts.promotion must be an object namespace.",
    );
  });

  it("rejects an unsupported nested promotion key", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = {
      promotion: {
        potential_entry: {},
        issue: {},
        feature_folder: {},
        unexpected_key: {},
      },
    };

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation_receipts.promotion contains unsupported key: " +
        "unexpected_key",
    );
  });

  it("accepts a valid promotion namespace", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = {
      promotion: {
        potential_entry: { path: "docs/features/potential/demo.md" },
        issue: "https://github.com/x/issues/168",
        feature_folder: { path: "docs/features/active/feature-1" },
      },
    };

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toEqual([]);
  });
});

describe("validateOrchestratorStateText optional blocks", () => {
  it("delegates to the remediation validator when remediation_loop is present", () => {
    // Arrange: a malformed cycle should surface a remediation error.
    const state = buildValidState();
    state["remediation_loop"] = { cycles: ["not-a-cycle"] };

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 must be an object.",
    );
  });

  it("delegates to the human-interaction validator when present", () => {
    // Arrange: a non-list requirements value should surface its error.
    const state = buildValidState();
    state["human_interaction"] = { requirements: "nope" };

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));

    // Assert
    expect(errors).toContain(
      "Checkpoint human_interaction.requirements must be a list.",
    );
  });
});

describe("validateOrchestratorStateText mixed delegation receipts", () => {
  it("accepts canonical agents and opaque promotion payloads", () => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = {
      agents: state["delegation_receipts"],
      promotion: {
        potential_entry: { opaque: "potential" },
        issue: "opaque issue value",
        feature_folder: ["opaque", "folder", "value"],
      },
    };

    // Act / Assert
    expect(validateOrchestratorStateText(JSON.stringify(state))).toEqual([]);
  });

  it("retains legacy-list and promotion-only compatibility", () => {
    // Arrange
    const legacy = buildValidState();
    const promotionOnly = buildValidState();
    promotionOnly["delegation_receipts"] = { promotion: { issue: {} } };

    // Act / Assert
    expect(validateOrchestratorStateText(JSON.stringify(legacy))).toEqual([]);
    expect(
      validateOrchestratorStateText(JSON.stringify(promotionOnly)),
    ).toEqual([]);
  });

  it.each([
    [
      { agents: "not-a-list" },
      "Checkpoint delegation_receipts.agents must be a list.",
    ],
    [
      { agents: [{ agent_name: "atomic-planner" }] },
      "Checkpoint delegation receipt #0 missing key: step",
    ],
    [
      { agents: [], unexpected: {} },
      "Checkpoint delegation_receipts object contains unsupported key: unexpected",
    ],
    [
      { promotion: { unexpected: {} } },
      "Checkpoint delegation_receipts.promotion contains unsupported key: unexpected",
    ],
  ])("rejects invalid canonical shape %#", (receipts, expected) => {
    // Arrange
    const state = buildValidState();
    state["delegation_receipts"] = receipts;

    // Act / Assert
    expect(validateOrchestratorStateText(JSON.stringify(state))).toContain(
      expected,
    );
  });
});
