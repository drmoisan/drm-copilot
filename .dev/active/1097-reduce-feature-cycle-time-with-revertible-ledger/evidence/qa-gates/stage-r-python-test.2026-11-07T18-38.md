# Stage R Python Test Gate

Timestamp: 2026-11-07T18-33
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-pycov-final1.json (one run, from the worktree root; launcher stored under SCRATCH); compared with the greatest stage-r-python-test-baseline.*.md and, per file, with the baseline run's JSON report under SCRATCH
EXIT_CODE: 0
Output Summary:
  Run 2026-11-07T18-33 to 18-36 UTC: 16204 passed, 0 failed, 6 skipped in 144.88 s. No failing test.
  Terminal TOTAL row: 33459 statements, 1008 missed, 12558 branches, 533 partial, 96% (combined column).
  Total line coverage from the Stmts and Miss columns: 96.99% (32451 of 33459). Total branch coverage from the summed BRF/BRH records of artifacts/python/lcov.info, which the run left on disk: 94.16% (11825 of 12558).
  Comparison with the Phase 0 baseline (16204 passed, 0 failed; lines 96.99%, 32451 of 33459; branches 94.17%, 11826 of 12558): no new failing test; lines unchanged; branches one fewer (11825 against 11826).
  Per-file comparison of the two JSON reports: one file differs, scripts/dev_tools/atomic_executor/cli_copilot_runtime.py, branches 62/88 to 61/88 (lines unchanged at 194/235), arc 395->362: the loop-back after the idle-timeout check in the threaded output reader, polled with a 0.1 s queue timeout, whose coverage depends on thread timing. The same arc varied in stages E2 and F1 (review note N2).
  Diff proof: git diff --name-only from the merge base of origin/main and HEAD lists no .py file and does not list cli_copilot_runtime.py; this stage changes no Python file, so the one-branch difference is not attributable to the change. No test was edited and no re-run was made, because no fix exists within this stage's scope.
