/**
 * Review-outcome vocabulary and invariants for orchestrator-state checkpoints.
 *
 * Purpose:
 *     Port the review-outcome portion of
 *     `scripts/dev_tools/_orchestrator_state_remediation_loop.py` (issue #484):
 *     the verdict and remediability vocabulary, `deriveReviewVerdict`, and the
 *     review-outcome invariants R8a, R8b, R9a-R9d, and R10 documented in
 *     `.claude/rules/orchestrator-state.md`. Split from
 *     `orchestrator-state-remediation.ts`, which re-exports every public name
 *     here, to keep both files below the module-split threshold.
 *
 * Invariants / Constraints:
 *     - Every comparison is case-sensitive.
 *     - Values are rendered with Python `str()` semantics for message parity.
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

/** Key holding the ordered review outcomes inside the remediation loop. */
export const REVIEW_OUTCOMES_KEY = "review_outcomes";

/** The four review verdicts. */
export type ReviewVerdict =
  "PASS" | "REMEDIATION_REQUIRED" | "HALT_NON_REMEDIABLE" | "AWAITING_CI";

/** Review verdicts in spec table order. */
export const REVIEW_VERDICTS: readonly ReviewVerdict[] = [
  "PASS",
  "REMEDIATION_REQUIRED",
  "HALT_NON_REMEDIABLE",
  "AWAITING_CI",
];

/** Remediability classes in spec table order. */
export const REMEDIABILITY_CLASSES: readonly string[] = [
  "autonomous",
  "external_dependency",
  "policy_hold",
  "awaiting_ci",
  "human_decision_required",
];

/** The four classes the remediation loop cannot resolve on its own. */
export const NON_REMEDIABLE_CLASSES: ReadonlySet<string> = new Set([
  "external_dependency",
  "policy_hold",
  "awaiting_ci",
  "human_decision_required",
]);

/** The classes that halt the loop (every non-remediable class but CI wait). */
export const HALT_CLASSES: ReadonlySet<string> = new Set([
  "external_dependency",
  "policy_hold",
  "human_decision_required",
]);

/** The only remediability class the loop resolves autonomously. */
const REMEDIABLE_CLASS = "autonomous";

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
 * Render a value the way Python's f-string `str()` would for error parity.
 *
 * Same body as the local renderer in `orchestrator-state-human-interaction.ts`:
 * `None` for an absent value, `True`/`False` for booleans, and the literal text
 * for strings and numbers.
 *
 * @param value Raw value to render.
 * @returns The Python-equivalent string representation.
 */
function pythonRepr(value: unknown): string {
  if (value === null || value === undefined) {
    return "None";
  }
  if (value === true) {
    return "True";
  }
  if (value === false) {
    return "False";
  }
  return String(value);
}

/**
 * Derive a review verdict from its blocking findings' remediability classes.
 *
 * @param remediabilities The class of every blocking finding; duplicates are
 *     permitted.
 * @returns `PASS` for no findings; `REMEDIATION_REQUIRED` when any finding is
 *     `autonomous`; `HALT_NON_REMEDIABLE` when any finding is in
 *     `HALT_CLASSES`; otherwise `AWAITING_CI`.
 * @throws RangeError When a member is outside `REMEDIABILITY_CLASSES`; the
 *     message starts with `invalid remediability: `.
 */
export function deriveReviewVerdict(
  remediabilities: readonly string[],
): ReviewVerdict {
  for (const value of remediabilities) {
    if (!REMEDIABILITY_CLASSES.includes(value)) {
      throw new RangeError(`invalid remediability: ${value}`);
    }
  }
  if (remediabilities.length === 0) {
    return "PASS";
  }
  if (remediabilities.includes(REMEDIABLE_CLASS)) {
    return "REMEDIATION_REQUIRED";
  }
  if (remediabilities.some((value) => HALT_CLASSES.has(value))) {
    return "HALT_NON_REMEDIABLE";
  }
  return "AWAITING_CI";
}

/**
 * Validate one review outcome object (R9a-R9d, then R10).
 *
 * @param index Zero-based position of this outcome within `review_outcomes`.
 * @param outcome The raw outcome object.
 * @returns The outcome's errors in spec order; R10 only when no shape error.
 */
function validateReviewOutcome(
  index: number,
  outcome: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  const prefix = `Checkpoint remediation review outcome #${index}`;

  const verdict = outcome["verdict"];
  if (
    typeof verdict !== "string" ||
    !(REVIEW_VERDICTS as readonly string[]).includes(verdict)
  ) {
    errors.push(
      `${prefix} verdict must be one of PASS, REMEDIATION_REQUIRED, ` +
        `HALT_NON_REMEDIABLE, AWAITING_CI; got: ${pythonRepr(verdict)}`,
    );
  }

  const classes: string[] = [];
  const findings = outcome["findings"];
  if (!Array.isArray(findings)) {
    errors.push(`${prefix} findings must be a list.`);
  } else {
    findings.forEach((finding: unknown, findingIndex) => {
      if (!isObject(finding)) {
        errors.push(`${prefix} finding #${findingIndex} must be an object.`);
        return;
      }
      const remediability = finding["remediability"];
      if (
        typeof remediability !== "string" ||
        !REMEDIABILITY_CLASSES.includes(remediability)
      ) {
        errors.push(
          `${prefix} finding #${findingIndex} remediability must be one of ` +
            "autonomous, external_dependency, policy_hold, awaiting_ci, " +
            `human_decision_required; got: ${pythonRepr(remediability)}`,
        );
        return;
      }
      classes.push(remediability);
    });
  }

  // R10 compares only a well-formed outcome; any shape error above suppresses it.
  if (errors.length === 0) {
    const expected = deriveReviewVerdict(classes);
    if (verdict !== expected) {
      errors.push(
        `${prefix} verdict ${pythonRepr(verdict)} does not match its findings ` +
          `(expected ${expected}).`,
      );
    }
  }

  return errors;
}

/**
 * Validate the optional review-outcome list (R8a, R8b, then each outcome).
 *
 * @param loop The remediation-loop object.
 * @returns The review-outcome errors in spec order; empty when absent.
 */
export function validateReviewOutcomes(
  loop: Record<string, unknown>,
): string[] {
  if (!Object.prototype.hasOwnProperty.call(loop, REVIEW_OUTCOMES_KEY)) {
    return [];
  }
  const outcomes = loop[REVIEW_OUTCOMES_KEY];
  if (!Array.isArray(outcomes)) {
    return ["Checkpoint remediation_loop review_outcomes must be a list."];
  }

  const errors: string[] = [];
  outcomes.forEach((outcome: unknown, index) => {
    if (!isObject(outcome)) {
      errors.push(
        `Checkpoint remediation review outcome #${index} must be an object.`,
      );
      return;
    }
    errors.push(...validateReviewOutcome(index, outcome));
  });
  return errors;
}
