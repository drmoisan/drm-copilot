# Pytest Baseline, tests/scripts/dev_tools, Coverage (Issue #464)

Timestamp: 2026-09-30T08-21
Command: poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Final line: `5609 passed, 6 skipped in 91.48s (0:01:31)` (0 failed).
- TOTAL row: Stmts 16937, Miss 1126, Branch 6106, BrPart 584, Cover 91%.
- Deviation note: the planned command omits `-q -p no:cacheprovider`; both flags only reduce output and disable the pytest cache plugin, and do not change collection or coverage.
