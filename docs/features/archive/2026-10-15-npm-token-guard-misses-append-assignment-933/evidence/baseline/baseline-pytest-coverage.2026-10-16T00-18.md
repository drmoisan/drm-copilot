# baseline-pytest-coverage

Timestamp: 2026-10-16T00-18
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:

```text
TOTAL                                                                 17638   1094   6368    505    92%
```

BaselineTotalCover: 92%
PytestResultLine: ================= 7094 passed, 6 skipped in 176.95s (0:02:56) =================
BaselineFailingNodes: none

Notes: the `-ra` short summary lists six SKIPPED entries (one in tests/scripts/dev_tools/test_blast_radius_regression_452.py, five in tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py) and no FAILED or ERROR lines. The full output (transient) was captured under SCRATCH and is not committed.
