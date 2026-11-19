/**
 * Thin handler of the two push-down integration MCP tools (issue #1051, S42,
 * S45, S47).
 *
 * It resolves the input, calls the optional service method and returns the
 * MCP result carrying `integration`. A completed run is `ok: true`, including
 * a validate run whose verdict is `fail`; input errors and a host without the
 * service method are thrown to the dispatcher's failure path.
 */

import type { RepoAutomationMcpToolResult } from "../mcp-tools";
import type { PushDownIntegrationToolName } from "../mcp-push-down-integration-tool-definitions";
import { resolvePushDownIntegrationToolInput } from "../mcp-tool-inputs-push-down-integration";
import type { RepoAutomationService } from "../repo-automation-service-contract";

/** Code that prefixes the error of a host without the tool's service method. */
export const PUSH_DOWN_INTEGRATION_UNAVAILABLE =
  "PUSH_DOWN_INTEGRATION_UNAVAILABLE";

/**
 * Build the error thrown when the host lacks the tool's service method.
 *
 * @param toolName The tool.
 * @returns A code-prefixed error.
 */
function unavailable(toolName: PushDownIntegrationToolName): Error {
  return new Error(
    `${PUSH_DOWN_INTEGRATION_UNAVAILABLE}: this host does not provide ${toolName}.`,
  );
}

/**
 * Run one push-down integration tool call.
 *
 * @param toolName The tool.
 * @param rawInput The raw MCP arguments.
 * @param service The shared repo-automation service.
 * @returns The MCP result carrying `integration`.
 * @throws Error For invalid input or a host without the service method.
 */
export async function handlePushDownIntegrationTool(
  toolName: PushDownIntegrationToolName,
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationMcpToolResult> {
  const input = resolvePushDownIntegrationToolInput(rawInput);
  if (toolName === "detect_push_down_integration") {
    if (service.detectPushDownIntegration === undefined) {
      throw unavailable(toolName);
    }
    const integration = await service.detectPushDownIntegration(input);
    return {
      ok: true,
      tool: toolName,
      workspace_root: input.workspaceRoot,
      summary: `Detected ${String(integration.workflows.length)} workflow(s) and ${String(integration.conflicts.length)} conflict(s).`,
      integration,
    };
  }
  if (service.validatePushDownIntegration === undefined) {
    throw unavailable(toolName);
  }
  const integration = await service.validatePushDownIntegration(input);
  const failed = integration.rules.filter((rule) => rule.status === "fail");
  return {
    ok: true,
    tool: toolName,
    workspace_root: input.workspaceRoot,
    summary: `Validation verdict: ${integration.verdict}${failed.length > 0 ? ` (${failed.map((rule) => rule.rule).join(", ")})` : ""}.`,
    integration,
  };
}
