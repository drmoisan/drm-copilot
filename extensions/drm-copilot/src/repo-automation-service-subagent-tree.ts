import { getClaudeProjectsRoot } from "./command-runtime";
import { buildSubagentTree, formatTree } from "./lib/subagent-tree";
import { resolveSessionTranscriptPath } from "./lib/subagent-tree/session-transcript-resolver";
import type { FileSystem } from "./lib/file-system";

/**
 * Input for the `renderSubagentTree` service method (workspace root plus the
 * root session id whose tree is rendered).
 */
export interface RenderSubagentTreeServiceInput {
  readonly workspaceRoot: string;
  readonly sessionId: string;
}

/**
 * Structural result returned by {@link renderSubagentTreeServiceCall};
 * assignable to `RepoAutomationExecutionResult` (which carries the optional
 * `renderedTree` field).
 */
export interface RenderSubagentTreeServiceResult {
  readonly tool: "render_subagent_tree";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly renderedTree: string;
}

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
export function renderSubagentTreeServiceCall(
  input: RenderSubagentTreeServiceInput & { readonly fileSystem: FileSystem },
  env: NodeJS.ProcessEnv = process.env,
): RenderSubagentTreeServiceResult {
  const claudeProjectsRoot = getClaudeProjectsRoot(env);
  const transcriptPath = resolveSessionTranscriptPath(
    input.sessionId,
    input.workspaceRoot,
    claudeProjectsRoot,
    input.fileSystem,
  );
  const renderedTree = formatTree(
    buildSubagentTree(transcriptPath, { fileSystem: input.fileSystem }),
  );
  return {
    tool: "render_subagent_tree",
    workspaceRoot: input.workspaceRoot,
    summary: `Rendered subagent tree for session ${input.sessionId} (${transcriptPath}).`,
    renderedTree,
  };
}
