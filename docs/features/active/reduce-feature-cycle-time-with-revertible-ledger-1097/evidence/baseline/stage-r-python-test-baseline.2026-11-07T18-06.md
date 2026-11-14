# Stage R Python Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-07T18-01
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-pycov-base.json (one run, from the worktree root; launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Run 2026-11-07T18-01 to 18-05 UTC: 16204 passed, 0 failed, 6 skipped in 213.70 s. No failing test.
  Terminal TOTAL row: 33459 statements, 1008 missed, 12558 branches, 532 partial, 96% (the Cover column combines lines and branches under --cov-branch).
  Total line coverage from the Stmts and Miss columns: 96.99% (32451 of 33459).
  Total branch coverage from the summed BRF/BRH records of artifacts/python/lcov.info: 94.17% (11826 of 12558); the run left artifacts/python/lcov.info on disk (LH/LF 32451/33459 agrees).
