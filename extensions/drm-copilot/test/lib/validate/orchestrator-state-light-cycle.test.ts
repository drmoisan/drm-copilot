import { describe, expect, it } from "@jest/globals";

import { validateLightCycles } from "../../../src/lib/validate/orchestrator-state-light-cycle";

/**
 * Unit tests for invariant 8, the light-remediation rule (issue #1097).
 *
 * `validateLightCycles` is pure, so every test calls it directly with
 * in-memory cycles and review outcomes and a local stand-in for the R11
 * predicate it receives as a seam; no module is mocked. The real predicate and
 * the invariant 2 exemption run through the shared corpus in
 * `orchestrator-state-remediation-loop-parity.test.ts`.
 */

const PREFIX = "Checkpoint remediation cycle #0 remediation_path is light but";

/**
 * Stand in for the R11 predicate: an in-range index of a
 * `REMEDIATION_REQUIRED` outcome object.
 *
 * @param openedByReview The cycle's `opened_by_review` value.
 * @param outcomes The raw `review_outcomes` value.
 * @returns True when the index names such an outcome.
 */
function opensReview(openedByReview: unknown, outcomes: unknown): boolean {
  if (typeof openedByReview !== "number" || !Array.isArray(outcomes)) {
    return false;
  }
  const target: unknown = outcomes[openedByReview];
  return (
    typeof target === "object" &&
    target !== null &&
    (target as Record<string, unknown>)["verdict"] === "REMEDIATION_REQUIRED"
  );
}

/**
 * Build a one-entry `review_outcomes` list opened by `REMEDIATION_REQUIRED`.
 *
 * @param findings The outcome's findings value.
 * @returns The outcomes list.
 */
function outcomesWith(findings: unknown): unknown[] {
  return [{ verdict: "REMEDIATION_REQUIRED", findings }];
}

/**
 * Build a light cycle opened by review 0.
 *
 * @param extra Keys to add or override.
 * @returns The cycle object.
 */
function lightCycle(
  extra: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    plan_path: "docs/features/active/x/remediation-inputs.md",
    remediation_path: "light",
    opened_by_review: 0,
    execution_status: "complete",
    ...extra,
  };
}

const CONTAINED = { remediability: "autonomous", scope: "contained" };

describe("validateLightCycles (issue #1097)", () => {
  it("reports nothing for a valid light cycle", () => {
    // Arrange
    const outcomes = outcomesWith([CONTAINED, CONTAINED, CONTAINED]);

    // Act
    const errors = validateLightCycles([lightCycle()], outcomes, opensReview);

    // Assert
    expect(errors).toEqual([]);
  });

  it("reports nothing for a full cycle", () => {
    // Arrange: a full cycle with a preflight and no valid opening review.
    const cycles = [
      { plan_path: "p", remediation_path: "full", preflight: {} },
    ];

    // Act
    const errors = validateLightCycles(cycles, null, opensReview);

    // Assert
    expect(errors).toEqual([]);
  });

  it("reports nothing when the key is absent", () => {
    // Arrange
    const cycles = [{ plan_path: "p", preflight: { final_status: "x" } }];

    // Act
    const withCycle = validateLightCycles(cycles, null, opensReview);
    const withoutCycles = validateLightCycles(null, null, opensReview);

    // Assert
    expect(withCycle).toEqual([]);
    expect(withoutCycles).toEqual([]);
  });

  it("reports both finding rules for a non-object finding", () => {
    // Act
    const errors = validateLightCycles(
      [lightCycle()],
      outcomesWith(["not-an-object"]),
      opensReview,
    );

    // Assert
    expect(errors).toEqual([
      `${PREFIX} finding #0 is not autonomous.`,
      `${PREFIX} finding #0 scope is not contained.`,
    ]);
  });

  it("counts non-list findings as empty", () => {
    // Act: R9b reports the shape; invariant 8 counts no finding.
    const errors = validateLightCycles(
      [lightCycle()],
      outcomesWith("none"),
      opensReview,
    );

    // Assert
    expect(errors).toEqual([]);
  });

  it("ignores a non-object prior cycle", () => {
    // Act: a string cycle before a light cycle.
    const errors = validateLightCycles(
      ["light", lightCycle()],
      outcomesWith([CONTAINED]),
      opensReview,
    );

    // Assert
    expect(errors).toEqual([]);
  });
});
