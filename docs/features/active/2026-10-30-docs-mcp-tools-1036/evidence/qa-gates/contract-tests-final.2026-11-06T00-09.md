# Final Contract Tests, Stage 6 ([P8-T7])

Timestamp: 2026-11-06T00-09
Command: poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py "tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q -p no:randomly --no-cov -rA; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 1
Output Summary:
- Pytest: 42 passed, 1 failed.
- `test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical` passed.
- Failed: `test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` (`assert 0 == 6`). Classification: WORKTREE_PATH_ENVIRONMENT. The test excludes paths containing `worktrees`, and this checkout lives under `.claude/worktrees/`, so it finds 0 copies; the same failure is recorded in the [P0-T10] baseline. The six copies are byte-identical (same md5), which is the test's remaining assertion.
- Codex generator `--check`: exit code 0.
- Status: pending CI confirmation; [P8-T7] stays unchecked until CI on the branch is green.
