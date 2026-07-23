import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import type { RepoAutomationService } from "../src/repo-automation-service";

/**
 * Defect A dispatch-boundary coverage (AC-8): an omitted workspace_root surfaces
 * to MCP callers as a structured ok:false result through toFailureToolResult,
 * preserving the RepoAutomationMcpToolResult envelope shape and the actionable
 * required-field message. Kept in a dedicated file so the primary dispatch
 * suites stay under the 500-line limit.
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

describe("dispatchRepoAutomationTool workspace_root failure envelope (AC-8)", () => {
  it("returns ok:false with the actionable message when workspace_root is omitted", async () => {
    const mockService = createMockService();

    const result = await dispatchRepoAutomationTool(
      "potential_to_issue",
      {
        potential_path: "docs/potential/entry.md",
        promotion_type: "bug",
        work_mode: "full-bug",
      },
      mockService,
    );

    // The service handler is never invoked because the resolver fails closed.
    expect(mockService.potentialToIssue).not.toHaveBeenCalled();
    // Envelope shape preserved: ok, tool, workspace_root, summary.
    expect(result.ok).toBe(false);
    expect(result.tool).toBe("potential_to_issue");
    expect(typeof result.workspace_root).toBe("string");
    expect(result.summary).toContain("workspace_root is required");
  });
});
