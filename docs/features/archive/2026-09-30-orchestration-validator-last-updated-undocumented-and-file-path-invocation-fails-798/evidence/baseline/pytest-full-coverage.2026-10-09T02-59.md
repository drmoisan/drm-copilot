# P0-T12 Baseline Full Pytest Coverage Run

Timestamp: 2026-10-09T02-59 (corrected to the host-clock reading; the value first written was composed and ahead of the clock)
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-798.json
EXIT_CODE: 0
Output Summary:
- Summary line: `================= 6603 passed, 6 skipped in 98.69s (0:01:38) ==================`
- BASELINE_FULL_PASSED = 6603
- Dispatcher row (verbatim): `scripts\dev_tools\validate_orchestration_artifacts.py                   148      4     56      4    96%   72, 406, 408, 410, 433->437`
- TOTAL row (verbatim): `TOTAL                                                                 17556   1111   6338    566    92%`
- FAILED lines: none
- KL-510: not observed
- Result: PASS
