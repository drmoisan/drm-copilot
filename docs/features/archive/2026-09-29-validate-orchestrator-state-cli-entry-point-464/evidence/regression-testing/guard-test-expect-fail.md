# Guard Test Expected Failure Before Guard Exists (Issue #464)

Timestamp: 2026-09-30T08-39
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py::test_validator_module_main_guard_reaches_cli_main -q -p no:cacheprovider --no-cov
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `1 failed in 0.12s`.
- Failure: `Failed: DID NOT RAISE <class 'SystemExit'>` at the `pytest.raises(SystemExit)` around `runpy.run_module(...)`, because `scripts/dev_tools/validate_orchestrator_state.py` has no `__main__` guard yet. This is the expected failure.
- EXIT_CODE 1 is pytest's exit status for test failures (the pipe used to print the tail hid the status; pytest documents 1 for failed tests).
