# Pytest Full Coverage (P2-T4)

Timestamp: 2026-10-09T04-00
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-798-r1.json
EXIT_CODE: 0
Output Summary:
- Loop iteration 1.
- Summary line: `================= 6659 passed, 6 skipped in 73.94s (0:01:13) ==================`
- Dispatcher row: `scripts\dev_tools\validate_orchestration_artifacts.py                   149      3     56      4    97%   409, 411, 413, 436->440`
- TOTAL row: `TOTAL                                                                 17557   1110   6338    565    92%`
- Passed count 6659 equals the P1-T1 passed count (6659). Dispatcher Cover 97% (>= 97%), TOTAL Cover 92% (>= 92%).
- Probe line (P1-T3 probe, run unchanged): `FILE_LINE 97.99 FILE_BRANCH 92.86 TOTAL_LINE 93.68 TOTAL_BRANCH 87.11 MISSING_16_TO_19 [] EXECUTED_17 True LCOV_SF_OWN 1`
FINAL2_FILE_LINE 97.99
FINAL2_FILE_BRANCH 92.86
FINAL2_TOTAL_LINE 93.68
FINAL2_TOTAL_BRANCH 87.11
Comparison with FINAL_ values (P1-T3): FILE_LINE, FILE_BRANCH, TOTAL_LINE identical. TOTAL_BRANCH differs: FINAL 87.09 versus FINAL2 87.11 (+0.02). The TOTAL row's partial-branch count changed from 566 to 565 between the two runs, which is consistent with a nondeterministic branch arc elsewhere in scripts/dev_tools. The change is an increase and does not affect the dispatcher.
Acceptance additions: MISSING_16_TO_19 [] ; EXECUTED_17 True ; LCOV_SF_OWN 1 ; FINAL2_FILE_LINE >= 97.99 ; FINAL2_FILE_BRANCH >= 92.86.
