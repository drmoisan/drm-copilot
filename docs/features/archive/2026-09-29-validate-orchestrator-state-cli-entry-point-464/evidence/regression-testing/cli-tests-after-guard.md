# CLI Tests After Guard (Issue #464)

Timestamp: 2026-09-30T08-52
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary:
- Full file: `21 passed in 0.11s`; 0 failed.
- Guard node alone: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py::test_validator_module_main_guard_reaches_cli_main -q -p no:cacheprovider --no-cov` printed `1 passed in 0.10s` (exit code 0). This node failed with `DID NOT RAISE SystemExit` before the guard (see `evidence/regression-testing/guard-test-expect-fail.md`).
- `git grep -c -F "__main__" -- scripts/dev_tools/validate_orchestrator_state.py` printed `scripts/dev_tools/validate_orchestrator_state.py:1` (it printed nothing before the edit).
