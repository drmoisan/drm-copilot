# Stage E2 Python Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-07T14-25
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-pycov-base.json (one run, from the worktree root; launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Run 2026-11-07T14-22 to 14-25 UTC: 16185 passed, 0 failed, 6 skipped in 174.08 s. No failing test.
  Terminal TOTAL row: 33459 statements, 1097 missed, 12558 branches, 548 partial, 96% (combined).
  Totals: lines 96.72% (32362 of 33459); branches 93.69% (11766 of 12558), from the JSON report and the BRF/BRH records of artifacts/python/lcov.info (LH/LF 32362/33459, BRH/BRF 11766/12558), which the run left on disk.
  test_execution_environment_brief_contracts.py: 21 tests, all passed. test_codex_orchestration_contracts.py: 3 tests, all passed (per-file counts from a collection-only listing; the run had 0 failures).
