# P2-T1 [expect-fail] INVOCATION-MODULE Against Unmodified Dispatcher

Timestamp: 2026-10-09T03-03
Command: git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py; poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- status: no output (exit 0); dispatcher unchanged
- pytest summary: `========================= 3 failed, 1 passed in 0.18s =========================` (exit 1)
- FAILED lines (verbatim):
  - FAILED tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_file_path_invocation_help_exits_zero
  - FAILED tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_file_path_invocation_validates_committed_fixture
  - FAILED tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py::test_file_path_bootstrap_appends_repo_root_once
- Traceback lines beginning `E   ModuleNotFoundError`: exactly 3, each `E   ModuleNotFoundError: No module named 'scripts.dev_tools.epic_planner_readiness'`
- Passing test: test_module_invocation_leaves_sys_path_unchanged
- Result: expected split observed (fail-before evidence for AC-1, AC-2, AC-4; AC-3 control passes)
- OPERATOR_OVERRIDE: INVOCATION-MODULE was committed at the Phase 1 boundary (commit 4dd1dcaa) before this run; the dispatcher status check is unaffected.
