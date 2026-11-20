# Baseline Bats: Cleanup Suites

Timestamp: 2026-11-03T12-10
Task: [P0-T4]
Route: B (local, `npx --yes bats`, Bats 1.13.0 under Git Bash), one process per file
Command: npx --yes bats tests/shell/test_cleanup_worktrees_<suite>.bats (run once for each of the six suites below)
EXIT_CODE: 0
Output Summary: 90 tests across six files, 90 `ok`, 0 `not ok`.

| File | TAP plan | ok | not ok | Tests | Exit |
|---|---|---|---|---|---|
| tests/shell/test_cleanup_worktrees_preserve.bats | 1..26 | 26 | 0 | 26 | 0 |
| tests/shell/test_cleanup_worktrees_preserve_eol.bats | 1..6 | 6 | 0 | 6 | 0 |
| tests/shell/test_cleanup_worktrees_preserve_failures.bats | 1..11 | 11 | 0 | 11 | 0 |
| tests/shell/test_cleanup_worktrees_scan_roots.bats | 1..21 | 21 | 0 | 21 | 0 |
| tests/shell/test_cleanup_worktrees_dirt_clear.bats | 1..15 | 15 | 0 | 15 | 0 |
| tests/shell/test_cleanup_worktrees_cli.bats | 1..11 | 11 | 0 | 11 | 0 |
