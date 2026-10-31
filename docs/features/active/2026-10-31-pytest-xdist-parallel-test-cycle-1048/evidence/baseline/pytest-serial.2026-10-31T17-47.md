# Serial pytest baseline (#1048)

Timestamp: 2026-10-31T17-47
Command: poetry run pytest --durations=25 --junitxml=SCRATCH/issue-1048-pytest-serial-baseline.xml --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1048-serial-baseline.json --cov
EXIT_CODE: 0
Output Summary:
- Result: 15871 passed, 6 skipped, 0 failed (pytest reported 725.25 s; launcher wall-clock 735 s).
- Collected: 15877 items.
- Coverage (JSON report totals): `totals.percent_statements_covered` = 96.6940; `totals.percent_branches_covered` = 93.6298 (32144/33243 statements, 11685/12480 branches). Terminal TOTAL row: 33243 statements, 1099 missed, 12480 branches, 551 partial, 96%.
- Environment note: the first attempt exited 2 with 201 collection errors (`ModuleNotFoundError: No module named 'drm_copilot_discovery'`) because the worktree virtual environment lacked the path package; `poetry install` installed `drm-copilot-discovery` from the lock file (no lock or manifest change) and the run above was repeated.
- 25 slowest tests (call phase):
  1. 15.15s tests/discovery_runtime/test_public_source_workflow.py::test_contract_scenario_evidence_and_reports_stay_honest
  2. 14.99s tests/discovery_runtime/test_public_combined_workflow.py::test_export_then_import_transports_exact_bytes_between_workspaces
  3. 11.84s tests/discovery_runtime/test_public_host_workflow.py::test_host_workflow_completes_and_refuses_drift_and_unconsumed_grants
  4. 8.75s tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[followups-2026-09-27]
  5. 8.10s tests/discovery_runtime/test_public_combined_workflow.py::test_tampered_transport_is_refused_before_publication
  6. 7.89s tests/discovery_runtime/test_public_target_workflow.py::test_evidence_backed_parity_passes_and_reports
  7. 7.49s tests/discovery_runtime/test_public_combined_workflow.py::test_request_fixtures_are_accepted_by_the_python_authority
  8. 6.90s tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False]
  9. 6.76s tests/discovery_runtime/test_service_mutation_guards.py::test_captured_snapshot_import_uses_real_planner_and_guarded_writer
  10. 6.48s tests/discovery_runtime/test_public_source_workflow.py::test_initialization_is_a_structural_draft_and_never_overwrites
  11. 5.97s tests/discovery_runtime/test_initialization_conflicts.py::test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes
  12. 5.71s tests/discovery_runtime/test_initialization.py::test_first_combined_initialization_publishes_parity_through_real_writer
  13. 5.56s tests/schemas/discovery/test_v1_fixtures.py::test_governed_discovery_includes_conforming_excludes_non_conforming
  14. 5.36s tests/discovery_runtime/test_service_report_guards.py::test_acceptance_write_plans_complete_sources_and_selected_views
  15. 5.09s tests/discovery_runtime/test_completion_planning.py::test_paired_views_support_dry_run_replacement_and_exact_unchanged_skip
  16. 5.00s tests/discovery_runtime/test_service_host_admission.py::test_granted_link_evidence_publishes_the_linked_record
  17. 5.00s tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[followups-2026-09-27]
  18. 4.68s tests/discovery_runtime/test_service_publication.py::test_explicit_bootstrap_preserves_actual_directory_and_file_units[False]
  19. 4.63s tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files
  20. 4.60s tests/discovery_runtime/test_service_mutation_guards.py::test_extension_write_publishes_real_normalized_inventory
  21. 4.33s tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[False]
  22. 4.03s tests/discovery_runtime/test_public_source_workflow.py::test_inventory_publishes_a_current_snapshot_and_repeats_identically
  23. 4.01s tests/discovery_runtime/test_parsing_limits.py::test_default_sixteen_mib_boundary_is_enforced
  24. 3.91s tests/discovery_runtime/test_service_host_admission.py::test_granted_new_contract_publishes_with_agent_attribution
  25. 3.90s tests/discovery_runtime/test_draft_scenarios.py::test_scenario_shared_commit_and_repeatable_dry_run_have_honest_effects[False]
