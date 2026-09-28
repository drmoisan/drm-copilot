# Baseline — Shell File Line Counts (Issue #630)

Timestamp: 2026-09-07T11-00

Task: [P0-T7]

Command: `wc -l scripts/bash/*.sh`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P0-T7] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && wc -l scripts/bash/*.sh'
```

Two substitutions were applied and are recorded here:

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`. The command was run in this run's worktree, `agent-adf4f49cbc48904be`. The plan's literal path was substituted for this worktree.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the worktree-isolation guard in this environment, as recorded in the [P0-T4] artifact. The wrapper was dropped and `wc -l scripts/bash/*.sh` was run natively from the worktree root. The command and its glob operand are unchanged.

## Full Printed Table

```
  382 scripts/bash/cleanup_worktrees_actions_lib.sh
  236 scripts/bash/cleanup_worktrees_enumerate_lib.sh
  479 scripts/bash/cleanup_worktrees_lib.sh
   92 scripts/bash/cleanup-worktrees.sh
    8 scripts/bash/coverage_demo.sh
    7 scripts/bash/coverage_lib.sh
  379 scripts/bash/shell_qc_lib.sh
  103 scripts/bash/shell-qc.sh
 1686 total
```

Output Summary: The table lists **8 per-file rows plus a `total` row**. The largest per-file count is **479**, for `scripts/bash/cleanup_worktrees_lib.sh`, which is 21 lines below the 500-line cap stated in `.claude/rules/shell.md` and `.claude/rules/general-code-change.md`. No file in `scripts/bash/` exceeds the cap at the baseline. The aggregate is 1686 lines. This is the baseline against which [P7-T6] is read, where the table is expected to list 9 per-file rows after `scripts/bash/cleanup_worktrees_detached_lib.sh` is added in Phase 3.
