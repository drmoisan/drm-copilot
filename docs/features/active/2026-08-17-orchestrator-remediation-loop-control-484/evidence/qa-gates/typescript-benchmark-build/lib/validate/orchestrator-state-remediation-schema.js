"use strict";
/** Schema boundary for version-2 orchestrator remediation state. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.REMEDIATION_STATUSES = exports.EXCEPTION_BINDING_FIELDS = exports.EXCEPTION_BINDING_REUSED_ERROR = exports.EXCEPTION_BINDING_INVALID_ERROR = exports.REMEDIATION_STAGNATION_ERROR = exports.REMEDIATION_TRANSITION_ERROR = exports.REMEDIATION_SEQUENCE_ERROR = exports.REMEDIATION_COUNT_ERROR = exports.REMEDIATION_SCHEMA_ERROR = exports.REMEDIATION_SCHEMA_VERSION = exports.REMEDIATION_CYCLES_KEY = void 0;
exports.codedError = codedError;
exports.schemaError = schemaError;
exports.isObject = isObject;
exports.isPositiveInteger = isPositiveInteger;
exports.isNonNegativeInteger = isNonNegativeInteger;
exports.isNonEmptyString = isNonEmptyString;
exports.isFingerprint = isFingerprint;
exports.isIsoTimestamp = isIsoTimestamp;
exports.isVersionedRemediationLoop = isVersionedRemediationLoop;
exports.validateVersionedSchema = validateVersionedSchema;
exports.REMEDIATION_CYCLES_KEY = "cycles";
exports.REMEDIATION_SCHEMA_VERSION = 2;
exports.REMEDIATION_SCHEMA_ERROR = "ORCH_REMEDIATION_SCHEMA";
exports.REMEDIATION_COUNT_ERROR = "ORCH_REMEDIATION_COUNT";
exports.REMEDIATION_SEQUENCE_ERROR = "ORCH_REMEDIATION_SEQUENCE";
exports.REMEDIATION_TRANSITION_ERROR = "ORCH_REMEDIATION_TRANSITION";
exports.REMEDIATION_STAGNATION_ERROR = "ORCH_REMEDIATION_STAGNATION";
exports.EXCEPTION_BINDING_INVALID_ERROR = "ORCH_EXCEPTION_BINDING_INVALID";
exports.EXCEPTION_BINDING_REUSED_ERROR = "ORCH_EXCEPTION_BINDING_REUSED";
const LOOP_REQUIRED_FIELDS = [
    "schema_version",
    "status",
    "max_completed_cycles",
    "attempt_count",
    "completed_cycle_count",
    "last_blocker_fingerprint",
    "attempts",
    exports.REMEDIATION_CYCLES_KEY,
];
const VERSIONED_MARKER_FIELDS = LOOP_REQUIRED_FIELDS.filter((field) => field !== exports.REMEDIATION_CYCLES_KEY);
const ATTEMPT_REQUIRED_FIELDS = [
    "attempt_id",
    "source_review_fingerprint",
    "plan_path",
    "preflight",
    "execution_status",
    "candidate_applied",
    "terminal_disposition",
    "started_at",
    "finished_at",
    "exception_binding",
];
const CYCLE_REQUIRED_FIELDS = [
    "cycle_id",
    "attempt_id",
    "commit_sha",
    "re_audit_path",
    "review_verdict",
    "remediation_action",
    "blocker_fingerprint_before",
    "blocker_fingerprint_after",
    "blocking_count",
    "exit_condition_met",
    "completed_at",
];
exports.EXCEPTION_BINDING_FIELDS = [
    "exception_id",
    "issue_number",
    "blocker_fingerprint",
    "routing_policy_sha256",
    "allowed_transition",
    "single_use",
    "consumed_at",
    "consumed_by_attempt_id",
];
const PREFLIGHT_STATUSES = new Set(["pending", "revisions_required", "clear"]);
const EXECUTION_STATUSES = new Set([
    "not_started",
    "in_progress",
    "complete",
    "failed",
    "awaiting_ci",
    "blocked",
]);
const TERMINAL_DISPOSITIONS = new Set([
    "candidate_applied",
    "no_candidate",
    "external_runtime",
    "awaiting_ci",
    "human_decision",
    "execution_failed",
]);
const REVIEW_VERDICTS = new Set(["PASS", "BLOCKED"]);
const REMEDIATION_ACTIONS = new Set([
    "NONE",
    "AUTONOMOUS",
    "NO_CANDIDATE",
    "EXTERNAL_RUNTIME",
    "AWAITING_CI",
    "HUMAN_DECISION",
]);
exports.REMEDIATION_STATUSES = new Set([
    "idle",
    "active",
    "awaiting_ci",
    "blocked_no_candidate",
    "blocked_external_runtime",
    "blocked_human_decision",
    "blocked_stagnation",
    "blocked_remediation_loop_limit",
    "resolved",
]);
const FINGERPRINT_RE = /^sha256:[0-9a-f]{64}$/;
const OFFSET_TIMESTAMP_RE = /(?:Z|[+-]\d{2}(?::?\d{2})?)$/;
function codedError(code, subject, requirement) {
    return `${code}: ${subject} ${requirement}.`;
}
function schemaError(subject, requirement) {
    return codedError(exports.REMEDIATION_SCHEMA_ERROR, subject, requirement);
}
function isObject(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function isPositiveInteger(value) {
    return typeof value === "number" && Number.isInteger(value) && value > 0;
}
function isNonNegativeInteger(value) {
    return typeof value === "number" && Number.isInteger(value) && value >= 0;
}
function isNonEmptyString(value) {
    return typeof value === "string" && value.trim() !== "";
}
function isFingerprint(value) {
    return typeof value === "string" && FINGERPRINT_RE.test(value);
}
function isFingerprintOrNone(value) {
    return value === "NONE" || isFingerprint(value);
}
function isIsoTimestamp(value, allowNull = false) {
    if (value === null)
        return allowNull;
    return (typeof value === "string" &&
        OFFSET_TIMESTAMP_RE.test(value) &&
        !Number.isNaN(Date.parse(value)));
}
function isEnumValue(value, allowed) {
    return typeof value === "string" && allowed.has(value);
}
function isPreflight(value) {
    return (isObject(value) && isEnumValue(value["final_status"], PREFLIGHT_STATUSES));
}
const ATTEMPT_FIELD_RULES = [
    ["attempt_id", "attempt_id", isPositiveInteger, "must be a positive integer"],
    [
        "source_review_fingerprint",
        "source_review_fingerprint",
        isFingerprint,
        "must be sha256 followed by 64 lowercase hexadecimal characters",
    ],
    ["plan_path", "plan_path", isNonEmptyString, "must be a non-empty string"],
    [
        "preflight",
        "preflight.final_status",
        isPreflight,
        "must be pending, revisions_required, or clear",
    ],
    [
        "execution_status",
        "execution_status",
        (value) => isEnumValue(value, EXECUTION_STATUSES),
        "must be a documented execution status",
    ],
    [
        "candidate_applied",
        "candidate_applied",
        (value) => typeof value === "boolean",
        "must be boolean",
    ],
    [
        "terminal_disposition",
        "terminal_disposition",
        (value) => isEnumValue(value, TERMINAL_DISPOSITIONS),
        "must be a documented terminal disposition",
    ],
    [
        "started_at",
        "started_at",
        isIsoTimestamp,
        "must be an ISO-8601 timestamp with offset",
    ],
    [
        "finished_at",
        "finished_at",
        (value) => isIsoTimestamp(value, true),
        "must be an ISO-8601 timestamp with offset",
    ],
    [
        "exception_binding",
        "exception_binding",
        (value) => value === null || isObject(value),
        "must be an object or null",
    ],
];
const CYCLE_FIELD_RULES = [
    ["cycle_id", "cycle_id", isPositiveInteger, "must be a positive integer"],
    ["attempt_id", "attempt_id", isPositiveInteger, "must be a positive integer"],
    ["commit_sha", "commit_sha", isNonEmptyString, "must be a non-empty string"],
    [
        "re_audit_path",
        "re_audit_path",
        isNonEmptyString,
        "must be a non-empty string",
    ],
    [
        "review_verdict",
        "review_verdict",
        (value) => isEnumValue(value, REVIEW_VERDICTS),
        "must be PASS or BLOCKED",
    ],
    [
        "remediation_action",
        "remediation_action",
        (value) => isEnumValue(value, REMEDIATION_ACTIONS),
        "must be a documented remediation action",
    ],
    [
        "blocker_fingerprint_before",
        "blocker_fingerprint_before",
        isFingerprintOrNone,
        "must be NONE or a fingerprint",
    ],
    [
        "blocker_fingerprint_after",
        "blocker_fingerprint_after",
        isFingerprintOrNone,
        "must be NONE or a fingerprint",
    ],
    [
        "blocking_count",
        "blocking_count",
        isNonNegativeInteger,
        "must be a non-negative integer",
    ],
    [
        "exit_condition_met",
        "exit_condition_met",
        (value) => typeof value === "boolean",
        "must be boolean",
    ],
    [
        "completed_at",
        "completed_at",
        isIsoTimestamp,
        "must be an ISO-8601 timestamp with offset",
    ],
];
function validateRecords(value, collectionName, requiredFields, rules) {
    if (!Array.isArray(value))
        return [];
    const errors = [];
    value.forEach((item, index) => {
        const subject = `remediation_loop.${collectionName}[${index}]`;
        if (!isObject(item)) {
            errors.push(schemaError(subject, "must be an object"));
            return;
        }
        requiredFields.forEach((field) => {
            if (!(field in item)) {
                errors.push(schemaError(subject, `missing required field: ${field}`));
            }
        });
        rules.forEach(([key, label, predicate, requirement]) => {
            if (key in item && !predicate(item[key])) {
                errors.push(schemaError(`${subject}.${label}`, requirement));
            }
        });
    });
    return errors;
}
/** Return whether an object contains any schema-version-2 marker field. */
function isVersionedRemediationLoop(value) {
    return (isObject(value) && VERSIONED_MARKER_FIELDS.some((field) => field in value));
}
/** Validate required version-2 fields and their scalar/container shapes. */
function validateVersionedSchema(loop) {
    const errors = LOOP_REQUIRED_FIELDS.filter((field) => !(field in loop)).map((field) => schemaError("remediation_loop", `missing required field: ${field}`));
    if ("schema_version" in loop &&
        loop["schema_version"] !== exports.REMEDIATION_SCHEMA_VERSION) {
        errors.push(schemaError("remediation_loop.schema_version", `must be ${exports.REMEDIATION_SCHEMA_VERSION}`));
    }
    ["attempts", exports.REMEDIATION_CYCLES_KEY].forEach((key) => {
        if (key in loop && !Array.isArray(loop[key])) {
            errors.push(schemaError(`remediation_loop.${key}`, "must be an array"));
        }
    });
    errors.push(...validateRecords(loop["attempts"], "attempts", ATTEMPT_REQUIRED_FIELDS, ATTEMPT_FIELD_RULES));
    if ("attempt_count" in loop && !isNonNegativeInteger(loop["attempt_count"])) {
        errors.push(codedError(exports.REMEDIATION_COUNT_ERROR, "remediation_loop.attempt_count", "must be a non-negative integer"));
    }
    errors.push(...validateRecords(loop[exports.REMEDIATION_CYCLES_KEY], exports.REMEDIATION_CYCLES_KEY, CYCLE_REQUIRED_FIELDS, CYCLE_FIELD_RULES));
    if ("completed_cycle_count" in loop &&
        !isNonNegativeInteger(loop["completed_cycle_count"])) {
        errors.push(codedError(exports.REMEDIATION_COUNT_ERROR, "remediation_loop.completed_cycle_count", "must be a non-negative integer"));
    }
    if ("status" in loop && !isEnumValue(loop["status"], exports.REMEDIATION_STATUSES)) {
        errors.push(schemaError("remediation_loop.status", "must be a documented status"));
    }
    if ("max_completed_cycles" in loop &&
        (!isPositiveInteger(loop["max_completed_cycles"]) ||
            loop["max_completed_cycles"] > 3)) {
        errors.push(schemaError("remediation_loop.max_completed_cycles", "must be a positive integer no greater than 3"));
    }
    if ("last_blocker_fingerprint" in loop &&
        loop["last_blocker_fingerprint"] !== null &&
        !isFingerprint(loop["last_blocker_fingerprint"])) {
        errors.push(schemaError("remediation_loop.last_blocker_fingerprint", "must be null or a fingerprint"));
    }
    return errors;
}
