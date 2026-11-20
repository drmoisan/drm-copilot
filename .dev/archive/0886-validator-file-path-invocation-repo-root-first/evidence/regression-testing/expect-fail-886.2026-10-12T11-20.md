# Expect-fail run before the production change (issue #886)

Timestamp: 2026-10-12T11-20

ExpectedExitCode: 1

Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py

EXIT_CODE: 1

Output Summary:
- Result line: `3 failed, 3 passed in 0.30s`.
- Failing node IDs (exactly the three required):
  - test_file_path_bootstrap_prepends_repo_root_once
  - test_file_path_bootstrap_keeps_existing_entries_in_order
  - test_file_path_invocation_prefers_worktree_over_foreign_scripts_entry
- Foreign-entry failure output contains `ModuleNotFoundError: No module named 'scripts.dev_tools'` raised at validate_orchestration_artifacts.py line 19 (the `from scripts.dev_tools.epic_planner_readiness import ...` line), proving the appended root lost to the foreign `scripts` entry.
- Passing before the fix: test_file_path_invocation_help_exits_zero, test_file_path_invocation_validates_committed_fixture, test_module_invocation_leaves_sys_path_unchanged.

Pre-fix production proof:
- git rev-parse HEAD: c0c44a5ba2b3c684ccc5acc42c332b5a81daa7d1
- git diff origin/main --stat -- scripts/dev_tools/validate_orchestration_artifacts.py: (empty output; production code is unchanged from origin/main)
