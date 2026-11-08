# Stage H Python Test Gate

Timestamp: 2026-11-08T15-15
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov (VIRTUAL_ENV set to the shared environment, PYTHONPATH set to packages/discovery-runtime/src of the worktree; one run; output stored under SCRATCH); artifacts/python/lcov.info left on disk
EXIT_CODE: 0
Output Summary:
  16537 passed, 6 skipped, 0 failed in 500.20 s. Baseline (stage-h-python-test, Phase 0): 16537 passed, 6 skipped, 0 failed. No new failing test.
  Repo-wide coverage from the terminal TOTAL row: 96% (35308 statements, 1021 missed; 13400 branches, 555 partial); identical to the baseline row.
  artifacts/python/lcov.info is byte-identical to the Phase 0 copy, so no per-file figure moved; no Python production file changed.
  The tests named in the plan (test_single_pass_preflight_contracts.py, test_codex_agent_wrapper_contracts.py, the push-down resource contract tests, test_plan_gate_document_docs.py, test_claude_planning_integrity_contracts.py) are part of the run and passed.
