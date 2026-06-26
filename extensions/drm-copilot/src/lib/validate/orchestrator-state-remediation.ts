/**
 * Remediation-loop invariants for orchestrator-state checkpoints.
 *
 * Purpose:
 *     Port the remediation-loop portion of
 *     `scripts/dev_tools/validate_orchestrator_state.py`. Apply the three
 *     remediation-cycle invariants documented in
 *     `.claude/rules/orchestrator-state.md` without importing any schema file.
 *
 * Invariants / Constraints:
 *     - `plan_path` must be a non-empty string.
 *     - Execution may only be recorded once preflight has cleared.
 *     - A satisfied exit gate requires zero blocking findings.
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

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
 * Validate the optional remediation loop.
 *
 * Purpose:
 *     Mirror Python `_validate_remediation_loop`. A non-object loop or a
 *     non-list `cycles` value yields no errors (nothing to enforce); each cycle
 *     is otherwise validated independently.
 *
 * @param remediationLoop Raw value of the checkpoint's `remediation_loop` key.
 * @returns One error string per violated cycle invariant; empty when clean.
 */
export function validateRemediationLoop(remediationLoop: unknown): string[] {
  const errors: string[] = [];

  // A non-object remediation_loop carries no cycles to validate; treat it as
  // nothing to enforce rather than fabricating a structural error here.
  if (!isObject(remediationLoop)) {
    return errors;
  }

  const cycles = remediationLoop[REMEDIATION_CYCLES_KEY];
  if (!Array.isArray(cycles)) {
    return errors;
  }

  // Validate each cycle independently so callers receive a complete error list
  // instead of stopping at the first malformed cycle.
  cycles.forEach((cycle, index) => {
    if (!isObject(cycle)) {
      errors.push(`Checkpoint remediation cycle #${index} must be an object.`);
      return;
    }
    errors.push(...validateRemediationCycle(index, cycle));
  });

  return errors;
}
