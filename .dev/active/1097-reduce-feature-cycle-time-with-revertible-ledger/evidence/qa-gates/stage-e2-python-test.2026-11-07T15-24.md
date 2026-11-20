# Stage E2 Python Test Gate (compared with the Phase 0 baseline)

Timestamp: 2026-11-07T15-24
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-pycov-final1.json (one run, from the worktree root; launcher stored under SCRATCH); baseline: stage-e2-python-test-baseline.2026-11-07T14-25.md
EXIT_CODE: 0
Output Summary:
  Run 2026-11-07T15-19 to 15-23 UTC: 16185 passed, 0 failed, 6 skipped in 237.20 s. Baseline: 16185 passed, 0 failed, 6 skipped. Difference: none; no test passing at baseline fails.
  Named files (per-file counts from a collection-only listing; the run had 0 failures): test_execution_environment_brief_contracts.py 21 (baseline 21), test_codex_orchestration_contracts.py 3 (baseline 3), test_validate_policy_audit_artifact.py 11, test_single_pass_preflight_contracts.py 12; all passed.
  Terminal TOTAL row: 33459 statements, 1097 missed, 12558 branches, 549 partial, 96%.
  Lines: 96.72% (32362 of 33459); baseline 96.72% (32362 of 33459); difference 0.
  Branches: 93.69% (11765 of 12558) from the JSON report and the BRF/BRH records of artifacts/python/lcov.info; baseline 93.69% (11766 of 12558). At the recorded two-decimal precision the totals are equal; the raw count is one branch lower (93.6932% against 93.7012%).
  The one branch is scripts/dev_tools/atomic_executor/cli_copilot_runtime.py arc 395->362 (the loop-back after the idle-timeout check in the threaded output reader loop, polled with a 0.1 s queue timeout), whose coverage depends on thread timing. That file is absent from the diff from the merge base of origin/main and HEAD; no Python production file changed in this stage, and the stage E gate recorded the same 11765.
  artifacts/python/lcov.info written by the run and left on disk.
