import { createHash } from "node:crypto";
import * as path from "node:path";

import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
} from "../../mcp-repo-automation-tool-definitions-handoff";
import { RealFileSystem, toPosixPath, type FileSystem } from "../file-system";
import { SubprocessRunner } from "../subprocess-runner";
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
import {
  createGitCheckoutContext,
  type CheckoutObservation,
  type HandoffCheckoutContext,
} from "./orchestration-handoff-checkout-context";
import {
  createNodeHandoffPathBoundary,
  type HandoffPathBoundary,
} from "./orchestration-handoff-path-boundary";

/** Observed variant of {@link CheckoutObservation}, narrowed for comparison. */
type ObservedCheckout = Extract<CheckoutObservation, { status: "observed" }>;

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

function createDefaultPathBoundary(
  fileSystem: FileSystem,
): HandoffPathBoundary {
  if (fileSystem instanceof RealFileSystem) {
    return createNodeHandoffPathBoundary();
  }
  const resolveWorkspaceRoot = (workspaceRoot: string): string | null => {
    if (!path.isAbsolute(workspaceRoot)) return null;
    return toPosixPath(path.resolve(workspaceRoot)).replace(/\/+$/, "");
  };
  const resolveExistingTarget = (
    canonicalWorkspaceRoot: string,
    repositoryPath: string,
  ): string | null => {
    if (
      repositoryPath.length === 0 ||
      repositoryPath.includes("\\") ||
      repositoryPath.includes(":") ||
      path.posix.isAbsolute(repositoryPath) ||
      path.posix.normalize(repositoryPath) !== repositoryPath ||
      repositoryPath
        .split("/")
        .some((segment) => segment === "." || segment === "..")
    ) {
      return null;
    }
    const candidate = toPosixPath(
      path.resolve(canonicalWorkspaceRoot, repositoryPath),
    );
    const root = toPosixPath(canonicalWorkspaceRoot).replace(/\/+$/, "");
    return candidate.startsWith(`${root}/`) && fileSystem.isFile(candidate)
      ? candidate
      : null;
  };
  return {
    resolveWorkspaceRoot,
    resolveExistingTarget,
    resolveCreatableTarget: () => null,
  };
}

function sha256(text: string): string {
  return createHash("sha256").update(text, "utf8").digest("hex");
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
  pathBoundary: HandoffPathBoundary,
  canonicalWorkspaceRoot: string,
): HandoffEnvelope | PortableHandoffAuthorityResult {
  const envelopePath = pathBoundary.resolveExistingTarget(
    canonicalWorkspaceRoot,
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

/**
 * Hash the plan the caller independently expects, never the plan the envelope
 * names, so a rewritten envelope cannot redirect the hash that proves it.
 */
function observedPlanSha256(
  fileSystem: FileSystem,
  expectedPlanPath: string,
  pathBoundary: HandoffPathBoundary,
  canonicalWorkspaceRoot: string,
): string | null {
  const planPath = pathBoundary.resolveExistingTarget(
    canonicalWorkspaceRoot,
    expectedPlanPath,
  );
  if (planPath === null) return null;
  try {
    return sha256(fileSystem.readTextFile(planPath));
  } catch {
    return null;
  }
}

/** Normalize a caller-supplied absolute path to the observed POSIX form. */
function canonicalizeObservedPath(value: string): string {
  return toPosixPath(value.trim()).replace(/(.)\/+$/, "$1");
}

/**
 * Compare the independently observed checkout against the caller's expected
 * context. Each disagreement selects its registry failure code directly, so an
 * envelope that agrees with itself cannot mask a checkout that disagrees.
 */
function collectObservationFailures(
  request: PortableHandoffReferenceRequest,
  observation: ObservedCheckout,
  headRelationshipValid: boolean,
): readonly HandoffFailureCode[] {
  const failures: HandoffFailureCode[] = [];
  if (observation.repositoryId !== request.expectedRepositoryId) {
    failures.push("HANDOFF_REPOSITORY_MISMATCH");
  }
  if (
    canonicalizeObservedPath(observation.workspaceRoot) !==
    canonicalizeObservedPath(request.expectedWorkspaceRoot)
  ) {
    failures.push("HANDOFF_WORKSPACE_MISMATCH");
  }
  if (observation.branch !== request.expectedBranch || !headRelationshipValid) {
    failures.push("HANDOFF_BRANCH_LINEAGE_MISMATCH");
  }
  return failures;
}

/**
 * Failures decidable before the plan is read. The destination-routing check
 * consults this set so provider routing can never preempt an earlier binding
 * failure that the registry orders ahead of it.
 */
function collectPrePlanFailures(
  envelope: HandoffEnvelope,
  request: PortableHandoffReferenceRequest,
  observationFailures: readonly HandoffFailureCode[],
): readonly HandoffFailureCode[] {
  const failures: HandoffFailureCode[] = [...observationFailures];
  if (request.expectedRepositoryId !== envelope.binding.repositoryId) {
    failures.push("HANDOFF_REPOSITORY_MISMATCH");
  }
  if (request.expectedWorkspaceRoot !== envelope.binding.workspaceRoot) {
    failures.push("HANDOFF_WORKSPACE_MISMATCH");
  }
  if (
    request.expectedIssueNumber !== envelope.identity.issueNumber ||
    request.expectedFeatureFolder !== envelope.identity.featureFolder ||
    request.expectedWorkMode !== envelope.identity.workMode
  ) {
    failures.push("HANDOFF_ISSUE_FEATURE_MISMATCH");
  }
  if (request.expectedBranch !== envelope.binding.branch) {
    failures.push("HANDOFF_BRANCH_LINEAGE_MISMATCH");
  }
  return failures;
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
  pathBoundary?: HandoffPathBoundary,
  checkoutContext?: HandoffCheckoutContext,
): PortableHandoffAuthorityResult {
  const effectivePathBoundary =
    pathBoundary ?? createDefaultPathBoundary(fileSystem);
  const canonicalWorkspaceRoot = effectivePathBoundary.resolveWorkspaceRoot(
    request.workspaceRoot,
  );
  if (canonicalWorkspaceRoot === null) {
    return blocked(request, "HANDOFF_PLAN_PATH_INVALID");
  }
  // The checkout is observed before the envelope is read, so the independent
  // context is established without any input from the envelope it will prove.
  const effectiveCheckoutContext =
    checkoutContext ?? createGitCheckoutContext(new SubprocessRunner());
  const observation = effectiveCheckoutContext.observe(
    request.expectedWorkspaceRoot,
  );
  if (observation.status !== "observed") {
    return blocked(request, "HANDOFF_VALIDATOR_UNAVAILABLE");
  }
  const headRelationshipValid =
    effectiveCheckoutContext.isHeadRelationshipSatisfied({
      workspaceRoot: request.expectedWorkspaceRoot,
      expectedSourceHeadSha: request.expectedSourceHeadSha,
      observedHeadSha: observation.headSha,
      allowedHeadRelationship: request.allowedHeadRelationship,
    });
  const observationFailures = collectObservationFailures(
    request,
    observation,
    headRelationshipValid,
  );
  const envelopeOrFailure = readEnvelope(
    fileSystem,
    request,
    effectivePathBoundary,
    canonicalWorkspaceRoot,
  );
  if ("status" in envelopeOrFailure) return envelopeOrFailure;
  const envelope = envelopeOrFailure;
  const prePlanFailures = collectPrePlanFailures(
    envelope,
    request,
    observationFailures,
  );
  if (
    prePlanFailures.length === 0 &&
    request.destinationProvider !== envelope.destinationProvider
  ) {
    return blocked(request, "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE", {
      handoffId: envelope.handoffId,
    });
  }
  const planSha256 = observedPlanSha256(
    fileSystem,
    request.expectedPlanPath,
    effectivePathBoundary,
    canonicalWorkspaceRoot,
  );
  if (planSha256 === null) {
    return blocked(request, "HANDOFF_PLAN_PATH_INVALID", {
      handoffId: envelope.handoffId,
    });
  }
  const validation = collectHandoffValidationFailures(envelope, {
    repositoryId: request.expectedRepositoryId,
    workspaceRoot: request.expectedWorkspaceRoot,
    branch: request.expectedBranch,
    sourceHeadRelationshipValid: headRelationshipValid,
    issueNumber: request.expectedIssueNumber,
    featureFolder: request.expectedFeatureFolder,
    workMode: request.expectedWorkMode,
    planPath: request.expectedPlanPath,
    planSha256,
    expectedSchedulerContext: envelope.schedulerContext,
    requestedTransition: "prepared_to_atomic_execution",
    transitionState: "preparation_complete",
    requestedPhase: envelope.lifecycle.nextTransition,
    supportedCapabilities: SUPPORTED_CAPABILITIES,
    supportedVocabularies: ["portable-orchestration-handoff-core-v1"],
    validatorAvailable: true,
    topologyResolverAvailable: true,
    providerRoutingAvailable:
      request.destinationProvider === envelope.destinationProvider,
    evaluateDirtyWorktree: () => [],
  });
  const primaryFailureCode = selectPrimaryHandoffFailure([
    ...validation.failures,
    ...observationFailures,
    ...(planSha256 === request.expectedPlanSha256
      ? []
      : (["HANDOFF_PLAN_HASH_MISMATCH"] as const)),
  ]);
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
