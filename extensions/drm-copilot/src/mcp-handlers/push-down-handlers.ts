import {
  resolvePushDownClaudeCustomizationsToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
  resolvePushDownCopilotCustomizationsToolInput,
} from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handlePushDownCopilotCustomizations(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolvePushDownCopilotCustomizationsToolInput(rawInput);
  return service.pushDownCopilotCustomizations(input);
}

export async function handlePushDownCodexAndAgentsCustomizations(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolvePushDownCodexAndAgentsCustomizationsToolInput(rawInput);
  return service.pushDownCodexAndAgentsCustomizations(input);
}

export async function handlePushDownClaudeCustomizations(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolvePushDownClaudeCustomizationsToolInput(rawInput);
  return service.pushDownClaudeCustomizations(input);
}
