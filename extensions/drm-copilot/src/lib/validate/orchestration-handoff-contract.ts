import { createHash } from "node:crypto";

import {
  CHECKPOINT_PATH,
  FAILURE_CODE,
  HANDOFF_ID,
  HandoffContractError,
  PHASES,
  SCHEMA_URI,
  SEMVER,
  SHA256,
  fail,
  matchingText,
  oneOf,
  parseBinding,
  parseCapabilities,
  parseIdentity,
  parsePlan,
  positiveInteger,
  record,
  stringArray,
  text,
} from "./orchestration-handoff-contract-support";
import type {
  HandoffEnvelope,
  HandoffFailureCode,
  HistoryEntry,
  LifecycleState,
  ProviderProvenance,
  ReceiptReference,
  SchedulerContext,
} from "./orchestration-handoff-contract-support";

export { HandoffContractError } from "./orchestration-handoff-contract-support";
export type {
  CapabilityRequirements,
  ChildSchedulerContext,
  HandoffEnvelope,
  HandoffFailureCode,
  HandoffProvider,
  HistoryEntry,
  LifecycleState,
  ObjectiveIdentity,
  OrdinarySchedulerContext,
  PlanIdentity,
  ProviderProvenance,
  ReceiptReference,
  SchedulerContext,
  SchedulerKind,
  WorkspaceBinding,
} from "./orchestration-handoff-contract-support";
export * from "./orchestration-handoff-validation";

function parseProvenance(value: unknown): ProviderProvenance {
  const data = record(value, "source", [
    "provider",
    "checkpoint",
    "expression",
  ]);
  const checkpoint = record(data["checkpoint"], "source.checkpoint", [
    "path",
    "sha256",
    "archive_path",
  ]);
  const expression = record(data["expression"], "source.expression", [
    "schema_id",
    "schema_version",
    "historical_receipts",
  ]);
  const receipts = record(
    expression["historical_receipts"],
    "source.expression.historical_receipts",
    ["mode", "references"],
  );
  if (receipts["mode"] !== "opaque" || !Array.isArray(receipts["references"])) {
    return fail("source.expression.historical_receipts");
  }
  const references = receipts["references"].map(
    (item, index): ReceiptReference => {
      const reference = record(
        item,
        `source.expression.historical_receipts.references.${index}`,
        ["path", "sha256"],
      );
      return {
        path: text(
          reference["path"],
          "source.expression.historical_receipts.path",
        ),
        sha256: matchingText(
          reference["sha256"],
          "source.expression.historical_receipts.sha256",
          SHA256,
        ),
      };
    },
  );
  const checkpointSha256 = matchingText(
    checkpoint["sha256"],
    "source.checkpoint.sha256",
    SHA256,
  );
  const archivePath = text(
    checkpoint["archive_path"],
    "source.checkpoint.archive_path",
  );
  if (
    archivePath !==
    `artifacts/orchestration/handoffs/sources/sha256/${checkpointSha256}.json`
  ) {
    return fail("source.checkpoint.archive_path");
  }
  return {
    provider: oneOf(data["provider"], "source.provider", ["claude", "codex"]),
    checkpointPath: text(checkpoint["path"], "source.checkpoint.path"),
    checkpointSha256,
    archivePath,
    expressionSchemaId: text(
      expression["schema_id"],
      "source.expression.schema_id",
    ),
    expressionSchemaVersion: text(
      expression["schema_version"],
      "source.expression.schema_version",
    ),
    receiptReferences: references,
  };
}

function parseLifecycle(value: unknown): LifecycleState {
  const data = record(value, "lifecycle", [
    "logical_complexity",
    "route_intent",
    "completed_phases",
    "next_transition",
    "replay_policy",
  ]);
  const completedPhases = stringArray(
    data["completed_phases"],
    "lifecycle.completed_phases",
  );
  const indexes = completedPhases.map((phase) =>
    PHASES.indexOf(phase as (typeof PHASES)[number]),
  );
  if (
    indexes.some((index) => index < 0) ||
    indexes.some(
      (index, position) =>
        position > 0 && index <= (indexes[position - 1] ?? -1),
    )
  ) {
    return fail("lifecycle.completed_phases");
  }
  const nextTransition = oneOf(
    data["next_transition"],
    "lifecycle.next_transition",
    PHASES,
  );
  if (completedPhases.includes(nextTransition)) {
    return fail("lifecycle.next_transition");
  }
  return {
    logicalComplexity: oneOf(
      data["logical_complexity"],
      "lifecycle.logical_complexity",
      ["C1", "C2", "C3", "C4"],
    ),
    routeIntent: oneOf(data["route_intent"], "lifecycle.route_intent", [
      "prepared_to_ordinary_execution",
      "prepared_child_to_ordinary_execution",
    ]),
    completedPhases,
    nextTransition,
    replayPolicy: oneOf(data["replay_policy"], "lifecycle.replay_policy", [
      "forbid_completed_phases",
    ]),
  };
}

function parseScheduler(value: unknown): SchedulerContext {
  const base = record(
    value,
    "scheduler_context",
    ["kind"],
    [
      "run_id",
      "item_id",
      "kickoff_or_manifest_path",
      "kickoff_or_manifest_sha256",
      "parent_checkpoint_path",
      "parent_checkpoint_sha256",
      "cohort_or_wave",
      "scheduler_owner",
      "child_execution_owner",
      "return_contract",
    ],
  );
  const kind = oneOf(base["kind"], "scheduler_context.kind", [
    "ordinary",
    "parallel",
    "epic",
  ]);
  if (kind === "ordinary") {
    return Object.keys(base).length === 1
      ? { kind }
      : fail("scheduler_context");
  }
  const data = record(value, "scheduler_context", [
    "kind",
    "run_id",
    "item_id",
    "kickoff_or_manifest_path",
    "kickoff_or_manifest_sha256",
    "parent_checkpoint_path",
    "parent_checkpoint_sha256",
    "cohort_or_wave",
    "scheduler_owner",
    "child_execution_owner",
    "return_contract",
  ]);
  const cohortOrWave = data["cohort_or_wave"];
  if (
    typeof cohortOrWave !== "string" &&
    (typeof cohortOrWave !== "number" || !Number.isInteger(cohortOrWave))
  ) {
    return fail("scheduler_context.cohort_or_wave");
  }
  return {
    kind,
    runId: text(data["run_id"], "scheduler_context.run_id"),
    itemId: text(data["item_id"], "scheduler_context.item_id"),
    kickoffOrManifestPath: text(
      data["kickoff_or_manifest_path"],
      "scheduler_context.kickoff_or_manifest_path",
    ),
    kickoffOrManifestSha256: matchingText(
      data["kickoff_or_manifest_sha256"],
      "scheduler_context.kickoff_or_manifest_sha256",
      SHA256,
    ),
    parentCheckpointPath: text(
      data["parent_checkpoint_path"],
      "scheduler_context.parent_checkpoint_path",
    ),
    parentCheckpointSha256: matchingText(
      data["parent_checkpoint_sha256"],
      "scheduler_context.parent_checkpoint_sha256",
      SHA256,
    ),
    cohortOrWave,
    schedulerOwner: oneOf(
      data["scheduler_owner"],
      "scheduler_context.scheduler_owner",
      [`${kind}_orchestrator`],
    ),
    childExecutionOwner: oneOf(
      data["child_execution_owner"],
      "scheduler_context.child_execution_owner",
      ["ordinary_orchestrator"],
    ),
    returnContract: oneOf(
      data["return_contract"],
      "scheduler_context.return_contract",
      ["portable_child_result-v1"],
    ),
  };
}

function parseHistoryEntry(value: unknown, index: number): HistoryEntry {
  const field = `handoff_history.${index}`;
  const data = record(
    value,
    field,
    [
      "sequence",
      "from_provider",
      "to_provider",
      "source_checkpoint_sha256",
      "envelope_sha256",
      "requested_at",
      "previous_entry_sha256",
      "entry_sha256",
      "status",
      "adapter_id",
      "adapter_version",
    ],
    ["target_checkpoint_sha256", "failure_code"],
  );
  const nullableDigest = (key: string): string | null => {
    const candidate = data[key];
    return candidate === null || candidate === undefined
      ? null
      : matchingText(candidate, `${field}.${key}`, SHA256);
  };
  const failureCode = data["failure_code"];
  if (!(
    failureCode === null ||
    failureCode === undefined ||
    (typeof failureCode === "string" && FAILURE_CODE.test(failureCode))
  )) {
    return fail(`${field}.failure_code`);
  }
  const fromProvider = oneOf(data["from_provider"], `${field}.from_provider`, [
    "claude",
    "codex",
  ]);
  const toProvider = oneOf(data["to_provider"], `${field}.to_provider`, [
    "claude",
    "codex",
  ]);
  if (fromProvider === toProvider) return fail(`${field}.to_provider`);
  return {
    sequence: positiveInteger(data["sequence"], `${field}.sequence`),
    fromProvider,
    toProvider,
    sourceCheckpointSha256: matchingText(
      data["source_checkpoint_sha256"],
      `${field}.source_checkpoint_sha256`,
      SHA256,
    ),
    envelopeSha256: matchingText(
      data["envelope_sha256"],
      `${field}.envelope_sha256`,
      SHA256,
    ),
    requestedAt: text(data["requested_at"], `${field}.requested_at`),
    previousEntrySha256: nullableDigest("previous_entry_sha256"),
    entrySha256: matchingText(
      data["entry_sha256"],
      `${field}.entry_sha256`,
      SHA256,
    ),
    status: oneOf(data["status"], `${field}.status`, [
      "requested",
      "validated",
      "materialized",
      "blocked",
      "returned",
    ]),
    adapterId: text(data["adapter_id"], `${field}.adapter_id`),
    adapterVersion: text(data["adapter_version"], `${field}.adapter_version`),
    targetCheckpointSha256: nullableDigest("target_checkpoint_sha256"),
    failureCode: typeof failureCode === "string" ? failureCode : null,
  };
}

function canonicalize(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (typeof value !== "object" || value === null) return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([key, entry]) => [key, canonicalize(entry)]),
  );
}

function historyDigest(entry: HistoryEntry): string {
  const payload = {
    adapter_id: entry.adapterId,
    adapter_version: entry.adapterVersion,
    envelope_sha256: entry.envelopeSha256,
    failure_code: entry.failureCode,
    from_provider: entry.fromProvider,
    previous_entry_sha256: entry.previousEntrySha256,
    requested_at: entry.requestedAt,
    sequence: entry.sequence,
    source_checkpoint_sha256: entry.sourceCheckpointSha256,
    status: entry.status,
    target_checkpoint_sha256: entry.targetCheckpointSha256,
    to_provider: entry.toProvider,
  };
  return createHash("sha256")
    .update(JSON.stringify(canonicalize(payload)))
    .digest("hex");
}

function validateHistory(entries: readonly HistoryEntry[]): void {
  let previous: string | null = null;
  entries.forEach((entry, index) => {
    if (
      entry.sequence !== index + 1 ||
      entry.previousEntrySha256 !== previous ||
      historyDigest(entry) !== entry.entrySha256
    ) {
      fail("handoff_history", "chain is invalid", "HANDOFF_HISTORY_INVALID");
    }
    previous = entry.entrySha256;
  });
}

export function parseHandoffEnvelope(value: unknown): HandoffEnvelope {
  const data = record(value, "handoff", [
    "$schema",
    "schema_version",
    "kind",
    "handoff_id",
    "identity",
    "binding",
    "source",
    "destination",
    "plan",
    "lifecycle",
    "capabilities",
    "scheduler_context",
    "handoff_history",
  ]);
  const source = parseProvenance(data["source"]);
  const destination = record(data["destination"], "destination", [
    "provider",
    "checkpoint_path",
  ]);
  const destinationProvider = oneOf(
    destination["provider"],
    "destination.provider",
    ["claude", "codex"],
  );
  if (destinationProvider === source.provider)
    return fail("destination.provider");
  const destinationCheckpointPath = text(
    destination["checkpoint_path"],
    "destination.checkpoint_path",
  );
  if (destinationCheckpointPath !== CHECKPOINT_PATH)
    return fail("destination.checkpoint_path");
  if (
    !Array.isArray(data["handoff_history"]) ||
    data["handoff_history"].length === 0
  ) {
    return fail(
      "handoff_history",
      "must be a non-empty array",
      "HANDOFF_HISTORY_INVALID",
    );
  }
  const handoffHistory = data["handoff_history"].map(parseHistoryEntry);
  validateHistory(handoffHistory);
  const first = handoffHistory[0];
  if (
    first?.fromProvider !== source.provider ||
    first.toProvider !== destinationProvider ||
    first.sourceCheckpointSha256 !== source.checkpointSha256
  ) {
    return fail(
      "handoff_history",
      "does not match source and destination",
      "HANDOFF_HISTORY_INVALID",
    );
  }
  return {
    schemaUri: oneOf(data["$schema"], "$schema", [SCHEMA_URI]),
    schemaVersion: matchingText(
      data["schema_version"],
      "schema_version",
      SEMVER,
    ),
    kind: oneOf(data["kind"], "kind", ["portable_orchestration_handoff"]),
    handoffId: matchingText(data["handoff_id"], "handoff_id", HANDOFF_ID),
    identity: parseIdentity(data["identity"]),
    binding: parseBinding(data["binding"]),
    source,
    destinationProvider,
    destinationCheckpointPath,
    plan: parsePlan(data["plan"]),
    lifecycle: parseLifecycle(data["lifecycle"]),
    capabilities: parseCapabilities(data["capabilities"]),
    schedulerContext: parseScheduler(data["scheduler_context"]),
    handoffHistory,
  };
}

export function parseHandoffEnvelopeText(textValue: string): HandoffEnvelope {
  try {
    const parsed: unknown = JSON.parse(textValue);
    return parseHandoffEnvelope(parsed);
  } catch (error: unknown) {
    if (error instanceof HandoffContractError) throw error;
    return fail("handoff", "must be valid JSON");
  }
}

export function validateHandoffEnvelopeText(
  textValue: string,
): HandoffFailureCode | null {
  try {
    const envelope = parseHandoffEnvelopeText(textValue);
    return Number(envelope.schemaVersion.split(".")[0]) === 2 &&
      envelope.capabilities.vocabularies.every(
        (value) => value === "portable-orchestration-handoff-core-v1",
      )
      ? null
      : "HANDOFF_UNSUPPORTED_VERSION";
  } catch (error: unknown) {
    return error instanceof HandoffContractError
      ? error.code
      : "HANDOFF_UNSUPPORTED_VERSION";
  }
}
