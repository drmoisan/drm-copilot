/**
 * Prepare constrained discovery invocations behind persisted protected bindings.
 *
 * `prepare_discovery_agent` is a root operation. Given the trusted parent and
 * session context, the protected activation envelope, the session's current
 * capability attestation and the routing decision from `discovery-routing`,
 * this module writes the protected `discovery-invocation` record and its
 * topology, model and required-output receipts under the invocation partition
 * of the authority store, then returns the exact launchable deployment. The
 * workspace mirror it offers is diagnostic only: protected reads never consult
 * it. Nothing here reads or writes `artifacts/orchestration/orchestrator-state.json`,
 * and no feature issue or checkpoint is required.
 */

import type { DiscoveryRuntimeIdentity } from "./discovery-service-types";
import {
  type AuthorityStoreIO,
  type ProtectedEnvelope,
  type ProtectedWorkspaceBinding,
  rejectCallerAuthorityClaims,
} from "./discovery-authority";
import {
  type AuthorityLocation,
  invocationDirectory,
  sessionDirectory,
  sha256Hex,
} from "./discovery-authority-paths";
import {
  CALLER_IDENTITY_KEYS,
  canonicalJson,
  type NativeIdentity,
} from "./discovery-authorization-record";
import {
  DISCOVERY_INVOCATION_SCHEMA,
  type DiscoveryInvocationError,
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
export const CAPABILITY_ATTESTATION_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:capability-attestation";
export const CAPABILITY_ATTESTATION_FILE = "capability-attestation.json";
export const TOPOLOGY_RECEIPT_FILE = "topology-receipt.json";
export const MODEL_RECEIPT_FILE = "model-receipt.json";
export const REQUIRED_OUTPUTS_FILE = "required-outputs.json";
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
const CONTROL_NAMES: ReadonlyArray<string> = [
  "workspace_trusted",
  "hooks_enabled",
  "trusted_attribution",
  "start_event",
  "tool_event",
  "stop_event",
  "forbidden_tools_denied",
];

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
  readonly availableModels?: ReadonlySet<string>;
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

function capabilityInvalid(detail: string): DiscoveryInvocationError {
  return refuse(
    "INVOCATION_CAPABILITY_INVALID",
    `Capability attestation is malformed: ${detail}`,
  );
}

/**
 * Read and verify the session's capability attestation from the protected store.
 *
 * Only the protected copy is consulted; attestations supplied by the caller or
 * by repository JSON are never accepted. The attestation must be `supported`
 * with every control true and the sentinel probe denied, bound to this
 * workspace, host, session and runtime, and inside its validity window.
 */
export function readCapabilityAttestation(options: {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly sessionId: string;
  readonly expected: {
    readonly workspace: ProtectedWorkspaceBinding;
    readonly host: string;
    readonly runtime: DiscoveryRuntimeIdentity;
  };
  readonly now: Date;
}): string {
  const path = `${sessionDirectory(options.location, options.sessionId)}/${CAPABILITY_ATTESTATION_FILE}`;
  const text = options.io.readText(path);
  if (text === null) {
    throw refuse(
      "INVOCATION_CAPABILITY_MISSING",
      "No current capability attestation exists for this session.",
    );
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw capabilityInvalid("not JSON");
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw capabilityInvalid("not an object");
  }
  const value = parsed as Record<string, unknown>;
  const {
    $schema: schema,
    attestation_ref: attestationRef,
    status,
    controls,
    probe,
    workspace,
    host,
    session_id: sessionId,
    runtime,
    observed_at: observedAt,
    expires_at: expiresAt,
  } = value;
  if (
    schema !== CAPABILITY_ATTESTATION_SCHEMA ||
    typeof attestationRef !== "string" ||
    attestationRef.length < 16 ||
    typeof observedAt !== "string" ||
    typeof expiresAt !== "string" ||
    Number.isNaN(Date.parse(observedAt)) ||
    Number.isNaN(Date.parse(expiresAt)) ||
    controls === null ||
    typeof controls !== "object" ||
    probe === null ||
    typeof probe !== "object"
  ) {
    throw capabilityInvalid("envelope fields");
  }
  const controlValues = controls as Record<string, unknown>;
  const { result: probeResult } = probe as { result?: unknown };
  // Fail closed: anything short of full supported controls is unsupported.
  if (
    status !== "supported" ||
    CONTROL_NAMES.some((name) => controlValues[name] !== true) ||
    probeResult !== "denied"
  ) {
    throw refuse(
      "INVOCATION_CAPABILITY_UNSUPPORTED",
      "The host does not provide the required discovery controls.",
    );
  }
  if (
    canonicalJson(workspace) !== canonicalJson(options.expected.workspace) ||
    host !== options.expected.host ||
    sessionId !== options.sessionId ||
    canonicalJson(runtime) !== canonicalJson(options.expected.runtime)
  ) {
    throw refuse(
      "INVOCATION_CAPABILITY_MISMATCH",
      "Capability attestation is bound to another workspace, host, session or runtime.",
    );
  }
  const instant = options.now.getTime();
  if (!(Date.parse(observedAt) <= instant && instant < Date.parse(expiresAt))) {
    throw refuse(
      "INVOCATION_CAPABILITY_EXPIRED",
      "Capability attestation is outside its validity window.",
    );
  }
  return attestationRef;
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
 * Prepare one discovery invocation and persist its protected bindings.
 *
 * Order: trusted context, request shape, routing (fails before any I/O),
 * activation envelope, capability attestation, then exclusive creation of the
 * four protected records. The deployment is returned only after every record
 * exists.
 */
export function prepareDiscoveryInvocation(
  options: PrepareOptions,
): PreparedDiscoveryInvocation {
  const { location, io, context, runtime, now } = options;
  validateContext(context);
  const request = validateRequestShape(options.request);
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
    expected: { workspace: envelope.workspace, host: context.host, runtime },
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
