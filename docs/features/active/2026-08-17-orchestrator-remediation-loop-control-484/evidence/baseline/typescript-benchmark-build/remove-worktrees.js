"use strict";
/**
 * Pure-logic module for the "Remove Secondary Worktrees" command.
 *
 * This module contains no I/O. It must NOT import `vscode`,
 * `node:child_process`, `node:fs`, or `node:path`. All functions are pure
 * string-in / value-out transforms so they can be unit-tested without git,
 * the filesystem, or the VS Code host runtime. Git invocation and the VS Code
 * wiring live in `./remove-worktrees-runner` and `./extension` respectively.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseWorktreePorcelain = parseWorktreePorcelain;
exports.selectSecondaryWorktrees = selectSecondaryWorktrees;
exports.classifyWorktreeForRemoval = classifyWorktreeForRemoval;
exports.deriveParentDirectoryPath = deriveParentDirectoryPath;
exports.classifyParentDirectoryForCleanup = classifyParentDirectoryForCleanup;
exports.buildRemovalSummaryMessage = buildRemovalSummaryMessage;
/**
 * Parses the porcelain output of `git worktree list --porcelain`.
 *
 * Each worktree is reported as a block of `key value` lines separated by a
 * blank line. The first block is always the primary (main) worktree and is
 * marked `isPrimary: true`; all subsequent blocks are secondary.
 *
 * @param raw The raw stdout from `git worktree list --porcelain`.
 * @returns The parsed worktree entries in the order git reported them.
 */
function parseWorktreePorcelain(raw) {
    // Normalize CRLF to LF so `\r\n\r\n` block separators split identically to
    // `\n\n`, then split on one-or-more blank lines.
    const normalized = raw.replace(/\r\n/g, "\n");
    const blocks = normalized.split(/\n{2,}/);
    const entries = [];
    let isFirstBlock = true;
    for (const block of blocks) {
        const lines = block.split("\n").filter((line) => line.trim().length > 0);
        if (lines.length === 0) {
            // Ignore empty trailing blocks produced by trailing newlines.
            continue;
        }
        let worktreePath;
        let isLocked = false;
        let lockReason = "";
        let isPrunable = false;
        let pruneReason = "";
        for (const line of lines) {
            if (line.startsWith("worktree ")) {
                worktreePath = line.slice("worktree ".length).trim();
            }
            else if (line === "locked" || line.startsWith("locked ")) {
                isLocked = true;
                lockReason = line.slice("locked".length).trim();
            }
            else if (line === "prunable" || line.startsWith("prunable ")) {
                isPrunable = true;
                pruneReason = line.slice("prunable".length).trim();
            }
            // `bare`, `detached`, `branch refs/heads/<name>`, and `HEAD <sha>`
            // are recognized as valid porcelain lines but are not needed for
            // removal decisions, so they are intentionally ignored here.
        }
        if (worktreePath === undefined) {
            // A block without a `worktree` line is not a valid worktree entry.
            continue;
        }
        entries.push({
            path: worktreePath,
            isPrimary: isFirstBlock,
            isLocked,
            lockReason,
            isPrunable,
            pruneReason,
        });
        isFirstBlock = false;
    }
    return entries;
}
/**
 * Selects the secondary worktrees from a parsed list.
 *
 * The primary worktree (the first block reported by git) is excluded by its
 * `isPrimary` flag, guaranteeing the primary is never selected for removal.
 * Input order is preserved.
 *
 * @param entries The parsed worktree entries.
 * @returns The non-primary worktree entries in their original order.
 */
function selectSecondaryWorktrees(entries) {
    return entries.filter((entry) => entry.isPrimary === false);
}
/**
 * Classifies whether a secondary worktree should be skipped before attempting
 * a NON-force `git worktree remove`.
 *
 * Locked worktrees are skipped first (locked takes precedence over prunable);
 * prunable worktrees (those whose working directory is missing on disk) are
 * skipped next. A clean worktree is eligible for removal.
 *
 * @param entry The secondary worktree entry to classify.
 * @returns A classification indicating skip-with-reason or eligible.
 */
function classifyWorktreeForRemoval(entry) {
    if (entry.isLocked) {
        const reason = entry.lockReason.length > 0 ? `locked: ${entry.lockReason}` : "locked";
        return { skip: true, reason };
    }
    if (entry.isPrunable) {
        const reason = entry.pruneReason.length > 0
            ? `working directory missing on disk: ${entry.pruneReason}`
            : "working directory missing on disk";
        return { skip: true, reason };
    }
    return { skip: false };
}
/**
 * Normalizes a path to forward slashes with no trailing separator. Pure
 * string transform; performs no filesystem access and imports no `node:path`.
 *
 * @param rawPath A filesystem path using `/` or `\` separators.
 * @returns The forward-slash path with any trailing separators removed.
 */
function normalizePathSeparators(rawPath) {
    return rawPath.replace(/\\/g, "/").replace(/\/+$/, "");
}
/**
 * Derives the parent directory of a removed worktree path by stripping its last
 * path segment. Handles both `/` and `\` separators without importing
 * `node:path`.
 *
 * @param worktreePath A worktree path (for the nested scheme,
 *                     `<parent>/<repoName>-wt/<timestamp>`).
 * @returns The parent directory path (the `<repoName>-wt` grouping directory
 *          for a nested-scheme worktree), forward-slash normalized.
 */
function deriveParentDirectoryPath(worktreePath) {
    const normalized = normalizePathSeparators(worktreePath);
    const lastSlash = normalized.lastIndexOf("/");
    return lastSlash > 0 ? normalized.slice(0, lastSlash) : normalized;
}
/**
 * Extracts the final path segment (basename) of a path without importing
 * `node:path`.
 *
 * @param rawPath A filesystem path.
 * @returns The basename, forward-slash normalized.
 */
function deriveBasename(rawPath) {
    const normalized = normalizePathSeparators(rawPath);
    const lastSlash = normalized.lastIndexOf("/");
    return lastSlash >= 0 ? normalized.slice(lastSlash + 1) : normalized;
}
/**
 * Pure decision for whether a candidate grouping directory should be removed
 * after its secondary worktrees have been removed. The caller supplies the
 * directory listing so this function performs no filesystem access.
 *
 * A parent is eligible only when all of the following hold:
 * - its basename ends with `-wt` (a `<repoName>-wt` grouping directory);
 * - the supplied directory listing is empty;
 * - it is neither the primary worktree path nor the primary worktree's parent.
 *
 * @param input The candidate parent path, its directory listing, and the
 *              primary worktree path used for the safety checks.
 * @returns A discriminated decision to remove or to leave the directory.
 */
function classifyParentDirectoryForCleanup(input) {
    const parent = normalizePathSeparators(input.parentPath);
    const basename = deriveBasename(parent);
    if (!basename.endsWith("-wt")) {
        return {
            remove: false,
            reason: `not a "-wt" grouping directory: ${input.parentPath}`,
        };
    }
    const primary = normalizePathSeparators(input.primaryWorktreePath);
    const primaryParent = deriveParentDirectoryPath(input.primaryWorktreePath);
    if (parent === primary || parent === primaryParent) {
        return {
            remove: false,
            reason: `refusing to remove the primary worktree or its parent: ${input.parentPath}`,
        };
    }
    if (input.entries.length > 0) {
        return {
            remove: false,
            reason: `directory not empty: ${input.parentPath}`,
        };
    }
    return { remove: true, path: input.parentPath };
}
/**
 * Builds the user-facing summary message for a completed removal operation.
 *
 * @param summary The aggregated removal summary.
 * @returns A single-line report of removed and skipped worktrees, plus any
 *          removed empty grouping directories.
 */
function buildRemovalSummaryMessage(summary) {
    const removedCount = summary.removed.length;
    const skippedCount = summary.skipped.length;
    const removedParents = summary.removedEmptyParents;
    const parentSuffix = removedParents.length > 0
        ? ` Removed ${String(removedParents.length)} empty grouping ${removedParents.length === 1 ? "directory" : "directories"}: ${removedParents.join(", ")}.`
        : "";
    if (removedCount === 0 && skippedCount === 0) {
        return `No secondary worktrees found.${parentSuffix}`;
    }
    if (skippedCount === 0) {
        return `Removed ${String(removedCount)} worktree(s).${parentSuffix}`;
    }
    const skippedPaths = summary.skipped.map((entry) => entry.path).join(", ");
    return `Removed ${String(removedCount)} worktree(s). Skipped ${String(skippedCount)}: ${skippedPaths}. See output channel for details.${parentSuffix}`;
}
