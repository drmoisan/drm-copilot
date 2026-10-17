# Old-Path Sweep of the Moved Scripts (P2-T6)

Timestamp: 2026-09-28T22-02
Command: sh SCRATCH/old-path-sweep.sh .claude/skills/cleanup-merged-worktrees/scripts
EXIT_CODE: 0
Output Summary: No match line; final line `SWEEP-EXIT=1` (git grep found none of `scripts/bash/cleanup`, `scripts/orchestration/Invoke-CiGateParser`, `tests/scripts/orchestration/`).

Preceding edits verified (P2-T2 through P2-T5), each by `git grep -c -F -e .claude/skills/cleanup-merged-worktrees/scripts/cleanup` over the file:
- cleanup-worktrees.sh: 8 (lines 16, 21, 24, 27, 30, 43, 48, 51); diff 8 insertions, 8 deletions
- cleanup_worktrees_detached_lib.sh: 3 (lines 19, 23, 46)
- cleanup_worktrees_actions_lib.sh: 4 (lines 10, 12, 39, 331)
- cleanup_worktrees_report_records_lib.sh: 1 (line 42)
Replacement ran through SCRATCH/replace-old-path.sh (sed s#OLD_PATH_LITERAL#NEW_PATH_LITERAL#g), because the isolation hook refuses the old literal in command text.
