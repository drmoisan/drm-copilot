# P0-T5 Baseline line counts

Timestamp: 2026-10-02T03-34
Command: wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_report_records.bats (run with each path prefixed by the worktree root, at BASE_SHA df5eb303129a30289a7d81775fdadaa40631be63)
EXIT_CODE: 0
Output Summary:
- cleanup_worktrees_enumerate_lib.sh 252
- cleanup_worktrees_report_records_lib.sh 476
- cleanup_worktrees_preserve_lib.sh 492
- cleanup_worktrees_scan_helper.sh 182
- cleanup-worktrees.sh 234
- cleanup_worktrees_lib.sh 496
- cleanup_worktrees_dirt_lib.sh 495
- tests/shell/test_cleanup_worktrees_scan_helper.bats 101
- tests/shell/test_cleanup_worktrees_report_records.bats 132
- Result: PASS. All nine counts equal the planning-time values; the D1/D8 size budget holds.
