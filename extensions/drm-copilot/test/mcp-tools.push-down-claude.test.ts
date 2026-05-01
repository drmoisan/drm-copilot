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
});
