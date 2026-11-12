# Pytest Final Gate ([P2-T4])

Timestamp: 2026-11-12T04-23
Command: sh SCRATCH/issue-1167-pytest.sh p2t4 (env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/issue-1167-p2t4-cov.json -q -p no:cacheprovider, from the item worktree root)
EXIT_CODE: 0
Output Summary:
- One pytest -n auto run: 16598 passed, 6 skipped, 0 failed, 0 errors in 167.89s (Phase 0: 16598 passed, 6 skipped, 0 failed). The run includes test_evidence_timestamp_contracts.py::test_plan_templates_carry_premortem_skeleton, test_execution_environment_brief_contracts.py, test_push_down_claude_resource_contracts.py, and test_push_down_codex_and_agents_resource_contracts.py.
- Repo-wide line coverage (JSON totals): 34334 / 35355 = 97.11% (Phase 0 baseline: 97.11%); no drop.
- Repo-wide branch coverage (JSON totals): 12668 / 13424 = 94.37% (Phase 0 baseline: 94.37%); no drop.
- Per-file production coverage: not applicable; no Python file changed or added.
