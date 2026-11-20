# Final Contract Tests and Reversed-Order Run (Issue #1074)

Timestamp: 2026-11-04T15-50
Task: [P6-T6]
Command: sh SCRATCH/issue-1074-contracts.sh (the P4-T6 pytest command over nine contract modules, then poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check); sh SCRATCH/issue-1074-reversed.sh (poetry run pytest --collect-only on tests/scripts/dev_tools/test_execution_environment_brief_contracts.py, then one poetry run pytest -q process over the collected node IDs in reversed file order)
EXIT_CODE: 0
Output Summary:
- P4-T6 pytest command: `167 passed in 2.10s`; failed 0; exit code 0.
- Codex generator `--check`: exit code 0; failed 0.
- Reversed-order run of the changed module: 19 node IDs, `19 passed in 0.15s`; failed 0; exit code 0.
- Black check, Ruff, and Pyright on `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (Phase 4, unchanged since): Black "1 file would be left unchanged.", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations".
- Reversed node order (one process): test_brief_test_runtime_section_orders_diagnosis_before_parallelism, test_brief_test_isolation_requires_seeded_pester_shuffle, test_brief_npm_run_tokens_exist_in_package_json, test_brief_preflight_classes_include_brief_maintenance, test_brief_preflight_classes_include_changed_existing_behavior, test_brief_has_no_g11_or_g12_findings, test_brief_has_no_consuming_names, test_epic_orchestrator_is_unchanged_by_brief_wiring, test_architecture_doc_lists_brief, test_orchestrate_prerequisites_reference_brief, test_brief_is_referenced_by_copilot_base_agents, test_brief_is_listed_by_codex_base_agents, test_brief_is_preloaded_by_four_claude_agents, test_brief_ci_section_names_jobs_and_required_contexts, test_brief_batch_budget_section_states_cap_codes_and_exemptions, test_brief_states_executor_route_and_poshqc_output_limits, test_brief_states_isolation_guard_as_runtime_behavior, test_brief_has_required_headings, test_brief_copies_are_byte_identical.
