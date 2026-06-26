import { describe, expect, it } from "@jest/globals";

import { validateRemediationLoop } from "../../../src/lib/validate/orchestrator-state-remediation";

/** Return a single well-formed remediation cycle for mutation. */
function buildCycle(): Record<string, unknown> {
  return {
    plan_path: "docs/features/active/feature-1/remediation-1.plan.md",
    execution_status: "complete",
    preflight: { final_status: "clear" },
    exit_condition_met: true,
    blocking_count: 0,
  };
}

describe("validateRemediationLoop", () => {
  it("returns no errors for a non-object remediation_loop", () => {
    // Arrange / Act / Assert
    expect(validateRemediationLoop("nope")).toEqual([]);
  });

  it("returns no errors when cycles is not a list", () => {
    // Arrange / Act / Assert
    expect(validateRemediationLoop({ cycles: "nope" })).toEqual([]);
  });

  it("returns no errors for a well-formed cycle", () => {
    // Arrange / Act / Assert
    expect(validateRemediationLoop({ cycles: [buildCycle()] })).toEqual([]);
  });

  it("reports a non-object cycle with its indexed error", () => {
    // Arrange / Act
    const errors = validateRemediationLoop({ cycles: ["not-a-cycle"] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 must be an object.",
    );
  });

  it("reports an empty plan_path", () => {
    // Arrange
    const cycle = { ...buildCycle(), plan_path: "" };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 plan_path must be a non-empty string.",
    );
  });

  it("reports a whitespace-only plan_path", () => {
    // Arrange
    const cycle = { ...buildCycle(), plan_path: "   " };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 plan_path must be a non-empty string.",
    );
  });

  it("reports a non-string plan_path", () => {
    // Arrange
    const cycle = { ...buildCycle(), plan_path: 5 };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 plan_path must be a non-empty string.",
    );
  });

  it("reports execution_status in the blocked set with a non-clear preflight", () => {
    // Arrange
    const cycle = {
      ...buildCycle(),
      preflight: { final_status: "pending" },
    };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 execution_status is " +
        "complete but preflight.final_status is not 'clear'.",
    );
  });

  it("reports execution_status in the blocked set with an absent preflight", () => {
    // Arrange
    const cycle = { ...buildCycle() };
    delete cycle["preflight"];

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 execution_status is " +
        "complete but preflight.final_status is not 'clear'.",
    );
  });

  it("reports execution_status in the blocked set with a non-object preflight", () => {
    // Arrange
    const cycle = { ...buildCycle(), preflight: "clear" };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 execution_status is " +
        "complete but preflight.final_status is not 'clear'.",
    );
  });

  it("accepts execution_status in the blocked set with a clear preflight", () => {
    // Arrange / Act / Assert
    expect(validateRemediationLoop({ cycles: [buildCycle()] })).toEqual([]);
  });

  it("reports exit_condition_met true with a non-zero blocking_count", () => {
    // Arrange
    const cycle = { ...buildCycle(), blocking_count: 2 };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycle] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 exit_condition_met is true " +
        "but blocking_count is not 0.",
    );
  });

  it("accepts exit_condition_met true with a zero blocking_count", () => {
    // Arrange / Act / Assert: the well-formed cycle already has count 0.
    expect(validateRemediationLoop({ cycles: [buildCycle()] })).toEqual([]);
  });

  it("validates multiple malformed cycles independently", () => {
    // Arrange: one missing plan_path, one with a non-zero blocking count.
    const cycleA = { ...buildCycle(), plan_path: "" };
    const cycleB = { ...buildCycle(), blocking_count: 1 };

    // Act
    const errors = validateRemediationLoop({ cycles: [cycleA, cycleB] });

    // Assert
    expect(errors).toContain(
      "Checkpoint remediation cycle #0 plan_path must be a non-empty string.",
    );
    expect(errors).toContain(
      "Checkpoint remediation cycle #1 exit_condition_met is true " +
        "but blocking_count is not 0.",
    );
  });
});
