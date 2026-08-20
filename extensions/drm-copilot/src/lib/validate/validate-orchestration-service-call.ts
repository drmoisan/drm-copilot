import * as path from "node:path";
import { type FileSystem, toPosixPath } from "../file-system";
import type { CommandRunner } from "../subprocess-runner";
import { validateArtifactWithWarnings } from "./orchestration-artifacts";

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
  /** Injected runner used for readiness Git integrity checks. */
  readonly runner?: CommandRunner;
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
  /** Require canonical Codex deployment receipts for delegated agents. */
  readonly requireCodexModelRouting?: boolean;
  /** Require canonical Codex topology receipts for delegated agents. */
  readonly requireCodexTopology?: boolean;
  /** Require every planned epic child to be execution-ready. */
  readonly requireReadyForExecution?: boolean;
}

/** Preserved success result of a successful in-process validation. */
export interface ValidateOrchestrationServiceCallResult {
  readonly tool: "validate_orchestration_artifacts";
  readonly workspaceRoot: string;
  readonly summary: string;
  /**
   * Plan acceptance-gate Warnings, present only when the run produced at least
   * one. A warning-free result is byte-identical to the pre-change shape.
   */
  readonly warnings?: ReadonlyArray<string>;
}

/** Prefix every surfaced plan-gate Warning line carries. */
export const PLAN_GATE_WARNING_PREFIX = "PLAN GATE WARNING: ";

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
  const { errors, warnings } = validateArtifactWithWarnings({
    artifactType: input.artifactType,
    text,
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
    artifactPath: artifactFullPath,
    ...(input.runner === undefined ? {} : { runner: input.runner }),
    fs: input.fileSystem,
    root: input.workspaceRoot,
  });

  // Surface validation failure as a thrown error so the MCP handler reports a
  // non-zero outcome, mirroring the Python stderr-per-line, exit-1 behavior.
  // Warnings never fail the call; they are appended after the error block so a
  // warning-free failure message is byte-identical to the pre-change format.
  if (errors.length > 0) {
    const warningBlock =
      warnings.length === 0
        ? ""
        : "\n" +
          warnings
            .map((warning) => `${PLAN_GATE_WARNING_PREFIX}${warning}`)
            .join("\n");
    throw new Error(
      `Validation failed for ${input.artifactType} artifact at ` +
        `'${input.artifactPath}':\n${errors.join("\n")}${warningBlock}`,
    );
  }

  // Preserve the existing success summary string. The warnings key is present
  // only when the run produced at least one Warning.
  return {
    tool: "validate_orchestration_artifacts",
    workspaceRoot: input.workspaceRoot,
    summary: `Validated ${input.artifactType} artifact at '${input.artifactPath}'.`,
    ...(warnings.length === 0 ? {} : { warnings }),
  };
}
