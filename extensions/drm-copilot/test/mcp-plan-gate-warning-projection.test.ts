import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import { toolDefinitions } from "../src/mcp-tool-definitions";
import type { RepoAutomationService } from "../src/repo-automation-service";
import type { RepoAutomationExecutionResult } from "../src/repo-automation-service-contract";

/**
 * The `validate_orchestration_artifacts` input-schema property keys, asserted
 * unchanged by spec AC4. The schema is duplicated across two modules, so both
 * are asserted; checking one would leave the other unguarded.
 */
const EXPECTED_SCHEMA_KEYS = [
  "workspace_root",
  "artifact_type",
  "artifact_path",
  "require_complete",
  "require_pr_creation_ready",
  "require_model_routing",
  "require_codex_model_routing",
  "require_codex_topology",
  "require_ready_for_execution",
];

/** Build a service double whose every method is an unused Jest mock. */
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

/** Dispatch the validation tool against a stubbed service result. */
async function dispatchWith(
  result: RepoAutomationExecutionResult,
): Promise<Record<string, unknown>> {
  const service = createMockService();
  service.validateOrchestrationArtifacts.mockResolvedValue(result);
  return dispatchRepoAutomationTool(
    "validate_orchestration_artifacts",
    {
      workspace_root: "C:/workspace",
      artifact_type: "plan",
      artifact_path: "docs/plan.md",
    },
    service,
  );
}

describe("MCP plan-gate warning projection", () => {
  it("projects the warnings field when present", async () => {
    // Arrange / Act
    const projected = await dispatchWith({
      tool: "validate_orchestration_artifacts",
      workspaceRoot: "C:/workspace",
      summary: "Validated plan artifact at 'docs/plan.md'.",
      warnings: ["[P1-T1] advisory finding"],
    });

    // Assert
    expect(projected["warnings"]).toEqual(["[P1-T1] advisory finding"]);
    expect(projected["ok"]).toBe(true);
  });

  it("omits the warnings field when absent", async () => {
    // Arrange / Act
    const projected = await dispatchWith({
      tool: "validate_orchestration_artifacts",
      workspaceRoot: "C:/workspace",
      summary: "Validated plan artifact at 'docs/plan.md'.",
    });

    // Assert: the own-property list is byte-identical to the pre-change shape.
    expect(Object.keys(projected)).toEqual([
      "ok",
      "tool",
      "workspace_root",
      "summary",
    ]);
  });

  it("keeps the validate_orchestration_artifacts input-schema property-key set unchanged", () => {
    // Arrange: the schema lives in both `src/mcp-repo-automation-tool-definitions.ts`
    // and `src/mcp-tool-definitions.ts`, so both modules are asserted.
    const definitions = [
      REPO_AUTOMATION_TOOL_DEFINITIONS.find(
        ({ name }) => name === "validate_orchestration_artifacts",
      ),
      toolDefinitions.find(
        ({ name }) => name === "validate_orchestration_artifacts",
      ),
    ];

    // Act / Assert
    expect(definitions.filter((entry) => entry !== undefined)).toHaveLength(2);
    for (const definition of definitions) {
      const schema = definition?.inputSchema as
        { properties?: Record<string, unknown> } | undefined;
      expect(Object.keys(schema?.properties ?? {})).toEqual(
        EXPECTED_SCHEMA_KEYS,
      );
    }
  });
});
