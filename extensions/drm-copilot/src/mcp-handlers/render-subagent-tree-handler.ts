import { resolveRenderSubagentTreeToolInput } from "../mcp-tool-inputs-subagent-tree";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

/**
 * Thin handler for the `render_subagent_tree` MCP tool: resolve the input and
 * delegate to the single service method.
 *
 * @param rawInput The raw MCP tool arguments.
 * @param service The shared repo-automation service.
 * @returns The service execution result carrying the rendered tree.
 */
export async function handleRenderSubagentTree(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRenderSubagentTreeToolInput(rawInput);
  return service.renderSubagentTree(input);
}
