# Validator Test Selection Before (Issue #464)

Timestamp: 2026-09-30T08-22
Command: poetry run pytest tests/scripts/dev_tools -k "validate_orchestrator_state and not cli" -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: `189 passed, 5426 deselected in 1.46s`; 0 failed. N = 189 is the comparison value for P3-T4.
