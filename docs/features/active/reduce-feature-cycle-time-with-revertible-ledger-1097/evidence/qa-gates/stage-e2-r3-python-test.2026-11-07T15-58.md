# Stage E2 R3 Python Test Gate (compared with the Phase 0 baseline)

Timestamp: 2026-11-07T15-58
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-f-coverage.json (one run, from the worktree root; launcher stored under SCRATCH); baseline: stage-e2-python-test-baseline.2026-11-07T14-25.md
EXIT_CODE: 0
Output Summary:
  Run 2026-11-07T15-54 to 15-58 UTC: 16185 passed, 0 failed, 6 skipped in 200.62 s. Baseline: 16185 passed, 0 failed, 6 skipped. Difference: none; no test passing at baseline fails.
  Terminal TOTAL row: 33459 statements, 1097 missed, 12558 branches, 548 partial, 96% (combined). Baseline TOTAL row: 33459, 1097, 12558, 548, 96%.
  Lines: 96.72% (32362 of 33459) from the LH/LF records of artifacts/python/lcov.info; baseline 96.72% (32362 of 33459); difference 0.
  Branches: 93.69% (11766 of 12558) from the BRH/BRF records of artifacts/python/lcov.info; baseline 93.69% (11766 of 12558); difference 0. The timing-dependent arc 395->362 of scripts/dev_tools/atomic_executor/cli_copilot_runtime.py (review note N2) was covered in this run, so no one-branch difference appears.
  The Codex generator and bundle contract tests are inside the run with 0 failures. No Python production file changed in this cycle.
  artifacts/python/lcov.info written by the run and left on disk.
