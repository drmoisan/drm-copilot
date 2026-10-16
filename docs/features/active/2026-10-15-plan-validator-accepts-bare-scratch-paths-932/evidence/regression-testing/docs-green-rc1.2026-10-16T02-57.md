# Documentation, Contract, Push-Down, and Frontmatter Suites (Remediation Cycle 1)

Timestamp: 2026-10-16T02-57
Task: [P4-T5]
Command: poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
EXIT_CODE: 0
Output Summary:

- `55 passed in 1.16s`; 0 failed. Case applied: 0 failed (the #510 node did not fail locally).
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical PASSED`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED`

Object IDs from [P4-T3] (`git hash-object`):

- `.claude/rules/plan-acceptance-gates.md`: `4ed1c30492cfd452c925072003b609adfd7dfd72`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`: `4ed1c30492cfd452c925072003b609adfd7dfd72`

The two object IDs are equal. [P4-T3] used the `cp` command; the Read-plus-Write fallback was not needed.
