import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
  TransitionPreparedOrchestrationRequest,
  TransitionPreparedOrchestrationResult,
} from "../../mcp-repo-automation-tool-definitions-handoff";
import type { HandoffFailureCode } from "./orchestration-handoff-contract";
import { HandoffContractError } from "./orchestration-handoff-contract-support";

/**
 * Request-shaping and blocked-result helpers for the handoff materializer.
 *
 * Extracted from `orchestration-handoff-materializer.ts` to keep that
 * coordinator under the 500-line cap once the independent expected context was
 * added, following the `parallel-state-records.ts` split precedent.
 */

/** A system or synthetic error code: an uppercase identifier such as `EACCES`. */
const HANDOFF_ERROR_CODE_PATTERN = /^[A-Z][A-Z0-9_]*$/;

/** An error class name: an ASCII identifier such as `TypeError`. */
const HANDOFF_ERROR_NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;

/**
 * Build a redaction-safe `<stage>: <token>` cause string for a blocked result.
 *
 * The token is, in order: the error's string `code` when it is an uppercase
 * identifier; otherwise, for an `Error`, its `name` when that name is an ASCII
 * identifier, or the fallback token `Error` when it is not (an empty name or
 * one containing spaces, separators, or path text); otherwise the literal
 * `non-error value`. The error's `message` and `stack` are never read, so no
 * path, environment value, or other host data can reach the cause string.
 *
 * @param stage - Fixed stage label naming the operation that failed.
 * @param error - The caught value.
 * @returns The cause string, for example `checkpoint-read: EACCES`.
 */
export function describeHandoffFailureCause(
  stage: string,
  error: unknown,
): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const code: unknown = error.code;
    if (typeof code === "string" && HANDOFF_ERROR_CODE_PATTERN.test(code)) {
      return `${stage}: ${code}`;
    }
  }
  if (error instanceof Error) {
    return HANDOFF_ERROR_NAME_PATTERN.test(error.name)
      ? `${stage}: ${error.name}`
      : `${stage}: Error`;
  }
  return `${stage}: non-error value`;
}

/**
 * Return the failure code and the `envelope-parse` cause for an error caught
 * while parsing envelope text.
 *
 * A `HandoffContractError` keeps its own code; any other caught value maps to
 * `HANDOFF_UNSUPPORTED_VERSION`. The cause is built by
 * {@link describeHandoffFailureCause}, so it carries no message or host data.
 *
 * @param error - The value caught while parsing the envelope text.
 * @returns The failure code and the cause string, for example
 *   `envelope-parse: HANDOFF_UNSUPPORTED_VERSION`.
 */
export function describeEnvelopeParseFailure(error: unknown): {
  readonly code: HandoffFailureCode;
  readonly failureCause: string;
} {
  return {
    code:
      error instanceof HandoffContractError
        ? error.code
        : "HANDOFF_UNSUPPORTED_VERSION",
    failureCause: describeHandoffFailureCause("envelope-parse", error),
  };
}

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
    readonly failureCause?: string | undefined;
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
    ...(options.failureCause === undefined
      ? {}
      : { failureCause: options.failureCause }),
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
      ...(authority.failureCause === undefined
        ? {}
        : { failureCause: authority.failureCause }),
    },
  );
}
