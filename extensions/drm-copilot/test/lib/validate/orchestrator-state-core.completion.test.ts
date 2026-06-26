import { describe, expect, it } from "@jest/globals";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

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

const ISSUE_232_PR_GATE = {
  pr_number: 232,
  pr_url: "https://github.com/drmoisan/drm-copilot/pull/232",
  head_branch: "feature/harden-orchestrate-skill-232",
  head_sha: "current-head-sha",
};
const ISSUE_232_CI_GATE = {
  conclusion: "success",
  head_sha: "current-head-sha",
  verified_at: "2026-06-25T07:45:00Z",
};

/**
 * Validate in completion mode with an empty routing matrix. The routing-contract
 * check is exercised separately in orchestrator-state-routing.test.ts; an empty
 * matrix yields a single deterministic routing error that does not collide with
 * the completion-gate substrings asserted here.
 */
function validateComplete(state: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(state), {
    requireComplete: true,
    routingMatrix: {},
  });
}

describe("validateOrchestratorStateText completion gates", () => {
  it("rejects pending or blocked step statuses under requireComplete", () => {
    // Arrange
    const state = buildValidState();
    state["step8_status"] = "pending";

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint completion validation failed: step8_status is pending.",
    );
  });

  it("rejects a non-none blocked_reason under requireComplete", () => {
    // Arrange
    const state = buildValidState();
    state["blocked_reason"] = "validator_failed";

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint completion validation failed: blocked_reason is not `none`.",
    );
  });

  it("rejects a missing pr_gate", () => {
    // Arrange / Act
    const errors = validateComplete(buildValidState());

    // Assert
    expect(errors.some((error) => error.includes("pr_gate"))).toBe(true);
  });

  it("rejects a missing ci_gate when pr_gate is present", () => {
    // Arrange
    const state = buildValidState();
    state["pr_gate"] = ISSUE_232_PR_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("ci_gate"))).toBe(true);
  });

  it("rejects a ci_gate whose conclusion is not success", () => {
    // Arrange
    const state = buildValidState();
    state["pr_gate"] = ISSUE_232_PR_GATE;
    state["ci_gate"] = { ...ISSUE_232_CI_GATE, conclusion: "failure" };

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("ci_gate.conclusion"))).toBe(
      true,
    );
  });

  it("rejects a ci_gate head_sha that does not match pr_gate", () => {
    // Arrange
    const state = buildValidState();
    state["issue-num"] = "232";
    state["pr_gate"] = ISSUE_232_PR_GATE;
    state["ci_gate"] = { ...ISSUE_232_CI_GATE, head_sha: "stale-head-sha" };

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(
      errors.some(
        (error) =>
          error.includes("ci_gate.head_sha") &&
          error.includes("pr_gate.head_sha"),
      ),
    ).toBe(true);
  });

  it("rejects an Issue #232 pr_gate with the wrong head branch", () => {
    // Arrange
    const state = buildValidState();
    state["issue-num"] = "232";
    state["pr_gate"] = { ...ISSUE_232_PR_GATE, head_branch: "feature/wrong" };

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("pr_gate.head_branch"))).toBe(
      true,
    );
  });

  it("rejects Issue #232 completion with missing promotion receipts", () => {
    // Arrange
    const state = buildValidState();
    state["issue-num"] = "232";
    state["pr_gate"] = ISSUE_232_PR_GATE;
    state["ci_gate"] = ISSUE_232_CI_GATE;
    state["delegation_receipts"] = { promotion: { issue: "#232" } };

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(
      errors.some((error) => error.includes("delegation_receipts.promotion")),
    ).toBe(true);
  });

  it("accepts Issue #232 top-level promotion receipts", () => {
    // Arrange
    const state = buildValidState();
    state["issue-num"] = "232";
    state["pr_gate"] = ISSUE_232_PR_GATE;
    state["ci_gate"] = ISSUE_232_CI_GATE;
    state["promotion_receipts"] = {
      potential_entry: { path: "docs/features/potential/demo.md" },
      issue: { number: 232 },
      feature_folder: {
        path: "docs/features/active/2026-06-24-harden-orchestrate-skill-232",
      },
    };

    // Act
    const errors = validateComplete(state);

    // Assert: no promotion-receipt error remains (routing errors are unrelated).
    expect(errors.some((error) => error.includes("promotion_receipts"))).toBe(
      false,
    );
  });

  it("invokes the routing contract under requireComplete with an injected matrix", () => {
    // Arrange: an empty routing matrix yields the routes-missing error.
    const state = buildValidState();
    state["pr_gate"] = ISSUE_232_PR_GATE;
    state["ci_gate"] = ISSUE_232_CI_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors).toContain("Routing matrix missing routes object.");
  });
});
