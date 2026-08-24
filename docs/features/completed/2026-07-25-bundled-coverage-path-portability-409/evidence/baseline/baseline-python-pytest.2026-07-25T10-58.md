# Baseline — Python Test and Coverage (Pytest) (issue #409)

Timestamp: 2026-07-25T10-58

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (run from the repository root)

EXIT_CODE: 0

Output Summary:
- Test counts: **2084 passed, 0 failed** in 13.61 s.
- Terminal `TOTAL` row: Stmts 12259, Miss 1105, Branch 4448, BrPart 554, Cover 89%.
- Precise numeric coverage values, read from the coverage data file `artifacts/.coverage` via `poetry run coverage json`:
  - **Line (statement) coverage: 90.99%** (`covered_lines` 11154 / `num_statements` 12259; `percent_statements_covered` 90.98621420996818).
  - **Branch coverage: 81.83%** (`covered_branches` 3640 / `num_branches` 4448; `percent_branches_covered` 81.83453237410072; `missing_branches` 808, `num_partial_branches` 554).
  - Combined coverage.py headline `percent_covered`: 88.55% (displayed as 89%).
- Threshold status against `.claude/rules/quality-tiers.md`: line 90.99% >= 85% PASS; branch 81.83% >= 75% PASS.
- Coverage LCOV written by the configured `addopts` to `artifacts/python/lcov.info`.

Auxiliary command used only to obtain the precise numeric values (the terminal report displays rounded integers):
`poetry run coverage json --data-file=artifacts/.coverage -o artifacts/python/cov-baseline-409.json` (EXIT_CODE 0)
