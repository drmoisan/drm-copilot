"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolvePotentialToIssueToolInput = resolvePotentialToIssueToolInput;
const workflow_command_arguments_1 = require("./workflow-command-arguments");
const mcp_tool_inputs_1 = require("./mcp-tool-inputs");
/**
 * Resolves the `potential_to_issue` MCP tool input, failing closed on an
 * omitted `workspace_root` and resolving a workspace-relative `potential_path`
 * against the resolved workspace root.
 *
 * Extracted from `mcp-tool-inputs.ts` (following the
 * `mcp-tool-inputs-push-down.ts` precedent) so the base module stays within the
 * 500-line production-file limit.
 *
 * @param rawInput The raw MCP tool argument object.
 * @param fallbackWorkspaceRoot Optional explicit workspace-root fallback used by
 *   the VS Code command surface; MCP handlers pass nothing so an omitted
 *   `workspace_root` fails closed.
 * @returns The resolved, validated potential-to-issue tool input.
 * @throws Error when `workspace_root` is omitted with no fallback, or when
 *   required fields are missing or invalid.
 */
function resolvePotentialToIssueToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const workspaceRoot = (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot);
    // Resolve a workspace-relative potential_path against the resolved
    // workspace_root (not the server's process.cwd()) so the tool honors its
    // documented "Absolute or workspace-relative path" contract. An absolute
    // path is preserved unchanged by normalizeWorkspaceDestinationPath.
    const potentialPath = (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)((0, workflow_command_arguments_1.normalizeRequiredText)(args["potential_path"], "potential_path"), workspaceRoot, "potential_path");
    return {
        workspaceRoot,
        potentialPath,
        promotionType: (0, workflow_command_arguments_1.validatePromotionType)((0, workflow_command_arguments_1.normalizeRequiredText)(args["promotion_type"], "promotion_type"), "promotion_type"),
        workMode: (0, workflow_command_arguments_1.validateWorkMode)((0, workflow_command_arguments_1.normalizeRequiredText)(args["work_mode"], "work_mode"), "work_mode"),
    };
}
