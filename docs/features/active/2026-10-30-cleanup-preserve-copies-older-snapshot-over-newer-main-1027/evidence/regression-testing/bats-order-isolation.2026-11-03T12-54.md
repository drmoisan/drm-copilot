# Bats Order Isolation

Timestamp: 2026-11-03T12-54
Task: [P7-T5]
Route: B (local, `npx --yes bats`, Bats 1.13.0 under Git Bash), each order in one process, launched by `sh SCRATCH/issue-1027-bats.sh` from the worktree root
Command: npx --yes bats <the five files in the order below> (run once forward and once reversed)
EXIT_CODE: 0
Output Summary: both orders pass with the same 69 tests; 0 `not ok` in each.

Forward order (TAP `1..69`, 69 `ok`, 0 `not ok`, exit 0; first test `the git stub replays a scenario response for add`):
1. tests/shell/test_cleanup_worktrees_preserve.bats
2. tests/shell/test_cleanup_worktrees_preserve_eol.bats
3. tests/shell/test_cleanup_worktrees_preserve_failures.bats
4. tests/shell/test_cleanup_worktrees_preserve_merge.bats
5. tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats

Reversed order (TAP `1..69`, 69 `ok`, 0 `not ok`, exit 0; first test `the git stub replays the merge key forms`):
1. tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats
2. tests/shell/test_cleanup_worktrees_preserve_merge.bats
3. tests/shell/test_cleanup_worktrees_preserve_failures.bats
4. tests/shell/test_cleanup_worktrees_preserve_eol.bats
5. tests/shell/test_cleanup_worktrees_preserve.bats

Jest, Python reversed-order, and Pester shuffle runs are not applicable: the change touches no TypeScript, Python, or PowerShell test.
