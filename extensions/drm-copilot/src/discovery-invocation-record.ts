/**
 * Define and decode the protected `discovery-invocation` record.
 *
 * The record binds invocation identity, workspace/profile digests, operation,
 * role, runtime, output manifest, scope digest, deployment and capability
 * reference. Reading is strict: the key set must match the schema, the write
 * count must be zero, the role and skill must be known, and the record must
 * belong to the workspace and partition it was read from. Workspace mirrors
 * are never consulted. Preparation lives in `discovery-invocation.ts`.
 */

import type { DiscoveryRuntimeIdentity } from "./discovery-service-types";
import type {
  AuthorityStoreIO,
  ProtectedWorkspaceBinding,
} from "./discovery-authority";
import {
  type AuthorityLocation,
  invocationDirectory,
} from "./discovery-authority-paths";
import {
  DISCOVERY_ROLES,
  DISCOVERY_SKILL_IDS,
  type InvocationDeployment,
  type RequiredOutputManifest,
} from "./discovery-routing";
export const DISCOVERY_INVOCATION_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:discovery-invocation";
export const INVOCATION_RECORD_FILE = "invocation.json";
export const INVOCATION_RECORD_KEYS: ReadonlyArray<string> = [
  "$schema",
  "agent_id",
  "artifact_kind",
  "capability_ref",
  "completion_receipt_ref",
  "created_at",
  "deployment",
  "gate_mode",
  "host",
  "id",
  "input_sha256",
  "invocation_id",
  "model_receipt_ref",
  "operation",
  "parent_agent_id",
  "production_write_count",
  "required_outputs",
  "role",
  "runtime",
  "schema_version",
  "scope_sha256",
  "selected_ids",
  "selected_paths",
  "session_id",
  "skill_id",
  "start_attestation_ref",
  "state",
  "topology_receipt_ref",
  "workspace",
];
export const HOSTS: ReadonlyArray<string> = [
  "claude-code",
  "codex",
  "github-copilot",
];

export type DiscoveryInvocationCode =
  | "INVOCATION_REQUEST_INVALID"
  | "INVOCATION_CONTEXT_INVALID"
  | "INVOCATION_NESTED_LAUNCH"
  | "INVOCATION_CAPABILITY_MISSING"
  | "INVOCATION_CAPABILITY_INVALID"
  | "INVOCATION_CAPABILITY_UNSUPPORTED"
  | "INVOCATION_CAPABILITY_MISMATCH"
  | "INVOCATION_CAPABILITY_EXPIRED"
  | "INVOCATION_MISSING"
  | "INVOCATION_RECORD_INVALID";

/** Raised when a discovery invocation cannot be prepared or loaded. */
export class DiscoveryInvocationError extends Error {
  readonly code: DiscoveryInvocationCode;

  constructor(code: DiscoveryInvocationCode, message: string) {
    super(message);
    this.name = "DiscoveryInvocationError";
    this.code = code;
  }
}

export interface DiscoveryInvocationRecord {
  readonly $schema: typeof DISCOVERY_INVOCATION_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "discovery-invocation";
  readonly id: string;
  readonly invocation_id: string;
  readonly workspace: ProtectedWorkspaceBinding;
  readonly host: string;
  readonly session_id: string;
  readonly parent_agent_id: string;
  readonly agent_id: string | null;
  readonly role: string;
  readonly skill_id: string;
  readonly operation: string;
  readonly gate_mode: string;
  readonly selected_ids: ReadonlyArray<string>;
  readonly selected_paths: ReadonlyArray<string>;
  readonly scope_sha256: string;
  readonly input_sha256: string;
  readonly runtime: DiscoveryRuntimeIdentity;
  readonly deployment: InvocationDeployment;
  readonly required_outputs: RequiredOutputManifest;
  readonly capability_ref: string;
  readonly topology_receipt_ref: string;
  readonly model_receipt_ref: string;
  readonly production_write_count: 0;
  readonly state: "prepared" | "started" | "finalized" | "revoked";
  readonly created_at: string;
  readonly start_attestation_ref: string | null;
  readonly completion_receipt_ref: string | null;
}

export function refuse(
  code: DiscoveryInvocationCode,
  message: string,
): DiscoveryInvocationError {
  return new DiscoveryInvocationError(code, message);
}

/**
 * Parse a protected invocation record strictly.
 *
 * The key set must match the schema exactly, the write count must be zero,
 * the role and skill must be known, and the workspace digest must match the
 * location it was read from.
 */
export function decodeDiscoveryInvocation(
  text: string,
  options: { readonly workspaceSha256: string },
): DiscoveryInvocationRecord {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw refuse("INVOCATION_RECORD_INVALID", "Invocation record is not JSON.");
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw refuse(
      "INVOCATION_RECORD_INVALID",
      "Invocation record is not an object.",
    );
  }
  const value = parsed as Record<string, unknown>;
  if (
    Object.keys(value).sort().join(",") !== INVOCATION_RECORD_KEYS.join(",")
  ) {
    throw refuse(
      "INVOCATION_RECORD_INVALID",
      "Invocation record key set differs.",
    );
  }
  const record = value as unknown as DiscoveryInvocationRecord;
  if (
    record.$schema !== DISCOVERY_INVOCATION_SCHEMA ||
    record.schema_version !== "2.0.0" ||
    record.artifact_kind !== "discovery-invocation" ||
    record.production_write_count !== 0 ||
    !["prepared", "started", "finalized", "revoked"].includes(record.state) ||
    !DISCOVERY_ROLES.includes(record.role) ||
    !DISCOVERY_SKILL_IDS.includes(record.skill_id) ||
    !HOSTS.includes(record.host) ||
    typeof record.workspace !== "object" ||
    record.workspace.workspace_sha256 !== options.workspaceSha256 ||
    (record.state === "prepared" &&
      (record.agent_id !== null || record.start_attestation_ref !== null))
  ) {
    throw refuse(
      "INVOCATION_RECORD_INVALID",
      "Invocation record violates its contract.",
    );
  }
  return record;
}

/** Load a prepared invocation from the protected store; mirrors are ignored. */
export function loadPreparedInvocation(options: {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly sessionId: string;
  readonly invocationId: string;
}): DiscoveryInvocationRecord {
  const directory = invocationDirectory(
    options.location,
    options.sessionId,
    options.invocationId,
  );
  const text = options.io.readText(`${directory}/${INVOCATION_RECORD_FILE}`);
  if (text === null) {
    throw refuse(
      "INVOCATION_MISSING",
      `No protected invocation ${options.invocationId} exists for this session.`,
    );
  }
  const record = decodeDiscoveryInvocation(text, {
    workspaceSha256: options.location.workspaceSha256,
  });
  if (
    record.invocation_id !== options.invocationId ||
    record.session_id !== options.sessionId ||
    record.state !== "prepared"
  ) {
    throw refuse(
      "INVOCATION_RECORD_INVALID",
      "Protected invocation does not match its partition or is not prepared.",
    );
  }
  return record;
}
