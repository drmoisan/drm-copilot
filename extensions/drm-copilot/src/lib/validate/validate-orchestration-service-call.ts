import * as path from "node:path";
import { type FileSystem, toPosixPath } from "../file-system";
import { validateArtifact } from "./orchestration-artifacts";

/**
 * In-process orchestration-artifact validation wiring.
 *
 * Purpose:
 *     Hold the body previously inlined in
 *     `RepoAutomationService.validateOrchestrationArtifacts`, so the service
 *     file stays within the 500-line limit while preserving the method's
 *     observable behavior, summary string, and thrown-error format exactly.
 *
 * Responsibilities:
 *     - Resolve the artifact path relative to the workspace root using the F1
 *       forward-slash path convention.
 *     - Read the artifact text through the injected {@link FileSystem}.
 *     - Dispatch validation via `validateArtifact` and either return the
 *       preserved success result or throw with the preserved error format.
 *
 * Side effects:
 *     Reads from the injected {@link FileSystem}; performs no other I/O.
 */

/** Input for the in-process validation wiring. */
export interface ValidateOrchestrationServiceCallInput {
  /** Injected filesystem used to read the artifact and route orchestrator-state. */
  readonly fileSystem: FileSystem;
  /** Repository/workspace root the artifact path is resolved against. */
  readonly workspaceRoot: string;
  /** Artifact type selecting the validator route. */
  readonly artifactType: string;
  /** Artifact path relative to `workspaceRoot`. */
  readonly artifactPath: string;
  /** Require completion-safe state (orchestrator-state route only). */
  readonly requireComplete?: boolean;
  /** Require model-routing receipts once delegated (orchestrator-state route). */
  readonly requireModelRouting?: boolean;
}

/** Preserved success result of a successful in-process validation. */
export interface ValidateOrchestrationServiceCallResult {
  readonly tool: "validate_orchestration_artifacts";
  readonly workspaceRoot: string;
  readonly summary: string;
}

/**
 * Validate an orchestration artifact in-process.
 *
 * @param input Filesystem, workspace root, artifact type/path, and optional
 *     completion flag.
 * @returns The preserved success result object on success.
 * @throws Error When the selected validator reports one or more errors; the
 *     message lists the validation errors using the preserved format.
 */
export function validateOrchestrationServiceCall(
  input: ValidateOrchestrationServiceCallInput,
): ValidateOrchestrationServiceCallResult {
  // Resolve the artifact path relative to the workspace root, matching the
  // Python `Path(args.path)` semantics, then validate in-process. The path is
  // normalized to forward slashes to match the F1 FileSystem path convention.
  const artifactFullPath = toPosixPath(
    path.join(input.workspaceRoot, input.artifactPath),
  );
  const text = input.fileSystem.readTextFile(artifactFullPath);
  const errors = validateArtifact({
    artifactType: input.artifactType,
    text,
    ...(input.requireComplete === undefined
      ? {}
      : { requireComplete: input.requireComplete }),
    ...(input.requireModelRouting === undefined
      ? {}
      : { requireModelRouting: input.requireModelRouting }),
    fs: input.fileSystem,
    root: input.workspaceRoot,
  });

  // Surface validation failure as a thrown error so the MCP handler reports a
  // non-zero outcome, mirroring the Python stderr-per-line, exit-1 behavior.
  if (errors.length > 0) {
    throw new Error(
      `Validation failed for ${input.artifactType} artifact at ` +
        `'${input.artifactPath}':\n${errors.join("\n")}`,
    );
  }

  // Preserve the existing success summary string.
  return {
    tool: "validate_orchestration_artifacts",
    workspaceRoot: input.workspaceRoot,
    summary: `Validated ${input.artifactType} artifact at '${input.artifactPath}'.`,
  };
}
