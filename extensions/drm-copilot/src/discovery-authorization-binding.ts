/**
 * Consume one-use native tool authorizations by invocation reference.
 *
 * The MCP server holds no identity of its own. A specialist's controlled call
 * names its started invocation through `invocation_ref`; this module resolves
 * that invocation's partition across every session, takes the host, session,
 * agent and role the started record binds, and consumes the one issued
 * authorization whose identity, workspace, tool, operation and input digest
 * match. The record codec, the request validation and the exclusive latch live
 * in `discovery-authorization-record.ts` and `discovery-authorization.ts`.
 */

import type { ProtectedWorkspaceBinding } from "./discovery-authority";
import {
  type AuthorityLocation,
  INVOCATION_PARTITION,
  partitionName,
  SESSION_PARTITION,
} from "./discovery-authority-paths";
import {
  AUTHORIZATIONS_PARTITION,
  type AuthorizationStoreIO,
  type BoundToolRequest,
  consume,
  CONSUMED_LATCH_SUFFIX,
  type ConsumedAuthorization,
  sameBinding,
  validateControlledRequest,
} from "./discovery-authorization";
import {
  CORRELATION_ID,
  decodeToolAuthorization,
  isText,
  type NativeIdentity,
  refuse,
  type ToolAuthorizationRecord,
} from "./discovery-authorization-record";
import {
  decodeDiscoveryInvocation,
  DiscoveryInvocationError,
  INVOCATION_RECORD_FILE,
} from "./discovery-invocation-record";

export interface ConsumeByBindingOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorizationStoreIO;
  readonly request: BoundToolRequest;
  /** Protected workspace binding of the activation; the record must match it. */
  readonly workspace: ProtectedWorkspaceBinding;
  readonly now: Date;
}

/**
 * Locate the one invocation partition named by `invocationRef` across every
 * session and return the identity its started record binds.
 *
 * The server knows no session, so `sessions/*` is scanned for the partition
 * `sha256(invocationRef)`; zero matches is `AUTHORIZATION_MISSING` and several
 * is `AUTHORIZATION_AMBIGUOUS`. The record must decode against this workspace,
 * be `started` and carry the agent the start bound, otherwise no identity exists
 * to admit the call (`AUTHORIZATION_IDENTITY`).
 */
function resolveInvocationIdentity(
  location: AuthorityLocation,
  io: AuthorizationStoreIO,
  invocationRef: string,
): { readonly directory: string; readonly identity: NativeIdentity } {
  const sessions = `${location.directory}/${SESSION_PARTITION}`;
  const partition = partitionName(invocationRef);
  const found: { directory: string; text: string }[] = [];
  // Every session partition is probed for the invocation partition by name.
  for (const session of io.listEntries(sessions)) {
    const directory = `${sessions}/${session}/${INVOCATION_PARTITION}/${partition}`;
    const text = io.readText(`${directory}/${INVOCATION_RECORD_FILE}`);
    if (text !== null) {
      found.push({ directory, text });
    }
  }
  if (found.length === 0) {
    throw refuse(
      "AUTHORIZATION_MISSING",
      `No protected invocation ${invocationRef} exists in this workspace.`,
    );
  }
  if (found.length > 1) {
    throw refuse(
      "AUTHORIZATION_AMBIGUOUS",
      `Invocation ${invocationRef} exists in ${String(found.length)} sessions.`,
    );
  }
  const { directory, text } = found[0]!;
  let record;
  try {
    record = decodeDiscoveryInvocation(text, {
      workspaceSha256: location.workspaceSha256,
    });
  } catch (error) {
    if (error instanceof DiscoveryInvocationError) {
      throw refuse("AUTHORIZATION_RECORD_INVALID", error.message);
    }
    throw error;
  }
  // Only a started invocation has an agent to attribute the call to.
  if (record.state !== "started" || record.agent_id === null) {
    throw refuse(
      "AUTHORIZATION_IDENTITY",
      `Invocation ${invocationRef} is ${record.state} and binds no started agent.`,
    );
  }
  return {
    directory,
    identity: {
      host: record.host,
      session_id: record.session_id,
      agent_id: record.agent_id,
      role: record.role,
      invocation_id: record.invocation_id,
    },
  };
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
 * Admit one controlled tool call by its invocation reference rather than a
 * caller request id or a process identity.
 *
 * The MCP layer holds the raw tool input the native PreToolUse adapter
 * digested but no correlation id and no identity of its own. The request's
 * `invocation_ref` selects the invocation partition (see
 * {@link resolveInvocationIdentity}); the live issued, unlatched records of
 * that invocation are filtered down to those whose identity equals the started
 * invocation's host, session, agent id and role, whose workspace equals the
 * activation and whose tool, operation and input digest equal the request.
 * Exactly one must remain; it is then checked against its validity window and
 * latched exactly as {@link consumeToolAuthorization}, and its identity is
 * returned for the runtime call. Each refusal class is distinct so a replay
 * (`AUTHORIZATION_CONSUMED`) is never reported as a missing grant.
 */
export function consumeToolAuthorizationByBinding(
  options: ConsumeByBindingOptions,
): ConsumedAuthorization {
  const { location, io, request, workspace, now } = options;
  const digest = validateControlledRequest(request);
  if (!isText(request.invocationRef, CORRELATION_ID)) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      "Invocation reference must be a correlation identifier.",
    );
  }
  const trusted = resolveInvocationIdentity(
    location,
    io,
    request.invocationRef,
  );
  const directory = `${trusted.directory}/${AUTHORIZATIONS_PARTITION}`;
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
    sameBinding({ ...record.workspace }, { ...workspace }),
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
    identity: trusted.identity,
  };
}
