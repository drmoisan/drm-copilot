# P3-T5 Python regression and back-compat tests after the fix

Timestamp: 2026-09-30T10-45
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py
EXIT_CODE: 0
Output Summary:
- Final line: `120 passed in 0.22s` (0 failed).
- Includes the 37 back-compat tests in `test_validate_orchestrator_state_blocked_reason.py`, which remain green against the modified validator, the 17 validator-level tests, the partition and classifier tests, and the corpus parity tests.
- All 14 failures recorded in `python-validator-parity-expect-fail.md` and the collection error recorded in `python-partition-expect-fail.md` now pass.
