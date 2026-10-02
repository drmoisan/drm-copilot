# Baseline Targeted Contract Suites

Timestamp: 2026-10-02T01-17
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity" "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_orchestrate_requires_independent_expected_context" -q
EXIT_CODE: 0
Output Summary:
- Result line: `135 passed in 0.58s`
- N_targeted_passed: 135
- N_targeted_skipped: 0
- No `failed` or `error` in the result line.
