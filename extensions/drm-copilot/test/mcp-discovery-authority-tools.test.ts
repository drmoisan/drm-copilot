/**
 * Shared MCP operation contract for the discovery tools: dispatch and
 * transport agreement.
 *
 * Dispatch must route each tool to its service method, pass the typed payloads
 * through, and surface `text`, `structuredContent` and `isError` that agree.
 * The one-use host records the gate consumes are proved in
 * `mcp-discovery-authority-tools.gate.test.ts`.
 */

import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";

jest.mock("vscode", () => ({ window: { createTerminal: jest.fn() } }), {
  virtual: true,
});

import { DiscoveryAuthorizationError } from "../src/discovery-authorization";
import { DISCOVERY_TOOL_DEFINITIONS } from "../src/mcp-discovery-tool-definitions";
import { createRepoAutomationMcpServer } from "../src/mcp-server";
import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import type { RepoAutomationExecutionResult } from "../src/repo-automation-service";
import type { RepoAutomationToolName } from "../src/repo-automation-tool-names";
import { buildServiceResult } from "./discovery-test-helpers";
import { createMockService, type MockService } from "./mcp-server-test-service";

type ServiceMock = jest.Mock<
  (input: unknown) => Promise<RepoAutomationExecutionResult>
>;
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
  const CASES: ReadonlyArray<
    [
      RepoAutomationToolName,
      Record<string, unknown>,
      keyof MockService,
      Record<string, unknown>,
    ]
  > = [
    [
      "configure_discovery_workspace",
      { configuration_action: "activate", input_path: "docs/profile.yaml" },
      "configureDiscoveryWorkspace",
      { configurationAction: "activate", inputPath: "docs/profile.yaml" },
    ],
    [
      "create_discovery_artifact",
      {
        artifact_kind: "feature-contract",
        feature_id: "orders",
        name: "Orders",
      },
      "createDiscoveryArtifact",
      { artifactKind: "feature-contract", featureId: "orders", name: "Orders" },
    ],
    [
      "update_discovery_artifact",
      {
        artifact_kind: "feature-contract",
        artifact_path: "a",
        input_path: "b",
        expected_sha256: null,
        update_action: "replace",
      },
      "updateDiscoveryArtifact",
      {
        artifactKind: "feature-contract",
        artifactPath: "a",
        inputPath: "b",
        expectedSha256: null,
        updateAction: "replace",
      },
    ],
    [
      "link_discovery_evidence",
      {
        artifact_kind: "feature-contract",
        artifact_id: "f",
        evidence_path: "e.json",
        expected_sha256: SHA,
      },
      "linkDiscoveryEvidence",
      {
        artifactKind: "feature-contract",
        artifactId: "f",
        evidencePath: "e.json",
        expectedSha256: SHA,
      },
    ],
    [
      "transfer_discovery_snapshot",
      { direction: "export", selected_ids: ["orders"] },
      "transferDiscoverySnapshot",
      { direction: "export", selectedIds: ["orders"] },
    ],
    [
      "import_discovery_inventory",
      { manifest_path: "m.json" },
      "importDiscoveryInventory",
      { manifestPath: "m.json" },
    ],
    [
      "migrate_discovery_artifacts",
      {
        destination: "d",
        system_id: "s",
        system_name: "n",
        system_role: "combined",
        repository_id: "r",
        input_path: "legacy.yaml",
      },
      "migrateDiscoveryArtifacts",
      {
        destination: "d",
        systemId: "s",
        systemName: "n",
        systemRole: "combined",
        repositoryId: "r",
        inputPath: "legacy.yaml",
      },
    ],
    [
      "run_discovery_doctor",
      {},
      "runDiscoveryDoctor",
      { toolInputs: { workspace_root: WS } },
    ],
    [
      "read_discovery_source",
      { read_operation: "list", paths: ["src"] },
      "readDiscoverySource",
      { readOperation: "list", paths: ["src"] },
    ],
    [
      "prepare_discovery_agent",
      {
        skill_id: "inventory-legacy-system",
        selected_ids: ["a"],
        paths: ["src"],
        expected_outputs: [{ artifact_kind: "inventory-snapshot" }],
        execution_context: "standalone",
        complexity: "C2",
      },
      "prepareDiscoveryAgent",
      {
        skillId: "inventory-legacy-system",
        selectedIds: ["a"],
        paths: ["src"],
        expectedOutputs: [{ artifact_kind: "inventory-snapshot" }],
        executionContext: "standalone",
        complexity: "C2",
        toolInputs: {
          workspace_root: WS,
          skill_id: "inventory-legacy-system",
          selected_ids: ["a"],
          paths: ["src"],
          expected_outputs: [{ artifact_kind: "inventory-snapshot" }],
          execution_context: "standalone",
          complexity: "C2",
        },
      },
    ],
    [
      "finalize_discovery_agent",
      { invocation_ref: "invocation-alpha", request_id: "request-alpha" },
      "finalizeDiscoveryAgent",
      { invocationRef: "invocation-alpha", requestId: "request-alpha" },
    ],
  ];

  it.each(CASES)(
    "routes %s to its service method",
    async (tool, args, method, expected) => {
      const mock = service[method] as unknown as ServiceMock;
      mock.mockResolvedValue(success(tool));
      const result = await dispatchRepoAutomationTool(
        tool,
        { workspace_root: WS, ...args },
        service,
      );
      expect(mock).toHaveBeenCalledWith({ workspaceRoot: WS, ...expected });
      expect(result).toMatchObject({
        ok: true,
        tool,
        workspace_root: WS,
        summary: `did ${tool}`,
      });
    },
  );

  it("passes the typed discovery, invocation and receipt payloads through", async () => {
    const discovery = buildServiceResult({ operation: "doctor" });
    service.runDiscoveryDoctor.mockResolvedValue({
      ...success("run_discovery_doctor"),
      discovery,
    });
    const invocation = {
      invocation_id: "invocation-alpha",
      role: "legacy-parity-analyst",
      skill_id: "inventory-legacy-system",
      deployment: {
        provider: "codex",
        agent_name: "legacy-parity-analyst-c2",
        model: "m",
        reasoning_effort: "medium",
        profile_path: "p",
        profile_sha256: SHA,
        complexity: "C2",
        execution_context: "standalone",
      },
      mirror_path: "artifacts/discovery/invocations/invocation-alpha.json",
    };
    service.prepareDiscoveryAgent.mockResolvedValue({
      ...success("prepare_discovery_agent"),
      invocation,
    });
    const receipt = {
      receipt_ref: "receipt-alpha",
      validation_result: "pass" as const,
      output_valid: true,
      planning_authorized: true,
    };
    service.finalizeDiscoveryAgent.mockResolvedValue({
      ...success("finalize_discovery_agent"),
      receipt,
    });

    expect(
      (
        await dispatchRepoAutomationTool(
          "run_discovery_doctor",
          { workspace_root: WS },
          service,
        )
      ).discovery,
    ).toEqual(discovery);
    expect(
      (
        await dispatchRepoAutomationTool(
          "prepare_discovery_agent",
          {
            workspace_root: WS,
            skill_id: "inventory-legacy-system",
            selected_ids: [],
            paths: [],
            expected_outputs: [{}],
            execution_context: "standalone",
            complexity: "C1",
          },
          service,
        )
      ).invocation,
    ).toEqual(invocation);
    expect(
      (
        await dispatchRepoAutomationTool(
          "finalize_discovery_agent",
          { workspace_root: WS, invocation_ref: "i", request_id: "r" },
          service,
        )
      ).receipt,
    ).toEqual(receipt);
  });

  it("rejects invalid input before calling the service", async () => {
    const result = await dispatchRepoAutomationTool(
      "transfer_discovery_snapshot",
      { workspace_root: WS, direction: "sync" },
      service,
    );
    expect(result.ok).toBe(false);
    expect(result.summary).toMatch(/direction/);
    expect(service.transferDiscoverySnapshot).not.toHaveBeenCalled();
  });
});

describe("discovery tools over the MCP transport", () => {
  let client: Client;
  let service: MockService;
  let server: ReturnType<typeof createRepoAutomationMcpServer>;

  beforeEach(async () => {
    service = createMockService();
    server = createRepoAutomationMcpServer({ createService: () => service });
    client = new Client(
      { name: "test-client", version: "1.0.0" },
      { capabilities: {} },
    );
    const [clientTransport, serverTransport] =
      InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);
    await client.connect(clientTransport);
  });

  afterEach(async () => {
    await client.close();
    await server.close();
    jest.clearAllMocks();
  });

  it("lists every discovery tool", async () => {
    const listed = (await client.listTools()).tools.map((tool) => tool.name);
    for (const name of DISCOVERY_TOOL_DEFINITIONS.map((entry) => entry.name)) {
      expect(listed).toContain(name);
    }
  });

  it("returns agreeing text, structuredContent and isError on success and on denial", async () => {
    service.runDiscoveryDoctor.mockResolvedValue({
      ...success("run_discovery_doctor"),
      discovery: buildServiceResult({ operation: "doctor" }),
    });
    const ok = await client.callTool({
      name: "run_discovery_doctor",
      arguments: { workspace_root: WS },
    });
    const okText = (ok.content as Array<{ type: string; text: string }>)[0]!;
    expect(ok.isError).toBe(false);
    expect(JSON.parse(okText.text)).toEqual(ok.structuredContent);
    expect(ok.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_doctor",
    });

    service.consumeDiscoveryRootGrant!.mockImplementation(() => {
      throw new DiscoveryAuthorizationError(
        "DISCOVERY_HOST_BINDING_REQUIRED",
        "no root grant",
      );
    });
    const denied = await client.callTool({
      name: "read_discovery_source",
      arguments: { workspace_root: WS, read_operation: "list", paths: ["src"] },
    });
    const deniedText = (
      denied.content as Array<{ type: string; text: string }>
    )[0]!;
    expect(denied.isError).toBe(true);
    expect(JSON.parse(deniedText.text)).toEqual(denied.structuredContent);
    expect(denied.structuredContent).toMatchObject({
      ok: false,
      tool: "read_discovery_source",
    });
    expect((denied.structuredContent as { summary: string }).summary).toContain(
      "DISCOVERY_HOST_BINDING_REQUIRED",
    );
  });
});
