# QA Gate — Shell File Line Counts, Post-Change (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P7-T6]

Command: `wc -l scripts/bash/*.sh`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P7-T6] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && wc -l scripts/bash/*.sh'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard. `wc -l scripts/bash/*.sh` was run natively from the worktree
   root. The command and its glob argument are unchanged; only the wrapper and the
   working-directory change differ.

## Full Printed Table

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

## Comparison Against the Phase 0 Baseline

The [P0-T7] baseline table listed **8** per-file rows plus a `total` row. This table lists
**9** per-file rows plus a `total` row. The added row is
`scripts/bash/cleanup_worktrees_detached_lib.sh`, the library this feature creates.

Output Summary: The table lists **9 per-file rows plus a `total` row**.
**`scripts/bash/cleanup_worktrees_detached_lib.sh` is among them**, at 301 lines. The
largest per-file count is **483** (`scripts/bash/cleanup_worktrees_lib.sh`), so **no
per-file count exceeds 500** and every file in `scripts/bash/` satisfies the 500-line limit
in `.claude/rules/general-code-change.md`. The `total` row of 2026 is the sum across the
nine files and is not itself a per-file measurement, so it is not read against the cap.
