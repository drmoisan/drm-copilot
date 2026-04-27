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

describe("dispatchRepoAutomationTool run_codex_native_converter", () => {
  it("dispatches run_codex_native_converter through the dedicated handler", async () => {
    const mockService = createMockService();
    mockService.runCodexNativeConverter.mockResolvedValue({
      tool: "run_codex_native_converter",
      workspaceRoot: "C:/workspace",
      artifacts: ["C:/workspace/artifacts/codex-native-converter"],
      summary:
        "Ran bundled codex-native-converter in review mode for 'github-copilot'.",
    });

    const result = await dispatchRepoAutomationTool(
      "run_codex_native_converter",
      {
        workspace_root: "C:/workspace",
        mode: "review",
        source_ecosystem: "github-copilot",
        source_root: "fixtures/source",
      },
      mockService,
    );

    expect(mockService.runCodexNativeConverter).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: "C:/workspace/fixtures/source",
    });
    expect(result.ok).toBe(true);
    expect(result.tool).toBe("run_codex_native_converter");
  });
});
