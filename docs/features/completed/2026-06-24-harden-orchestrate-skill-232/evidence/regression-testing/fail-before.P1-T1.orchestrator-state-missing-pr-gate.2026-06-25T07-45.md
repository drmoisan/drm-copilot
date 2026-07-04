Timestamp: 2026-06-25T07-45
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py::test_require_complete_rejects_issue_232_without_pr_gate
EXIT_CODE: 1
Output Summary:
- Pytest collected 1 targeted test.
- The test failed before implementation because validate_orchestrator_state_text(require_complete=True) did not report a missing pr_gate error for Issue #232 completion.
- Failure assertion: assert any("pr_gate" in error for error in errors).
