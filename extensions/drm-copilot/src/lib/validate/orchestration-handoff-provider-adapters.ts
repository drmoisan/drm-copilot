import { HandoffContractError } from "./orchestration-handoff-contract";
import type {
  HandoffEnvelope,
  HandoffProvider,
  SchedulerContext,
} from "./orchestration-handoff-contract";
import { SHA256 } from "./orchestration-handoff-contract-support";

/** Registry-backed provider metadata used at the native checkpoint boundary. */
export interface ProviderAdapterDefinition {
  readonly provider: HandoffProvider;
  readonly checkpointExpression: string;
  readonly sourceValidator: string;
  readonly destinationProjector: string;
  readonly routingPolicy: string;
  readonly topologyPolicy?: string;
}

export interface DestinationProjectionInput {
  readonly envelope: HandoffEnvelope;
  readonly envelopeSha256: string;
  readonly historyEntrySha256: string;
}

export interface DestinationExecutionEvidence {
  readonly routing: Readonly<Record<string, unknown>>;
  readonly topology: Readonly<Record<string, unknown>>;
  readonly model: Readonly<Record<string, unknown>>;
  readonly receipts: readonly Readonly<Record<string, unknown>>[];
}

type DestinationEvidence =
  | {
      readonly status: "pending_first_delegation";
      readonly receipts: readonly unknown[];
    }
  | (DestinationExecutionEvidence & {
      readonly status: "first_delegation_recorded";
      readonly delegation_sequence: 1;
    });

export interface ProviderDestinationProjection {
  readonly provider: HandoffProvider;
  readonly checkpoint_expression: string;
  readonly destination_projector: string;
  readonly "plan-path": string;
  readonly next_step: string;
  readonly portable_handoff: Readonly<Record<string, unknown>>;
  readonly destination_evidence: DestinationEvidence;
}

export interface FirstDestinationDelegationInput {
  readonly projection: ProviderDestinationProjection;
  readonly evidence: DestinationExecutionEvidence;
  readonly checkpointMaterialized: boolean;
  readonly delegationSequence: number;
}

const PROVIDER_ADAPTERS: Readonly<
  Record<HandoffProvider, ProviderAdapterDefinition>
> = {
  claude: {
    provider: "claude",
    checkpointExpression: "claude.orchestrator-state",
    sourceValidator: "claude-source-v1",
    destinationProjector: "portable-to-claude-v1",
    routingPolicy: "model_policy",
  },
  codex: {
    provider: "codex",
    checkpointExpression: "codex.orchestrator-state",
    sourceValidator: "codex-source-v1",
    destinationProjector: "portable-to-codex-v1",
    routingPolicy: "codex_model_policy",
    topologyPolicy: "codex_topology_policy",
  },
};

/** Return the immutable adapter metadata for a supported provider. */
export function providerAdapterFor(
  provider: HandoffProvider,
): ProviderAdapterDefinition {
  return PROVIDER_ADAPTERS[provider];
}

/**
 * Validate that portable source provenance selects the source provider's
 * registered expression and the exact bidirectional adapter recorded in the
 * first digest-linked history entry.
 */
export function validateProviderSource(
  envelope: HandoffEnvelope,
): ProviderAdapterDefinition {
  const sourceAdapter = providerAdapterFor(envelope.source.provider);
  if (
    envelope.source.expressionSchemaId !== sourceAdapter.checkpointExpression
  ) {
    throw new HandoffContractError(
      "source.expression.schema_id",
      `expected ${sourceAdapter.checkpointExpression}`,
      "HANDOFF_UNSUPPORTED_VERSION",
    );
  }
  const firstEntry = envelope.handoffHistory[0];
  const expectedAdapterId = `${envelope.source.provider}-to-${envelope.destinationProvider}-v1`;
  if (
    firstEntry === undefined ||
    firstEntry.fromProvider !== envelope.source.provider ||
    firstEntry.toProvider !== envelope.destinationProvider ||
    firstEntry.adapterId !== expectedAdapterId ||
    firstEntry.adapterVersion !== "1.0.0"
  ) {
    throw new HandoffContractError(
      "handoff_history[0].adapter_id",
      `expected ${expectedAdapterId} at adapter version 1.0.0`,
      "HANDOFF_HISTORY_INVALID",
    );
  }
  return sourceAdapter;
}

function projectSchedulerContext(
  scheduler: SchedulerContext,
): Readonly<Record<string, unknown>> {
  if (scheduler.kind === "ordinary") return { kind: "ordinary" };
  return {
    kind: scheduler.kind,
    run_id: scheduler.runId,
    item_id: scheduler.itemId,
    kickoff_or_manifest_path: scheduler.kickoffOrManifestPath,
    kickoff_or_manifest_sha256: scheduler.kickoffOrManifestSha256,
    parent_checkpoint_path: scheduler.parentCheckpointPath,
    parent_checkpoint_sha256: scheduler.parentCheckpointSha256,
    cohort_or_wave: scheduler.cohortOrWave,
    scheduler_owner: scheduler.schedulerOwner,
    child_execution_owner: scheduler.childExecutionOwner,
    return_contract: scheduler.returnContract,
  };
}

function requireProjectionDigest(
  field: string,
  value: string,
  failureCode: "HANDOFF_SOURCE_HASH_MISMATCH" | "HANDOFF_HISTORY_INVALID",
): void {
  if (!SHA256.test(value)) {
    throw new HandoffContractError(field, "invalid SHA-256", failureCode);
  }
}

/**
 * Project portable state into a destination-owned checkpoint expression.
 * Historical provider evidence is retained only as opaque path/digest
 * references. No destination routing, model, profile, topology, launch, or
 * receipt evidence is created before the first new destination delegation.
 */
export function projectDestinationCheckpoint(
  input: DestinationProjectionInput,
): ProviderDestinationProjection {
  const { envelope } = input;
  const sourceAdapter = validateProviderSource(envelope);
  const destinationAdapter = providerAdapterFor(envelope.destinationProvider);
  requireProjectionDigest(
    "portable_handoff.envelope_sha256",
    input.envelopeSha256,
    "HANDOFF_SOURCE_HASH_MISMATCH",
  );
  requireProjectionDigest(
    "portable_handoff.history_entry_sha256",
    input.historyEntrySha256,
    "HANDOFF_HISTORY_INVALID",
  );

  return {
    provider: destinationAdapter.provider,
    checkpoint_expression: destinationAdapter.checkpointExpression,
    destination_projector: destinationAdapter.destinationProjector,
    "plan-path": envelope.plan.path,
    next_step: envelope.lifecycle.nextTransition,
    portable_handoff: {
      handoff_id: envelope.handoffId,
      envelope_sha256: input.envelopeSha256,
      history_entry_sha256: input.historyEntrySha256,
      selected_adapter: `${envelope.source.provider}-to-${envelope.destinationProvider}-v1`,
      source_validator: sourceAdapter.sourceValidator,
      identity: {
        objective_id: envelope.identity.objectiveId,
        issue_number: envelope.identity.issueNumber,
        feature_folder: envelope.identity.featureFolder,
        work_mode: envelope.identity.workMode,
      },
      binding: {
        repository_id: envelope.binding.repositoryId,
        workspace_root: envelope.binding.workspaceRoot,
        branch: envelope.binding.branch,
        source_head_sha: envelope.binding.sourceHeadSha,
        allowed_head_relationship: envelope.binding.allowedHeadRelationship,
      },
      source: {
        provider: envelope.source.provider,
        checkpoint_path: envelope.source.checkpointPath,
        checkpoint_sha256: envelope.source.checkpointSha256,
        archive_path: envelope.source.archivePath,
        expression: {
          schema_id: envelope.source.expressionSchemaId,
          schema_version: envelope.source.expressionSchemaVersion,
          historical_receipts: {
            mode: "opaque",
            references: envelope.source.receiptReferences.map((reference) => ({
              path: reference.path,
              sha256: reference.sha256,
            })),
          },
        },
      },
      plan: {
        path: envelope.plan.path,
        sha256: envelope.plan.sha256,
        contract_version: envelope.plan.contractVersion,
      },
      lifecycle: {
        logical_complexity: envelope.lifecycle.logicalComplexity,
        route_intent: envelope.lifecycle.routeIntent,
        completed_phases: [...envelope.lifecycle.completedPhases],
        next_transition: envelope.lifecycle.nextTransition,
        replay_policy: envelope.lifecycle.replayPolicy,
      },
      capabilities: {
        vocabularies: [...envelope.capabilities.vocabularies],
        required: [...envelope.capabilities.required],
      },
      scheduler_context: projectSchedulerContext(envelope.schedulerContext),
    },
    destination_evidence: {
      status: "pending_first_delegation",
      receipts: [],
    },
  };
}

/** Record destination-owned evidence exactly once, after materialization. */
export function recordFirstDestinationDelegation(
  input: FirstDestinationDelegationInput,
): ProviderDestinationProjection {
  const { projection, evidence } = input;
  const pending = projection.destination_evidence;
  const evidenceIsComplete =
    Object.keys(evidence.routing).length > 0 &&
    Object.keys(evidence.topology).length > 0 &&
    Object.keys(evidence.model).length > 0 &&
    evidence.receipts.length > 0;
  if (
    !input.checkpointMaterialized ||
    input.delegationSequence !== 1 ||
    pending.status !== "pending_first_delegation" ||
    pending.receipts.length !== 0 ||
    !evidenceIsComplete
  ) {
    throw new HandoffContractError(
      "destination_evidence",
      "requires the first new delegation after materialization",
      "HANDOFF_TRANSITION_NOT_ALLOWED",
    );
  }
  return {
    ...projection,
    destination_evidence: {
      status: "first_delegation_recorded",
      delegation_sequence: 1,
      ...evidence,
    },
  };
}
