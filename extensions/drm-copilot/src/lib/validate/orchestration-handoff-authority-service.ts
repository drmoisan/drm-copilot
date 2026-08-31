import { createHash } from "node:crypto";
import * as path from "node:path";

import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
} from "../../mcp-repo-automation-tool-definitions-handoff";
import type { FileSystem } from "../file-system";
import { toPosixPath } from "../file-system";
import {
  HandoffContractError,
  collectHandoffValidationFailures,
  parseHandoffEnvelopeText,
  selectPrimaryHandoffFailure,
} from "./orchestration-handoff-contract";
import type {
  HandoffEnvelope,
  HandoffFailureCode,
} from "./orchestration-handoff-contract";

export type PortableAuthorityKind = "topology" | "provider_routing";

const SUPPORTED_CAPABILITIES = [
  "handoff-schema:2",
  "transition:prepared_to_atomic_execution",
  "plan-contract:atomic-plan-v1",
  "semantic-tool:drm-copilot.validate_orchestration_artifacts",
  "semantic-tool:drm-copilot.resolve_orchestration_topology",
  "semantic-tool:drm-copilot.resolve_provider_routing",
  "semantic-tool:drm-copilot.transition_prepared_orchestration",
  "workspace-explicit-validation",
  "workspace-explicit-routing",
  "atomic-checkpoint-materialization",
  "scheduler-context:ordinary",
  "scheduler-context:parallel-child",
  "scheduler-context:epic-child",
  "scheduler-return:portable_child_result-v1",
] as const;

function sha256(text: string): string {
  return createHash("sha256").update(text, "utf8").digest("hex");
}

function resolveWorkspaceFile(
  workspaceRoot: string,
  repositoryPath: string,
): string | null {
  const root = toPosixPath(path.resolve(workspaceRoot)).replace(/\/+$/, "");
  const candidate = toPosixPath(path.resolve(workspaceRoot, repositoryPath));
  return candidate.startsWith(`${root}/`) ? candidate : null;
}

function blocked(
  request: PortableHandoffReferenceRequest,
  code: HandoffFailureCode,
  options: {
    readonly handoffId?: string | null;
    readonly affectedPaths?: readonly string[];
    readonly unsupportedCapabilities?: readonly string[];
  } = {},
): PortableHandoffAuthorityResult {
  return {
    status: "blocked",
    handoffId: options.handoffId ?? null,
    handoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    primaryFailureCode: code,
    affectedPaths: options.affectedPaths ?? [],
    unsupportedCapabilities: options.unsupportedCapabilities ?? [],
    resolution: null,
  };
}

function readEnvelope(
  fileSystem: FileSystem,
  request: PortableHandoffReferenceRequest,
): HandoffEnvelope | PortableHandoffAuthorityResult {
  const envelopePath = resolveWorkspaceFile(
    request.workspaceRoot,
    request.handoffEnvelopePath,
  );
  if (envelopePath === null) {
    return blocked(request, "HANDOFF_PLAN_PATH_INVALID");
  }
  let envelopeText: string;
  try {
    envelopeText = fileSystem.readTextFile(envelopePath);
  } catch {
    return blocked(request, "HANDOFF_VALIDATOR_UNAVAILABLE");
  }
  if (sha256(envelopeText) !== request.expectedHandoffEnvelopeSha256) {
    return blocked(request, "HANDOFF_SOURCE_HASH_MISMATCH");
  }
  try {
    return parseHandoffEnvelopeText(envelopeText);
  } catch (error: unknown) {
    return blocked(
      request,
      error instanceof HandoffContractError
        ? error.code
        : "HANDOFF_UNSUPPORTED_VERSION",
    );
  }
}

function observedPlanSha256(
  fileSystem: FileSystem,
  request: PortableHandoffReferenceRequest,
  envelope: HandoffEnvelope,
): string | null {
  const planPath = resolveWorkspaceFile(
    request.workspaceRoot,
    envelope.plan.path,
  );
  if (planPath === null) return null;
  try {
    return sha256(fileSystem.readTextFile(planPath));
  } catch {
    return null;
  }
}

function buildResolution(
  kind: PortableAuthorityKind,
  envelope: HandoffEnvelope,
): Readonly<Record<string, unknown>> {
  if (kind === "topology") {
    return {
      kind: "destination_topology",
      provider: envelope.destinationProvider,
      logical_complexity: envelope.lifecycle.logicalComplexity,
      scheduler_kind: envelope.schedulerContext.kind,
      execution_owner: "ordinary_orchestrator",
      topology_policy:
        envelope.destinationProvider === "codex"
          ? "codex_topology_policy"
          : "claude_native_worktree_policy",
    };
  }
  return {
    kind: "provider_routing",
    provider: envelope.destinationProvider,
    logical_complexity: envelope.lifecycle.logicalComplexity,
    routing_policy:
      envelope.destinationProvider === "codex"
        ? "codex_model_policy"
        : "model_policy",
    source_evidence_mode: "opaque",
  };
}

export function resolvePortableHandoffAuthority(
  fileSystem: FileSystem,
  request: PortableHandoffReferenceRequest,
  kind: PortableAuthorityKind,
): PortableHandoffAuthorityResult {
  const envelopeOrFailure = readEnvelope(fileSystem, request);
  if ("status" in envelopeOrFailure) return envelopeOrFailure;
  const envelope = envelopeOrFailure;
  if (request.destinationProvider !== envelope.destinationProvider) {
    return blocked(request, "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE", {
      handoffId: envelope.handoffId,
    });
  }
  const planSha256 = observedPlanSha256(fileSystem, request, envelope);
  if (planSha256 === null) {
    return blocked(request, "HANDOFF_PLAN_PATH_INVALID", {
      handoffId: envelope.handoffId,
    });
  }
  const validation = collectHandoffValidationFailures(envelope, {
    repositoryId: envelope.binding.repositoryId,
    workspaceRoot: request.workspaceRoot,
    branch: envelope.binding.branch,
    sourceHeadRelationshipValid: true,
    issueNumber: envelope.identity.issueNumber,
    featureFolder: envelope.identity.featureFolder,
    workMode: envelope.identity.workMode,
    planPath: envelope.plan.path,
    planSha256,
    expectedSchedulerContext: envelope.schedulerContext,
    requestedTransition: "prepared_to_atomic_execution",
    transitionState: "preparation_complete",
    requestedPhase: envelope.lifecycle.nextTransition,
    supportedCapabilities: SUPPORTED_CAPABILITIES,
    supportedVocabularies: ["portable-orchestration-handoff-core-v1"],
    validatorAvailable: true,
    topologyResolverAvailable: true,
    providerRoutingAvailable: true,
    evaluateDirtyWorktree: () => [],
  });
  const primaryFailureCode = selectPrimaryHandoffFailure(validation.failures);
  if (primaryFailureCode !== null) {
    return blocked(request, primaryFailureCode, {
      handoffId: envelope.handoffId,
      affectedPaths: validation.affectedPaths,
      unsupportedCapabilities: validation.unsupportedCapabilities,
    });
  }
  return {
    status: "validated",
    handoffId: envelope.handoffId,
    handoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    primaryFailureCode: null,
    affectedPaths: [],
    unsupportedCapabilities: [],
    resolution: buildResolution(kind, envelope),
  };
}
