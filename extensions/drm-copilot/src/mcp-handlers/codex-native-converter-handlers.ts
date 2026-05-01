import { resolveRunCodexNativeConverterToolInput } from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handleRunCodexNativeConverter(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunCodexNativeConverterToolInput(rawInput);
  return service.runCodexNativeConverter(input);
}
