# Pass-After: Issue Repro and Cleanup Suites

Timestamp: 2026-11-03T12-41
Task: [P4-T8]
Route: B (local, `npx --yes bats`, Bats 1.13.0 under Git Bash, one process, launched by `sh SCRATCH/issue-1027-bats.sh` from the worktree root)
Command: npx --yes bats tests/shell/test_cleanup_worktrees_preserve_merge.bats tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats tests/shell/test_cleanup_worktrees_preserve.bats tests/shell/test_cleanup_worktrees_preserve_eol.bats tests/shell/test_cleanup_worktrees_preserve_failures.bats tests/shell/test_cleanup_worktrees_scan_roots.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_cli.bats
EXIT_CODE: 0
Output Summary:
- TAP plan line: `1..116`; 116 `ok`, 0 `not ok`.
- `ok 8 an older modified snapshot never overwrites newer main lines` (failed before the fix; see `fail-before-repro.2026-11-03T12-35.md`).
- Per file: preserve_merge 17, preserve_merge_fallback 7, preserve 26, preserve_eol 6, preserve_failures 13 (11 baseline plus 2 added), scan_roots 21, dirt_clear 15, cli 11.
