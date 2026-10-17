# Pytest After, tests/scripts/dev_tools, Coverage (Issue #464)

Timestamp: 2026-09-30T09-50
Command: poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Final line: `5630 passed, 6 skipped in 78.17s (0:01:18)`; 0 failed. The baseline was `5609 passed, 6 skipped`; the 21 additional passes are the new CLI tests.
- TOTAL row: Stmts 16974, Miss 1127, Branch 6110, BrPart 583, Cover 92%.
- Changed-module rows: `_orchestrator_state_remediation_loop.py` 36/1/16/2/94%; `validate_orchestrator_state.py` 170/2/82/2/98%; `validate_orchestrator_state_cli.py` 33/1/4/0/97% (Stmts/Miss/Branch/BrPart/Cover).
- Environment note (issue #510): run with the gitignored batch-budget state file moved aside for the pytest process and restored byte-identical afterwards (same approach as `evidence/qa-gates/pytest-final.md`).
