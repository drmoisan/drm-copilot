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

const PR_GATE = {
  pr_number: 232,
  pr_url: "https://github.com/drmoisan/drm-copilot/pull/232",
  head_branch: "feature/example",
  head_sha: "current-head-sha",
};
const CI_GATE = {
  conclusion: "success",
  head_sha: "current-head-sha",
  verified_at: "2026-06-25T07:45:00Z",
};

const ROUTING_MATRIX = {
  routes: {
    large: {
      requires_pr_gate: true,
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
    small: {
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
  },
};

/**
 * Validate in completion mode with a focused routing matrix. The routing
 * contract is exercised separately in orchestrator-state-routing.test.ts.
 */
function validateComplete(state: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(state), {
    requireComplete: true,
    routingMatrix: ROUTING_MATRIX,
  });
}

/** Validate only the independent pre-PR-creation readiness gate. */
function validateReady(state: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(state), {
    requirePrCreationReady: true,
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

  it("rejects a missing pr_gate for a route that requires it", () => {
    // Arrange / Act
    const errors = validateComplete(buildValidState());

    // Assert
    expect(errors.some((error) => error.includes("pr_gate"))).toBe(true);
  });

  it("rejects a missing ci_gate when pr_gate is present", () => {
    // Arrange
    const state = buildValidState();
    state["pr_gate"] = PR_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("ci_gate"))).toBe(true);
  });

  it("rejects a ci_gate whose conclusion is not success", () => {
    // Arrange
    const state = buildValidState();
    state["pr_gate"] = PR_GATE;
    state["ci_gate"] = { ...CI_GATE, conclusion: "failure" };

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
    state["pr_gate"] = PR_GATE;
    state["ci_gate"] = { ...CI_GATE, head_sha: "stale-head-sha" };

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

  it("skips the PR gate for a route that does not require it", () => {
    // Arrange
    const state = buildValidState();
    state["path_selected"] = "small";
    state["ci_gate"] = CI_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("pr_gate"))).toBe(false);
  });

  it("does not apply issue-specific branch or promotion requirements", () => {
    // Arrange
    const state = buildValidState();
    state["issue-num"] = "232";
    state["pr_gate"] = { ...PR_GATE, head_branch: "feature/arbitrary" };
    state["ci_gate"] = CI_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("head_branch"))).toBe(false);
    expect(errors.some((error) => error.includes("promotion_receipts"))).toBe(
      false,
    );
  });

  it("rejects each documented failure step status under requireComplete", () => {
    // Arrange / Act / Assert: each failure value on its owning step key blocks
    // completion with the byte-identical Python message form.
    const failureStatuses: ReadonlyArray<readonly [string, string]> = [
      ["step9_status", "failed_remediation_required"],
      ["step9_status", "blocked_ci_loop_limit"],
      ["step6_status", "blocked_remediation_loop_limit"],
    ];
    for (const [key, value] of failureStatuses) {
      const state = buildValidState();
      state[key] = value;
      expect(validateComplete(state)).toContain(
        `Checkpoint completion validation failed: ${key} is ${value}.`,
      );
    }
  });

  it("does not block completion on step9_status passed", () => {
    // Arrange: an otherwise-complete checkpoint recording CI green.
    const state = buildValidState();
    state["step9_status"] = "passed";
    state["pr_gate"] = PR_GATE;
    state["ci_gate"] = CI_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(
      errors.some((error) =>
        error.startsWith(
          "Checkpoint completion validation failed: step9_status",
        ),
      ),
    ).toBe(false);
  });

  it("invokes the routing contract under requireComplete with an injected matrix", () => {
    // Arrange: an empty routing matrix yields the routes-missing error.
    const state = buildValidState();
    state["pr_gate"] = PR_GATE;
    state["ci_gate"] = CI_GATE;

    // Act
    const errors = validateComplete(state);

    // Assert
    expect(errors.some((error) => error.includes("required_agents"))).toBe(
      true,
    );
  });

  it("accepts pre-PR readiness without PR, CI, or pr-author evidence", () => {
    const state = buildValidState();
    state["step9_status"] = "pending";

    const errors = validateReady(state);

    expect(errors).toEqual([]);
    expect(
      errors.some(
        (error) =>
          error.includes("pr_gate") ||
          error.includes("ci_gate") ||
          error.includes("pr-author"),
      ),
    ).toBe(false);
  });

  it.each([
    ["step6_status", "pending"],
    ["step8_status", "blocked"],
    ["step6_status", "blocked_remediation_loop_limit"],
  ] as const)("rejects readiness when %s is %s", (key, value) => {
    const state = buildValidState();
    state[key] = value;

    expect(validateReady(state)).toContain(
      `Checkpoint PR-creation readiness validation failed: ${key} is ${value}.`,
    );
  });

  it("rejects a non-none blocked reason during readiness", () => {
    const state = buildValidState();
    state["blocked_reason"] = "delegate_no_receipt";

    expect(validateReady(state)).toContain(
      "Checkpoint PR-creation readiness validation failed: " +
        "blocked_reason is not `none`.",
    );
  });

  it.each(["local_execution_overrides", "delegation_bypasses"])(
    "rejects non-empty readiness override field %s",
    (key) => {
      const state = buildValidState();
      state[key] = ["recorded"];

      expect(validateReady(state)).toContain(
        "Checkpoint PR-creation readiness validation failed: " +
          `${key} must be an empty list when present.`,
      );
    },
  );

  it("returns the deterministic union when readiness and completion are selected", () => {
    const state = buildValidState();
    state["step9_status"] = "pending";
    const completionErrors = validateComplete(state);

    const combinedErrors = validateOrchestratorStateText(
      JSON.stringify(state),
      {
        requireComplete: true,
        requirePrCreationReady: true,
        routingMatrix: ROUTING_MATRIX,
      },
    );

    expect(combinedErrors).toEqual(completionErrors);
    expect(combinedErrors).toContain(
      "Checkpoint completion validation failed: step9_status is pending.",
    );
  });
});
