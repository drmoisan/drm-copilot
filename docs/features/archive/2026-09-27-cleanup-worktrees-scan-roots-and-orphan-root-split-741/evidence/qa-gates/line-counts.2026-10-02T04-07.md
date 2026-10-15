# P2-T4 Line limits (AC-11)

Timestamp: 2026-10-02T04-07
Command: `wc -l .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_scan_helper.bats`
EXIT_CODE: 0
Output Summary:
- Every per-file count is at most 500. PASS.

| File | Lines | D8 target | Within target |
| --- | --- | --- | --- |
| cleanup_worktrees_enumerate_lib.sh | 416 | <= 430 | yes |
| cleanup_worktrees_report_records_lib.sh | 439 | <= 450 | yes |
| cleanup_worktrees_preserve_lib.sh | 492 | <= 492 | yes |
| cleanup_worktrees_scan_helper.sh | 171 | <= 180 | yes |
| cleanup-worktrees.sh | 243 | <= 246 | yes |
| tests/shell/test_cleanup_worktrees_scan_roots.bats | 242 | <= 300 | yes |
| tests/shell/test_cleanup_worktrees_scan_helper.bats | 77 | <= 90 | yes |

- Total 2080.
