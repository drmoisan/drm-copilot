# Baseline Full-Suite Pytest with Coverage (P0-T12)

Timestamp: 2026-09-27T09-14
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- TOTAL row (columns `Stmts Miss Branch BrPart Cover`):
  `TOTAL                                                               15841   1114   5760    573    91%`
- BaselineTotalCover: 91%
- Pytest result line: `====================== 5132 passed, 5 skipped in 21.01s =======================`
- BaselineFailingNodes: none
- Skipped entries in the `-ra` summary (recorded for context, not failures): 5 skips from `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` (fixtures that declare no accessor expectation).
- Tool-generated report `artifacts/python/coverage.json` (gitignored; not evidence, not committed).
