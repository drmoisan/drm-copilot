"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PROMOTION_RECEIPT_KEYS = exports.PROMOTION_RECEIPT_NAMESPACE_KEY = exports.CI_GATE_KEYS = exports.PR_GATE_KEYS = void 0;
exports.missingObjectKeys = missingObjectKeys;
exports.validateCompletionPrGate = validateCompletionPrGate;
exports.validateCompletionCiGate = validateCompletionCiGate;
/**
 * Completion-gate helpers for the orchestrator-state validator.
 *
 * Purpose:
 *     Hold the route-aware PR gate and CI-gate completion checks ported from
 *     `scripts/dev_tools/validate_orchestrator_state.py` so the core validator
 *     module stays within the 500-line file limit.
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */
const orchestrator_state_routing_1 = require("./orchestrator-state-routing");
/** Keys required on the completion PR gate. */
exports.PR_GATE_KEYS = [
    "pr_number",
    "pr_url",
    "head_branch",
    "head_sha",
];
/** Keys required on the completion CI gate. */
exports.CI_GATE_KEYS = ["conclusion", "head_sha", "verified_at"];
/** Namespace key for the additive promotion receipts. */
exports.PROMOTION_RECEIPT_NAMESPACE_KEY = "promotion";
/** Keys required inside the promotion receipts namespace. */
exports.PROMOTION_RECEIPT_KEYS = [
    "potential_entry",
    "issue",
    "feature_folder",
];
/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value) {
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
function missingObjectKeys(value, keys) {
    if (!isObject(value)) {
        return [...keys];
    }
    const missing = [];
    // A key is missing when absent or present only as whitespace.
    for (const key of keys) {
        const item = value[key];
        if (item === undefined ||
            (typeof item === "string" && item.trim() === "")) {
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
function validateCompletionPrGate(state, options = {}) {
    if (!(0, orchestrator_state_routing_1.routeRequiresPrGate)(state, options)) {
        return [];
    }
    const prGate = state["pr_gate"];
    const missing = missingObjectKeys(prGate, exports.PR_GATE_KEYS);
    if (!isObject(prGate)) {
        return [
            "Checkpoint completion validation failed: pr_gate must be an object " +
                `with keys: ${exports.PR_GATE_KEYS.join(", ")}.`,
        ];
    }
    const errors = [];
    if (missing.length > 0) {
        errors.push("Checkpoint completion validation failed: pr_gate missing required " +
            `fields: ${missing.join(", ")}.`);
    }
    return errors;
}
/**
 * Validate the completion CI gate.
 *
 * @param state Checkpoint state object.
 * @returns Validation errors for a missing or malformed CI gate.
 */
function validateCompletionCiGate(state) {
    const ciGate = state["ci_gate"];
    const missing = missingObjectKeys(ciGate, exports.CI_GATE_KEYS);
    if (!isObject(ciGate)) {
        return [
            "Checkpoint completion validation failed: ci_gate must be an object " +
                `with keys: ${exports.CI_GATE_KEYS.join(", ")}.`,
        ];
    }
    const errors = [];
    if (missing.length > 0) {
        errors.push("Checkpoint completion validation failed: ci_gate missing required " +
            `fields: ${missing.join(", ")}.`);
    }
    if (ciGate["conclusion"] !== "success") {
        errors.push("Checkpoint completion validation failed: ci_gate.conclusion must be " +
            "success.");
    }
    // The CI head SHA must match the PR head SHA when the PR gate provides one.
    const prGate = state["pr_gate"];
    const prHeadSha = isObject(prGate) ? prGate["head_sha"] : null;
    if (prHeadSha !== null &&
        prHeadSha !== undefined &&
        ciGate["head_sha"] !== prHeadSha) {
        errors.push("Checkpoint completion validation failed: ci_gate.head_sha must match " +
            "pr_gate.head_sha.");
    }
    return errors;
}
