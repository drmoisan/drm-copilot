"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.VALIDATE_ORCHESTRATION_BUILDER_FLAG_OPTIONS = void 0;
exports.buildValidateOrchestrationServiceCallInput = buildValidateOrchestrationServiceCallInput;
const mcp_validator_catalog_1 = require("../../mcp-validator-catalog");
exports.VALIDATE_ORCHESTRATION_BUILDER_FLAG_OPTIONS = mcp_validator_catalog_1.VALIDATOR_FLAG_DEFINITIONS.map(({ optionName }) => optionName);
/**
 * Assemble the {@link ValidateOrchestrationServiceCallInput} for an in-process
 * orchestration-artifact validation call.
 *
 * Purpose:
 *     Extracted from `RepoAutomationService.validateOrchestrationArtifacts` to
 *     keep the service file within the 500-line limit while preserving the
 *     request-shaping behavior exactly. The optional `requireComplete` and
 *     validation-option keys are omitted entirely when their source value is
 *     `undefined`, preserving downstream `exactOptionalPropertyTypes` behavior.
 *
 * Side effects:
 *     None. Pure object construction.
 *
 * @param fileSystem Injected filesystem used to read the artifact.
 * @param input Request fields sourced from the service method input.
 * @returns The validation-call input with optional keys present only when
 *     defined.
 */
function buildValidateOrchestrationServiceCallInput(fileSystem, input, runner) {
    return {
        fileSystem,
        ...(runner === undefined ? {} : { runner }),
        workspaceRoot: input.workspaceRoot,
        artifactType: input.artifactType,
        artifactPath: input.artifactPath,
        ...(0, mcp_validator_catalog_1.selectDefinedValidatorFlagValues)(input),
    };
}
