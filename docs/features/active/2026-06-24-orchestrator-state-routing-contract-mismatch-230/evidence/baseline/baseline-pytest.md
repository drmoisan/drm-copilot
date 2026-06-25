# Baseline — Pytest with Coverage

Timestamp: 2026-06-24T17-47

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output Summary:
- Tests: 1168 passed, 19 skipped, 0 failed.
- TOTAL coverage row: Stmts=8391, Miss=1218, Branch=2994, BrPart=420.
- Line coverage (TOTAL): 83%.
- Branch coverage (TOTAL): (2994 - 420) / 2994 = 85.97% (~86%).
- Routing module `scripts/dev_tools/_orchestrator_state_routing.py`:
  Stmts=128, Miss=10, Branch=68, BrPart=11, coverage 89%.

Note: The repository-wide TOTAL line coverage of 83% is the pre-existing
baseline state for this branch and is below the 85% policy threshold prior to
this change. This plan changes only JSON config, Markdown documentation, and
test files (no production Python source). The no-regression requirement
(P5-T5) is measured against this baseline.
