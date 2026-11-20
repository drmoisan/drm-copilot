# Stage G Python Test Baseline (P0-T3, Phase 0 baseline)

Timestamp: 2026-11-08T03-35
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov (one run, from the worktree root; launcher stored under SCRATCH); total branch figures read from the BRF and BRH records of artifacts/python/lcov.info by a reader script under SCRATCH
EXIT_CODE: 0
Output Summary:
  Run 03-35 to 03-38 UTC: 16270 passed, 0 failed, 6 skipped in 164.82 s. No failing test.
  Terminal TOTAL row: 33494 statements, 1008 missed, 12572 branches, 533 partial, 96%.
  Total line coverage from the TOTAL row: 96.99% (32486 of 33494 statements).
  Total branch coverage from lcov.info (368 files, summed BRF and BRH): 94.17% (11839 of 12572).
  artifacts/python/lcov.info written by the run and left on disk.
