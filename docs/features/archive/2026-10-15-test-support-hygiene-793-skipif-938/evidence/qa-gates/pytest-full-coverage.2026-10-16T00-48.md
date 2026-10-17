# pytest-full-coverage

Timestamp: 2026-10-16T00-48
Command: poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
Note: output was filtered through grep for summary rows; the pytest exit status was captured through PIPESTATUS and equals 0, matching the ExpectedExitCode (0) recorded in the baseline artifact.
Output Summary:
```
TOTAL                                                                 17638   1094   6368    504    92%
7094 passed, 6 skipped in 162.51s (0:02:42)
```
FinalFullPassed: 7094
FinalTotalCover: 92%
FinalFullFailingNodes: none
Comparison: BaselineFullPassed 7094 equals FinalFullPassed 7094; BaselineFullFailingNodes none equals FinalFullFailingNodes none. The six skipped tests are the same six as in the baseline (test_blast_radius_regression_452.py and five test_parallel_manifest_bash_parity.py cases).
