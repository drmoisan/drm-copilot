# Baseline Brief and Push-Down Contract Tests ([P0-T10])

Timestamp: 2026-11-05T23-39
Command: poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py "tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q -p no:randomly --no-cov; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 1
Output Summary:
- Pytest: 42 passed, 1 failed.
- Failed: `test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` with `assert len(copies) == 6` where `len(copies)` is 0.
- Cause (environmental, pre-existing): the test enumerates copies with `REPO_ROOT.rglob("execution-environment/SKILL.md")` and drops every path whose parts include `worktrees`. This checkout is an agent worktree under `.claude/worktrees/`, so every copy is excluded and the count is 0. The failure is independent of this feature's change and does not occur in a checkout whose path has no `worktrees` component (CI).
- The byte-identity of the six copies is also asserted by `test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical`, which passed.
- Codex generator `--check`: exit code 0.
