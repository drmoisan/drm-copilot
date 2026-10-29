/**
 * Prove the doctor projection takes the host and session from the root grant
 * of the doctor call and otherwise answers `context-missing`; the runtime is
 * an in-memory launcher and no Python process, filesystem or network is
 * touched.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import { projectDoctorCapability } from "../src/repo-automation-service-discovery-agent";
import { issueRootGrant, rootGrantPath } from "./discovery-grant-test-support";
import { RUNTIME, seeded } from "./discovery-invocation-test-support";
import type { MemoryStoreIO } from "./discovery-store-test-helpers";
import {
  buildServiceResult,
  FakeLauncher,
  successOutcome,
} from "./discovery-test-helpers";
import {
  provider,
  service,
  WS_ROOT,
} from "./repo-automation-service-discovery-test-support";

const DOCTOR_RAW = { workspace_root: WS_ROOT };

describe("discovery request composition", () => {
  describe("doctor capability projection", () => {
    const unavailable = {
      code: "DISCOVERY_ENFORCEMENT_UNAVAILABLE",
      severity: "warning" as const,
      artifact_path: null,
      pointer: "/summary/deployment",
      related_ids: [],
      related_paths: [],
      message: "Native discovery capability has not been verified.",
      next_action: "Install and verify a supported native capability provider.",
    };
    const doctor = (runtime: typeof RUNTIME | null = RUNTIME) =>
      new FakeLauncher(
        successOutcome(
          buildServiceResult({
            operation: "doctor",
            runtime,
            findings: [unavailable],
          }),
        ),
      );
    const codes = (result: {
      discovery?: {
        findings: ReadonlyArray<{ code: string; message: string }>;
      };
    }) =>
      result.discovery?.findings.map(
        (finding) => `${finding.code} ${finding.message}`,
      ) ?? [];
    /** Seed the root grant the native gate issued for the doctor call. */
    const granted = (io: MemoryStoreIO): MemoryStoreIO => {
      issueRootGrant(io, {
        tool: "run_discovery_doctor",
        operation: "doctor",
        inputs: DOCTOR_RAW,
      });
      return io;
    };
    const doctorInput = { workspaceRoot: WS_ROOT, toolInputs: DOCTOR_RAW };

    it("projects the lazily created host provider without an injected one", async () => {
      // Production never injects a provider, so the doctor must still project the
      // session capability; a call no host gate observed has no root grant, which
      // is the exact context-missing deficiency, reported before any protected
      // path is resolved.
      const result = await service(doctor()).runDiscoveryDoctor({
        workspaceRoot: WS_ROOT,
      });
      expect(codes(result)).toEqual([
        `${unavailable.code} Native discovery capability is unavailable (context-missing): no root grant of the native host gate supplied a session context for this call.`,
      ]);
    });

    it("reports a verified capability from the protected attestation of the grant's session", async () => {
      const io = granted(seeded());
      const result = await service(doctor(), provider(io)).runDiscoveryDoctor(
        doctorInput,
      );
      expect(codes(result)).toEqual([
        expect.stringContaining(
          "DISCOVERY_ENFORCEMENT_VERIFIED Native discovery capability verified by attestation attestation-alpha",
        ),
      ]);
      expect(io.files.has(`${rootGrantPath()}.consumed`)).toBe(true);
    });

    it.each([
      [
        "a missing attestation",
        granted(seeded(null)),
        {},
        "(attestation-missing)",
      ],
      ["no root grant for this call", seeded(), {}, "(context-missing)"],
      [
        "an unreadable activation",
        granted(seeded()),
        {
          activation: () => ({
            envelope: () => {
              throw new DiscoveryAuthorityError(
                "ACTIVATION_INACTIVE",
                "inactive",
              );
            },
          }),
        },
        "(activation-unavailable)",
      ],
    ])(
      "explains %s as a deficiency warning",
      async (_label, io, overrides, text) => {
        const before = new Set(io.files.keys());
        const result = await service(
          doctor(),
          provider(io, overrides),
        ).runDiscoveryDoctor(doctorInput);
        expect(codes(result)).toEqual([
          expect.stringContaining(
            `DISCOVERY_ENFORCEMENT_UNAVAILABLE Native discovery capability is unavailable ${text}`,
          ),
        ]);
        // Doctor writes nothing protected; at most the consumed grant latch appears.
        const added = [...io.files.keys()].filter((key) => !before.has(key));
        expect(added.every((key) => key.endsWith(".consumed"))).toBe(true);
      },
    );

    it("names a runtime without identity and passes through results without a discovery payload", async () => {
      const result = await service(
        doctor(null),
        provider(granted(seeded())),
      ).runDiscoveryDoctor(doctorInput);
      expect(codes(result)).toEqual([
        expect.stringContaining("(runtime-mismatch)"),
      ]);
      const bare = {
        tool: "run_discovery_doctor" as const,
        workspaceRoot: WS_ROOT,
        summary: "none",
      };
      expect(
        projectDoctorCapability(provider(seeded()), doctorInput, bare),
      ).toBe(bare);
    });
  });
});
