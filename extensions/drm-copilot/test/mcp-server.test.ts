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
    pushDownCodexAndAgentsCustomizations: jest.fn(),
    newPotentialBugEntry: jest.fn(),
    newPotentialEntry: jest.fn(),
    potentialToIssue: jest.fn(),
    newActiveFeatureFolder: jest.fn(),
    runPoshQCFormat: jest.fn(),
    runPoshQCAnalyze: jest.fn(),
    runPoshQCTest: jest.fn(),
    runPoshQCAnalyzeAutofix: jest.fn(),
    runPoshQCSuite: jest.fn(),
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
      "push_down_codex_and_agents_customizations",
      "new_potential_bug_entry",
      "new_potential_entry",
      "potential_to_issue",
      "new_active_feature_folder",
      "run_poshqc_format",
      "run_poshqc_analyze",
      "run_poshqc_test",
      "run_poshqc_analyze_autofix",
      "run_poshqc_suite",
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

  it("dispatches push_down_codex_and_agents_customizations through the shared service", async () => {
    service.pushDownCodexAndAgentsCustomizations.mockResolvedValue({
      tool: "push_down_codex_and_agents_customizations",
      workspaceRoot: "C:/workspace",
      artifacts: [
        "C:/workspace/artifacts/codex-and-agents-customizations/push-down-20260405T174500Z.json",
      ],
      summary:
        "Pushed bundled Codex and agents customizations into the destination workspace.",
    });

    const result = await client.callTool({
      name: "push_down_codex_and_agents_customizations",
      arguments: {
        workspace_root: "C:/workspace",
      },
    });

    expect(service.pushDownCodexAndAgentsCustomizations).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "push_down_codex_and_agents_customizations",
      workspace_root: "C:/workspace",
      artifacts: [
        "C:/workspace/artifacts/codex-and-agents-customizations/push-down-20260405T174500Z.json",
      ],
    });
  });

  it("dispatches run_poshqc_suite through the shared service with scan folders", async () => {
    service.runPoshQCSuite.mockResolvedValue({
      tool: "run_poshqc_suite",
      workspaceRoot: "C:/workspace",
      summary:
        "Ran the bundled PoshQC suite against 'C:/workspace' with 2 selected scan folder(s).",
    });

    const result = await client.callTool({
      name: "run_poshqc_suite",
      arguments: {
        workspace_root: "C:/workspace",
        scan_folders: ["C:/workspace/src", "C:/workspace/tests/powershell"],
      },
    });

    expect(service.runPoshQCSuite).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      scanFolders: ["C:/workspace/src", "C:/workspace/tests/powershell"],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_suite",
      workspace_root: "C:/workspace",
    });
  });

  it("dispatches run_poshqc_format through the shared service with scan folders", async () => {
    service.runPoshQCFormat.mockResolvedValue({
      tool: "run_poshqc_format",
      workspaceRoot: "C:/workspace",
      summary:
        "Ran bundled PoshQC format against 'C:/workspace' with 1 selected scan folder(s).",
    });

    const result = await client.callTool({
      name: "run_poshqc_format",
      arguments: {
        workspace_root: "C:/workspace",
        scan_folders: ["C:/workspace/src"],
      },
    });

    expect(service.runPoshQCFormat).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      scanFolders: ["C:/workspace/src"],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_format",
      workspace_root: "C:/workspace",
    });
  });

  it("dispatches run_poshqc_analyze through the shared service with scan folders", async () => {
    service.runPoshQCAnalyze.mockResolvedValue({
      tool: "run_poshqc_analyze",
      workspaceRoot: "C:/workspace",
      summary:
        "Ran bundled PoshQC analyze against 'C:/workspace' with 1 selected scan folder(s).",
    });

    const result = await client.callTool({
      name: "run_poshqc_analyze",
      arguments: {
        workspace_root: "C:/workspace",
        scan_folders: ["C:/workspace/src"],
      },
    });

    expect(service.runPoshQCAnalyze).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      scanFolders: ["C:/workspace/src"],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_analyze",
      workspace_root: "C:/workspace",
    });
  });

  it("dispatches run_poshqc_test through the shared service with scan folders", async () => {
    service.runPoshQCTest.mockResolvedValue({
      tool: "run_poshqc_test",
      workspaceRoot: "C:/workspace",
      summary:
        "Ran bundled PoshQC test against 'C:/workspace' with 1 selected scan folder(s).",
    });

    const result = await client.callTool({
      name: "run_poshqc_test",
      arguments: {
        workspace_root: "C:/workspace",
        scan_folders: ["C:/workspace/tests/powershell"],
      },
    });

    expect(service.runPoshQCTest).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      scanFolders: ["C:/workspace/tests/powershell"],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_test",
      workspace_root: "C:/workspace",
    });
  });

  it("dispatches run_poshqc_analyze_autofix through the shared service with scan folders", async () => {
    service.runPoshQCAnalyzeAutofix.mockResolvedValue({
      tool: "run_poshqc_analyze_autofix",
      workspaceRoot: "C:/workspace",
      summary:
        "Ran bundled PoshQC analyze autofix against 'C:/workspace' with 1 selected scan folder(s).",
    });

    const result = await client.callTool({
      name: "run_poshqc_analyze_autofix",
      arguments: {
        workspace_root: "C:/workspace",
        scan_folders: ["C:/workspace/src"],
      },
    });

    expect(service.runPoshQCAnalyzeAutofix).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      scanFolders: ["C:/workspace/src"],
    });
    expect(result.isError).toBe(false);
    expect(result.structuredContent).toMatchObject({
      ok: true,
      tool: "run_poshqc_analyze_autofix",
      workspace_root: "C:/workspace",
    });
  });
});
