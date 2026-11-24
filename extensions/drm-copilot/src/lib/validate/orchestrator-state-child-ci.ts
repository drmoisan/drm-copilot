/**
 * Completion rule for epic children that opt out of per-child CI (issue #1233).
 *
 * Purpose:
 *     TypeScript port of the `child_ci: integration_only` selection in
 *     `scripts/dev_tools/validate_orchestrator_state.py`. Under the opt-out
 *     predicate, the completion check reads `local_qc_gate` in place of
 *     `ci_gate`; without it, the existing `ci_gate` check applies unchanged.
 *
 * Invariants:
 *     - The predicate holds only when `epic_mode` is the boolean `true` and
 *       `child_ci` is the exact string `integration_only`.
 *     - The error strings and their order are byte-identical in the three
 *       runtimes, pinned by the corpus `tests/fixtures/orchestrator_state_child_ci/`.
 *
 * Side effects: none.
 */
import {
  missingObjectKeys,
  validateCompletionCiGate,
} from "./orchestrator-state-completion";

/** Keys required on the local final-QC gate record. */
export const LOCAL_QC_GATE_KEYS = [
  "conclusion",
  "head_sha",
  "evidence_path",
  "verified_at",
] as const;

/** The only `child_ci` value that activates the opt-out. */
const CHILD_CI_INTEGRATION_ONLY = "integration_only";

/** Reported when `local_qc_gate` is absent or not an object; returned alone. */
const LOCAL_QC_GATE_SHAPE_ERROR =
  "Checkpoint completion validation failed: child_ci integration_only requires local_qc_gate to be an object with keys: " +
  `${LOCAL_QC_GATE_KEYS.join(", ")}.`;

/** Reported when the local gate conclusion is not `success`. */
const LOCAL_QC_GATE_CONCLUSION_ERROR =
  "Checkpoint completion validation failed: local_qc_gate.conclusion must be success.";

/** Reported when the opt-out is recorded without concurrent review. */
const LOCAL_QC_GATE_REVIEW_MODE_ERROR =
  "Checkpoint completion validation failed: child_ci integration_only requires review_mode concurrent.";

/** Reported when the local gate head is not the last reviewed head. */
const LOCAL_QC_GATE_HEAD_ERROR =
  "Checkpoint completion validation failed: local_qc_gate.head_sha must match the head_sha of the last review_outcomes entry.";

/**
 * Narrow a parsed JSON value to a plain object.
 *
 * @param value Parsed JSON value.
 * @returns The value as an object, or undefined when it is not a plain object.
 */
function asObject(value: unknown): Record<string, unknown> | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return undefined;
  }
  return value as Record<string, unknown>;
}

/**
 * Report whether a checkpoint opts its epic child out of per-child CI.
 *
 * @param state Parsed checkpoint state.
 * @returns True only for `epic_mode === true` and `child_ci === "integration_only"`.
 */
export function isChildCiIntegrationOnly(
  state: Record<string, unknown>,
): boolean {
  return (
    state["epic_mode"] === true &&
    state["child_ci"] === CHILD_CI_INTEGRATION_ONLY
  );
}

/**
 * Return the `head_sha` of the final `review_outcomes` entry.
 *
 * @param state Parsed checkpoint state.
 * @returns The value, or undefined when the loop, the list, or the last
 * object entry is absent.
 */
function lastReviewHeadSha(state: Record<string, unknown>): unknown {
  const outcomes = asObject(state["remediation_loop"])?.["review_outcomes"];
  if (!Array.isArray(outcomes) || outcomes.length === 0) {
    return undefined;
  }
  return asObject(outcomes[outcomes.length - 1])?.["head_sha"];
}

/**
 * Validate the local final-QC gate of an opted-out epic child.
 *
 * Errors are emitted in the fixed order: the shape error alone, otherwise the
 * missing fields, the conclusion, and then either the review-mode error or,
 * under concurrent review, the head binding.
 *
 * @param state Parsed checkpoint state.
 * @returns The ordered completion errors.
 */
export function validateCompletionLocalQcGate(
  state: Record<string, unknown>,
): string[] {
  const gate = asObject(state["local_qc_gate"]);
  if (gate === undefined) {
    return [LOCAL_QC_GATE_SHAPE_ERROR];
  }
  const errors: string[] = [];
  const missing = missingObjectKeys(gate, LOCAL_QC_GATE_KEYS);
  if (missing.length > 0) {
    errors.push(
      "Checkpoint completion validation failed: local_qc_gate missing required " +
        `fields: ${missing.join(", ")}.`,
    );
  }
  if (gate["conclusion"] !== "success") {
    errors.push(LOCAL_QC_GATE_CONCLUSION_ERROR);
  }
  if (state["review_mode"] !== "concurrent") {
    errors.push(LOCAL_QC_GATE_REVIEW_MODE_ERROR);
    return errors;
  }
  const lastHead = lastReviewHeadSha(state);
  if (typeof lastHead !== "string" || gate["head_sha"] !== lastHead) {
    errors.push(LOCAL_QC_GATE_HEAD_ERROR);
  }
  return errors;
}

/**
 * Select the completion gate check for a CI-gated route.
 *
 * @param state Parsed checkpoint state.
 * @returns The local-QC errors under the opt-out, else the `ci_gate` errors.
 */
export function validateCompletionGateEvidence(
  state: Record<string, unknown>,
): string[] {
  if (isChildCiIntegrationOnly(state)) {
    return validateCompletionLocalQcGate(state);
  }
  return validateCompletionCiGate(state);
}
