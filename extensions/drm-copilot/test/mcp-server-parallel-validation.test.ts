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

/**
 * In-memory MCP round trip for the two parallel-orchestration artifact types.
 *
 * The transport pair exercises the real tool registration and input-resolution
 * path against a mocked service, so a call that reaches the service proves the
 * new artifact types are advertised, resolved, and forwarded end to end.
 */

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

describe("repo automation MCP parallel validation", () => {
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
    jest.resetAllMocks();
  });

  it("forwards parallel orchestrator completion validation through MCP", async () => {
    // Arrange
    service.validateOrchestrationArtifacts.mockResolvedValue({
      tool: "validate_orchestration_artifacts",
      workspaceRoot: "C:/workspace",
      summary: "Validated complete parallel orchestrator state.",
    });

    // Act
    const result = await client.callTool({
      name: "validate_orchestration_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "parallel-orchestrator-state",
        artifact_path:
          "artifacts/orchestration/parallel-orchestrator-state.json",
        require_complete: true,
      },
    });

    // Assert
    expect(service.validateOrchestrationArtifacts).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      artifactType: "parallel-orchestrator-state",
      artifactPath: "artifacts/orchestration/parallel-orchestrator-state.json",
      requireComplete: true,
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "validate_orchestration_artifacts",
      workspace_root: "C:/workspace",
    });
  });

  it("forwards parallel planner readiness validation through MCP", async () => {
    // Arrange
    service.validateOrchestrationArtifacts.mockResolvedValue({
      tool: "validate_orchestration_artifacts",
      workspaceRoot: "C:/workspace",
      summary: "Validated execution-ready parallel planner state.",
    });

    // Act
    const result = await client.callTool({
      name: "validate_orchestration_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "parallel-planner-state",
        artifact_path: "artifacts/orchestration/parallel-planner-state.json",
        require_ready_for_execution: true,
      },
    });

    // Assert
    expect(service.validateOrchestrationArtifacts).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      artifactType: "parallel-planner-state",
      artifactPath: "artifacts/orchestration/parallel-planner-state.json",
      requireReadyForExecution: true,
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "validate_orchestration_artifacts",
      workspace_root: "C:/workspace",
    });
  });

  it("returns a validation error for a parallel artifact type outside the allow-list", async () => {
    // Arrange / Act
    const result = await client.callTool({
      name: "validate_orchestration_artifacts",
      arguments: {
        workspace_root: "C:/workspace",
        artifact_type: "parallel-kickoff",
        artifact_path: "artifacts/orchestration/parallel-kickoff-demo.md",
      },
    });

    // Assert
    expect(service.validateOrchestrationArtifacts).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "validate_orchestration_artifacts",
    });
  });
});
