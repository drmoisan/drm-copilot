# Python Coverage Run (P2-T7, remediation cycle 2)

Timestamp: 2026-10-12T18-02

Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/issue-899-coverage-cycle2.json

EXIT_CODE: 0

Output Summary:
- Loop iteration 1.
- Pytest summary line (verbatim): `================= 7004 passed, 6 skipped in 79.35s (0:01:19) ==================`
- Counts: passed 7004, failed 0, skipped 6. No `FAILED` or `ERROR` line; KL-510 did not fail.
- TOTAL row (verbatim; columns Stmts, Miss, Branch, BrPart, Cover): `TOTAL                                                                 17633   1094   6364    505    92%`
- Report lines (verbatim):
  - `Coverage JSON written to file artifacts/python/issue-899-coverage-cycle2.json`
  - `Coverage LCOV written to file artifacts/python/lcov.info`
- Skipped nodes (6): one in `tests/scripts/dev_tools/test_blast_radius_regression_452.py:483` (issue #722 tolerance layer absent) and five in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` (fixtures declaring no accessor expectation).
- The combined `Cover` column (92%) mixes line and branch; separate line and branch percentages are derived in P2-T8.
