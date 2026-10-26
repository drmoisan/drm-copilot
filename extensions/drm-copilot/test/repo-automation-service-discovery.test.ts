/**
 * Prove the shared service composes one closed v2 request per discovery
 * operation and reports the trusted role context.
 *
 * The runtime is an in-memory launcher that records the stdin request; no
 * Python process, filesystem or network is touched.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import type { RepoAutomationService } from "../src/repo-automation-service";
import { projectDoctorCapability } from "../src/repo-automation-service-discovery-agent";
import { CONTEXT, RUNTIME, seeded } from "./discovery-invocation-test-support";
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

describe("discovery request composition", () => {
  it.each([
    [
      "configure",
      (svc: RepoAutomationService) =>
        svc.configureDiscoveryWorkspace({
          workspaceRoot: WS_ROOT,
          configurationAction: "activate",
          inputPath: "docs/p.yaml",
          dryRun: true,
        }),
      {
        operation: "configure",
        mode: "structural",
        dry_run: true,
        write: false,
        inputs: { configuration_action: "activate", input_path: "docs/p.yaml" },
        invocation_ref: null,
      },
    ],
    [
      "new-contract under a grant",
      (svc: RepoAutomationService) =>
        svc.createDiscoveryArtifact({
          workspaceRoot: WS_ROOT,
          artifactKind: "feature-contract",
          featureId: "orders",
          name: "Orders",
          invocationRef: "invocation-alpha-0000000001",
          authorizationRef: "authz-alpha-000000000000001",
          write: true,
        }),
      {
        operation: "new-contract",
        mode: "agent-output",
        write: true,
        dry_run: false,
        inputs: { feature_id: "orders", name: "Orders" },
        invocation_ref: "invocation-alpha-0000000001",
        authorization_ref: "authz-alpha-000000000000001",
      },
    ],
    [
      "new-scenario",
      (svc: RepoAutomationService) =>
        svc.createDiscoveryArtifact({
          workspaceRoot: WS_ROOT,
          artifactKind: "runtime-scenario",
          scenarioId: "s",
          featureIds: ["orders"],
        }),
      {
        operation: "new-scenario",
        mode: "structural",
        inputs: { scenario_id: "s", feature_ids: ["orders"] },
      },
    ],
    [
      "update-artifact",
      (svc: RepoAutomationService) =>
        svc.updateDiscoveryArtifact({
          workspaceRoot: WS_ROOT,
          artifactKind: "feature-contract",
          artifactPath: "a",
          inputPath: "b",
          expectedSha256: null,
          updateAction: "replace",
          dryRun: true,
        }),
      {
        operation: "update-artifact",
        dry_run: true,
        inputs: {
          artifact_kind: "feature-contract",
          artifact_path: "a",
          input_path: "b",
          expected_sha256: null,
          update_action: "replace",
        },
      },
    ],
    [
      "link-evidence",
      (svc: RepoAutomationService) =>
        svc.linkDiscoveryEvidence({
          workspaceRoot: WS_ROOT,
          artifactKind: "feature-contract",
          artifactId: "f",
          evidencePath: "e.json",
          expectedSha256: "a".repeat(64),
        }),
      {
        operation: "link-evidence",
        inputs: {
          artifact_kind: "feature-contract",
          artifact_id: "f",
          evidence_path: "e.json",
          expected_sha256: "a".repeat(64),
        },
      },
    ],
    [
      "snapshot-export",
      (svc: RepoAutomationService) =>
        svc.transferDiscoverySnapshot({
          workspaceRoot: WS_ROOT,
          direction: "export",
          selectedIds: ["orders"],
          paths: ["docs"],
          write: true,
        }),
      {
        operation: "snapshot-export",
        write: true,
        inputs: { selected_ids: ["orders"], paths: ["docs"] },
      },
    ],
    [
      "snapshot-import",
      (svc: RepoAutomationService) =>
        svc.transferDiscoverySnapshot({
          workspaceRoot: WS_ROOT,
          direction: "import",
          manifestPath: "m.json",
        }),
      { operation: "snapshot-import", inputs: { manifest_path: "m.json" } },
    ],
    [
      "import-inventory",
      (svc: RepoAutomationService) =>
        svc.importDiscoveryInventory({
          workspaceRoot: WS_ROOT,
          manifestPath: "inv.json",
          dryRun: true,
        }),
      {
        operation: "import-inventory",
        dry_run: true,
        inputs: { manifest_path: "inv.json" },
      },
    ],
    [
      "migrate",
      (svc: RepoAutomationService) =>
        svc.migrateDiscoveryArtifacts({
          workspaceRoot: WS_ROOT,
          destination: "docs/v2",
          systemId: "s",
          systemName: "n",
          systemRole: "combined",
          repositoryId: "r",
          paths: ["legacy.yaml"],
          draft: true,
        }),
      {
        operation: "migrate",
        inputs: {
          from_version: 1,
          to_version: 2,
          destination: "docs/v2",
          paths: ["legacy.yaml"],
          system_id: "s",
          system_name: "n",
          system_role: "combined",
          repository_id: "r",
          draft: true,
        },
      },
    ],
    [
      "doctor",
      (svc: RepoAutomationService) =>
        svc.runDiscoveryDoctor({ workspaceRoot: WS_ROOT }),
      { operation: "doctor", mode: "structural", inputs: {} },
    ],
    [
      "read-source search as an agent",
      (svc: RepoAutomationService) =>
        svc.readDiscoverySource({
          workspaceRoot: WS_ROOT,
          readOperation: "search",
          paths: ["src"],
          query: "Order",
          regex: true,
          maxBytes: 2048,
          invocationRef: "invocation-alpha-0000000001",
          mode: "agent-output",
        }),
      {
        operation: "read-source",
        mode: "agent-output",
        invocation_ref: "invocation-alpha-0000000001",
        authorization_ref: null,
        inputs: {
          read_operation: "search",
          paths: ["src"],
          query: "Order",
          regex: true,
          max_bytes: 2048,
        },
      },
    ],
  ])("composes the %s request", async (_label, call, expected) => {
    const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
    const result = await call(service(launcher));
    expect(launcher.request()).toMatchObject(expected);
    expect(launcher.single().cwd).toBe(WS_ROOT);
    expect(result.discovery).toMatchObject({
      ok: true,
      runtime: buildServiceResult().runtime,
    });
  });

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

    it("projects the lazily created host provider without an injected one", async () => {
      // Production never injects a provider, so the doctor must still project the
      // session capability; outside a discovery host session that is the exact
      // context-missing deficiency, reported before any protected path is resolved.
      const saved = {
        host: process.env["DRM_DISCOVERY_HOST"],
        session: process.env["DRM_DISCOVERY_SESSION_ID"],
      };
      delete process.env["DRM_DISCOVERY_HOST"];
      delete process.env["DRM_DISCOVERY_SESSION_ID"];
      try {
        const result = await service(doctor()).runDiscoveryDoctor({
          workspaceRoot: WS_ROOT,
        });
        expect(codes(result)).toEqual([
          `${unavailable.code} Native discovery capability is unavailable (context-missing): no trusted session context was supplied by the host.`,
        ]);
      } finally {
        if (saved.host !== undefined)
          process.env["DRM_DISCOVERY_HOST"] = saved.host;
        if (saved.session !== undefined) {
          process.env["DRM_DISCOVERY_SESSION_ID"] = saved.session;
        }
      }
    });

    it("reports a verified capability from the protected attestation", async () => {
      const result = await service(
        doctor(),
        provider(seeded()),
      ).runDiscoveryDoctor({ workspaceRoot: WS_ROOT });
      expect(codes(result)).toEqual([
        expect.stringContaining(
          "DISCOVERY_ENFORCEMENT_VERIFIED Native discovery capability verified by attestation attestation-alpha",
        ),
      ]);
    });

    it.each([
      ["a missing attestation", seeded(null), {}, "(attestation-missing)"],
      [
        "no trusted session context",
        seeded(),
        { context: { ...CONTEXT, sessionId: "" } },
        "(context-missing)",
      ],
      [
        "an unreadable activation",
        seeded(),
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
        const result = await service(
          doctor(),
          provider(io, overrides),
        ).runDiscoveryDoctor({ workspaceRoot: WS_ROOT });
        expect(codes(result)).toEqual([
          expect.stringContaining(
            `DISCOVERY_ENFORCEMENT_UNAVAILABLE Native discovery capability is unavailable ${text}`,
          ),
        ]);
        expect(io.writtenPaths()).toEqual([]);
      },
    );

    it("names a runtime without identity and passes through results without a discovery payload", async () => {
      const result = await service(
        doctor(null),
        provider(seeded()),
      ).runDiscoveryDoctor({ workspaceRoot: WS_ROOT });
      expect(codes(result)).toEqual([
        expect.stringContaining("(runtime-mismatch)"),
      ]);
      const bare = {
        tool: "run_discovery_doctor" as const,
        workspaceRoot: WS_ROOT,
        summary: "none",
      };
      expect(projectDoctorCapability(provider(seeded()), WS_ROOT, bare)).toBe(
        bare,
      );
    });
  });

  it("reports no role without an authority provider and the agent role with one", () => {
    const launcher = new FakeLauncher(successOutcome());
    expect(service(launcher).discoveryRole?.()).toBeNull();
    const withAgent = provider(seeded(), {
      agent: { agentId: "agent-alpha", role: "requirements-reconciler" },
    });
    expect(service(launcher, withAgent).discoveryRole?.()).toBe(
      "requirements-reconciler",
    );
  });
});
