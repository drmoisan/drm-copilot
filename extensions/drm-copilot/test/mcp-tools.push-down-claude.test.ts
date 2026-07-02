import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
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
  };
}

describe("dispatchRepoAutomationTool push_down_claude_customizations", () => {
  it("invokes mockService.pushDownClaudeCustomizations exactly once and returns a successful result with the correct tool name", async () => {
    const mockService = createMockService();
    mockService.pushDownClaudeCustomizations.mockResolvedValue({
      tool: "push_down_claude_customizations",
      workspaceRoot: "/dest",
      artifacts: [],
      summary: "Pushed bundled Claude Code customizations.",
    });

    const result = await dispatchRepoAutomationTool(
      "push_down_claude_customizations",
      { workspace_root: "/dest" },
      mockService,
    );

    // The service method must be called exactly once.
    expect(mockService.pushDownClaudeCustomizations).toHaveBeenCalledTimes(1);
    expect(mockService.pushDownClaudeCustomizations).toHaveBeenCalledWith({
      workspaceRoot: "/dest",
    });
    expect(result.ok).toBe(true);
    expect(result.tool).toBe("push_down_claude_customizations");
  });

  it("forwards packs, csharp_variant, and memory_mode through dispatch", async () => {
    const mockService = createMockService();
    mockService.pushDownClaudeCustomizations.mockResolvedValue({
      tool: "push_down_claude_customizations",
      workspaceRoot: "/dest",
      artifacts: [],
      summary: "Pushed bundled Claude Code customizations.",
    });

    await dispatchRepoAutomationTool(
      "push_down_claude_customizations",
      {
        workspace_root: "/dest",
        packs: ["core", "csharp"],
        csharp_variant: "legacy",
        memory_mode: "skip",
      },
      mockService,
    );

    expect(mockService.pushDownClaudeCustomizations).toHaveBeenCalledWith({
      workspaceRoot: "/dest",
      packs: ["core", "csharp"],
      csharpVariant: "legacy",
      memoryMode: "skip",
    });
  });
});

describe("dispatchRepoAutomationTool push_down_codex_and_agents_customizations", () => {
  it("forwards packs, csharp_variant, and memory_mode through dispatch", async () => {
    const mockService = createMockService();
    mockService.pushDownCodexAndAgentsCustomizations.mockResolvedValue({
      tool: "push_down_codex_and_agents_customizations",
      workspaceRoot: "/dest",
      artifacts: [],
      summary: "Pushed bundled Codex and agents customizations.",
    });

    await dispatchRepoAutomationTool(
      "push_down_codex_and_agents_customizations",
      {
        workspace_root: "/dest",
        packs: ["core", "csharp"],
        csharp_variant: "legacy",
        memory_mode: "skip",
      },
      mockService,
    );

    expect(
      mockService.pushDownCodexAndAgentsCustomizations,
    ).toHaveBeenCalledWith({
      workspaceRoot: "/dest",
      packs: ["core", "csharp"],
      csharpVariant: "legacy",
      memoryMode: "skip",
    });
  });
});

describe("push_down_claude_customizations tool schema", () => {
  function findClaudeSchema(definitions: typeof toolDefinitions) {
    const definition = definitions.find(
      (tool) => tool.name === "push_down_claude_customizations",
    );
    if (definition === undefined) {
      throw new Error("push_down_claude_customizations definition missing.");
    }
    return definition.inputSchema;
  }

  it("adds optional packs, csharp_variant, and memory_mode without a required array", () => {
    const schema = findClaudeSchema(toolDefinitions);
    const properties = schema.properties as Record<string, unknown>;

    expect(properties["workspace_root"]).toBeDefined();
    expect(properties["packs"]).toBeDefined();
    expect(properties["csharp_variant"]).toBeDefined();
    expect(properties["memory_mode"]).toBeDefined();
    // No field is required; a workspace_root-only invocation stays valid.
    expect(
      (schema as { required?: ReadonlyArray<string> }).required,
    ).toBeUndefined();
    // additionalProperties is retained as false.
    expect(schema.additionalProperties).toBe(false);
  });

  it("keeps both MCP tool definition files in sync for this tool", () => {
    const primary = findClaudeSchema(toolDefinitions);
    const repoAutomation = findClaudeSchema(REPO_AUTOMATION_TOOL_DEFINITIONS);

    // Both definition files must carry identical schemas to avoid drift.
    expect(repoAutomation).toStrictEqual(primary);
  });
});

describe("push_down_codex_and_agents_customizations tool schema", () => {
  function findCodexSchema(definitions: typeof toolDefinitions) {
    const definition = definitions.find(
      (tool) => tool.name === "push_down_codex_and_agents_customizations",
    );
    if (definition === undefined) {
      throw new Error(
        "push_down_codex_and_agents_customizations definition missing.",
      );
    }
    return definition.inputSchema;
  }

  it("adds optional packs, csharp_variant, and memory_mode with no required array", () => {
    const schema = findCodexSchema(toolDefinitions);
    const properties = schema.properties as Record<string, unknown>;

    expect(properties["workspace_root"]).toBeDefined();
    expect(properties["packs"]).toBeDefined();
    expect(properties["csharp_variant"]).toBeDefined();
    expect(properties["memory_mode"]).toBeDefined();
    expect(
      (schema as { required?: ReadonlyArray<string> }).required,
    ).toBeUndefined();
    expect(schema.additionalProperties).toBe(false);
  });

  it("keeps both MCP tool definition files in sync for this tool", () => {
    const primary = findCodexSchema(toolDefinitions);
    const repoAutomation = findCodexSchema(REPO_AUTOMATION_TOOL_DEFINITIONS);

    expect(repoAutomation).toStrictEqual(primary);
  });
});
