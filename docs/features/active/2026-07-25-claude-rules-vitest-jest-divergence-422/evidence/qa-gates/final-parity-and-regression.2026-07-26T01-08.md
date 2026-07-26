# Final QC — Parity Tests and Regression Module (Issue #422)

Timestamp: 2026-07-26T01-08

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts" tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py
```

EXIT_CODE: 0

Output Summary:

- Collected: 17 items
- **Passed: 17**
- Failed: 0
- Duration: 0.17s
- Verbatim result line: `17 passed in 0.17s`

Per-test results (captured with the same selection under `-v`):

| # | Test | Result |
|---|---|---|
| 1 | `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | PASSED |
| 2 | `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` | PASSED |
| 3 | `test_mirror_does_not_name_the_vitest_framework[.claude/rules/typescript.md]` | PASSED |
| 4 | `test_mirror_does_not_name_the_vitest_framework[.claude/rules/general-unit-test.md]` | PASSED |
| 5 | `test_mirror_does_not_name_the_vitest_framework[.claude/rules/general-code-change.md]` | PASSED |
| 6 | `test_mirror_does_not_name_the_vitest_framework[.claude/agents/atomic-executor.md]` | PASSED |
| 7 | `test_mirror_does_not_name_the_vitest_framework[.agents/skills/general-unit-test/SKILL.md]` | PASSED |
| 8 | `test_mirror_does_not_name_the_vitest_framework[.agents/skills/general-code-change/SKILL.md]` | PASSED |
| 9 | `test_mirror_does_not_reference_the_vitest_api[.claude/rules/typescript.md]` | PASSED |
| 10 | `test_mirror_does_not_reference_the_vitest_api[.claude/rules/general-unit-test.md]` | PASSED |
| 11 | `test_mirror_does_not_reference_the_vitest_api[.claude/rules/general-code-change.md]` | PASSED |
| 12 | `test_mirror_does_not_reference_the_vitest_api[.claude/agents/atomic-executor.md]` | PASSED |
| 13 | `test_mirror_does_not_reference_the_vitest_api[.agents/skills/general-unit-test/SKILL.md]` | PASSED |
| 14 | `test_mirror_does_not_reference_the_vitest_api[.agents/skills/general-code-change/SKILL.md]` | PASSED |
| 15 | `test_typescript_rule_npm_commands_resolve_to_root_package_scripts` | PASSED |
| 16 | `test_typescript_rule_testing_line_names_the_unit_test_command` | PASSED |
| 17 | `test_typescript_rule_coverage_line_names_the_coverage_command` | PASSED |

Aggregate per-target counts:
- `.claude/**` parity test: 1 collected, 1 passed.
- `.agents/**` parity test: 1 collected, 1 passed.
- New regression module: 15 collected, 15 passed.

This run is after the Phase 5 `poetry run black .` repo-wide write pass, so it confirms that the final QA loop did not disturb repo-root/bundled parity or the corrected instruction text.
