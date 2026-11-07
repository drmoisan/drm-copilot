/**
 * Light-remediation invariant 8 for orchestrator-state checkpoints (issue #1097).
 *
 * Purpose:
 *     Port `scripts/dev_tools/_orchestrator_state_light_cycle.py`. A remediation
 *     cycle that carries `remediation_path` names a known path, and a `light`
 *     cycle carries no preflight, names its opening review, fixes at most three
 *     contained autonomous findings, and does not follow another light cycle.
 *
 * Usage:
 *     `validateRemediationAccounting` in `orchestrator-state-remediation.ts`
 *     calls `validateLightCycles` last and passes its private R11 predicate, so
 *     this module imports nothing from that module and no predicate is
 *     duplicated.
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python source and render no
 *       checkpoint value.
 *     - A cycle without the key reaches no rule.
 *
 * Side Effects:
 *     None.
 */

/** Cycle key naming the remediation path a cycle followed. */
export const REMEDIATION_PATH_KEY = "remediation_path";

/** The path value of a light cycle. */
export const LIGHT_REMEDIATION_PATH = "light";

/** The path value of a full cycle. */
export const FULL_REMEDIATION_PATH = "full";

/** The most findings a light cycle's opening review may carry. */
export const LIGHT_FINDING_LIMIT = 3;

/** Reports whether an `opened_by_review` value indexes a remediation review. */
export type OpensReview = (
  openedByReview: unknown,
  outcomes: unknown,
) => boolean;

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
 * Read one key of a finding, or `undefined` for a non-object finding.
 *
 * @param finding One element of an outcome's `findings` list.
 * @param key The finding key to read.
 * @returns The value under the key; `undefined` never equals a class or scope.
 */
function findingValue(finding: unknown, key: string): unknown {
  return isObject(finding) ? finding[key] : undefined;
}

/**
 * Return the findings list of the outcome a light cycle names.
 *
 * @param openedByReview An index already proven to name an outcome object.
 * @param outcomes The raw `review_outcomes` list.
 * @returns The findings, or an empty list when `findings` is not a list.
 */
function openingFindings(
  openedByReview: unknown,
  outcomes: unknown,
): readonly unknown[] {
  const outcome: unknown =
    Array.isArray(outcomes) && typeof openedByReview === "number"
      ? outcomes[openedByReview]
      : undefined;
  const findings = isObject(outcome) ? outcome["findings"] : undefined;
  return Array.isArray(findings) ? findings : [];
}

/**
 * Return the rule 2 to 7 errors of one cycle whose path is exactly light.
 *
 * @param index Zero-based position of the cycle within `cycles`.
 * @param cycle The cycle object.
 * @param prior The immediately prior list element, or `undefined`.
 * @param outcomes The raw `review_outcomes` value.
 * @param opensReview The R11 predicate.
 * @returns The errors in rule order.
 */
function lightCycleErrors(
  index: number,
  cycle: Record<string, unknown>,
  prior: unknown,
  outcomes: unknown,
  opensReview: OpensReview,
): string[] {
  const prefix = `Checkpoint remediation cycle #${index} remediation_path is light but`;
  const errors: string[] = [];

  // Rule 2: any preflight key is untruthful, because a light cycle runs none.
  if (Object.prototype.hasOwnProperty.call(cycle, "preflight")) {
    errors.push(`${prefix} the cycle carries preflight.`);
  }

  // Rule 3 gates rules 4 to 6: without a valid opening review there are no
  // findings to count or classify.
  const hasOpened = Object.prototype.hasOwnProperty.call(
    cycle,
    "opened_by_review",
  );
  const openedByReview = cycle["opened_by_review"];
  if (!hasOpened || !opensReview(openedByReview, outcomes)) {
    errors.push(`${prefix} opened_by_review does not name its opening review.`);
  } else {
    const findings = openingFindings(openedByReview, outcomes);
    if (findings.length > LIGHT_FINDING_LIMIT) {
      errors.push(
        `${prefix} its opening review has ${findings.length} findings; ` +
          `the limit is ${LIGHT_FINDING_LIMIT}.`,
      );
    }
    findings.forEach((finding, findingIndex) => {
      if (findingValue(finding, "remediability") !== "autonomous") {
        errors.push(`${prefix} finding #${findingIndex} is not autonomous.`);
      }
    });
    findings.forEach((finding, findingIndex) => {
      if (findingValue(finding, "scope") !== "contained") {
        errors.push(
          `${prefix} finding #${findingIndex} scope is not contained.`,
        );
      }
    });
  }

  // Rule 7: two light cycles may not run back to back.
  if (
    isObject(prior) &&
    prior[REMEDIATION_PATH_KEY] === LIGHT_REMEDIATION_PATH
  ) {
    errors.push(`${prefix} the prior cycle is light.`);
  }

  return errors;
}

/**
 * Validate invariant 8 for every cycle that carries `remediation_path`.
 *
 * @param cycleList The `cycles` list, or `null` when absent or not a list.
 * @param outcomes The raw `review_outcomes` value.
 * @param opensReview The R11 predicate of the remediation module.
 * @returns The errors in cycle order; empty when no cycle carries the key.
 */
export function validateLightCycles(
  cycleList: readonly unknown[] | null,
  outcomes: unknown,
  opensReview: OpensReview,
): string[] {
  const errors: string[] = [];
  const cycles = cycleList ?? [];

  cycles.forEach((cycle, index) => {
    if (
      !isObject(cycle) ||
      !Object.prototype.hasOwnProperty.call(cycle, REMEDIATION_PATH_KEY)
    ) {
      return;
    }
    // Rule 1 routes by exact value: full has no further rule, light runs rules
    // 2 to 7, and anything else is reported once and stops there.
    const path = cycle[REMEDIATION_PATH_KEY];
    if (path === FULL_REMEDIATION_PATH) {
      return;
    }
    if (path !== LIGHT_REMEDIATION_PATH) {
      errors.push(
        `Checkpoint remediation cycle #${index} remediation_path must be ` +
          "light or full.",
      );
      return;
    }
    const prior: unknown = index > 0 ? cycles[index - 1] : undefined;
    errors.push(
      ...lightCycleErrors(index, cycle, prior, outcomes, opensReview),
    );
  });

  return errors;
}
