"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerSubagentTreeCommand = registerSubagentTreeCommand;
const vscode = __importStar(require("vscode"));
const command_runtime_1 = require("./command-runtime");
const file_system_1 = require("./lib/file-system");
const subagent_tree_1 = require("./lib/subagent-tree");
const quick_pick_labels_1 = require("./lib/subagent-tree/quick-pick-labels");
const workspace_encoding_1 = require("./lib/subagent-tree/workspace-encoding");
const terminal_writer_1 = require("./terminal-writer");
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
function registerSubagentTreeCommand(options) {
    const createFileSystem = options.createFileSystem ?? (() => new file_system_1.RealFileSystem());
    const createFileTimes = options.createFileTimes ?? (() => new file_system_1.RealFileTimes());
    const createTerminalWriter = options.createTerminalWriter ?? terminal_writer_1.createSubagentTreeTerminalWriter;
    // Constructed once at registration time so repeated command invocations
    // share the same TerminalWriter instance, which is what lets the real
    // implementation reuse (or, once closed, replace) a single named terminal
    // instead of accumulating one terminal per invocation.
    const terminalWriter = createTerminalWriter();
    return vscode.commands.registerCommand(COMMAND_ID, async () => {
        const { output } = options;
        try {
            const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
            const claudeProjectsRoot = (0, command_runtime_1.getClaudeProjectsRoot)();
            const fileSystem = createFileSystem();
            const fileTimes = createFileTimes();
            const candidates = discoverRootSessionCandidates(claudeProjectsRoot, workspaceRoot, fileSystem, fileTimes);
            const selected = await selectRootSession(candidates, output, claudeProjectsRoot);
            if (selected === undefined) {
                return;
            }
            const tree = (0, subagent_tree_1.buildSubagentTree)(selected, { fileSystem });
            const rendered = (0, subagent_tree_1.formatTree)(tree);
            const header = `[${COMMAND_ID}] subagent tree for ${selected}:`;
            terminalWriter.write(header, rendered);
            terminalWriter.reveal();
        }
        catch (error) {
            const detail = error instanceof Error ? error.message : "Unknown error.";
            output.appendLine(`[${COMMAND_ID}] failed: ${detail}`);
            await vscode.window.showErrorMessage(`Show Subagent Tree failed: ${detail}`);
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
 * @param fileTimes Narrow seam used to read each candidate transcript's
 *   last-modified time for display and ordering.
 * @returns Root-session candidates (path plus read mtime), excluding any path
 *   under a `subagents` directory. Ordering is deferred to
 *   `buildRootSessionPickEntries`, so no sort is applied here.
 */
function discoverRootSessionCandidates(claudeProjectsRoot, workspaceRoot, fileSystem, fileTimes) {
    const encodedWorkspaceName = (0, workspace_encoding_1.encodeWorkspacePath)(workspaceRoot);
    const directoryNames = fileSystem.listDirectory(claudeProjectsRoot);
    const matchingDirectories = (0, workspace_encoding_1.matchEncodedDirectories)(directoryNames, encodedWorkspaceName);
    const candidates = matchingDirectories.flatMap((directoryName) => fileSystem.glob(`${claudeProjectsRoot}/${directoryName}`, ROOT_SESSION_GLOB));
    return candidates
        .filter((path) => !(0, file_system_1.toPosixPath)(path).includes(SUBAGENTS_SEGMENT))
        .map((path) => ({
        path,
        lastActivityMs: fileTimes.getModifiedTimeMs(path),
    }));
}
/**
 * Resolve which root session to render: auto-select a single candidate,
 * prompt among multiple, or report an error when there are none.
 *
 * @param candidates The discovered root-session candidates (path plus mtime).
 * @param output The output channel used for logging and error reporting.
 * @param claudeProjectsRoot The resolved user-global Claude projects
 *   directory, named in the zero-candidates error message so it reflects the
 *   real search location rather than a stale relative-glob string.
 * @returns The selected session path, or `undefined` when there is nothing
 *   to select (zero candidates) or the user cancels the prompt.
 */
async function selectRootSession(candidates, output, claudeProjectsRoot) {
    if (candidates.length === 0) {
        const message = `No root session transcripts found under ${claudeProjectsRoot}.`;
        output.appendLine(`[${COMMAND_ID}] ${message}`);
        await vscode.window.showErrorMessage(message);
        return undefined;
    }
    if (candidates.length === 1) {
        const [onlyCandidate] = candidates;
        if (onlyCandidate !== undefined) {
            return onlyCandidate.path;
        }
    }
    const entries = (0, quick_pick_labels_1.buildRootSessionPickEntries)(candidates, quick_pick_labels_1.MAX_PATH_LABEL_LENGTH);
    const selectedItem = await vscode.window.showQuickPick(entries, {
        title: "drm-copilot: Show Subagent Tree",
        placeHolder: "Choose the root session to render",
        matchOnDetail: true,
        ignoreFocusOut: true,
    });
    if (selectedItem === undefined) {
        output.appendLine(`[${COMMAND_ID}] session selection canceled by user`);
        return undefined;
    }
    return selectedItem.path;
}
