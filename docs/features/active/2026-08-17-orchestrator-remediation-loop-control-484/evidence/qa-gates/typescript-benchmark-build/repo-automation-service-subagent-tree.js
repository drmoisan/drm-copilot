"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.renderSubagentTreeServiceCall = renderSubagentTreeServiceCall;
const command_runtime_1 = require("./command-runtime");
const subagent_tree_1 = require("./lib/subagent-tree");
const session_transcript_resolver_1 = require("./lib/subagent-tree/session-transcript-resolver");
/**
 * Resolve a session id to its transcript and render the subagent tree.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.renderSubagentTree` delegates
 *     to, keeping the service file within the 500-line limit while preserving
 *     the method's observable return contract. Mirrors the existing
 *     `*-service-call` extraction precedents. Validation and not-found errors
 *     propagate from {@link resolveSessionTranscriptPath} and surface through
 *     the dispatcher's failure path.
 *
 * @param input Workspace root, session id, and the injected filesystem seam.
 * @param env Environment used to resolve the Claude projects root; defaults to
 *   `process.env`.
 * @returns The tool result carrying the rendered tree text.
 */
function renderSubagentTreeServiceCall(input, env = process.env) {
    const claudeProjectsRoot = (0, command_runtime_1.getClaudeProjectsRoot)(env);
    const transcriptPath = (0, session_transcript_resolver_1.resolveSessionTranscriptPath)(input.sessionId, input.workspaceRoot, claudeProjectsRoot, input.fileSystem);
    const renderedTree = (0, subagent_tree_1.formatTree)((0, subagent_tree_1.buildSubagentTree)(transcriptPath, { fileSystem: input.fileSystem }));
    return {
        tool: "render_subagent_tree",
        workspaceRoot: input.workspaceRoot,
        summary: `Rendered subagent tree for session ${input.sessionId} (${transcriptPath}).`,
        renderedTree,
    };
}
