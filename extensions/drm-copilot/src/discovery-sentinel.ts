/**
 * Consume the one-use sentinel grant the native PreToolUse gate records for
 * the capability sentinel agent.
 *
 * While the `discovery-capability-sentinel` agent runs, the gate records each
 * payload it attributed to that agent as a `host-observation` under
 * `sessions/<sha256(session)>/observations/`. The observation of the sentinel
 * MCP tool call also carries the one-use grant fields (tool, input digest,
 * expiry, state). This module finds the single issued grant whose digest
 * equals the call, latches it exactly once and reports what the host
 * observed: whether the payload carried an agent identity and which agent
 * type. Without a matching grant the result is `observed: false`; the sentinel
 * tool never throws, because its only purpose is to produce evidence the
 * capability probe reads from the same records.
 */

import {
  type AuthorityLocation,
  SESSION_PARTITION,
} from "./discovery-authority-paths";
import { DiscoveryAuthorityError } from "./discovery-authority-record";
import type { AuthorizationStoreIO } from "./discovery-authorization";
import {
  canonicalJson,
  computeInputDigest,
  CORRELATION_ID,
  type DiscoveryAuthorizationError,
  HOSTS,
  IDENTIFIER,
  isReference,
  isText,
  isTimestamp,
  refuse,
  SHA256,
} from "./discovery-authorization-record";

export const HOST_OBSERVATION_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:host-observation";
export const OBSERVATIONS_PARTITION = "observations";
export const SENTINEL_TOOL = "discovery_capability_sentinel";
export const SENTINEL_OPERATION = "sentinel";
export const SENTINEL_CONSUMED_SUFFIX = ".consumed";
const OBSERVATION_BASE_KEYS: ReadonlyArray<string> = [
  "$schema",
  "agent_id",
  "agent_type",
  "artifact_kind",
  "code",
  "decision",
  "handler_sha256",
  "host",
  "id",
  "observation_ref",
  "observed_at",
  "parent_agent_id",
  "schema_version",
  "session_id",
  "tool_name",
  "tool_use_id_present",
];
const GRANT_KEYS: ReadonlyArray<string> = [
  "expires_at",
  "input_sha256",
  "state",
  "tool",
];
const CODE = /^[A-Z][A-Z0-9_]*$/u;

/** One `host-observation` record; the grant fields are present together or absent. */
export interface HostObservationRecord {
  readonly $schema: typeof HOST_OBSERVATION_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "host-observation";
  readonly id: string;
  readonly observation_ref: string;
  readonly host: string;
  readonly session_id: string;
  readonly agent_id: string | null;
  readonly agent_type: string | null;
  readonly parent_agent_id: string;
  readonly tool_name: string;
  readonly tool_use_id_present: boolean;
  readonly decision: "allow" | "deny";
  readonly code: string;
  readonly handler_sha256: string;
  readonly observed_at: string;
  readonly grant: {
    readonly tool: typeof SENTINEL_TOOL;
    readonly input_sha256: string;
    readonly expires_at: string;
    readonly state: "issued" | "consumed" | "revoked";
  } | null;
}

/** What the sentinel tool reports: evidence only, never authority. */
export interface SentinelObservation {
  readonly observed: boolean;
  readonly observationRef: string | null;
  readonly agentIdPresent: boolean | null;
  readonly agentType: string | null;
}

export interface ConsumeSentinelGrantOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorizationStoreIO;
  /** The raw tool input exactly as the host hook digested it. */
  readonly inputs: unknown;
  readonly now: Date;
}

function recordInvalid(detail: string): DiscoveryAuthorizationError {
  return refuse(
    "AUTHORIZATION_RECORD_INVALID",
    `Host observation record is malformed: ${detail}`,
  );
}

/** Parse one host observation strictly; a malformed record is an error. */
export function decodeHostObservation(text: string): HostObservationRecord {
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
  const keys = Object.keys(value).sort().join(",");
  const granted =
    keys === [...OBSERVATION_BASE_KEYS, ...GRANT_KEYS].sort().join(",");
  if (!granted && keys !== OBSERVATION_BASE_KEYS.join(",")) {
    throw recordInvalid("key set");
  }
  const agentId = value["agent_id"];
  const agentType = value["agent_type"];
  const decision = value["decision"] as string;
  // The base fields mirror the host-observation schema; identity fields may be null.
  if (
    value["$schema"] !== HOST_OBSERVATION_SCHEMA ||
    value["schema_version"] !== "2.0.0" ||
    value["artifact_kind"] !== "host-observation" ||
    !isText(value["id"], IDENTIFIER) ||
    !isReference(value["observation_ref"]) ||
    !HOSTS.includes(value["host"] as string) ||
    !isText(value["session_id"], CORRELATION_ID) ||
    !(agentId === null || isText(agentId, CORRELATION_ID)) ||
    !(agentType === null || isText(agentType, CORRELATION_ID)) ||
    !isText(value["parent_agent_id"], CORRELATION_ID) ||
    !isText(value["tool_name"], /\S/u) ||
    typeof value["tool_use_id_present"] !== "boolean" ||
    !["allow", "deny"].includes(decision) ||
    !isText(value["code"], CODE) ||
    !isText(value["handler_sha256"], SHA256, 64) ||
    !isTimestamp(value["observed_at"])
  ) {
    throw recordInvalid("envelope fields");
  }
  let grant: HostObservationRecord["grant"] = null;
  if (granted) {
    const state = value["state"] as string;
    // The grant quartet is the sentinel tool's one-use consumable.
    if (
      value["tool"] !== SENTINEL_TOOL ||
      !isText(value["input_sha256"], SHA256, 64) ||
      !isTimestamp(value["expires_at"]) ||
      !["issued", "consumed", "revoked"].includes(state)
    ) {
      throw recordInvalid("sentinel grant fields");
    }
    grant = {
      tool: SENTINEL_TOOL,
      input_sha256: value["input_sha256"] as string,
      expires_at: value["expires_at"] as string,
      state: state as "issued" | "consumed" | "revoked",
    };
  }
  return {
    $schema: HOST_OBSERVATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "host-observation",
    id: value["id"] as string,
    observation_ref: value["observation_ref"] as string,
    host: value["host"] as string,
    session_id: value["session_id"] as string,
    agent_id: agentId as string | null,
    agent_type: agentType as string | null,
    parent_agent_id: value["parent_agent_id"] as string,
    tool_name: value["tool_name"] as string,
    tool_use_id_present: value["tool_use_id_present"] as boolean,
    decision: decision as "allow" | "deny",
    code: value["code"] as string,
    handler_sha256: value["handler_sha256"] as string,
    observed_at: value["observed_at"] as string,
    grant,
  };
}

/** Every decodable observation under the observations partition of any session. */
function listObservations(
  location: AuthorityLocation,
  io: AuthorizationStoreIO,
): { path: string; record: HostObservationRecord }[] {
  const sessions = `${location.directory}/${SESSION_PARTITION}`;
  const found: { path: string; record: HostObservationRecord }[] = [];
  // Every session partition may hold observations; undecodable entries are
  // not evidence and are skipped, because the sentinel reports, never refuses.
  for (const session of io.listEntries(sessions)) {
    const directory = `${sessions}/${session}/${OBSERVATIONS_PARTITION}`;
    for (const name of io.listEntries(directory)) {
      if (!name.endsWith(".json")) {
        continue;
      }
      const path = `${directory}/${name}`;
      const text = io.readText(path);
      if (text === null) {
        continue;
      }
      try {
        found.push({ path, record: decodeHostObservation(text) });
      } catch (error) {
        if (
          error instanceof Error &&
          error.name === "DiscoveryAuthorizationError"
        ) {
          continue;
        }
        throw error;
      }
    }
  }
  return found;
}

const NOT_OBSERVED: SentinelObservation = {
  observed: false,
  observationRef: null,
  agentIdPresent: null,
  agentType: null,
};

/**
 * Consume the one issued sentinel grant whose digest equals this call.
 *
 * The grant must be issued, unlatched and inside its validity window; exactly
 * one may match. Any other outcome (no observation, a replay, an expired or
 * duplicated grant, a latch lost to a concurrent consumer) yields
 * `observed: false` without throwing. On success the record is latched and the
 * observation reports whether the host payload carried an agent identity.
 */
export function consumeSentinelGrant(
  options: ConsumeSentinelGrantOptions,
): SentinelObservation {
  const { location, io, inputs, now } = options;
  const digest = computeInputDigest(SENTINEL_TOOL, SENTINEL_OPERATION, inputs);
  const instant = now.getTime();
  const matching = listObservations(location, io).filter(
    ({ path, record }) =>
      record.grant !== null &&
      record.grant.input_sha256 === digest &&
      record.grant.state === "issued" &&
      io.readText(`${path}${SENTINEL_CONSUMED_SUFFIX}`) === null &&
      Date.parse(record.observed_at) <= instant &&
      instant < Date.parse(record.grant.expires_at),
  );
  if (matching.length !== 1) {
    return NOT_OBSERVED;
  }
  const { path, record } = matching[0]!;
  try {
    io.createExclusive(
      `${path}${SENTINEL_CONSUMED_SUFFIX}`,
      canonicalJson({
        consumed_at: now.toISOString(),
        observation_ref: record.observation_ref,
      }),
    );
  } catch (error) {
    // A lost latch race is a replay: the first consumer holds the evidence.
    if (
      error instanceof DiscoveryAuthorityError &&
      error.code === "AUTHORITY_LOCKED"
    ) {
      return NOT_OBSERVED;
    }
    throw error;
  }
  return {
    observed: true,
    observationRef: record.observation_ref,
    agentIdPresent: record.agent_id !== null,
    agentType: record.agent_type,
  };
}
