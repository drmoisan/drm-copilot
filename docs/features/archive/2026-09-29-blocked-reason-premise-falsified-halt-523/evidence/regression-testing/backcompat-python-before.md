# Python Back-Compat Suite Against the Unmodified Validator (P1-T4)

Timestamp: 2026-09-30T14-40
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py -k backcompat
EXIT_CODE: 0
Output Summary: `37 passed in 0.10s`; 0 failed. 36 parametrized cases (9 stems by 4 modes) plus `test_backcompat_fixture_count_is_nine`. Count matches the plan expectation of 37.

Capture context: `scripts/dev_tools/validate_orchestrator_state.py` is unmodified (HEAD of the integration branch). The `python` section of `tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json` was produced by running that validator on each committed fixture with only one flag set per mode.
