# Pytest Coverage Run (P1-T1)

Timestamp: 2026-10-09T03-57
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-798-r1.json
EXIT_CODE: 0
Output Summary:
- Summary line: `================= 6659 passed, 6 skipped in 92.97s (0:01:32) ==================`
- Dispatcher row: `scripts\dev_tools\validate_orchestration_artifacts.py                   149      3     56      4    97%   409, 411, 413, 436->440`
- TOTAL row: `TOTAL                                                                 17557   1110   6338    566    92%`
- Passed count 6659, no failures; dispatcher Cover 97% (>= 97%), TOTAL Cover 92% (>= 92%).
