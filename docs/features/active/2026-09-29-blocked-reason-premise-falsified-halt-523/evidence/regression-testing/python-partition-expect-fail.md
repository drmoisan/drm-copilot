# P2-T6 Python partition test before the module exists (expect-fail)

Timestamp: 2026-09-30T10-40
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
- Collection error: `ERROR collecting tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py`.
- Observed class (verbatim): `E   ModuleNotFoundError: No module named 'scripts.dev_tools._orchestrator_state_blocked_reason'` (reported under `ImportError while importing test module`).
- Final line: `1 error in 0.13s`; `Interrupted: 1 error during collection`.
- Result: expected failure observed; the error names `_orchestrator_state_blocked_reason` as required.
