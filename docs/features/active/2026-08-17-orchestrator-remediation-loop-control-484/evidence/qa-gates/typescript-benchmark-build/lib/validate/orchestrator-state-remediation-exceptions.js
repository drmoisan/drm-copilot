"use strict";
/** Validate exact, single-use remediation stagnation exceptions. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateExceptionBindings = validateExceptionBindings;
const orchestrator_state_remediation_schema_1 = require("./orchestrator-state-remediation-schema");
const STAGNATION_CONTINUATION = "blocked_stagnation_to_active";
const WILDCARD_RE = /[*?[\]]/u;
function invalid(subject, requirement) {
    return (0, orchestrator_state_remediation_schema_1.codedError)(orchestrator_state_remediation_schema_1.EXCEPTION_BINDING_INVALID_ERROR, subject, requirement);
}
function issueToken(value) {
    if ((0, orchestrator_state_remediation_schema_1.isPositiveInteger)(value))
        return String(value);
    if (typeof value !== "string")
        return undefined;
    const token = value.trim();
    return /^\d+$/u.test(token) ? token : undefined;
}
function isExactString(value) {
    return (typeof value === "string" && value.trim() !== "" && !WILDCARD_RE.test(value));
}
function unchangedCycleByNextAttempt(cycles) {
    const result = new Map();
    cycles.forEach((value, index) => {
        if (!(0, orchestrator_state_remediation_schema_1.isObject)(value))
            return;
        const attemptId = value["attempt_id"];
        const before = value["blocker_fingerprint_before"];
        const after = value["blocker_fingerprint_after"];
        if (value["review_verdict"] === "BLOCKED" &&
            (0, orchestrator_state_remediation_schema_1.isPositiveInteger)(attemptId) &&
            (0, orchestrator_state_remediation_schema_1.isFingerprint)(before) &&
            before === after) {
            result.set(attemptId + 1, [index, before]);
        }
    });
    return result;
}
/** Return ordered binding errors and cycle indexes authorized exactly once. */
function validateExceptionBindings(loop, context) {
    const attempts = loop["attempts"];
    const cycles = loop[orchestrator_state_remediation_schema_1.REMEDIATION_CYCLES_KEY];
    if (!Array.isArray(attempts) || !Array.isArray(cycles))
        return [[], new Set()];
    const expectedIssue = issueToken(context.issueNumber);
    const priorByAttempt = unchangedCycleByNextAttempt(cycles);
    const errors = [];
    const exceptionIds = [];
    const candidates = [];
    attempts.forEach((value, index) => {
        if (!(0, orchestrator_state_remediation_schema_1.isObject)(value) || !(0, orchestrator_state_remediation_schema_1.isObject)(value["exception_binding"]))
            return;
        const binding = value["exception_binding"];
        const subject = `remediation_loop.attempts[${index}].exception_binding`;
        const localErrors = [];
        const keys = Object.keys(binding);
        if (keys.length !== orchestrator_state_remediation_schema_1.EXCEPTION_BINDING_FIELDS.length ||
            !orchestrator_state_remediation_schema_1.EXCEPTION_BINDING_FIELDS.every((field) => field in binding)) {
            localErrors.push(invalid(subject, "must contain exactly the canonical fields"));
        }
        const exceptionId = binding["exception_id"];
        if (!isExactString(exceptionId)) {
            localErrors.push(invalid(`${subject}.exception_id`, "must be exact"));
        }
        else {
            exceptionIds.push(exceptionId);
        }
        const attemptId = value["attempt_id"];
        const prior = (0, orchestrator_state_remediation_schema_1.isPositiveInteger)(attemptId)
            ? priorByAttempt.get(attemptId)
            : undefined;
        if (prior === undefined) {
            localErrors.push(invalid(subject, "must bind the next attempt after unchanged blockers"));
        }
        const expectedFingerprint = prior?.[1];
        if (binding["blocker_fingerprint"] !== expectedFingerprint) {
            localErrors.push(invalid(`${subject}.blocker_fingerprint`, "must match both blockers"));
        }
        if (value["source_review_fingerprint"] !== expectedFingerprint) {
            localErrors.push(invalid(subject, "must match the consuming attempt source fingerprint"));
        }
        if (issueToken(binding["issue_number"]) !== expectedIssue ||
            expectedIssue === undefined) {
            localErrors.push(invalid(`${subject}.issue_number`, "must match the checkpoint issue"));
        }
        if (!(0, orchestrator_state_remediation_schema_1.isFingerprint)(context.routingPolicySha256) ||
            binding["routing_policy_sha256"] !== context.routingPolicySha256) {
            localErrors.push(invalid(`${subject}.routing_policy_sha256`, "must match the current routing policy"));
        }
        if (binding["allowed_transition"] !== STAGNATION_CONTINUATION) {
            localErrors.push(invalid(`${subject}.allowed_transition`, `must be ${STAGNATION_CONTINUATION}`));
        }
        if (binding["single_use"] !== true) {
            localErrors.push(invalid(`${subject}.single_use`, "must be true"));
        }
        const consumedAt = binding["consumed_at"];
        const consumedBy = binding["consumed_by_attempt_id"];
        const consumed = consumedAt != null || consumedBy != null;
        if (consumedAt == null && consumedBy == null) {
            // An unused exact binding is valid but does not authorize continuation.
        }
        else if (!(0, orchestrator_state_remediation_schema_1.isIsoTimestamp)(consumedAt) ||
            !(0, orchestrator_state_remediation_schema_1.isPositiveInteger)(consumedBy) ||
            consumedBy !== attemptId) {
            localErrors.push(invalid(subject, "consumption fields must be paired to this attempt"));
        }
        errors.push(...localErrors);
        if (localErrors.length === 0 &&
            consumed &&
            typeof exceptionId === "string" &&
            prior !== undefined) {
            candidates.push([exceptionId, prior[0]]);
        }
    });
    const counts = new Map();
    exceptionIds.forEach((id) => counts.set(id, (counts.get(id) ?? 0) + 1));
    const reused = [...counts]
        .filter((entry) => entry[1] > 1)
        .map(([id]) => id)
        .sort();
    reused.forEach((exceptionId) => {
        errors.push((0, orchestrator_state_remediation_schema_1.codedError)(orchestrator_state_remediation_schema_1.EXCEPTION_BINDING_REUSED_ERROR, `exception_id ${exceptionId}`, "must be consumed only once"));
    });
    const reusedSet = new Set(reused);
    const authorized = new Set(candidates
        .filter(([exceptionId]) => !reusedSet.has(exceptionId))
        .map(([, cycleIndex]) => cycleIndex));
    return [errors, authorized];
}
