"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildValidateOrchestrationServiceCallInput = buildValidateOrchestrationServiceCallInput;
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
        ...(input.requireComplete === undefined
            ? {}
            : { requireComplete: input.requireComplete }),
        ...(input.requireModelRouting === undefined
            ? {}
            : { requireModelRouting: input.requireModelRouting }),
        ...(input.requireCodexModelRouting === undefined
            ? {}
            : { requireCodexModelRouting: input.requireCodexModelRouting }),
        ...(input.requireCodexTopology === undefined
            ? {}
            : { requireCodexTopology: input.requireCodexTopology }),
        ...(input.requireReadyForExecution === undefined
            ? {}
            : { requireReadyForExecution: input.requireReadyForExecution }),
    };
}
