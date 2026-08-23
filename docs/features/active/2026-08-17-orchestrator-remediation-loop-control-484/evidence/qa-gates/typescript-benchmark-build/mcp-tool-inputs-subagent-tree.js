"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveRenderSubagentTreeToolInput = resolveRenderSubagentTreeToolInput;
const workflow_command_arguments_1 = require("./workflow-command-arguments");
const mcp_tool_inputs_1 = require("./mcp-tool-inputs");
/**
 * Resolve the raw MCP arguments for `render_subagent_tree`.
 *
 * @param rawInput The raw MCP tool arguments.
 * @param fallbackWorkspaceRoot Workspace root used when `workspace_root` is
 *   omitted.
 * @returns The normalized `{ workspaceRoot, sessionId }` input.
 * @throws Error when `session_id` is missing, non-string, or empty.
 */
function resolveRenderSubagentTreeToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        sessionId: (0, workflow_command_arguments_1.normalizeRequiredText)(args["session_id"], "session_id"),
    };
}
