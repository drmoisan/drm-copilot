import {
  resolveCollectCommitContextToolInput,
  resolveCollectPrContextToolInput,
} from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handleCollectCommitContext(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveCollectCommitContextToolInput(rawInput);
  return service.collectCommitContext(input);
}

export async function handleCollectPrContext(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveCollectPrContextToolInput(rawInput);
  return service.collectPrContext(input);
}
