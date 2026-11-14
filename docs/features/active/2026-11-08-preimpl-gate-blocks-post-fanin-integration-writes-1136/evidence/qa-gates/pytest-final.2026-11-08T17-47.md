# Pytest Final Gate ([P5-T4])

Timestamp: 2026-11-08T17-47
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1136-pytest-final.json --cov -q -rfE
EXIT_CODE: 0
Output Summary:
- 16538 passed, 6 skipped, 0 failed in 218.52s. Baseline [P0-T4]: 16538 passed, 6 skipped, 0 failed. No failing test.
- The run includes `test_frozen_epic_surface_matches_pinned_baseline_digest` (tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py), `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py`; none failed and the skipped count is unchanged from the baseline.
- Total line coverage (JSON report totals): 97.11% (34287 of 35308), baseline 97.11%; no drop.
- Total branch coverage (JSON report totals): 94.37% (12645 of 13400), baseline 94.37%; no drop.
