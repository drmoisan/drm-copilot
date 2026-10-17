# Old-Path Sweep of the cleanup Test Tree (P2-T12)

Timestamp: 2026-09-28T22-02
Command: sh SCRATCH/old-path-sweep.sh tests/shell tests/fixtures/cleanup_worktrees
EXIT_CODE: 0
Output Summary: No match line; final line `SWEEP-EXIT=1`. `git diff --numstat HEAD -- tests/shell` totals 101 insertions and 101 deletions across 19 files, matching the plan inventory of 101 lines in 19 suites.

Per-group counts of NEW_PATH_LITERAL (`git grep -c -F`), P2-T8 through P2-T11, all equal to the inventory:
- Dirt: dirt_classify 6, dirt_clear 8, dirt_content_locations 4, dirt_failclosed 4, dirt_guard_registry 4, dirt_regression 6
- Preserve: preserve 7, preserve_eol 7, preserve_failures 6
- Scan and report: report_records 6, scan_helper 2, scan_seam 2
- Core: classification 6, cli 3, consolidation 5, deletion 7, detached 7, enumeration 4, hard_failures 7
- SKILL.md (P2-T7): 8, line 9 reads `  - "Bash(bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh *)"`; sweep over SKILL.md printed `SWEEP-EXIT=1`.
