"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.REQUIRED_RECEIPT_KEYS = exports.VALID_BLOCKED_REASONS = exports.VALID_STEP_STATUS = exports.REQUIRED_STATE_KEYS = exports.PROMOTION_RECEIPT_NAMESPACE_KEY = exports.PROMOTION_RECEIPT_KEYS = exports.PR_GATE_KEYS = exports.CI_GATE_KEYS = void 0;
exports.validateOrchestratorStateText = validateOrchestratorStateText;
const orchestrator_state_codex_model_routing_1 = require("./orchestrator-state-codex-model-routing");
const orchestrator_state_codex_topology_1 = require("./orchestrator-state-codex-topology");
const orchestrator_state_completion_1 = require("./orchestrator-state-completion");
Object.defineProperty(exports, "PROMOTION_RECEIPT_KEYS", { enumerable: true, get: function () { return orchestrator_state_completion_1.PROMOTION_RECEIPT_KEYS; } });
Object.defineProperty(exports, "PROMOTION_RECEIPT_NAMESPACE_KEY", { enumerable: true, get: function () { return orchestrator_state_completion_1.PROMOTION_RECEIPT_NAMESPACE_KEY; } });
const orchestrator_state_human_interaction_1 = require("./orchestrator-state-human-interaction");
const orchestrator_state_remediation_1 = require("./orchestrator-state-remediation");
const orchestrator_state_preparation_terminal_1 = require("./orchestrator-state-preparation-terminal");
const orchestrator_state_model_routing_existence_1 = require("./orchestrator-state-model-routing-existence");
const orchestrator_state_routing_1 = require("./orchestrator-state-routing");
// Re-export the completion-gate constants the core ports historically carried so
// callers and tests can continue to import them from this module.
var orchestrator_state_completion_2 = require("./orchestrator-state-completion");
Object.defineProperty(exports, "CI_GATE_KEYS", { enumerable: true, get: function () { return orchestrator_state_completion_2.CI_GATE_KEYS; } });
Object.defineProperty(exports, "PR_GATE_KEYS", { enumerable: true, get: function () { return orchestrator_state_completion_2.PR_GATE_KEYS; } });
/**
 * Core orchestrator-state checkpoint validator.
 *
 * Purpose:
 *     Port the core of `scripts/dev_tools/validate_orchestrator_state.py`. The
 *     remediation, human-interaction, and routing concerns are imported from
 *     their dedicated modules so this file stays within the 500-line limit.
 *
 * Responsibilities:
 *     - Parse the checkpoint JSON and validate required top-level keys, step
 *       statuses, blocked-reason, and delegation receipts (list or namespace).
 *     - Delegate the optional remediation and human-interaction blocks.
 *     - Under `requireComplete`, enforce completion-safe statuses, the PR/CI
 *       route-aware PR/CI gates, mandatory phases, the preparation terminal
 *       contract, and the routing contract.
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python source.
 *     - The routing matrix is injected to keep the validator hermetic.
 *
 * Side Effects:
 *     None directly; the injected `FileSystem` performs reads when loading the
 *     routing matrix.
 */
/** Required top-level checkpoint keys. */
exports.REQUIRED_STATE_KEYS = [
    "objective",
    "change_budget_estimate",
    "path_selected",
    "promotion-type",
    "short-name",
    "relativeFile",
    "long-name",
    "issue-num",
    "feature-folder",
    "work-mode",
    "plan-path",
    "completed_steps",
    "next_step",
    "last_updated",
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
    "delegation_receipts",
    "blocked_reason",
];
/** Permitted step status values. */
exports.VALID_STEP_STATUS = new Set([
    "not-applicable",
    "pending",
    "delegated",
    "verified",
    "blocked",
    "not_started",
    "in_progress",
    "completed",
]);
/** Permitted blocked-reason values. */
exports.VALID_BLOCKED_REASONS = new Set([
    "none",
    "spawn_agent_unavailable",
    "delegation_launch_failed",
    "delegate_no_receipt",
    "delegate_contract_incomplete",
    "validator_failed",
    "user_requested_stop",
]);
/** Keys required on each legacy list delegation receipt. */
exports.REQUIRED_RECEIPT_KEYS = [
    "step",
    "agent_name",
    "agent_id",
    "skill_source",
    "started_at",
    "completed_at",
    "result_signal",
    "artifact_paths",
];
const STEP_STATUS_KEYS = [
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
];
const AGENT_RECEIPT_NAMESPACE_KEY = "agents";
/**
 * Per-key additive vocabulary layered on the shared `VALID_STEP_STATUS` set. A
 * value listed here is valid only on its owning key; the same value on any
 * other step key is still rejected. Ported from Python
 * `scripts/dev_tools/_orchestrator_state_step_status.py`.
 */
const STEP_SPECIFIC_EXTRA_STATUS = new Map([
    ["step6_status", new Set(["blocked_remediation_loop_limit"])],
    [
        "step9_status",
        new Set(["passed", "failed_remediation_required", "blocked_ci_loop_limit"]),
    ],
]);
/**
 * Step statuses that must never appear in a checkpoint written as DONE. The
 * documented S9 success value `passed` is deliberately absent: it records CI
 * green and must not block completion. Typed over `unknown` so membership is
 * tested on the raw checkpoint value, matching the Python `in` check.
 */
const COMPLETION_BLOCKING_STEP_STATUS = new Set([
    "pending",
    "blocked",
    "failed_remediation_required",
    "blocked_ci_loop_limit",
    "blocked_remediation_loop_limit",
]);
/**
 * Report whether a step-status value is valid for its own step key.
 *
 * @param key Checkpoint step-status key the value was written to.
 * @param value String value read from the checkpoint.
 * @returns True when the value is in the shared vocabulary or in the extra set
 * owned by `key`.
 */
function isValidStepStatus(key, value) {
    if (exports.VALID_STEP_STATUS.has(value)) {
        return true;
    }
    return STEP_SPECIFIC_EXTRA_STATUS.get(key)?.has(value) === true;
}
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
 * Validate the legacy list-based delegation receipt payload.
 *
 * @param receipts Raw receipt list extracted from the checkpoint JSON.
 * @returns Validation errors for malformed receipt objects.
 */
function validateListDelegationReceipts(receipts) {
    const errors = [];
    // Validate each legacy receipt independently so callers receive a complete
    // error list instead of stopping at the first malformed item.
    receipts.forEach((receipt, index) => {
        if (!isObject(receipt)) {
            errors.push(`Checkpoint delegation receipt #${index} must be an object.`);
            return;
        }
        for (const key of exports.REQUIRED_RECEIPT_KEYS) {
            if (!(key in receipt)) {
                errors.push(`Checkpoint delegation receipt #${index} missing key: ${key}`);
            }
        }
        const artifactPaths = receipt["artifact_paths"];
        if (artifactPaths !== undefined &&
            artifactPaths !== null &&
            !Array.isArray(artifactPaths)) {
            errors.push(`Checkpoint delegation receipt #${index} artifact_paths must be a list.`);
        }
    });
    return errors;
}
/**
 * Validate the additive object-namespace form of delegation receipts.
 *
 * @param receipts Object-form receipt payload from the checkpoint JSON.
 * @returns Validation errors for unsupported object-shape keys.
 */
function validateNamespacedDelegationReceipts(receipts) {
    const errors = [];
    // Reject any top-level key outside the documented receipt namespaces, sorted.
    const unsupportedKeys = Object.keys(receipts)
        .filter((key) => key !== AGENT_RECEIPT_NAMESPACE_KEY &&
        key !== orchestrator_state_completion_1.PROMOTION_RECEIPT_NAMESPACE_KEY)
        .sort();
    for (const key of unsupportedKeys) {
        errors.push(`Checkpoint delegation_receipts object contains unsupported key: ${key}`);
    }
    if (AGENT_RECEIPT_NAMESPACE_KEY in receipts) {
        const agentReceipts = receipts[AGENT_RECEIPT_NAMESPACE_KEY];
        if (!Array.isArray(agentReceipts)) {
            errors.push("Checkpoint delegation_receipts.agents must be a list.");
        }
        else {
            errors.push(...validateListDelegationReceipts(agentReceipts));
        }
    }
    const promotionReceipts = receipts[orchestrator_state_completion_1.PROMOTION_RECEIPT_NAMESPACE_KEY];
    if (promotionReceipts === undefined || promotionReceipts === null) {
        return errors;
    }
    if (!isObject(promotionReceipts)) {
        errors.push("Checkpoint delegation_receipts.promotion must be an object namespace.");
        return errors;
    }
    // Reject unknown nested keys while leaving raw receipt values untouched.
    const unsupportedPromotionKeys = Object.keys(promotionReceipts)
        .filter((key) => !orchestrator_state_completion_1.PROMOTION_RECEIPT_KEYS.includes(key))
        .sort();
    for (const key of unsupportedPromotionKeys) {
        errors.push("Checkpoint delegation_receipts.promotion contains unsupported key: " +
            key);
    }
    return errors;
}
/**
 * Resolve the routing matrix for the completion routing-contract check.
 *
 * @param options Validation options carrying `routingMatrix` or `fs`+`root`.
 * @returns The resolved routing matrix, or undefined when none is available.
 */
function resolveRoutingMatrix(options) {
    if (options.routingMatrix !== undefined) {
        return options.routingMatrix;
    }
    // Default to loading via the supplied FileSystem from production wiring.
    if (options.fs !== undefined && options.root !== undefined) {
        return (0, orchestrator_state_routing_1.loadRoutingMatrix)(options.fs, options.root);
    }
    return undefined;
}
/**
 * Validate checkpoint schema and completion-state fields.
 *
 * Purpose:
 *     Mirror Python `validate_orchestrator_state_text`. Enforce the repository
 *     contract for orchestrator-state artifacts before resume or review
 *     workflows rely on the checkpoint contents.
 *
 * @param text Raw checkpoint JSON text.
 * @param options Validation options (completion gate and routing-matrix wiring).
 * @returns Validation errors for malformed or incomplete checkpoint state.
 */
function validateOrchestratorStateText(text, options = {}) {
    const errors = [];
    let state;
    try {
        state = JSON.parse(text);
    }
    catch (exc) {
        return [
            `Checkpoint is not valid JSON: ${exc instanceof Error ? exc.message : String(exc)}`,
        ];
    }
    if (!isObject(state)) {
        return ["Checkpoint root must be a JSON object."];
    }
    const stateMap = state;
    // Require the canonical top-level fields before evaluating deeper invariants.
    for (const key of exports.REQUIRED_STATE_KEYS) {
        if (!(key in stateMap)) {
            errors.push(`Checkpoint missing required key: ${key}`);
        }
    }
    // Validate each tracked step status against the shared permitted set plus
    // that key's additive extra vocabulary.
    for (const key of STEP_STATUS_KEYS) {
        const value = stateMap[key];
        if (value !== undefined &&
            value !== null &&
            !(typeof value === "string" && isValidStepStatus(key, value))) {
            errors.push(`Checkpoint has invalid ${key}: ${String(value)}`);
        }
    }
    const blockedReason = stateMap["blocked_reason"];
    if (blockedReason !== undefined &&
        blockedReason !== null &&
        !(typeof blockedReason === "string" &&
            exports.VALID_BLOCKED_REASONS.has(blockedReason))) {
        errors.push(`Checkpoint has invalid blocked_reason: ${String(blockedReason)}`);
    }
    const receipts = stateMap["delegation_receipts"];
    if (receipts !== undefined && receipts !== null) {
        if (Array.isArray(receipts)) {
            errors.push(...validateListDelegationReceipts(receipts));
        }
        else if (isObject(receipts)) {
            errors.push(...validateNamespacedDelegationReceipts(receipts));
        }
        else {
            errors.push("Checkpoint delegation_receipts must be a list or object namespace.");
        }
    }
    // Apply the additive remediation-cycle invariants only when present.
    if (orchestrator_state_remediation_1.REMEDIATION_LOOP_KEY in stateMap) {
        errors.push(...(0, orchestrator_state_remediation_1.validateRemediationLoop)(stateMap[orchestrator_state_remediation_1.REMEDIATION_LOOP_KEY]));
    }
    // Apply the additive human_interaction invariants only when present.
    if (orchestrator_state_human_interaction_1.HUMAN_INTERACTION_KEY in stateMap) {
        errors.push(...(0, orchestrator_state_human_interaction_1.validateHumanInteraction)(stateMap[orchestrator_state_human_interaction_1.HUMAN_INTERACTION_KEY]));
    }
    if (options.requireComplete === true) {
        // Enforce completion-safe lifecycle states only when the caller opts into
        // the stricter completion gate.
        for (const key of STEP_STATUS_KEYS) {
            const value = stateMap[key];
            if (COMPLETION_BLOCKING_STEP_STATUS.has(value)) {
                errors.push(`Checkpoint completion validation failed: ${key} is ${String(value)}.`);
            }
        }
        const completionBlockedReason = stateMap["blocked_reason"];
        if (completionBlockedReason !== undefined &&
            completionBlockedReason !== null &&
            completionBlockedReason !== "none") {
            errors.push("Checkpoint completion validation failed: blocked_reason is not `none`.");
        }
        const routingMatrix = resolveRoutingMatrix(options);
        errors.push(...(0, orchestrator_state_completion_1.validateCompletionPrGate)(stateMap, { routingMatrix }));
        if ((0, orchestrator_state_routing_1.routeRequiresCiGate)(stateMap, { routingMatrix })) {
            errors.push(...(0, orchestrator_state_completion_1.validateCompletionCiGate)(stateMap));
        }
        errors.push(...(0, orchestrator_state_routing_1.validatePhaseCompleteness)(stateMap));
        errors.push(...(0, orchestrator_state_preparation_terminal_1.validatePreparationTerminalContract)(stateMap));
        errors.push(...(0, orchestrator_state_routing_1.validateRoutingContract)(stateMap, {
            routingMatrix,
        }));
    }
    // Existence-only model-routing gate; independent of requireComplete and a
    // no-op for delegation-free checkpoints, preserving backward compatibility.
    if (options.requireModelRouting === true) {
        errors.push(...(0, orchestrator_state_model_routing_existence_1.validateModelRoutingExistence)(stateMap));
    }
    errors.push(...(0, orchestrator_state_codex_model_routing_1.validateCodexModelRoutingState)(stateMap, options.requireCodexModelRouting === true));
    errors.push(...(0, orchestrator_state_codex_topology_1.validateCodexTopologyState)(stateMap, options.requireCodexTopology === true));
    return errors;
}
