"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleRenderSubagentTree = handleRenderSubagentTree;
const mcp_tool_inputs_subagent_tree_1 = require("../mcp-tool-inputs-subagent-tree");
/**
 * Thin handler for the `render_subagent_tree` MCP tool: resolve the input and
 * delegate to the single service method.
 *
 * @param rawInput The raw MCP tool arguments.
 * @param service The shared repo-automation service.
 * @returns The service execution result carrying the rendered tree.
 */
async function handleRenderSubagentTree(rawInput, service) {
    const input = (0, mcp_tool_inputs_subagent_tree_1.resolveRenderSubagentTreeToolInput)(rawInput);
    return service.renderSubagentTree(input);
}
