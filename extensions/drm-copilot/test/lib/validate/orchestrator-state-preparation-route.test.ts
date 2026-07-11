import { describe, expect, it } from "@jest/globals";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";
import {
  OUT_OF_SCOPE_STEP_KEYS,
  validatePreparationTerminalContract,
} from "../../../src/lib/validate/orchestrator-state-preparation-terminal";
import {
  routeRequiresCiGate,
  routeRequiresPrGate,
} from "../../../src/lib/validate/orchestrator-state-routing";

interface RouteFixture {
  readonly requires_pr_gate?: boolean;
  readonly requires_ci_gate?: boolean | string;
  readonly required_agents: ReadonlyArray<string>;
  readonly required_skills: ReadonlyArray<string>;
  readonly required_mcp_tools: ReadonlyArray<string>;
}

const PREPARATION_ROUTE: RouteFixture = {
  requires_ci_gate: false,
  required_agents: [
    "task-researcher",
    "prd-feature",
    "atomic-planner",
    "atomic-executor",
  ],
  required_skills: [
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
  ],
  required_mcp_tools: [
    "new_potential_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "validate_orchestration_artifacts",
  ],
};

const LARGE_ROUTE: RouteFixture = {
  requires_pr_gate: true,
  required_agents: [
    "task-researcher",
    "prd-feature",
    "atomic-planner",
    "atomic-executor",
    "feature-review",
    "pr-author",
  ],
  required_skills: [
    "orchestrate",
    "orchestrator-workflow",
    "feature-promotion-lifecycle",
    "repo-automation-adapter",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "pr-context-artifacts",
    "pr-base-branch-merge-base",
  ],
  required_mcp_tools: [
    "new_potential_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "collect_pr_context",
    "validate_orchestration_artifacts",
  ],
};

const ROUTING_MATRIX = {
  routes: {
    small: {
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
    large: LARGE_ROUTE,
    preparation: PREPARATION_ROUTE,
  },
};

type TestedRoute = "large" | "preparation";

/** Build a completion-safe checkpoint carrying the selected route's receipts. */
function buildCompleteState(routeId: TestedRoute): Record<string, unknown> {
  const route = routeId === "large" ? LARGE_ROUTE : PREPARATION_ROUTE;
  const requiredAgents = [...route.required_agents];
  const requiredSkills = [...route.required_skills];
  const requiredMcpTools = [...route.required_mcp_tools];
  const state: Record<string, unknown> = {
    objective: "obj",
    change_budget_estimate: routeId,
    route_id: routeId,
    path_selected: routeId,
    "promotion-type": "feature",
    "short-name": "short",
    relativeFile: "docs/features/potential/x.md",
    "long-name": "feature-1",
    "issue-num": "1",
    "feature-folder": "docs/features/active/feature-1",
    "work-mode": "full-feature",
    "plan-path": "docs/features/active/feature-1/plan.md",
    completed_steps: ["S3_promotion", "S4_atomic_planning"],
    next_step: "S5_atomic_execution",
    last_updated: "2026-07-10T10:00:00-04:00",
    step5_status: "not-applicable",
    step6_status: "not-applicable",
    step7_status: "not-applicable",
    step8_status: "not-applicable",
    step9_status: "not-applicable",
    step10_status: "not-applicable",
    required_agents: requiredAgents,
    required_skills: requiredSkills,
    required_mcp_tools: requiredMcpTools,
    delegation_receipts: requiredAgents.map((agent, index) => ({
      step: `handoff-${index + 1}`,
      agent_name: agent,
      agent_id: `${agent}-1`,
      skill_source: "orchestrate",
      started_at: "2026-07-10T09:00:00-04:00",
      completed_at: "2026-07-10T09:05:00-04:00",
      result_signal: "COMPLETE",
      artifact_paths: [`artifacts/orchestration/${agent}.receipt.json`],
    })),
    skill_receipts: requiredSkills.map((skill) => ({
      skill,
      required: true,
      acknowledged_at_phase: "completion",
      evidence: `artifact:${skill}`,
    })),
    mcp_call_receipts: requiredMcpTools.map((tool) => ({
      tool,
      ok: true,
      evidence: `mcp_call:${tool}`,
    })),
    local_execution_overrides: [],
    delegation_bypasses: [],
    lifecycle_operations: requiredMcpTools.map((tool) => ({
      name: tool,
      surface: "mcp",
    })),
    blocked_reason: "none",
  };
  if (routeId === "large") {
    state["pr_gate"] = {
      pr_number: 1,
      pr_url: "https://github.com/drmoisan/drm-copilot/pull/1",
      head_branch: "feature-1",
      head_sha: "current-head-sha",
    };
    state["ci_gate"] = {
      conclusion: "success",
      head_sha: "current-head-sha",
      verified_at: "2026-07-10T10:00:00Z",
    };
  }
  return state;
}

/** Run completion validation against the shared route fixture. */
function validate(state: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(state), {
    requireComplete: true,
    routingMatrix: ROUTING_MATRIX,
  });
}

describe("preparation route completion gates", () => {
  it("opts out of CI only for the preparation route's Boolean false", () => {
    // Arrange / Act / Assert
    expect(
      routeRequiresCiGate(
        { route_id: "preparation" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(false);
  });

  it("requires CI when the selected route's flag is absent", () => {
    // Arrange / Act / Assert
    expect(
      routeRequiresCiGate(
        { route_id: "large" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(true);
    expect(
      routeRequiresCiGate(
        { route_id: "small" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(true);
  });

  it("requires CI for missing and unknown routes", () => {
    // Arrange / Act / Assert
    expect(routeRequiresCiGate({}, { routingMatrix: ROUTING_MATRIX })).toBe(
      true,
    );
    expect(
      routeRequiresCiGate(
        { route_id: "fabricated-route" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(true);
  });

  it("requires CI for a malformed routing matrix", () => {
    // Arrange / Act / Assert
    expect(
      routeRequiresCiGate(
        { route_id: "preparation" },
        { routingMatrix: { routes: [] } },
      ),
    ).toBe(true);
  });

  it("requires CI when the opt-out flag is not a Boolean", () => {
    // Arrange
    const matrix = {
      routes: {
        preparation: {
          ...PREPARATION_ROUTE,
          requires_ci_gate: "false",
        },
      },
    };

    // Act / Assert
    expect(
      routeRequiresCiGate(
        { route_id: "preparation" },
        { routingMatrix: matrix },
      ),
    ).toBe(true);
  });

  it("does not require a PR for the preparation route", () => {
    // Arrange / Act / Assert
    expect(
      routeRequiresPrGate(
        { route_id: "preparation" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(false);
  });

  it("requires a PR only for a route with the literal Boolean true", () => {
    // Arrange
    const malformedFlagMatrix = {
      routes: { large: { ...LARGE_ROUTE, requires_pr_gate: "true" } },
    };

    // Act / Assert
    expect(
      routeRequiresPrGate(
        { route_id: "large" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(true);
    expect(
      routeRequiresPrGate(
        { route_id: "large" },
        { routingMatrix: malformedFlagMatrix },
      ),
    ).toBe(false);
    expect(
      routeRequiresPrGate(
        { route_id: "fabricated-route" },
        { routingMatrix: ROUTING_MATRIX },
      ),
    ).toBe(false);
  });

  it("accepts a complete preparation state without PR or CI gates", () => {
    // Arrange / Act / Assert
    expect(validate(buildCompleteState("preparation"))).toEqual([]);
  });

  it("still requires a CI gate for large-route completion", () => {
    // Arrange
    const state = buildCompleteState("large");
    delete state["ci_gate"];

    // Act
    const errors = validate(state);

    // Assert
    expect(errors.some((error) => error.includes("ci_gate"))).toBe(true);
  });

  it("rejects preparation completion missing a mandatory phase", () => {
    // Arrange
    const state = buildCompleteState("preparation");
    state["completed_steps"] = ["S4_atomic_planning"];

    // Act
    const errors = validate(state);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("missing mandatory phase S3_promotion"),
      ),
    ).toBe(true);
  });

  it("rejects preparation completion missing a required agent receipt", () => {
    // Arrange
    const state = buildCompleteState("preparation");
    const receipts = state["delegation_receipts"] as Record<string, unknown>[];
    state["delegation_receipts"] = receipts.filter(
      (receipt) => receipt["agent_name"] !== "atomic-executor",
    );

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint missing required agent receipt: atomic-executor.",
    );
  });

  it("rejects preparation completion with a pending step", () => {
    // Arrange
    const state = buildCompleteState("preparation");
    state["step5_status"] = "pending";

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Checkpoint completion validation failed: step5_status is pending.",
    );
  });

  it("rejects preparation completion with the wrong next step", () => {
    // Arrange
    const state = buildCompleteState("preparation");
    state["next_step"] = "done";

    // Act
    const errors = validate(state);

    // Assert
    expect(errors).toContain(
      "Preparation checkpoint next_step must be 'S5_atomic_execution', " +
        "found 'done'.",
    );
  });

  it.each(OUT_OF_SCOPE_STEP_KEYS)(
    "rejects preparation completion when %s is in scope",
    (key) => {
      // Arrange
      const state = buildCompleteState("preparation");
      state[key] = "verified";

      // Act
      const errors = validate(state);

      // Assert
      expect(errors).toContain(
        `Preparation checkpoint ${key} must be 'not-applicable', ` +
          "found 'verified'.",
      );
    },
  );

  it("applies the exact terminal contract only in completion mode", () => {
    // Arrange
    const state = buildCompleteState("preparation");
    state["next_step"] = "done";
    state["step7_status"] = "verified";

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state), {
      routingMatrix: ROUTING_MATRIX,
    });

    // Assert
    expect(
      errors.some((error) => error.startsWith("Preparation checkpoint")),
    ).toBe(false);
  });

  it.each([
    [undefined, "None"],
    [null, "None"],
    [true, "True"],
    [42, "42"],
    [["phase", null], "['phase', None]"],
    [{ phase: "planning" }, "{'phase': 'planning'}"],
  ])(
    "reports malformed next_step value %p with Python parity",
    (value, repr) => {
      // Arrange
      const state = buildCompleteState("preparation");
      state["next_step"] = value;

      // Act
      const errors = validatePreparationTerminalContract(state);

      // Assert
      expect(errors).toContain(
        "Preparation checkpoint next_step must be 'S5_atomic_execution', " +
          `found ${repr}.`,
      );
    },
  );
});
