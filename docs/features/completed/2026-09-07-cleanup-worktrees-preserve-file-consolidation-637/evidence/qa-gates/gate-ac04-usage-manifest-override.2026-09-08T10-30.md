# Gate — AC-04, the usage text documents CLEANUP_WT_MANIFEST_PATH

Timestamp: 2026-09-08T10-30
Task: `[P4-T8]`
Command: grep -c -F -- CLEANUP_WT_MANIFEST_PATH scripts/bash/cleanup-worktrees.sh
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: printed count `3`, which is at least 1, and the command exited 0.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -c -F -- CLEANUP_WT_MANIFEST_PATH /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/scripts/bash/cleanup-worktrees.sh'"`
- Substitute actually run: the identical `grep -c -F --` invocation executed locally in Git Bash
  against the same file by absolute path. Only the hosting shell differs.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree, and a bare `wsl`
  invocation is prohibited by binding amendment EA-1.

## The three occurrences

1. The `preserve | --preserve` entry in the `Commands:` block, which states that the manifest path
   comes from `CLEANUP_WT_MANIFEST_PATH`.
2. The `CLEANUP_WT_MANIFEST_PATH` entry in the `Environment overrides:` block, which records the
   default `artifacts/orchestration/cleanup-worktrees-manifest.json`.
3. The dispatch comment on `main`, which records that the arm takes no operand and reads the
   override instead.

The literal asserted is `CLEANUP_WT_MANIFEST_PATH`, a single-line, non-interpolated token this task
creates in that heredoc. The count was `0` before this task ran, so the assertion discriminates.

The companion override `CLEANUP_WT_JQ_BIN` and the new record shape
`PRESERVE|<worktree-path>|<source-path>|<verdict>` were added to the same heredoc in the same task
and are present in the `Environment overrides:` and `Report lines` blocks respectively.

Verdict: PASS.
