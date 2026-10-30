/**
 * Shared seeding helpers for the one-use records the native hooks write.
 *
 * The binding, identity, service and agent suites share one way of turning a
 * prepared invocation into a started one, of issuing a tool authorization
 * bound to that invocation and the exact call, of issuing a root grant for a
 * root call, and of recording a sentinel observation. Everything is written
 * into the in-memory store; no file, process, network or clock is touched.
 */

import {
  invocationDirectory,
  sessionDirectory,
} from "../src/discovery-authority-paths";
import {
  AUTHORIZATIONS_PARTITION,
  computeInputDigest,
  type ControlledTool,
  type ToolAuthorizationRecord,
} from "../src/discovery-authorization";
import { prepareDiscoveryInvocation } from "../src/discovery-invocation";
import {
  ROOT_GRANT_SCHEMA,
  type RootGrantRecord,
  ROOT_GRANTS_PARTITION,
} from "../src/discovery-root-grant";
import {
  HOST_OBSERVATION_SCHEMA,
  OBSERVATIONS_PARTITION,
  SENTINEL_OPERATION,
  SENTINEL_TOOL,
} from "../src/discovery-sentinel";
import { vectors } from "./discovery-authorization-test-support";
import {
  ACTIVATION,
  CONTEXT,
  LOCATION,
  options,
  request,
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
import type { MemoryStoreIO } from "./discovery-store-test-helpers";

/** Agent the native start hook attributes to the prepared invocation. */
export const AGENT_ID = "agent-alpha";
/** Role of the invocation `request()` prepares (inventory-legacy-system). */
export const AGENT_ROLE = "legacy-parity-analyst";
export const AUTHORIZATION_REF = "authz-alpha-0000000000000001";
export const ROOT_GRANT_REF = "grant-0123456789abcdef0001";
export const OBSERVATION_REF = "observation-0123456789abcdef0123";
export const START_ATTESTATION_REF = "attestation-alpha-00000000001";

export interface PreparedStore {
  readonly io: MemoryStoreIO;
  readonly invocationId: string;
}

/** Prepare one invocation over a supported session, as the root prepare does. */
export function preparedStore(skillId?: string): PreparedStore {
  const io = seeded();
  const prepared = prepareDiscoveryInvocation(
    options(io, { activation: ACTIVATION, request: request(skillId) }),
  );
  return { io, invocationId: prepared.record.invocation_id };
}

/**
 * Mark the prepared invocation as started by `agentId`, which is what the
 * native start hook records when exactly one prepared invocation matches.
 */
export function startInvocation(
  io: MemoryStoreIO,
  invocationId: string,
  agentId: string = AGENT_ID,
  sessionId: string = CONTEXT.sessionId,
): void {
  const path = `${invocationDirectory(LOCATION, sessionId, invocationId)}/invocation.json`;
  const record = JSON.parse(io.files.get(path)!) as Record<string, unknown>;
  io.files.set(
    path,
    JSON.stringify({
      ...record,
      state: "started",
      agent_id: agentId,
      start_attestation_ref: START_ATTESTATION_REF,
    }),
  );
}

/** Prepare and start one invocation for `AGENT_ID`. */
export function startedStore(skillId?: string): PreparedStore {
  const store = preparedStore(skillId);
  startInvocation(store.io, store.invocationId);
  return store;
}

export interface AuthorizationOptions {
  readonly invocationId: string;
  readonly tool: ControlledTool;
  readonly operation: string;
  readonly inputs: unknown;
  readonly ref?: string;
  readonly agentId?: string;
  readonly role?: string;
  readonly host?: string;
  readonly sessionId?: string;
  readonly workspace?: ToolAuthorizationRecord["workspace"];
  readonly record?: Partial<ToolAuthorizationRecord>;
}

/**
 * Write one issued tool authorization bound to the invocation and the exact
 * tool, operation and input digest, as the native PreToolUse gate does.
 * Returns the authorization reference.
 */
export function issueAuthorization(
  io: MemoryStoreIO,
  authorization: AuthorizationOptions,
): string {
  const ref = authorization.ref ?? AUTHORIZATION_REF;
  const sessionId = authorization.sessionId ?? CONTEXT.sessionId;
  const identity = {
    host: authorization.host ?? CONTEXT.host,
    session_id: sessionId,
    agent_id: authorization.agentId ?? AGENT_ID,
    role: authorization.role ?? AGENT_ROLE,
    invocation_id: authorization.invocationId,
  };
  const record: ToolAuthorizationRecord = {
    ...vectors.records.issued,
    authorization_ref: ref,
    workspace: authorization.workspace ?? WORKSPACE,
    identity,
    tool: authorization.tool,
    operation: authorization.operation,
    input_sha256: computeInputDigest(
      authorization.tool,
      authorization.operation,
      authorization.inputs,
    ),
    invocation_ref: authorization.invocationId,
    issued_at: "2026-10-22T11:59:00Z",
    expires_at: "2026-10-22T12:30:00Z",
    state: "issued",
    consumed_at: null,
    writer: { ...vectors.records.issued.writer, host: identity.host },
    ...authorization.record,
  };
  const directory = `${invocationDirectory(LOCATION, sessionId, authorization.invocationId)}/${AUTHORIZATIONS_PARTITION}`;
  io.files.set(`${directory}/${ref}.json`, JSON.stringify(record));
  return ref;
}

export interface RootGrantOptions {
  readonly tool: string;
  readonly operation: string;
  readonly inputs: unknown;
  readonly ref?: string;
  readonly host?: string;
  readonly sessionId?: string;
  readonly parentAgentId?: string;
  readonly record?: Partial<RootGrantRecord>;
}

/**
 * Write one issued root grant for a root call of `tool`, as the native gate
 * does for a payload without agent identity. Returns the grant reference.
 */
export function issueRootGrant(
  io: MemoryStoreIO,
  grant: RootGrantOptions,
): string {
  const ref = grant.ref ?? ROOT_GRANT_REF;
  const record: RootGrantRecord = {
    $schema: ROOT_GRANT_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "root-grant",
    id: ref,
    grant_ref: ref,
    host: grant.host ?? CONTEXT.host,
    session_id: grant.sessionId ?? CONTEXT.sessionId,
    parent_agent_id: grant.parentAgentId ?? CONTEXT.parentAgentId,
    tool: grant.tool,
    operation: grant.operation,
    input_sha256: computeInputDigest(grant.tool, grant.operation, grant.inputs),
    tool_use_id: "toolu-0123456789abcdef",
    handler_sha256: "c".repeat(64),
    issued_at: "2026-10-22T11:59:00Z",
    expires_at: "2026-10-22T12:04:00Z",
    state: "issued",
    ...grant.record,
  };
  io.files.set(
    `${LOCATION.directory}/${ROOT_GRANTS_PARTITION}/${ref}.json`,
    JSON.stringify(record),
  );
  return ref;
}

/** `root-grants/<ref>.json` under the fixture location. */
export function rootGrantPath(ref: string = ROOT_GRANT_REF): string {
  return `${LOCATION.directory}/${ROOT_GRANTS_PARTITION}/${ref}.json`;
}

export interface ObservationOptions {
  readonly inputs?: unknown;
  readonly ref?: string;
  readonly sessionId?: string;
  readonly agentId?: string | null;
  readonly agentType?: string | null;
  readonly withGrant?: boolean;
  readonly record?: Record<string, unknown>;
}

/**
 * Record one host observation of the sentinel tool call, carrying the one-use
 * sentinel grant fields unless `withGrant` is false. Returns the record path.
 */
export function recordObservation(
  io: MemoryStoreIO,
  observation: ObservationOptions = {},
): string {
  const ref = observation.ref ?? OBSERVATION_REF;
  const sessionId = observation.sessionId ?? CONTEXT.sessionId;
  const record: Record<string, unknown> = {
    $schema: HOST_OBSERVATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "host-observation",
    id: ref,
    observation_ref: ref,
    host: CONTEXT.host,
    session_id: sessionId,
    agent_id:
      observation.agentId === undefined
        ? "agent-sentinel"
        : observation.agentId,
    agent_type:
      observation.agentType === undefined
        ? "discovery-capability-sentinel"
        : observation.agentType,
    parent_agent_id: "root",
    tool_name: "mcp__drm-copilot__discovery_capability_sentinel",
    tool_use_id_present: true,
    decision: "allow",
    code: "SENTINEL",
    handler_sha256: "c".repeat(64),
    observed_at: "2026-10-22T11:59:00Z",
    ...(observation.withGrant === false
      ? {}
      : {
          tool: SENTINEL_TOOL,
          input_sha256: computeInputDigest(
            SENTINEL_TOOL,
            SENTINEL_OPERATION,
            observation.inputs ?? { workspace_root: WORKSPACE.workspace_root },
          ),
          expires_at: "2026-10-22T12:04:00Z",
          state: "issued",
        }),
    ...observation.record,
  };
  const path = `${sessionDirectory(LOCATION, sessionId)}/${OBSERVATIONS_PARTITION}/${ref}.json`;
  io.files.set(path, JSON.stringify(record));
  return path;
}
