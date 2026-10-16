# pytest-full-coverage

Timestamp: 2026-10-16T00-35
Command: poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
ExpectedExitCode: 0
Note: the run was piped through a grep filter that removed per-file coverage rows to limit output, so the pipeline exit status was not the pytest status; EXIT_CODE 0 is inferred from the result line `7094 passed, 6 skipped` with no failed or error entries.
Output Summary:
```
TOTAL                                                                 17638   1094   6368    504    92%
7094 passed, 6 skipped in 160.21s (0:02:40)
```
BaselineFullPassed: 7094
BaselineTotalCover: 92%
BaselineFullFailingNodes: none
Skipped (6): test_blast_radius_regression_452.py:483 (Issue #722 tolerance layer absent) and five test_parallel_manifest_bash_parity.py:231 manifest_m1_* cases; none belongs to the eight in-scope files.
