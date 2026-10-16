# final-pytest-coverage

Timestamp: 2026-10-16T00-34
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary:

```text
TOTAL                                                                 17638   1094   6368    504    92%
```

PostChangeTotalCover: 92%
PytestResultLine: ================= 7100 passed, 6 skipped in 155.72s (0:02:35) =================
FinalFailingNodes: none

Notes: 7100 passed versus 7094 at baseline (+6 new parametrize rows in tests/scripts/dev_tools/test_workflow_npm_token_guard.py). The `-ra` short summary lists the same six SKIPPED entries as the baseline and no FAILED or ERROR lines, so the issue #510 environmental condition was not invoked and no `Issue510Check:` is recorded. The full output (transient) was captured under SCRATCH and is not committed.
