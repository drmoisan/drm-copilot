import { type FileSystem } from "../file-system";
import { type ValidateOrchestrationServiceCallInput } from "./validate-orchestration-service-call";

/**
 * Assemble the {@link ValidateOrchestrationServiceCallInput} for an in-process
 * orchestration-artifact validation call.
 *
 * Purpose:
 *     Extracted from `RepoAutomationService.validateOrchestrationArtifacts` to
 *     keep the service file within the 500-line limit while preserving the
 *     request-shaping behavior exactly. The optional `requireComplete` and
 *     `requireModelRouting` keys are omitted entirely when their source value is
 *     `undefined`, matching the prior inline spread semantics so downstream
 *     `exactOptionalPropertyTypes` behavior is unchanged.
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
    readonly requireComplete?: boolean;
    readonly requireModelRouting?: boolean;
  },
): ValidateOrchestrationServiceCallInput {
  return {
    fileSystem,
    workspaceRoot: input.workspaceRoot,
    artifactType: input.artifactType,
    artifactPath: input.artifactPath,
    ...(input.requireComplete === undefined
      ? {}
      : { requireComplete: input.requireComplete }),
    ...(input.requireModelRouting === undefined
      ? {}
      : { requireModelRouting: input.requireModelRouting }),
  };
}
