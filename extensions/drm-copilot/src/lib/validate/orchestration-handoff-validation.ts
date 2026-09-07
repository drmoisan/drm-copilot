import type {
  HandoffEnvelope,
  HandoffFailureCode,
  SchedulerContext,
} from "./orchestration-handoff-contract-support";
import { HandoffContractError } from "./orchestration-handoff-contract-support";

export const HANDOFF_FAILURE_PRECEDENCE: readonly HandoffFailureCode[] = [
  "HANDOFF_UNSUPPORTED_VERSION",
  "HANDOFF_SOURCE_HASH_MISMATCH",
  "HANDOFF_HISTORY_INVALID",
  "HANDOFF_REPOSITORY_MISMATCH",
  "HANDOFF_WORKSPACE_MISMATCH",
  "HANDOFF_ISSUE_FEATURE_MISMATCH",
  "HANDOFF_BRANCH_LINEAGE_MISMATCH",
  "HANDOFF_PLAN_PATH_INVALID",
  "HANDOFF_PLAN_HASH_MISMATCH",
  "HANDOFF_SCHEDULER_BINDING_MISMATCH",
  "HANDOFF_TRANSITION_NOT_ALLOWED",
  "HANDOFF_CAPABILITY_UNAVAILABLE",
  "HANDOFF_VALIDATOR_UNAVAILABLE",
  "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
  "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
  "HANDOFF_DIRTY_WORKTREE",
];

export function selectPrimaryHandoffFailure(
  failures: readonly HandoffFailureCode[],
): HandoffFailureCode | null {
  const found = new Set(failures);
  for (const failure of found) {
    if (!HANDOFF_FAILURE_PRECEDENCE.includes(failure)) {
      throw new HandoffContractError("failures", "contains an unknown code");
    }
  }
  return HANDOFF_FAILURE_PRECEDENCE.find((code) => found.has(code)) ?? null;
}

export interface HandoffValidationContext {
  readonly repositoryId: string;
  readonly workspaceRoot: string;
  readonly branch: string;
  readonly sourceHeadRelationshipValid: boolean;
  readonly issueNumber: number;
  readonly featureFolder: string;
  readonly workMode: string;
  readonly planPath: string;
  readonly planSha256: string;
  readonly expectedSchedulerContext: SchedulerContext;
  readonly requestedTransition: string;
  readonly transitionState: string;
  readonly requestedPhase: string;
  readonly supportedCapabilities: readonly string[];
  readonly supportedVocabularies: readonly string[];
  readonly validatorAvailable: boolean;
  readonly topologyResolverAvailable: boolean;
  readonly providerRoutingAvailable: boolean;
  readonly evaluateDirtyWorktree: () => readonly string[];
}

export interface HandoffValidationResult {
  readonly failures: readonly HandoffFailureCode[];
  readonly affectedPaths: readonly string[];
  readonly unsupportedCapabilities: readonly string[];
}

const REGISTERED_TRANSITION_SOURCES: Readonly<
  Record<string, readonly string[]>
> = {
  migrate_legacy: ["legacy_v1"],
  prepared_to_atomic_execution: ["preparation_complete"],
  materialize_destination: ["validated"],
  atomic_execution: ["materialized"],
  return_to_scheduler: [
    "atomic_execution",
    "qa",
    "feature_review",
    "completion",
  ],
};

function addFailure(
  failures: HandoffFailureCode[],
  condition: boolean,
  code: HandoffFailureCode,
): void {
  if (condition && !failures.includes(code)) failures.push(code);
}

function schedulerContextsMatch(
  actual: SchedulerContext,
  expected: SchedulerContext,
): boolean {
  return JSON.stringify(actual) === JSON.stringify(expected);
}

function schedulerCapability(context: SchedulerContext): string {
  const suffix =
    context.kind === "ordinary" ? "ordinary" : `${context.kind}-child`;
  return `scheduler-context:${suffix}`;
}

function validateVersion(
  envelope: HandoffEnvelope,
  context: HandoffValidationContext,
  failures: HandoffFailureCode[],
): void {
  const major = Number(envelope.schemaVersion.split(".")[0]);
  const vocabularyUnsupported = envelope.capabilities.vocabularies.some(
    (value) => !context.supportedVocabularies.includes(value),
  );
  addFailure(
    failures,
    major !== 2 || vocabularyUnsupported,
    "HANDOFF_UNSUPPORTED_VERSION",
  );
}

function validateIdentityAndBinding(
  envelope: HandoffEnvelope,
  context: HandoffValidationContext,
  failures: HandoffFailureCode[],
): void {
  addFailure(
    failures,
    context.repositoryId !== envelope.binding.repositoryId,
    "HANDOFF_REPOSITORY_MISMATCH",
  );
  addFailure(
    failures,
    context.workspaceRoot !== envelope.binding.workspaceRoot,
    "HANDOFF_WORKSPACE_MISMATCH",
  );
  addFailure(
    failures,
    context.issueNumber !== envelope.identity.issueNumber ||
      context.featureFolder !== envelope.identity.featureFolder ||
      context.workMode !== envelope.identity.workMode,
    "HANDOFF_ISSUE_FEATURE_MISMATCH",
  );
  addFailure(
    failures,
    context.branch !== envelope.binding.branch ||
      !context.sourceHeadRelationshipValid,
    "HANDOFF_BRANCH_LINEAGE_MISMATCH",
  );
  addFailure(
    failures,
    context.planPath !== envelope.plan.path,
    "HANDOFF_PLAN_PATH_INVALID",
  );
  addFailure(
    failures,
    context.planSha256 !== envelope.plan.sha256,
    "HANDOFF_PLAN_HASH_MISMATCH",
  );
}

function validateCapabilities(
  envelope: HandoffEnvelope,
  context: HandoffValidationContext,
  failures: HandoffFailureCode[],
): readonly string[] {
  const major = Number(envelope.schemaVersion.split(".")[0]);
  const mandatory = new Set([
    `handoff-schema:${major}`,
    `plan-contract:${envelope.plan.contractVersion}`,
    schedulerCapability(envelope.schedulerContext),
    `transition:${context.requestedTransition}`,
  ]);
  const declared = new Set(envelope.capabilities.required);
  const unsupported = envelope.capabilities.required.filter(
    (capability) => !context.supportedCapabilities.includes(capability),
  );
  for (const capability of mandatory) {
    if (!declared.has(capability)) unsupported.push(capability);
  }
  const uniqueUnsupported = [...new Set(unsupported)];
  addFailure(
    failures,
    uniqueUnsupported.length > 0,
    "HANDOFF_CAPABILITY_UNAVAILABLE",
  );
  return uniqueUnsupported;
}

function validateSchedulerAndTransition(
  envelope: HandoffEnvelope,
  context: HandoffValidationContext,
  failures: HandoffFailureCode[],
): void {
  const expectedRoute =
    envelope.schedulerContext.kind === "ordinary"
      ? "prepared_to_ordinary_execution"
      : "prepared_child_to_ordinary_execution";
  addFailure(
    failures,
    !schedulerContextsMatch(
      envelope.schedulerContext,
      context.expectedSchedulerContext,
    ) || envelope.lifecycle.routeIntent !== expectedRoute,
    "HANDOFF_SCHEDULER_BINDING_MISMATCH",
  );
  const allowedSources =
    REGISTERED_TRANSITION_SOURCES[context.requestedTransition];
  addFailure(
    failures,
    allowedSources === undefined ||
      !allowedSources.includes(context.transitionState) ||
      context.requestedPhase !== envelope.lifecycle.nextTransition ||
      envelope.lifecycle.completedPhases.includes(context.requestedPhase),
    "HANDOFF_TRANSITION_NOT_ALLOWED",
  );
}

export function collectHandoffValidationFailures(
  envelope: HandoffEnvelope,
  context: HandoffValidationContext,
): HandoffValidationResult {
  const failures: HandoffFailureCode[] = [];
  validateVersion(envelope, context, failures);
  validateIdentityAndBinding(envelope, context, failures);
  validateSchedulerAndTransition(envelope, context, failures);
  const unsupportedCapabilities = validateCapabilities(
    envelope,
    context,
    failures,
  );
  addFailure(
    failures,
    !context.validatorAvailable,
    "HANDOFF_VALIDATOR_UNAVAILABLE",
  );
  addFailure(
    failures,
    !context.topologyResolverAvailable,
    "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
  );
  addFailure(
    failures,
    !context.providerRoutingAvailable,
    "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
  );

  const affectedPaths = [...context.evaluateDirtyWorktree()];
  addFailure(failures, affectedPaths.length > 0, "HANDOFF_DIRTY_WORKTREE");
  return { failures, affectedPaths, unsupportedCapabilities };
}
