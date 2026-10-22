/**
 * Shared fixtures for the capability diagnostics suites: a supported
 * attestation bound to one workspace, host, session and runtime, the matching
 * expectation with pinned hashes, and the schema's required key list.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  assessCapability,
  CAPABILITY_CONTROLS,
  type CapabilityAttestation,
  type CapabilityExpectation,
  composeCapabilityAttestation,
} from "../src/discovery-capabilities";

export const SCHEMA = JSON.parse(
  fs.readFileSync(
    path.resolve(
      __dirname,
      "..",
      "..",
      "..",
      "schemas",
      "discovery",
      "v2",
      "capability-attestation.schema.json",
    ),
    "utf8",
  ),
) as { required: string[] };

export const WORKSPACE = {
  workspace_root: "C:/Users/Example/Repos/Workspace",
  workspace_sha256: "a".repeat(64),
  profile_path: "docs/migration/discovery/domain-profile.yaml",
  profile_sha256: "b".repeat(64),
};
export const RUNTIME = {
  package_version: "2.0.0",
  schema_version: "2.0.0",
  build_sha256: "c".repeat(64),
  policy_version: 1,
  policy_sha256: "d".repeat(64),
};
export const HANDLERS = [
  { event: "start" as const, path: "hooks/start.ps1", sha256: "1".repeat(64) },
  { event: "tool" as const, path: "hooks/tool.ps1", sha256: "2".repeat(64) },
  { event: "stop" as const, path: "hooks/stop.ps1", sha256: "3".repeat(64) },
];
export const CONTROLS = Object.fromEntries(
  CAPABILITY_CONTROLS.map((name) => [name, true]),
) as CapabilityAttestation["controls"];
export const OBSERVED = new Date("2026-10-22T11:50:00Z");
export const NOW = new Date("2026-10-22T12:00:00Z");
export const EXPECTED: CapabilityExpectation = {
  workspace: WORKSPACE,
  host: "codex",
  sessionId: "session-alpha",
  runtime: RUNTIME,
  pins: { configuration_sha256: "f".repeat(64), handlers: HANDLERS },
};

export function observation(overrides: Record<string, unknown> = {}) {
  return {
    id: "capability-alpha",
    attestationRef: "attestation-alpha-00000000001",
    workspace: WORKSPACE,
    host: "codex",
    sessionId: "session-alpha",
    runtime: RUNTIME,
    configurationSha256: "f".repeat(64),
    handlers: HANDLERS,
    controls: CONTROLS,
    probe: {
      sentinel_id: "sentinel-alpha",
      result: "denied" as const,
      evidence_ref: "evidence-alpha-000000000001",
    },
    observedAt: OBSERVED,
    ttlSeconds: 3600,
    ...overrides,
  };
}

export function supported(): CapabilityAttestation {
  return composeCapabilityAttestation(observation());
}

export function kinds(
  attestation: CapabilityAttestation | null,
  expected: CapabilityExpectation = EXPECTED,
  now = NOW,
): string[] {
  return assessCapability(attestation, expected, now).deficiencies.map(
    (item) => item.kind,
  );
}
