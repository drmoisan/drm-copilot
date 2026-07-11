import { describe, expect, it } from "@jest/globals";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";
import { validateModelRoutingExistence } from "../../../src/lib/validate/orchestrator-state-model-routing-existence";

/**
 * Return a minimally valid orchestrator-state payload with one atomic-planner
 * delegation recorded. Tests mutate the routing arrays to exercise the
 * existence-only model-routing check.
 */
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
    last_updated: "2026-07-04T10:00:00-04:00",
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
        started_at: "2026-07-04T09:00:00-04:00",
        completed_at: "2026-07-04T09:05:00-04:00",
        result_signal: "PREFLIGHT: ALL CLEAR",
        artifact_paths: ["docs/features/active/feature-1/plan.md"],
      },
    ],
    blocked_reason: "none",
  };
}

/** A routing receipt object for the given agent. */
function receipt(agent: string): Record<string, unknown> {
  return {
    agent,
    phase: "7",
    complexity_band: "C3",
    fable_policy: "disabled",
    table_model: "opus",
    clamped_from: null,
    model: "opus",
  };
}

describe("validateOrchestratorStateText model-routing existence check", () => {
  it("reports an error when a delegated agent lacks a routing receipt", () => {
    // Arrange: delegate to two agents but record a receipt for only one.
    const state = buildValidState();
    (state["delegation_receipts"] as Record<string, unknown>[]).push({
      step: "8",
      agent_name: "atomic-executor",
      agent_id: "a2",
      skill_source: "orchestrator-workflow",
      started_at: "2026-07-04T09:10:00-04:00",
      completed_at: "2026-07-04T09:15:00-04:00",
      result_signal: "DONE",
      artifact_paths: ["docs/features/active/feature-1/evidence/x.md"],
    });
    state["model_routing_receipts"] = [receipt("atomic-planner")];

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state), {
      requireModelRouting: true,
    });

    // Assert
    expect(
      errors.some((error) =>
        error.includes(
          "missing a receipt for delegated agent: atomic-executor",
        ),
      ),
    ).toBe(true);
  });

  it("reports no error when every delegated agent has a routing receipt", () => {
    // Arrange
    const state = buildValidState();
    state["model_routing_receipts"] = [receipt("atomic-planner")];

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state), {
      requireModelRouting: true,
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("leaves output unchanged when requireModelRouting is absent", () => {
    // Arrange: a delegation with no routing receipts at all.
    const state = buildValidState();

    // Act
    const withoutFlag = validateOrchestratorStateText(JSON.stringify(state));
    const withFalse = validateOrchestratorStateText(JSON.stringify(state), {
      requireModelRouting: false,
    });

    // Assert: absent and explicit-false both produce no existence error.
    expect(withoutFlag).toEqual([]);
    expect(withFalse).toEqual([]);
  });

  it("imposes no requirement on a delegation-free checkpoint under the flag", () => {
    // Arrange: remove the delegation so the gate does not fire.
    const state = buildValidState();
    state["delegation_receipts"] = [];

    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state), {
      requireModelRouting: true,
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("uses a recognized next step and ignores malformed receipt entries", () => {
    expect(
      validateModelRoutingExistence({
        next_step: "atomic-executor",
        delegation_receipts: [null, { agent_name: " " }],
        model_routing_receipts: [
          null,
          { agent: " " },
          receipt("atomic-executor"),
        ],
      }),
    ).toEqual([]);
  });
});
