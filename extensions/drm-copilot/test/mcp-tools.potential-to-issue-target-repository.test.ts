import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../src/repo-automation-service";

/**
 * Result-projection coverage for the resolved target repository (spec AC-7).
 *
 * The projection helper in `mcp-tools.ts` is not exported, so the only way to
 * observe the snake-cased MCP field is to dispatch a repo-automation tool
 * against a mocked service and inspect the dispatched result. These cases
 * therefore exercise the full projection chain rather than the service-call
 * return alone.
 */

/** Workspace root supplied to every dispatch below. */
const WORKSPACE_ROOT = "C:/workspace";

/** Slug the mocked promotion result carries. */
const TARGET_REPOSITORY = "drmoisan/drm-copilot";

/**
 * Build a fully-stubbed {@link RepoAutomationService}.
 *
 * @returns A mocked service whose every method is an unconfigured jest mock.
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

describe("dispatchRepoAutomationTool target-repository projection", () => {
  it("projects the target repository onto the potential to issue MCP result", async () => {
    // Arrange: the promotion result carries the resolved slug.
    const mockService = createMockService();
    const executionResult: RepoAutomationExecutionResult = {
      tool: "potential_to_issue",
      workspaceRoot: WORKSPACE_ROOT,
      summary: "Promoted potential entry to issue #123.",
      targetRepository: TARGET_REPOSITORY,
    };
    mockService.potentialToIssue.mockResolvedValue(executionResult);

    // Act
    const result = await dispatchRepoAutomationTool(
      "potential_to_issue",
      {
        workspace_root: WORKSPACE_ROOT,
        potential_path: "docs/features/potential/entry.md",
        promotion_type: "feature",
        work_mode: "full-feature",
      },
      mockService,
    );

    // Assert: the snake-cased key carries the same value through the full
    // projection chain, and the envelope is otherwise intact.
    expect(result.ok).toBe(true);
    expect(result.tool).toBe("potential_to_issue");
    expect(result.target_repository).toBe(TARGET_REPOSITORY);
  });

  it("omits the target repository key for tools that resolve none", async () => {
    // Arrange: a different repo-automation tool whose result resolves no
    // repository, so the optional field must not be projected at all.
    const mockService = createMockService();
    const executionResult: RepoAutomationExecutionResult = {
      tool: "new_potential_entry",
      workspaceRoot: WORKSPACE_ROOT,
      summary: "Created potential entry.",
      artifacts: ["docs/features/potential/entry.md"],
    };
    mockService.newPotentialEntry.mockResolvedValue(executionResult);

    // Act
    const result = await dispatchRepoAutomationTool(
      "new_potential_entry",
      { workspace_root: WORKSPACE_ROOT, short_name: "entry" },
      mockService,
    );

    // Assert: the key is absent rather than present-and-undefined, and every
    // other projected key is unchanged.
    expect("target_repository" in result).toBe(false);
    expect(result).toEqual({
      ok: true,
      tool: "new_potential_entry",
      workspace_root: WORKSPACE_ROOT,
      summary: "Created potential entry.",
      artifacts: ["docs/features/potential/entry.md"],
    });
  });
});
