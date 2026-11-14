# Pytest Final Gate — [P6-T4]

Timestamp: 2026-11-14T03-42
Command: sh SCRATCH/issue-1156-pytest-final.sh (from the item worktree root, VIRTUAL_ENV unset: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:artifacts/python/coverage-final.json --junitxml=artifacts/python/junit-final.xml -q -p no:cacheprovider; coverage sources from [tool.coverage.run] source in pyproject.toml, as in [P0-T4])
EXIT_CODE: 0
Output Summary: one pytest -n auto run: 16729 passed, 6 skipped, 0 failed (171.19 s). Repo-wide line coverage 97.13% (34574/35595 statements) against the Phase 0 baseline 97.11%; repo-wide branch coverage 94.42% (12784/13540 branches) against 94.37%; both from the JSON report totals. JUnit: 16735 test cases, 0 failures, 0 errors. No new failing test. No production Python file changed, so no per-file production figure applies.

## Named test files (JUnit, artifacts/python/junit-final.xml)

| File | Cases | Failed | Skipped |
|---|---|---|---|
| test_parallel_orchestrator_surface_contracts.py | 38 | 0 | 0 |
| test_orchestrator_state_remediation_loop_parity.py | 123 | 0 | 0 |
| test_orchestrator_state_remediation_docs.py | 15 | 0 | 0 |
| test_epic_orchestrate_main_sync_contract.py | 18 | 0 | 0 |
| test_epic_orchestrator_permission_contracts.py | 1 | 0 | 0 |
| test_execution_environment_brief_contracts.py | 23 | 0 | 0 |
| test_validate_epic_orchestrator_state.py | 33 | 0 | 0 |
| test_orchestration_handoff_taskmaster_469.py | 58 | 0 | 0 |
| test_stage_timing_checkpoint_key.py | 16 | 0 | 0 |

Brief-listed mirror contract tests (`## Contract Tests That Pin Mirrored Files`):

| File | Cases | Failed |
|---|---|---|
| test_push_down_claude_resource_contracts.py | 14 | 0 |
| test_push_down_codex_and_agents_resource_contracts.py | 9 | 0 |
| test_push_down_claude_pack_manifest_completeness.py | 2 | 0 |
| test_push_down_codex_and_agents_pack_manifest_completeness.py | 2 | 0 |
| test_push_down_pack_manifest_dependency_closure.py | 18 | 0 |
| test_codex_agent_wrapper_contracts.py | 7 | 0 |
| test_codex_handoff_contract_parity.py | 5 | 0 |
| test_claude_rules_frontmatter.py | 9 | 0 |
| test_quality_checks_workflow_contracts.py | 9 | 0 |
| test_push_down_issue_824_follow_ups.py | 62 | 0 |
| test_typescript_toolchain_instruction_contracts.py | 15 | 0 |

`parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`) is exercised through `test_parallel_orchestrator_surface_contracts.py`. The Codex generator `--check` was recorded in `evidence/qa-gates/codex-generator-check.2026-11-14T02-47.md`; the edited `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` is not a Codex generator input.
