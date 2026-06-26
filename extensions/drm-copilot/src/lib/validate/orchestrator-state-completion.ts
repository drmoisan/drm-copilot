/**
 * Completion-gate helpers for the orchestrator-state validator.
 *
 * Purpose:
 *     Hold the PR-gate, CI-gate, and Issue #232 promotion-receipt completion
 *     checks ported from `scripts/dev_tools/validate_orchestrator_state.py` so
 *     the core validator module stays within the 500-line file limit.
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

/** Issue number used by the Issue #232 completion gates. */
export const ISSUE_232 = "232";

/** Branch name required for the Issue #232 completion gate. */
export const ISSUE_232_BRANCH = "feature/harden-orchestrate-skill-232";

/** Keys required on the completion PR gate. */
export const PR_GATE_KEYS = [
  "pr_number",
  "pr_url",
  "head_branch",
  "head_sha",
] as const;

/** Keys required on the completion CI gate. */
export const CI_GATE_KEYS = ["conclusion", "head_sha", "verified_at"] as const;

/** Namespace key for the additive promotion receipts. */
export const PROMOTION_RECEIPT_NAMESPACE_KEY = "promotion";

/** Keys required inside the promotion receipts namespace. */
export const PROMOTION_RECEIPT_KEYS = [
  "potential_entry",
  "issue",
  "feature_folder",
] as const;

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
 * Return the required keys missing (or empty-string) from an object value.
 *
 * Mirrors Python `_missing_object_keys`: a non-object yields all keys; a key is
 * missing when absent, or present as a whitespace-only string.
 *
 * @param value Candidate object value.
 * @param keys Keys that must be present and non-empty.
 * @returns The missing keys, in order.
 */
export function missingObjectKeys(
  value: unknown,
  keys: ReadonlyArray<string>,
): string[] {
  if (!isObject(value)) {
    return [...keys];
  }
  const missing: string[] = [];
  // A key is missing when absent or present only as whitespace.
  for (const key of keys) {
    const item = value[key];
    if (
      item === undefined ||
      (typeof item === "string" && item.trim() === "")
    ) {
      missing.push(key);
    }
  }
  return missing;
}

/**
 * Validate the completion PR gate.
 *
 * @param state Checkpoint state object.
 * @returns Validation errors for a missing or malformed PR gate.
 */
export function validateCompletionPrGate(
  state: Record<string, unknown>,
): string[] {
  const prGate = state["pr_gate"];
  const missing = missingObjectKeys(prGate, PR_GATE_KEYS);
  if (!isObject(prGate)) {
    return [
      "Checkpoint completion validation failed: pr_gate must be an object " +
        `with keys: ${PR_GATE_KEYS.join(", ")}.`,
    ];
  }
  const errors: string[] = [];
  if (missing.length > 0) {
    errors.push(
      "Checkpoint completion validation failed: pr_gate missing required " +
        `fields: ${missing.join(", ")}.`,
    );
  }
  // Issue #232 additionally pins the PR head branch.
  if (state["issue-num"] === ISSUE_232) {
    if (prGate["head_branch"] !== ISSUE_232_BRANCH) {
      errors.push(
        "Checkpoint completion validation failed: pr_gate.head_branch " +
          `must be ${ISSUE_232_BRANCH} for Issue #232.`,
      );
    }
  }
  return errors;
}

/**
 * Validate the completion CI gate.
 *
 * @param state Checkpoint state object.
 * @returns Validation errors for a missing or malformed CI gate.
 */
export function validateCompletionCiGate(
  state: Record<string, unknown>,
): string[] {
  const ciGate = state["ci_gate"];
  const missing = missingObjectKeys(ciGate, CI_GATE_KEYS);
  if (!isObject(ciGate)) {
    return [
      "Checkpoint completion validation failed: ci_gate must be an object " +
        `with keys: ${CI_GATE_KEYS.join(", ")}.`,
    ];
  }
  const errors: string[] = [];
  if (missing.length > 0) {
    errors.push(
      "Checkpoint completion validation failed: ci_gate missing required " +
        `fields: ${missing.join(", ")}.`,
    );
  }
  if (ciGate["conclusion"] !== "success") {
    errors.push(
      "Checkpoint completion validation failed: ci_gate.conclusion must be " +
        "success.",
    );
  }
  // The CI head SHA must match the PR head SHA when the PR gate provides one.
  const prGate = state["pr_gate"];
  const prHeadSha = isObject(prGate) ? prGate["head_sha"] : null;
  if (
    prHeadSha !== null &&
    prHeadSha !== undefined &&
    ciGate["head_sha"] !== prHeadSha
  ) {
    errors.push(
      "Checkpoint completion validation failed: ci_gate.head_sha must match " +
        "pr_gate.head_sha.",
    );
  }
  return errors;
}

/**
 * Validate the Issue #232 promotion receipts.
 *
 * @param state Checkpoint state object.
 * @returns Validation errors for missing Issue #232 promotion receipt keys.
 */
export function validateIssue232PromotionReceipts(
  state: Record<string, unknown>,
): string[] {
  if (state["issue-num"] !== ISSUE_232) {
    return [];
  }
  const receipts = state["delegation_receipts"];
  let promotionSource = "promotion_receipts";
  let promotion: unknown = state["promotion_receipts"];
  // Prefer the namespaced promotion receipts when present in the object form.
  if (isObject(receipts)) {
    const namespacedPromotion = receipts[PROMOTION_RECEIPT_NAMESPACE_KEY];
    if (namespacedPromotion !== undefined && namespacedPromotion !== null) {
      promotionSource = "delegation_receipts.promotion";
      promotion = namespacedPromotion;
    }
  }
  const missing = missingObjectKeys(promotion, PROMOTION_RECEIPT_KEYS);
  if (missing.length > 0) {
    return [
      "Checkpoint completion validation failed: " +
        `${promotionSource} missing required Issue #232 ` +
        `receipt keys: ${missing.join(", ")}.`,
    ];
  }
  return [];
}
