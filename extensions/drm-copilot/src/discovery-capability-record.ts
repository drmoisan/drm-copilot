/**
 * `capability-attestation` record contract for discovery hosts.
 *
 * Declares the attestation shape, its control and handler vocabularies and the
 * strict decoder. A malformed attestation is an error, never a partial value,
 * and a caller payload that asserts capability is recognised so it can be
 * refused. Assessment and composition live in `discovery-capabilities`.
 */

import type { ProtectedWorkspaceBinding } from "./discovery-authority";
import type {
  DiscoveryFinding,
  DiscoveryRuntimeIdentity,
} from "./discovery-service-types";

export const CAPABILITY_ATTESTATION_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:capability-attestation";
export const CAPABILITY_ATTESTATION_FILE = "capability-attestation.json";
export const DISCOVERY_ENFORCEMENT_UNAVAILABLE =
  "DISCOVERY_ENFORCEMENT_UNAVAILABLE";
export const DISCOVERY_ENFORCEMENT_VERIFIED = "DISCOVERY_ENFORCEMENT_VERIFIED";
export const CAPABILITY_CONTROLS = [
  "workspace_trusted",
  "hooks_enabled",
  "trusted_attribution",
  "start_event",
  "tool_event",
  "stop_event",
  "forbidden_tools_denied",
] as const;
export const HANDLER_EVENTS = ["start", "tool", "stop"] as const;
export const PROBE_RESULTS = ["denied", "allowed", "unavailable"] as const;
/** Keys a caller might use to assert capability; none is ever accepted. */
export const CALLER_CAPABILITY_KEYS: ReadonlyArray<string> = [
  "capability",
  "capability_attestation",
  "attestation_ref",
  "controls",
  "probe",
  "hooks_enabled",
];
export const ATTESTATION_KEYS: ReadonlyArray<string> = [
  "$schema",
  "artifact_kind",
  "attestation_ref",
  "configuration_sha256",
  "controls",
  "expires_at",
  "findings",
  "handlers",
  "host",
  "id",
  "observed_at",
  "probe",
  "runtime",
  "schema_version",
  "session_id",
  "status",
  "workspace",
];
const HOSTS: ReadonlyArray<string> = ["claude-code", "codex", "github-copilot"];
const SHA256 = /^[0-9a-f]{64}$/u;
const OPAQUE_REFERENCE = /^[A-Za-z0-9][A-Za-z0-9._-]{15,255}$/u;

export type CapabilityControl = (typeof CAPABILITY_CONTROLS)[number];
export type HandlerEvent = (typeof HANDLER_EVENTS)[number];
export type ProbeResult = (typeof PROBE_RESULTS)[number];

export interface CapabilityHandler {
  readonly event: HandlerEvent;
  readonly path: string;
  readonly sha256: string;
}

export interface CapabilityProbe {
  readonly sentinel_id: string;
  readonly result: ProbeResult;
  readonly evidence_ref: string | null;
}

/** Decoded `capability-attestation`. */
export interface CapabilityAttestation {
  readonly $schema: typeof CAPABILITY_ATTESTATION_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "capability-attestation";
  readonly id: string;
  readonly attestation_ref: string;
  readonly workspace: ProtectedWorkspaceBinding;
  readonly host: string;
  readonly session_id: string;
  readonly runtime: DiscoveryRuntimeIdentity;
  readonly configuration_sha256: string;
  readonly handlers: ReadonlyArray<CapabilityHandler>;
  readonly controls: Readonly<Record<CapabilityControl, boolean>>;
  readonly probe: CapabilityProbe;
  readonly status: "supported" | "unsupported";
  readonly findings: ReadonlyArray<DiscoveryFinding>;
  readonly observed_at: string;
  readonly expires_at: string;
}

export type CapabilityDeficiencyKind =
  | "attestation-missing"
  | "attestation-malformed"
  | "harness-unsupported"
  | "hooks-disabled"
  | "trust-missing"
  | "event-unsupported"
  | "probe-not-denied"
  | "probe-stale"
  | "workspace-mismatch"
  | "host-mismatch"
  | "session-mismatch"
  | "runtime-mismatch"
  | "configuration-hash-mismatch"
  | "hook-hash-mismatch";

export interface CapabilityDeficiency {
  readonly kind: CapabilityDeficiencyKind;
  readonly detail: string;
}

/** Host-pinned hashes the attestation must reproduce exactly. */
export interface CapabilityPins {
  readonly configuration_sha256?: string;
  readonly handlers?: ReadonlyArray<CapabilityHandler>;
}

export interface CapabilityExpectation {
  readonly workspace: ProtectedWorkspaceBinding;
  readonly host: string;
  readonly sessionId: string;
  readonly runtime: DiscoveryRuntimeIdentity;
  readonly pins?: CapabilityPins;
}

export interface CapabilityAssessment {
  readonly status: "supported" | "unavailable";
  readonly deficiencies: ReadonlyArray<CapabilityDeficiency>;
  readonly attestation: CapabilityAttestation | null;
}

export class DiscoveryCapabilityError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "DiscoveryCapabilityError";
  }
}

function malformed(detail: string): DiscoveryCapabilityError {
  return new DiscoveryCapabilityError(
    `Capability attestation is malformed: ${detail}`,
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isTimestamp(value: unknown): value is string {
  return typeof value === "string" && !Number.isNaN(Date.parse(value));
}

function decodeHandlers(value: unknown): CapabilityHandler[] {
  if (!Array.isArray(value)) {
    throw malformed("handlers");
  }
  // Each handler names one hook event, its path and the hash the host observed.
  return value.map((entry: unknown) => {
    const row = entry as {
      event?: unknown;
      path?: unknown;
      sha256?: unknown;
    } | null;
    if (
      row === null ||
      typeof row !== "object" ||
      !HANDLER_EVENTS.includes(row.event as HandlerEvent) ||
      typeof row.path !== "string" ||
      typeof row.sha256 !== "string" ||
      !SHA256.test(row.sha256)
    ) {
      throw malformed("handler entry");
    }
    return {
      event: row.event as HandlerEvent,
      path: row.path,
      sha256: row.sha256,
    };
  });
}

function decodeControls(value: unknown): Record<CapabilityControl, boolean> {
  if (
    !isRecord(value) ||
    Object.keys(value).sort().join(",") !==
      [...CAPABILITY_CONTROLS].sort().join(",")
  ) {
    throw malformed("controls");
  }
  const controls = {} as Record<CapabilityControl, boolean>;
  // Every control is an explicit boolean; absence is never read as support.
  for (const name of CAPABILITY_CONTROLS) {
    const flag = value[name];
    if (typeof flag !== "boolean") {
      throw malformed(`control ${name}`);
    }
    controls[name] = flag;
  }
  return controls;
}

function decodeProbe(value: unknown): CapabilityProbe {
  const probe = value as {
    sentinel_id?: unknown;
    result?: unknown;
    evidence_ref?: unknown;
  } | null;
  if (
    probe === null ||
    typeof probe !== "object" ||
    typeof probe.sentinel_id !== "string" ||
    !PROBE_RESULTS.includes(probe.result as ProbeResult) ||
    (probe.evidence_ref !== null && typeof probe.evidence_ref !== "string")
  ) {
    throw malformed("probe");
  }
  return {
    sentinel_id: probe.sentinel_id,
    result: probe.result as ProbeResult,
    evidence_ref: probe.evidence_ref as string | null,
  };
}

/** Parse an attestation strictly; a malformed document is an error. */
export function decodeCapabilityAttestation(
  text: string,
): CapabilityAttestation {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw malformed("not JSON");
  }
  if (!isRecord(parsed)) {
    throw malformed("not an object");
  }
  if (Object.keys(parsed).sort().join(",") !== ATTESTATION_KEYS.join(",")) {
    throw malformed("key set");
  }
  const {
    $schema: schema,
    schema_version: schemaVersion,
    artifact_kind: artifactKind,
    id,
    attestation_ref: attestationRef,
    workspace,
    host,
    session_id: sessionId,
    runtime,
    configuration_sha256: configurationSha256,
    handlers,
    controls,
    probe,
    status,
    findings,
    observed_at: observedAt,
    expires_at: expiresAt,
  } = parsed;
  if (
    schema !== CAPABILITY_ATTESTATION_SCHEMA ||
    schemaVersion !== "2.0.0" ||
    artifactKind !== "capability-attestation" ||
    typeof id !== "string" ||
    typeof attestationRef !== "string" ||
    !OPAQUE_REFERENCE.test(attestationRef) ||
    !isRecord(workspace) ||
    !HOSTS.includes(host as string) ||
    typeof sessionId !== "string" ||
    !isRecord(runtime) ||
    typeof configurationSha256 !== "string" ||
    !SHA256.test(configurationSha256) ||
    (status !== "supported" && status !== "unsupported") ||
    !Array.isArray(findings) ||
    !isTimestamp(observedAt) ||
    !isTimestamp(expiresAt)
  ) {
    throw malformed("envelope fields");
  }
  return {
    $schema: CAPABILITY_ATTESTATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "capability-attestation",
    id,
    attestation_ref: attestationRef,
    workspace: workspace as unknown as ProtectedWorkspaceBinding,
    host: host as string,
    session_id: sessionId,
    runtime: runtime as unknown as DiscoveryRuntimeIdentity,
    configuration_sha256: configurationSha256,
    handlers: decodeHandlers(handlers),
    controls: decodeControls(controls),
    probe: decodeProbe(probe),
    status,
    findings: findings as DiscoveryFinding[],
    observed_at: observedAt,
    expires_at: expiresAt,
  };
}

/** True when a caller payload tries to assert capability itself. */
export function isCallerCapabilityClaim(payload: unknown): boolean {
  return (
    isRecord(payload) &&
    CALLER_CAPABILITY_KEYS.some((key) =>
      Object.prototype.hasOwnProperty.call(payload, key),
    )
  );
}
