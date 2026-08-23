"use strict";
/**
 * Pure helpers for mapping an absolute workspace path to the encoded
 * directory name Claude Code uses under the user-global
 * `~/.claude/projects/` directory, and for matching that encoded name
 * (plus per-worktree sibling directories) against directory names actually
 * present on disk.
 *
 * Purpose:
 *     Isolate the encoding/matching rule confirmed against on-disk examples
 *     (`evidence/other/encoding-rule-confirmation.*.md`) in a pure,
 *     host-neutral module with no `vscode` import, so
 *     `src/subagent-tree-command.ts` can resolve real transcript locations
 *     without embedding the encoding rule inline.
 *
 * Path convention:
 *     Operates on plain strings only; performs no filesystem access.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.encodeWorkspacePath = encodeWorkspacePath;
exports.matchEncodedDirectories = matchEncodedDirectories;
const WORKTREE_INFIX = "-wt-";
/**
 * Encode an absolute workspace path the way Claude Code encodes a `cwd` when
 * naming its per-workspace projects directory: every path separator (`\` or
 * `/`) and every `:` is replaced with `-`.
 *
 * @param workspacePath Absolute workspace path, using either `\` or `/`
 *   separators.
 * @returns The encoded directory-name form of `workspacePath`.
 */
function encodeWorkspacePath(workspacePath) {
    return workspacePath.replace(/[\\/:]/g, "-");
}
/**
 * Match candidate on-disk directory names against an encoded workspace name.
 *
 * A directory matches when its name equals the encoded workspace name, or
 * begins with `<encodedWorkspaceName>-wt-` (a per-worktree sibling, including
 * nested worktree-of-a-worktree siblings whose name simply extends the
 * matched prefix with another `-wt-<suffix>` segment). The comparison is
 * case-insensitive because the drive-letter segment's case is not normalized
 * by Claude Code: both `c--Users-...` and `C--Users-...` are observed on disk
 * for encodings of the same underlying path prefix.
 *
 * Under the nested worktree scheme the on-disk path is
 * `<parent>/<repoName>-wt/<timestamp>`. Because {@link encodeWorkspacePath}
 * replaces the `/` between `<repoName>-wt` and the timestamp with `-`, the
 * encoded directory name still contains the `-wt-` infix
 * (`...-<repoName>-wt-<timestamp>`) exactly as the previous flat scheme did.
 * The prefix match therefore resolves new-scheme directories with no change to
 * the matching logic below; the `-wt-` infix arises from `-wt` plus the encoded
 * `/`, rather than from a flat `<repoName>-wt-<timestamp>` sibling name.
 *
 * @param directoryNames Candidate directory names present on disk.
 * @param encodedWorkspaceName The encoded name produced by
 *   {@link encodeWorkspacePath} for the current workspace root.
 * @returns The subset of `directoryNames` that match, preserving input order.
 */
function matchEncodedDirectories(directoryNames, encodedWorkspaceName) {
    const target = encodedWorkspaceName.toLowerCase();
    const worktreePrefix = `${target}${WORKTREE_INFIX}`;
    return directoryNames.filter((directoryName) => {
        const lowerDirectoryName = directoryName.toLowerCase();
        return (lowerDirectoryName === target ||
            lowerDirectoryName.startsWith(worktreePrefix));
    });
}
