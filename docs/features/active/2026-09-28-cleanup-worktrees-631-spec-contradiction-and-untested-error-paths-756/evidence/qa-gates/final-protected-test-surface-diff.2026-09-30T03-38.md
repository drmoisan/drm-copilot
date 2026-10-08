# Final protected test surface diff (P2-T9)

Timestamp: 2026-10-08T02:32:00Z
Command: git diff origin/main --name-only -- tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/fixtures/cleanup_worktrees/stub-bin tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged tests/fixtures/cleanup_worktrees/scenarios/child_of_ancestry_probe_error ; git status --porcelain -- tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/fixtures/cleanup_worktrees/stub-bin tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged tests/fixtures/cleanup_worktrees/scenarios/child_of_ancestry_probe_error
EXIT_CODE: 0
Output Summary:
- git diff origin/main --name-only (protected surfaces): exit 0, path list: EMPTY
- git status --porcelain (protected surfaces): exit 0, path list: EMPTY
Both outputs are byte-identical to baseline-protected-test-surface-diff.2026-09-30T03-38.md (both EMPTY).
