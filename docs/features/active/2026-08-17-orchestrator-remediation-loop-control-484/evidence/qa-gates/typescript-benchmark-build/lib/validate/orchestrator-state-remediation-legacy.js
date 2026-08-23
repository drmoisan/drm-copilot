"use strict";
/** Validate legacy remediation aliases before strict checkpoint use. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateLegacyRemediationState = validateLegacyRemediationState;
const orchestrator_state_remediation_schema_1 = require("./orchestrator-state-remediation-schema");
const LEGACY_PASS = "PASS";
const LEGACY_REMEDIATION_REQUIRED = "REMEDIATION_REQUIRED";
function isLegacyNoPath(value) {
    return (value === undefined ||
        value === null ||
        (typeof value === "string" && value.trim() === "NONE"));
}
function isLegacyArtifactPath(value) {
    return (typeof value === "string" && value.trim() !== "" && value.trim() !== "NONE");
}
/** Return Python-equivalent errors for legacy review and remediation aliases. */
function validateLegacyRemediationState(state, strict) {
    const reviewStatus = state["review-status"];
    const inputsPath = state["remediation-inputs-path"];
    const planPath = state["remediation-plan-path"];
    const mappedPass = reviewStatus === LEGACY_PASS &&
        isLegacyNoPath(inputsPath) &&
        isLegacyNoPath(planPath);
    const mappedActionable = reviewStatus === LEGACY_REMEDIATION_REQUIRED &&
        isLegacyArtifactPath(inputsPath) &&
        isLegacyArtifactPath(planPath);
    const hasReviewOutput = (reviewStatus !== undefined && reviewStatus !== null) ||
        !isLegacyNoPath(inputsPath) ||
        !isLegacyNoPath(planPath);
    const errors = [];
    if (hasReviewOutput && !mappedPass && !mappedActionable) {
        const requirement = reviewStatus === LEGACY_PASS
            ? "PASS maps to PASS/NONE and requires both paths to be NONE"
            : reviewStatus === LEGACY_REMEDIATION_REQUIRED
                ? "REMEDIATION_REQUIRED maps to BLOCKED/AUTONOMOUS and requires both remediation paths"
                : "must be PASS or REMEDIATION_REQUIRED with matching paths";
        errors.push((0, orchestrator_state_remediation_schema_1.schemaError)("legacy review output", requirement));
    }
    const hasLegacyRemediation = reviewStatus === LEGACY_REMEDIATION_REQUIRED ||
        !isLegacyNoPath(inputsPath) ||
        !isLegacyNoPath(planPath) ||
        (0, orchestrator_state_remediation_schema_1.isPositiveInteger)(state["remediation-pass"]);
    if (strict &&
        hasLegacyRemediation &&
        !(0, orchestrator_state_remediation_schema_1.isVersionedRemediationLoop)(state["remediation_loop"])) {
        errors.push((0, orchestrator_state_remediation_schema_1.schemaError)("legacy remediation state", "requires evidence-backed schema version 2 migration before strict validation"));
    }
    return errors;
}
