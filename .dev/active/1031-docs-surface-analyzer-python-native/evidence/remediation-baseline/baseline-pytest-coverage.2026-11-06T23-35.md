# [P0-T9] Merged-tree re-capture of the [P0-T4] suite baseline

Timestamp: 2026-11-06T23-35
Command: poetry run python -m pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-baseline-coverage.json --cov
EXIT_CODE: 0
Output Summary: 16307 passed, 0 failed, 6 skipped in 685.17 s. JSON totals: line 96.82% (34026/35142), branch 93.83% (12521/13344), percent_covered 96.00. The test that failed in the pre-merge baseline (test_execution_environment_fact_is_unchanged_across_copies) passes on the merged tree.
