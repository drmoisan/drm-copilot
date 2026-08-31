import * as path from "node:path";

import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
  TransitionPreparedOrchestrationRequest,
  TransitionPreparedOrchestrationResult,
} from "../../mcp-repo-automation-tool-definitions-handoff";
import type {
  HandoffEnvelope,
  HandoffFailureCode,
} from "./orchestration-handoff-contract";
import {
  candidateFilePath,
  porcelainAffectedPaths,
  resolveWorkspaceFile,
  sha256,
} from "./orchestration-handoff-materializer-support";
import { projectDestinationCheckpoint } from "./orchestration-handoff-provider-adapters";

const textDecoder = new TextDecoder("utf-8", { fatal: true });
const textEncoder = new TextEncoder();

function toReferenceRequest(
  request: TransitionPreparedOrchestrationRequest,
): PortableHandoffReferenceRequest {
  return {
    workspaceRoot: request.workspaceRoot,
    handoffEnvelopePath: request.handoffEnvelopePath,
    expectedHandoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    destinationProvider: request.destinationProvider,
  };
}

function blockedResult(
  request: TransitionPreparedOrchestrationRequest,
  primaryFailureCode: HandoffFailureCode,
  options: {
    readonly handoffId?: string | null;
    readonly handoffHistorySha256?: string | null;
    readonly affectedPaths?: readonly string[];
    readonly unsupportedCapabilities?: readonly string[];
  } = {},
): TransitionPreparedOrchestrationResult {
  return {
    status: "blocked",
    handoffId: options.handoffId ?? null,
    sourceCheckpointSha256: request.expectedSourceCheckpointSha256,
    handoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    handoffHistorySha256: options.handoffHistorySha256 ?? null,
    requestedTransition: "prepared_to_atomic_execution",
    destinationCheckpointPath: null,
    destinationCheckpointSha256: null,
    primaryFailureCode,
    affectedPaths: options.affectedPaths ?? [],
    unsupportedCapabilities: options.unsupportedCapabilities ?? [],
  };
}

function authorityFailure(
  request: TransitionPreparedOrchestrationRequest,
  authority: PortableHandoffAuthorityResult,
  handoffHistorySha256: string,
): TransitionPreparedOrchestrationResult | null {
  if (authority.status === "validated") return null;
  return blockedResult(
    request,
    authority.primaryFailureCode ?? "HANDOFF_VALIDATOR_UNAVAILABLE",
    {
      handoffId: authority.handoffId,
      handoffHistorySha256,
      affectedPaths: authority.affectedPaths,
      unsupportedCapabilities: authority.unsupportedCapabilities,
    },
  );
}

/** Raw-file operations required by the handoff transition write boundary. */
export interface HandoffFileSystemBoundary {
  readonly readFile: (path: string) => Uint8Array;
  readonly createDirectory: (path: string) => void;
  readonly writeFile: (
    path: string,
    content: Uint8Array,
    options?: { readonly exclusive?: boolean },
  ) => void;
  readonly replaceFile: (
    candidatePath: string,
    destinationPath: string,
  ) => void;
  readonly removeFile: (path: string) => void;
}

/** Read-only Git seam returning standard newline-delimited porcelain-v1 text. */
export interface HandoffGitBoundary {
  readonly readPorcelainStatus: (workspaceRoot: string) => Promise<string>;
}

/** Destination topology authority; implementations must not mutate the checkout. */
export interface HandoffTopologyBoundary {
  readonly resolve: (
    request: PortableHandoffReferenceRequest,
  ) => Promise<PortableHandoffAuthorityResult>;
}

/** Destination provider-routing authority; implementations are read-only. */
export interface HandoffRoutingBoundary {
  readonly resolve: (
    request: PortableHandoffReferenceRequest,
  ) => Promise<PortableHandoffAuthorityResult>;
}

export interface HandoffEnvelopeValidationResult {
  readonly envelope: HandoffEnvelope | null;
  readonly primaryFailureCode: HandoffFailureCode | null;
  readonly affectedPaths: readonly string[];
  readonly unsupportedCapabilities: readonly string[];
}

/** Contract and destination-candidate validation seam. */
export interface HandoffValidatorBoundary {
  readonly validateEnvelope: (
    envelopeText: string,
  ) => HandoffEnvelopeValidationResult;
  readonly validateDestinationProjection: (
    projectionText: string,
  ) => readonly string[];
}

/** Injectable clock keeps transition history deterministic under unit tests. */
export interface HandoffClockBoundary {
  readonly nowIso8601: () => string;
}

export interface HandoffMaterializerDependencies {
  readonly fileSystem: HandoffFileSystemBoundary;
  readonly git: HandoffGitBoundary;
  readonly topology: HandoffTopologyBoundary;
  readonly routing: HandoffRoutingBoundary;
  readonly validator: HandoffValidatorBoundary;
  readonly clock: HandoffClockBoundary;
}

interface PreparedTransition {
  readonly result: TransitionPreparedOrchestrationResult;
  readonly sourceBytes: Uint8Array;
  readonly archivePath: string;
  readonly destinationPath: string;
  readonly candidatePath: string;
  readonly projectionBytes: Uint8Array;
  readonly projectionText: string;
}

type TransitionPreparation =
  TransitionPreparedOrchestrationResult | PreparedTransition;

function isPrepared(
  preparation: TransitionPreparation,
): preparation is PreparedTransition {
  return "result" in preparation;
}

/**
 * Materialization coordinator whose entire I/O and authority surface is
 * injected. Ordered tasks add dry-run, dirtiness, archive, candidate, and
 * replacement behavior without introducing filesystem or process globals.
 */
export class OrchestrationHandoffMaterializer {
  constructor(readonly dependencies: HandoffMaterializerDependencies) {}

  async transition(
    request: TransitionPreparedOrchestrationRequest,
  ): Promise<TransitionPreparedOrchestrationResult> {
    const preparation = await this.prepare(request);
    if (!isPrepared(preparation)) return preparation;
    return request.mode === "dry_run"
      ? preparation.result
      : this.stageMaterialization(request, preparation);
  }

  private async prepare(
    request: TransitionPreparedOrchestrationRequest,
  ): Promise<TransitionPreparation> {
    const sourcePath = resolveWorkspaceFile(
      request.workspaceRoot,
      request.sourceCheckpointPath,
    );
    const envelopePath = resolveWorkspaceFile(
      request.workspaceRoot,
      request.handoffEnvelopePath,
    );
    if (sourcePath === null || envelopePath === null) {
      return blockedResult(request, "HANDOFF_PLAN_PATH_INVALID");
    }

    let sourceBytes: Uint8Array;
    let envelopeBytes: Uint8Array;
    try {
      sourceBytes = this.dependencies.fileSystem.readFile(sourcePath);
      envelopeBytes = this.dependencies.fileSystem.readFile(envelopePath);
    } catch {
      return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE");
    }
    if (
      sha256(sourceBytes) !== request.expectedSourceCheckpointSha256 ||
      sha256(envelopeBytes) !== request.expectedHandoffEnvelopeSha256
    ) {
      return blockedResult(request, "HANDOFF_SOURCE_HASH_MISMATCH");
    }

    let envelopeText: string;
    try {
      envelopeText = textDecoder.decode(envelopeBytes);
    } catch {
      return blockedResult(request, "HANDOFF_UNSUPPORTED_VERSION");
    }
    const validation =
      this.dependencies.validator.validateEnvelope(envelopeText);
    if (
      validation.primaryFailureCode !== null ||
      validation.envelope === null
    ) {
      return blockedResult(
        request,
        validation.primaryFailureCode ?? "HANDOFF_VALIDATOR_UNAVAILABLE",
        {
          affectedPaths: validation.affectedPaths,
          unsupportedCapabilities: validation.unsupportedCapabilities,
        },
      );
    }
    const envelope = validation.envelope;
    const lastHistoryEntry = envelope.handoffHistory.at(-1);
    if (lastHistoryEntry === undefined) {
      return blockedResult(request, "HANDOFF_HISTORY_INVALID", {
        handoffId: envelope.handoffId,
      });
    }
    if (
      envelope.source.checkpointPath !== request.sourceCheckpointPath ||
      envelope.source.checkpointSha256 !==
        request.expectedSourceCheckpointSha256
    ) {
      return blockedResult(request, "HANDOFF_SOURCE_HASH_MISMATCH", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
      });
    }
    if (envelope.binding.workspaceRoot !== request.workspaceRoot) {
      return blockedResult(request, "HANDOFF_WORKSPACE_MISMATCH", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
      });
    }
    if (envelope.destinationProvider !== request.destinationProvider) {
      return blockedResult(request, "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
      });
    }
    const archivePath = resolveWorkspaceFile(
      request.workspaceRoot,
      envelope.source.archivePath,
    );
    const destinationPath = resolveWorkspaceFile(
      request.workspaceRoot,
      envelope.destinationCheckpointPath,
    );
    if (archivePath === null || destinationPath === null) {
      return blockedResult(request, "HANDOFF_PLAN_PATH_INVALID", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
      });
    }

    const referenceRequest = toReferenceRequest(request);
    const topology = await this.dependencies.topology.resolve(referenceRequest);
    const topologyFailure = authorityFailure(
      request,
      topology,
      lastHistoryEntry.entrySha256,
    );
    if (topologyFailure !== null) return topologyFailure;
    const routing = await this.dependencies.routing.resolve(referenceRequest);
    const routingFailure = authorityFailure(
      request,
      routing,
      lastHistoryEntry.entrySha256,
    );
    if (routingFailure !== null) return routingFailure;

    let projectionText: string;
    try {
      const projection = projectDestinationCheckpoint({
        envelope,
        envelopeSha256: request.expectedHandoffEnvelopeSha256,
        historyEntrySha256: lastHistoryEntry.entrySha256,
      });
      projectionText = `${JSON.stringify(projection, null, 2)}\n`;
    } catch (error: unknown) {
      return blockedResult(
        request,
        error instanceof Error && "code" in error
          ? (error.code as HandoffFailureCode)
          : "HANDOFF_VALIDATOR_UNAVAILABLE",
        {
          handoffId: envelope.handoffId,
          handoffHistorySha256: lastHistoryEntry.entrySha256,
        },
      );
    }
    const projectionErrors =
      this.dependencies.validator.validateDestinationProjection(projectionText);
    if (projectionErrors.length > 0) {
      return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
        affectedPaths: [envelope.destinationCheckpointPath],
      });
    }
    let porcelainStatus: string;
    try {
      porcelainStatus = await this.dependencies.git.readPorcelainStatus(
        request.workspaceRoot,
      );
    } catch {
      return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
      });
    }
    const affectedPaths = porcelainAffectedPaths(porcelainStatus);
    if (affectedPaths.length > 0) {
      return blockedResult(request, "HANDOFF_DIRTY_WORKTREE", {
        handoffId: envelope.handoffId,
        handoffHistorySha256: lastHistoryEntry.entrySha256,
        affectedPaths,
      });
    }
    const projectionBytes = textEncoder.encode(projectionText);
    const result: TransitionPreparedOrchestrationResult = {
      status: "validated",
      handoffId: envelope.handoffId,
      sourceCheckpointSha256: request.expectedSourceCheckpointSha256,
      handoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
      handoffHistorySha256: lastHistoryEntry.entrySha256,
      requestedTransition: "prepared_to_atomic_execution",
      destinationCheckpointPath: envelope.destinationCheckpointPath,
      destinationCheckpointSha256: sha256(projectionBytes),
      primaryFailureCode: null,
      affectedPaths: [],
      unsupportedCapabilities: [],
    };
    return {
      result,
      sourceBytes,
      archivePath,
      destinationPath,
      candidatePath: candidateFilePath(
        destinationPath,
        request.expectedHandoffEnvelopeSha256,
      ),
      projectionBytes,
      projectionText,
    };
  }

  private stageMaterialization(
    request: TransitionPreparedOrchestrationRequest,
    preparation: PreparedTransition,
  ): TransitionPreparedOrchestrationResult {
    const expectedSourceSha256 = request.expectedSourceCheckpointSha256;
    try {
      this.dependencies.fileSystem.createDirectory(
        path.posix.dirname(preparation.archivePath),
      );
      this.dependencies.fileSystem.writeFile(
        preparation.archivePath,
        preparation.sourceBytes,
        { exclusive: true },
      );
    } catch {
      let archivedBytes: Uint8Array;
      try {
        archivedBytes = this.dependencies.fileSystem.readFile(
          preparation.archivePath,
        );
      } catch {
        return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
          handoffId: preparation.result.handoffId,
          handoffHistorySha256: preparation.result.handoffHistorySha256,
          affectedPaths: [preparation.archivePath],
        });
      }
      if (sha256(archivedBytes) !== expectedSourceSha256) {
        return blockedResult(request, "HANDOFF_SOURCE_HASH_MISMATCH", {
          handoffId: preparation.result.handoffId,
          handoffHistorySha256: preparation.result.handoffHistorySha256,
          affectedPaths: [preparation.archivePath],
        });
      }
    }

    try {
      this.dependencies.fileSystem.writeFile(
        preparation.candidatePath,
        preparation.projectionBytes,
        { exclusive: true },
      );
    } catch {
      let existingCandidate: Uint8Array;
      try {
        existingCandidate = this.dependencies.fileSystem.readFile(
          preparation.candidatePath,
        );
      } catch {
        return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
          handoffId: preparation.result.handoffId,
          handoffHistorySha256: preparation.result.handoffHistorySha256,
          affectedPaths: [preparation.candidatePath],
        });
      }
      if (sha256(existingCandidate) !== sha256(preparation.projectionBytes)) {
        return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
          handoffId: preparation.result.handoffId,
          handoffHistorySha256: preparation.result.handoffHistorySha256,
          affectedPaths: [preparation.candidatePath],
        });
      }
    }

    try {
      const writtenCandidate = this.dependencies.fileSystem.readFile(
        preparation.candidatePath,
      );
      const writtenText = textDecoder.decode(writtenCandidate);
      if (
        sha256(writtenCandidate) !== sha256(preparation.projectionBytes) ||
        this.dependencies.validator.validateDestinationProjection(writtenText)
          .length > 0
      ) {
        throw new Error("Candidate validation failed.");
      }
    } catch {
      try {
        this.dependencies.fileSystem.removeFile(preparation.candidatePath);
      } catch {
        // The blocked result names the retained candidate for explicit cleanup.
      }
      return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
        handoffId: preparation.result.handoffId,
        handoffHistorySha256: preparation.result.handoffHistorySha256,
        affectedPaths: [preparation.candidatePath],
      });
    }
    try {
      this.dependencies.fileSystem.replaceFile(
        preparation.candidatePath,
        preparation.destinationPath,
      );
    } catch {
      return blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", {
        handoffId: preparation.result.handoffId,
        handoffHistorySha256: preparation.result.handoffHistorySha256,
        affectedPaths: [preparation.destinationPath],
      });
    }
    return { ...preparation.result, status: "materialized" };
  }
}
