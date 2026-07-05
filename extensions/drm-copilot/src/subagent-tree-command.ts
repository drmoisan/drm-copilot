import * as vscode from "vscode";
import { getWorkspaceRoot } from "./command-runtime";
import { RealFileSystem, toPosixPath } from "./lib/file-system";
import { buildSubagentTree, formatTree } from "./lib/subagent-tree";

/** Command id contributed to `package.json`'s `contributes.commands`. */
const COMMAND_ID = "drmCopilotExtension.showSubagentTree";
/** Glob (relative to the workspace root) matching root-session transcripts. */
const ROOT_SESSION_GLOB = ".claude/projects/**/*.jsonl";
/** Path segment identifying a flattened subagent transcript, not a root session. */
const SUBAGENTS_SEGMENT = "/subagents/";

/**
 * Register the `drmCopilotExtension.showSubagentTree` command.
 *
 * Purpose:
 *     Thin VS Code host wiring per Design Decision item 8. Discovers
 *     candidate root sessions under `.claude/projects/**\/*.jsonl`, excludes
 *     flattened subagent transcripts, auto-selects a single candidate or
 *     prompts via `showQuickPick` for multiple, then renders the tree
 *     through the host-neutral `buildSubagentTree`/`formatTree` pair. All
 *     domain logic lives in `./lib/subagent-tree`; this file only performs
 *     discovery, prompting, and output-channel wiring.
 *
 * @param options Options carrying the shared output channel.
 * @returns The command registration's `Disposable`.
 */
export function registerSubagentTreeCommand(options: {
  readonly output: vscode.OutputChannel;
}): vscode.Disposable {
  return vscode.commands.registerCommand(COMMAND_ID, async () => {
    const { output } = options;
    try {
      const workspaceRoot = getWorkspaceRoot();
      const fileSystem = new RealFileSystem();
      const candidates = discoverRootSessionCandidates(
        workspaceRoot,
        fileSystem,
      );

      const selected = await selectRootSession(candidates, output);
      if (selected === undefined) {
        return;
      }

      const tree = buildSubagentTree(selected, { fileSystem });
      const rendered = formatTree(tree);
      output.appendLine(`[${COMMAND_ID}] subagent tree for ${selected}:`);
      output.appendLine(rendered);
      output.show(true);
    } catch (error: unknown) {
      const detail = error instanceof Error ? error.message : "Unknown error.";
      output.appendLine(`[${COMMAND_ID}] failed: ${detail}`);
      await vscode.window.showErrorMessage(
        `Show Subagent Tree failed: ${detail}`,
      );
    }
  });
}

/**
 * Discover candidate root-session transcript paths under the workspace.
 *
 * @param workspaceRoot Absolute path to the workspace root.
 * @param fileSystem Filesystem seam used to glob for `.jsonl` files.
 * @returns Root-session candidate paths, sorted for deterministic prompting,
 *   excluding any path under a `subagents` directory.
 */
function discoverRootSessionCandidates(
  workspaceRoot: string,
  fileSystem: RealFileSystem,
): string[] {
  return fileSystem
    .glob(workspaceRoot, ROOT_SESSION_GLOB)
    .filter((path) => !toPosixPath(path).includes(SUBAGENTS_SEGMENT))
    .sort((left, right) => left.localeCompare(right));
}

/**
 * Resolve which root session to render: auto-select a single candidate,
 * prompt among multiple, or report an error when there are none.
 *
 * @param candidates The discovered root-session candidates.
 * @param output The output channel used for logging and error reporting.
 * @returns The selected session path, or `undefined` when there is nothing
 *   to select (zero candidates) or the user cancels the prompt.
 */
async function selectRootSession(
  candidates: readonly string[],
  output: vscode.OutputChannel,
): Promise<string | undefined> {
  if (candidates.length === 0) {
    const message =
      "No root session transcripts found under .claude/projects/**/*.jsonl.";
    output.appendLine(`[${COMMAND_ID}] ${message}`);
    await vscode.window.showErrorMessage(message);
    return undefined;
  }

  if (candidates.length === 1) {
    const [onlyCandidate] = candidates;
    if (onlyCandidate !== undefined) {
      return onlyCandidate;
    }
  }

  const selectedItem = await vscode.window.showQuickPick([...candidates], {
    title: "drm-copilot: Show Subagent Tree",
    placeHolder: "Choose the root session to render",
    ignoreFocusOut: true,
  });

  if (selectedItem === undefined) {
    output.appendLine(`[${COMMAND_ID}] session selection canceled by user`);
    return undefined;
  }

  return selectedItem;
}
