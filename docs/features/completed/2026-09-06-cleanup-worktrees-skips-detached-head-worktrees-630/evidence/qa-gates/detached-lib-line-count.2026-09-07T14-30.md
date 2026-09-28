# QA Gate — New Detached Library Against the 500-Line Cap (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P3-T8]

Command: `wc -l scripts/bash/*.sh`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P3-T8] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && wc -l scripts/bash/cleanup_worktrees_detached_lib.sh'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard. `wc` was run natively from the worktree root over the glob
   `scripts/bash/*.sh`, which is a superset of the single file the plan names: the same
   count for `cleanup_worktrees_detached_lib.sh` is read from its row, and the surrounding
   rows serve [P7-T6] from the same output.

## Raw Output

```
  406 scripts/bash/cleanup_worktrees_actions_lib.sh
  301 scripts/bash/cleanup_worktrees_detached_lib.sh
  236 scripts/bash/cleanup_worktrees_enumerate_lib.sh
  483 scripts/bash/cleanup_worktrees_lib.sh
  103 scripts/bash/cleanup-worktrees.sh
    8 scripts/bash/coverage_demo.sh
    7 scripts/bash/coverage_lib.sh
  379 scripts/bash/shell_qc_lib.sh
  103 scripts/bash/shell-qc.sh
 2026 total
```

Output Summary: The new library `scripts/bash/cleanup_worktrees_detached_lib.sh` is
**301 lines**, which is **at most 500** and therefore satisfies this task's stated
acceptance and the 500-line file-size limit in `.claude/rules/general-code-change.md`. The
file is present in the table, so the count is a measurement of an existing file rather than
an absent-file zero.
