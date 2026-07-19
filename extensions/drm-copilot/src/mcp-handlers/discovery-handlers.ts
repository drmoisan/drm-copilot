import {
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  resolveRunDiscoveryInitToolInput,
  resolveRunDiscoveryReportToolInput,
  resolveRunDiscoveryRepoInventoryToolInput,
  resolveRunDiscoveryScenarioGenerationToolInput,
  resolveRunDiscoveryVstoAnalyzerToolInput,
  resolveValidateDiscoveryArtifactsToolInput,
} from "../mcp-tool-inputs-discovery";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handleValidateDiscoveryArtifacts(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveValidateDiscoveryArtifactsToolInput(rawInput);
  return service.validateDiscoveryArtifacts(input);
}

export async function handleRunDiscoveryInit(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunDiscoveryInitToolInput(rawInput);
  return service.runDiscoveryInit(input);
}

export async function handleRunDiscoveryRepoInventory(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunDiscoveryRepoInventoryToolInput(rawInput);
  return service.runDiscoveryRepoInventory(input);
}

export async function handleRunDiscoveryDotnetAnalyzer(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunDiscoveryDotnetAnalyzerToolInput(rawInput);
  return service.runDiscoveryDotnetAnalyzer(input);
}

export async function handleRunDiscoveryVstoAnalyzer(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunDiscoveryVstoAnalyzerToolInput(rawInput);
  return service.runDiscoveryVstoAnalyzer(input);
}

export async function handleRunDiscoveryScenarioGeneration(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunDiscoveryScenarioGenerationToolInput(rawInput);
  return service.runDiscoveryScenarioGeneration(input);
}

export async function handleRunDiscoveryReport(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunDiscoveryReportToolInput(rawInput);
  return service.runDiscoveryReport(input);
}
