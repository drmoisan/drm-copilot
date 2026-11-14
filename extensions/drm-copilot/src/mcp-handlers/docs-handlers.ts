/**
 * Thin handler for the six docs MCP tools (issue #1036).
 *
 * It resolves the input through the declarative tables, runs the docs command
 * through the service seam and maps the envelope to the MCP result: `ok` is
 * the envelope `ok`, `docs` is the envelope unchanged, and `stderr_excerpt` is
 * added only for exit code 3. Host failures are thrown as code-prefixed errors.
 */

import {
  DocsHostError,
  excerptDocsStderr,
  formatDocsSummary,
} from "../docs-command-envelope";
import type { RepoAutomationMcpToolResult } from "../mcp-tools";
import {
  resolveDocsToolInput,
  type DocsToolName,
} from "../mcp-tool-inputs-docs";
import type { RepoAutomationService } from "../repo-automation-service-contract";

/**
 * Runs one docs tool call.
 *
 * @param toolName The docs tool.
 * @param rawInput The raw MCP arguments.
 * @param service The shared repo-automation service.
 * @returns The MCP result carrying the envelope in `docs`.
 * @throws DocsInputError for invalid input; DocsHostError for a host failure.
 */
export async function handleDocsTool(
  toolName: DocsToolName,
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationMcpToolResult> {
  const input = resolveDocsToolInput(toolName, rawInput);
  if (service.runDocsCommand === undefined) {
    throw new DocsHostError(
      "DOCS_RUNTIME_UNAVAILABLE",
      "this host does not provide the docs command runtime.",
    );
  }
  const outcome = await service.runDocsCommand(input);
  const envelope = outcome.envelope;
  const stderrExcerpt =
    envelope.exit_code === 3 ? excerptDocsStderr(outcome.stderr) : undefined;
  return {
    ok: envelope.ok,
    tool: toolName,
    workspace_root: input.workspaceRoot,
    summary: formatDocsSummary(envelope),
    docs: envelope,
    ...(stderrExcerpt === undefined ? {} : { stderr_excerpt: stderrExcerpt }),
  };
}
