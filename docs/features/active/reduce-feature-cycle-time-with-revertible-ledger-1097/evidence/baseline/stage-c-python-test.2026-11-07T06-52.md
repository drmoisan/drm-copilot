# Stage C Python Test Baseline

Timestamp: 2026-11-07T06-48
Command: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-baseline-coverage.json, run once from the worktree root with PYTHONPATH set to the worktree's packages/discovery-runtime/src
EXIT_CODE: 0
Output Summary: 16115 passed, 6 skipped, 0 failed in 153.36 seconds. Totals from the JSON report: 33367 statements, 1097 missed, 12516 branches, 11722 covered. `artifacts/python/lcov.info` sums to lines 96.71% (32270 of 33367) and branches 93.66% (11722 of 12516). `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`: lines 19 of 19 (100.00%), branches 10 of 10 (100.00%). `scripts/dev_tools/validate_orchestrator_state.py`: lines 168 of 170 (98.82%), branches 80 of 82 (97.56%).
