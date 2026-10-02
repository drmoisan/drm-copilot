# Python Targeted Tests with Coverage Baseline (P0-T10)

Timestamp: 2026-09-30T14-19
Command: poetry run pytest tests/scripts/dev_tools -k "orchestrator_state" --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-523-baseline.json
EXIT_CODE: 0
Output Summary:
- Final line: `597 passed, 5054 deselected in 7.11s` (0 failed)
- Terminal-table row: `scripts\dev_tools\validate_orchestrator_state.py  Stmts 170  Miss 2  Branch 82  BrPart 2  Cover 98%  Missing 124, 138`
- Coverage JSON written to `artifacts/python/coverage-523-baseline.json`
