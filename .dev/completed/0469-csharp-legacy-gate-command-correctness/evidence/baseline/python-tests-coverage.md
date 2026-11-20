# Baseline — Python Tests and Coverage (Issue #469)

Timestamp: 2026-08-13T17-28

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (repository root)

EXIT_CODE: 0

Output Summary:
- Tests: 3774 passed, 5 skipped, 0 failed (16.19s). The 5 skips are pre-existing parameterized skips in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` for manifest cases that declare no accessor expectation.
- Combined coverage headline (term-missing TOTAL row): 90%.
- Line (statement) coverage: 92.30% (13288 covered of 14396 statements; 1108 missing). Threshold is >= 85% — met.
- Branch coverage: 84.66% (4475 covered of 5286 branches; 811 missing, 557 partial). Threshold is >= 75% — met.
- Precise numeric values were obtained from the same coverage run data via `coverage json` totals (`percent_statements_covered`, `percent_branches_covered`); the temporary JSON export was deleted after reading.
