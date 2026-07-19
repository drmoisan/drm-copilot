# Phase 0 Baseline — Pytest Coverage

- Timestamp: 2026-07-18T21-15
- Task: [P0-T5]
- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- EXIT_CODE: 0

## Output Summary

- Result: 1839 passed.
- TOTAL coverage row: Stmts=11842, Miss=1318, Branch=4354, BrPart=554, Cover=86%.
- Combined coverage headline (coverage.py TOTAL): 86%.
- Derived line coverage: (11842 - 1318) / 11842 = 88.87%.
- Derived branch coverage: (4354 - 554) / 4354 = 87.28%.

Baseline line coverage 88.87% and branch coverage 87.28% both exceed the policy
thresholds (line >= 85%, branch >= 75%). The new analyzer modules do not yet exist
at baseline, so they contribute no coverage here.
