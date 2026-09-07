import { jest } from "@jest/globals";
import * as path from "node:path";

import type { RepoAutomationService } from "../src/repo-automation-service";

/**
 * Absolute workspace root shared by every MCP fixture, derived at run time
 * rather than written as a drive-letter literal. A drive-letter literal is
 * absolute on Windows and relative on POSIX, so the handoff handler's
 * `path.isAbsolute` guards reject it on Linux. Resolving a relative virtual
 * name yields a root that is absolute on both platforms.
 */
export const VIRTUAL_WORKSPACE_ROOT = path
  .resolve("virtual-workspace")
  .replaceAll("\\", "/");

/**
 * Joins a repository-relative path onto {@link VIRTUAL_WORKSPACE_ROOT} with a
 * single forward slash, producing the same absolute path the production
 * modules derive for that repository-relative input.
 */
export function workspacePath(repositoryPath: string): string {
  return `${VIRTUAL_WORKSPACE_ROOT}/${repositoryPath}`;
}

/**
 * Artifact path reported by the Codex-and-agents push-down fixture. It is
 * named here so the long composite literal lives in this module rather than in
 * `mcp-server.test.ts`, which has little line headroom.
 */
export const PUSH_DOWN_CODEX_ARTIFACT_PATH = workspacePath(
  "artifacts/codex-and-agents-customizations/push-down-20260405T174500Z.json",
);

/** Create a fully mocked MCP service while retaining optional handoff seams. */
export function createMockService(): jest.Mocked<RepoAutomationService> {
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
    transitionPreparedOrchestration: jest.fn(),
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

/** Return one exact portable transition request/result mapping for MCP tests. */
export function createPreparedTransitionCase() {
  const sourceSha256 = "a".repeat(64);
  const envelopeSha256 = "b".repeat(64);
  const destinationSha256 = "c".repeat(64);
  const request = {
    workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
    sourceCheckpointPath: "artifacts/orchestration/orchestrator-state.json",
    expectedSourceCheckpointSha256: sourceSha256,
    handoffEnvelopePath: "artifacts/orchestration/handoffs/handoff.json",
    expectedHandoffEnvelopeSha256: envelopeSha256,
    destinationProvider: "codex",
    mode: "materialize",
  } as const;
  return {
    arguments: {
      workspace_root: request.workspaceRoot,
      source_checkpoint_path: request.sourceCheckpointPath,
      expected_source_checkpoint_sha256: sourceSha256,
      handoff_envelope_path: request.handoffEnvelopePath,
      expected_handoff_envelope_sha256: envelopeSha256,
      destination_provider: request.destinationProvider,
      mode: request.mode,
    },
    request,
    result: {
      status: "materialized",
      handoffId: "handoff-614",
      sourceCheckpointSha256: sourceSha256,
      handoffEnvelopeSha256: envelopeSha256,
      handoffHistorySha256: "d".repeat(64),
      requestedTransition: "prepared_to_atomic_execution",
      destinationCheckpointPath: request.sourceCheckpointPath,
      destinationCheckpointSha256: destinationSha256,
      primaryFailureCode: null,
      affectedPaths: [],
      unsupportedCapabilities: [],
    } as const,
    expectedMcpResult: {
      ok: true,
      tool: "transition_prepared_orchestration",
      status: "materialized",
      source_checkpoint_sha256: sourceSha256,
      destination_checkpoint_sha256: destinationSha256,
      primary_failure_code: null,
    },
  };
}
