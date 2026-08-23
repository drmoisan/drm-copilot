/** Result and terminal-status transitions for version-2 remediation state. */

import {
  REMEDIATION_CYCLES_KEY,
  REMEDIATION_STAGNATION_ERROR,
  REMEDIATION_STATUSES,
  REMEDIATION_TRANSITION_ERROR,
  codedError,
  isFingerprint,
  isObject,
  isPositiveInteger,
} from "./orchestrator-state-remediation-schema";

const NON_ACTIONABLE_STATUS_BY_ACTION: Readonly<Record<string, string>> = {
  NO_CANDIDATE: "blocked_no_candidate",
  EXTERNAL_RUNTIME: "blocked_external_runtime",
  AWAITING_CI: "awaiting_ci",
  HUMAN_DECISION: "blocked_human_decision",
};
const FALSE_CANDIDATE_STATUS_BY_DISPOSITION: Readonly<Record<string, string>> =
  {
    no_candidate: "blocked_no_candidate",
    external_runtime: "blocked_external_runtime",
    awaiting_ci: "awaiting_ci",
    human_decision: "blocked_human_decision",
    execution_failed: "blocked_no_candidate",
  };

function transitionError(subject: string, requirement: string): string {
  return codedError(REMEDIATION_TRANSITION_ERROR, subject, requirement);
}

function stagnationError(subject: string, requirement: string): string {
  return codedError(REMEDIATION_STAGNATION_ERROR, subject, requirement);
}

/** Validate completed review verdict, action, and blocker tuples. */
export function validateReviewTransitions(
  loop: Record<string, unknown>,
): string[] {
  const cycles = loop[REMEDIATION_CYCLES_KEY];
  if (!Array.isArray(cycles)) return [];
  const errors: string[] = [];
  cycles.forEach((value, index) => {
    if (!isObject(value)) return;
    const verdict = value["review_verdict"];
    const action = value["remediation_action"];
    const blockingCount = value["blocking_count"];
    const fingerprintBefore = value["blocker_fingerprint_before"];
    const fingerprintAfter = value["blocker_fingerprint_after"];
    const subject = `remediation_loop.cycles[${index}]`;
    if (!isFingerprint(fingerprintBefore)) {
      errors.push(
        transitionError(
          `${subject}.blocker_fingerprint_before`,
          "must identify the actionable source review",
        ),
      );
    }
    if (verdict === "PASS") {
      if (action !== "NONE") {
        errors.push(
          transitionError(subject, "PASS requires remediation_action NONE"),
        );
      }
      if (fingerprintAfter !== "NONE" || blockingCount !== 0) {
        errors.push(
          transitionError(
            subject,
            "PASS requires fingerprint NONE and blocking_count 0",
          ),
        );
      }
    } else if (verdict === "BLOCKED") {
      if (
        typeof action !== "string" ||
        (action !== "AUTONOMOUS" &&
          NON_ACTIONABLE_STATUS_BY_ACTION[action] === undefined)
      ) {
        errors.push(
          transitionError(
            subject,
            "BLOCKED requires a documented blocked remediation action",
          ),
        );
      }
      if (
        !isFingerprint(fingerprintAfter) ||
        !isPositiveInteger(blockingCount)
      ) {
        errors.push(
          transitionError(
            subject,
            "BLOCKED requires a fingerprint and positive blocking_count",
          ),
        );
      }
    }
  });
  return errors;
}

/** Stop unchanged blockers unless one exact consumed exception authorizes them. */
export function validateStagnation(
  loop: Record<string, unknown>,
  authorizedCycleIndices: ReadonlySet<number>,
): string[] {
  const cycles = loop[REMEDIATION_CYCLES_KEY];
  const attempts = loop["attempts"];
  if (!Array.isArray(cycles) || !Array.isArray(attempts)) return [];
  const errors: string[] = [];
  cycles.forEach((value, index) => {
    if (!isObject(value) || value["review_verdict"] !== "BLOCKED") return;
    const before = value["blocker_fingerprint_before"];
    const after = value["blocker_fingerprint_after"];
    if (!isFingerprint(before) || !isFingerprint(after)) return;
    const unchanged = before === after;
    const attemptId = value["attempt_id"];
    const laterAttempt =
      isPositiveInteger(attemptId) && attempts.length > attemptId;
    const laterCycle = index < cycles.length - 1;
    const authorized = authorizedCycleIndices.has(index);
    if (unchanged && (laterAttempt || laterCycle) && !authorized) {
      errors.push(
        stagnationError(
          `remediation_loop.cycles[${index}]`,
          "unchanged blockers forbid another attempt or cycle",
        ),
      );
    } else if (index === cycles.length - 1 && !authorized) {
      const status = loop["status"];
      if (unchanged && status !== "blocked_stagnation") {
        errors.push(
          stagnationError(
            "remediation_loop.status",
            "must be blocked_stagnation for unchanged blockers",
          ),
        );
      } else if (!unchanged && status === "blocked_stagnation") {
        errors.push(
          stagnationError(
            "remediation_loop.status",
            "cannot be blocked_stagnation for changed blockers",
          ),
        );
      }
    }
  });
  return errors;
}

function allowedTerminalStatuses(loop: Record<string, unknown>): Set<string> {
  const cycles = loop[REMEDIATION_CYCLES_KEY];
  const attempts = loop["attempts"];
  if (!Array.isArray(cycles) || !Array.isArray(attempts)) {
    return new Set(REMEDIATION_STATUSES);
  }
  const referencedIds = new Set(
    cycles
      .filter(isObject)
      .map((cycle) => cycle["attempt_id"])
      .filter(isPositiveInteger),
  );
  const lastAttempt = attempts.at(-1);
  if (isObject(lastAttempt)) {
    const lastAttemptId = lastAttempt["attempt_id"];
    if (
      !isPositiveInteger(lastAttemptId) ||
      !referencedIds.has(lastAttemptId)
    ) {
      if (lastAttempt["candidate_applied"] === true) return new Set(["active"]);
      const disposition = lastAttempt["terminal_disposition"];
      const expected =
        typeof disposition === "string"
          ? FALSE_CANDIDATE_STATUS_BY_DISPOSITION[disposition]
          : undefined;
      return expected === undefined ? new Set() : new Set([expected]);
    }
  }
  const lastCycle = cycles.at(-1);
  if (isObject(lastCycle)) {
    const verdict = lastCycle["review_verdict"];
    const action = lastCycle["remediation_action"];
    if (verdict === "PASS" && action === "NONE") return new Set(["resolved"]);
    const nonActionable =
      typeof action === "string"
        ? NON_ACTIONABLE_STATUS_BY_ACTION[action]
        : undefined;
    if (verdict === "BLOCKED" && nonActionable !== undefined) {
      return new Set([nonActionable, "blocked_stagnation"]);
    }
    if (verdict === "BLOCKED" && action === "AUTONOMOUS") {
      return loop["completed_cycle_count"] === 3 &&
        loop["max_completed_cycles"] === 3
        ? new Set(["blocked_stagnation", "blocked_remediation_loop_limit"])
        : new Set(["active", "blocked_stagnation"]);
    }
    return new Set();
  }
  return new Set([
    "idle",
    "active",
    "awaiting_ci",
    "blocked_no_candidate",
    "blocked_external_runtime",
    "blocked_human_decision",
    "resolved",
  ]);
}

/** Validate that loop status exactly represents the latest recorded outcome. */
export function validateLoopTransition(
  loop: Record<string, unknown>,
): string[] {
  const status = loop["status"];
  if (typeof status !== "string" || !REMEDIATION_STATUSES.has(status))
    return [];
  if (allowedTerminalStatuses(loop).has(status)) return [];
  return [
    transitionError(
      "remediation_loop.status",
      `${status} does not match the latest remediation outcome`,
    ),
  ];
}
