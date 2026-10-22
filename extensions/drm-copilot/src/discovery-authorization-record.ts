/**
 * Decode native tool authorizations and compute normalized input digests.
 *
 * This module is pure. It defines the controlled tool/operation table, the
 * root-only operation set, the strict `tool-authorization` record codec and
 * the Python-identical `canonical_json` digest of `{inputs, operation, tool}`.
 * `tests/fixtures/discovery_host/tool-authorizations.json` pins every vector for
 * both runtimes. Consumption lives in `discovery-authorization.ts`.
 */

import { createHash } from "node:crypto";

import type { ProtectedWorkspaceBinding } from "./discovery-authority";
import { assertRelativePath } from "./discovery-authority-record";
export const AUTHORIZATION_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:tool-authorization";

export type ControlledTool =
  | "read_discovery_source"
  | "run_discovery_repo_inventory"
  | "run_discovery_dotnet_analyzer"
  | "run_discovery_vsto_analyzer"
  | "create_discovery_artifact"
  | "update_discovery_artifact"
  | "link_discovery_evidence"
  | "run_discovery_scenario_generation"
  | "run_discovery_report"
  | "validate_discovery_artifacts"
  | "finalize_discovery_agent";

/** Operations each controlled tool may be authorized for; the union is the enum. */
export const TOOL_OPERATIONS: Readonly<
  Record<ControlledTool, ReadonlyArray<string>>
> = {
  read_discovery_source: ["read-source"],
  run_discovery_repo_inventory: ["inventory"],
  run_discovery_dotnet_analyzer: ["inventory"],
  run_discovery_vsto_analyzer: ["inventory"],
  create_discovery_artifact: ["new-contract", "new-scenario"],
  update_discovery_artifact: ["update-artifact"],
  link_discovery_evidence: ["link-evidence"],
  run_discovery_scenario_generation: ["generate-acceptance"],
  run_discovery_report: [
    "coverage-report",
    "parity-report",
    "completion-report",
  ],
  validate_discovery_artifacts: [
    "profile",
    "validate-profile",
    "validate-feature-contract",
    "validate-coverage-ledger",
    "validate-runtime-scenario",
    "validate-parity-matrix",
    "validate-unspecified-behavior",
    "validate-product-decision",
    "validate-evidence-reference",
    "validate-decisions",
    "validate-all",
  ],
  finalize_discovery_agent: ["finalize-agent"],
};
export const CONTROLLED_TOOLS: ReadonlyArray<string> =
  Object.keys(TOOL_OPERATIONS);
export const CONTROLLED_OPERATIONS: ReadonlyArray<string> = [
  ...new Set(Object.values(TOOL_OPERATIONS).flat()),
].sort();
/** Request operations that no analyst authorization can ever admit. */
export const ROOT_ONLY_OPERATIONS: ReadonlyArray<string> = [
  "init",
  "configure",
  "snapshot-export",
  "snapshot-import",
  "import-inventory",
  "migrate",
  "doctor",
  "prepare-agent",
];
/** Caller-supplied identity fields are never read; their presence is refused. */
export const CALLER_IDENTITY_KEYS: ReadonlyArray<string> = [
  "agent_id",
  "host",
  "invocation_id",
  "request_id",
  "role",
  "session_id",
];
const HOSTS: ReadonlyArray<string> = ["claude-code", "codex", "github-copilot"];
const ROLES: ReadonlyArray<string> = [
  "legacy-parity-analyst",
  "runtime-characterization-analyst",
  "requirements-reconciler",
  "migration-coverage-reviewer",
];
const STATES: ReadonlyArray<string> = ["issued", "consumed", "revoked"];
export const AUTHORIZATION_RECORD_KEYS: ReadonlyArray<string> = [
  "$schema",
  "artifact_kind",
  "authorization_ref",
  "capability_ref",
  "consumed_at",
  "expires_at",
  "id",
  "identity",
  "input_sha256",
  "invocation_ref",
  "issued_at",
  "operation",
  "request_id",
  "schema_version",
  "start_attestation_ref",
  "state",
  "tool",
  "workspace",
  "writer",
];
const SHA256 = /^[0-9a-f]{64}$/u;
export const CORRELATION_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]*$/u;
const OPAQUE_REFERENCE = /^[A-Za-z0-9][A-Za-z0-9._-]*$/u;
const IDENTIFIER = /^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$/u;
const TIMESTAMP =
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/u;

export type DiscoveryAuthorizationCode =
  | "AUTHORIZATION_REQUEST_INVALID"
  | "AUTHORIZATION_INPUT_INVALID"
  | "AUTHORIZATION_OPERATION_UNKNOWN"
  | "AUTHORIZATION_ROOT_ONLY"
  | "AUTHORIZATION_TOOL_OPERATION"
  | "AUTHORIZATION_RECORD_INVALID"
  | "AUTHORIZATION_MISSING"
  | "AUTHORIZATION_AMBIGUOUS"
  | "AUTHORIZATION_CONSUMED"
  | "AUTHORIZATION_EXPIRED"
  | "AUTHORIZATION_WORKSPACE"
  | "AUTHORIZATION_IDENTITY"
  | "AUTHORIZATION_INPUT"
  | "AUTHORIZATION_IO";

/** Raised for every refused controlled tool request. */
export class DiscoveryAuthorizationError extends Error {
  readonly code: DiscoveryAuthorizationCode;

  constructor(code: DiscoveryAuthorizationCode, message: string) {
    super(message);
    this.name = "DiscoveryAuthorizationError";
    this.code = code;
  }
}

/** Trusted native identity taken from the host event, never from the request. */
export interface NativeIdentity {
  readonly host: string;
  readonly session_id: string;
  readonly agent_id: string;
  readonly role: string;
  readonly invocation_id: string;
}

export interface AuthorizationWriter {
  readonly kind: "native-pretooluse";
  readonly host: string;
  readonly event_id: string;
  readonly handler_sha256: string;
}

/** One `tool-authorization` record as written by the native adapter. */
export interface ToolAuthorizationRecord {
  readonly $schema: typeof AUTHORIZATION_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "tool-authorization";
  readonly id: string;
  readonly authorization_ref: string;
  readonly request_id: string;
  readonly workspace: ProtectedWorkspaceBinding;
  readonly identity: NativeIdentity;
  readonly tool: ControlledTool;
  readonly operation: string;
  readonly input_sha256: string;
  readonly invocation_ref: string;
  readonly start_attestation_ref: string;
  readonly capability_ref: string;
  readonly issued_at: string;
  readonly expires_at: string;
  readonly state: "issued" | "consumed" | "revoked";
  readonly consumed_at: string | null;
  readonly writer: AuthorizationWriter;
}

/** Controlled request as received by the service; nothing in it is trusted. */
export function refuse(
  code: DiscoveryAuthorizationCode,
  message: string,
): DiscoveryAuthorizationError {
  return new DiscoveryAuthorizationError(code, message);
}

/** Render JSON exactly as Python `canonical_json`: sorted keys, compact, LF. */
export function canonicalJson(value: unknown): string {
  return `${renderCanonical(value)}\n`;
}

function renderCanonical(value: unknown): string {
  // Routing by JSON type; anything outside JSON (undefined, functions,
  // non-integer numbers) cannot be normalized identically in both runtimes.
  if (value === null) {
    return "null";
  }
  if (typeof value === "boolean" || typeof value === "string") {
    return JSON.stringify(value);
  }
  if (typeof value === "number") {
    if (!Number.isSafeInteger(value)) {
      throw refuse(
        "AUTHORIZATION_INPUT_INVALID",
        "Tool inputs may contain only safe integers as numbers.",
      );
    }
    return String(value);
  }
  if (Array.isArray(value)) {
    return `[${value.map((item) => renderCanonical(item)).join(",")}]`;
  }
  if (typeof value === "object") {
    const record = value as Record<string, unknown>;
    const members = Object.keys(record)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${renderCanonical(record[key])}`);
    return `{${members.join(",")}}`;
  }
  throw refuse(
    "AUTHORIZATION_INPUT_INVALID",
    `Tool inputs contain a non-JSON value of type ${typeof value}.`,
  );
}

/** Digest of the normalized tool request; equal requests have equal digests. */
export function computeInputDigest(
  tool: string,
  operation: string,
  inputs: unknown,
): string {
  if (inputs === null || typeof inputs !== "object" || Array.isArray(inputs)) {
    throw refuse(
      "AUTHORIZATION_INPUT_INVALID",
      "Tool inputs must be a JSON object.",
    );
  }
  return createHash("sha256")
    .update(canonicalJson({ inputs, operation, tool }), "utf8")
    .digest("hex");
}

export function isText(
  value: unknown,
  pattern: RegExp,
  max = 256,
): value is string {
  return (
    typeof value === "string" &&
    value.length >= 1 &&
    value.length <= max &&
    pattern.test(value)
  );
}

function isReference(value: unknown): value is string {
  return isText(value, OPAQUE_REFERENCE) && (value as string).length >= 16;
}

function isTimestamp(value: unknown): value is string {
  return (
    typeof value === "string" &&
    TIMESTAMP.test(value) &&
    !Number.isNaN(Date.parse(value))
  );
}

function recordInvalid(detail: string): DiscoveryAuthorizationError {
  return refuse(
    "AUTHORIZATION_RECORD_INVALID",
    `Native authorization record is malformed: ${detail}`,
  );
}

/** Same keys as `T`, every value still unverified. */
type Loose<T> = { readonly [K in keyof T]?: unknown };

function decodeWorkspace(value: unknown): ProtectedWorkspaceBinding {
  const binding = value as Loose<ProtectedWorkspaceBinding> | null;
  if (
    binding === null ||
    typeof binding !== "object" ||
    Object.keys(binding).sort().join(",") !==
      "profile_path,profile_sha256,workspace_root,workspace_sha256" ||
    typeof binding.workspace_root !== "string" ||
    binding.workspace_root === "." ||
    !isText(binding.workspace_sha256, SHA256, 64) ||
    typeof binding.profile_path !== "string" ||
    !isText(binding.profile_sha256, SHA256, 64)
  ) {
    throw recordInvalid("workspace binding");
  }
  try {
    assertRelativePath(binding.profile_path);
  } catch {
    throw recordInvalid("workspace profile path");
  }
  return {
    workspace_root: binding.workspace_root,
    workspace_sha256: binding.workspace_sha256,
    profile_path: binding.profile_path,
    profile_sha256: binding.profile_sha256,
  };
}

function decodeIdentity(value: unknown): NativeIdentity {
  const identity = value as Loose<NativeIdentity> | null;
  if (
    identity === null ||
    typeof identity !== "object" ||
    Object.keys(identity).sort().join(",") !==
      "agent_id,host,invocation_id,role,session_id" ||
    !HOSTS.includes(identity.host as string) ||
    !isText(identity.session_id, CORRELATION_ID) ||
    !isText(identity.agent_id, CORRELATION_ID) ||
    !ROLES.includes(identity.role as string) ||
    !isText(identity.invocation_id, CORRELATION_ID)
  ) {
    throw recordInvalid("native identity");
  }
  return {
    host: identity.host as string,
    session_id: identity.session_id,
    agent_id: identity.agent_id,
    role: identity.role as string,
    invocation_id: identity.invocation_id,
  };
}

function decodeWriter(value: unknown): AuthorizationWriter {
  const writer = value as Loose<AuthorizationWriter> | null;
  if (
    writer === null ||
    typeof writer !== "object" ||
    Object.keys(writer).sort().join(",") !==
      "event_id,handler_sha256,host,kind" ||
    writer.kind !== "native-pretooluse" ||
    !HOSTS.includes(writer.host as string) ||
    !isText(writer.event_id, CORRELATION_ID) ||
    !isText(writer.handler_sha256, SHA256, 64)
  ) {
    throw recordInvalid("writer");
  }
  return {
    kind: "native-pretooluse",
    host: writer.host as string,
    event_id: writer.event_id,
    handler_sha256: writer.handler_sha256,
  };
}

/** Parse one record strictly; malformed records are errors, never skipped. */
export function decodeToolAuthorization(text: string): ToolAuthorizationRecord {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw recordInvalid("not JSON");
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw recordInvalid("not an object");
  }
  const value = parsed as Record<string, unknown>;
  if (
    Object.keys(value).sort().join(",") !== AUTHORIZATION_RECORD_KEYS.join(",")
  ) {
    throw recordInvalid("key set");
  }
  const {
    $schema: schema,
    schema_version: schemaVersion,
    artifact_kind: artifactKind,
    id,
    authorization_ref: authorizationRef,
    request_id: requestId,
    workspace,
    identity,
    input_sha256: inputSha256,
    invocation_ref: invocationRef,
    start_attestation_ref: startAttestationRef,
    capability_ref: capabilityRef,
    issued_at: issuedAt,
    expires_at: expiresAt,
    consumed_at: consumedAt,
    writer,
  } = value;
  const {
    tool: toolValue,
    operation: operationValue,
    state: stateValue,
  } = value;
  const tool = toolValue as string;
  const operation = operationValue as string;
  const state = stateValue as string;
  // Scalar envelope rules mirror the tool-authorization schema constraints.
  if (
    schema !== AUTHORIZATION_SCHEMA ||
    schemaVersion !== "2.0.0" ||
    artifactKind !== "tool-authorization" ||
    !isText(id, IDENTIFIER) ||
    !isReference(authorizationRef) ||
    !isText(requestId, CORRELATION_ID) ||
    !CONTROLLED_TOOLS.includes(tool) ||
    !TOOL_OPERATIONS[tool as ControlledTool].includes(operation) ||
    !isText(inputSha256, SHA256, 64) ||
    !isReference(invocationRef) ||
    !isReference(startAttestationRef) ||
    !isReference(capabilityRef) ||
    !isTimestamp(issuedAt) ||
    !isTimestamp(expiresAt) ||
    !STATES.includes(state)
  ) {
    throw recordInvalid("envelope fields");
  }
  // A consumed record carries its stamp; an issued one must not.
  const stamped = consumedAt !== null;
  if (
    (state === "consumed" && !isTimestamp(consumedAt)) ||
    (state === "issued" && stamped) ||
    (stamped && !isTimestamp(consumedAt))
  ) {
    throw recordInvalid("consumed_at");
  }
  return {
    $schema: AUTHORIZATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "tool-authorization",
    id,
    authorization_ref: authorizationRef,
    request_id: requestId,
    workspace: decodeWorkspace(workspace),
    identity: decodeIdentity(identity),
    tool: tool as ControlledTool,
    operation,
    input_sha256: inputSha256,
    invocation_ref: invocationRef,
    start_attestation_ref: startAttestationRef,
    capability_ref: capabilityRef,
    issued_at: issuedAt,
    expires_at: expiresAt,
    state: state as "issued" | "consumed" | "revoked",
    consumed_at: consumedAt as string | null,
    writer: decodeWriter(writer),
  };
}
