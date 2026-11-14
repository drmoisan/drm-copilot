/**
 * Completion rule for orchestrator-state checkpoints under concurrent review.
 *
 * Purpose:
 *     TypeScript port of `validate_concurrent_review_completion` in
 *     `scripts/dev_tools/_orchestrator_state_concurrent_review.py`. Under
 *     `review_mode: "concurrent"`, the last `review_outcomes` entry must carry
 *     verdict `PASS` and a full lowercase `head_sha`.
 *
 * Invariants:
 *     - Only the exact string `concurrent` activates the rule.
 *     - Only the final list element counts.
 *     - The rule does no git work: head currency stays with the merge guard.
 *     - The error strings are byte-identical in the three runtimes, pinned by
 *       the corpus `tests/fixtures/orchestrator_state_concurrent_review/`.
 *
 * Side effects: none.
 */

/** The only value that activates the rule. */
const CONCURRENT_REVIEW_MODE = "concurrent";

/** The verdict the last review outcome must carry. */
const PASSING_REVIEW_VERDICT = "PASS";

/** Reported when the last review outcome is absent or did not pass. */
const LAST_REVIEW_NOT_PASSED_ERROR =
  "Checkpoint completion validation failed: review_mode concurrent requires a last review_outcomes entry with verdict PASS.";

/** Reported when the last passing review outcome has no well-formed head. */
const LAST_REVIEW_HEAD_MISSING_ERROR =
  "Checkpoint completion validation failed: review_mode concurrent requires head_sha on the last review_outcomes entry.";

/** A full lowercase object id: 40 characters for SHA-1, 64 for SHA-256. */
const OBJECT_ID_PATTERN = /^[0-9a-f]{40}(?:[0-9a-f]{24})?$/;

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
 * Return the final `review_outcomes` entry when it is an object.
 *
 * @param state Parsed checkpoint state.
 * @returns The last entry, or undefined when the loop or the list is absent or
 * empty, or the last entry is not an object.
 */
function lastReviewOutcome(
  state: Record<string, unknown>,
): Record<string, unknown> | undefined {
  const outcomes = asObject(state["remediation_loop"])?.["review_outcomes"];
  if (!Array.isArray(outcomes)) {
    return undefined;
  }
  const entries: readonly unknown[] = outcomes;
  return asObject(entries.at(-1));
}

/**
 * Validate the review record of a completed concurrent run.
 *
 * @param state Parsed checkpoint state.
 * @returns An empty list without the key or when the record is complete;
 * otherwise exactly one error string. The head error is reported only when the
 * verdict error does not apply.
 */
export function validateConcurrentReviewCompletion(
  state: Record<string, unknown>,
): string[] {
  if (state["review_mode"] !== CONCURRENT_REVIEW_MODE) {
    return [];
  }
  const last = lastReviewOutcome(state);
  if (last?.["verdict"] !== PASSING_REVIEW_VERDICT) {
    return [LAST_REVIEW_NOT_PASSED_ERROR];
  }
  const head = last["head_sha"];
  if (typeof head !== "string" || !OBJECT_ID_PATTERN.test(head)) {
    return [LAST_REVIEW_HEAD_MISSING_ERROR];
  }
  return [];
}
