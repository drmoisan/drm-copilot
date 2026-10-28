/**
 * Consume exact one-use native tool authorizations.
 *
 * A native PreToolUse adapter issues a short-lived `tool-authorization` record
 * for one permitted purpose-built tool call. The record is keyed by the caller
 * request id (a correlation key, never authority) and bound to the exact
 * normalized tool/operation/input digest, the protected workspace binding and
 * the trusted native identity of the invocation. This module finds the unique
 * unconsumed record for a controlled request, verifies every binding, and
 * consumes it exactly once through an exclusive latch. Zero or ambiguous
 * matches, replays, expired grants, foreign workspaces or identities, root-only
 * operations and caller-supplied identity or authority claims are rejected.
 * The record codec and digest live in `discovery-authorization-record.ts`.
 */

import * as nodeFs from "node:fs";

import {
  type AuthorityFileSystemModule,
  type AuthorityStoreIO,
  createNodeAuthorityStoreIO,
  type ProtectedWorkspaceBinding,
  rejectCallerAuthorityClaims,
} from "./discovery-authority";
import {
  type AuthorityLocation,
  invocationDirectory,
} from "./discovery-authority-paths";
import { DiscoveryAuthorityError } from "./discovery-authority-record";
import {
  CALLER_IDENTITY_KEYS,
  canonicalJson,
  computeInputDigest,
  CONTROLLED_OPERATIONS,
  CONTROLLED_TOOLS,
  type ControlledTool,
  CORRELATION_ID,
  decodeToolAuthorization,
  isText,
  type NativeIdentity,
  refuse,
  ROOT_ONLY_OPERATIONS,
  TOOL_OPERATIONS,
  type ToolAuthorizationRecord,
} from "./discovery-authorization-record";

export {
  AUTHORIZATION_RECORD_KEYS,
  AUTHORIZATION_SCHEMA,
  CALLER_IDENTITY_KEYS,
  canonicalJson,
  computeInputDigest,
  CONTROLLED_OPERATIONS,
  CONTROLLED_TOOLS,
  decodeToolAuthorization,
  DiscoveryAuthorizationError,
  ROOT_ONLY_OPERATIONS,
  TOOL_OPERATIONS,
} from "./discovery-authorization-record";
export type {
  AuthorizationWriter,
  ControlledTool,
  DiscoveryAuthorizationCode,
  NativeIdentity,
  ToolAuthorizationRecord,
} from "./discovery-authorization-record";
export const AUTHORIZATIONS_PARTITION = "authorizations";
export const CONSUMED_LATCH_SUFFIX = ".consumed";

export interface ControlledToolRequest {
  readonly requestId: string;
  readonly tool: string;
  readonly operation: string;
  readonly inputs: unknown;
}

/** Host-verified bindings the consumer compares the record against. */
export interface TrustedBinding {
  readonly workspace: ProtectedWorkspaceBinding;
  readonly identity: NativeIdentity;
}

export interface ConsumedAuthorization {
  readonly authorizationRef: string;
  readonly inputSha256: string;
  readonly path: string;
  readonly record: ToolAuthorizationRecord;
}

/** Store seam: the authority seam plus directory listing. */
export interface AuthorizationStoreIO extends AuthorityStoreIO {
  /** Immediate entry names of `directory`, sorted; `[]` when it does not exist. */
  listEntries(directory: string): string[];
}

/** `<invocation>/authorizations` for the trusted session and invocation. */
export function authorizationsDirectory(
  location: AuthorityLocation,
  identity: NativeIdentity,
): string {
  const invocation = invocationDirectory(
    location,
    identity.session_id,
    identity.invocation_id,
  );
  return `${invocation}/${AUTHORIZATIONS_PARTITION}`;
}

/** Tool request fields shared by the request-id and the binding consumers. */
export type BoundToolRequest = Omit<ControlledToolRequest, "requestId"> & {
  /** Protected invocation the caller's tool call is bound to. */
  readonly invocationRef: string;
};

function validateRequest(request: ControlledToolRequest): string {
  if (!isText(request.requestId, CORRELATION_ID)) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      "Request id must be a correlation identifier.",
    );
  }
  return validateControlledRequest(request);
}

/** Validate the tool, operation and inputs of a controlled request; return the digest. */
function validateControlledRequest(
  request: Omit<ControlledToolRequest, "requestId">,
): string {
  rejectCallerAuthorityClaims(request.inputs, "Tool request inputs");
  if (request.inputs !== null && typeof request.inputs === "object") {
    const claimed = CALLER_IDENTITY_KEYS.filter((key) =>
      Object.prototype.hasOwnProperty.call(request.inputs, key),
    );
    if (claimed.length > 0) {
      throw refuse(
        "AUTHORIZATION_REQUEST_INVALID",
        `Caller identity fields are not accepted in tool inputs: ${claimed.join(", ")}`,
      );
    }
  }
  // Operation routing: root-only operations are refused before any lookup so
  // no record, however shaped, can admit them; unknown names are refused next.
  if (ROOT_ONLY_OPERATIONS.includes(request.operation)) {
    throw refuse(
      "AUTHORIZATION_ROOT_ONLY",
      `Operation ${request.operation} requires the local-user principal.`,
    );
  }
  if (!CONTROLLED_OPERATIONS.includes(request.operation)) {
    throw refuse(
      "AUTHORIZATION_OPERATION_UNKNOWN",
      `Operation ${request.operation} is not a controlled discovery operation.`,
    );
  }
  if (!CONTROLLED_TOOLS.includes(request.tool)) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      `Tool ${request.tool} is not a controlled discovery tool.`,
    );
  }
  if (
    !TOOL_OPERATIONS[request.tool as ControlledTool].includes(request.operation)
  ) {
    throw refuse(
      "AUTHORIZATION_TOOL_OPERATION",
      `Tool ${request.tool} cannot perform ${request.operation}.`,
    );
  }
  return computeInputDigest(request.tool, request.operation, request.inputs);
}

function sameBinding(
  left: Record<string, string>,
  right: Record<string, string>,
): boolean {
  return Object.keys(left).every((key) => left[key] === right[key]);
}

export interface ConsumeOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorizationStoreIO;
  readonly request: ControlledToolRequest;
  readonly trusted: TrustedBinding;
  readonly now: Date;
}

/**
 * Admit one controlled tool request by consuming its unique native grant.
 *
 * Returns the consumed record. Throws `DiscoveryAuthorizationError` (or
 * `DiscoveryAuthorityError` for protected-claim forgery) on every refusal; a
 * refusal before the latch leaves the grant untouched.
 */
export function consumeToolAuthorization(
  options: ConsumeOptions,
): ConsumedAuthorization {
  const { location, io, request, trusted, now } = options;
  const digest = validateRequest(request);
  const directory = authorizationsDirectory(location, trusted.identity);
  const candidates: { path: string; record: ToolAuthorizationRecord }[] = [];
  // Every JSON entry is decoded; only records keyed by this request id compete.
  for (const name of io.listEntries(directory)) {
    if (!name.endsWith(".json")) {
      continue;
    }
    const path = `${directory}/${name}`;
    const text = io.readText(path);
    if (text === null) {
      continue;
    }
    const record = decodeToolAuthorization(text);
    if (record.request_id === request.requestId) {
      candidates.push({ path, record });
    }
  }
  if (candidates.length === 0) {
    throw refuse(
      "AUTHORIZATION_MISSING",
      `No native authorization matches request ${request.requestId}.`,
    );
  }
  const live = candidates.filter(
    ({ path, record }) =>
      record.state === "issued" &&
      io.readText(`${path}${CONSUMED_LATCH_SUFFIX}`) === null,
  );
  if (live.length === 0) {
    throw refuse(
      "AUTHORIZATION_CONSUMED",
      `Authorization for request ${request.requestId} was already consumed or revoked.`,
    );
  }
  if (live.length > 1) {
    throw refuse(
      "AUTHORIZATION_AMBIGUOUS",
      `Request ${request.requestId} matches ${String(live.length)} issued authorizations.`,
    );
  }
  const { path, record } = live[0]!;
  // Binding checks compare the record against host-verified values only.
  if (!sameBinding({ ...record.workspace }, { ...trusted.workspace })) {
    throw refuse(
      "AUTHORIZATION_WORKSPACE",
      "Authorization is bound to another workspace or profile.",
    );
  }
  if (!sameBinding({ ...record.identity }, { ...trusted.identity })) {
    throw refuse(
      "AUTHORIZATION_IDENTITY",
      "Authorization is bound to another native identity.",
    );
  }
  if (
    record.tool !== request.tool ||
    record.operation !== request.operation ||
    record.input_sha256 !== digest
  ) {
    throw refuse(
      "AUTHORIZATION_INPUT",
      "Authorization was issued for a different tool, operation or input.",
    );
  }
  const instant = now.getTime();
  if (!(
    Date.parse(record.issued_at) <= instant &&
    instant < Date.parse(record.expires_at)
  )) {
    throw refuse(
      "AUTHORIZATION_EXPIRED",
      "Authorization is outside its validity window.",
    );
  }
  consume(io, path, record, now);
  return {
    authorizationRef: record.authorization_ref,
    inputSha256: digest,
    path,
    record: { ...record, state: "consumed", consumed_at: now.toISOString() },
  };
}

export interface ConsumeByBindingOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorizationStoreIO;
  readonly request: BoundToolRequest;
  /** Host-verified binding; `identity.invocation_id` is the request's invocation. */
  readonly trusted: TrustedBinding;
  readonly now: Date;
}

/** The four identity fields a one-use record must share with the trusted process. */
const BINDING_IDENTITY_KEYS: ReadonlyArray<keyof NativeIdentity> = [
  "host",
  "session_id",
  "agent_id",
  "role",
];

function sameIdentity(left: NativeIdentity, right: NativeIdentity): boolean {
  return BINDING_IDENTITY_KEYS.every((key) => left[key] === right[key]);
}

/**
 * Admit one controlled tool call by its trusted binding rather than a caller
 * request id.
 *
 * The MCP layer holds the raw tool input the native PreToolUse adapter
 * digested but no correlation id, so the live issued, unlatched records of the
 * invocation named by the trusted session and the request's `invocation_ref`
 * are filtered down to those whose identity binds the trusted host, session,
 * agent id and role and whose tool, operation and input digest equal the
 * request. Exactly one must remain; it is then checked against its validity
 * window and latched exactly as {@link consumeToolAuthorization}. Each refusal
 * class is distinct so a replay (`AUTHORIZATION_CONSUMED`) is never reported as
 * a missing grant.
 */
export function consumeToolAuthorizationByBinding(
  options: ConsumeByBindingOptions,
): ConsumedAuthorization {
  const { location, io, request, trusted, now } = options;
  const digest = validateControlledRequest(request);
  if (
    !isText(request.invocationRef, CORRELATION_ID) ||
    trusted.identity.invocation_id !== request.invocationRef
  ) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      "Invocation reference must name the trusted invocation of this process.",
    );
  }
  const directory = authorizationsDirectory(location, trusted.identity);
  const records: { path: string; record: ToolAuthorizationRecord }[] = [];
  // Every JSON entry of the invocation partition is decoded strictly.
  for (const name of io.listEntries(directory)) {
    if (!name.endsWith(".json")) {
      continue;
    }
    const path = `${directory}/${name}`;
    const text = io.readText(path);
    if (text !== null) {
      records.push({ path, record: decodeToolAuthorization(text) });
    }
  }
  if (records.length === 0) {
    throw refuse(
      "AUTHORIZATION_MISSING",
      `No native authorization exists for invocation ${request.invocationRef}.`,
    );
  }
  // Staged filtering names the first binding that fails for this request.
  const identityBound = records.filter(({ record }) =>
    sameIdentity(record.identity, trusted.identity),
  );
  if (identityBound.length === 0) {
    throw refuse(
      "AUTHORIZATION_IDENTITY",
      "No authorization of this invocation is bound to the trusted identity.",
    );
  }
  const workspaceBound = identityBound.filter(({ record }) =>
    sameBinding({ ...record.workspace }, { ...trusted.workspace }),
  );
  if (workspaceBound.length === 0) {
    throw refuse(
      "AUTHORIZATION_WORKSPACE",
      "Authorization is bound to another workspace or profile.",
    );
  }
  const bound = workspaceBound.filter(
    ({ record }) =>
      record.tool === request.tool &&
      record.operation === request.operation &&
      record.input_sha256 === digest,
  );
  if (bound.length === 0) {
    throw refuse(
      "AUTHORIZATION_INPUT",
      "No authorization was issued for this tool, operation and input.",
    );
  }
  const live = bound.filter(
    ({ path, record }) =>
      record.state === "issued" &&
      io.readText(`${path}${CONSUMED_LATCH_SUFFIX}`) === null,
  );
  if (live.length === 0) {
    throw refuse(
      "AUTHORIZATION_CONSUMED",
      "The matching authorization was already consumed or revoked.",
    );
  }
  // A grant outside its validity window is not live: a re-issued grant after a
  // timeout must remain consumable beside the expired one it replaces.
  const instant = now.getTime();
  const current = live.filter(
    ({ record }) =>
      Date.parse(record.issued_at) <= instant &&
      instant < Date.parse(record.expires_at),
  );
  if (current.length === 0) {
    throw refuse(
      "AUTHORIZATION_EXPIRED",
      "Authorization is outside its validity window.",
    );
  }
  if (current.length > 1) {
    throw refuse(
      "AUTHORIZATION_AMBIGUOUS",
      `${String(current.length)} issued authorizations match this tool call.`,
    );
  }
  const { path, record } = current[0]!;
  consume(io, path, record, now);
  return {
    authorizationRef: record.authorization_ref,
    inputSha256: digest,
    path,
    record: { ...record, state: "consumed", consumed_at: now.toISOString() },
  };
}

/** Latch exclusively, then rewrite the record as consumed. */
function consume(
  io: AuthorizationStoreIO,
  path: string,
  record: ToolAuthorizationRecord,
  now: Date,
): void {
  const stamp = now.toISOString();
  try {
    io.createExclusive(
      `${path}${CONSUMED_LATCH_SUFFIX}`,
      canonicalJson({ consumed_at: stamp, request_id: record.request_id }),
    );
  } catch (error) {
    // Losing the latch race means another consumer admitted this request.
    if (
      error instanceof DiscoveryAuthorityError &&
      error.code === "AUTHORITY_LOCKED"
    ) {
      throw refuse(
        "AUTHORIZATION_CONSUMED",
        `Authorization for request ${record.request_id} was consumed concurrently.`,
      );
    }
    throw error;
  }
  const consumed: ToolAuthorizationRecord = {
    ...record,
    state: "consumed",
    consumed_at: stamp,
  };
  const staged = `${path}.staged`;
  io.remove(staged);
  io.createExclusive(staged, `${JSON.stringify(consumed, null, 2)}\n`);
  try {
    io.publish(staged, path, true);
  } catch (error) {
    io.remove(staged);
    throw error;
  }
}

/** `node:fs` subset for the Node adapter, extended with directory listing. */
export interface AuthorizationFileSystemModule extends AuthorityFileSystemModule {
  readdirSync(path: string): string[];
}

/** Build the production adapter over `node:fs` (or an injected equivalent). */
export function createNodeAuthorizationStoreIO(
  fs: AuthorizationFileSystemModule = nodeFs,
): AuthorizationStoreIO {
  return {
    ...createNodeAuthorityStoreIO(fs),
    listEntries(directory) {
      try {
        return [...fs.readdirSync(directory)].sort();
      } catch (error) {
        // An absent directory holds no grants; any other failure is reported.
        const code = (error as { code?: unknown }).code;
        if (code === "ENOENT") {
          return [];
        }
        const detail = error instanceof Error ? error.message : String(error);
        throw refuse(
          "AUTHORIZATION_IO",
          `Listing authorizations failed for ${directory}: ${detail}`,
        );
      }
    },
  };
}
