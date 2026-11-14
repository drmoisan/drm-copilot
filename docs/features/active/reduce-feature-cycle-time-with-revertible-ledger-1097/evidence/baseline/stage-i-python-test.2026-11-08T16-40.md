# Stage I Python Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-08T16-40
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-i-baseline-coverage.json --cov (from the worktree root; VIRTUAL_ENV set to the shared environment, PYTHONPATH set to packages/discovery-runtime/src of the worktree; one run; output stored under SCRATCH); per-file counts from pytest --collect-only -q, figures from the JSON report
EXIT_CODE: 0
Output Summary:
  16538 passed, 6 skipped, 0 failed in 342.64 s. No failing test.
  test_epic_wave_barrier_parity_corpus.py: 30 tests. test_validate_epic_orchestrator_state_wave_barrier.py: 25 tests. test_parallel_orchestrator_surface_contracts.py: 38 tests.
  Repo-wide (JSON totals): line 97.11% (34287 of 35308); branch 94.36% (12644 of 13400). Terminal TOTAL row: 96% combined.
  scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py: line 100.00% (35 of 35); branch 100.00% (16 of 16).
