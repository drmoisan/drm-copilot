"use strict";
/** Result and terminal-status transitions for version-2 remediation state. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateReviewTransitions = validateReviewTransitions;
exports.validateStagnation = validateStagnation;
exports.validateLoopTransition = validateLoopTransition;
const orchestrator_state_remediation_schema_1 = require("./orchestrator-state-remediation-schema");
const NON_ACTIONABLE_STATUS_BY_ACTION = {
    NO_CANDIDATE: "blocked_no_candidate",
    EXTERNAL_RUNTIME: "blocked_external_runtime",
    AWAITING_CI: "awaiting_ci",
    HUMAN_DECISION: "blocked_human_decision",
};
const FALSE_CANDIDATE_STATUS_BY_DISPOSITION = {
    no_candidate: "blocked_no_candidate",
    external_runtime: "blocked_external_runtime",
    awaiting_ci: "awaiting_ci",
    human_decision: "blocked_human_decision",
    execution_failed: "blocked_no_candidate",
};
function transitionError(subject, requirement) {
    return (0, orchestrator_state_remediation_schema_1.codedError)(orchestrator_state_remediation_schema_1.REMEDIATION_TRANSITION_ERROR, subject, requirement);
}
function stagnationError(subject, requirement) {
    return (0, orchestrator_state_remediation_schema_1.codedError)(orchestrator_state_remediation_schema_1.REMEDIATION_STAGNATION_ERROR, subject, requirement);
}
/** Validate completed review verdict, action, and blocker tuples. */
function validateReviewTransitions(loop) {
    const cycles = loop[orchestrator_state_remediation_schema_1.REMEDIATION_CYCLES_KEY];
    if (!Array.isArray(cycles))
        return [];
    const errors = [];
    cycles.forEach((value, index) => {
        if (!(0, orchestrator_state_remediation_schema_1.isObject)(value))
            return;
        const verdict = value["review_verdict"];
        const action = value["remediation_action"];
        const blockingCount = value["blocking_count"];
        const fingerprintBefore = value["blocker_fingerprint_before"];
        const fingerprintAfter = value["blocker_fingerprint_after"];
        const subject = `remediation_loop.cycles[${index}]`;
        if (!(0, orchestrator_state_remediation_schema_1.isFingerprint)(fingerprintBefore)) {
            errors.push(transitionError(`${subject}.blocker_fingerprint_before`, "must identify the actionable source review"));
        }
        if (verdict === "PASS") {
            if (action !== "NONE") {
                errors.push(transitionError(subject, "PASS requires remediation_action NONE"));
            }
            if (fingerprintAfter !== "NONE" || blockingCount !== 0) {
                errors.push(transitionError(subject, "PASS requires fingerprint NONE and blocking_count 0"));
            }
        }
        else if (verdict === "BLOCKED") {
            if (typeof action !== "string" ||
                (action !== "AUTONOMOUS" &&
                    NON_ACTIONABLE_STATUS_BY_ACTION[action] === undefined)) {
                errors.push(transitionError(subject, "BLOCKED requires a documented blocked remediation action"));
            }
            if (!(0, orchestrator_state_remediation_schema_1.isFingerprint)(fingerprintAfter) ||
                !(0, orchestrator_state_remediation_schema_1.isPositiveInteger)(blockingCount)) {
                errors.push(transitionError(subject, "BLOCKED requires a fingerprint and positive blocking_count"));
            }
        }
    });
    return errors;
}
/** Stop unchanged blockers unless one exact consumed exception authorizes them. */
function validateStagnation(loop, authorizedCycleIndices) {
    const cycles = loop[orchestrator_state_remediation_schema_1.REMEDIATION_CYCLES_KEY];
    const attempts = loop["attempts"];
    if (!Array.isArray(cycles) || !Array.isArray(attempts))
        return [];
    const errors = [];
    cycles.forEach((value, index) => {
        if (!(0, orchestrator_state_remediation_schema_1.isObject)(value) || value["review_verdict"] !== "BLOCKED")
            return;
        const before = value["blocker_fingerprint_before"];
        const after = value["blocker_fingerprint_after"];
        if (!(0, orchestrator_state_remediation_schema_1.isFingerprint)(before) || !(0, orchestrator_state_remediation_schema_1.isFingerprint)(after))
            return;
        const unchanged = before === after;
        const attemptId = value["attempt_id"];
        const laterAttempt = (0, orchestrator_state_remediation_schema_1.isPositiveInteger)(attemptId) && attempts.length > attemptId;
        const laterCycle = index < cycles.length - 1;
        const authorized = authorizedCycleIndices.has(index);
        if (unchanged && (laterAttempt || laterCycle) && !authorized) {
            errors.push(stagnationError(`remediation_loop.cycles[${index}]`, "unchanged blockers forbid another attempt or cycle"));
        }
        else if (index === cycles.length - 1 && !authorized) {
            const status = loop["status"];
            if (unchanged && status !== "blocked_stagnation") {
                errors.push(stagnationError("remediation_loop.status", "must be blocked_stagnation for unchanged blockers"));
            }
            else if (!unchanged && status === "blocked_stagnation") {
                errors.push(stagnationError("remediation_loop.status", "cannot be blocked_stagnation for changed blockers"));
            }
        }
    });
    return errors;
}
function allowedTerminalStatuses(loop) {
    const cycles = loop[orchestrator_state_remediation_schema_1.REMEDIATION_CYCLES_KEY];
    const attempts = loop["attempts"];
    if (!Array.isArray(cycles) || !Array.isArray(attempts)) {
        return new Set(orchestrator_state_remediation_schema_1.REMEDIATION_STATUSES);
    }
    const referencedIds = new Set(cycles
        .filter(orchestrator_state_remediation_schema_1.isObject)
        .map((cycle) => cycle["attempt_id"])
        .filter(orchestrator_state_remediation_schema_1.isPositiveInteger));
    const lastAttempt = attempts.at(-1);
    if ((0, orchestrator_state_remediation_schema_1.isObject)(lastAttempt)) {
        const lastAttemptId = lastAttempt["attempt_id"];
        if (!(0, orchestrator_state_remediation_schema_1.isPositiveInteger)(lastAttemptId) ||
            !referencedIds.has(lastAttemptId)) {
            if (lastAttempt["candidate_applied"] === true)
                return new Set(["active"]);
            const disposition = lastAttempt["terminal_disposition"];
            const expected = typeof disposition === "string"
                ? FALSE_CANDIDATE_STATUS_BY_DISPOSITION[disposition]
                : undefined;
            return expected === undefined ? new Set() : new Set([expected]);
        }
    }
    const lastCycle = cycles.at(-1);
    if ((0, orchestrator_state_remediation_schema_1.isObject)(lastCycle)) {
        const verdict = lastCycle["review_verdict"];
        const action = lastCycle["remediation_action"];
        if (verdict === "PASS" && action === "NONE")
            return new Set(["resolved"]);
        const nonActionable = typeof action === "string"
            ? NON_ACTIONABLE_STATUS_BY_ACTION[action]
            : undefined;
        if (verdict === "BLOCKED" && nonActionable !== undefined) {
            return new Set([nonActionable, "blocked_stagnation"]);
        }
        if (verdict === "BLOCKED" && action === "AUTONOMOUS") {
            return loop["completed_cycle_count"] === 3 &&
                loop["max_completed_cycles"] === 3
                ? new Set(["blocked_stagnation", "blocked_remediation_loop_limit"])
                : new Set(["active", "blocked_stagnation"]);
        }
        return new Set();
    }
    return new Set([
        "idle",
        "active",
        "awaiting_ci",
        "blocked_no_candidate",
        "blocked_external_runtime",
        "blocked_human_decision",
        "resolved",
    ]);
}
/** Validate that loop status exactly represents the latest recorded outcome. */
function validateLoopTransition(loop) {
    const status = loop["status"];
    if (typeof status !== "string" || !orchestrator_state_remediation_schema_1.REMEDIATION_STATUSES.has(status))
        return [];
    if (allowedTerminalStatuses(loop).has(status))
        return [];
    return [
        transitionError("remediation_loop.status", `${status} does not match the latest remediation outcome`),
    ];
}
