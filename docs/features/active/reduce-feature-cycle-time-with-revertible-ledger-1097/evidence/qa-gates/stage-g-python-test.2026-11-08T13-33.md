# Stage G Python Test Final Gate (P3-T3)

Timestamp: 2026-11-08T13-29
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov (one run, from the worktree root, with VIRTUAL_ENV set to the main checkout's environment; launcher stored under SCRATCH); total branch figures read from the BRF and BRH records of artifacts/python/lcov.info by a reader script under SCRATCH
EXIT_CODE: 0
Output Summary:
  Run 13-29 to 13-33 UTC: 16537 passed, 0 failed, 6 skipped in 228.91 s (24 workers). No failing test; the push-down contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, the pack-manifest suites, `test_codex_agent_wrapper_contracts.py`) and `test_validate_policy_audit_artifact.py` are among the passed tests.
  Terminal TOTAL row: 35308 statements, 1021 missed, 13400 branches, 555 partial, 96%.
  Total line coverage from the TOTAL row: 97.11% (34287 of 35308 statements).
  Total branch coverage from lcov.info (386 files, summed BRF and BRH): 94.37% (12645 of 13400).
  artifacts/python/lcov.info written by the run and left on disk.
  Launch note: an earlier launch of the same command exited 4 before collecting any test (`unrecognized arguments: -n`), because poetry created an empty in-project environment in the item worktree; no test ran in it, so it is not a gate run. This run selected the main checkout's environment and is the one gate run.

## Comparison With the Phase 0 Baseline

Baseline: `stage-g-python-test-baseline.2026-11-08T03-38.md` (16270 passed, 0 failed, 6 skipped; line 96.99%, 32486 of 33494; branch 94.17%, 11839 of 12572; 368 lcov files). The baseline was recorded before the origin/main merge that brought in PRs #1124 and #1125.

- Failing tests: 0 before, 0 after. No new failing test.
- Test count: +267 (16270 to 16537). Stage G adds and changes no Python test, so all 267 come from the merge: the 20 test modules and `conftest.py` it added under `tests/scripts/claude-lib/docs/python/` (`test_docs_python_native_*.py`).
- Total line coverage: 96.99% to 97.11%, no drop. Total branch coverage: 94.17% to 94.37%, no drop. The 1814 added statements, 828 added branches, and 18 added lcov files are the merge's production modules under `.claude/lib/docs/python/` (`docs_python_native/*.py` and `run_docs_python_native.py`).
- Stage G changes no production Python file, so no per-file row applies.
