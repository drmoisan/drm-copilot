# Pytest Parallel Baseline (P0-T4, Phase 0 baseline)

Timestamp: 2026-11-10T03-53
Command: sh SCRATCH/issue-1156-exec-pytest.sh baseline (from the item worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:artifacts/python/coverage-baseline.json --junitxml=artifacts/python/junit-baseline.xml -q -p no:cacheprovider; coverage sources from [tool.coverage.run] source in pyproject.toml)
EXIT_CODE: 0
Output Summary:
- Result: 16598 passed, 6 skipped, 0 failed (398.33 s), one pytest -n auto run.
- Repo-wide line coverage: 97.11% (34334/35355 statements), from the JSON report totals.
- Repo-wide branch coverage: 94.37% (12668/13424 branches), from the JSON report totals.
- Terminal TOTAL row (combined column): 96%.
- Named suites (from the JUnit report): test_parallel_orchestrator_surface_contracts 38 tests 0 failed; test_orchestrator_state_remediation_loop_parity 119 tests 0 failed.
- Push-down and mirror contract tests (brief `## Contract Tests That Pin Mirrored Files`): test_push_down_claude_resource_contracts 14/0 failed; test_push_down_codex_and_agents_resource_contracts 9/0; test_push_down_claude_pack_manifest_completeness 2/0; test_push_down_codex_and_agents_pack_manifest_completeness 2/0; test_push_down_pack_manifest_dependency_closure 18/0; test_codex_agent_wrapper_contracts 7/0; test_codex_handoff_contract_parity 5/0; test_claude_rules_frontmatter 9/0; test_quality_checks_workflow_contracts 9/0; test_push_down_issue_824_follow_ups 62/0; test_typescript_toolchain_instruction_contracts 15/0.
- The three Python test files this plan edits are test files and carry no production coverage figure.
