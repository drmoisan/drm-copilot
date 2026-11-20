# Stage F Python Test Baseline (Phase 0)

Timestamp: 2026-11-07T23-04
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov (one run, from the worktree root; launcher stored under SCRATCH); per-file and total branch figures read from the BRF and BRH records of artifacts/python/lcov.info by SCRATCH/sf/issue-1097-sf-lcov.py
EXIT_CODE: 0
Output Summary:
  Run 23-04 to 23-07 UTC: 16218 passed, 0 failed, 6 skipped in 166.64 s. No failing test.
  scripts/dev_tools/plan_gate_document.py: terminal table 116 statements, 0 missed, 100%; lines 100.00% (116 of 116), branches 100.00% (48 of 48, BRF/BRH).
  scripts/dev_tools/plan_gate_discrimination.py: 136 statements, 1 missed (216), 99%; lines 99.26% (135 of 136), branches 98.08% (51 of 52).
  scripts/dev_tools/validate_orchestration_artifacts.py: 149 statements, 3 missed (409, 411, 413; partial 436->440), 97%; lines 97.99% (146 of 149), branches 92.86% (52 of 56).
  Terminal TOTAL row: 33464 statements, 1008 missed, 12560 branches, 532 partial, 96%.
  Repo-wide from lcov.info (368 files): lines 96.99% (32456 of 33464), branches 94.17% (11828 of 12560).
  artifacts/python/lcov.info written by the run and left on disk.
