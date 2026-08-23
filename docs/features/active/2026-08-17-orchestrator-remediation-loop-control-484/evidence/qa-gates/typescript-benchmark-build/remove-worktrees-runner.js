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
exports.createParentDirectoryFileSystem = createParentDirectoryFileSystem;
exports.createGitRunner = createGitRunner;
exports.removeAllSecondaryWorktrees = removeAllSecondaryWorktrees;
const cp = __importStar(require("node:child_process"));
const fs = __importStar(require("node:fs"));
const remove_worktrees_1 = require("./remove-worktrees");
/**
 * Creates the production {@link ParentDirectoryFileSystem} backed by `node:fs`.
 *
 * `removeEmptyDirectory` uses `fs.rmdirSync`, which refuses to remove a
 * non-empty directory, providing defense in depth beyond the pure emptiness
 * check in `classifyParentDirectoryForCleanup`.
 *
 * @returns A filesystem seam that operates on the real filesystem.
 */
function createParentDirectoryFileSystem() {
    return {
        directoryExists(path) {
            return fs.existsSync(path) && fs.statSync(path).isDirectory();
        },
        listDirectoryEntries(path) {
            return fs.readdirSync(path);
        },
        removeEmptyDirectory(path) {
            fs.rmdirSync(path);
        },
    };
}
function createGitRunner() {
    return {
        run(args, cwd) {
            return new Promise((resolve, reject) => {
                const stdoutChunks = [];
                const stderrChunks = [];
                const child = cp.spawn("git", args, {
                    cwd,
                    stdio: ["ignore", "pipe", "pipe"],
                    shell: false,
                });
                child.stdout.on("data", (chunk) => {
                    stdoutChunks.push(chunk.toString("utf-8"));
                });
                child.stderr.on("data", (chunk) => {
                    stderrChunks.push(chunk.toString("utf-8"));
                });
                child.on("error", (error) => {
                    reject(error);
                });
                child.on("close", (code) => {
                    resolve({
                        exitCode: code ?? 0,
                        stdout: stdoutChunks.join(""),
                        stderr: stderrChunks.join(""),
                    });
                });
            });
        },
    };
}
/**
 * Removes all secondary worktrees of a repository using NON-force semantics.
 *
 * Behavior:
 * - Enumerates worktrees via `git worktree list --porcelain`. A non-zero exit
 *   from the list command throws an `Error` carrying the stderr.
 * - Selects only secondary worktrees; the primary is never removed.
 * - Locked and prunable worktrees are skipped (left intact) with a reason.
 * - Eligible worktrees are removed with NON-force `git worktree remove <path>`.
 *   `--force` is never used and `git worktree prune` is never invoked.
 * - A worktree that cannot be fully removed (non-zero remove exit) is recorded
 *   as skipped with the stderr reason; the batch continues with the remainder.
 * - Per-worktree progress is appended to the supplied output sink.
 *
 * After all removals, any emptied `<repoName>-wt` grouping directory of a
 * successfully removed worktree is removed via the injected filesystem seam and
 * reported in `summary.removedEmptyParents`. A non-empty directory, a
 * non-`-wt` parent, or the primary worktree / its parent is never removed.
 * Cleanup failures are logged and never fail the overall command.
 *
 * @param workspaceRoot The repository root used as the git working directory.
 * @param git The injectable git runner.
 * @param output The output sink for per-worktree progress lines.
 * @param fileSystem The injectable filesystem seam for grouping-directory
 *                   cleanup.
 * @returns The aggregated removal summary.
 * @throws Error when `git worktree list --porcelain` exits non-zero.
 */
async function removeAllSecondaryWorktrees(workspaceRoot, git, output, fileSystem) {
    const listResult = await git.run(["worktree", "list", "--porcelain"], workspaceRoot);
    if (listResult.exitCode !== 0) {
        const detail = listResult.stderr.trim();
        throw new Error(detail.length > 0
            ? `git worktree list failed: ${detail}`
            : "git worktree list failed.");
    }
    const entries = (0, remove_worktrees_1.parseWorktreePorcelain)(listResult.stdout);
    const primaryEntry = entries.find((entry) => entry.isPrimary);
    const primaryWorktreePath = primaryEntry ? primaryEntry.path : "";
    const secondary = (0, remove_worktrees_1.selectSecondaryWorktrees)(entries);
    const removed = [];
    const skipped = [];
    for (const entry of secondary) {
        const classification = (0, remove_worktrees_1.classifyWorktreeForRemoval)(entry);
        if (classification.skip) {
            skipped.push({ path: entry.path, reason: classification.reason });
            output.appendLine(`[removeSecondaryWorktrees] skipped ${entry.path}: ${classification.reason}`);
            continue;
        }
        // NON-force removal only. A non-zero exit means the worktree cannot be
        // fully removed (dirty/locked); it is recorded as skipped and left intact.
        const removeResult = await git.run(["worktree", "remove", entry.path], workspaceRoot);
        if (removeResult.exitCode === 0) {
            removed.push(entry.path);
            output.appendLine(`[removeSecondaryWorktrees] removed ${entry.path}`);
            continue;
        }
        const reason = removeResult.stderr.trim().length > 0
            ? removeResult.stderr.trim()
            : "git worktree remove failed";
        skipped.push({ path: entry.path, reason });
        output.appendLine(`[removeSecondaryWorktrees] skipped ${entry.path}: ${reason}`);
    }
    // Empty grouping-directory cleanup. Derive the unique parents of the
    // successfully removed worktrees, then — for each — take a fresh listing via
    // the seam immediately before removal and let the pure classifier decide.
    const removedEmptyParents = [];
    const candidateParents = [];
    for (const removedPath of removed) {
        const parent = (0, remove_worktrees_1.deriveParentDirectoryPath)(removedPath);
        if (!candidateParents.includes(parent)) {
            candidateParents.push(parent);
        }
    }
    for (const parent of candidateParents) {
        try {
            if (!fileSystem.directoryExists(parent)) {
                continue;
            }
            const entriesInParent = fileSystem.listDirectoryEntries(parent);
            const decision = (0, remove_worktrees_1.classifyParentDirectoryForCleanup)({
                parentPath: parent,
                entries: entriesInParent,
                primaryWorktreePath,
            });
            if (!decision.remove) {
                output.appendLine(`[removeSecondaryWorktrees] left grouping directory ${parent}: ${decision.reason}`);
                continue;
            }
            fileSystem.removeEmptyDirectory(parent);
            removedEmptyParents.push(parent);
            output.appendLine(`[removeSecondaryWorktrees] removed empty grouping directory ${parent}`);
        }
        catch (error) {
            // Cleanup is best-effort; a failure here must not fail the overall
            // command, so it is logged with context and the batch continues.
            const detail = error instanceof Error ? error.message : "unknown error";
            output.appendLine(`[removeSecondaryWorktrees] grouping-directory cleanup skipped for ${parent}: ${detail}`);
        }
    }
    const summary = { removed, skipped, removedEmptyParents };
    output.appendLine(`[removeSecondaryWorktrees] ${(0, remove_worktrees_1.buildRemovalSummaryMessage)(summary)}`);
    return summary;
}
