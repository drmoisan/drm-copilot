# Coverage Delta and Threshold Verification

Timestamp: 2026-07-18T11-12

Sources:
- Baseline: evidence/baseline/pytest-baseline.2026-07-17T14-37.md
- Post-change: evidence/qa-gates/pytest-final.2026-07-17T14-37.md

## Baseline (before change)
- Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
- Tests: 1679 passed.
- TOTAL: Stmts=11202, Miss=1336, Branch=4212, BrPart=550.
- Total line coverage: 88.07%.
- Total branch coverage: 86.94%.
- Combined reported total: 86%.

## Post-change (after change)
- Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
- Tests: 1713 passed (+34 new tests: 28 in the new module test file plus 6 parametrized cases).
- TOTAL: Stmts=11388, Miss=1336, Branch=4254, BrPart=550.
- Total line coverage: 88.27%.
- Total branch coverage: 87.07%.
- Combined reported total: 86%.

## New / changed-code coverage
- scripts/dev_tools/generate_acceptance_scenarios.py: Stmts=186, Miss=0, Branch=42, BrPart=0.
- New-module line coverage: 100.00%.
- New-module branch coverage: 100.00%.

## Threshold verification
- Line coverage >= 85%: total 88.27% PASS; new module 100.00% PASS.
- Branch coverage >= 75%: total 87.07% PASS; new module 100.00% PASS.
- No regression on changed lines: the only production change is the new module (100% covered) plus one additive `pyproject.toml` console-script line; total line coverage rose from 88.07% to 88.27% and total branch from 86.94% to 87.07%. No existing lines were removed or modified, so no changed-line regression.

Outcome: PASS. All coverage thresholds are met with no regression.
