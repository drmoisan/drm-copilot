/**
 * Orchestrator-state `blocked_reason` vocabulary and partition.
 *
 * Purpose:
 *     Port `scripts/dev_tools/_orchestrator_state_blocked_reason.py`, which is the
 *     authoritative source. Publish the `blocked_reason` vocabulary as the
 *     not-blocked member `none` plus two disjoint partitions, and classify a
 *     recorded value into one of those three classes.
 *
 * Invariants / Constraints:
 *     - The mechanical partition holds the six validator-enforced members; the
 *       non-mechanical partition holds the five halt classes added by #523. The
 *       partitions are disjoint and neither contains `none`.
 *     - Membership is case-sensitive, and a non-string value is never looked up
 *       in a set.
 *     - The member lists are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

/** The six validator-enforced (mechanical) members. */
export const MECHANICAL_BLOCKED_REASONS: ReadonlySet<string> = new Set([
  "spawn_agent_unavailable",
  "delegation_launch_failed",
  "delegate_no_receipt",
  "delegate_contract_incomplete",
  "validator_failed",
  "user_requested_stop",
]);

/** The five non-mechanical halt classes added by #523. */
export const NON_MECHANICAL_BLOCKED_REASONS: ReadonlySet<string> = new Set([
  "premise_falsified",
  "external_dependency",
  "policy_hold",
  "awaiting_ci",
  "human_decision_required",
]);

/** Permitted blocked-reason values: `none` plus both partitions. */
export const VALID_BLOCKED_REASONS: ReadonlySet<string> = new Set([
  "none",
  ...MECHANICAL_BLOCKED_REASONS,
  ...NON_MECHANICAL_BLOCKED_REASONS,
]);

/** The three classes a recorded `blocked_reason` value can fall into. */
export type BlockedReasonClass =
  "not_blocked" | "mechanical" | "non_mechanical";

/**
 * Classify a recorded `blocked_reason` value.
 *
 * @param value The checkpoint's `blocked_reason` value.
 * @returns `"not_blocked"` for `null`, `undefined`, or `"none"`; `"mechanical"`
 *     for a mechanical member; `"non_mechanical"` for a non-mechanical member.
 * @throws RangeError when the value is not a string member of the vocabulary;
 *     the message is `invalid blocked_reason: ` followed by `String(value)`.
 */
export function classifyBlockedReason(value: unknown): BlockedReasonClass {
  if (value === null || value === undefined || value === "none") {
    return "not_blocked";
  }
  if (typeof value === "string") {
    if (MECHANICAL_BLOCKED_REASONS.has(value)) {
      return "mechanical";
    }
    if (NON_MECHANICAL_BLOCKED_REASONS.has(value)) {
      return "non_mechanical";
    }
  }
  throw new RangeError(`invalid blocked_reason: ${String(value)}`);
}
