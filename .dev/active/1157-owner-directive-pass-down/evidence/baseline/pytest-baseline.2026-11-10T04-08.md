# pytest Phase 0 baseline (issue #1157)

Timestamp: 2026-11-10T04-08
Command: sh SCRATCH/issue-1157-pytest.sh baseline (in the item worktree with VIRTUAL_ENV unset: poetry run pytest -n auto -q -rfE -p no:cacheprovider)
EXIT_CODE: 0
Output Summary:
- "16590 passed, 6 skipped in 144.64s (0:02:24)"
- Failed: 0; errors: 0. Pre-existing failures: none.
- The item's new, not yet bundled files were moved out of the worktree for this run so the push-down contract tests read the pre-change tree; they were moved back afterwards.
- Coverage: N/A - no production Python file in scope
