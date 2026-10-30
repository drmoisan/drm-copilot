/**
 * Consume one-use root grants written by the native PreToolUse adapters.
 *
 * When a hook payload carries no agent identity, the caller is the root of its
 * session. For `prepare_discovery_agent`, `run_discovery_doctor` and every
 * controlled discovery tool called by the root, the native gate writes one
 * short-lived `root-grant` record under `<workspace authority>/root-grants/`,
 * bound to the tool, the derived operation and the digest of the raw tool
 * input. The server selects the record by tool, operation and digest, latches
 * it exactly once and takes host, session and parent from it; nothing in the
 * tool input supplies those values. Zero matches, replays, expired grants and
 * ambiguous matches are refused with distinct codes.
 */

import type { AuthorityLocation } from "./discovery-authority-paths";
import { DiscoveryAuthorityError } from "./discovery-authority-record";
import type { AuthorizationStoreIO } from "./discovery-authorization";
import {
  canonicalJson,
  computeInputDigest,
  CONTROLLED_TOOLS,
  type ControlledTool,
  CORRELATION_ID,
  type DiscoveryAuthorizationCode,
  type DiscoveryAuthorizationError,
  HOSTS,
  IDENTIFIER,
  isReference,
  isText,
  isTimestamp,
  refuse,
  SHA256,
  TOOL_OPERATIONS,
} from "./discovery-authorization-record";

export const ROOT_GRANT_SCHEMA = "urn:drm-copilot:discovery:2.0.0:root-grant";
export const ROOT_GRANTS_PARTITION = "root-grants";
export const ROOT_GRANT_CONSUMED_SUFFIX = ".consumed";
/** Root-only tools a root grant may name beside the controlled tools. */
const ROOT_GRANT_FIXED_OPERATIONS: Readonly<Record<string, string>> = {
  prepare_discovery_agent: "prepare-agent",
  run_discovery_doctor: "doctor",
};
export const ROOT_GRANT_RECORD_KEYS: ReadonlyArray<string> = [
  "$schema",
  "artifact_kind",
  "expires_at",
  "grant_ref",
  "handler_sha256",
  "host",
  "id",
  "input_sha256",
  "issued_at",
  "operation",
  "parent_agent_id",
  "schema_version",
  "session_id",
  "state",
  "tool",
  "tool_use_id",
];

/** One `root-grant` record as written by the native adapter. */
export interface RootGrantRecord {
  readonly $schema: typeof ROOT_GRANT_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "root-grant";
  readonly id: string;
  readonly grant_ref: string;
  readonly host: string;
  readonly session_id: string;
  readonly parent_agent_id: string;
  readonly tool: string;
  readonly operation: string;
  readonly input_sha256: string;
  readonly tool_use_id: string | null;
  readonly handler_sha256: string;
  readonly issued_at: string;
  readonly expires_at: string;
  readonly state: "issued" | "consumed" | "revoked";
}

/** The trusted values a consumed root grant supplies to the server. */
export interface ConsumedRootGrant {
  readonly rootGrantRef: string;
  readonly host: string;
  readonly sessionId: string;
  readonly parentAgentId: string;
  readonly path: string;
  readonly record: RootGrantRecord;
}

export interface ConsumeRootGrantOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorizationStoreIO;
  readonly tool: string;
  readonly operation: string;
  /** The raw tool input exactly as the host hook digested it. */
  readonly inputs: unknown;
  readonly now: Date;
}

/** `<workspace authority>/root-grants`. */
export function rootGrantsDirectory(location: AuthorityLocation): string {
  return `${location.directory}/${ROOT_GRANTS_PARTITION}`;
}

/** Build a refusal whose message starts with its code, so an MCP summary names it. */
function refuseNamed(
  code: DiscoveryAuthorizationCode,
  message: string,
): DiscoveryAuthorizationError {
  return refuse(code, `${code}: ${message}`);
}

function recordInvalid(detail: string): DiscoveryAuthorizationError {
  return refuseNamed(
    "AUTHORIZATION_RECORD_INVALID",
    `Root grant record is malformed: ${detail}`,
  );
}

/** True when `operation` is one the root grant schema admits for `tool`. */
function isGrantableOperation(tool: string, operation: string): boolean {
  const fixed = ROOT_GRANT_FIXED_OPERATIONS[tool];
  if (fixed !== undefined) {
    return operation === fixed;
  }
  // The sentinel tool is observed, never granted, so it is excluded here.
  return (
    CONTROLLED_TOOLS.includes(tool) &&
    tool !== "discovery_capability_sentinel" &&
    TOOL_OPERATIONS[tool as ControlledTool].includes(operation)
  );
}

/** Parse one root grant strictly; a malformed record is an error, never skipped. */
export function decodeRootGrant(text: string): RootGrantRecord {
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
    Object.keys(value).sort().join(",") !== ROOT_GRANT_RECORD_KEYS.join(",")
  ) {
    throw recordInvalid("key set");
  }
  const tool = value["tool"] as string;
  const operation = value["operation"] as string;
  const state = value["state"] as string;
  const toolUseId = value["tool_use_id"];
  // Every scalar mirrors the root-grant schema; identity fields are host-shaped.
  if (
    value["$schema"] !== ROOT_GRANT_SCHEMA ||
    value["schema_version"] !== "2.0.0" ||
    value["artifact_kind"] !== "root-grant" ||
    !isText(value["id"], IDENTIFIER) ||
    !isReference(value["grant_ref"]) ||
    !HOSTS.includes(value["host"] as string) ||
    !isText(value["session_id"], CORRELATION_ID) ||
    !isText(value["parent_agent_id"], CORRELATION_ID) ||
    typeof tool !== "string" ||
    typeof operation !== "string" ||
    !isGrantableOperation(tool, operation) ||
    !isText(value["input_sha256"], SHA256, 64) ||
    !(toolUseId === null || isText(toolUseId, CORRELATION_ID)) ||
    !isText(value["handler_sha256"], SHA256, 64) ||
    !isTimestamp(value["issued_at"]) ||
    !isTimestamp(value["expires_at"]) ||
    !["issued", "consumed", "revoked"].includes(state)
  ) {
    throw recordInvalid("envelope fields");
  }
  return {
    $schema: ROOT_GRANT_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "root-grant",
    id: value["id"] as string,
    grant_ref: value["grant_ref"] as string,
    host: value["host"] as string,
    session_id: value["session_id"] as string,
    parent_agent_id: value["parent_agent_id"] as string,
    tool,
    operation,
    input_sha256: value["input_sha256"] as string,
    tool_use_id: toolUseId as string | null,
    handler_sha256: value["handler_sha256"] as string,
    issued_at: value["issued_at"] as string,
    expires_at: value["expires_at"] as string,
    state: state as "issued" | "consumed" | "revoked",
  };
}

/**
 * Admit one root call by consuming its unique root grant.
 *
 * Every `.json` entry of `root-grants/` is decoded strictly. The records whose
 * tool, operation and input digest equal the request are the candidates
 * (none: `DISCOVERY_HOST_BINDING_REQUIRED`); those still issued and unlatched
 * are live (none: `AUTHORIZATION_CONSUMED`); those inside their validity
 * window are current (none: `AUTHORIZATION_EXPIRED`; several:
 * `AUTHORIZATION_AMBIGUOUS`). The one current record is latched exclusively
 * and its host, session and parent are returned. A refusal before the latch
 * leaves every grant untouched.
 *
 * @throws DiscoveryAuthorizationError on every refusal.
 */
export function consumeRootGrant(
  options: ConsumeRootGrantOptions,
): ConsumedRootGrant {
  const { location, io, tool, operation, inputs, now } = options;
  if (!isGrantableOperation(tool, operation)) {
    throw refuseNamed(
      "AUTHORIZATION_REQUEST_INVALID",
      `${tool} ${operation} is not a root-grantable discovery call.`,
    );
  }
  const digest = computeInputDigest(tool, operation, inputs);
  const directory = rootGrantsDirectory(location);
  const candidates: { path: string; record: RootGrantRecord }[] = [];
  // Decode every grant; only records bound to this exact call compete.
  for (const name of io.listEntries(directory)) {
    if (!name.endsWith(".json")) {
      continue;
    }
    const path = `${directory}/${name}`;
    const text = io.readText(path);
    if (text === null) {
      continue;
    }
    const record = decodeRootGrant(text);
    if (
      record.tool === tool &&
      record.operation === operation &&
      record.input_sha256 === digest
    ) {
      candidates.push({ path, record });
    }
  }
  if (candidates.length === 0) {
    throw refuseNamed(
      "DISCOVERY_HOST_BINDING_REQUIRED",
      `No root grant was issued for this ${tool} call; the native host gate must observe the root call first.`,
    );
  }
  const live = candidates.filter(
    ({ path, record }) =>
      record.state === "issued" &&
      io.readText(`${path}${ROOT_GRANT_CONSUMED_SUFFIX}`) === null,
  );
  if (live.length === 0) {
    throw refuseNamed(
      "AUTHORIZATION_CONSUMED",
      `The root grant for this ${tool} call was already consumed or revoked.`,
    );
  }
  const instant = now.getTime();
  const current = live.filter(
    ({ record }) =>
      Date.parse(record.issued_at) <= instant &&
      instant < Date.parse(record.expires_at),
  );
  if (current.length === 0) {
    throw refuseNamed(
      "AUTHORIZATION_EXPIRED",
      "The root grant is outside its validity window.",
    );
  }
  if (current.length > 1) {
    throw refuseNamed(
      "AUTHORIZATION_AMBIGUOUS",
      `${String(current.length)} issued root grants match this ${tool} call.`,
    );
  }
  const { path, record } = current[0]!;
  try {
    io.createExclusive(
      `${path}${ROOT_GRANT_CONSUMED_SUFFIX}`,
      canonicalJson({
        consumed_at: now.toISOString(),
        grant_ref: record.grant_ref,
      }),
    );
  } catch (error) {
    // Losing the latch race means another consumer admitted this root call.
    if (
      error instanceof DiscoveryAuthorityError &&
      error.code === "AUTHORITY_LOCKED"
    ) {
      throw refuseNamed(
        "AUTHORIZATION_CONSUMED",
        `Root grant ${record.grant_ref} was consumed concurrently.`,
      );
    }
    throw error;
  }
  return {
    rootGrantRef: record.grant_ref,
    host: record.host,
    sessionId: record.session_id,
    parentAgentId: record.parent_agent_id,
    path,
    record,
  };
}
