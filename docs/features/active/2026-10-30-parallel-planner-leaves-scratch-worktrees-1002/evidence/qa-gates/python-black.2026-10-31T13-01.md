# Black Check

Timestamp: 2026-10-31T13-01
Command: poetry run black --check tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
EXIT_CODE: 0
Output Summary: "1 file would be left unchanged." (Black 26.1.0, Poetry environment). The two plan-mandated long test names are wrapped with a backslash continuation inside a `# fmt: off` / `# fmt: on` region so that Black and Ruff E501 both pass without a suppression comment.
