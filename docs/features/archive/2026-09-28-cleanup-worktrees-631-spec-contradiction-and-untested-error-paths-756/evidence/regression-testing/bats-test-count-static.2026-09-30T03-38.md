# Bats test count (static)

Timestamp: 2026-10-07T22-10
Command: git grep -c '^@test ' -- tests/shell/test_cleanup_worktrees_report_records.bats (equivalent of grep -c; no plain grep available in the Bash tool)
EXIT_CODE: 0
Output Summary: printed count is 18 (tests/shell/test_cleanup_worktrees_report_records.bats:18): 10 existing tests plus N1 through N8. Each of the eight new test names also matched exactly once under `git grep -cF`. `git grep -c cleanup_wt_scan_roots` on the same file still prints 6.
