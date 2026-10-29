/**
 * Prove the host records at the MCP gate: a controlled call carrying
 * `invocation_ref` consumes a tool authorization, a controlled call without
 * it consumes a root grant, the root-only prepare is refused without its
 * root grant before any runtime launch, the root setup tools consume
 * nothing, and decision approval is denied to a call bound to an invocation.
 */

import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

jest.mock("vscode", () => ({ window: { createTerminal: jest.fn() } }), {
  virtual: true,
});

import { DiscoveryAuthorizationError } from "../src/discovery-authorization";
import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import type { RepoAutomationExecutionResult } from "../src/repo-automation-service";
import type { RepoAutomationToolName } from "../src/repo-automation-tool-names";
import { seeded } from "./discovery-invocation-test-support";
import {
  buildServiceResult,
  FakeLauncher,
  successOutcome,
} from "./discovery-test-helpers";
import { createMockService, type MockService } from "./mcp-server-test-service";
import {
  provider,
  service as realService,
} from "./repo-automation-service-discovery-test-support";

const WS = "C:/workspace";

function success(tool: RepoAutomationToolName): RepoAutomationExecutionResult {
  return { tool, workspaceRoot: WS, summary: `did ${tool}` };
}

describe("discovery tool dispatch", () => {
  let service: MockService;

  beforeEach(() => {
    service = createMockService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  const SHA = "a".repeat(64);

  describe("host records at the gate", () => {
    it("refuses prepare_discovery_agent without a root grant through the real service before any runtime launch", async () => {
      // The root-only prepare consumes the root grant the native gate issued for
      // exactly this call; a call no gate observed is refused, never run as root.
      const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
      const result = await dispatchRepoAutomationTool(
        "prepare_discovery_agent",
        {
          workspace_root: WS,
          skill_id: "inventory-legacy-system",
          selected_ids: ["a"],
          paths: ["src"],
          expected_outputs: [{ artifact_kind: "inventory-snapshot" }],
          execution_context: "standalone",
          complexity: "C2",
        },
        realService(launcher, provider(seeded())),
      );
      expect(result.ok).toBe(false);
      expect(result.summary).toContain("DISCOVERY_HOST_BINDING_REQUIRED");
      expect(launcher.captures).toHaveLength(0);
    });

    it("consumes no record for the root setup tools", async () => {
      service.configureDiscoveryWorkspace.mockResolvedValue(
        success("configure_discovery_workspace"),
      );
      const result = await dispatchRepoAutomationTool(
        "configure_discovery_workspace",
        { workspace_root: WS, configuration_action: "activate" },
        service,
      );
      expect(result.ok).toBe(true);
      expect(service.consumeDiscoveryRootGrant).not.toHaveBeenCalled();
      expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
    });

    it("allows diagnostics, bounded reads and artifact replacement under a consumed grant", async () => {
      // Controlled calls carrying invocation_ref consume one native grant each
      // (P12-T4 gate) and carry its reference; doctor is not controlled.
      const invocationRef = "invocation-0123456789abcdef0001";
      const authorizationRef = "authz-alpha-0000000000000001";
      service.consumeDiscoveryToolAuthorization!.mockReturnValue(
        authorizationRef,
      );
      service.runDiscoveryDoctor.mockResolvedValue(
        success("run_discovery_doctor"),
      );
      service.readDiscoverySource.mockResolvedValue(
        success("read_discovery_source"),
      );
      service.updateDiscoveryArtifact.mockResolvedValue(
        success("update_discovery_artifact"),
      );
      expect(
        (
          await dispatchRepoAutomationTool(
            "run_discovery_doctor",
            { workspace_root: WS },
            service,
          )
        ).ok,
      ).toBe(true);
      expect(
        (
          await dispatchRepoAutomationTool(
            "read_discovery_source",
            {
              workspace_root: WS,
              read_operation: "list",
              paths: ["src"],
              invocation_ref: invocationRef,
            },
            service,
          )
        ).ok,
      ).toBe(true);
      expect(
        (
          await dispatchRepoAutomationTool(
            "update_discovery_artifact",
            {
              workspace_root: WS,
              artifact_kind: "feature-contract",
              artifact_path: "a",
              input_path: "b",
              expected_sha256: null,
              update_action: "replace",
              invocation_ref: invocationRef,
            },
            service,
          )
        ).ok,
      ).toBe(true);
      expect(service.consumeDiscoveryToolAuthorization).toHaveBeenCalledTimes(
        2,
      );
      expect(service.consumeDiscoveryRootGrant).not.toHaveBeenCalled();
      expect(service.readDiscoverySource).toHaveBeenCalledWith(
        expect.objectContaining({ invocationRef, authorizationRef }),
      );
      expect(service.updateDiscoveryArtifact).toHaveBeenCalledWith(
        expect.objectContaining({ invocationRef, authorizationRef }),
      );
    });

    it("admits a controlled call without invocation_ref through its root grant", async () => {
      service.readDiscoverySource.mockResolvedValue(
        success("read_discovery_source"),
      );
      const raw = {
        workspace_root: WS,
        read_operation: "list",
        paths: ["src"],
      };
      const result = await dispatchRepoAutomationTool(
        "read_discovery_source",
        raw,
        service,
      );
      expect(result.ok).toBe(true);
      expect(service.consumeDiscoveryRootGrant).toHaveBeenCalledWith({
        workspaceRoot: WS,
        tool: "read_discovery_source",
        operation: "read-source",
        inputs: raw,
      });
      expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
      expect(service.readDiscoverySource).toHaveBeenCalledWith(
        expect.not.objectContaining({ authorizationRef: expect.anything() }),
      );
    });

    it("refuses a controlled call without invocation_ref when no root grant exists", async () => {
      service.consumeDiscoveryRootGrant!.mockImplementation(() => {
        throw new DiscoveryAuthorizationError(
          "DISCOVERY_HOST_BINDING_REQUIRED",
          "no root grant",
        );
      });
      const result = await dispatchRepoAutomationTool(
        "read_discovery_source",
        { workspace_root: WS, read_operation: "list", paths: ["src"] },
        service,
      );
      expect(result.ok).toBe(false);
      expect(result.summary).toContain("DISCOVERY_HOST_BINDING_REQUIRED");
      expect(service.readDiscoverySource).not.toHaveBeenCalled();
      expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
    });

    it("denies decision approval to a call bound to an invocation and consumes no record for it", async () => {
      const approval = {
        workspace_root: WS,
        artifact_kind: "product-decision",
        artifact_path: "a",
        input_path: "b",
        expected_sha256: SHA,
        update_action: "approve-decision",
        artifact_id: "d",
        approval_owner: "o",
        approval_evidence_refs: ["e"],
      };
      const result = await dispatchRepoAutomationTool(
        "update_discovery_artifact",
        { ...approval, invocation_ref: "invocation-0123456789abcdef0001" },
        service,
      );
      expect(result.ok).toBe(false);
      expect(result.summary).toContain(
        "approve-decision is a root-only update",
      );
      expect(service.updateDiscoveryArtifact).not.toHaveBeenCalled();
      expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
      // The root may approve: the call consumes its root grant and proceeds.
      service.updateDiscoveryArtifact.mockResolvedValue(
        success("update_discovery_artifact"),
      );
      const root = await dispatchRepoAutomationTool(
        "update_discovery_artifact",
        approval,
        service,
      );
      expect(root.ok).toBe(true);
      expect(service.consumeDiscoveryRootGrant).toHaveBeenCalledTimes(1);
    });
  });
});
