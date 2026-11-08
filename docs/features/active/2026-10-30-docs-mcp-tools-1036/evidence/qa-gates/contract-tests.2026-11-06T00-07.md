# Brief and Push-Down Contract Tests After the Brief Edit ([P7-T4])

Timestamp: 2026-11-06T00-07
Command: poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py "tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies" tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q -p no:randomly --no-cov -rA; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 1
Output Summary:
- Pytest: 42 passed, 1 failed (same counts as the [P0-T10] baseline).
- Passed, among others: `test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical`, `test_brief_has_required_headings`, `test_brief_has_no_consuming_names`, `test_brief_has_no_g11_or_g12_findings`, `test_brief_npm_run_tokens_exist_in_package_json`, and every test in `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`.
- Failed: `test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` with `assert 0 == 6`. Classification: WORKTREE_PATH_ENVIRONMENT. The test drops every path whose parts include `worktrees`, and this checkout is an agent worktree under `.claude/worktrees/`, so it finds 0 copies. The failure is the same as in the [P0-T10] baseline and is not caused by this change. The test's remaining assertion (each copy byte-equal to `.github/skills/execution-environment/SKILL.md`) holds: md5 of all six copies is identical after the edit, `fe43258b50ec159b4fafdeef50efb595`.
- Codex generator `--check`: exit code 0.
- Each of the six brief copies contains `run_docs_coverage` once (fixed-string count 1).
- Status: pending CI confirmation of `test_execution_environment_fact_is_unchanged_across_copies` on the branch; [P7-T4] is left unchecked until that CI run is green.
