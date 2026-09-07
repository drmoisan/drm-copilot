import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
  TransitionPreparedOrchestrationRequest,
  TransitionPreparedOrchestrationResult,
} from "../../mcp-repo-automation-tool-definitions-handoff";
import type { HandoffFailureCode } from "./orchestration-handoff-contract";

/**
 * Request-shaping and blocked-result helpers for the handoff materializer.
 *
 * Extracted from `orchestration-handoff-materializer.ts` to keep that
 * coordinator under the 500-line cap once the independent expected context was
 * added, following the `parallel-state-records.ts` split precedent.
 */

/**
 * Narrow a transition request to its reference shape while carrying the entire
 * caller-supplied independent context, so both authorities validate against the
 * same expected checkout rather than against the envelope under transition.
 */
export function toReferenceRequest(
  request: TransitionPreparedOrchestrationRequest,
): PortableHandoffReferenceRequest {
  return {
    workspaceRoot: request.workspaceRoot,
    handoffEnvelopePath: request.handoffEnvelopePath,
    expectedHandoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    destinationProvider: request.destinationProvider,
    expectedRepositoryId: request.expectedRepositoryId,
    expectedWorkspaceRoot: request.expectedWorkspaceRoot,
    expectedBranch: request.expectedBranch,
    expectedSourceHeadSha: request.expectedSourceHeadSha,
    allowedHeadRelationship: request.allowedHeadRelationship,
    expectedIssueNumber: request.expectedIssueNumber,
    expectedFeatureFolder: request.expectedFeatureFolder,
    expectedWorkMode: request.expectedWorkMode,
    expectedPlanPath: request.expectedPlanPath,
    expectedPlanSha256: request.expectedPlanSha256,
  };
}

export function blockedResult(
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

export function authorityFailure(
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
