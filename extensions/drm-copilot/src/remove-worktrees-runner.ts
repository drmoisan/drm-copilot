import * as cp from "node:child_process";
import type { CommandOutput } from "./command-runtime";
import {
  buildRemovalSummaryMessage,
  classifyWorktreeForRemoval,
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
 * @param workspaceRoot The repository root used as the git working directory.
 * @param git The injectable git runner.
 * @param output The output sink for per-worktree progress lines.
 * @returns The aggregated removal summary.
 * @throws Error when `git worktree list --porcelain` exits non-zero.
 */
export async function removeAllSecondaryWorktrees(
  workspaceRoot: string,
  git: GitRunner,
  output: CommandOutput,
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

  const summary: WorktreeSummary = { removed, skipped };
  output.appendLine(
    `[removeSecondaryWorktrees] ${buildRemovalSummaryMessage(summary)}`,
  );
  return summary;
}
