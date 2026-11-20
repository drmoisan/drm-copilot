# python-tests

Timestamp: 2026-10-18T03-51
Command: poetry run pytest -o addopts=-ra --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-python-coverage.json --junitxml=SCRATCH/issue-980-python-junit.xml
EXIT_CODE: 0
Output Summary: 7336 passed, 0 failed, 0 errors, 6 skipped; repository lines 94.111715%, branches 88.783742%; discovery lines 98.725303%, branches 97.355769%.

Working directory: .
Started: 2026-10-18T03:49:54.663479+00:00
Duration seconds: 71.469
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 7342 items

tests\schemas\discovery\test_v1_fixtures.py .................            [  0%]
tests\schemas\discovery\test_v1_schema_documents.py .................... [  0%]
..................................................                       [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli.py ...................  [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli_part2.py ........       [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli_part2_part2.py .        [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli_part3.py .............  [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli_part4.py .......        [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli_part4_part2.py ....     [  1%]
tests\scripts\dev_tools\atomic_executor\test_copilot_backoff.py ...      [  1%]
tests\scripts\dev_tools\atomic_executor\test_copilot_rate_limiter.py ..  [  1%]
tests\scripts\dev_tools\atomic_executor\test_copilot_throttling_classifier.py . [  1%]
...........                                                              [  2%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_bounded_retries.py . [  2%]
                                                                         [  2%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_ordering.py . [  2%]
                                                                         [  2%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_retry_regression.py . [  2%]
                                                                         [  2%]
tests\scripts\dev_tools\atomic_executor\test_feature_resolver.py ....... [  2%]
........                                                                 [  2%]
tests\scripts\dev_tools\atomic_executor\test_plan_discovery.py ......... [  2%]
                                                                         [  2%]
tests\scripts\dev_tools\atomic_executor\test_plan_parser.py ............ [  2%]
.........................                                                [  2%]
tests\scripts\dev_tools\atomic_executor\test_prompt_builder.py ......... [  3%]
........                                                                 [  3%]
tests\scripts\dev_tools\atomic_executor\test_pytest_expectations.py .... [  3%]
.........                                                                [  3%]
tests\scripts\dev_tools\atomic_executor\test_qc_runner.py .............. [  3%]
..........                                                               [  3%]
tests\scripts\dev_tools\atomic_executor\test_unicode_integration.py ..   [  3%]
tests\scripts\dev_tools\codex_native_converter\test_classifier.py ...... [  3%]
.                                                                        [  3%]
tests\scripts\dev_tools\codex_native_converter\test_cli_apply.py .       [  3%]
tests\scripts\dev_tools\codex_native_converter\test_cli_entrypoints.py . [  3%]
.......                                                                  [  3%]
tests\scripts\dev_tools\codex_native_converter\test_cli_review.py .      [  3%]
tests\scripts\dev_tools\codex_native_converter\test_end_to_end.py ...    [  4%]
tests\scripts\dev_tools\codex_native_converter\test_intermediate_state.py . [  4%]
..                                                                       [  4%]
tests\scripts\dev_tools\codex_native_converter\test_inventory.py ..      [  4%]
tests\scripts\dev_tools\codex_native_converter\test_mapping.py .....     [  4%]
tests\scripts\dev_tools\codex_native_converter\test_parser.py ...        [  4%]
tests\scripts\dev_tools\codex_native_converter\test_prompt_decomposition_end_to_end.py . [  4%]
..                                                                       [  4%]
tests\scripts\dev_tools\codex_native_converter\test_reporting.py .       [  4%]
tests\scripts\dev_tools\codex_native_converter\test_reporting_topology_end_to_end.py . [  4%]
                                                                         [  4%]
tests\scripts\dev_tools\codex_native_converter\test_rewrites.py ........ [  4%]
...                                                                      [  4%]
tests\scripts\dev_tools\codex_native_converter\test_section_classifier.py . [  4%]
                                                                         [  4%]
tests\scripts\dev_tools\codex_native_converter\test_section_intent.py .. [  4%]
........                                                                 [  4%]
tests\scripts\dev_tools\codex_native_converter\test_validation.py .....  [  4%]
tests\scripts\dev_tools\discovery\analyzer\test_cli.py ........          [  4%]
tests\scripts\dev_tools\discovery\analyzer\test_domain_neutrality.py ... [  4%]
.....                                                                    [  4%]
tests\scripts\dev_tools\discovery\analyzer\test_dotnet_inventory.py .... [  4%]
...............................                                          [  5%]
tests\scripts\dev_tools\discovery\analyzer\test_emitter.py ........      [  5%]
tests\scripts\dev_tools\discovery\analyzer\test_inventory.py ........... [  5%]
........                                                                 [  5%]
tests\scripts\dev_tools\discovery\analyzer\test_inventory_e2e.py ...     [  5%]
tests\scripts\dev_tools\discovery\analyzer\test_models.py .......        [  5%]
tests\scripts\dev_tools\discovery\analyzer\test_pipeline.py ...          [  5%]
tests\scripts\dev_tools\discovery\analyzer\test_source_text.py ......... [  6%]
....................................                                     [  6%]
tests\scripts\dev_tools\discovery\analyzer\test_stack_cli.py ........... [  6%]
.                                                                        [  6%]
tests\scripts\dev_tools\discovery\analyzer\test_stack_neutrality.py .... [  6%]
.........                                                                [  6%]
tests\scripts\dev_tools\discovery\analyzer\test_vsto_office.py ......... [  6%]
......................                                                   [  7%]
tests\scripts\dev_tools\discovery\test_completion_report.py .......      [  7%]
tests\scripts\dev_tools\discovery\test_coverage_report.py .......        [  7%]
tests\scripts\dev_tools\discovery\test_domain_neutrality.py ..           [  7%]
tests\scripts\dev_tools\discovery\test_domain_profile.py ............... [  7%]
................................                                         [  8%]
tests\scripts\dev_tools\discovery\test_init_cli.py ..........            [  8%]
tests\scripts\dev_tools\discovery\test_init_flow.py ............         [  8%]
tests\scripts\dev_tools\discovery\test_init_models.py ...                [  8%]
tests\scripts\dev_tools\discovery\test_io.py ....                        [  8%]
tests\scripts\dev_tools\discovery\test_package_exports.py ..             [  8%]
tests\scripts\dev_tools\discovery\test_parity_report.py .......          [  8%]
tests\scripts\dev_tools\discovery\test_profile_cli.py ........           [  8%]
tests\scripts\dev_tools\discovery\test_rendering.py .....                [  8%]
tests\scripts\dev_tools\pr_context\test_autoclose.py ............        [  8%]
tests\scripts\dev_tools\pr_context\test_autoclose_builder.py ........    [  9%]
tests\scripts\dev_tools\pr_context\test_autoclose_collector.py ......... [  9%]
...                                                                      [  9%]
tests\scripts\dev_tools\pr_context\test_issue_reference_pattern.py ..... [  9%]
......................................................                   [ 10%]
tests\scripts\dev_tools\pr_context\test_render_pr_helpers.py .....       [ 10%]
tests\scripts\dev_tools\pr_context\test_verification_evidence.py ....... [ 10%]
...............................................                          [ 10%]
tests\scripts\dev_tools\pr_context\test_verification_evidence_first_occurrence.py . [ 10%]
..............                                                           [ 11%]
tests\scripts\dev_tools\test_agentic_sync.py ...........                 [ 11%]
tests\scripts\dev_tools\test_atomic_executor_cli.py ...............      [ 11%]
tests\scripts\dev_tools\test_blast_radius_config.py .................... [ 11%]
............                                                             [ 11%]
tests\scripts\dev_tools\test_blast_radius_config_parity.py ............. [ 12%]
.......                                                                  [ 12%]
tests\scripts\dev_tools\test_blast_radius_config_tolerance_keys.py ..... [ 12%]
......                                                                   [ 12%]
tests\scripts\dev_tools\test_blast_radius_conflicts.py ................. [ 12%]
...............................                                          [ 12%]
tests\scripts\dev_tools\test_blast_radius_extraction.py ................ [ 13%]
....................................................................     [ 14%]
tests\scripts\dev_tools\test_blast_radius_extraction_rules.py .......... [ 14%]
......................................                                   [ 14%]
tests\scripts\dev_tools\test_blast_radius_historical_runs.py ........... [ 14%]
.............                                                            [ 15%]
tests\scripts\dev_tools\test_blast_radius_invariants.py ................ [ 15%]
................................................                         [ 15%]
tests\scripts\dev_tools\test_blast_radius_mandate_reads.py .........     [ 16%]
tests\scripts\dev_tools\test_blast_radius_mergeable_paths.py ........... [ 16%]
......                                                                   [ 16%]
tests\scripts\dev_tools\test_blast_radius_normalization.py ............. [ 16%]
                                                                         [ 16%]
tests\scripts\dev_tools\test_blast_radius_parity.py .................... [ 16%]
...........................................................              [ 17%]
tests\scripts\dev_tools\test_blast_radius_regression_452.py ............ [ 17%]
.............s                                                           [ 17%]
tests\scripts\dev_tools\test_blast_radius_scheduling.py ................ [ 18%]
..................                                                       [ 18%]
tests\scripts\dev_tools\test_blast_radius_scheduling_properties.py ..... [ 18%]
.......                                                                  [ 18%]
tests\scripts\dev_tools\test_blast_radius_token_shapes.py .............. [ 18%]
.....................                                                    [ 18%]
tests\scripts\dev_tools\test_blast_radius_validation.py ................ [ 19%]
.........                                                                [ 19%]
tests\scripts\dev_tools\test_blast_radius_verification_integrity.py .... [ 19%]
..                                                                       [ 19%]
tests\scripts\dev_tools\test_blast_radius_write_intent.py .............. [ 19%]
..............                                                           [ 19%]
tests\scripts\dev_tools\test_check_python_coverage_thresholds.py ....... [ 19%]
..                                                                       [ 19%]
tests\scripts\dev_tools\test_check_quality_tiers.py .................    [ 20%]
tests\scripts\dev_tools\test_ci_gate_all_checks_contracts.py ........... [ 20%]
........................                                                 [ 20%]
tests\scripts\dev_tools\test_ci_gate_epic_child_contracts.py ........... [ 20%]
...............                                                          [ 20%]
tests\scripts\dev_tools\test_claude_payload_scope_support.py ........... [ 21%]
.....                                                                    [ 21%]
tests\scripts\dev_tools\test_claude_planning_integrity_contracts.py .... [ 21%]
..                                                                       [ 21%]
tests\scripts\dev_tools\test_claude_rules_frontmatter.py ........        [ 21%]
tests\scripts\dev_tools\test_clean_devcontainer.py ....                  [ 21%]
tests\scripts\dev_tools\test_codex_agent_role_schema.py ................ [ 21%]
........................................................................ [ 22%]
........................................................................ [ 23%]
........................................................................ [ 24%]
........................................................................ [ 25%]
........................................................................ [ 26%]
........................................................................ [ 27%]
........................................................................ [ 28%]
.........................................................                [ 29%]
tests\scripts\dev_tools\test_codex_agent_wrapper_contracts.py .......    [ 29%]
tests\scripts\dev_tools\test_codex_core_manifest_closure.py .....        [ 29%]
tests\scripts\dev_tools\test_codex_full_migration_inventory.py ...       [ 29%]
tests\scripts\dev_tools\test_codex_handoff_contract_parity.py .....      [ 29%]
tests\scripts\dev_tools\test_codex_model_policy_config_parity.py ....    [ 29%]
tests\scripts\dev_tools\test_codex_model_routing_skill.py ......         [ 29%]
tests\scripts\dev_tools\test_codex_orchestration_contracts.py ...        [ 29%]
tests\scripts\dev_tools\test_codex_routing_cli_corpus.py ............... [ 29%]
.........                                                                [ 30%]
tests\scripts\dev_tools\test_codex_topology_policy_config_parity.py .... [ 30%]
                                                                         [ 30%]
tests\scripts\dev_tools\test_collect_commit_context.py ................. [ 30%]
........                                                                 [ 30%]
tests\scripts\dev_tools\test_collect_pr_context.py ....................  [ 30%]
tests\scripts\dev_tools\test_collect_pr_context_expected_exit.py ...     [ 30%]
tests\scripts\dev_tools\test_collect_pr_context_part2.py .........       [ 30%]
tests\scripts\dev_tools\test_collect_pr_context_part3.py ..              [ 30%]
tests\scripts\dev_tools\test_collect_pr_context_part4.py ..              [ 30%]
tests\scripts\dev_tools\test_collect_pr_context_part5.py ..              [ 30%]
tests\scripts\dev_tools\test_completion_gate_documentation_contracts.py . [ 30%]
.................................................                        [ 31%]
tests\scripts\dev_tools\test_compute_blast_radius.py ................... [ 31%]
................                                                         [ 32%]
tests\scripts\dev_tools\test_compute_complexity_floor.py ............... [ 32%]
.                                                                        [ 32%]
tests\scripts\dev_tools\test_copy_research_to_issue.py ..........        [ 32%]
tests\scripts\dev_tools\test_csharp_orchestration_contracts.py ......    [ 32%]
tests\scripts\dev_tools\test_dependabot_config_contract.py .....         [ 32%]
tests\scripts\dev_tools\test_epic_bounded_child_return_contract.py ..... [ 32%]
..                                                                       [ 32%]
tests\scripts\dev_tools\test_epic_kickoff_contract.py ...........        [ 32%]
tests\scripts\dev_tools\test_epic_orchestrate_main_sync_contract.py .... [ 32%]
.........                                                                [ 33%]
tests\scripts\dev_tools\test_epic_orchestrator_permission_contracts.py . [ 33%]
                                                                         [ 33%]
tests\scripts\dev_tools\test_epic_orchestrator_state_launch_binding_edges.py . [ 33%]
......                                                                   [ 33%]
tests\scripts\dev_tools\test_epic_planner_git_integrity.py ......        [ 33%]
tests\scripts\dev_tools\test_epic_planner_git_integrity_feature_indices.py . [ 33%]
.......                                                                  [ 33%]
tests\scripts\dev_tools\test_epic_planner_launch_evidence.py ........... [ 33%]
...............                                                          [ 33%]
tests\scripts\dev_tools\test_epic_planner_readiness.py ..........        [ 33%]
tests\scripts\dev_tools\test_epic_planner_readiness_edges.py ..........  [ 33%]
tests\scripts\dev_tools\test_epic_planner_readiness_filesystem.py .      [ 34%]
tests\scripts\dev_tools\test_epic_planner_readiness_relative_paths.py .. [ 34%]
............                                                             [ 34%]
tests\scripts\dev_tools\test_epic_run_kickoff_discovery_contract.py .... [ 34%]
                                                                         [ 34%]
tests\scripts\dev_tools\test_epic_wave_barrier_parity_corpus.py ........ [ 34%]
......................                                                   [ 34%]
tests\scripts\dev_tools\test_epic_wave_computation.py ........           [ 34%]
tests\scripts\dev_tools\test_evidence_timestamp_contracts.py ........... [ 34%]
....                                                                     [ 34%]
tests\scripts\dev_tools\test_execution_environment_brief_contracts.py .. [ 35%]
................                                                         [ 35%]
tests\scripts\dev_tools\test_feature_docs.py ........................... [ 35%]
........                                                                 [ 35%]
tests\scripts\dev_tools\test_fix_all.py ................                 [ 35%]
tests\scripts\dev_tools\test_fix_all_branches.py .....................   [ 36%]
tests\scripts\dev_tools\test_fix_all_failure_paths.py ............       [ 36%]
tests\scripts\dev_tools\test_fix_all_json_cancel.py ....                 [ 36%]
tests\scripts\dev_tools\test_format_json.py ....................         [ 36%]
tests\scripts\dev_tools\test_generate_acceptance_scenarios.py .......... [ 36%]
........................                                                 [ 37%]
tests\scripts\dev_tools\test_generate_codex_agent_variants.py .......... [ 37%]
.....                                                                    [ 37%]
tests\scripts\dev_tools\test_git.py .......................              [ 37%]
tests\scripts\dev_tools\test_github.py ........................          [ 38%]
tests\scripts\dev_tools\test_github_part2.py .............               [ 38%]
tests\scripts\dev_tools\test_github_part3.py ......                      [ 38%]
tests\scripts\dev_tools\test_json_config.py ...............              [ 38%]
tests\scripts\dev_tools\test_legacy_discovery_skills_contracts.py ...... [ 38%]
......................................................                   [ 39%]
tests\scripts\dev_tools\test_markdown_label_formatter.py ............... [ 39%]
...............                                                          [ 39%]
tests\scripts\dev_tools\test_minor_audit_acceptance_criteria_contracts.py . [ 39%]
..                                                                       [ 39%]
tests\scripts\dev_tools\test_new_active_feature_folder.py .............. [ 39%]
.                                                                        [ 39%]
tests\scripts\dev_tools\test_new_active_feature_folder_bug_template_preserved.py . [ 39%]
                                                                         [ 39%]
tests\scripts\dev_tools\test_new_active_feature_folder_launcher.py ..... [ 40%]
......                                                                   [ 40%]
tests\scripts\dev_tools\test_new_active_feature_folder_markdown_escape.py . [ 40%]
.                                                                        [ 40%]
tests\scripts\dev_tools\test_new_active_feature_folder_models_coverage.py . [ 40%]
.........                                                                [ 40%]
tests\scripts\dev_tools\test_new_active_feature_folder_part2.py ........ [ 40%]
......                                                                   [ 40%]
tests\scripts\dev_tools\test_new_active_feature_folder_part3.py ........ [ 40%]
..........                                                               [ 40%]
tests\scripts\dev_tools\test_new_active_feature_folder_part4.py ........ [ 40%]
..                                                                       [ 40%]
tests\scripts\dev_tools\test_new_active_feature_folder_part5.py ...      [ 40%]
tests\scripts\dev_tools\test_new_potential_bug_entry.py ................ [ 41%]
.........                                                                [ 41%]
tests\scripts\dev_tools\test_orchestration_guardrail_contracts.py ...... [ 41%]
....                                                                     [ 41%]
tests\scripts\dev_tools\test_orchestration_handoff_adapters.py ......... [ 41%]
........................                                                 [ 41%]
tests\scripts\dev_tools\test_orchestration_handoff_contract.py .......   [ 41%]
tests\scripts\dev_tools\test_orchestration_handoff_paths.py ............ [ 42%]
.                                                                        [ 42%]
tests\scripts\dev_tools\test_orchestration_handoff_provenance.py ....... [ 42%]
                                                                         [ 42%]
tests\scripts\dev_tools\test_orchestration_handoff_schema.py .........   [ 42%]
tests\scripts\dev_tools\test_orchestration_handoff_taskmaster_469.py ... [ 42%]
.....................................................                    [ 43%]
tests\scripts\dev_tools\test_orchestration_handoff_versions.py .......   [ 43%]
tests\scripts\dev_tools\test_orchestration_routing_config_parity.py .    [ 43%]
tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py .. [ 43%]
..                                                                       [ 43%]
tests\scripts\dev_tools\test_orchestrator_state_blocked_reason.py ...... [ 43%]
................................................                         [ 43%]
tests\scripts\dev_tools\test_orchestrator_state_blocked_reason_parity.py . [ 43%]
...........................................                              [ 44%]
tests\scripts\dev_tools\test_orchestrator_state_issue_adoption.py ...... [ 44%]
.........................                                                [ 44%]
tests\scripts\dev_tools\test_orchestrator_state_issue_adoption_parity.py . [ 44%]
....................................                                     [ 45%]
tests\scripts\dev_tools\test_orchestrator_state_issue_adoption_waivers.py . [ 45%]
..............                                                           [ 45%]
tests\scripts\dev_tools\test_orchestrator_state_promotion_type_parity.py . [ 45%]
..............                                                           [ 45%]
tests\scripts\dev_tools\test_orchestrator_state_remediation_accounting.py . [ 45%]
........................................................................ [ 46%]
.................................................                        [ 47%]
tests\scripts\dev_tools\test_orchestrator_state_remediation_docs.py .... [ 47%]
...........                                                              [ 47%]
tests\scripts\dev_tools\test_orchestrator_state_remediation_loop_parity.py . [ 47%]
........................................................................ [ 48%]
............                                                             [ 48%]
tests\scripts\dev_tools\test_orchestrator_state_required_keys_docs.py .. [ 48%]
..................................................                       [ 49%]
tests\scripts\dev_tools\test_orchestrator_state_routing_split.py ....... [ 49%]
..........................                                               [ 50%]
tests\scripts\dev_tools\test_parallel_abandon_bash_parity.py ........... [ 50%]
                                                                         [ 50%]
tests\scripts\dev_tools\test_parallel_abandon_token_seam.py ............ [ 50%]
..                                                                       [ 50%]
tests\scripts\dev_tools\test_parallel_cohort_barrier_parity.py ......... [ 50%]
........................                                                 [ 50%]
tests\scripts\dev_tools\test_parallel_cohort_bash_parity.py ............ [ 51%]
....................                                                     [ 51%]
tests\scripts\dev_tools\test_parallel_cohort_computation.py ............ [ 51%]
......                                                                   [ 51%]
tests\scripts\dev_tools\test_parallel_cohort_computation_errors.py ..... [ 51%]
...............                                                          [ 51%]
tests\scripts\dev_tools\test_parallel_complexity_routing_contracts.py .. [ 51%]
.........                                                                [ 51%]
tests\scripts\dev_tools\test_parallel_drift_detection.py ............... [ 52%]
................................                                         [ 52%]
tests\scripts\dev_tools\test_parallel_drift_detection_cli.py ........... [ 52%]
............                                                             [ 52%]
tests\scripts\dev_tools\test_parallel_drift_detection_cli_halt.py ....   [ 52%]
tests\scripts\dev_tools\test_parallel_drift_detection_conflicts.py ..... [ 53%]
...........                                                              [ 53%]
tests\scripts\dev_tools\test_parallel_drift_detection_quiesce.py ....... [ 53%]
..................                                                       [ 53%]
tests\scripts\dev_tools\test_parallel_drift_halt.py .................... [ 53%]
..........                                                               [ 53%]
tests\scripts\dev_tools\test_parallel_drift_parity.py .................. [ 54%]
..                                                                       [ 54%]
tests\scripts\dev_tools\test_parallel_drift_resolution.py ...            [ 54%]
tests\scripts\dev_tools\test_parallel_drift_scheduling.py ........       [ 54%]
tests\scripts\dev_tools\test_parallel_drift_timestamps.py .............. [ 54%]
......                                                                   [ 54%]
tests\scripts\dev_tools\test_parallel_issue_adoption_skill_contracts.py . [ 54%]
...............                                                          [ 54%]
tests\scripts\dev_tools\test_parallel_kickoff_contract.py .............. [ 55%]
..............                                                           [ 55%]
tests\scripts\dev_tools\test_parallel_kickoff_contract_tables.py ....... [ 55%]
..............                                                           [ 55%]
tests\scripts\dev_tools\test_parallel_kickoff_template_seam.py ......... [ 55%]
                                                                         [ 55%]
tests\scripts\dev_tools\test_parallel_lane_assertion.py ................ [ 55%]
...........................                                              [ 56%]
tests\scripts\dev_tools\test_parallel_lane_assertion_bash_parity.py .... [ 56%]
......................                                                   [ 56%]
tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py .......... [ 56%]
...................................................sssss................ [ 57%]
...........................                                              [ 58%]
tests\scripts\dev_tools\test_parallel_manifest_contract.py ............. [ 58%]
........................................................................ [ 59%]
......                                                                   [ 59%]
tests\scripts\dev_tools\test_parallel_manifest_contract_m8.py .......... [ 59%]
...............                                                          [ 59%]
tests\scripts\dev_tools\test_parallel_mergeable_cohort.py ...            [ 59%]
tests\scripts\dev_tools\test_parallel_mutation_abandon_cli.py .......... [ 59%]
.........                                                                [ 59%]
tests\scripts\dev_tools\test_parallel_mutation_admission.py ............ [ 60%]
                                                                         [ 60%]
tests\scripts\dev_tools\test_parallel_mutation_cohort_invariant_binding.py . [ 60%]
....                                                                     [ 60%]
tests\scripts\dev_tools\test_parallel_mutation_contention_properties.py . [ 60%]
............                                                             [ 60%]
tests\scripts\dev_tools\test_parallel_mutation_errors.py .....           [ 60%]
tests\scripts\dev_tools\test_parallel_mutation_pin_stability_properties.py . [ 60%]
.......................                                                  [ 60%]
tests\scripts\dev_tools\test_parallel_mutation_protocol.py ............. [ 60%]
...........................                                              [ 61%]
tests\scripts\dev_tools\test_parallel_mutation_protocol_ops.py ......... [ 61%]
................................                                         [ 61%]
tests\scripts\dev_tools\test_parallel_mutation_protocol_properties.py .. [ 61%]
........................................................................ [ 62%]
........................................................................ [ 63%]
..................................                                       [ 64%]
tests\scripts\dev_tools\test_parallel_mutation_recolor.py .............. [ 64%]
.                                                                        [ 64%]
tests\scripts\dev_tools\test_parallel_mutation_remove_bash_parity.py ... [ 64%]
...............                                                          [ 64%]
tests\scripts\dev_tools\test_parallel_mutation_run_bash_parity.py ...... [ 64%]
...................                                                      [ 65%]
tests\scripts\dev_tools\test_parallel_orchestrator_permission_contracts.py . [ 65%]
..                                                                       [ 65%]
tests\scripts\dev_tools\test_parallel_orchestrator_surface_contracts.py . [ 65%]
...................................                                      [ 65%]
tests\scripts\dev_tools\test_parallel_planner_surface_contracts.py ..... [ 65%]
...........                                                              [ 65%]
tests\scripts\dev_tools\test_parallel_planner_surface_contracts_landed.py . [ 65%]
.......                                                                  [ 65%]
tests\scripts\dev_tools\test_plan_gate_commands.py ..................    [ 66%]
tests\scripts\dev_tools\test_plan_gate_discrimination_context.py ....... [ 66%]
                                                                         [ 66%]
tests\scripts\dev_tools\test_plan_gate_discrimination_cov.py ........... [ 66%]
.......                                                                  [ 66%]
tests\scripts\dev_tools\test_plan_gate_discrimination_literals.py ...... [ 66%]
..............                                                           [ 66%]
tests\scripts\dev_tools\test_plan_gate_document.py ............          [ 66%]
tests\scripts\dev_tools\test_plan_gate_document_docs.py .....            [ 67%]
tests\scripts\dev_tools\test_plan_gate_document_parity.py .........      [ 67%]
tests\scripts\dev_tools\test_plan_gate_observability.py ................ [ 67%]
.                                                                        [ 67%]
tests\scripts\dev_tools\test_plan_gate_observability_boundaries.py ..... [ 67%]
......                                                                   [ 67%]
tests\scripts\dev_tools\test_plan_gate_parity.py .........               [ 67%]
tests\scripts\dev_tools\test_plan_gate_scratch.py ...................... [ 67%]
...............                                                          [ 68%]
tests\scripts\dev_tools\test_plan_gate_scratch_docs.py .........         [ 68%]
tests\scripts\dev_tools\test_plan_gate_scratch_whitespace.py ........... [ 68%]
                                                                         [ 68%]
tests\scripts\dev_tools\test_plan_progress_report.py ..............      [ 68%]
tests\scripts\dev_tools\test_poshqc_bundled_parity.py .                  [ 68%]
tests\scripts\dev_tools\test_potential_to_issue.py ........              [ 68%]
tests\scripts\dev_tools\test_potential_to_issue_branches.py ..........   [ 68%]
tests\scripts\dev_tools\test_potential_to_issue_bug_bodies.py ......     [ 68%]
tests\scripts\dev_tools\test_potential_to_issue_cli_and_adapters.py .... [ 69%]
.                                                                        [ 69%]
tests\scripts\dev_tools\test_potential_to_issue_content.py ...........   [ 69%]
tests\scripts\dev_tools\test_potential_to_issue_filesystem.py ........   [ 69%]
tests\scripts\dev_tools\test_potential_to_issue_missing_label_regression.py . [ 69%]
                                                                         [ 69%]
tests\scripts\dev_tools\test_potential_to_issue_move_verification.py ... [ 69%]
                                                                         [ 69%]
tests\scripts\dev_tools\test_potential_to_issue_work_modes.py .......    [ 69%]
tests\scripts\dev_tools\test_pr_context_freshness.py ...                 [ 69%]
tests\scripts\dev_tools\test_pr_context_integration.py .....             [ 69%]
tests\scripts\dev_tools\test_prompt_mode_contract.py ..............      [ 69%]
tests\scripts\dev_tools\test_push_down_claude_blast_radius_derive.py ... [ 69%]
...                                                                      [ 69%]
tests\scripts\dev_tools\test_push_down_claude_blast_radius_derive_core.py . [ 69%]
..................                                                       [ 70%]
tests\scripts\dev_tools\test_push_down_claude_blast_radius_derive_core_guard.py . [ 70%]
..........                                                               [ 70%]
tests\scripts\dev_tools\test_push_down_claude_blast_radius_derive_manifests.py . [ 70%]
.............................                                            [ 70%]
tests\scripts\dev_tools\test_push_down_claude_blast_radius_overlay.py .. [ 70%]
................................................                         [ 71%]
tests\scripts\dev_tools\test_push_down_claude_config_carriage.py ....... [ 71%]
...                                                                      [ 71%]
tests\scripts\dev_tools\test_push_down_claude_customizations.py ........ [ 71%]
......                                                                   [ 71%]
tests\scripts\dev_tools\test_push_down_claude_destination_writes.py .... [ 71%]
..............                                                           [ 71%]
tests\scripts\dev_tools\test_push_down_claude_exclusion_filter.py ...... [ 71%]
.........                                                                [ 72%]
tests\scripts\dev_tools\test_push_down_claude_exclusion_parity.py ...... [ 72%]
.......................................                                  [ 72%]
tests\scripts\dev_tools\test_push_down_claude_gitignore_delivery.py .... [ 72%]
..........                                                               [ 72%]
tests\scripts\dev_tools\test_push_down_claude_gitignore_merge.py ....... [ 73%]
.........                                                                [ 73%]
tests\scripts\dev_tools\test_push_down_claude_gitignore_parity.py .      [ 73%]
tests\scripts\dev_tools\test_push_down_claude_memory_scope.py .......... [ 73%]
..                                                                       [ 73%]
tests\scripts\dev_tools\test_push_down_claude_overlay_parity.py ....     [ 73%]
tests\scripts\dev_tools\test_push_down_claude_pack_end_to_end.py ....... [ 73%]
...                                                                      [ 73%]
tests\scripts\dev_tools\test_push_down_claude_pack_manifest_completeness.py . [ 73%]
.                                                                        [ 73%]
tests\scripts\dev_tools\test_push_down_claude_pack_memory_modes.py ....  [ 73%]
tests\scripts\dev_tools\test_push_down_claude_pack_selection.py ........ [ 73%]
...........                                                              [ 73%]
tests\scripts\dev_tools\test_push_down_claude_parity.py ............     [ 73%]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .... [ 74%]
..........                                                               [ 74%]
tests\scripts\dev_tools\test_push_down_claude_routing_merge.py ......... [ 74%]
...................                                                      [ 74%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_customizations.py . [ 74%]
.........                                                                [ 74%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_pack_manifest_completeness.py . [ 74%]
.                                                                        [ 74%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py . [ 74%]
........                                                                 [ 74%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_variant_packs.py . [ 74%]
...                                                                      [ 74%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_virtual_paths.py . [ 74%]
.....                                                                    [ 74%]
tests\scripts\dev_tools\test_push_down_codex_pack_selection.py ......... [ 75%]
...........                                                              [ 75%]
tests\scripts\dev_tools\test_push_down_copilot_customizations.py ...     [ 75%]
tests\scripts\dev_tools\test_push_down_copilot_customizations_helpers.py . [ 75%]
...............                                                          [ 75%]
tests\scripts\dev_tools\test_push_down_copilot_customizations_rewrites.py . [ 75%]
.....                                                                    [ 75%]
tests\scripts\dev_tools\test_push_down_exclusion_manifest.py ........... [ 75%]
................................................................         [ 76%]
tests\scripts\dev_tools\test_push_down_issue_824_follow_ups.py ......... [ 76%]
.....................................................                    [ 77%]
tests\scripts\dev_tools\test_push_down_tier_rule_adoption_gate.py ...... [ 77%]
........................................................................ [ 78%]
...                                                                      [ 78%]
tests\scripts\dev_tools\test_pyright_config_alignment.py ..              [ 78%]
tests\scripts\dev_tools\test_quality_checks_workflow_contracts.py ...... [ 78%]
                                                                         [ 78%]
tests\scripts\dev_tools\test_quality_tiers_contract.py ................. [ 78%]
..................                                                       [ 79%]
tests\scripts\dev_tools\test_quality_tiers_contract_classification.py .. [ 79%]
..............                                                           [ 79%]
tests\scripts\dev_tools\test_render.py ................................. [ 79%]
............                                                             [ 79%]
tests\scripts\dev_tools\test_render_helpers.py ......................... [ 80%]
...                                                                      [ 80%]
tests\scripts\dev_tools\test_render_resolve_feature_dir.py ............. [ 80%]
                                                                         [ 80%]
tests\scripts\dev_tools\test_resolve_codex_deployment.py ............... [ 80%]
........                                                                 [ 80%]
tests\scripts\dev_tools\test_resolve_codex_topology.py ................. [ 81%]
.............                                                            [ 81%]
tests\scripts\dev_tools\test_resolve_delegation_model.py ............... [ 81%]
.....                                                                    [ 81%]
tests\scripts\dev_tools\test_resolve_execute_plan_prompt.py ............ [ 81%]
..............                                                           [ 81%]
tests\scripts\dev_tools\test_resolve_execute_plan_prompt_part2.py ...... [ 81%]
.............                                                            [ 82%]
tests\scripts\dev_tools\test_resolve_execute_plan_prompt_part3.py ..     [ 82%]
tests\scripts\dev_tools\test_resolve_file_prompt.py .................... [ 82%]
.                                                                        [ 82%]
tests\scripts\dev_tools\test_resolve_hard_lock_prompt.py ............... [ 82%]
...                                                                      [ 82%]
tests\scripts\dev_tools\test_resolve_hard_lock_prompt_output.py ........ [ 82%]
.                                                                        [ 82%]
tests\scripts\dev_tools\test_resolve_hard_lock_prompt_part2.py ......    [ 82%]
tests\scripts\dev_tools\test_ruff_config_alignment.py ....               [ 82%]
tests\scripts\dev_tools\test_schema_loading.py ........                  [ 83%]
tests\scripts\dev_tools\test_scratch_location_contracts.py ............. [ 83%]
.............                                                            [ 83%]
tests\scripts\dev_tools\test_single_pass_preflight_contracts.py ........ [ 83%]
....                                                                     [ 83%]
tests\scripts\dev_tools\test_skill_bundle_contract.py .................. [ 83%]
...........                                                              [ 83%]
tests\scripts\dev_tools\test_skill_bundle_contract_cli.py .....          [ 84%]
tests\scripts\dev_tools\test_skill_bundle_contract_evaluation.py ....... [ 84%]
.....                                                                    [ 84%]
tests\scripts\dev_tools\test_skill_bundle_contract_repo.py ..........    [ 84%]
tests\scripts\dev_tools\test_typescript_toolchain_instruction_contracts.py . [ 84%]
..............                                                           [ 84%]
tests\scripts\dev_tools\test_typescript_twin_test_support.py ..          [ 84%]
tests\scripts\dev_tools\test_validate_discovery_artifacts_dispatch.py .. [ 84%]
.............                                                            [ 84%]
tests\scripts\dev_tools\test_validate_discovery_profile.py .....         [ 84%]
tests\scripts\dev_tools\test_validate_discovery_schema_artifacts.py .... [ 84%]
......                                                                   [ 85%]
tests\scripts\dev_tools\test_validate_discovery_schema_artifacts_more.py . [ 85%]
..                                                                       [ 85%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state.py ....... [ 85%]
.........................                                                [ 85%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state_codex_routing.py . [ 85%]
..                                                                       [ 85%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state_codex_topology.py . [ 85%]
....                                                                     [ 85%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state_launch_binding.py . [ 85%]
..........................                                               [ 85%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state_merge_status.py . [ 85%]
...........................                                              [ 86%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state_wave_barrier.py . [ 86%]
........................                                                 [ 86%]
tests\scripts\dev_tools\test_validate_epic_planner_state.py ............ [ 86%]
...............                                                          [ 87%]
tests\scripts\dev_tools\test_validate_epic_planner_state_feature_indices.py . [ 87%]
........                                                                 [ 87%]
tests\scripts\dev_tools\test_validate_epic_planner_state_feature_receipts.py . [ 87%]
.......                                                                  [ 87%]
tests\scripts\dev_tools\test_validate_epic_planner_state_launch_binding.py . [ 87%]
.......................                                                  [ 87%]
tests\scripts\dev_tools\test_validate_epic_planner_state_shape_errors.py . [ 87%]
.........                                                                [ 87%]
tests\scripts\dev_tools\test_validate_evidence_locations.py .......      [ 87%]
tests\scripts\dev_tools\test_validate_json.py .......................... [ 88%]
.                                                                        [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts.py ....... [ 88%]
.                                                                        [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_codex_topology_cli.py . [ 88%]
.                                                                        [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_dispatch.py . [ 88%]
........                                                                 [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_invocation.py . [ 88%]
.....                                                                    [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_model_routing.py . [ 88%]
....                                                                     [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_parallel_dispatch.py . [ 88%]
...............                                                          [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_plan_gates.py . [ 88%]
...........                                                              [ 88%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_pr_creation_readiness.py . [ 89%]
.                                                                        [ 89%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_state_shape.py . [ 89%]
.......                                                                  [ 89%]
tests\scripts\dev_tools\test_validate_orchestrator_state.py ............ [ 89%]
....                                                                     [ 89%]
tests\scripts\dev_tools\test_validate_orchestrator_state_blocked_reason.py . [ 89%]
.....................................................                    [ 90%]
tests\scripts\dev_tools\test_validate_orchestrator_state_cli.py ........ [ 90%]
.............                                                            [ 90%]
tests\scripts\dev_tools\test_validate_orchestrator_state_codex_model_routing.py . [ 90%]
...........                                                              [ 90%]
tests\scripts\dev_tools\test_validate_orchestrator_state_codex_topology.py . [ 90%]
............                                                             [ 90%]
tests\scripts\dev_tools\test_validate_orchestrator_state_completion.py . [ 90%]
......                                                                   [ 90%]
tests\scripts\dev_tools\test_validate_orchestrator_state_complexity.py . [ 90%]
..............                                                           [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_delegation_receipts.py . [ 91%]
......                                                                   [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_human_interaction.py . [ 91%]
.......                                                                  [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_issue_adoption.py . [ 91%]
...                                                                      [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_model_routing.py . [ 91%]
..........                                                               [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_model_routing_backcompat.py . [ 91%]
....                                                                     [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_model_routing_gate.py . [ 91%]
.........                                                                [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_pr_creation_readiness.py . [ 91%]
.........                                                                [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_preparation_route.py . [ 91%]
...........                                                              [ 91%]
tests\scripts\dev_tools\test_validate_orchestrator_state_remediation_backcompat.py . [ 91%]
............................................                             [ 92%]
tests\scripts\dev_tools\test_validate_orchestrator_state_remediation_loop.py . [ 92%]
.........                                                                [ 92%]
tests\scripts\dev_tools\test_validate_orchestrator_state_routing_contract.py . [ 92%]
................                                                         [ 92%]
tests\scripts\dev_tools\test_validate_orchestrator_state_step_status_extras.py . [ 92%]
............................                                             [ 93%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state.py ... [ 93%]
........................................................................ [ 94%]
.......                                                                  [ 94%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_cohort_barrier.py . [ 94%]
..............................                                           [ 94%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_completion.py . [ 94%]
.........................................................                [ 95%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_drift.py . [ 95%]
..........................                                               [ 95%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_mergeable.py . [ 96%]
.                                                                        [ 96%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_mutation_modes.py . [ 96%]
...............                                                          [ 96%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_mutations.py . [ 96%]
..........................                                               [ 96%]
tests\scripts\dev_tools\test_validate_parallel_orchestrator_state_structures.py . [ 96%]
............................................                             [ 97%]
tests\scripts\dev_tools\test_validate_parallel_planner_state.py ........ [ 97%]
........................................................................ [ 98%]
                                                                         [ 98%]
tests\scripts\dev_tools\test_validate_parallel_planner_state_bounds.py . [ 98%]
.....                                                                    [ 98%]
tests\scripts\dev_tools\test_validate_parallel_planner_state_routing.py . [ 98%]
..............................                                           [ 98%]
tests\scripts\dev_tools\test_validate_parallel_state_tolerated_edge_fields.py . [ 98%]
....                                                                     [ 98%]
tests\scripts\dev_tools\test_validate_policy_audit_artifact.py ......... [ 99%]
                                                                         [ 99%]
tests\scripts\dev_tools\test_vscode_workspace_settings.py ..             [ 99%]
tests\scripts\dev_tools\test_workflow_npm_token_guard.py ............... [ 99%]
.......................................................                  [ 99%]
tests\test_pytest_collection.py .                                        [100%]

- generated xml file: SCRATCH\issue-980-python-junit.xml -
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------
scripts\dev_tools\__init__.py                                             0      0      0      0   100%
scripts\dev_tools\_blast_radius_conflicts.py                             62      0     22      0   100%
scripts\dev_tools\_blast_radius_extraction.py                            97      0     44      0   100%
scripts\dev_tools\_blast_radius_glob.py                                  58      1     28      1    98%   222
scripts\dev_tools\_blast_radius_guards.py                                19      0     10      0   100%
scripts\dev_tools\_blast_radius_mergeable.py                             28      0     14      0   100%
scripts\dev_tools\_blast_radius_normalization.py                         13      0      6      0   100%
scripts\dev_tools\_blast_radius_scheduling.py                           143      0     32      0   100%
scripts\dev_tools\_blast_radius_thresholds.py                            10      0      4      0   100%
scripts\dev_tools\_blast_radius_token_shapes.py                          27      0     10      0   100%
scripts\dev_tools\_blast_radius_validation.py                           101      0     32      0   100%
scripts\dev_tools\_blast_radius_write_intent.py                          99      2     42      2    97%   345, 351
scripts\dev_tools\_epic_orchestrator_state_launch_binding.py            119      0     56      0   100%
scripts\dev_tools\_epic_orchestrator_state_resolution.py                 85      0     48      0   100%
scripts\dev_tools\_epic_orchestrator_state_wave_barrier.py               35      0     16      0   100%
scripts\dev_tools\_orchestrator_state_blocked_reason.py                  15      0      8      0   100%
scripts\dev_tools\_orchestrator_state_codex_model_routing.py             95      6     54      9    90%   38, 48, 59, 88, 146, 148->144, 169, 173->175, 175->167
scripts\dev_tools\_orchestrator_state_codex_topology.py                 126      0     72      3    98%   139->135, 157->151, 159->151
scripts\dev_tools\_orchestrator_state_complexity.py                      45      0     20      0   100%
scripts\dev_tools\_orchestrator_state_human_interaction.py               32      0     14      0   100%
scripts\dev_tools\_orchestrator_state_issue_adoption.py                 116      0     48      0   100%
scripts\dev_tools\_orchestrator_state_model_routing.py                   45      0     16      0   100%
scripts\dev_tools\_orchestrator_state_model_routing_gate.py              70      1     38      3    96%   117, 180->173, 217->216
scripts\dev_tools\_orchestrator_state_pr_creation_readiness.py           19      0     10      0   100%
scripts\dev_tools\_orchestrator_state_preparation_terminal.py            14      0      8      0   100%
scripts\dev_tools\_orchestrator_state_promotion_tools.py                 10      0      2      0   100%
scripts\dev_tools\_orchestrator_state_remediation_loop.py               138      0     74      1    99%   141->154
scripts\dev_tools\_orchestrator_state_route_gates.py                     98      8     44      8    89%   126, 131, 136, 225, 274, 323, 366, 380
scripts\dev_tools\_orchestrator_state_routing.py                        125      9     68     10    90%   87, 100->98, 114, 119->112, 139, 173, 177-180, 197, 202, 205
scripts\dev_tools\_orchestrator_state_step_status.py                     24      0     10      0   100%
scripts\dev_tools\_parallel_drift_cli_io.py                              41      0     18      0   100%
scripts\dev_tools\_parallel_drift_scheduling.py                          33      0     10      0   100%
scripts\dev_tools\_parallel_drift_shape.py                               51      0     26      0   100%
scripts\dev_tools\_parallel_kickoff_tables.py                            72      0     38      0   100%
scripts\dev_tools\_parallel_mutation_entries.py                          13      0      0      0   100%
scripts\dev_tools\_parallel_mutation_errors.py                           37      0      2      0   100%
scripts\dev_tools\_parallel_mutation_models.py                           93      0     30      0   100%
scripts\dev_tools\_parallel_orchestrator_state_cohort_barrier.py        108      1     56      1    99%   324
scripts\dev_tools\_parallel_orchestrator_state_drift.py                  44      0     14      0   100%
scripts\dev_tools\_parallel_orchestrator_state_mode_completion.py        66      0     32      0   100%
scripts\dev_tools\_parallel_orchestrator_state_mutations.py              65      0     28      0   100%
scripts\dev_tools\_parallel_planner_state_routing.py                     50      0     16      0   100%
scripts\dev_tools\_parallel_state_common.py                             122      0     62      0   100%
scripts\dev_tools\_parallel_state_records.py                             88      0     50      0   100%
scripts\dev_tools\_parallel_state_structures.py                         149      0     86      0   100%
scripts\dev_tools\agentic_sync.py                                       180     23     40      9    83%   145-153, 174, 195, 217-218, 239, 261, 282, 416, 491, 639, 643, 646, 794, 796, 801, 803
scripts\dev_tools\atomic_executor\__init__.py                             6      0      0      0   100%
scripts\dev_tools\atomic_executor\cli.py                                182     20     52      8    85%   82->exit, 88-90, 130-135, 229, 300, 304-306, 354, 361-362, 414->419, 420, 430-435
scripts\dev_tools\atomic_executor\cli_copilot_runtime.py                235     41     88     23    79%   55, 61, 84-94, 100, 123->126, 172->174, 174->176, 177, 239, 247, 251-252, 273-276, 284-289, 295->exit, 322, 329, 337-338, 372->377, 375, 387-390, 395->362, 407-409, 423-427
scripts\dev_tools\atomic_executor\cli_execute_one_task.py               133     14     46     11    86%   74->96, 76-80, 101, 103, 131-132, 161-162, 192-200, 204, 248->260, 256->258, 286->288
scripts\dev_tools\atomic_executor\cli_preflight.py                      153     54     78     10    58%   61, 70-71, 77, 93-97, 102-106, 155, 190-192, 212, 251-254, 270, 274->279, 290-353, 392
scripts\dev_tools\atomic_executor\cli_task_runtime.py                   169    151     50      0     8%   59-66, 76-84, 124-263, 290-407
scripts\dev_tools\atomic_executor\cli_workspace.py                      122     12     34      6    87%   167, 197, 222, 244, 249-250, 255, 288-289, 300, 311-312
scripts\dev_tools\atomic_executor\copilot_runner.py                       6      0      0      0   100%
scripts\dev_tools\atomic_executor\copilot_throttling.py                  88      8     26      7    87%   136, 138, 159->140, 214, 216, 227, 229, 327, 340
scripts\dev_tools\atomic_executor\feature_resolver.py                    61      1     26      1    98%   144
scripts\dev_tools\atomic_executor\plan_discovery.py                      38      0     12      1    98%   99->95
scripts\dev_tools\atomic_executor\plan_parser.py                        225     14     94     14    91%   346, 405, 416, 443, 527, 534, 541->545, 547, 556, 571, 592, 632, 637, 654-655
scripts\dev_tools\atomic_executor\prompt_builder.py                     124     32     44      8    70%   81, 89, 205, 212, 244-246, 256-257, 275, 328, 379, 383, 388-390, 411-434
scripts\dev_tools\atomic_executor\pytest_expectations.py                156     41     82     10    68%   57, 85, 187->189, 191->177, 193, 194->196, 246-247, 284, 297-298, 304-307, 332-348, 361-384
scripts\dev_tools\atomic_executor\qc_runner.py                          103      7     18      4    91%   139->145, 152, 195, 300-301, 478, 510, 565
scripts\dev_tools\atomic_executor\qc_runner_expectations.py              85     48     54      6    38%   23->22, 30-34, 39-43, 69-70, 86, 90, 97-98, 128-184
scripts\dev_tools\atomic_executor\qc_runner_loop.py                     110     30     34     11    70%   49, 54-55, 80, 83, 109, 126-145, 186-197, 202, 217, 233, 242, 259, 277
scripts\dev_tools\atomic_executor\qc_runner_process.py                   31     12      8      2    54%   28-47, 52, 56
scripts\dev_tools\atomic_executor\qc_toolchain.py                        15      0      0      0   100%
scripts\dev_tools\check_python_coverage_thresholds.py                    61      2     14      2    95%   230, 236
scripts\dev_tools\check_quality_tiers.py                                 70      0     14      1    99%   157->160
scripts\dev_tools\clean_devcontainer.py                                  36      2     10      1    93%   165, 179
scripts\dev_tools\codex_native_converter\__init__.py                      2      0      0      0   100%
scripts\dev_tools\codex_native_converter\__main__.py                      1      0      0      0   100%
scripts\dev_tools\codex_native_converter\_pipeline_traces.py             24      1     10      2    91%   106->109, 110
scripts\dev_tools\codex_native_converter\_reporting_topology.py          57      0     14      0   100%
scripts\dev_tools\codex_native_converter\classifier.py                   85      6     44      5    91%   85-86, 189, 256, 312->317, 378, 447
scripts\dev_tools\codex_native_converter\cli.py                          45      0      6      0   100%
scripts\dev_tools\codex_native_converter\engine.py                      101      3     34      3    96%   187, 195, 239
scripts\dev_tools\codex_native_converter\intermediate_state.py           30      0      0      0   100%
scripts\dev_tools\codex_native_converter\inventory.py                    45      2     20      2    94%   156, 215
scripts\dev_tools\codex_native_converter\mapping.py                      48      3     24      3    92%   60->64, 164-165, 189
scripts\dev_tools\codex_native_converter\models.py                       80      2      0      0    98%   348, 424
scripts\dev_tools\codex_native_converter\models_intermediate.py          66      0      0      0   100%
scripts\dev_tools\codex_native_converter\parser.py                       88      8     38      8    87%   83->88, 89, 124->129, 141-142, 174-175, 240->252, 249->252, 257-259
scripts\dev_tools\codex_native_converter\pipeline.py                     92      5     42      7    91%   140, 149, 270, 284, 430->437, 444->440, 447
scripts\dev_tools\codex_native_converter\reporting.py                    64      5     12      1    89%   117, 139-140, 325-333
scripts\dev_tools\codex_native_converter\rewrites.py                     46      4     14      2    90%   73->72, 75, 81-83
scripts\dev_tools\codex_native_converter\section_intent.py               41      0     18      0   100%
scripts\dev_tools\codex_native_converter\validation.py                   59      2     32      2    96%   176, 247
scripts\dev_tools\collect_commit_context.py                             123      1     20      1    99%   33
scripts\dev_tools\compute_blast_radius.py                                80      0     14      0   100%
scripts\dev_tools\compute_complexity_floor.py                            16      0      2      0   100%
scripts\dev_tools\copy_research_to_issue.py                              80     41     26      2    48%   49, 52-53, 56, 78, 82, 159-165, 186-189, 217-231, 244-256, 276-314
scripts\dev_tools\discovery\__init__.py                                   3      0      0      0   100%
scripts\dev_tools\discovery\analyzer\__init__.py                         11      0      4      0   100%
scripts\dev_tools\discovery\analyzer\__main__.py                          2      0      0      0   100%
scripts\dev_tools\discovery\analyzer\cli.py                              47      0      2      0   100%
scripts\dev_tools\discovery\analyzer\dotnet_inventory.py                126      4     44      4    95%   144, 166, 332, 403
scripts\dev_tools\discovery\analyzer\emitter.py                          18      0      2      0   100%
scripts\dev_tools\discovery\analyzer\inventory.py                        68      0     16      0   100%
scripts\dev_tools\discovery\analyzer\models.py                           52      0      6      0   100%
scripts\dev_tools\discovery\analyzer\pipeline.py                         42      0      6      0   100%
scripts\dev_tools\discovery\analyzer\source_text.py                     144      0     52      2    99%   82->102, 168->198
scripts\dev_tools\discovery\analyzer\stack_cli.py                        52      3      2      0    94%   75, 80-81
scripts\dev_tools\discovery\analyzer\vsto_office.py                     134      3     60      4    96%   156->158, 305, 339, 414
scripts\dev_tools\discovery\analyzer\vsto_patterns.py                    16      0      0      0   100%
scripts\dev_tools\discovery\completion_report.py                         51      4      6      0    93%   124-128, 154-158
scripts\dev_tools\discovery\coverage_report.py                           40      2      4      0    95%   128-132
scripts\dev_tools\discovery\domain_profile.py                           189      1     78      1    99%   75
scripts\dev_tools\discovery\domain_profile_models.py                     55      0     14      0   100%
scripts\dev_tools\discovery\init_cli.py                                  20      0      0      0   100%
scripts\dev_tools\discovery\init_flow.py                                 36      0     22      0   100%
scripts\dev_tools\discovery\init_models.py                               32      0     12      0   100%
scripts\dev_tools\discovery\io.py                                        16      0      2      0   100%
scripts\dev_tools\discovery\parity_report.py                             40      2      4      0    95%   129-133
scripts\dev_tools\discovery\profile_cli.py                               46      0      6      0   100%
scripts\dev_tools\discovery\rendering.py                                 13      0      2      0   100%
scripts\dev_tools\epic_kickoff_contract.py                              152     11     64      9    91%   81, 117-118, 121, 161, 165, 185, 189, 197-200, 202
scripts\dev_tools\epic_planner_git_integrity.py                         159      0     90      0   100%
scripts\dev_tools\epic_planner_launch_evidence.py                       195     15     92     10    91%   55, 58, 73-74, 81-82, 125-126, 130, 154, 162, 169, 175, 211, 294
scripts\dev_tools\epic_planner_readiness.py                             182      0     86      6    98%   220->213, 249->262, 251->250, 325->329, 332->336, 348->341
scripts\dev_tools\epic_wave_computation.py                               26      0      8      0   100%
scripts\dev_tools\fix_all.py                                            183     17     64     13    87%   92->exit, 122, 124, 150, 154, 160, 188, 244, 279, 284, 291-294, 354, 410, 427->429, 618-619
scripts\dev_tools\fix_all_branches.py                                    82      0     24      0   100%
scripts\dev_tools\fix_all_branches_extra.py                              85      0     24      0   100%
scripts\dev_tools\fix_all_runtime.py                                     82      1     22      1    98%   77
scripts\dev_tools\format_json.py                                         64      0     22      0   100%
scripts\dev_tools\generate_acceptance_scenarios.py                      186      0     42      0   100%
scripts\dev_tools\generate_codex_agent_variants.py                      128      7     46      5    93%   15, 119-120, 232, 245, 254, 265
scripts\dev_tools\json_config.py                                         20      2     12      2    88%   47, 49
scripts\dev_tools\markdown_label_formatter.py                            65      0     18      0   100%
scripts\dev_tools\new_active_feature_folder.py                            7      0      0      0   100%
scripts\dev_tools\new_active_feature_folder_docs.py                      80      1     40      4    96%   175->255, 180->182, 203->205, 266
scripts\dev_tools\new_active_feature_folder_flow.py                     151     12     60      6    91%   96->99, 117, 294->317, 322, 324->335, 328->335, 399-416
scripts\dev_tools\new_active_feature_folder_io.py                       110      3     50      4    94%   101->exit, 103->101, 112->110, 129-131
scripts\dev_tools\new_active_feature_folder_markdown.py                  99      7     46     11    86%   56-59, 79->81, 88, 92, 114, 141->143, 143->145, 145->147, 177->191, 218->232, 232->246
scripts\dev_tools\new_active_feature_folder_models.py                    73      1     28      2    97%   91, 102->104
scripts\dev_tools\new_potential_bug_entry.py                            111      9     30      3    91%   28, 82-89, 143->145, 147, 416-427
scripts\dev_tools\orchestration_handoff_adapters.py                     128      0     22      0   100%
scripts\dev_tools\orchestration_handoff_contract.py                     307      4     92      5    98%   320->exit, 349, 366, 470, 489
scripts\dev_tools\orchestration_handoff_contract_support.py              89      7     38      7    89%   32, 42, 51, 54, 77, 129, 133
scripts\dev_tools\parallel_cohort_computation.py                         59      0     22      0   100%
scripts\dev_tools\parallel_drift_detection.py                            79      0     26      0   100%
scripts\dev_tools\parallel_drift_detection_cli.py                        74      0     10      0   100%
scripts\dev_tools\parallel_drift_halt.py                                 42      0      6      0   100%
scripts\dev_tools\parallel_drift_resolution.py                           15      0      0      0   100%
scripts\dev_tools\parallel_kickoff_contract.py                           91      0     26      0   100%
scripts\dev_tools\parallel_lane_assertion.py                            143      0     44      0   100%
scripts\dev_tools\parallel_manifest_contract.py                         113      0     50      0   100%
scripts\dev_tools\parallel_mutation_abandon_cli.py                       62      0     10      0   100%
scripts\dev_tools\parallel_mutation_protocol.py                          49      0     24      0   100%
scripts\dev_tools\plan_gate_commands.py                                 111      1     40      2    98%   398->400, 405
scripts\dev_tools\plan_gate_coverage.py                                  48      0     22      0   100%
scripts\dev_tools\plan_gate_discrimination.py                           136      1     52      1    99%   216
scripts\dev_tools\plan_gate_document.py                                 116      0     48      0   100%
scripts\dev_tools\plan_gate_observability.py                            139      4     62      5    96%   250, 397->395, 399, 414, 422
scripts\dev_tools\plan_gate_scratch.py                                   52      0     16      0   100%
scripts\dev_tools\plan_progress_report.py                               101     27     26      2    74%   147-148, 152, 176-179, 213, 299-305, 322-325, 338-368, 384-392
scripts\dev_tools\potential_to_issue.py                                 136      1     38      1    99%   298
scripts\dev_tools\potential_to_issue_adapters.py                         48      0     16      0   100%
scripts\dev_tools\potential_to_issue_content.py                          95      3     28      5    93%   46->49, 111, 114, 172, 200->203
scripts\dev_tools\potential_to_issue_filesystem.py                       31      0     14      0   100%
scripts\dev_tools\pr_context\__init__.py                                  2      0      0      0   100%
scripts\dev_tools\pr_context\autoclose.py                                45      0     16      0   100%
scripts\dev_tools\pr_context\collector.py                               168     11     50      8    91%   218, 229, 230->225, 272-273, 299-302, 315, 328, 360
scripts\dev_tools\pr_context\collector_documents.py                      60      4     22      2    93%   85-86, 293, 341
scripts\dev_tools\pr_context\feature_docs.py                            168     11     92      8    91%   165, 169, 193->191, 223, 247, 255-256, 303->308, 312-316
scripts\dev_tools\pr_context\git.py                                      61      0     10      1    99%   18->exit
scripts\dev_tools\pr_context\github.py                                  350     23    166     31    90%   61->63, 81, 89, 97, 104, 130, 139-140, 152, 162, 167, 172->183, 176, 180->174, 189, 196, 215->211, 225->221, 231-233, 249->273, 260->262, 301, 376->375, 379->375, 423, 436->431, 446, 468->464, 477->473, 501, 512, 518, 545
scripts\dev_tools\pr_context\models.py                                  126      1     14      1    99%   165
scripts\dev_tools\pr_context\render.py                                  135     22     46      6    81%   157, 159->173, 167-168, 207, 211-217, 241, 276-287
scripts\dev_tools\pr_context\render_feature_excerpts.py                 144     20     72      6    82%   70-87, 154->158, 165->167, 209, 223, 231-232
scripts\dev_tools\pr_context\render_pr_helpers.py                       132      5     66      3    96%   68, 93-95, 141, 278->277
scripts\dev_tools\pr_context\summary_helpers.py                         161     14     70      9    88%   80, 129->134, 239, 242, 273, 278, 283-284, 322->329, 332-345
scripts\dev_tools\pr_context\verification_evidence.py                    56      0     16      1    99%   98->97
scripts\dev_tools\prompt_mode_contract.py                                44      1     26      1    97%   41
scripts\dev_tools\push_down_claude_blast_radius_derive.py                46      0     10      0   100%
scripts\dev_tools\push_down_claude_blast_radius_derive_core.py           61      0     16      0   100%
scripts\dev_tools\push_down_claude_blast_radius_derive_manifests.py      46      0     14      0   100%
scripts\dev_tools\push_down_claude_blast_radius_overlay.py              109      0     52      0   100%
scripts\dev_tools\push_down_claude_customizations.py                     79      5     16      0    93%   130-139
scripts\dev_tools\push_down_claude_destination_writes.py                101      1     14      1    98%   180
scripts\dev_tools\push_down_claude_exclusion_filter.py                  100      1     16      1    98%   330
scripts\dev_tools\push_down_claude_filesystem.py                        113      4     28      2    96%   145, 182-183, 326
scripts\dev_tools\push_down_claude_gitignore_merge.py                    48      0     14      0   100%
scripts\dev_tools\push_down_claude_pack_selection.py                     83      5     30      5    91%   214, 229, 240, 256, 314
scripts\dev_tools\push_down_claude_routing_merge.py                      44      0     18      0   100%
scripts\dev_tools\push_down_codex_and_agents_customizations.py          102      2     14      2    97%   211, 396
scripts\dev_tools\push_down_codex_filesystem.py                          46      3      8      1    93%   54-55, 64
scripts\dev_tools\push_down_codex_pack_selection.py                      99      1     42      2    98%   94, 191->194
scripts\dev_tools\push_down_copilot_customizations.py                   130      7     18      2    93%   29-37, 331, 389->388
scripts\dev_tools\push_down_copilot_customizations_filesystem.py         29      0     18      0   100%
scripts\dev_tools\push_down_copilot_customizations_rewrites.py           57      1     10      1    97%   248
scripts\dev_tools\push_down_exclusion_manifest.py                       104      0     34      0   100%
scripts\dev_tools\quality_tiers_contract.py                             191      0     78      0   100%
scripts\dev_tools\resolve_codex_deployment.py                            83      0     18      0   100%
scripts\dev_tools\resolve_codex_topology.py                              99      0     34      0   100%
scripts\dev_tools\resolve_delegation_model.py                            19      0      4      0   100%
scripts\dev_tools\resolve_execute_plan_prompt.py                        172      8     52      5    94%   123->126, 154-155, 236->239, 409, 452-453, 468->471, 564-566
scripts\dev_tools\resolve_file_prompt.py                                183     13     58     10    90%   56, 83->87, 110-119, 130, 150->154, 230, 265->275, 272->275, 402, 477-478, 497, 507
scripts\dev_tools\resolve_hard_lock_prompt.py                           126      3     34      1    98%   145-146, 149
scripts\dev_tools\schema_loading.py                                      35      0     14      0   100%
scripts\dev_tools\skill_bundle_contract.py                              141      5     60      3    96%   109, 216, 245-246, 254
scripts\dev_tools\skill_bundle_contract_cli.py                           58      4     22      5    89%   62, 99, 130, 132, 141->143
scripts\dev_tools\tk_dialog_helpers.py                                   99     57     30      4    45%   39-40, 64-67, 85-117, 133-159, 170-171, 184, 191, 236, 238, 245-260
scripts\dev_tools\validate_discovery_artifacts.py                        61      1     16      0    99%   82
scripts\dev_tools\validate_discovery_profile.py                          25      0     10      0   100%
scripts\dev_tools\validate_discovery_schema_artifacts.py                 44      0      4      0   100%
scripts\dev_tools\validate_epic_orchestrator_state.py                   128      2     62      2    98%   278, 283
scripts\dev_tools\validate_epic_planner_state.py                        191      0    100      1    99%   174->178
scripts\dev_tools\validate_evidence_locations.py                         28      0     12      0   100%
scripts\dev_tools\validate_json.py                                       98     20     38      2    74%   21, 104-126, 174-176
scripts\dev_tools\validate_orchestration_artifacts.py                   149      3     56      4    97%   409, 411, 413, 436->440
scripts\dev_tools\validate_orchestration_review_artifacts.py             20      0     10      1    97%   78->80
scripts\dev_tools\validate_orchestrator_state.py                        170      2     82      2    98%   116, 130
scripts\dev_tools\validate_orchestrator_state_cli.py                     33      1      4      0    97%   118
scripts\dev_tools\validate_parallel_orchestrator_state.py                88      2     34      2    97%   231, 270
scripts\dev_tools\validate_parallel_planner_state.py                    115      0     46      0   100%
scripts\dev_tools\validate_policy_audit_artifact.py                     125     12     74     11    88%   156, 340, 372, 376, 382, 386-389, 392, 398, 414, 420, 430
-----------------------------------------------------------------------------------------------------------------
TOTAL                                                                 17849   1051   6446    473    93%
Coverage JSON written to file SCRATCH/issue-980-python-coverage.json
=========================== short test summary info ===========================
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
================= 7336 passed, 6 skipped in 68.45s (0:01:08) ==================
```

Coverage report: python-coverage.2026-10-18T03-51.json
Numeric metrics: python-coverage-metrics.2026-10-18T03-51.json
JUnit results: python-junit.2026-10-18T03-51.xml
