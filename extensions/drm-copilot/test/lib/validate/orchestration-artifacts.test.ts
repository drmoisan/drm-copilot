import { describe, expect, it } from "@jest/globals";

import {
  validateArtifact,
  validatePlanText,
} from "../../../src/lib/validate/orchestration-artifacts";

const VALID_PLAN = [
  "# Plan",
  "### Phase 0 — Setup",
  "- [ ] [P0-T1] First task",
  "- [ ] [P0-T2] Second task",
  "### Phase 1 — Build",
  "- [x] [P1-T1] Third task",
].join("\n");

describe("validatePlanText", () => {
  it("returns no errors for a valid plan", () => {
    // Arrange / Act / Assert
    expect(validatePlanText(VALID_PLAN)).toEqual([]);
  });

  it("reports a malformed phase heading", () => {
    // Arrange: a phase heading without the em-dash/title contract.
    const text = ["### Phase 0 Setup", "- [ ] [P0-T1] Task"].join("\n");

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("phase heading must match `### Phase N — <Title>`."),
      ),
    ).toBe(true);
  });

  it("reports a malformed task line", () => {
    // Arrange: a task token without the canonical checkbox/title shape.
    const text = ["### Phase 0 — Setup", "- [ ] [P0-T1]NoSpaceTitle"].join(
      "\n",
    );

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("task line must match `- [ ] [P#-T#] <Title>`."),
      ),
    ).toBe(true);
  });

  it("reports a task that appears before a phase heading", () => {
    // Arrange
    const text = "- [ ] [P0-T1] Orphan task";

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("task appears before a canonical phase heading."),
      ),
    ).toBe(true);
  });

  it("reports a task phase mismatch", () => {
    // Arrange: task labeled P1 under Phase 0.
    const text = ["### Phase 0 — Setup", "- [ ] [P1-T1] Task"].join("\n");

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("task phase P1 does not match current phase 0."),
      ),
    ).toBe(true);
  });

  it("reports a task number out of sequence", () => {
    // Arrange: T2 follows directly without a T1.
    const text = ["### Phase 0 — Setup", "- [ ] [P0-T2] Task"].join("\n");

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("expected task number T1 for phase 0, found T2."),
      ),
    ).toBe(true);
  });

  it("reports a plan with no phase headings", () => {
    // Arrange
    const text = "# Plan without phases";

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(errors).toContain(
      "Plan does not contain any canonical phase headings.",
    );
  });

  it("reports a plan with no task lines", () => {
    // Arrange
    const text = "### Phase 0 — Setup";

    // Act
    const errors = validatePlanText(text);

    // Assert
    expect(errors).toContain("Plan does not contain any canonical task lines.");
  });
});

describe("validateArtifact dispatch", () => {
  it("routes plan to the plan validator", () => {
    // Arrange / Act / Assert
    expect(
      validateArtifact({ artifactType: "plan", text: VALID_PLAN }),
    ).toEqual([]);
  });

  it("routes policy-audit to the policy-audit validator", () => {
    // Arrange: an empty document triggers a policy-audit heading error.
    const errors = validateArtifact({ artifactType: "policy-audit", text: "" });

    // Assert
    expect(
      errors.some((error) => error.startsWith("Policy audit missing")),
    ).toBe(true);
  });

  it("routes code-review to the code-review validator", () => {
    // Arrange / Act
    const errors = validateArtifact({ artifactType: "code-review", text: "" });

    // Assert
    expect(
      errors.some((error) => error.startsWith("Code review missing")),
    ).toBe(true);
  });

  it("routes feature-audit to the feature-audit validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "feature-audit",
      text: "",
    });

    // Assert
    expect(
      errors.some((error) => error.startsWith("Feature audit missing")),
    ).toBe(true);
  });

  it("routes orchestrator-state to the orchestrator-state validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "orchestrator-state",
      text: "[]",
    });

    // Assert
    expect(errors).toEqual(["Checkpoint root must be a JSON object."]);
  });

  it("threads requireComplete and routing matrix into orchestrator-state", () => {
    // Arrange: completion mode with an empty routing matrix surfaces the
    // routes-missing error, proving the wiring reaches the routing contract.
    const errors = validateArtifact({
      artifactType: "orchestrator-state",
      text: "{}",
      requireComplete: true,
      routingMatrix: {},
    });

    // Assert
    expect(errors).toContain("Routing matrix missing routes object.");
  });

  it("falls back for an unsupported artifact type", () => {
    // Arrange / Act
    const errors = validateArtifact({ artifactType: "mystery", text: "" });

    // Assert
    expect(errors).toEqual(["Unsupported artifact type: mystery"]);
  });
});

describe("validateArtifact combined orchestrator-state acceptance", () => {
  it("accepts completed statuses with promotion, human_interaction, and remediation", () => {
    // Arrange: a checkpoint exercising the additive blocks with no completion
    // gate (requireComplete omitted) must produce no errors.
    const state = {
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
      completed_steps: ["S7"],
      next_step: "done",
      last_updated: "2026-04-07T10:00:00-04:00",
      step5_status: "completed",
      step6_status: "completed",
      step7_status: "completed",
      step8_status: "completed",
      step9_status: "completed",
      step10_status: "completed",
      delegation_receipts: {
        promotion: {
          potential_entry: { path: "docs/features/potential/demo.md" },
          issue: "https://github.com/x/issues/1",
          feature_folder: { path: "docs/features/active/feature-1" },
        },
      },
      human_interaction: {
        requirements: [{ id: "r1", response: "scope_change" }],
      },
      remediation_loop: {
        cycles: [
          {
            plan_path: "docs/features/active/feature-1/remediation-1.plan.md",
            execution_status: "complete",
            preflight: { final_status: "clear" },
            exit_condition_met: true,
            blocking_count: 0,
          },
        ],
      },
      blocked_reason: "none",
    };

    // Act
    const errors = validateArtifact({
      artifactType: "orchestrator-state",
      text: JSON.stringify(state),
    });

    // Assert
    expect(errors).toEqual([]);
  });

  it("rejects an unsupported promotion key in the combined checkpoint", () => {
    // Arrange
    const state = {
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
      step5_status: "completed",
      step6_status: "completed",
      step7_status: "completed",
      step8_status: "completed",
      step9_status: "completed",
      step10_status: "completed",
      delegation_receipts: {
        promotion: {
          potential_entry: {},
          issue: {},
          feature_folder: {},
          unexpected_key: {},
        },
      },
      blocked_reason: "none",
    };

    // Act
    const errors = validateArtifact({
      artifactType: "orchestrator-state",
      text: JSON.stringify(state),
    });

    // Assert
    expect(errors).toContain(
      "Checkpoint delegation_receipts.promotion contains unsupported key: " +
        "unexpected_key",
    );
  });
});
