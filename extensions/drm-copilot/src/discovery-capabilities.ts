/**
 * Host capability diagnostics and probe orchestration for discovery agents.
 *
 * A `capability-attestation` is written by a native host adapter after it has
 * observed its own hook handlers (start, tool, stop), trusted attribution and
 * a harmless denial sentinel. This module assesses the protected attestation
 * against the host-verified expectation (workspace, host, session, runtime
 * identity and optional configuration/hook hash pins), composes a new
 * attestation from trusted observations, and projects the assessment into the
 * `doctor` result so a user sees exactly which control is missing. Only the
 * protected copy counts: a capability asserted by the caller or by repository
 * JSON is never accepted. The module performs no writes.
 */

import type {
  AuthorityStoreIO,
  ProtectedEnvelope,
  ProtectedWorkspaceBinding,
} from "./discovery-authority";
import {
  type AuthorityLocation,
  sessionDirectory,
} from "./discovery-authority-paths";
import { canonicalJson } from "./discovery-authorization-record";
import {
  CAPABILITY_ATTESTATION_FILE,
  CAPABILITY_ATTESTATION_SCHEMA,
  CAPABILITY_CONTROLS,
  type CapabilityAttestation,
  type CapabilityControl,
  type CapabilityHandler,
  type CapabilityProbe,
  decodeCapabilityAttestation,
  DISCOVERY_ENFORCEMENT_UNAVAILABLE,
  DISCOVERY_ENFORCEMENT_VERIFIED,
  HANDLER_EVENTS,
} from "./discovery-capability-record";
import type {
  DiscoveryFinding,
  DiscoveryRuntimeIdentity,
  DiscoveryServiceResult,
} from "./discovery-service-types";

export {
  ATTESTATION_KEYS,
  CALLER_CAPABILITY_KEYS,
  CAPABILITY_ATTESTATION_FILE,
  CAPABILITY_ATTESTATION_SCHEMA,
  CAPABILITY_CONTROLS,
  decodeCapabilityAttestation,
  DISCOVERY_ENFORCEMENT_UNAVAILABLE,
  DISCOVERY_ENFORCEMENT_VERIFIED,
  DiscoveryCapabilityError,
  HANDLER_EVENTS,
  isCallerCapabilityClaim,
  PROBE_RESULTS,
} from "./discovery-capability-record";
export type {
  CapabilityAttestation,
  CapabilityControl,
  CapabilityHandler,
  CapabilityProbe,
  HandlerEvent,
  ProbeResult,
} from "./discovery-capability-record";

export type CapabilityDeficiencyKind =
  | "attestation-missing"
  | "attestation-malformed"
  | "context-missing"
  | "activation-unavailable"
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

function unavailable(
  kind: CapabilityDeficiencyKind,
  detail: string,
): CapabilityAssessment {
  return {
    status: "unavailable",
    deficiencies: [{ kind, detail }],
    attestation: null,
  };
}

/**
 * Assess a decoded attestation against the host-verified expectation.
 *
 * Deficiencies accumulate in contract order: harness support, hooks and trust,
 * event coverage, the sentinel probe, identity bindings, pinned hashes and
 * freshness. An empty list means the host is supported for this session now.
 */
export function assessCapability(
  attestation: CapabilityAttestation | null,
  expected: CapabilityExpectation,
  now: Date,
): CapabilityAssessment {
  if (attestation === null) {
    return unavailable(
      "attestation-missing",
      "no protected capability attestation exists for this session",
    );
  }
  const deficiencies: CapabilityDeficiency[] = [];
  const add = (kind: CapabilityDeficiencyKind, detail: string): void => {
    deficiencies.push({ kind, detail });
  };
  if (attestation.status !== "supported") {
    add("harness-unsupported", "the host reported its harness as unsupported");
  }
  if (!attestation.controls.hooks_enabled) {
    add("hooks-disabled", "native hooks are disabled");
  }
  if (
    !attestation.controls.workspace_trusted ||
    !attestation.controls.trusted_attribution
  ) {
    add(
      "trust-missing",
      "the workspace is not trusted or attribution is untrusted",
    );
  }
  // Every lifecycle event needs both a reported control and an observed handler.
  for (const event of HANDLER_EVENTS) {
    const control = attestation.controls[`${event}_event`];
    const handler = attestation.handlers.find((entry) => entry.event === event);
    if (!control || handler === undefined) {
      add(
        "event-unsupported",
        `${event} hook is not supported or not observed`,
      );
    }
  }
  if (
    !attestation.controls.forbidden_tools_denied ||
    attestation.probe.result !== "denied" ||
    attestation.probe.evidence_ref === null
  ) {
    add(
      "probe-not-denied",
      `sentinel ${attestation.probe.sentinel_id} was ${attestation.probe.result} without protected denial evidence`,
    );
  }
  if (
    canonicalJson(attestation.workspace) !== canonicalJson(expected.workspace)
  ) {
    add(
      "workspace-mismatch",
      "attestation is bound to another workspace or profile",
    );
  }
  if (attestation.host !== expected.host) {
    add(
      "host-mismatch",
      `attestation host ${attestation.host} differs from ${expected.host}`,
    );
  }
  if (attestation.session_id !== expected.sessionId) {
    add("session-mismatch", "attestation belongs to another session");
  }
  if (canonicalJson(attestation.runtime) !== canonicalJson(expected.runtime)) {
    add(
      "runtime-mismatch",
      "attestation runtime identity differs from the installed runtime",
    );
  }
  const pins = expected.pins;
  if (
    pins?.configuration_sha256 !== undefined &&
    pins.configuration_sha256 !== attestation.configuration_sha256
  ) {
    add(
      "configuration-hash-mismatch",
      "host configuration hash differs from the pinned value",
    );
  }
  // Pinned handlers must match by event, path and hash; extra observed handlers are fine.
  for (const pinned of pins?.handlers ?? []) {
    const observed = attestation.handlers.find(
      (entry) => entry.event === pinned.event,
    );
    if (
      observed === undefined ||
      observed.path !== pinned.path ||
      observed.sha256 !== pinned.sha256
    ) {
      add(
        "hook-hash-mismatch",
        `${pinned.event} hook differs from the pinned handler`,
      );
    }
  }
  const instant = now.getTime();
  if (!(
    Date.parse(attestation.observed_at) <= instant &&
    instant < Date.parse(attestation.expires_at)
  )) {
    add("probe-stale", "attestation is outside its validity window");
  }
  return {
    status: deficiencies.length === 0 ? "supported" : "unavailable",
    deficiencies,
    attestation,
  };
}

/** Read the protected attestation for `sessionId` and assess it. */
export function assessProtectedCapability(options: {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly sessionId: string;
  readonly expected: CapabilityExpectation;
  readonly now: Date;
}): CapabilityAssessment {
  const path = `${sessionDirectory(options.location, options.sessionId)}/${CAPABILITY_ATTESTATION_FILE}`;
  const text = options.io.readText(path);
  if (text === null) {
    return assessCapability(null, options.expected, options.now);
  }
  let attestation: CapabilityAttestation;
  try {
    attestation = decodeCapabilityAttestation(text);
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    return unavailable("attestation-malformed", detail);
  }
  return assessCapability(attestation, options.expected, options.now);
}

/**
 * Assess the session's capability for `doctor` from the trusted provider state.
 *
 * Without a trusted host and session, or without a readable protected
 * activation, there is nothing an attestation could be bound to, so the result
 * is unavailable with an explanatory deficiency instead of an error; doctor is
 * diagnostic and must still answer.
 */
export function assessSessionCapability(options: {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly activation: { envelope(): ProtectedEnvelope };
  readonly context: { readonly host: string; readonly sessionId: string };
  readonly runtime: DiscoveryRuntimeIdentity | null;
  readonly pins?: CapabilityPins;
  readonly now: Date;
}): CapabilityAssessment {
  if (options.context.host === "" || options.context.sessionId === "") {
    return unavailable(
      "context-missing",
      "no trusted session context was supplied by the host",
    );
  }
  if (options.runtime === null) {
    return unavailable(
      "runtime-mismatch",
      "the installed runtime did not report its identity",
    );
  }
  let envelope: ProtectedEnvelope;
  try {
    envelope = options.activation.envelope();
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    return unavailable(
      "activation-unavailable",
      `protected activation could not be read: ${detail}`,
    );
  }
  return assessProtectedCapability({
    location: options.location,
    io: options.io,
    sessionId: options.context.sessionId,
    expected: {
      workspace: envelope.workspace,
      host: options.context.host,
      sessionId: options.context.sessionId,
      runtime: options.runtime,
      ...(options.pins === undefined ? {} : { pins: options.pins }),
    },
    now: options.now,
  });
}

/** Harmless forbidden-operation sentinel a host adapter attempts and must see denied. */
export function capabilityProbeSpec(sentinelId: string): {
  readonly sentinel_id: string;
  readonly forbidden_tool: "shell";
  readonly request: string;
} {
  return {
    sentinel_id: sentinelId,
    forbidden_tool: "shell",
    request: `drm-copilot discovery capability probe ${sentinelId}: this command must be denied by the native hook and never executed`,
  };
}

/** Trusted observations a host adapter supplies to compose an attestation. */
export interface CapabilityObservation {
  readonly id: string;
  readonly attestationRef: string;
  readonly workspace: ProtectedWorkspaceBinding;
  readonly host: string;
  readonly sessionId: string;
  readonly runtime: DiscoveryRuntimeIdentity;
  readonly configurationSha256: string;
  readonly handlers: ReadonlyArray<CapabilityHandler>;
  readonly controls: Readonly<Record<CapabilityControl, boolean>>;
  readonly probe: CapabilityProbe;
  readonly observedAt: Date;
  readonly ttlSeconds: number;
}

/**
 * Compose a schema-shaped attestation from trusted observations.
 *
 * Status is derived, never supplied: `supported` requires every control true,
 * an observed handler for each lifecycle event and a denied probe with
 * protected evidence; otherwise the attestation is `unsupported` and carries
 * one blocking finding per missing control so doctor can explain it.
 */
export function composeCapabilityAttestation(
  observation: CapabilityObservation,
): CapabilityAttestation {
  const findings: DiscoveryFinding[] = [];
  const problem = (message: string, nextAction: string): void => {
    findings.push({
      code: DISCOVERY_ENFORCEMENT_UNAVAILABLE,
      severity: "error",
      artifact_path: null,
      pointer: "/controls",
      related_ids: [],
      related_paths: [],
      message,
      next_action: nextAction,
    });
  };
  // Each false control and each missing handler is a separate, explainable gap.
  for (const control of CAPABILITY_CONTROLS) {
    if (!observation.controls[control]) {
      problem(
        `Native control ${control} is not available.`,
        "Enable the native hook controls for this host and re-run the capability probe.",
      );
    }
  }
  for (const event of HANDLER_EVENTS) {
    if (!observation.handlers.some((entry) => entry.event === event)) {
      problem(
        `No ${event} hook handler was observed.`,
        "Install the discovery hook handlers and re-run the capability probe.",
      );
    }
  }
  if (
    observation.probe.result !== "denied" ||
    observation.probe.evidence_ref === null
  ) {
    problem(
      `Sentinel ${observation.probe.sentinel_id} was ${observation.probe.result}.`,
      "Confirm the native hook denies forbidden operations and records protected evidence.",
    );
  }
  const expires = new Date(
    observation.observedAt.getTime() + observation.ttlSeconds * 1000,
  );
  return {
    $schema: CAPABILITY_ATTESTATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "capability-attestation",
    id: observation.id,
    attestation_ref: observation.attestationRef,
    workspace: { ...observation.workspace },
    host: observation.host,
    session_id: observation.sessionId,
    runtime: { ...observation.runtime },
    configuration_sha256: observation.configurationSha256,
    handlers: observation.handlers.map((entry) => ({ ...entry })),
    controls: { ...observation.controls },
    probe: { ...observation.probe },
    status: findings.length === 0 ? "supported" : "unsupported",
    findings,
    observed_at: observation.observedAt.toISOString(),
    expires_at: expires.toISOString(),
  };
}

/**
 * Replace the runtime's generic enforcement warning with the gateway's
 * assessment: one verified info finding, or one warning per deficiency.
 */
export function projectCapabilityDiagnostics(
  result: DiscoveryServiceResult,
  assessment: CapabilityAssessment,
): DiscoveryServiceResult {
  const retained = result.findings.filter(
    (finding) => finding.code !== DISCOVERY_ENFORCEMENT_UNAVAILABLE,
  );
  const projected: DiscoveryFinding[] =
    assessment.status === "supported"
      ? [
          {
            code: DISCOVERY_ENFORCEMENT_VERIFIED,
            severity: "info",
            artifact_path: null,
            pointer: "/summary/deployment",
            related_ids: [],
            related_paths: [],
            message: `Native discovery capability verified by attestation ${assessment.attestation?.attestation_ref ?? "unknown"}.`,
            next_action:
              "Controlled agent preparation may proceed for this session.",
          },
        ]
      : assessment.deficiencies.map((deficiency) => ({
          code: DISCOVERY_ENFORCEMENT_UNAVAILABLE,
          severity: "warning" as const,
          artifact_path: null,
          pointer: "/summary/deployment",
          related_ids: [],
          related_paths: [],
          message: `Native discovery capability is unavailable (${deficiency.kind}): ${deficiency.detail}.`,
          next_action:
            "Install and verify a supported native capability provider, then re-run the capability probe.",
        }));
  return { ...result, findings: [...retained, ...projected] };
}
