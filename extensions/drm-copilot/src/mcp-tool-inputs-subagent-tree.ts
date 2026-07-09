import {
  normalizeRequiredText,
  normalizeWorkspaceRoot,
} from "./workflow-command-arguments";
import {
  asToolArgumentObject,
  type WorkspaceToolInput,
} from "./mcp-tool-inputs";

/**
 * Resolved input for the `render_subagent_tree` MCP tool.
 *
 * `sessionId` is normalized (required, trimmed, non-empty) here; its charset
 * validation against `^[0-9A-Za-z-]{8,64}$` is enforced downstream in
 * `resolveSessionTranscriptPath`, keeping a single validation point before any
 * filesystem access.
 */
export interface RenderSubagentTreeToolInput extends WorkspaceToolInput {
  readonly sessionId: string;
}

/**
 * Resolve the raw MCP arguments for `render_subagent_tree`.
 *
 * @param rawInput The raw MCP tool arguments.
 * @param fallbackWorkspaceRoot Workspace root used when `workspace_root` is
 *   omitted.
 * @returns The normalized `{ workspaceRoot, sessionId }` input.
 * @throws Error when `session_id` is missing, non-string, or empty.
 */
export function resolveRenderSubagentTreeToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RenderSubagentTreeToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    sessionId: normalizeRequiredText(args["session_id"], "session_id"),
  };
}
