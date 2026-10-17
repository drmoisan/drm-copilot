# rc1 Final Full-Suite Coverage (P2-T5)

Timestamp: 2026-10-16T01-47
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary:
TOTAL                                                                 17638   1094   6368    505    92%
PostChangeTotalCover: 92%
================= 7104 passed, 6 skipped in 148.60s (0:02:28) =================
PostChangePassedCount: 7104
PostChangeSkippedCount: 6
FinalFailingNodes: none
Comparison: PostChangePassedCount 7104 = BaselinePassedCount 7100 + 4; PostChangeSkippedCount 6 = BaselineSkippedCount 6.
Note: the TOTAL row's partial-branch column is 505, against 504 in the P0-T14 baseline row; statements, missed statements, and branches are identical (17638, 1094, 6368).
