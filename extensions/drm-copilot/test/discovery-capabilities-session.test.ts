/**
 * Prove the protected-store and session assessments and the doctor projection.
 *
 * Only the protected copy of an attestation is consulted, caller-supplied
 * capability claims are recognised and refused, and the doctor projection
 * explains each deficiency or reports the verified attestation.
 */

import {
  resolveAuthorityLocation,
  sessionDirectory,
} from "../src/discovery-authority-paths";
import { DiscoveryAuthorityError } from "../src/discovery-authority";
import {
  assessCapability,
  assessProtectedCapability,
  assessSessionCapability,
  CAPABILITY_ATTESTATION_FILE,
  type CapabilityAttestation,
  DISCOVERY_ENFORCEMENT_UNAVAILABLE,
  DISCOVERY_ENFORCEMENT_VERIFIED,
  isCallerCapabilityClaim,
  projectCapabilityDiagnostics,
} from "../src/discovery-capabilities";
import {
  EXPECTED,
  HANDLERS,
  NOW,
  RUNTIME,
  supported,
  WORKSPACE,
} from "./discovery-capabilities-test-support";
import { MemoryStoreIO } from "./discovery-store-test-helpers";
import { buildServiceResult } from "./discovery-test-helpers";

describe("assessProtectedCapability and caller claims", () => {
  const location = resolveAuthorityLocation(WORKSPACE.workspace_root, {
    platform: "windows",
    userHome: "C:/Users/Example",
    localAppData: "C:/Users/Example/AppData/Local",
  });
  const protectedPath = `${sessionDirectory(location, "session-alpha")}/${CAPABILITY_ATTESTATION_FILE}`;

  it("reads only the protected copy and classifies absence, malformed text and support", () => {
    const io = new MemoryStoreIO();
    const options = {
      location,
      io,
      sessionId: "session-alpha",
      expected: EXPECTED,
      now: NOW,
    };
    expect(
      assessProtectedCapability(options).deficiencies.map((item) => item.kind),
    ).toEqual(["attestation-missing"]);
    io.files.set(protectedPath, "{");
    expect(
      assessProtectedCapability(options).deficiencies.map((item) => item.kind),
    ).toEqual(["attestation-malformed"]);
    io.files.set(protectedPath, JSON.stringify(supported()));
    expect(assessProtectedCapability(options).status).toBe("supported");
    // A copy in another session's partition or under the workspace is ignored.
    const other = { ...options, sessionId: "session-beta" };
    expect(assessProtectedCapability(other).deficiencies[0]?.kind).toBe(
      "attestation-missing",
    );
    expect(io.operations.every((entry) => entry.startsWith("read "))).toBe(
      true,
    );
  });

  it("assesses the session from provider state and explains missing prerequisites", () => {
    const io = new MemoryStoreIO();
    io.files.set(protectedPath, JSON.stringify(supported()));
    const activation = {
      envelope: () => ({
        workspace: WORKSPACE,
        activation_sha256: "e".repeat(64),
        generation: 1,
      }),
    };
    const unpinned = {
      location,
      io,
      activation,
      context: { host: "codex", sessionId: "session-alpha" },
      runtime: RUNTIME,
      now: NOW,
    };
    const base = {
      ...unpinned,
      pins: { configuration_sha256: "f".repeat(64), handlers: HANDLERS },
    };
    expect(assessSessionCapability(base).status).toBe("supported");
    expect(assessSessionCapability(unpinned).status).toBe("supported");
    const kind = (options: Parameters<typeof assessSessionCapability>[0]) =>
      assessSessionCapability(options).deficiencies.map((item) => item.kind);
    expect(
      kind({ ...base, context: { host: "", sessionId: "session-alpha" } }),
    ).toEqual(["context-missing"]);
    expect(
      kind({ ...base, context: { host: "codex", sessionId: "" } }),
    ).toEqual(["context-missing"]);
    expect(kind({ ...base, runtime: null })).toEqual(["runtime-mismatch"]);
    const inactive = {
      envelope: () => {
        throw new DiscoveryAuthorityError("ACTIVATION_INACTIVE", "inactive");
      },
    };
    const assessment = assessSessionCapability({
      ...base,
      activation: inactive,
    });
    expect(assessment.deficiencies).toEqual([
      {
        kind: "activation-unavailable",
        detail: expect.stringContaining("inactive") as string,
      },
    ]);
    expect(
      assessSessionCapability({
        ...base,
        activation: {
          envelope: () => {
            throw "plain";
          },
        },
      }).deficiencies[0]?.detail,
    ).toContain("plain");
  });

  it("recognises caller-supplied capability claims", () => {
    expect(
      isCallerCapabilityClaim({ capability: { status: "supported" } }),
    ).toBe(true);
    expect(isCallerCapabilityClaim({ attestation_ref: "x" })).toBe(true);
    expect(isCallerCapabilityClaim({ controls: {} })).toBe(true);
    expect(isCallerCapabilityClaim({ skill_id: "x" })).toBe(false);
    expect(isCallerCapabilityClaim("text")).toBe(false);
    expect(isCallerCapabilityClaim(null)).toBe(false);
  });
});

describe("projectCapabilityDiagnostics", () => {
  const runtimeResult = buildServiceResult({
    operation: "doctor",
    findings: [
      {
        code: DISCOVERY_ENFORCEMENT_UNAVAILABLE,
        severity: "warning",
        artifact_path: null,
        pointer: "/summary/deployment",
        related_ids: [],
        related_paths: [],
        message: "Native discovery capability has not been verified.",
        next_action:
          "Install and verify a supported native capability provider.",
      },
      {
        code: "DOCTOR_CONFIGURATION",
        severity: "error",
        artifact_path: null,
        pointer: "/profile_path",
        related_ids: [],
        related_paths: [],
        message: "Local profile is invalid.",
        next_action: "Repair the profile.",
      },
    ],
  });

  it("replaces the generic warning with a verified finding when supported", () => {
    const projected = projectCapabilityDiagnostics(
      runtimeResult,
      assessCapability(supported(), EXPECTED, NOW),
    );
    expect(projected.findings.map((finding) => finding.code)).toEqual([
      "DOCTOR_CONFIGURATION",
      DISCOVERY_ENFORCEMENT_VERIFIED,
    ]);
    expect(projected.findings[1]?.severity).toBe("info");
    expect(projected.findings[1]?.message).toContain(
      "attestation-alpha-00000000001",
    );
    expect(projected.ok).toBe(runtimeResult.ok);
  });

  it("explains each deficiency as its own warning when unavailable", () => {
    const attestation = {
      ...supported(),
      status: "unsupported",
      host: "claude-code",
    } as CapabilityAttestation;
    const projected = projectCapabilityDiagnostics(
      runtimeResult,
      assessCapability(attestation, EXPECTED, NOW),
    );
    const warnings = projected.findings.filter(
      (finding) => finding.code === DISCOVERY_ENFORCEMENT_UNAVAILABLE,
    );
    expect(warnings.map((finding) => finding.message)).toEqual([
      expect.stringContaining("(harness-unsupported)"),
      expect.stringContaining("(host-mismatch)"),
    ]);
    expect(warnings.every((finding) => finding.severity === "warning")).toBe(
      true,
    );
    expect(projected.findings[0]?.code).toBe("DOCTOR_CONFIGURATION");
  });
});
