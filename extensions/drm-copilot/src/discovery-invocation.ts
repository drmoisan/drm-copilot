/**
 * Prepare constrained discovery invocations behind persisted protected bindings.
 *
 * `prepare_discovery_agent` is a root operation. Given the trusted parent and
 * session context, the protected activation envelope, the session's current
 * capability attestation and the routing decision from `discovery-routing`,
 * this module writes the protected `discovery-invocation` record, its
 * topology, model and required-output receipts and the authoritative
 * `prepare-agent` baseline result under the invocation partition of the
 * authority store, then returns the exact launchable deployment. The
 * workspace mirror it offers is diagnostic only: protected reads never consult
 * it. Nothing here reads or writes `artifacts/orchestration/orchestrator-state.json`,
 * and no feature issue or checkpoint is required.
 */

import type {
  DiscoveryRuntimeIdentity,
  DiscoveryServiceResult,
} from "./discovery-service-types";
import {
  type AuthorityStoreIO,
  type ProtectedEnvelope,
  rejectCallerAuthorityClaims,
} from "./discovery-authority";
import {
  type AuthorityLocation,
  invocationDirectory,
  sha256Hex,
} from "./discovery-authority-paths";
import {
  CALLER_IDENTITY_KEYS,
  canonicalJson,
  type NativeIdentity,
} from "./discovery-authorization-record";
import {
  assessProtectedCapability,
  type CapabilityDeficiencyKind,
  type CapabilityExpectation,
  type CapabilityPins,
  DISCOVERY_ENFORCEMENT_UNAVAILABLE,
} from "./discovery-capabilities";
import {
  DISCOVERY_INVOCATION_SCHEMA,
  type DiscoveryInvocationCode,
  type DiscoveryInvocationRecord,
  HOSTS,
  INVOCATION_RECORD_FILE,
  refuse,
} from "./discovery-invocation-record";
import {
  buildInvocationDeployment,
  buildRequiredOutputManifest,
  DISCOVERY_ROLES,
  type InvocationDeployment,
  resolveDiscoveryRouting,
  scopeDigest,
  validateExpectedOutputs,
  validateScope,
} from "./discovery-routing";

export {
  decodeDiscoveryInvocation,
  DISCOVERY_INVOCATION_SCHEMA,
  DiscoveryInvocationError,
  INVOCATION_RECORD_FILE,
  INVOCATION_RECORD_KEYS,
  loadPreparedInvocation,
} from "./discovery-invocation-record";
export type {
  DiscoveryInvocationCode,
  DiscoveryInvocationRecord,
} from "./discovery-invocation-record";
export {
  CAPABILITY_ATTESTATION_FILE,
  CAPABILITY_ATTESTATION_SCHEMA,
} from "./discovery-capabilities";
export const TOPOLOGY_RECEIPT_FILE = "topology-receipt.json";
export const MODEL_RECEIPT_FILE = "model-receipt.json";
export const REQUIRED_OUTPUTS_FILE = "required-outputs.json";
/** Verbatim `prepare-agent` result: the pre-invocation baseline Python pinned. */
export const BASELINE_RESULT_FILE = "baseline-result.json";
export const DIAGNOSTIC_MIRROR_ROOT = "artifacts/discovery/invocations";
export const PREPARE_REQUEST_KEYS: ReadonlyArray<string> = [
  "complexity",
  "execution_context",
  "expected_outputs",
  "paths",
  "selected_ids",
  "skill_id",
];
const OPTIONAL_REQUEST_KEYS: ReadonlyArray<string> = [
  "orchestration_complexity_ceiling",
  "production_write_count",
  "test_write_count",
];
const CORRELATION_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]*$/u;
const NONCE = /^[a-z0-9]{8,64}$/u;
/** Refusal code for each capability deficiency, in the assessment's vocabulary. */
const CAPABILITY_REFUSALS: Readonly<
  Record<CapabilityDeficiencyKind, DiscoveryInvocationCode>
> = {
  "attestation-missing": "INVOCATION_CAPABILITY_MISSING",
  "attestation-malformed": "INVOCATION_CAPABILITY_INVALID",
  "context-missing": "INVOCATION_CAPABILITY_MISSING",
  "activation-unavailable": "INVOCATION_CAPABILITY_MISSING",
  "harness-unsupported": "INVOCATION_CAPABILITY_UNSUPPORTED",
  "hooks-disabled": "INVOCATION_CAPABILITY_UNSUPPORTED",
  "trust-missing": "INVOCATION_CAPABILITY_UNSUPPORTED",
  "event-unsupported": "INVOCATION_CAPABILITY_UNSUPPORTED",
  "probe-not-denied": "INVOCATION_CAPABILITY_UNSUPPORTED",
  "probe-stale": "INVOCATION_CAPABILITY_EXPIRED",
  "workspace-mismatch": "INVOCATION_CAPABILITY_MISMATCH",
  "host-mismatch": "INVOCATION_CAPABILITY_MISMATCH",
  "session-mismatch": "INVOCATION_CAPABILITY_MISMATCH",
  "runtime-mismatch": "INVOCATION_CAPABILITY_MISMATCH",
  "configuration-hash-mismatch": "INVOCATION_CAPABILITY_MISMATCH",
  "hook-hash-mismatch": "INVOCATION_CAPABILITY_MISMATCH",
};

export interface PrepareContext {
  readonly host: string;
  readonly sessionId: string;
  readonly parentAgentId: string;
  /** Role of the calling agent when it is itself a discovery specialist. */
  readonly parentRole: string | null;
}

/** Protected `discovery-invocation` record. */
export interface DiagnosticMirror {
  readonly diagnostic: true;
  readonly relative_path: string;
  readonly text: string;
}

export interface PreparedDiscoveryInvocation {
  readonly record: DiscoveryInvocationRecord;
  readonly deployment: InvocationDeployment;
  readonly identity: NativeIdentity;
  readonly protectedPaths: ReadonlyArray<string>;
  readonly mirror: DiagnosticMirror;
}

export interface PrepareOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly activation: { envelope(): ProtectedEnvelope };
  readonly context: PrepareContext;
  readonly request: unknown;
  readonly runtime: DiscoveryRuntimeIdentity;
  /**
   * Authoritative ok `prepare-agent` result of the installed runtime for the
   * same request. It is persisted verbatim so the host-principal gateway can
   * reconstruct the pre-invocation inputs; it is never derived from the caller.
   */
  readonly baseline: DiscoveryServiceResult;
  readonly availableModels?: ReadonlySet<string>;
  /** Host-pinned configuration and hook hashes the attestation must match. */
  readonly pins?: CapabilityPins;
  readonly now: Date;
  readonly nonce: () => string;
}

function validateContext(context: PrepareContext): void {
  if (
    !HOSTS.includes(context.host) ||
    !CORRELATION_ID.test(context.sessionId) ||
    !CORRELATION_ID.test(context.parentAgentId)
  ) {
    throw refuse(
      "INVOCATION_CONTEXT_INVALID",
      "Trusted host, session and parent agent identity are required.",
    );
  }
  // A discovery specialist can never prepare another discovery invocation.
  if (
    context.parentRole !== null &&
    DISCOVERY_ROLES.includes(context.parentRole)
  ) {
    throw refuse(
      "INVOCATION_NESTED_LAUNCH",
      `Role ${context.parentRole} cannot launch a nested discovery agent.`,
    );
  }
}

/** Prepare request fields after key validation; values are still unverified. */
interface PrepareRequestFields {
  readonly skill_id: unknown;
  readonly selected_ids: unknown;
  readonly paths: unknown;
  readonly expected_outputs: unknown;
  readonly execution_context: unknown;
  readonly complexity: unknown;
  readonly orchestration_complexity_ceiling?: unknown;
  readonly production_write_count?: unknown;
  readonly test_write_count?: unknown;
}

function validateRequestShape(request: unknown): PrepareRequestFields {
  rejectCallerAuthorityClaims(request, "Prepare request");
  if (
    request === null ||
    typeof request !== "object" ||
    Array.isArray(request)
  ) {
    throw refuse(
      "INVOCATION_REQUEST_INVALID",
      "Prepare request must be an object.",
    );
  }
  const value = request as Record<string, unknown>;
  const keys = Object.keys(value);
  const claimed = keys.filter(
    (key) => CALLER_IDENTITY_KEYS.includes(key) || key === "capability",
  );
  if (claimed.length > 0) {
    throw refuse(
      "INVOCATION_REQUEST_INVALID",
      `Prepare requests cannot supply identity or capability: ${claimed.join(", ")}`,
    );
  }
  const unknown = keys.filter(
    (key) =>
      !PREPARE_REQUEST_KEYS.includes(key) &&
      !OPTIONAL_REQUEST_KEYS.includes(key),
  );
  const missing = PREPARE_REQUEST_KEYS.filter((key) => !keys.includes(key));
  if (unknown.length > 0 || missing.length > 0) {
    throw refuse(
      "INVOCATION_REQUEST_INVALID",
      `Prepare request keys must be exactly ${PREPARE_REQUEST_KEYS.join(", ")}.`,
    );
  }
  return request as PrepareRequestFields;
}

/**
 * Read and verify the session's capability attestation from the protected store.
 *
 * Only the protected copy is consulted; attestations supplied by the caller or
 * by repository JSON are never accepted. The assessment in
 * `discovery-capabilities` decides support; the first deficiency in contract
 * order becomes the refusal, prefixed with `DISCOVERY_ENFORCEMENT_UNAVAILABLE`
 * so a caller can distinguish a host gap from a request defect.
 */
export function readCapabilityAttestation(options: {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly sessionId: string;
  readonly expected: CapabilityExpectation;
  readonly now: Date;
}): string {
  const assessment = assessProtectedCapability(options);
  const [first] = assessment.deficiencies;
  if (first !== undefined || assessment.attestation === null) {
    const deficiency = first ?? {
      kind: "attestation-missing" as const,
      detail: "no attestation was decoded",
    };
    const code = CAPABILITY_REFUSALS[deficiency.kind];
    // The unsupported wording stays stable: callers key on "required discovery controls".
    const summary =
      code === "INVOCATION_CAPABILITY_UNSUPPORTED"
        ? "The host does not provide the required discovery controls"
        : `Capability attestation is unavailable (${deficiency.kind})`;
    throw refuse(
      code,
      `${DISCOVERY_ENFORCEMENT_UNAVAILABLE}: ${summary}: ${deficiency.detail}.`,
    );
  }
  return assessment.attestation.attestation_ref;
}

/** Render the diagnostic workspace mirror; it is a copy and never authority. */
export function diagnosticMirror(
  record: DiscoveryInvocationRecord,
): DiagnosticMirror {
  return {
    diagnostic: true,
    relative_path: `${DIAGNOSTIC_MIRROR_ROOT}/${record.invocation_id}.json`,
    text: `${JSON.stringify(record, null, 2)}\n`,
  };
}

/**
 * Require the baseline to be the ok `prepare-agent` result of this runtime.
 *
 * A failed, foreign or runtime-less result would persist a baseline the
 * Python gateway cannot verify, so it is refused before any protected write.
 */
function validateBaseline(
  baseline: DiscoveryServiceResult,
  runtime: DiscoveryRuntimeIdentity,
): void {
  if (
    baseline.operation !== "prepare-agent" ||
    !baseline.ok ||
    baseline.runtime === null ||
    canonicalJson(baseline.runtime) !== canonicalJson(runtime)
  ) {
    throw refuse(
      "INVOCATION_REQUEST_INVALID",
      "Prepare requires the ok prepare-agent baseline result of the installed runtime.",
    );
  }
}

/**
 * Prepare one discovery invocation and persist its protected bindings.
 *
 * Order: trusted context, request shape, baseline result, routing (fails
 * before any I/O), activation envelope, capability attestation, then exclusive
 * creation of the five protected records. The deployment is returned only
 * after every record exists.
 */
export function prepareDiscoveryInvocation(
  options: PrepareOptions,
): PreparedDiscoveryInvocation {
  const { location, io, context, runtime, now } = options;
  validateContext(context);
  const request = validateRequestShape(options.request);
  validateBaseline(options.baseline, runtime);
  const decision = resolveDiscoveryRouting(
    {
      skillId: request.skill_id,
      executionContext: request.execution_context,
      complexity: request.complexity,
      orchestrationComplexityCeiling: request.orchestration_complexity_ceiling,
      productionWriteCount: request.production_write_count,
      testWriteCount: request.test_write_count,
    },
    options.availableModels,
  );
  const scope = validateScope(request.selected_ids, request.paths);
  const outputs = validateExpectedOutputs(
    decision.skillId,
    request.expected_outputs,
  );
  const envelope = options.activation.envelope();
  const capabilityRef = readCapabilityAttestation({
    location,
    io,
    sessionId: context.sessionId,
    expected: {
      workspace: envelope.workspace,
      host: context.host,
      sessionId: context.sessionId,
      runtime,
      ...(options.pins === undefined ? {} : { pins: options.pins }),
    },
    now,
  });
  const nonce = options.nonce();
  if (!NONCE.test(nonce)) {
    throw refuse(
      "INVOCATION_REQUEST_INVALID",
      "Invocation nonce must be lowercase hex.",
    );
  }
  const invocationId = `invocation-${nonce}`;
  const manifest = buildRequiredOutputManifest({
    invocationId,
    workspace: envelope.workspace,
    role: decision.role,
    outputs,
  });
  const inputDigest = canonicalJson({
    complexity: request.complexity,
    execution_context: request.execution_context,
    expected_outputs: outputs,
    paths: scope.paths,
    selected_ids: scope.selectedIds,
    skill_id: decision.skillId,
  });
  const record: DiscoveryInvocationRecord = {
    $schema: DISCOVERY_INVOCATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "discovery-invocation",
    id: `inv-${nonce}`,
    invocation_id: invocationId,
    workspace: { ...envelope.workspace },
    host: context.host,
    session_id: context.sessionId,
    parent_agent_id: context.parentAgentId,
    agent_id: null,
    role: decision.role,
    skill_id: decision.skillId,
    operation: decision.operation,
    gate_mode: decision.gateMode,
    selected_ids: [...scope.selectedIds],
    selected_paths: [...scope.paths],
    scope_sha256: scopeDigest(scope),
    input_sha256: sha256Hex(inputDigest),
    runtime: { ...runtime },
    deployment: buildInvocationDeployment(
      decision,
      context.host,
      envelope.workspace,
    ),
    required_outputs: manifest,
    capability_ref: capabilityRef,
    topology_receipt_ref: decision.topologyReceiptRef,
    model_receipt_ref: decision.modelReceiptRef,
    production_write_count: 0,
    state: "prepared",
    created_at: now.toISOString(),
    start_attestation_ref: null,
    completion_receipt_ref: null,
  };
  // Protected bindings are persisted exclusively before the deployment is
  // returned; a partial directory from a crashed run is never reused.
  const directory = invocationDirectory(
    location,
    context.sessionId,
    invocationId,
  );
  io.ensureDirectory(directory);
  const files: ReadonlyArray<[string, unknown]> = [
    [INVOCATION_RECORD_FILE, record],
    [
      TOPOLOGY_RECEIPT_FILE,
      { ref: decision.topologyReceiptRef, receipt: decision.topology },
    ],
    [
      MODEL_RECEIPT_FILE,
      { ref: decision.modelReceiptRef, receipt: decision.deployment },
    ],
    [REQUIRED_OUTPUTS_FILE, manifest],
    [BASELINE_RESULT_FILE, options.baseline],
  ];
  const protectedPaths: string[] = [];
  for (const [name, document] of files) {
    const path = `${directory}/${name}`;
    io.createExclusive(path, `${JSON.stringify(document, null, 2)}\n`);
    protectedPaths.push(path);
  }
  return {
    record,
    deployment: record.deployment,
    identity: {
      host: context.host,
      session_id: context.sessionId,
      agent_id: context.parentAgentId,
      role: decision.role,
      invocation_id: invocationId,
    },
    protectedPaths,
    mirror: diagnosticMirror(record),
  };
}
