# Final QC - pytest Gate - Issue #1228 ([P2-T4])

Timestamp: 2026-11-24T06-43
Command: `sh C:/<item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/issue-1228-coverage-final.json --cov` (the launcher runs `poetry run pytest -n auto`; one parallel run; through the exit-75 retry wrapper `artifacts/issue-1228/retry.sh`, launched from `artifacts/issue-1228/qa.sh q1` with VIRTUAL_ENV unset); then `pwsh -NoProfile -File <item worktree>/artifacts/issue-1228/pyjson.ps1` over the final and the baseline JSON reports
EXIT_CODE: 0
Output Summary:
- 17104 passed, 6 skipped, 0 failed in 179.51 s. [P0-T4]: 17104 passed, 6 skipped, 0 failed. No new failing test; the count is unchanged, because the `origin/main` merge added no Python test and the item adds none.
- Named tests, all passing (0 failures in the run): `test_frozen_epic_surface_matches_pinned_baseline_digest` (in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`), `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_execution_environment_brief_contracts.py` (AC-13, AC-19).
- Repo-wide coverage from the JSON report totals: lines 35372 / 36090 = 98.01%; branches 13100 / 13722 = 95.47%; percent_covered 97.31%. [P0-T4]: lines 98.01%, branches 95.47%, percent_covered 97.31% (identical). Terminal TOTAL row: 36090 statements, 718 missed, 13722 branches, 534 partial, 97%. Not below the baseline; above 85% line and 75% branch. The item changes no Python file, so no per-file figure applies.
- The JSON report was written to the gitignored `artifacts/python/issue-1228-coverage-final.json` and copied byte-identically to SCRATCH/issue-1228-coverage-final.json (the preimplementation gate denies an absolute SCRATCH operand in the launcher command, as recorded at [P0-T4]). The first parse attempt in `qa.sh` failed (`ConvertFrom-Json` rejects the report's empty property name); the parse was repeated with `-AsHashtable` on the same report, with no test re-run.
- Queue timeouts (not failures): 5 attempts exited 75 before the run (2026-11-24T06-29 to 06-37).
- Result: PASS (AC-13, AC-17, AC-19).
