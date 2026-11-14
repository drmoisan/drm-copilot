# Stage D Python Test Baseline

Timestamp: 2026-11-07T09-36
Command: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-d-baseline-coverage.json, run once from the worktree root with PYTHONPATH set to the worktree's packages/discovery-runtime/src
EXIT_CODE: 0
Output Summary: 16142 passed, 6 skipped, 0 failed in 148.50 seconds. Totals from the JSON report: 33401 statements, 1097 missed, 12530 branches, 11737 covered. `artifacts/python/lcov.info` sums to lines 96.72% (32304 of 33401) and branches 93.67% (11737 of 12530). `scripts/dev_tools/_orchestrator_state_remediation_loop.py`, from the JSON report: lines 138 of 138 (100.00%), branches 73 of 74 (98.65%).
