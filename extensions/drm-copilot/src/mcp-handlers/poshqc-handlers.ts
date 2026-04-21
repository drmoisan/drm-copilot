import { resolveRunPoshQCSuiteToolInput } from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handleRunPoshQCFormat(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunPoshQCSuiteToolInput(rawInput);
  return service.runPoshQCFormat(input);
}

export async function handleRunPoshQCAnalyze(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunPoshQCSuiteToolInput(rawInput);
  return service.runPoshQCAnalyze(input);
}

export async function handleRunPoshQCTest(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunPoshQCSuiteToolInput(rawInput);
  return service.runPoshQCTest(input);
}

export async function handleRunPoshQCAnalyzeAutofix(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunPoshQCSuiteToolInput(rawInput);
  return service.runPoshQCAnalyzeAutofix(input);
}

export async function handleRunPoshQCSuite(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunPoshQCSuiteToolInput(rawInput);
  return service.runPoshQCSuite(input);
}
