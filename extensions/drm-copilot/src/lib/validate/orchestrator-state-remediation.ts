/**
 * Remediation-loop invariants for orchestrator-state checkpoints.
 *
 * Purpose:
 *     Port `scripts/dev_tools/_orchestrator_state_remediation_loop.py`. Apply
 *     the three remediation-cycle invariants and the review-outcome and
 *     accounting invariants R5-R11 (issue #484) documented in
 *     `.claude/rules/orchestrator-state.md` without importing any schema file.
 *     The review-outcome vocabulary, `deriveReviewVerdict`, and R8-R10 live in
 *     `orchestrator-state-remediation-accounting.ts` and are re-exported here.
 *
 * Invariants / Constraints:
 *     - `plan_path` must be a non-empty string.
 *     - Execution may only be recorded once preflight has cleared.
 *     - A satisfied exit gate requires zero blocking findings.
 *     - R5/R6: `candidate_applied` is a boolean, and `true` requires
 *       `execution_status` `complete`.
 *     - R7: `completed_attempts` is a non-negative integer equal to the number
 *       of cycles with `candidate_applied: true`.
 *     - R8-R10: `review_outcomes` is a list of objects with a known verdict and
 *       classified findings, and each verdict matches its findings.
 *     - R11: `opened_by_review` indexes a `REMEDIATION_REQUIRED` outcome.
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

import {
  REVIEW_OUTCOMES_KEY,
  validateReviewOutcomes,
} from "./orchestrator-state-remediation-accounting";

export {
  HALT_CLASSES,
  NON_REMEDIABLE_CLASSES,
  REMEDIABILITY_CLASSES,
  REVIEW_OUTCOMES_KEY,
  REVIEW_VERDICTS,
  deriveReviewVerdict,
} from "./orchestrator-state-remediation-accounting";
export type { ReviewVerdict } from "./orchestrator-state-remediation-accounting";

/** Top-level checkpoint key for the optional remediation loop. */
export const REMEDIATION_LOOP_KEY = "remediation_loop";

/** Key holding the cycles list inside the remediation loop. */
export const REMEDIATION_CYCLES_KEY = "cycles";

/**
 * Execution statuses that may only be recorded once a cycle's preflight gate has
 * cleared; recording any of these before preflight clears is a malformed cycle.
 */
export const EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT: ReadonlySet<string> =
  new Set(["in_progress", "complete", "failed"]);

/** The preflight final status that clears the execution gate. */
export const PREFLIGHT_CLEARED_STATUS = "clear";

/** Key holding the completed-attempt count inside the remediation loop. */
export const COMPLETED_ATTEMPTS_KEY = "completed_attempts";

/** Cycle key marking a completed remediation attempt. */
export const CANDIDATE_APPLIED_KEY = "candidate_applied";

/** Cycle key holding the zero-based index of the review that opened it. */
export const OPENED_BY_REVIEW_KEY = "opened_by_review";

/** The execution status that a completed attempt requires. */
const COMPLETED_EXECUTION_STATUS = "complete";

/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Type guard for an integer that is not a boolean.
 *
 * @param value Candidate value.
 * @returns True when the value is a number with an integral value.
 */
function isStrictInteger(value: unknown): value is number {
  return typeof value === "number" && Number.isInteger(value);
}

/**
 * Report whether a key is present on a plain object.
 *
 * @param value The object to inspect.
 * @param key The key to look for.
 * @returns True when the object carries the key as an own property.
 */
function hasKey(value: Record<string, unknown>, key: string): boolean {
  return Object.prototype.hasOwnProperty.call(value, key);
}

/**
 * Validate the three invariants for one remediation cycle.
 *
 * @param index Zero-based position of this cycle within `cycles`.
 * @param cycle The raw cycle object.
 * @returns One error string per violated invariant; empty when all hold.
 */
function validateRemediationCycle(
  index: number,
  cycle: Record<string, unknown>,
): string[] {
  const errors: string[] = [];

  // Invariant 1: plan_path must be a non-empty, non-whitespace string.
  const planPath = cycle["plan_path"];
  if (typeof planPath !== "string" || planPath.trim() === "") {
    errors.push(
      `Checkpoint remediation cycle #${index} plan_path must be a ` +
        "non-empty string.",
    );
  }

  // Invariant 2: an execution status in the blocked set requires that the
  // cycle's preflight gate reports exactly the cleared status.
  const executionStatus = cycle["execution_status"];
  if (
    typeof executionStatus === "string" &&
    EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT.has(executionStatus)
  ) {
    const preflight = cycle["preflight"];
    // Read the nested preflight final status defensively; a missing or
    // non-object preflight cannot satisfy the cleared requirement.
    const preflightStatus: unknown = isObject(preflight)
      ? preflight["final_status"]
      : undefined;
    if (preflightStatus !== PREFLIGHT_CLEARED_STATUS) {
      errors.push(
        `Checkpoint remediation cycle #${index} execution_status is ` +
          `${executionStatus} but preflight.final_status is not 'clear'.`,
      );
    }
  }

  // Invariant 3: a satisfied exit gate requires zero blocking findings.
  if (cycle["exit_condition_met"] === true && cycle["blocking_count"] !== 0) {
    errors.push(
      `Checkpoint remediation cycle #${index} exit_condition_met is true ` +
        "but blocking_count is not 0.",
    );
  }

  return errors;
}

/**
 * Report whether an index names a `REMEDIATION_REQUIRED` outcome object.
 *
 * @param openedByReview The raw `opened_by_review` value.
 * @param outcomes The raw `review_outcomes` value.
 * @returns True only for an in-range integer pointing at such an outcome.
 */
function opensRemediationReview(
  openedByReview: unknown,
  outcomes: unknown,
): boolean {
  if (!isStrictInteger(openedByReview) || !Array.isArray(outcomes)) {
    return false;
  }
  if (openedByReview < 0 || openedByReview >= outcomes.length) {
    return false;
  }
  const target: unknown = outcomes[openedByReview];
  return isObject(target) && target["verdict"] === "REMEDIATION_REQUIRED";
}

/**
 * Validate the accounting invariants: per cycle R5, R6, R11; then R7a or R7b.
 *
 * @param loop The remediation-loop object.
 * @param cycleList The `cycles` list, or `null` when absent or not a list.
 * @returns The accounting errors in spec order.
 */
function validateRemediationAccounting(
  loop: Record<string, unknown>,
  cycleList: readonly unknown[] | null,
): string[] {
  const errors: string[] = [];
  const outcomes = loop[REVIEW_OUTCOMES_KEY];
  let appliedCount = 0;

  (cycleList ?? []).forEach((cycle, index) => {
    if (!isObject(cycle)) {
      return;
    }
    const prefix = `Checkpoint remediation cycle #${index}`;
    if (hasKey(cycle, CANDIDATE_APPLIED_KEY)) {
      const candidateApplied = cycle[CANDIDATE_APPLIED_KEY];
      if (typeof candidateApplied !== "boolean") {
        errors.push(`${prefix} candidate_applied must be a boolean.`);
      } else if (candidateApplied) {
        appliedCount += 1;
        if (cycle["execution_status"] !== COMPLETED_EXECUTION_STATUS) {
          errors.push(
            `${prefix} candidate_applied is true but execution_status ` +
              "is not 'complete'.",
          );
        }
      }
    }
    if (
      hasKey(cycle, OPENED_BY_REVIEW_KEY) &&
      !opensRemediationReview(cycle[OPENED_BY_REVIEW_KEY], outcomes)
    ) {
      errors.push(
        `${prefix} opened_by_review must reference a review outcome whose ` +
          "verdict is REMEDIATION_REQUIRED.",
      );
    }
  });

  if (hasKey(loop, COMPLETED_ATTEMPTS_KEY)) {
    const completedAttempts = loop[COMPLETED_ATTEMPTS_KEY];
    if (!isStrictInteger(completedAttempts) || completedAttempts < 0) {
      errors.push(
        "Checkpoint remediation_loop completed_attempts must be a " +
          "non-negative integer.",
      );
    } else if (completedAttempts !== appliedCount) {
      errors.push(
        `Checkpoint remediation_loop completed_attempts is ` +
          `${completedAttempts} but ${appliedCount} cycles have ` +
          "candidate_applied true.",
      );
    }
  }

  return errors;
}

/**
 * Validate the optional remediation loop.
 *
 * Purpose:
 *     Mirror Python `_validate_remediation_loop`. A non-object loop yields no
 *     errors (nothing to enforce). When `cycles` is a list each cycle is
 *     validated independently; the review-outcome and accounting checks then
 *     run with the cycle list or `null`.
 *
 * @param remediationLoop Raw value of the checkpoint's `remediation_loop` key.
 * @returns Per-cycle errors, then review-outcome errors, then accounting errors.
 */
export function validateRemediationLoop(remediationLoop: unknown): string[] {
  const errors: string[] = [];

  // A non-object remediation_loop carries no cycles to validate; treat it as
  // nothing to enforce rather than fabricating a structural error here.
  if (!isObject(remediationLoop)) {
    return errors;
  }

  const cycles = remediationLoop[REMEDIATION_CYCLES_KEY];
  let cycleList: readonly unknown[] | null = null;
  if (Array.isArray(cycles)) {
    cycleList = cycles;
    // Validate each cycle independently so callers receive a complete error
    // list instead of stopping at the first malformed cycle.
    cycles.forEach((cycle: unknown, index) => {
      if (!isObject(cycle)) {
        errors.push(
          `Checkpoint remediation cycle #${index} must be an object.`,
        );
        return;
      }
      errors.push(...validateRemediationCycle(index, cycle));
    });
  }

  errors.push(...validateReviewOutcomes(remediationLoop));
  errors.push(...validateRemediationAccounting(remediationLoop, cycleList));
  return errors;
}
