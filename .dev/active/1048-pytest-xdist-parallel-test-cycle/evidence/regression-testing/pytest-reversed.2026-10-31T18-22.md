# Full pytest suite in reversed order, one process (#1048, P2-T5)

Timestamp: 2026-10-31T18-22
Command: PYTHONPATH=SCRATCH/issue-1048-plugins ISSUE_1048_ORDER_SEED=reverse poetry run pytest -p order_plugin -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Plugin header line: `issue-1048 order plugin: mode=reverse seed=None`.
- Collected 15881 items; 15875 passed, 6 skipped, 0 failed in 222.69 s (launcher wall-clock 225 s).
- The run includes the P2-T2 fix and the P2-T1 regression test.
