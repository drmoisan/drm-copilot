import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  canonicalBlockerFingerprint,
  validateRemediationLoop,
} from "../../../src/lib/validate/orchestrator-state-remediation";

const BLOCKER_FINGERPRINT_A = `sha256:${"a".repeat(64)}`;
const BLOCKER_FINGERPRINT_B = `sha256:${"b".repeat(64)}`;
const ROUTING_POLICY_SHA256 = `sha256:${"c".repeat(64)}`;
const SHARED_FIXTURE_DIR = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "orchestration",
  "remediation-loop-v2",
);

/** Load committed shared fixtures in stable file-name order. */
function loadSharedFixtures(): ReadonlyArray<Record<string, unknown>> {
  return fs
    .readdirSync(SHARED_FIXTURE_DIR)
    .filter((fileName) => fileName.endsWith(".json"))
    .sort((left, right) => left.localeCompare(right))
    .map((fileName) => {
      const parsed: unknown = JSON.parse(
        fs.readFileSync(path.join(SHARED_FIXTURE_DIR, fileName), "utf8"),
      );
      if (
        typeof parsed !== "object" ||
        parsed === null ||
        Array.isArray(parsed)
      ) {
        throw new Error(`${fileName} must contain a JSON object.`);
      }
      return parsed as Record<string, unknown>;
    });
}

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

function buildAttempt(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    attempt_id: 1,
    source_review_fingerprint: BLOCKER_FINGERPRINT_A,
    plan_path: "plan-1.md",
    preflight: { final_status: "clear" },
    execution_status: "complete",
    candidate_applied: true,
    terminal_disposition: "candidate_applied",
    started_at: "2026-08-17T12:01:00Z",
    finished_at: "2026-08-17T12:01:30Z",
    exception_binding: null,
    ...overrides,
  };
}

function buildVersionedCycle(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    cycle_id: 1,
    attempt_id: 1,
    commit_sha: "commit-1",
    re_audit_path: "audit-1.md",
    review_verdict: "PASS",
    remediation_action: "NONE",
    blocker_fingerprint_before: BLOCKER_FINGERPRINT_A,
    blocker_fingerprint_after: "NONE",
    blocking_count: 0,
    exit_condition_met: true,
    completed_at: "2026-08-17T13:01:00Z",
    ...overrides,
  };
}

function buildVersionedLoop(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  const attempts = Array.isArray(overrides["attempts"])
    ? overrides["attempts"]
    : [];
  const cycles = Array.isArray(overrides["cycles"]) ? overrides["cycles"] : [];
  return {
    schema_version: 2,
    status: "resolved",
    max_completed_cycles: 3,
    attempt_count: attempts.length,
    completed_cycle_count: cycles.length,
    last_blocker_fingerprint: BLOCKER_FINGERPRINT_A,
    attempts,
    cycles,
    ...overrides,
  };
}

function buildExceptionBinding(attemptId: number): Record<string, unknown> {
  return {
    exception_id: "exception-1",
    issue_number: "1",
    blocker_fingerprint: BLOCKER_FINGERPRINT_A,
    routing_policy_sha256: ROUTING_POLICY_SHA256,
    allowed_transition: "blocked_stagnation_to_active",
    single_use: true,
    consumed_at: "2026-08-17T14:00:00Z",
    consumed_by_attempt_id: attemptId,
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

  it("reports a missing active version-2 cycles array", () => {
    const loop = buildVersionedLoop({ status: "active" });
    delete loop["cycles"];

    expect(validateRemediationLoop(loop)).toEqual([
      "ORCH_REMEDIATION_SCHEMA: remediation_loop missing required field: cycles.",
    ]);
  });

  it("keeps non-actionable reviews outside completed cycles", () => {
    const valid = buildVersionedLoop({ status: "blocked_external_runtime" });
    const invalid = buildVersionedLoop({
      status: "blocked_external_runtime",
      cycles: [
        buildVersionedCycle({
          review_verdict: "BLOCKED",
          remediation_action: "EXTERNAL_RUNTIME",
          blocker_fingerprint_after: BLOCKER_FINGERPRINT_B,
          blocking_count: 1,
          exit_condition_met: false,
        }),
      ],
    });

    expect(validateRemediationLoop(valid)).toEqual([]);
    expect(validateRemediationLoop(invalid)).toEqual([
      "ORCH_REMEDIATION_TRANSITION: remediation_loop.cycles[0].attempt_id references missing attempt 1.",
    ]);
  });

  it("rejects a completed cycle for a false-candidate attempt", () => {
    const attempt = buildAttempt({
      candidate_applied: false,
      terminal_disposition: "no_candidate",
    });
    const valid = buildVersionedLoop({
      status: "blocked_no_candidate",
      attempts: [attempt],
    });
    const invalid = buildVersionedLoop({
      status: "blocked_no_candidate",
      attempts: [attempt],
      cycles: [
        buildVersionedCycle({
          review_verdict: "BLOCKED",
          remediation_action: "NO_CANDIDATE",
          blocker_fingerprint_after: BLOCKER_FINGERPRINT_B,
          blocking_count: 1,
          exit_condition_met: false,
        }),
      ],
    });

    expect(validateRemediationLoop(valid)).toEqual([]);
    expect(validateRemediationLoop(invalid)).toEqual([
      "ORCH_REMEDIATION_TRANSITION: remediation_loop.cycles[0].attempt_id candidate_applied must be true.",
    ]);
  });

  it("reports count and identifier sequence failures in Python order", () => {
    const loop = buildVersionedLoop({
      attempts: [buildAttempt({ attempt_id: 2 })],
      cycles: [buildVersionedCycle({ cycle_id: 2, attempt_id: 2 })],
      attempt_count: 2,
      completed_cycle_count: 2,
    });

    expect(validateRemediationLoop(loop)).toEqual([
      "ORCH_REMEDIATION_COUNT: remediation_loop.attempt_count must equal attempts length 1.",
      "ORCH_REMEDIATION_SEQUENCE: remediation_loop attempt_id sequence must be [1]; received [2].",
      "ORCH_REMEDIATION_COUNT: remediation_loop.completed_cycle_count must equal cycles length 1.",
      "ORCH_REMEDIATION_SEQUENCE: remediation_loop cycle_id sequence must be [1]; received [2].",
    ]);
  });

  it("computes the exact canonical blocker fingerprint independent of order", () => {
    const findings = [
      {
        audit_kind: " code ",
        rule_id: " R2 ",
        path: "C:\\repo\\src\\b.ts",
        message: "Second   issue",
        timestamp: "ignored",
      },
      {
        audit_kind: "policy",
        rule_id: "R1",
        path: "./docs/a.md",
        message: " First issue ",
      },
    ];
    const expected =
      "sha256:47e5c5c2d3442f47a1d6f4c6f21d404df4ba7f96fe59fde2588592a8caf862e1";

    expect(canonicalBlockerFingerprint(findings, "C:/repo")).toBe(expected);
    expect(
      canonicalBlockerFingerprint([...findings].reverse(), "C:/repo"),
    ).toBe(expected);
  });

  it("requires blocked_stagnation for an unchanged blocker fingerprint", () => {
    const attempt = buildAttempt();
    const cycle = buildVersionedCycle({
      review_verdict: "BLOCKED",
      remediation_action: "AUTONOMOUS",
      blocker_fingerprint_after: BLOCKER_FINGERPRINT_A,
      blocking_count: 1,
      exit_condition_met: false,
    });
    const invalid = buildVersionedLoop({
      status: "active",
      attempts: [attempt],
      cycles: [cycle],
    });
    const valid = buildVersionedLoop({
      status: "blocked_stagnation",
      attempts: [attempt],
      cycles: [cycle],
    });

    expect(validateRemediationLoop(invalid)).toEqual([
      "ORCH_REMEDIATION_STAGNATION: remediation_loop.status must be blocked_stagnation for unchanged blockers.",
    ]);
    expect(validateRemediationLoop(valid)).toEqual([]);
  });

  it("rejects a reused single-use exception in deterministic order", () => {
    const firstAttempt = buildAttempt();
    const firstCycle = buildVersionedCycle({
      review_verdict: "BLOCKED",
      remediation_action: "AUTONOMOUS",
      blocker_fingerprint_after: BLOCKER_FINGERPRINT_A,
      blocking_count: 1,
      exit_condition_met: false,
    });
    const secondAttempt = buildAttempt({
      attempt_id: 2,
      exception_binding: buildExceptionBinding(2),
    });
    const context = {
      issueNumber: "1",
      routingPolicySha256: ROUTING_POLICY_SHA256,
    };
    expect(
      validateRemediationLoop(
        buildVersionedLoop({
          status: "active",
          attempts: [firstAttempt, secondAttempt],
          cycles: [firstCycle],
        }),
        context,
      ),
    ).toEqual([]);

    const errors = validateRemediationLoop(
      buildVersionedLoop({
        status: "active",
        attempts: [
          firstAttempt,
          secondAttempt,
          buildAttempt({
            attempt_id: 3,
            exception_binding: buildExceptionBinding(3),
          }),
        ],
        cycles: [
          firstCycle,
          buildVersionedCycle({
            cycle_id: 2,
            attempt_id: 2,
            review_verdict: "BLOCKED",
            remediation_action: "AUTONOMOUS",
            blocker_fingerprint_after: BLOCKER_FINGERPRINT_A,
            blocking_count: 1,
            exit_condition_met: false,
          }),
        ],
      }),
      context,
    );
    expect(errors).toEqual([
      "ORCH_EXCEPTION_BINDING_REUSED: exception_id exception-1 must be consumed only once.",
      "ORCH_REMEDIATION_STAGNATION: remediation_loop.cycles[0] unchanged blockers forbid another attempt or cycle.",
      "ORCH_REMEDIATION_STAGNATION: remediation_loop.cycles[1] unchanged blockers forbid another attempt or cycle.",
    ]);
  });

  it("preserves legacy reads and rejects strict legacy mutation", () => {
    const legacy = { cycles: [buildCycle()] };

    expect(validateRemediationLoop(legacy)).toEqual([]);
    expect(validateRemediationLoop(legacy, { strict: true })).toEqual([
      "ORCH_REMEDIATION_SCHEMA: legacy remediation_loop requires evidence-backed schema version 2 migration before strict validation.",
    ]);
  });

  it.each(loadSharedFixtures())(
    "matches shared byte-stable result $name",
    (fixture) => {
      const name = fixture["name"];
      const expectedErrors = fixture["expected_errors"];
      if (typeof name !== "string" || !Array.isArray(expectedErrors)) {
        throw new Error(
          "Shared remediation fixture has an invalid result shape.",
        );
      }

      const errors = validateRemediationLoop(fixture["loop"]);
      expect(expectedErrors.every((error) => typeof error === "string")).toBe(
        true,
      );
      expect(errors).toEqual(expectedErrors);
      expect(JSON.stringify({ name, errors })).toBe(
        fixture["expected_normalized"],
      );
    },
  );
});
