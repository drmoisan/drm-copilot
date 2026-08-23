import { type FileSystem } from "../file-system";
import type { CommandRunner } from "../subprocess-runner";
import { type ValidateOrchestrationServiceCallInput } from "./validate-orchestration-service-call";
import {
  selectDefinedValidatorFlagValues,
  VALIDATOR_FLAG_DEFINITIONS,
  type ValidatorFlagValues,
} from "../../mcp-validator-catalog";

export const VALIDATE_ORCHESTRATION_BUILDER_FLAG_OPTIONS =
  VALIDATOR_FLAG_DEFINITIONS.map(({ optionName }) => optionName);

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
export function buildValidateOrchestrationServiceCallInput(
  fileSystem: FileSystem,
  input: {
    readonly workspaceRoot: string;
    readonly artifactType: string;
    readonly artifactPath: string;
  } & ValidatorFlagValues,
  runner?: CommandRunner,
): ValidateOrchestrationServiceCallInput {
  return {
    fileSystem,
    ...(runner === undefined ? {} : { runner }),
    workspaceRoot: input.workspaceRoot,
    artifactType: input.artifactType,
    artifactPath: input.artifactPath,
    ...selectDefinedValidatorFlagValues(input),
  };
}
