/**
 * Prove the shared service composes one closed v2 request per discovery
 * operation and takes every host identity from a consumed one-use record.
 *
 * The runtime is an in-memory launcher that records the stdin request; no
 * Python process, filesystem or network is touched.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import type { ControlledTool } from "../src/discovery-authorization";
import type { RepoAutomationService } from "../src/repo-automation-service";
import {
  AGENT_ID,
  AGENT_ROLE,
  AUTHORIZATION_REF,
  issueAuthorization,
  issueRootGrant,
  ROOT_GRANT_REF,
  startedStore,
} from "./discovery-grant-test-support";
import { seeded } from "./discovery-invocation-test-support";
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

/** The invocation `startedStore()` prepares with the fixture nonce. */
const INVOCATION_ID = "invocation-0123456789abcdef0001";
/** The raw MCP input the gate digested for a bound call; any object serves. */
const RAW = { workspace_root: WS_ROOT, call: "bound" };
const DOCTOR_RAW = { workspace_root: WS_ROOT };
const BOUND_TOOLS: Readonly<Record<string, ControlledTool>> = {
  "new-contract": "create_discovery_artifact",
  "read-source": "read_discovery_source",
};

interface Grant {
  readonly invocationId: string;
  readonly authorizationRef: string;
}

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
      (svc: RepoAutomationService, grant: Grant) =>
        svc.createDiscoveryArtifact({
          workspaceRoot: WS_ROOT,
          artifactKind: "feature-contract",
          featureId: "orders",
          name: "Orders",
          invocationRef: grant.invocationId,
          authorizationRef: grant.authorizationRef,
          write: true,
        }),
      {
        operation: "new-contract",
        mode: "agent-output",
        write: true,
        dry_run: false,
        inputs: { feature_id: "orders", name: "Orders" },
        invocation_ref: INVOCATION_ID,
        authorization_ref: AUTHORIZATION_REF,
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
      (svc: RepoAutomationService, grant: Grant) =>
        svc.readDiscoverySource({
          workspaceRoot: WS_ROOT,
          readOperation: "search",
          paths: ["src"],
          query: "Order",
          regex: true,
          maxBytes: 2048,
          invocationRef: grant.invocationId,
          authorizationRef: grant.authorizationRef,
          mode: "agent-output",
        }),
      {
        operation: "read-source",
        mode: "agent-output",
        invocation_ref: INVOCATION_ID,
        authorization_ref: AUTHORIZATION_REF,
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
    // A request bound to a protected invocation runs under the identity of the
    // authorization the gate consumed for it; every other request stays local-user.
    const operation = (expected as Record<string, unknown>)[
      "operation"
    ] as string;
    const bound =
      typeof (expected as Record<string, unknown>)["invocation_ref"] ===
      "string";
    let subject = service(launcher);
    let grant: Grant = { invocationId: "", authorizationRef: "" };
    if (bound) {
      const started = startedStore();
      const tool = BOUND_TOOLS[operation]!;
      issueAuthorization(started.io, {
        invocationId: started.invocationId,
        tool,
        operation,
        inputs: RAW,
      });
      subject = service(launcher, provider(started.io));
      const authorizationRef = subject.consumeDiscoveryToolAuthorization!({
        workspaceRoot: WS_ROOT,
        tool,
        operation,
        inputs: RAW,
        invocationRef: started.invocationId,
      });
      grant = { invocationId: started.invocationId, authorizationRef };
    }
    const result = await call(subject, grant);
    expect(launcher.request()).toMatchObject(expected);
    expect(launcher.single().cwd).toBe(WS_ROOT);
    const args = launcher.single().args;
    if (bound) {
      expect(args.slice(-10)).toEqual([
        "--principal",
        "host",
        "--author-id",
        AGENT_ID,
        "--session-id",
        "session-alpha",
        "--host-name",
        "codex",
        "--agent-role",
        AGENT_ROLE,
      ]);
    } else {
      expect(args).toEqual(
        expect.arrayContaining(["--principal", "local-user"]),
      );
      expect(args).not.toContain("--session-id");
    }
    expect(result.discovery).toMatchObject({
      ok: true,
      runtime: buildServiceResult().runtime,
    });
  });

  it.each([
    [
      "new-contract",
      (svc: RepoAutomationService) =>
        svc.createDiscoveryArtifact({
          workspaceRoot: WS_ROOT,
          artifactKind: "feature-contract",
          featureId: "orders",
          name: "Orders",
          invocationRef: INVOCATION_ID,
        }),
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
          invocationRef: INVOCATION_ID,
          authorizationRef: "authz-never-consumed-000000001",
        }),
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
          invocationRef: INVOCATION_ID,
        }),
    ],
    [
      "read-source",
      (svc: RepoAutomationService) =>
        svc.readDiscoverySource({
          workspaceRoot: WS_ROOT,
          readOperation: "list",
          paths: ["src"],
          invocationRef: INVOCATION_ID,
          mode: "agent-output",
        }),
    ],
  ])(
    "refuses a %s request bound to an invocation without a consumed authorization",
    async (_label, call) => {
      const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
      await expect(
        call(service(launcher, provider(startedStore().io))),
      ).rejects.toThrow("DISCOVERY_HOST_BINDING_REQUIRED");
      // Refused before any process launch; nothing is downgraded to local-user.
      expect(launcher.captures).toHaveLength(0);
    },
  );

  it("hands a consumed authorization to exactly one request", async () => {
    const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
    const started = startedStore();
    issueAuthorization(started.io, {
      invocationId: started.invocationId,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: RAW,
    });
    const subject = service(launcher, provider(started.io));
    const authorizationRef = subject.consumeDiscoveryToolAuthorization!({
      workspaceRoot: WS_ROOT,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: RAW,
      invocationRef: started.invocationId,
    });
    const input = {
      workspaceRoot: WS_ROOT,
      readOperation: "list" as const,
      paths: ["src"],
      invocationRef: started.invocationId,
      authorizationRef,
      mode: "agent-output" as const,
    };
    await subject.readDiscoverySource(input);
    await expect(subject.readDiscoverySource(input)).rejects.toThrow(
      "DISCOVERY_HOST_BINDING_REQUIRED",
    );
    expect(launcher.captures).toHaveLength(1);
  });

  it("consumes a root grant through the service seam exactly once", () => {
    const launcher = new FakeLauncher(successOutcome());
    const io = seeded();
    issueRootGrant(io, {
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: DOCTOR_RAW,
    });
    const subject = service(launcher, provider(io));
    const input = {
      workspaceRoot: WS_ROOT,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: DOCTOR_RAW,
    };
    expect(subject.consumeDiscoveryRootGrant!(input)).toBe(ROOT_GRANT_REF);
    expect(() => subject.consumeDiscoveryRootGrant!(input)).toThrow(
      "AUTHORIZATION_CONSUMED",
    );
    expect(launcher.captures).toHaveLength(0);
  });

  it("exposes no role or identity of its own", () => {
    const subject = service(new FakeLauncher(successOutcome()));
    expect("discoveryRole" in subject).toBe(false);
    expect(Object.keys(provider(seeded()))).not.toContain("agent");
    expect(Object.keys(provider(seeded()))).not.toContain("context");
  });
});
