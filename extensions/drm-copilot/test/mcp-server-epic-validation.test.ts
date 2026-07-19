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

describe("repo automation MCP epic validation", () => {
  let client: Client;
  let service: jest.Mocked<RepoAutomationService>;
  let server: ReturnType<typeof createRepoAutomationMcpServer>;

  beforeEach(async () => {
    service = createMockService();
    server = createRepoAutomationMcpServer({
      createService: () => service,
    });
    client = new Client(
      {
        name: "test-client",
        version: "1.0.0",
      },
      {
        capabilities: {},
      },
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

  it("forwards epic planner execution-readiness validation through MCP", async () => {
    service.validateOrchestrationArtifacts.mockResolvedValue({
      tool: "validate_orchestration_artifacts",
      workspaceRoot: "C:/workspace",
      summary: "Validated execution-ready epic planner state.",
    });

    const result = await client.callTool({
      name: "validate_orchestration_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "epic-planner-state",
        artifact_path: "artifacts/orchestration/epic-planner-state.json",
        require_ready_for_execution: true,
      },
    });

    expect(service.validateOrchestrationArtifacts).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      artifactType: "epic-planner-state",
      artifactPath: "artifacts/orchestration/epic-planner-state.json",
      requireReadyForExecution: true,
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "validate_orchestration_artifacts",
      workspace_root: "C:/workspace",
    });
  });

  it("returns a validation error for an invalid artifact type", async () => {
    const result = await client.callTool({
      name: "validate_orchestration_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "invalid-type",
        artifact_path: "docs/plan.md",
      },
    });

    expect(service.validateOrchestrationArtifacts).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "validate_orchestration_artifacts",
    });
  });
});
