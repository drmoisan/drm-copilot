import * as cp from "node:child_process";
import * as fs from "node:fs";
import type { CommandOutput } from "./command-runtime";
import {
  buildRemovalSummaryMessage,
  classifyParentDirectoryForCleanup,
  classifyWorktreeForRemoval,
  deriveParentDirectoryPath,
  parseWorktreePorcelain,
  selectSecondaryWorktrees,
  type WorktreeSummary,
} from "./remove-worktrees";

/**
 * The result of running a single git invocation.
 */
export interface GitRunResult {
  readonly exitCode: number;
  readonly stdout: string;
  readonly stderr: string;
}

/**
 * Injectable git invocation seam for the remove-worktrees orchestration.
 *
 * The contract is that `run` RESOLVES (never rejects) on a non-zero exit code:
 * a non-zero `git worktree remove` indicates a worktree that cannot be fully
 * removed, which must be reported as skipped rather than aborting the batch.
 * `run` rejects only when the child process cannot be spawned at all.
 */
export interface GitRunner {
  run(args: ReadonlyArray<string>, cwd: string): Promise<GitRunResult>;
}

/**
 * Creates the production `GitRunner` backed by `node:child_process.spawn`.
 *
 * The runner resolves with the captured exit code, stdout, and stderr for any
 * close code (including non-zero). It rejects only on the child `error` event,
 * which signals a spawn failure. `runCommandWithOutput` from `command-runtime`
 * is intentionally not reused because it rejects on non-zero exit, which would
 * abort the batch on the first non-removable worktree.
 *
 * @returns A `GitRunner` that invokes the `git` executable on PATH.
 */
/**
 * Injectable filesystem seam for empty grouping-directory cleanup, mirroring
 * the {@link GitRunner} injection pattern so the decision logic stays pure and
 * no unit test touches the real filesystem.
 */
export interface ParentDirectoryFileSystem {
  directoryExists(path: string): boolean;
  listDirectoryEntries(path: string): ReadonlyArray<string>;
  removeEmptyDirectory(path: string): void;
}

/**
 * Creates the production {@link ParentDirectoryFileSystem} backed by `node:fs`.
 *
 * `removeEmptyDirectory` uses `fs.rmdirSync`, which refuses to remove a
 * non-empty directory, providing defense in depth beyond the pure emptiness
 * check in `classifyParentDirectoryForCleanup`.
 *
 * @returns A filesystem seam that operates on the real filesystem.
 */
export function createParentDirectoryFileSystem(): ParentDirectoryFileSystem {
  return {
    directoryExists(path: string): boolean {
      return fs.existsSync(path) && fs.statSync(path).isDirectory();
    },
    listDirectoryEntries(path: string): ReadonlyArray<string> {
      return fs.readdirSync(path);
    },
    removeEmptyDirectory(path: string): void {
      fs.rmdirSync(path);
    },
  };
}

export function createGitRunner(): GitRunner {
  return {
    run(args: ReadonlyArray<string>, cwd: string): Promise<GitRunResult> {
      return new Promise<GitRunResult>((resolve, reject) => {
        const stdoutChunks: string[] = [];
        const stderrChunks: string[] = [];
        const child = cp.spawn("git", args, {
          cwd,
          stdio: ["ignore", "pipe", "pipe"],
          shell: false,
        });

        child.stdout.on("data", (chunk: Buffer) => {
          stdoutChunks.push(chunk.toString("utf-8"));
        });

        child.stderr.on("data", (chunk: Buffer) => {
          stderrChunks.push(chunk.toString("utf-8"));
        });

        child.on("error", (error: Error) => {
          reject(error);
        });

        child.on("close", (code: number | null) => {
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
export async function removeAllSecondaryWorktrees(
  workspaceRoot: string,
  git: GitRunner,
  output: CommandOutput,
  fileSystem: ParentDirectoryFileSystem,
): Promise<WorktreeSummary> {
  const listResult = await git.run(
    ["worktree", "list", "--porcelain"],
    workspaceRoot,
  );
  if (listResult.exitCode !== 0) {
    const detail = listResult.stderr.trim();
    throw new Error(
      detail.length > 0
        ? `git worktree list failed: ${detail}`
        : "git worktree list failed.",
    );
  }

  const entries = parseWorktreePorcelain(listResult.stdout);
  const primaryEntry = entries.find((entry) => entry.isPrimary);
  const primaryWorktreePath = primaryEntry ? primaryEntry.path : "";
  const secondary = selectSecondaryWorktrees(entries);

  const removed: string[] = [];
  const skipped: Array<{ path: string; reason: string }> = [];

  for (const entry of secondary) {
    const classification = classifyWorktreeForRemoval(entry);
    if (classification.skip) {
      skipped.push({ path: entry.path, reason: classification.reason });
      output.appendLine(
        `[removeSecondaryWorktrees] skipped ${entry.path}: ${classification.reason}`,
      );
      continue;
    }

    // NON-force removal only. A non-zero exit means the worktree cannot be
    // fully removed (dirty/locked); it is recorded as skipped and left intact.
    const removeResult = await git.run(
      ["worktree", "remove", entry.path],
      workspaceRoot,
    );
    if (removeResult.exitCode === 0) {
      removed.push(entry.path);
      output.appendLine(`[removeSecondaryWorktrees] removed ${entry.path}`);
      continue;
    }

    const reason =
      removeResult.stderr.trim().length > 0
        ? removeResult.stderr.trim()
        : "git worktree remove failed";
    skipped.push({ path: entry.path, reason });
    output.appendLine(
      `[removeSecondaryWorktrees] skipped ${entry.path}: ${reason}`,
    );
  }

  // Empty grouping-directory cleanup. Derive the unique parents of the
  // successfully removed worktrees, then — for each — take a fresh listing via
  // the seam immediately before removal and let the pure classifier decide.
  const removedEmptyParents: string[] = [];
  const candidateParents: string[] = [];
  for (const removedPath of removed) {
    const parent = deriveParentDirectoryPath(removedPath);
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
      const decision = classifyParentDirectoryForCleanup({
        parentPath: parent,
        entries: entriesInParent,
        primaryWorktreePath,
      });
      if (!decision.remove) {
        output.appendLine(
          `[removeSecondaryWorktrees] left grouping directory ${parent}: ${decision.reason}`,
        );
        continue;
      }
      fileSystem.removeEmptyDirectory(parent);
      removedEmptyParents.push(parent);
      output.appendLine(
        `[removeSecondaryWorktrees] removed empty grouping directory ${parent}`,
      );
    } catch (error: unknown) {
      // Cleanup is best-effort; a failure here must not fail the overall
      // command, so it is logged with context and the batch continues.
      const detail = error instanceof Error ? error.message : "unknown error";
      output.appendLine(
        `[removeSecondaryWorktrees] grouping-directory cleanup skipped for ${parent}: ${detail}`,
      );
    }
  }

  const summary: WorktreeSummary = { removed, skipped, removedEmptyParents };
  output.appendLine(
    `[removeSecondaryWorktrees] ${buildRemovalSummaryMessage(summary)}`,
  );
  return summary;
}
