# Regression: Targeted Contract Suites (Re-run of P0-T19)

Timestamp: 2026-10-02T01-43
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity" "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_orchestrate_requires_independent_expected_context" -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Result line: `135 passed in 0.52s`; no `failed` or `error`.
- Passed 135 equals N_targeted_passed (135) from P0-T19; skipped 0 equals N_targeted_skipped (0).
- Command note: `-p no:cacheprovider` appended (no `.pytest_cache` write). Deviation D-TOOLS.
