# P0-T11 Baseline full pytest run in coverage mode

Timestamp: 2026-10-03T09-22
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary:
- Execution mode: foreground. The plan's "run in the background" instruction was superseded by orchestrator directive (foreground execution, single Bash call, timeout 600000 ms). Elapsed: 98 s.
- "6474 passed, 6 skipped in 95.78s (0:01:35)"
- TOTAL row (verbatim): "TOTAL                                                                 17552   1118   6336    576    92%"
- FAILED lines: none. KL-510 failures: 0.
- BASELINE_FULL_PASSED: 6474
- Result: PASS
