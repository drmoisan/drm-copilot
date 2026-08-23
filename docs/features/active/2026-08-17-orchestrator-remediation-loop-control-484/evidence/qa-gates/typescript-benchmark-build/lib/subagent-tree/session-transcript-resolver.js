"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveSessionTranscriptPath = resolveSessionTranscriptPath;
const workspace_encoding_1 = require("./workspace-encoding");
/**
 * Allowed shape of a Claude Code session id (transcript filename stem).
 * Observed ids are UUIDv4 values; the charset admits digits, ASCII letters,
 * and hyphens, bounded to 8-64 characters. Because the id is interpolated into
 * a filesystem path, this charset also blocks path traversal by construction:
 * separators (`/`, `\`), `.`, `..`, and NUL are all outside the class.
 */
const SESSION_ID_PATTERN = /^[0-9A-Za-z-]{8,64}$/;
/** Human-readable form of {@link SESSION_ID_PATTERN} used in error messages. */
const SESSION_ID_RULE = "^[0-9A-Za-z-]{8,64}$ (8-64 characters of digits, ASCII letters, or hyphen)";
/**
 * Resolve the transcript path for a root session id under the user-global
 * Claude projects directory, using the same search scope as the VS Code
 * command: the encoded workspace directory plus its `-wt-` worktree siblings,
 * matched case-insensitively.
 *
 * Purpose:
 *     Host-neutral id-to-path mapping for the `render_subagent_tree` MCP tool.
 *     Validation runs before any filesystem access, so a malformed id never
 *     touches the filesystem. Imports neither `vscode` nor `node:fs`; all I/O
 *     flows through the injected {@link FileSystem} seam.
 *
 * @param sessionId The root session identifier (transcript filename stem).
 * @param workspaceRoot Absolute workspace path whose encoded form and
 *   worktree siblings scope the search.
 * @param claudeProjectsRoot Absolute path to the resolved user-global Claude
 *   projects directory.
 * @param fileSystem Filesystem seam used to list candidate directories and
 *   test for the transcript file.
 * @returns The absolute transcript path of the first matching directory that
 *   contains `<sessionId>.jsonl`.
 * @throws Error when `sessionId` is malformed (before any filesystem access),
 *   or when no matching directory contains the transcript.
 */
function resolveSessionTranscriptPath(sessionId, workspaceRoot, claudeProjectsRoot, fileSystem) {
    if (!SESSION_ID_PATTERN.test(sessionId)) {
        throw new Error(`Invalid session id '${sessionId}': must match ${SESSION_ID_RULE}.`);
    }
    const encodedWorkspaceName = (0, workspace_encoding_1.encodeWorkspacePath)(workspaceRoot);
    const matchingDirectories = (0, workspace_encoding_1.matchEncodedDirectories)(fileSystem.listDirectory(claudeProjectsRoot), encodedWorkspaceName);
    for (const directoryName of matchingDirectories) {
        const transcriptPath = `${claudeProjectsRoot}/${directoryName}/${sessionId}.jsonl`;
        if (fileSystem.isFile(transcriptPath)) {
            return transcriptPath;
        }
    }
    const searched = matchingDirectories.length === 0
        ? "(no directories matched the encoded workspace path)"
        : matchingDirectories
            .map((directoryName) => `${claudeProjectsRoot}/${directoryName}`)
            .join(", ");
    throw new Error(`No transcript found for session id '${sessionId}' under ${claudeProjectsRoot}. Searched: ${searched}.`);
}
