import * as vscode from "vscode";
import { getClaudeProjectsRoot, getWorkspaceRoot } from "./command-runtime";
import {
  RealFileSystem,
  toPosixPath,
  type FileSystem,
} from "./lib/file-system";
import { buildSubagentTree, formatTree } from "./lib/subagent-tree";
import {
  encodeWorkspacePath,
  matchEncodedDirectories,
} from "./lib/subagent-tree/workspace-encoding";
import {
  createSubagentTreeTerminalWriter,
  type TerminalWriter,
} from "./terminal-writer";

/** Command id contributed to `package.json`'s `contributes.commands`. */
const COMMAND_ID = "drmCopilotExtension.showSubagentTree";
/** Glob (relative to a matched projects directory) matching `.jsonl` files. */
const ROOT_SESSION_GLOB = "**/*.jsonl";
/** Path segment identifying a flattened subagent transcript, not a root session. */
const SUBAGENTS_SEGMENT = "/subagents/";

/**
 * Register the `drmCopilotExtension.showSubagentTree` command.
 *
 * Purpose:
 *     Thin VS Code host wiring per Design Decision item 8. Discovers
 *     candidate root sessions under the user-global Claude projects
 *     directory (`~/.claude/projects/`, honoring a home-dir / CLAUDE config
 *     dir override), narrowed to the directory (or directories) matching the
 *     current workspace path and its per-worktree siblings. Excludes
 *     flattened subagent transcripts, auto-selects a single candidate or
 *     prompts via `showQuickPick` for multiple, then renders the tree
 *     through the host-neutral `buildSubagentTree`/`formatTree` pair to an
 *     integrated terminal. All domain logic lives in `./lib/subagent-tree`;
 *     this file only performs discovery, prompting, and terminal/error
 *     wiring.
 *
 * @param options Options carrying the shared output channel plus optional
 *   injectable seams (`createFileSystem`, `createTerminalWriter`) that tests
 *   use to substitute fakes for the real filesystem and integrated terminal.
 * @returns The command registration's `Disposable`.
 */
export function registerSubagentTreeCommand(options: {
  readonly output: vscode.OutputChannel;
  readonly createFileSystem?: () => FileSystem;
  readonly createTerminalWriter?: () => TerminalWriter;
}): vscode.Disposable {
  const createFileSystem =
    options.createFileSystem ?? ((): FileSystem => new RealFileSystem());
  const createTerminalWriter =
    options.createTerminalWriter ?? createSubagentTreeTerminalWriter;
  // Constructed once at registration time so repeated command invocations
  // share the same TerminalWriter instance, which is what lets the real
  // implementation reuse (or, once closed, replace) a single named terminal
  // instead of accumulating one terminal per invocation.
  const terminalWriter = createTerminalWriter();

  return vscode.commands.registerCommand(COMMAND_ID, async () => {
    const { output } = options;
    try {
      const workspaceRoot = getWorkspaceRoot();
      const claudeProjectsRoot = getClaudeProjectsRoot();
      const fileSystem = createFileSystem();
      const candidates = discoverRootSessionCandidates(
        claudeProjectsRoot,
        workspaceRoot,
        fileSystem,
      );

      const selected = await selectRootSession(
        candidates,
        output,
        claudeProjectsRoot,
      );
      if (selected === undefined) {
        return;
      }

      const tree = buildSubagentTree(selected, { fileSystem });
      const rendered = formatTree(tree);
      const header = `[${COMMAND_ID}] subagent tree for ${selected}:`;
      terminalWriter.write(header, rendered);
      terminalWriter.reveal();
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
 * Discover candidate root-session transcript paths under the user-global
 * Claude projects directory, narrowed to the directory (or directories)
 * matching the current workspace path.
 *
 * @param claudeProjectsRoot Absolute path to the resolved user-global Claude
 *   projects directory (`~/.claude/projects` or the `CLAUDE_CONFIG_DIR`
 *   override).
 * @param workspaceRoot Absolute path to the open workspace root.
 * @param fileSystem Filesystem seam used to list matching directories and
 *   glob for `.jsonl` files within them.
 * @returns Root-session candidate paths, sorted for deterministic prompting,
 *   excluding any path under a `subagents` directory.
 */
function discoverRootSessionCandidates(
  claudeProjectsRoot: string,
  workspaceRoot: string,
  fileSystem: FileSystem,
): string[] {
  const encodedWorkspaceName = encodeWorkspacePath(workspaceRoot);
  const directoryNames = fileSystem.listDirectory(claudeProjectsRoot);
  const matchingDirectories = matchEncodedDirectories(
    directoryNames,
    encodedWorkspaceName,
  );

  const candidates = matchingDirectories.flatMap((directoryName) =>
    fileSystem.glob(
      `${claudeProjectsRoot}/${directoryName}`,
      ROOT_SESSION_GLOB,
    ),
  );

  return candidates
    .filter((path) => !toPosixPath(path).includes(SUBAGENTS_SEGMENT))
    .sort((left, right) => left.localeCompare(right));
}

/**
 * Resolve which root session to render: auto-select a single candidate,
 * prompt among multiple, or report an error when there are none.
 *
 * @param candidates The discovered root-session candidates.
 * @param output The output channel used for logging and error reporting.
 * @param claudeProjectsRoot The resolved user-global Claude projects
 *   directory, named in the zero-candidates error message so it reflects the
 *   real search location rather than a stale relative-glob string.
 * @returns The selected session path, or `undefined` when there is nothing
 *   to select (zero candidates) or the user cancels the prompt.
 */
async function selectRootSession(
  candidates: readonly string[],
  output: vscode.OutputChannel,
  claudeProjectsRoot: string,
): Promise<string | undefined> {
  if (candidates.length === 0) {
    const message = `No root session transcripts found under ${claudeProjectsRoot}.`;
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
