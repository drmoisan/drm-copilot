# Pairwise scenario diff

Timestamp: 2026-10-07T22-02
Command: git diff --no-index --name-status tests/fixtures/cleanup_worktrees/scenarios/child_of_not_merged tests/fixtures/cleanup_worktrees/scenarios/child_of_pairwise_probe_error (equivalent of diff -r; no plain diff available in the Bash tool)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: exit 1 (differences found). Output is exactly one line: `A	tests/fixtures/cleanup_worktrees/scenarios/child_of_pairwise_probe_error/merge-base.feature-child.feature-parent.rc`, i.e. the only difference is the added file merge-base.feature-child.feature-parent.rc (equivalent to `Only in .../child_of_pairwise_probe_error: merge-base.feature-child.feature-parent.rc`). The other 18 files are byte-identical.
