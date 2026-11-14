# Stage F Python Test Gate (P3-T3, compared with the Phase 0 baseline)

Timestamp: 2026-11-07T23-39
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov (one run, from the worktree root; launcher stored under SCRATCH); branch figures from the BRF and BRH records of artifacts/python/lcov.info by SCRATCH/sf/issue-1097-sf-lcov.py; per-module counts from a collection-only listing of the five modules (no test executed); baseline: stage-f-python-test-baseline.2026-11-07T23-07.md
EXIT_CODE: 0
Output Summary:
  Run 23-39 to 23-42 UTC: 16270 passed, 0 failed, 6 skipped in 160.32 s (baseline 16218 passed, 0 failed, 6 skipped). No failing test; the 52 added tests are the 51 cases of test_plan_gate_guideline_cutoff.py and test_cutoff_value_is_identical_in_rule_file_and_both_validators.
  Module counts (all passed): test_plan_gate_guideline_cutoff.py 51 (new file), test_plan_gate_document.py 12, test_plan_gate_document_parity.py 9, test_plan_gate_document_docs.py 6, test_validate_orchestration_artifacts_plan_gates.py 12.
  scripts/dev_tools/plan_gate_document.py: terminal 146 statements, 0 missed, 100%; lines 100.00% (146 of 146), branches 100.00% (60 of 60); baseline 100.00% lines (116 of 116) and 100.00% branches (48 of 48).
  scripts/dev_tools/plan_gate_discrimination.py: 136 statements, 1 missed (216), 99%; lines 99.26% (135 of 136), branches 98.08% (51 of 52); baseline identical.
  scripts/dev_tools/validate_orchestration_artifacts.py: 149 statements, 3 missed (414, 416, 418; partial 441->445; the same three error-path lines as the baseline's 409, 411, 413 and 436->440, moved by the added lines), 97%; lines 97.99% (146 of 149), branches 92.86% (52 of 56); baseline identical.
  Each of the three files is at or above 85% line and 75% branch coverage, and none is below its baseline figure.
  Terminal TOTAL row: 33494 statements, 1008 missed, 12572 branches, 533 partial, 96% (baseline 33464, 1008, 12560, 532, 96%).
  Repo-wide from lcov.info (368 files): lines 96.99% (32486 of 33494) against 96.99% (32456 of 33464), raw 96.9905% against 96.9902%; branches 94.17% (11839 of 12572) against 94.17% (11828 of 12560). At the recorded two-decimal precision the totals are equal; the raw branch ratio is 94.1696% against 94.1720%.
  The difference is one partial arc, scripts/dev_tools/atomic_executor/cli_copilot_runtime.py 395->362 (the loop-back after the idle-timeout check of the threaded output reader, polled with a 0.1 s queue timeout), whose coverage depends on thread timing; the stage E2 gate recorded the same arc. The term-missing rows of the two runs differ only in that file, plan_gate_document.py, and validate_orchestration_artifacts.py; cli_copilot_runtime.py is absent from the diff from the merge base of origin/main and HEAD (0 matching paths). The branch's own changes add 12 branches, all covered.
  artifacts/python/lcov.info written by the run and left on disk.
