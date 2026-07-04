Timestamp: 2026-06-25T07-45
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py::test_require_complete_rejects_issue_232_stale_ci_head_sha
EXIT_CODE: 1
Output Summary:
- Pytest collected 1 targeted test.
- The test failed before implementation because validate_orchestrator_state_text(require_complete=True) did not report stale CI evidence when ci_gate.head_sha differed from pr_gate.head_sha.
- Failure assertion: assert any("ci_gate.head_sha" in error and "pr_gate.head_sha" in error for error in errors).
