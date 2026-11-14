# Bats Order Isolation (loop pass 2)

Timestamp: 2026-11-03T13-03
Task: [P7-T5] (re-run after the self-review remediation)
Route: B (local, `npx --yes bats`, Bats 1.13.0 under Git Bash), each order in one process, launched by `sh SCRATCH/issue-1027-bats.sh` from the worktree root
Command: npx --yes bats <the five files in the order below> (run once forward and once reversed)
EXIT_CODE: 0
Output Summary: both orders pass with the same 71 tests; 0 `not ok` in each.

Forward order (TAP `1..71`, 71 `ok`, 0 `not ok`, exit 0):
1. tests/shell/test_cleanup_worktrees_preserve.bats
2. tests/shell/test_cleanup_worktrees_preserve_eol.bats
3. tests/shell/test_cleanup_worktrees_preserve_failures.bats
4. tests/shell/test_cleanup_worktrees_preserve_merge.bats
5. tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats

Reversed order (TAP `1..71`, 71 `ok`, 0 `not ok`, exit 0):
1. tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats
2. tests/shell/test_cleanup_worktrees_preserve_merge.bats
3. tests/shell/test_cleanup_worktrees_preserve_failures.bats
4. tests/shell/test_cleanup_worktrees_preserve_eol.bats
5. tests/shell/test_cleanup_worktrees_preserve.bats

The two remediation tests redefine `cleanup_wt_git` inside their own test process. Bats runs each test in a separate process, and both orders pass, so the redefinition does not reach another test. Jest, Python, and Pester isolation runs are not applicable.
