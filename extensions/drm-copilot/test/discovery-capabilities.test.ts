/**
 * Prove capability attestation composition, assessment and decoding.
 *
 * A supported attestation requires trusted observed start/tool/stop handlers,
 * exact host/configuration/hook hashes and a denied harmless sentinel; every
 * other state is a named deficiency, and a malformed document is an error.
 */

import {
  assessCapability,
  ATTESTATION_KEYS,
  type CapabilityAttestation,
  capabilityProbeSpec,
  composeCapabilityAttestation,
  decodeCapabilityAttestation,
  DISCOVERY_ENFORCEMENT_UNAVAILABLE,
  DiscoveryCapabilityError,
} from "../src/discovery-capabilities";
import {
  CONTROLS,
  EXPECTED,
  HANDLERS,
  kinds,
  NOW,
  OBSERVED,
  observation,
  RUNTIME,
  SCHEMA,
  supported,
  WORKSPACE,
} from "./discovery-capabilities-test-support";

describe("composeCapabilityAttestation", () => {
  it("derives a supported attestation from complete trusted observations", () => {
    const attestation = supported();
    expect(attestation.status).toBe("supported");
    expect(attestation.findings).toEqual([]);
    expect(attestation.observed_at).toBe(OBSERVED.toISOString());
    expect(attestation.expires_at).toBe("2026-10-22T12:50:00.000Z");
    expect(Object.keys(attestation).sort()).toEqual(
      [...SCHEMA.required].sort(),
    );
    expect([...ATTESTATION_KEYS]).toEqual([...SCHEMA.required].sort());
    expect(decodeCapabilityAttestation(JSON.stringify(attestation))).toEqual(
      attestation,
    );
  });

  it.each([
    [
      "a false control",
      { controls: { ...CONTROLS, forbidden_tools_denied: false } },
      "forbidden_tools_denied",
    ],
    [
      "a missing handler",
      { handlers: HANDLERS.slice(0, 2) },
      "No stop hook handler",
    ],
    [
      "an allowed sentinel",
      {
        probe: {
          sentinel_id: "s",
          result: "allowed",
          evidence_ref: "evidence-alpha-000000000001",
        },
      },
      "was allowed",
    ],
    [
      "a denial without evidence",
      { probe: { sentinel_id: "s", result: "denied", evidence_ref: null } },
      "was denied",
    ],
  ])(
    "derives unsupported with an explanatory finding for %s",
    (_label, overrides, text) => {
      const attestation = composeCapabilityAttestation(observation(overrides));
      expect(attestation.status).toBe("unsupported");
      expect(attestation.findings.length).toBeGreaterThan(0);
      expect(
        attestation.findings.every(
          (finding) =>
            finding.code === DISCOVERY_ENFORCEMENT_UNAVAILABLE &&
            finding.severity === "error",
        ),
      ).toBe(true);
      expect(
        attestation.findings.map((finding) => finding.message).join(" "),
      ).toContain(text);
    },
  );

  it("describes the harmless sentinel the host must deny", () => {
    const probe = capabilityProbeSpec("sentinel-alpha");
    expect(probe).toEqual({
      sentinel_id: "sentinel-alpha",
      forbidden_tool: "shell",
      request: expect.stringContaining("must be denied") as string,
    });
  });
});

describe("assessCapability", () => {
  it("accepts a current supported attestation bound to the expectation", () => {
    const assessment = assessCapability(supported(), EXPECTED, NOW);
    expect(assessment.status).toBe("supported");
    expect(assessment.deficiencies).toEqual([]);
    expect(assessment.attestation?.attestation_ref).toBe(
      "attestation-alpha-00000000001",
    );
  });

  it("reports a missing attestation", () => {
    expect(kinds(null)).toEqual(["attestation-missing"]);
  });

  it.each([
    ["unsupported harness", { status: "unsupported" }, ["harness-unsupported"]],
    [
      "disabled hooks",
      { controls: { ...CONTROLS, hooks_enabled: false } },
      ["hooks-disabled"],
    ],
    [
      "missing workspace trust",
      { controls: { ...CONTROLS, workspace_trusted: false } },
      ["trust-missing"],
    ],
    [
      "untrusted attribution",
      { controls: { ...CONTROLS, trusted_attribution: false } },
      ["trust-missing"],
    ],
    [
      "unsupported stop event",
      { controls: { ...CONTROLS, stop_event: false } },
      ["event-unsupported"],
    ],
    [
      "unobserved tool handler",
      { handlers: HANDLERS.filter((handler) => handler.event !== "tool") },
      ["event-unsupported", "hook-hash-mismatch"],
    ],
    [
      "sentinel allowed",
      {
        probe: {
          sentinel_id: "s",
          result: "allowed",
          evidence_ref: "evidence-alpha-000000000001",
        },
      },
      ["probe-not-denied"],
    ],
    [
      "sentinel unavailable",
      {
        probe: { sentinel_id: "s", result: "unavailable", evidence_ref: null },
      },
      ["probe-not-denied"],
    ],
    [
      "forbidden tools not denied",
      { controls: { ...CONTROLS, forbidden_tools_denied: false } },
      ["probe-not-denied"],
    ],
    [
      "other workspace",
      { workspace: { ...WORKSPACE, profile_sha256: "9".repeat(64) } },
      ["workspace-mismatch"],
    ],
    ["other host", { host: "claude-code" }, ["host-mismatch"]],
    ["other session", { session_id: "session-beta" }, ["session-mismatch"]],
    [
      "other runtime build",
      { runtime: { ...RUNTIME, build_sha256: "0".repeat(64) } },
      ["runtime-mismatch"],
    ],
    [
      "other runtime version",
      { runtime: { ...RUNTIME, package_version: "2.1.0" } },
      ["runtime-mismatch"],
    ],
    [
      "configuration hash drift",
      { configuration_sha256: "e".repeat(64) },
      ["configuration-hash-mismatch"],
    ],
    [
      "hook hash drift",
      {
        handlers: [
          HANDLERS[0]!,
          { ...HANDLERS[1]!, sha256: "7".repeat(64) },
          HANDLERS[2]!,
        ],
      },
      ["hook-hash-mismatch"],
    ],
    [
      "hook path drift",
      {
        handlers: [
          { ...HANDLERS[0]!, path: "hooks/other.ps1" },
          HANDLERS[1]!,
          HANDLERS[2]!,
        ],
      },
      ["hook-hash-mismatch"],
    ],
  ])("names %s", (_label, overrides, expected) => {
    const attestation = {
      ...supported(),
      ...overrides,
    } as CapabilityAttestation;
    expect(kinds(attestation)).toEqual(expected);
  });

  it("reports a stale or not-yet-observed attestation", () => {
    expect(
      kinds(supported(), EXPECTED, new Date("2026-10-22T12:50:00Z")),
    ).toEqual(["probe-stale"]);
    expect(
      kinds(supported(), EXPECTED, new Date("2026-10-22T11:49:59Z")),
    ).toEqual(["probe-stale"]);
    expect(kinds(supported(), EXPECTED, OBSERVED)).toEqual([]);
  });

  it("accumulates several deficiencies in contract order and ignores absent pins", () => {
    const attestation = {
      ...supported(),
      status: "unsupported",
      host: "claude-code",
    } as CapabilityAttestation;
    expect(
      kinds(
        attestation,
        {
          workspace: WORKSPACE,
          host: "codex",
          sessionId: "session-alpha",
          runtime: RUNTIME,
        },
        new Date("2026-10-22T13:00:00Z"),
      ),
    ).toEqual(["harness-unsupported", "host-mismatch", "probe-stale"]);
  });
});

describe("decodeCapabilityAttestation", () => {
  it.each([
    ["not JSON", "{"],
    ["array", "[]"],
    ["extra key", JSON.stringify({ ...supported(), caller: true })],
    ["wrong schema", JSON.stringify({ ...supported(), $schema: "urn:other" })],
    [
      "short reference",
      JSON.stringify({ ...supported(), attestation_ref: "short" }),
    ],
    ["bad timestamp", JSON.stringify({ ...supported(), expires_at: "soon" })],
    ["unknown host", JSON.stringify({ ...supported(), host: "shell" })],
    [
      "bad control",
      JSON.stringify({
        ...supported(),
        controls: { ...CONTROLS, hooks_enabled: "yes" },
      }),
    ],
    [
      "missing control",
      JSON.stringify({ ...supported(), controls: { hooks_enabled: true } }),
    ],
    [
      "bad handler",
      JSON.stringify({
        ...supported(),
        handlers: [{ event: "boot", path: "x", sha256: "1".repeat(64) }],
      }),
    ],
    [
      "bad probe",
      JSON.stringify({
        ...supported(),
        probe: { sentinel_id: "s", result: "maybe", evidence_ref: null },
      }),
    ],
    [
      "bad configuration hash",
      JSON.stringify({ ...supported(), configuration_sha256: "nope" }),
    ],
  ])("rejects %s", (_label, text) => {
    expect(() => decodeCapabilityAttestation(text)).toThrow(
      DiscoveryCapabilityError,
    );
  });
});
