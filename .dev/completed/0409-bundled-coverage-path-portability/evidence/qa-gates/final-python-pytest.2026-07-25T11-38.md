# Final QC — Python Test and Coverage (Pytest) (issue #409)

Timestamp: 2026-07-25T11-38

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (run from the repository root)

EXIT_CODE: 0

Output Summary:
- Test counts: **2084 passed, 0 failed** in 11.36 s. This run includes `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, which passed and therefore re-confirms byte parity of the mirrored `PoshQC.Testing.psm1` pair within the full suite.
- Terminal `TOTAL` row: Stmts 12259, Miss 1105, Branch 4448, BrPart 554, Cover 89%.
- Precise numeric coverage values (from `poetry run coverage json --data-file=artifacts/.coverage`):
  - **Line (statement) coverage: 90.99%** (`covered_lines` 11154 / `num_statements` 12259; `percent_statements_covered` 90.98621420996818).
  - **Branch coverage: 81.83%** (`covered_branches` 3640 / `num_branches` 4448; `percent_branches_covered` 81.83453237410072; `missing_branches` 808, `num_partial_branches` 554).
  - Combined coverage.py headline `percent_covered`: 88.55% (displayed as 89%).
- Comparison against the [P0-T9] baseline: line 90.99% -> 90.99%, branch 81.83% -> 81.83%, tests 2084 -> 2084. **Values are unchanged and identical**, which is the expected outcome because this change modifies no Python production code and adds no Python test; the Python surface is exercised only as the mirror-parity guard.
- Threshold status: line 90.99% >= 85% PASS; branch 81.83% >= 75% PASS.
- No files were changed by this stage, so the Python loop does not restart. The full Python loop (Black -> Ruff -> Pyright -> Pytest) completed clean in a single uninterrupted pass.
