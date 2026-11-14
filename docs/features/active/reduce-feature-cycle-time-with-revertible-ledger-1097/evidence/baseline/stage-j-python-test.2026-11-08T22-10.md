# Stage J Python Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-08T22-10
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-j-baseline-coverage.json --cov (from the worktree root; VIRTUAL_ENV set to the main checkout's .venv, PYTHONPATH set to packages/discovery-runtime/src of the worktree; one run; output stored under SCRATCH); figures from the JSON report totals
EXIT_CODE: 0
Output Summary:
  16590 passed, 6 skipped, 0 failed in 270.83 s. No failing test.
  Repo-wide (JSON totals): line 97.11% (34334 of 35355); branch 94.37% (12668 of 13424). Terminal TOTAL row: 96% combined.
  The stage changes no Python file, so no per-file Python figure is in scope; the push-down and dependency-closure contract tests are part of this run.
