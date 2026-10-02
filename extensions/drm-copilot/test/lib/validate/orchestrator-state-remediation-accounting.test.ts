import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { NON_MECHANICAL_BLOCKED_REASONS } from "../../../src/lib/validate/orchestrator-state-blocked-reason";
import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";
import {
  CANDIDATE_APPLIED_KEY,
  COMPLETED_ATTEMPTS_KEY,
  HALT_CLASSES,
  NON_REMEDIABLE_CLASSES,
  OPENED_BY_REVIEW_KEY,
  REMEDIABILITY_CLASSES,
  REVIEW_OUTCOMES_KEY,
  REVIEW_VERDICTS,
  deriveReviewVerdict,
} from "../../../src/lib/validate/orchestrator-state-remediation";

/**
 * Unit tests for remediation-loop verdict accounting (issue #484, R5-R11).
 *
 * Covers `deriveReviewVerdict` over every subset of the five remediability
 * classes, the vocabulary constants, the drift guard against the #523
 * non-mechanical `blocked_reason` partition, and each new invariant driven
 * through `validateOrchestratorStateText`. Expected messages are written
 * locally from the spec message table. The base checkpoint is read in place
 * from a committed corpus file; no temporary file is created.
 */

const SPEC_VERDICTS = [
  "PASS",
  "REMEDIATION_REQUIRED",
  "HALT_NON_REMEDIABLE",
  "AWAITING_CI",
];
const SPEC_CLASSES = [
  "autonomous",
  "external_dependency",
  "policy_hold",
  "awaiting_ci",
  "human_decision_required",
];
const SPEC_HALT = new Set([
  "external_dependency",
  "policy_hold",
  "human_decision_required",
]);

/** Committed corpus file whose checkpoint is a clean small-route state. */
const BASE_FIXTURE = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "orchestrator_state_remediation_loop",
  "verdict_pass_valid.json",
);

/** Return a fresh copy of the clean base checkpoint. */
function baseState(): Record<string, unknown> {
  const parsed = JSON.parse(fs.readFileSync(BASE_FIXTURE, "utf8")) as {
    checkpoint: Record<string, unknown>;
  };
  return parsed.checkpoint;
}

/** Valid legacy cycle with the given changes applied. */
function vc(changes: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    entry_timestamp: "2026-09-29T00-00",
    inputs_path:
      "docs/features/active/example/remediation-inputs.2026-09-29T00-00.md",
    plan_path:
      "docs/features/active/example/remediation-plan.2026-09-29T00-00.md",
    preflight: { iterations: 1, final_status: "clear" },
    execution_status: "complete",
    audit_paths: [],
    blocking_count: 1,
    exit_condition_met: false,
    ...changes,
  };
}

/** Review outcome whose findings carry the given classes. */
function outcome(
  verdict: unknown,
  ...classes: unknown[]
): Record<string, unknown> {
  return { verdict, findings: classes.map((c) => ({ remediability: c })) };
}

const RR = outcome("REMEDIATION_REQUIRED", "autonomous");
const HALT = outcome("HALT_NON_REMEDIABLE", "external_dependency");
const WAIT = outcome("AWAITING_CI", "awaiting_ci");
const PASSV = outcome("PASS");

const r5 = (i: number): string =>
  `Checkpoint remediation cycle #${i} candidate_applied must be a boolean.`;
const r6 = (i: number): string =>
  `Checkpoint remediation cycle #${i} candidate_applied is true but execution_status is not 'complete'.`;
const R7A =
  "Checkpoint remediation_loop completed_attempts must be a non-negative integer.";
const r7b = (n: number, k: number): string =>
  `Checkpoint remediation_loop completed_attempts is ${n} but ${k} cycles have candidate_applied true.`;
const R8A = "Checkpoint remediation_loop review_outcomes must be a list.";
const r8b = (j: number): string =>
  `Checkpoint remediation review outcome #${j} must be an object.`;
const r9a = (j: number, v: string): string =>
  `Checkpoint remediation review outcome #${j} verdict must be one of PASS, REMEDIATION_REQUIRED, HALT_NON_REMEDIABLE, AWAITING_CI; got: ${v}`;
const r9b = (j: number): string =>
  `Checkpoint remediation review outcome #${j} findings must be a list.`;
const r9c = (j: number, m: number): string =>
  `Checkpoint remediation review outcome #${j} finding #${m} must be an object.`;
const r9d = (j: number, m: number, v: string): string =>
  `Checkpoint remediation review outcome #${j} finding #${m} remediability must be one of autonomous, external_dependency, policy_hold, awaiting_ci, human_decision_required; got: ${v}`;
const r10 = (j: number, v: string, e: string): string =>
  `Checkpoint remediation review outcome #${j} verdict ${v} does not match its findings (expected ${e}).`;
const r11 = (i: number): string =>
  `Checkpoint remediation cycle #${i} opened_by_review must reference a review outcome whose verdict is REMEDIATION_REQUIRED.`;

/** Spec-ordered verdict derivation used as the test oracle. */
function specVerdict(classes: readonly string[]): string {
  if (classes.length === 0) return "PASS";
  if (classes.includes("autonomous")) return "REMEDIATION_REQUIRED";
  if (classes.some((c) => SPEC_HALT.has(c))) return "HALT_NON_REMEDIABLE";
  return "AWAITING_CI";
}

/** Validate the base state carrying `loop`; keep remediation-family errors. */
function loopErrors(loop: unknown): string[] {
  const state = baseState();
  state["remediation_loop"] = loop;
  return validateOrchestratorStateText(JSON.stringify(state)).filter((e) =>
    e.includes("remediation"),
  );
}

/** All 32 subsets of the five classes, in bitmask order. */
const SUBSETS: readonly (readonly string[])[] = Array.from(
  { length: 1 << SPEC_CLASSES.length },
  (_, mask) => SPEC_CLASSES.filter((_c, bit) => (mask & (1 << bit)) !== 0),
);

describe("deriveReviewVerdict", () => {
  it.each(SUBSETS.map((s) => [s.join("+") || "empty", s] as const))(
    "derives the spec verdict for subset %s",
    (_label, classes) => {
      expect(deriveReviewVerdict(classes)).toBe(specVerdict(classes));
    },
  );

  it("covers all 32 subsets", () => {
    expect(SUBSETS).toHaveLength(32);
  });

  it.each([
    [["awaiting_ci", "awaiting_ci"], "AWAITING_CI"],
    [["policy_hold", "policy_hold"], "HALT_NON_REMEDIABLE"],
    [["autonomous", "autonomous", "policy_hold"], "REMEDIATION_REQUIRED"],
  ] as const)("ignores duplicate classes in %j", (classes, expected) => {
    expect(deriveReviewVerdict(classes)).toBe(expected);
  });

  it.each([["Autonomous"], ["PASS"], [""], ["autonomous", "AWAITING_CI"]])(
    "throws a prefixed RangeError for non-member input %j",
    (...classes: string[]) => {
      expect(() => deriveReviewVerdict(classes)).toThrow(RangeError);
      expect(() => deriveReviewVerdict(classes)).toThrow(
        /^invalid remediability: /,
      );
    },
  );
});

describe("remediation vocabulary constants", () => {
  it("matches the spec tables", () => {
    expect(REVIEW_OUTCOMES_KEY).toBe("review_outcomes");
    expect(COMPLETED_ATTEMPTS_KEY).toBe("completed_attempts");
    expect(CANDIDATE_APPLIED_KEY).toBe("candidate_applied");
    expect(OPENED_BY_REVIEW_KEY).toBe("opened_by_review");
    expect([...REVIEW_VERDICTS]).toEqual(SPEC_VERDICTS);
    expect([...REMEDIABILITY_CLASSES]).toEqual(SPEC_CLASSES);
    expect([...NON_REMEDIABLE_CLASSES].sort()).toEqual(
      SPEC_CLASSES.slice(1).sort(),
    );
    expect([...HALT_CLASSES].sort()).toEqual([...SPEC_HALT].sort());
  });

  it("keeps every non-remediable class inside NON_MECHANICAL_BLOCKED_REASONS", () => {
    const missing = [...NON_REMEDIABLE_CLASSES].filter(
      (c) => !NON_MECHANICAL_BLOCKED_REASONS.has(c),
    );
    expect(missing).toEqual([]);
  });
});

describe("remediation-loop invariants R5-R11", () => {
  it.each([
    ["string", vc({ candidate_applied: "yes" }), [r5(0)]],
    ["integer-one", vc({ candidate_applied: 1 }), [r5(0)]],
    ["null", vc({ candidate_applied: null }), [r5(0)]],
    ["true-complete", vc({ candidate_applied: true }), []],
    [
      "false-failed",
      vc({ candidate_applied: false, execution_status: "failed" }),
      [],
    ],
    [
      "true-failed",
      vc({ candidate_applied: true, execution_status: "failed" }),
      [r6(0)],
    ],
  ] as const)(
    "applies R5 and R6 to candidate_applied (%s)",
    (_l, cycle, expected) => {
      expect(loopErrors({ cycles: [cycle] })).toEqual(expected);
    },
  );

  it.each([
    ["negative", { completed_attempts: -1 }, [R7A]],
    ["boolean", { completed_attempts: true }, [R7A]],
    ["string", { completed_attempts: "1" }, [R7A]],
    ["null", { completed_attempts: null }, [R7A]],
    [
      "mismatch",
      { completed_attempts: 2, cycles: [vc({ candidate_applied: true })] },
      [r7b(2, 1)],
    ],
    ["zero-no-cycles", { completed_attempts: 0 }, []],
    ["positive-no-cycles", { completed_attempts: 1 }, [r7b(1, 0)]],
    ["cycles-not-list", { completed_attempts: 1, cycles: "none" }, [r7b(1, 0)]],
  ] as const)(
    "applies R7a and R7b to completed_attempts (%s)",
    (_l, loop, expected) => {
      expect(loopErrors(loop)).toEqual(expected);
    },
  );

  it.each([
    ["outcomes-string", "PASS", [R8A]],
    ["outcomes-object", { verdict: "PASS" }, [R8A]],
    ["outcome-integer", [7], [r8b(0)]],
    ["outcome-null-skipped", [null, PASSV], [r8b(0)]],
    ["verdict-case-variant", [outcome("Pass")], [r9a(0, "Pass")]],
    ["verdict-integer", [outcome(7)], [r9a(0, "7")]],
    ["verdict-null", [outcome(null)], [r9a(0, "None")]],
    ["findings-missing", [{ verdict: "PASS" }], [r9b(0)]],
    [
      "verdict-and-findings-invalid",
      [{ verdict: "x", findings: "y" }],
      [r9a(0, "x"), r9b(0)],
    ],
    [
      "finding-integer",
      [{ verdict: "REMEDIATION_REQUIRED", findings: [7] }],
      [r9c(0, 0)],
    ],
    [
      "finding-errors-in-order",
      [
        {
          verdict: "REMEDIATION_REQUIRED",
          findings: [7, { remediability: "bad" }],
        },
      ],
      [r9c(0, 0), r9d(0, 1, "bad")],
    ],
    [
      "remediability-null",
      [outcome("REMEDIATION_REQUIRED", null)],
      [r9d(0, 0, "None")],
    ],
    [
      "remediability-integer",
      [outcome("REMEDIATION_REQUIRED", 7)],
      [r9d(0, 0, "7")],
    ],
    [
      "empty-findings-non-pass",
      [{ verdict: "REMEDIATION_REQUIRED", findings: [] }],
      [r10(0, "REMEDIATION_REQUIRED", "PASS")],
    ],
  ] as const)(
    "applies R8a-R9d to review outcomes (%s)",
    (_l, outcomes, expected) => {
      expect(loopErrors({ review_outcomes: outcomes })).toEqual(expected);
    },
  );

  it.each([
    ...SPEC_VERDICTS.flatMap((v) => [
      [
        `verdict-${v}-lower`,
        outcome(v.toLowerCase()),
        [r9a(0, v.toLowerCase())],
      ] as const,
      [
        `verdict-${v}-mixed`,
        outcome(v.charAt(0) + v.slice(1).toLowerCase()),
        [r9a(0, v.charAt(0) + v.slice(1).toLowerCase())],
      ] as const,
    ]),
    ...SPEC_CLASSES.flatMap((c) => [
      [
        `class-${c}-upper`,
        outcome("REMEDIATION_REQUIRED", c.toUpperCase()),
        [r9d(0, 0, c.toUpperCase())],
      ] as const,
      [
        `class-${c}-capitalized`,
        outcome("REMEDIATION_REQUIRED", c.charAt(0).toUpperCase() + c.slice(1)),
        [r9d(0, 0, c.charAt(0).toUpperCase() + c.slice(1))],
      ] as const,
    ]),
  ])("rejects the case variant %s", (_l, variant, expected) => {
    expect(loopErrors({ review_outcomes: [variant] })).toEqual(expected);
  });

  it.each([
    ["pass-empty", outcome("PASS"), []],
    [
      "pass-autonomous",
      outcome("PASS", "autonomous"),
      [r10(0, "PASS", "REMEDIATION_REQUIRED")],
    ],
    [
      "halt-mixture",
      outcome("HALT_NON_REMEDIABLE", "policy_hold", "human_decision_required"),
      [],
    ],
    [
      "awaiting-with-external",
      outcome("AWAITING_CI", "awaiting_ci", "external_dependency"),
      [r10(0, "AWAITING_CI", "HALT_NON_REMEDIABLE")],
    ],
    [
      "awaiting-with-autonomous",
      outcome("AWAITING_CI", "autonomous", "awaiting_ci"),
      [r10(0, "AWAITING_CI", "REMEDIATION_REQUIRED")],
    ],
    [
      "halt-with-awaiting-only",
      outcome("HALT_NON_REMEDIABLE", "awaiting_ci"),
      [r10(0, "HALT_NON_REMEDIABLE", "AWAITING_CI")],
    ],
    [
      "remediation-mixed",
      outcome("REMEDIATION_REQUIRED", "autonomous", "human_decision_required"),
      [],
    ],
  ] as const)(
    "applies R10 verdict consistency (%s)",
    (_l, review, expected) => {
      expect(loopErrors({ review_outcomes: [review] })).toEqual(expected);
    },
  );

  it.each([
    ["remediation-required", [RR], 0, []],
    ["second-index", [PASSV, RR], 1, []],
    ["points-at-pass", [RR, PASSV], 1, [r11(0)]],
    ["out-of-range", [RR], 5, [r11(0)]],
    ["negative", [RR], -1, [r11(0)]],
    ["boolean", [RR], true, [r11(0)]],
    ["null", [RR], null, [r11(0)]],
    ["string", [RR], "0", [r11(0)]],
    ["halt-target", [HALT], 0, [r11(0)]],
    ["awaiting-target", [WAIT], 0, [r11(0)]],
    ["outcomes-absent", undefined, 0, [r11(0)]],
    ["outcomes-not-list", "PASS", 0, [R8A, r11(0)]],
    ["non-object-target", [7], 0, [r8b(0), r11(0)]],
  ] as const)(
    "applies R11 to opened_by_review (%s)",
    (_l, outcomes, opened, expected) => {
      const loop: Record<string, unknown> = {
        cycles: [vc({ opened_by_review: opened })],
      };
      if (outcomes !== undefined) loop["review_outcomes"] = outcomes;
      expect(loopErrors(loop)).toEqual(expected);
    },
  );

  it("orders legacy, review-outcome, per-cycle, then attempt-count errors", () => {
    // Arrange
    const loop = {
      cycles: [
        vc({ plan_path: "", candidate_applied: "yes", opened_by_review: 3 }),
        vc({ candidate_applied: true, execution_status: "failed" }),
      ],
      review_outcomes: [outcome("Pass"), { verdict: "PASS", findings: "x" }],
      completed_attempts: 5,
    };
    // Act
    const observed = loopErrors(loop);
    // Assert
    expect(observed).toEqual([
      "Checkpoint remediation cycle #0 plan_path must be a non-empty string.",
      r9a(0, "Pass"),
      r9b(1),
      r5(0),
      r11(0),
      r6(1),
      r7b(5, 1),
    ]);
  });

  it.each([
    ["legacy-cycle", { current_cycle: 0, cycles: [vc()] }],
    ["cycles-not-list", { cycles: "none" }],
    ["empty-loop", {}],
    ["loop-not-object", "active"],
  ] as const)("adds no error for a loop without new keys (%s)", (_l, loop) => {
    expect(loopErrors(loop)).toEqual([]);
  });

  it("validates a halt checkpoint without cycles cleanly", () => {
    // Arrange
    const state = baseState();
    state["blocked_reason"] = "external_dependency";
    state["remediation_loop"] = { review_outcomes: [HALT] };
    // Act
    const errors = validateOrchestratorStateText(JSON.stringify(state));
    // Assert: the full, unfiltered error list is empty.
    expect(errors).toEqual([]);
  });
});
