/**
 * Pure-logic module for the "Remove Secondary Worktrees" command.
 *
 * This module contains no I/O. It must NOT import `vscode`,
 * `node:child_process`, `node:fs`, or `node:path`. All functions are pure
 * string-in / value-out transforms so they can be unit-tested without git,
 * the filesystem, or the VS Code host runtime. Git invocation and the VS Code
 * wiring live in `./remove-worktrees-runner` and `./extension` respectively.
 */

/**
 * A single worktree entry parsed from `git worktree list --porcelain`.
 *
 * `isPrimary` is true only for the first parsed block, which `git` always
 * reports as the main worktree. The primary is excluded from removal by
 * position so it can never be selected.
 */
export interface WorktreeEntry {
  readonly path: string;
  readonly isPrimary: boolean;
  readonly isLocked: boolean;
  readonly lockReason: string;
  readonly isPrunable: boolean;
  readonly pruneReason: string;
}

/**
 * The outcome of attempting to remove one secondary worktree.
 */
export interface WorktreeRemovalOutcome {
  readonly path: string;
  readonly removed: boolean;
  readonly skipReason: string | undefined;
}

/**
 * Aggregated result of a remove-all-secondary-worktrees operation.
 */
export interface WorktreeSummary {
  readonly removed: ReadonlyArray<string>;
  readonly skipped: ReadonlyArray<{
    readonly path: string;
    readonly reason: string;
  }>;
}

/**
 * Discriminated union describing whether a worktree should be skipped before a
 * `git worktree remove` is attempted.
 */
export type WorktreeRemovalClassification =
  { readonly skip: true; readonly reason: string } | { readonly skip: false };

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
export function parseWorktreePorcelain(raw: string): WorktreeEntry[] {
  // Normalize CRLF to LF so `\r\n\r\n` block separators split identically to
  // `\n\n`, then split on one-or-more blank lines.
  const normalized = raw.replace(/\r\n/g, "\n");
  const blocks = normalized.split(/\n{2,}/);

  const entries: WorktreeEntry[] = [];
  let isFirstBlock = true;

  for (const block of blocks) {
    const lines = block.split("\n").filter((line) => line.trim().length > 0);
    if (lines.length === 0) {
      // Ignore empty trailing blocks produced by trailing newlines.
      continue;
    }

    let worktreePath: string | undefined;
    let isLocked = false;
    let lockReason = "";
    let isPrunable = false;
    let pruneReason = "";

    for (const line of lines) {
      if (line.startsWith("worktree ")) {
        worktreePath = line.slice("worktree ".length).trim();
      } else if (line === "locked" || line.startsWith("locked ")) {
        isLocked = true;
        lockReason = line.slice("locked".length).trim();
      } else if (line === "prunable" || line.startsWith("prunable ")) {
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
export function selectSecondaryWorktrees(
  entries: WorktreeEntry[],
): WorktreeEntry[] {
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
export function classifyWorktreeForRemoval(
  entry: WorktreeEntry,
): WorktreeRemovalClassification {
  if (entry.isLocked) {
    const reason =
      entry.lockReason.length > 0 ? `locked: ${entry.lockReason}` : "locked";
    return { skip: true, reason };
  }

  if (entry.isPrunable) {
    const reason =
      entry.pruneReason.length > 0
        ? `working directory missing on disk: ${entry.pruneReason}`
        : "working directory missing on disk";
    return { skip: true, reason };
  }

  return { skip: false };
}

/**
 * Builds the user-facing summary message for a completed removal operation.
 *
 * @param summary The aggregated removal summary.
 * @returns A single-line report of removed and skipped worktrees.
 */
export function buildRemovalSummaryMessage(summary: WorktreeSummary): string {
  const removedCount = summary.removed.length;
  const skippedCount = summary.skipped.length;

  if (removedCount === 0 && skippedCount === 0) {
    return "No secondary worktrees found.";
  }

  if (skippedCount === 0) {
    return `Removed ${String(removedCount)} worktree(s).`;
  }

  const skippedPaths = summary.skipped.map((entry) => entry.path).join(", ");
  return `Removed ${String(removedCount)} worktree(s). Skipped ${String(
    skippedCount,
  )}: ${skippedPaths}. See output channel for details.`;
}
