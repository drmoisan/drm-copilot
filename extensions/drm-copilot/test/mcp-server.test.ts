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

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationMcpServer } from "../src/mcp-server";
import type { RepoAutomationService } from "../src/repo-automation-service";

function createMockService(): jest.Mocked<RepoAutomationService> {
  return {
    collectCommitContext: jest.fn(),
    collectPrContext: jest.fn(),
    pushDownCopilotCustomizations: jest.fn(),
    newPotentialBugEntry: jest.fn(),
    newPotentialEntry: jest.fn(),
    potentialToIssue: jest.fn(),
    newActiveFeatureFolder: jest.fn(),
    resolveExecuteHardLockPrompt: jest.fn(),
  };
}

describe("repo automation MCP server", () => {
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

  it("registers the semantic repo automation tools", async () => {
    const result = await client.listTools();

    expect(result.tools.map((tool) => tool.name)).toEqual([
      "collect_commit_context",
      "collect_pr_context",
      "push_down_copilot_customizations",
      "new_potential_bug_entry",
      "new_potential_entry",
      "potential_to_issue",
      "new_active_feature_folder",
      "resolve_execute_hard_lock_prompt",
    ]);
  });

  it("dispatches collect_pr_context through the shared service with an explicit base", async () => {
    service.collectPrContext.mockResolvedValue({
      tool: "collect_pr_context",
      workspaceRoot: "C:/workspace",
      artifacts: [
        "C:/workspace/artifacts/pr_context.summary.txt",
        "C:/workspace/artifacts/pr_context.appendix.txt",
      ],
      summary: "Collected PR context against base 'origin/main'.",
    });

    const result = await client.callTool({
      name: "collect_pr_context",
      arguments: {
        workspace_root: "C:/workspace",
        base: "origin/main",
      },
    });

    expect(service.collectPrContext).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      base: "origin/main",
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "collect_pr_context",
      workspace_root: "C:/workspace",
      artifacts: [
        "C:/workspace/artifacts/pr_context.summary.txt",
        "C:/workspace/artifacts/pr_context.appendix.txt",
      ],
    });
  });

  it("returns validation failures without calling the shared service", async () => {
    const result = await client.callTool({
      name: "collect_pr_context",
      arguments: {
        workspace_root: "C:/workspace",
      },
    });

    expect(service.collectPrContext).not.toHaveBeenCalled();
    expect(result.isError).toBe(true);
    expect(result.structuredContent).toMatchObject({
      ok: false,
      tool: "collect_pr_context",
      workspace_root: "C:/workspace",
      summary: "Field 'base' must be a string.",
    });
  });

  it("defaults workspace_root to process.cwd() when omitted", async () => {
    service.collectCommitContext.mockResolvedValue({
      tool: "collect_commit_context",
      workspaceRoot: process.cwd(),
      artifacts: [`${process.cwd()}/artifacts/commit_context.txt`],
      summary: "Collected commit context into artifacts/commit_context.txt.",
    });

    const result = await client.callTool({
      name: "collect_commit_context",
      arguments: {},
    });

    expect(service.collectCommitContext).toHaveBeenCalledWith({
      workspaceRoot: process.cwd(),
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "collect_commit_context",
      workspace_root: process.cwd(),
    });
  });
});
