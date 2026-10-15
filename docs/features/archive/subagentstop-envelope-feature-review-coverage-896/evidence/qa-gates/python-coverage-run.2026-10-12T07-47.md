# Python Coverage Run (P1-T1)

Timestamp: 2026-10-12T07-47
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-896.json
EXIT_CODE: 0
Output Summary:
- Pytest summary line (verbatim): `================= 6956 passed, 6 skipped in 74.24s (0:01:14) ==================`
- Counts: passed 6956, failed 0, skipped 6.
- Table header (verbatim): `Name    Stmts   Miss Branch BrPart  Cover   Missing`
- TOTAL row (verbatim): `TOTAL                                                                 17633   1094   6364    505    92%`
- Reports written: `Coverage JSON written to file artifacts/python/coverage-896.json`; `Coverage LCOV written to file artifacts/python/lcov.info`.
- KL-510 did not occur in this run (no failed node), so no `ExpectedExitCode` applies.
