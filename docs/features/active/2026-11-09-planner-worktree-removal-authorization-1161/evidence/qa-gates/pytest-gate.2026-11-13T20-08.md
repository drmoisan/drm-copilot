# Final pytest gate ([P4-T4])

Timestamp: 2026-11-13T20-08
Command: sh SCRATCH/issue-1161-pytest.sh (in the item worktree: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-final.json --cov -q -rfE`; per-file figures read from the JSON report)
EXIT_CODE: 0
Output Summary: 16714 passed, 6 skipped, 0 failed in 266.83 s (one `pytest -n auto` run); no FAILED or ERROR line. Repo-wide (configured sources): line 97.13% (34573/35594), branch 94.42% (12784/13540); baseline line 97.11%, branch 94.38%. `scripts/dev_tools/validate_epic_planner_state.py`: line 100.00% (239/239), branch 99.21% (125/126); baseline line 100.00% (191/191), branch 99.00% (99/100).

## Per-file comparison with the Phase 0 baseline

Baseline: `evidence/baseline/pytest-gate.2026-11-10T03-33.md`.

| File | Baseline line | Final line | Baseline branch | Final branch | Thresholds 85% / 75% | No drop |
| --- | --- | --- | --- | --- | --- | --- |
| scripts/dev_tools/validate_epic_planner_state.py | 100.00% (191/191) | 100.00% (239/239) | 99.00% (99/100) | 99.21% (125/126) | PASS | PASS |
| Repo-wide | 97.11% | 97.13% | 94.38% | 94.42% | PASS | PASS |

Changed-line coverage: every added line is covered (no missing line), and the one missing branch (176->180 in the final report) is the pre-existing branch the baseline reports as 175->179, shifted one line by the in-place edit. The added `_validate_planner_worktrees` branches are therefore all covered.

## Named contract tests

The run reports 0 failures across the full suite, which includes `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `test_epic_skill_script_citations_shipped.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_codex_and_agents_customizations.py`, and the `PINNED_FROZEN_SURFACE_HASHES` rows of `test_parallel_orchestrator_surface_contracts.py` (AC-25, AC-30). The skip count equals the baseline's 6.

## Note

The JSON report path passed through the launcher's POSIX form was written beneath a `c` directory at the drive root; it was moved into SCRATCH before the per-file figures were read. No figure is affected.
