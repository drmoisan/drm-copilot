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

// Spy on terminal creation so the discovery MCP dispatch path can be asserted to
// never create a terminal (it uses the buffered in-memory sink).
const mockCreateTerminal = jest.fn();
jest.mock(
  "vscode",
  () => ({ window: { createTerminal: mockCreateTerminal } }),
  { virtual: true },
);

import { createRepoAutomationMcpServer } from "../src/mcp-server";
import type { RepoAutomationService } from "../src/repo-automation-service";

function createMockService(): jest.Mocked<RepoAutomationService> {
  return {
    collectCommitContext: jest.fn(),
    collectPrContext: jest.fn(),
    runCodexNativeConverter: jest.fn(),
    pushDownCopilotCustomizations: jest.fn(),
    pushDownCodexAndAgentsCustomizations: jest.fn(),
    pushDownClaudeCustomizations: jest.fn(),
    newPotentialBugEntry: jest.fn(),
    newPotentialEntry: jest.fn(),
    linkParentChild: jest.fn(),
    potentialToIssue: jest.fn(),
    newActiveFeatureFolder: jest.fn(),
    runPoshQCFormat: jest.fn(),
    runPoshQCAnalyze: jest.fn(),
    runPoshQCTest: jest.fn(),
    runPoshQCAnalyzeAutofix: jest.fn(),
    runPoshQCSuite: jest.fn(),
    resolvePolicyAuditTemplateAsset: jest.fn(),
    resolveExecuteHardLockPrompt: jest.fn(),
    resolveAtomicPlanPrompt: jest.fn(),
    validateOrchestrationArtifacts: jest.fn(),
    renderSubagentTree: jest.fn(),
    validateDiscoveryArtifacts: jest.fn(),
    runDiscoveryInit: jest.fn(),
    runDiscoveryRepoInventory: jest.fn(),
    runDiscoveryDotnetAnalyzer: jest.fn(),
    runDiscoveryVstoAnalyzer: jest.fn(),
    runDiscoveryScenarioGeneration: jest.fn(),
    runDiscoveryReport: jest.fn(),
  };
}

describe("discovery tools over the MCP server transport", () => {
  let client: Client;
  let service: jest.Mocked<RepoAutomationService>;
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

  it("dispatches validate_discovery_artifacts with normalized input", async () => {
    service.validateDiscoveryArtifacts.mockResolvedValue({
      tool: "validate_discovery_artifacts",
      workspaceRoot: "C:/workspace",
      summary:
        "Validated discovery artifact 'p.yaml' as artifact type 'profile'.",
    });

    const result = await client.callTool({
      name: "validate_discovery_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "profile",
        artifact_path: "p.yaml",
      },
    });

    expect(service.validateDiscoveryArtifacts).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      artifactType: "profile",
      artifactPath: "p.yaml",
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "validate_discovery_artifacts",
      workspace_root: "C:/workspace",
    });
  });

  it("dispatches run_discovery_init with normalized input", async () => {
    service.runDiscoveryInit.mockResolvedValue({
      tool: "run_discovery_init",
      workspaceRoot: "C:/workspace",
      summary: "Initialized the discovery workspace at 'discovery'.",
    });

    const result = await client.callTool({
      name: "run_discovery_init",
      arguments: { workspace_root: "C:/workspace", target_dir: "discovery" },
    });

    expect(service.runDiscoveryInit).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      targetDir: "discovery",
    });
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_init",
    });
  });

  it("dispatches run_discovery_repo_inventory returning parsed artifacts", async () => {
    service.runDiscoveryRepoInventory.mockResolvedValue({
      tool: "run_discovery_repo_inventory",
      workspaceRoot: "C:/workspace",
      summary: "Generated the repository inventory discovery analysis.",
      artifacts: ["C:/workspace/discovery/inventory.json"],
    });

    const result = await client.callTool({
      name: "run_discovery_repo_inventory",
      arguments: { workspace_root: "C:/workspace" },
    });

    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_repo_inventory",
      artifacts: ["C:/workspace/discovery/inventory.json"],
    });
  });

  it("dispatches run_discovery_dotnet_analyzer with normalized input", async () => {
    service.runDiscoveryDotnetAnalyzer.mockResolvedValue({
      tool: "run_discovery_dotnet_analyzer",
      workspaceRoot: "C:/workspace",
      summary: "Generated the .NET stack discovery analysis.",
    });

    const result = await client.callTool({
      name: "run_discovery_dotnet_analyzer",
      arguments: { workspace_root: "C:/workspace", profile_path: "p.yaml" },
    });

    expect(service.runDiscoveryDotnetAnalyzer).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      profilePath: "p.yaml",
    });
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_dotnet_analyzer",
    });
  });

  it("dispatches run_discovery_vsto_analyzer", async () => {
    service.runDiscoveryVstoAnalyzer.mockResolvedValue({
      tool: "run_discovery_vsto_analyzer",
      workspaceRoot: "C:/workspace",
      summary: "Generated the VSTO stack discovery analysis.",
    });

    const result = await client.callTool({
      name: "run_discovery_vsto_analyzer",
      arguments: { workspace_root: "C:/workspace" },
    });

    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_vsto_analyzer",
    });
  });

  it("dispatches run_discovery_scenario_generation with the three inputs", async () => {
    service.runDiscoveryScenarioGeneration.mockResolvedValue({
      tool: "run_discovery_scenario_generation",
      workspaceRoot: "C:/workspace",
      summary: "Generated discovery acceptance scenarios.",
    });

    const result = await client.callTool({
      name: "run_discovery_scenario_generation",
      arguments: {
        workspace_root: "C:/workspace",
        feature_contract: "fc.yaml",
        parity_matrix: "pm.yaml",
        runtime_characterization: "rc.yaml",
      },
    });

    expect(service.runDiscoveryScenarioGeneration).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      featureContract: "fc.yaml",
      parityMatrix: "pm.yaml",
      runtimeCharacterization: "rc.yaml",
    });
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_scenario_generation",
    });
  });

  it("dispatches run_discovery_report", async () => {
    service.runDiscoveryReport.mockResolvedValue({
      tool: "run_discovery_report",
      workspaceRoot: "C:/workspace",
      summary: "Generated the 'parity' discovery report.",
    });

    const result = await client.callTool({
      name: "run_discovery_report",
      arguments: {
        workspace_root: "C:/workspace",
        report_type: "parity",
        input_path: "discovery/parity-matrix.yaml",
      },
    });

    expect(service.runDiscoveryReport).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      reportType: "parity",
      inputPath: "discovery/parity-matrix.yaml",
    });
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_discovery_report",
    });
  });

  it("rejects an out-of-enum report_type before the service", async () => {
    const result = await client.callTool({
      name: "run_discovery_report",
      arguments: {
        workspace_root: "C:/workspace",
        report_type: "bogus",
        input_path: "x",
      },
    });

    expect(service.runDiscoveryReport).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "run_discovery_report",
    });
  });

  it("rejects an out-of-enum artifact_type before the service", async () => {
    const result = await client.callTool({
      name: "validate_discovery_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "not-a-kind",
        artifact_path: "p.yaml",
      },
    });

    expect(service.validateDiscoveryArtifacts).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "validate_discovery_artifacts",
    });
  });

  it("creates no terminal on the discovery MCP dispatch path (buffered sink only)", async () => {
    service.runDiscoveryReport.mockResolvedValue({
      tool: "run_discovery_report",
      workspaceRoot: "C:/workspace",
      summary: "Generated the 'coverage' discovery report.",
    });

    await client.callTool({
      name: "run_discovery_report",
      arguments: {
        workspace_root: "C:/workspace",
        report_type: "coverage",
        input_path: "ledger.json",
      },
    });

    expect(mockCreateTerminal).not.toHaveBeenCalled();
  });
});
