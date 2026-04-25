import { resolveResolveExecuteHardLockPromptToolInput } from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export const DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH =
  "artifacts/hard_lock_prompt.txt";

export async function handleResolveExecuteHardLockPrompt(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveResolveExecuteHardLockPromptToolInput(rawInput);
  return service.resolveExecuteHardLockPrompt({
    ...input,
    output: DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH,
    quiet: true,
  });
}
