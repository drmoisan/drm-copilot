# Python Targeted Coverage Final QA (P8-T5)

Timestamp: 2026-09-30T15-05
Command: poetry run pytest tests/scripts/dev_tools -k "orchestrator_state" --cov=scripts.dev_tools._orchestrator_state_blocked_reason --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-523-final.json
EXIT_CODE: 0
Output Summary:
- Final line: `749 passed, 5054 deselected in 2.50s` (0 failed)
- Row: `scripts\dev_tools\_orchestrator_state_blocked_reason.py  Stmts 15  Miss 0  Branch 8  BrPart 0  Cover 100%`
- Row: `scripts\dev_tools\validate_orchestrator_state.py  Stmts 170  Miss 2  Branch 82  BrPart 2  Cover 98%  Missing 116, 130`
- TOTAL: Stmts 185, Miss 2, Branch 90, BrPart 2, Cover 99%
- The `Cover` column is combined line+branch and is not read as a line or branch figure; see P8-T6.
- Coverage JSON written to `artifacts/python/coverage-523-final.json`
