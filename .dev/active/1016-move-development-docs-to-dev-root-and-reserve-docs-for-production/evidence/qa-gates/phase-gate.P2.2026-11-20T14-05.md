# Phase Gate P2 ([P2-T4], stage B)

Timestamp: 2026-11-20T14-05
Command: generator check forms (pwsh -WorkingDirectory <worktree> -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check; env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.generate_codex_agent_variants --check; the same with scripts.dev_tools.build_discovery_runtime --check), then stages 1 to 6: sh SCRATCH/issue-1016-static2.sh (npx prettier --check; npm run lint; npm run typecheck in extensions/drm-copilot); sh SCRATCH/issue-1016-pystatic.sh (black --check .; ruff check .; pyright); sh SCRATCH/issue-1016-psstatic.sh (Invoke-PoshQCFormat with a non-writing seam; Invoke-ScriptAnalyzer per file); sh SCRATCH/issue-1016-g-jest.sh (launcher jest-extension --coverage); sh SCRATCH/issue-1016-g-pytest.sh (launcher pytest -n auto --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-p2g.json); sh SCRATCH/issue-1016-g-pester.sh (launcher pester, Invoke-PoshQCParallelTest; failures read from the shard JUnit files under artifacts/pester/parallel because a failed run writes no merged artifact); auto-fixes: sh SCRATCH/issue-1016-p2fix.sh (npx prettier --write on 6 files; poetry run black on 7 files) and pwsh -File SCRATCH/issue-1016-psfmt1.ps1 (Invoke-PoshQCFormat on 1 file)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: REHEARSAL = apply-rehearsal.2026-11-20T13-04.md. Pass 1 found formatter drift introduced by the tool's prefix rewrites (Prettier 6 test files, Black 7 test files); they were auto-fixed and the loop restarted. Pass 2 found PowerShell formatter drift in 1 tool-rewritten test file (tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1, with 6 PSAlignAssignmentStatement warnings on the same lines); it was auto-fixed and the loop restarted. Pass 3 was clean in stages 1 to 4 and 6 with no further auto-fix. Unit stage (pass 3): Jest 6684 passed, 0 failed; pytest 16673 passed, 33 failed, 395 errors, 6 skipped; Pester 29146 tests, 19 failed, 0 errors (exit 1, 774.27 s). The failing tests equal the run A FIX rows of REHEARSAL exactly (pytest: the sorted failure lists are identical, 428 lines; Pester: the 19 file and test names are identical; Jest: none in either), with 0 failures outside those rows and no run A FIX test passing. The only ProcessReductionChain.Ledger.Tests.ps1 failure is PRC-LEDGER-CHAIN-HOLDS, attributed to [P3-T4], with its error naming extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md (entry 0001). Generators: harness-generation: no drift (exit 0); Codex variant check exit 0; build_discovery_runtime exit 1 only on the six canonical inputs under docs/discovery/templates/v2 (missing coverage-ledger.json, domain-profile.yaml, parity-matrix.json, product-decisions.yaml, scope.yaml, unspecified-behaviors.yaml; extra none), attributed to [P3-T7]. Result: PASS under the [P2-T4] expect-fail rule.

| Stage | Command | Exit | Findings (final pass) |
| --- | --- | --- | --- |
| 1 Format (TypeScript) | npx prettier --check | 0 | `All matched files use Prettier code style!` (pass 1: 6 files, auto-fixed) |
| 1 Format (Python) | black --check . | 0 | `1071 files would be left unchanged.` (pass 1: 7 files, auto-fixed) |
| 1 Format (PowerShell) | Invoke-PoshQCFormat, non-writing seam | 0 | 1864 files, 0 `Formatted:` lines (pass 2: 1 file, auto-fixed) |
| 2 Lint (TypeScript) | npm run lint | 0 | 0 |
| 2 Lint (Python) | ruff check . | 0 | `All checks passed!` |
| 2 Lint (PowerShell) | Invoke-ScriptAnalyzer per file | 0 | 1864 files, 0 findings |
| 3 Type check (TypeScript) | npm run typecheck | 0 | 0 `error TS` lines |
| 3 Type check (Python) | pyright | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 Architecture boundaries | dependency-cruiser not configured (as in [P0-T4]); boundary suites inside stage 5 | 0 | 0 |
| 5 Unit (Jest) | launcher jest-extension | 0 | 412 suites, 6684 passed, 0 failed |
| 5 Unit (pytest) | launcher pytest -n auto | 1 | 33 failed, 395 errors: all run A FIX rows |
| 5 Unit (Pester) | launcher pester | 1 | 19 failed: all run A FIX rows |
| 6 Contract | contract suites inside stage 5; harness, Codex variant and discovery checks | 0, 0, 1 | `harness-generation: no drift`; Codex exit 0; discovery drift attributed to [P3-T7] |

Auto-fixed files (tool-rewritten test files, none a REWRITE_EXCLUSIONS member): extensions/drm-copilot/test/extension.integration.test.ts, test/lib/pr-context/collector-output.test.ts, test/lib/validate/orchestrator-state-remediation-accounting.test.ts, test/lib/validate/parallel-kickoff-template-seam.test.ts, test/lib/validate/parallel-orchestrator-state-cohort-barrier.test.ts, test/lib/validate/parallel-state-test-support.ts; tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py, test_single_pass_preflight_contracts.py, test_validate_parallel_orchestrator_state_mutations.py, test_validate_epic_planner_state.py, test_orchestrator_state_remediation_accounting.py, test_validate_parallel_orchestrator_state.py, test_validate_parallel_orchestrator_state_cohort_barrier.py; tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1.

Integration and golden lanes: excluded locally by the launcher; they run in CI.

## Failing tests with their run A FIX rows and fixing tasks

| Run | Gate | Test file | Test | Rule | Fixing task |
| --- | --- | --- | --- | --- | --- |
| A | pytest FAILED | tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py | test_epic_run_skill_discovers_kickoff_across_integration_branch | FIX-NAMED | [P3-T6] (A30 pinned kickoff literal) |
| A | pytest FAILED | tests/scripts/dev_tools/discovery/test_domain_neutrality.py | test_domain_neutrality_templates_contain_no_disallowed_tokens | FIX-NAMED | [P3-T7] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_handoff_carries_no_stale_installed_host_limit | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_no_checkout_is_required | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_architecture_document_links_the_planning_prerequisite | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_page_exists_and_is_indexed | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[README.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[architecture.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[workflow.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[domain-profile.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[artifacts-and-schemas.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[analyzers.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[running-the-workflow.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[cli-reference.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[enforcement.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[migration.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[consumer-onboarding.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_every_relative_link_resolves[maintainer-guide.md] | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_architecture_page_carries_a_mermaid_diagram | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_cli_reference_lists_every_console_script | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_cli_reference_lists_every_discovery_mcp_tool_and_command | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_gateway_operations_and_modes_match_the_service_contract | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_artifact_kinds_and_analyzers_match_the_schemas | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_roles_workflows_aliases_and_hooks_are_documented | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_required_topics_are_covered | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_criteria_are_separated_from_test_passes | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_consumer_names_appear_only_in_separated_examples | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_separated_example_is_the_only_consumer_specific_page | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_handoff_reconciles_the_built_artifacts | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_discovery_documentation_contracts.py | test_host_principal_path_is_documented | FIX-NAMED | [P3-T6] |
| A | pytest FAILED | tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py | test_orchestrate_skill_section_states_its_required_obligations[kickoff-feature-folder-and-issue-number] | FIX-NAMED | [P3-T6] (SECTION_OBLIGATION_CASES kickoff-feature-folder-and-issue-number) |
| A | pytest FAILED | tests/scripts/dev_tools/test_single_pass_preflight_contracts.py | test_plan_templates_carry_premortem_skeleton | FIX-NAMED | [P3-T4] |
| A | pytest FAILED | tests/scripts/dev_tools/test_single_pass_preflight_contracts.py | test_contract_requires_final_phase_self_review | FIX-NAMED | [P3-T9] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_stale_physical_inputs_invalidate_a_prepared_plan[collision] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_reconstruction_restores_the_prepared_output_bytes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_stale_physical_inputs_invalidate_a_prepared_plan[parent-identity] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_invocation_without_required_outputs_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_stale_physical_inputs_invalidate_a_prepared_plan[source-byte] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_malformed_required_output_rows_are_refused[rows] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_bootstrap_failures_report_partial_effects_and_release_handles[profile-publish] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_malformed_required_output_rows_are_refused[outputs1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_bootstrap_failures_report_partial_effects_and_release_handles[directory-open] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_bootstrap_failures_report_partial_effects_and_release_handles[guard-busy] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_bootstrap_failures_report_partial_effects_and_release_handles[revocation] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_bootstrap_rejects_unconfigured_directories | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_opened_directory_identity_must_match_retained_parent_stamp[.] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_baseline_without_input_manifest_is_drift | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_removed_input_is_drift | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_opened_directory_identity_must_match_retained_parent_stamp[docs] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_pinned_row_without_text_is_drift | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_baseline.py | test_pinned_row_digest_mismatch_is_drift | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_metadata_changes_after_capture_are_detected_by_physical_reader | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_virtual_reads_are_bounded_and_do_not_hide_changed_physical_bytes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_changed_parent_metadata_before_open_is_rejected | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_existing_graph_preservation_without_writes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_new_directory_identity_is_bound_through_guarded_postcapture[none] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_new_directory_identity_is_bound_through_guarded_postcapture[identity] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_new_directory_identity_is_bound_through_guarded_postcapture[bytes] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_new_directory_identity_is_bound_through_guarded_postcapture[lost-path] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_new_directory_identity_is_bound_through_guarded_postcapture[kind] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_main.py | test_main_composes_the_host_ports_from_the_complete_identity[extra0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_new_directory_identity_is_bound_through_guarded_postcapture[namespace] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_main.py | test_main_composes_the_host_ports_from_the_complete_identity[extra1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_bootstrap_handoff_rejects_same_bytes_with_changed_parent_identity | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_concurrent_profile_creation_has_typed_conflict_path | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_retains_exact_files_and_trusted_ports | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_rejects_invalid_selection[duplicate] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_rejects_invalid_selection[traversal] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_rejects_invalid_selection[link] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_doctor_uses_verified_runtime_without_claiming_native_capability | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_rejects_changed_originals[changed] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_decision_validation_preserves_complete_graph_result | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_rejects_changed_originals[missing] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_catalog_failure_keeps_only_bounded_recognized_context[fields0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_catalog_failure_keeps_only_bounded_recognized_context[fields1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_rejects_conflicting_observations | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_catalog_failure_keeps_only_bounded_recognized_context[fields2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_reserves_before_reads[file-count] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_catalog_failure_keeps_only_bounded_recognized_context[fields3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_reserves_before_reads[work] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_catalog_failure_keeps_only_bounded_recognized_context[fields4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_provider_mismatch_has_actionable_unavailable_context | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_migration_capture_reserves_before_reads[bytes] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_invalid_inventory_selector_is_a_typed_invocation_failure[selector0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_invalid_inventory_selector_is_a_typed_invocation_failure[selector1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_reversed_source_line_range_is_rejected_before_inspection | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_source_failures_do_not_return_partial_rows[selection] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_source_failures_do_not_return_partial_rows[encoding] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_capture_checks_exact_capacity_and_original_bytes[coalesced] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_source_failures_do_not_return_partial_rows[capacity] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_source_first_page_exposes_exact_truncation | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_read_refusals.py | test_read_outside_the_selected_paths_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error0-3-RUNTIME_CORRUPT] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_projection_reserves_exact_merged_capacity_before_retention[count-exact] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_projection_reserves_exact_merged_capacity_before_retention[count-short] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error1-3-RUNTIME_CORRUPT] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_read_refusals.py | test_read_outside_the_configured_input_scope_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error2-2-SERVICE_CONFIGURATION] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_read_refusals.py | test_a_symlinked_read_inside_the_selection_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error3-2-PATH_SCOPE] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_read_refusals.py | test_a_resolved_target_outside_the_selection_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_capture.py | test_projection_reserves_exact_merged_capacity_before_retention[bytes-short] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error4-2-EXTENSION_TEST] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error5-1-MUTATION_INVALID] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-another agent] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error6-2-MUTATION_STALE] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[coverage-ledger] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-not been started] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error7-2-SERVICE_LIMIT] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-another host identity0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_precise_operational_errors_keep_their_exit_class_without_raw_text[error8-3-SERVICE_IO] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[evidence-reference] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_existing_typed_findings_are_preserved[profile] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[feature-contract] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_existing_typed_findings_are_preserved[request] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_existing_typed_findings_are_preserved[mutation] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[parity-matrix] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[product-decision] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-not the one the invocation names] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[runtime-characterization-scenario] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-another host identity1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_every_original_field_remains_untrusted_metadata[unspecified-behavior] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[unsupported_capability-does not report support] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[feature-contract-fields0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-not been consumed] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[runtime-characterization-scenario-fields1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[drop_latch-not been consumed] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[product-decision-fields2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_unexpected_programming_error_is_not_relabelled_as_no_effect_result | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-another operation] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[unspecified-behavior-fields3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_projection_reserves_complete_encoded_content_before_row_allocation[\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-another invocation] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_projection_reserves_complete_encoded_content_before_row_allocation[\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\xc3\xa9\x | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[coverage-ledger-fields4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_every_protected_record_binding_refuses_before_dispatch[<lambda>-not an ok prepare-agent result] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_opaque_binary_projection_retains_digest_without_fake_text | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[parity-matrix-fields5] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_context_invalid_or_unavailable_inputs_fail_explicitly[snapshot] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_a_second_dispatch_of_the_same_grant_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_legacy_claims_do_not_become_verified_target_state[evidence-reference-fields6] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_an_expired_grant_is_refused_before_any_read | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_context_invalid_or_unavailable_inputs_fail_explicitly[plan] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_missing_context_is_actionable_and_never_fabricated[product-decision-selector0-None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_unknown_authorization_reference_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_context_invalid_or_unavailable_inputs_fail_explicitly[read] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_missing_context_is_actionable_and_never_fabricated[evidence-reference-selector1-None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_requests_without_host_markers_are_refused[structural-None-protected-alpha-00000001] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_missing_context_is_actionable_and_never_fabricated[runtime-characterization-scenario-selector2-None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_context_invalid_or_unavailable_inputs_fail_explicitly[document] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_requests_without_host_markers_are_refused[agent-output-invocation-alpha-None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_context_invalid_or_unavailable_inputs_fail_explicitly[text] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_missing_context_is_actionable_and_never_fabricated[runtime-characterization-scenario-selector3-environment3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_non_output_input_drift_is_refused_as_baseline_drift[change_scope] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_context_invalid_or_unavailable_inputs_fail_explicitly[strings] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_non_output_input_drift_is_refused_as_baseline_drift[add_input] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_explicit_binding_and_empty_preconditions_stay_observation_plans | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_direct_publication_context_cannot_derive_host_grants[host] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_output_changes_are_not_drift | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[feature-contract-fields0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_direct_publication_context_cannot_derive_host_grants[invocation_ref] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_a_missing_protected_record_raises_an_io_failure[invocation.json] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_direct_publication_context_cannot_derive_host_grants[authorization_ref] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_a_missing_protected_record_raises_an_io_failure[start-attestation.json] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_interrupted_publication_preserves_actual_conflict_and_failure | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[feature-contract-fields1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_a_missing_protected_record_raises_an_io_failure[baseline-result.json] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[product-decision-fields2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_another_invocation_reference_finds_no_partition | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[product-decision-fields3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_an_inactive_workspace_is_refused_before_any_record_read | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[unspecified-behavior-fields4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_a_malformed_record_is_refused_by_kind | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[runtime-characterization-scenario-fields5] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host_refusals.py | test_a_foreign_workspace_request_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_empty_v1_mechanical_fields_cannot_invent_replacement_text[runtime-characterization-scenario-fields6] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_missing_collection_template_and_malformed_builder_fail_closed | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_multiple_singleton_sources_require_separate_roots[coverage-ledger] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_multiple_singleton_sources_require_separate_roots[parity-matrix] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_effective_profile_limits_and_output_roots_are_rechecked[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_effective_profile_limits_and_output_roots_are_rechecked[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_unknowns.py | test_dry_run_never_bootstraps_or_revokes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_all_kinds_have_exact_mapping_and_honest_projected_graph | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_planning_order_and_transient_input_do_not_change_report | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_native_operations_remain_unavailable_without_a_verified_provider[finalize-agent] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_source_validation_fails_closed[missing] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_failed_freshness_preserves_observation_without_second_read | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_source_validation_fails_closed[different] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_projection_prepays_work_before_hashing_and_carrier_construction[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_source_validation_fails_closed[invalid] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_projection_prepays_work_before_hashing_and_carrier_construction[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_source_validation_fails_closed[version] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_result_prepays_incremental_comparison_work_and_preserves_findings[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_source_validation_fails_closed[duplicate] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_boundaries.py | test_result_prepays_incremental_comparison_work_and_preserves_findings[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_source_validation_fails_closed[unknown-binding] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_missing_capture_cannot_authorize_mutation[MG1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_yaml_and_identifier_mapping_keep_original_bytes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_missing_capture_cannot_authorize_mutation[MG7] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_configured_uncaptured_read_refuses_before_physical_io | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_returned_outcome_tracks_actual_partial_publication[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_missing_capture_cannot_authorize_mutation[MG8] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_required_read_none_contract_violation_refuses_fabricated_bytes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_returned_outcome_tracks_actual_partial_publication[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_explicit_identity_and_cas_are_independent_preconditions | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_commit_failures_preserve_truth_and_do_not_activate[reconstruct] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_naive_trusted_clock_refuses_before_capture_or_publication | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_missing_activation_profile_refuses_without_graph_authority | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_approval_requires_actual_status_owner_and_evidence[MG3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_profile_change_between_selection_and_capture_refuses_publication | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_approval_requires_actual_status_owner_and_evidence[MG4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_changed_reauthorization_actor_refuses_dispatch_and_writes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_approval_requires_actual_status_owner_and_evidence[MG5] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_context_guards.py | test_bootstrap_rejects_wrong_operation_family_without_effects | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_matching_approval_preserves_exact_bounded_proposal | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_commit_failures_preserve_truth_and_do_not_activate[bootstrap] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_export_identity_must_resolve_exactly_once[MG9] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_commit_failures_preserve_truth_and_do_not_activate[physical] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_export_identity_must_resolve_exactly_once[MG10] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_commit_failures_preserve_truth_and_do_not_activate[projection] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_commit_failures_preserve_truth_and_do_not_activate[revocation] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_captured_snapshot_import_uses_real_planner_and_guarded_writer | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_commit_failures_preserve_truth_and_do_not_activate[dry-reconstruct] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_extension_preview_retains_normalized_bytes_and_blockers[MG12] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_proposal_preserves_existing_bytes_or_reports_explicit_conflicts[malformed-template] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_extension_preview_retains_normalized_bytes_and_blockers[MG13] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_proposal_preserves_existing_bytes_or_reports_explicit_conflicts[record-conflict] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_proposal_preserves_existing_bytes_or_reports_explicit_conflicts[same-output] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_passing_finalize_reports_created_outputs_and_mints_nothing | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_extension_write_publishes_real_normalized_inventory | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_migration_v1.py | test_proposal_preserves_existing_bytes_or_reports_explicit_conflicts[different-output] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_reviewer_valid_failing_review_exits_one_with_valid_outputs | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_mutation_guards.py | test_mutation_dispatch_refuses_another_valid_operation_family | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_missing_required_output_is_a_conflict_row_and_exit_one | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_each_role_projects_a_complete_honest_structural_draft[legacy-source] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_never_written_output_is_reported_by_finding_without_a_fabricated_row | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_each_role_projects_a_complete_honest_structural_draft[modernization-target] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_ungranted_required_output_row_is_refused_before_validation | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_local_user_finalize_remains_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_each_role_projects_a_complete_honest_structural_draft[combined] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_first_combined_initialization_publishes_parity_through_real_writer | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_finalization.py | test_a_provider_permission_refusal_is_an_authority_failure | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_dry_run_is_repeatable_and_retains_exact_physical_absence | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_valid_rows_pin_existing_content_and_absence_without_writes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_explicit_draft_and_custom_paths_preserve_caller_values | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_digest_mismatch_blocks_without_artifact_rows[True-None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_existing_profile_conflicts_are_explicit[system_name-different] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_digest_mismatch_blocks_without_artifact_rows[True-0000000000000000000000000000000000000000000000000000000000000000] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_granted_new_contract_publishes_with_agent_attribution | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_existing_profile_conflicts_are_explicit[production_roots-value1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_digest_mismatch_blocks_without_artifact_rows[False-0000000000000000000000000000000000000000000000000000000000000000] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_granted_update_artifact_publishes_the_replacement | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_granted_link_evidence_publishes_the_linked_record | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_existing_profile_conflicts_are_explicit[test_roots-value2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_duplicate_path_is_refused_once_per_repeat | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_ungranted_change_is_refused_before_any_write | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_existing_profile_conflicts_are_explicit[documentation_roots-value3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_binary_existing_output_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_host_requests_without_their_bindings_are_refused_before_capture[fields0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_existing_profile_conflicts_are_explicit[artifact_overrides-value4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_host_requests_without_their_bindings_are_refused_before_capture[fields1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_path_outside_the_kind_location_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_host_requests_without_their_bindings_are_refused_before_capture[fields2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_template_loader_requires_complete_valid_structures | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_every_defective_row_is_reported_in_one_round_trip | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_root_only_operation_is_refused_under_host_authority | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_partition_paths_follow_the_host_digest_layout | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_template_cannot_claim_a_configured_profile | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_non_structural_mode_is_inapplicable | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_host_authority_without_invocation_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_finalize_agent_remains_refused_under_local_user | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_local_repository_identity_is_observed_or_left_null[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_host_authority_binds_invocation_grants_and_pinned_baseline | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_provider_value_that_is_not_a_service_authority_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_preparation.py | test_host_markers_on_prepare_are_still_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_host_admission.py | test_local_user_behavior_is_unchanged | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_authorize_before_capture_uses_its_own_bound_capture | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_read_source_authority_is_bounded_by_the_selected_paths | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_finalize_authority_carries_every_required_output_grant | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_writer_is_issued_only_for_the_verified_host_authority | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_new_contract_uses_real_plan_and_honest_file_effects[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_capability_observation_is_never_reported_for_a_host | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_local_repository_identity_is_observed_or_left_null[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_new_contract_uses_real_plan_and_honest_file_effects[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_wrong_local_git_repository_identity_is_rejected | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_host_io_writes_only_the_use_latch_of_the_protected_store | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_nonempty_provider_grants_are_never_expanded[extra] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_commit_failure_dispositions_preserve_guarded_boundary[reconstruction] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_gateway_host.py | test_dispatch_creates_the_use_latch_exactly_once | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_combined_workflow.py | test_export_then_import_transports_exact_bytes_between_workspaces | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_commit_failure_dispositions_preserve_guarded_boundary[bootstrap] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_nonempty_provider_grants_are_never_expanded[wrong-id] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_commit_failure_dispositions_preserve_guarded_boundary[graph] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_combined_workflow.py | test_tampered_transport_is_refused_before_publication | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_nonempty_provider_grants_are_never_expanded[wrong-path] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_commit_failure_dispositions_preserve_guarded_boundary[revocation] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig1_default_profile_uses_trusted_selection_and_exact_bytes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_combined_workflow.py | test_no_runtime_capability_completes_without_runtime_claims | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_report_preview_and_failed_gate_publication_keep_selected_status[coverage-report] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization.py | test_capture_rechecks_physical_bytes_after_virtual_loader_returns | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_combined_workflow.py | test_multiple_clients_and_optional_dimensions_configure_without_inventing_results | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_report_preview_and_failed_gate_publication_keep_selected_status[parity-report] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig2_unsupported_profile_version_refuses_artifacts | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_report_preview_and_failed_gate_publication_keep_selected_status[completion-report] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig3_malformed_v2_preserves_original_profile_findings | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_pure_report_format_does_not_publish[json] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig4_selector_profile_error_survives_before_analysis | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[profile] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_pure_report_format_does_not_publish[markdown] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig5_inventory_write_reconstructs_exact_selection_and_grants | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_pure_report_format_does_not_publish[both] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[scope] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig6_changed_physical_source_refuses_captured_page | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_validate_all_defaults_to_paired_reports_and_rejects_outside_root | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig7_captured_source_bound_refuses_before_physical_read | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[coverage_ledger] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_malformed_core_cannot_publish_a_diagnostic_report | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig8_invalid_direct_source_request_refuses_before_read | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[unspecified_behaviors] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_inspection_guards.py | test_ig9_other_operation_family_refuses_before_assessment | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[product_decisions] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_host_receives_only_granted_rows_without_expansion | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[parity_matrix] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_host_refuses_ungranted_mismatched_or_unauthorized_changes[grants0-fields0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[identity] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[directory] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_host_refuses_ungranted_mismatched_or_unauthorized_changes[grants1-fields1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_invalid_or_incompatible_existing_content_aborts_before_any_write[unknown-artifact] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_host_refuses_ungranted_mismatched_or_unauthorized_changes[grants2-fields2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_initialization_conflicts.py | test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_host_refuses_ungranted_mismatched_or_unauthorized_changes[grants3-fields3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_host_without_invocation_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_operation_grants.py | test_attribution_follows_the_principal | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_canonical_identity_and_same_reader_reach_service[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_canonical_identity_and_same_reader_reach_service[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_typed_service_exit_and_exact_json_survive[0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_typed_service_exit_and_exact_json_survive[1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_typed_service_exit_and_exact_json_survive[2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_typed_service_exit_and_exact_json_survive[3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_help_and_unsupported_authority_never_call_providers[argv0-0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_help_and_unsupported_authority_never_call_providers[argv1-2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_preexecution_failures_are_redacted_and_do_not_execute[root] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_preexecution_failures_are_redacted_and_do_not_execute[canonical] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_preexecution_failures_are_redacted_and_do_not_execute[reader] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_preexecution_failures_are_redacted_and_do_not_execute[io] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_preexecution_failures_are_redacted_and_do_not_execute[runtime] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_unexpected_execution_failure_cannot_invent_empty_effects | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_output_failure_never_retries_json[short] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_output_failure_never_retries_json[write] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_output_failure_never_retries_json[flush] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_output_failure_never_retries_json[serialize] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_installed_entry_binds_fixed_local_user_and_one_reader[True-False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_installed_entry_binds_fixed_local_user_and_one_reader[True-True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_installed_entry_binds_fixed_local_user_and_one_reader[False-False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_validate_all_default_pair_uses_real_planner[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_validate_all_default_pair_uses_real_planner[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_failed_report_publication_keeps_selected_gate_failure | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_cli_dry_run.py | test_partial_service_failure_retains_reported_effects | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/scripts/dev_tools/discovery/test_domain_neutrality.py | test_rendered_v2_drafts_use_only_caller_identity_and_empty_knowledge | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_configuration_preserves_protected_effect_accounting[activate] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_configuration_preserves_protected_effect_accounting[deactivate] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_scenario_creation_keeps_unknown_expectation_and_unexecuted_state | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_exact_replacement_requires_identity_cas_path_and_explicit_approval[None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_exact_replacement_requires_identity_cas_path_and_explicit_approval[stale] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_exact_replacement_requires_identity_cas_path_and_explicit_approval[outside] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_exact_replacement_requires_identity_cas_path_and_explicit_approval[wrong-kind] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_exact_replacement_requires_identity_cas_path_and_explicit_approval[approval] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_acceptance_preview_retains_structured_sources_and_pending_views[legacy-characterization] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_acceptance_preview_retains_structured_sources_and_pending_views[target-acceptance] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_clean_snapshot_export_publishes_exact_files | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_malformed_captured_transport_never_becomes_publication_authority[snapshot-import] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_malformed_captured_transport_never_becomes_publication_authority[import-inventory] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_host_workflow.py | test_host_workflow_completes_and_refuses_drift_and_unconsumed_grants | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_malformed_request_stops_before_authority[fields0] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_malformed_request_stops_before_authority[fields1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_malformed_request_stops_before_authority[fields2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_malformed_request_stops_before_authority[fields3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_malformed_request_stops_before_authority[fields4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_explicit_host_or_spoofed_reference_never_falls_back[host] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_explicit_host_or_spoofed_reference_never_falls_back[invocation_ref] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_explicit_host_or_spoofed_reference_never_falls_back[authorization_ref] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_installed_identity_failure_is_not_a_resource_only_success | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_profile_operations_preserve_v2_and_actual_manifest[profile] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_profile_operations_preserve_v2_and_actual_manifest[validate-profile] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[True] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[False] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_source_page_preserves_authorized_bytes_and_line_identity[list] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_source_page_preserves_authorized_bytes_and_line_identity[read] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_source_page_preserves_authorized_bytes_and_line_identity[search] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-coverage-ledger] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-runtime-scenario] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-parity-matrix] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-unspecified-behavior] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-product-decision] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-evidence-reference] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_inventory_selection_retains_captured_source_hash[None] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_inventory_selection_retains_captured_source_hash[selector1] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service.py | test_source_without_independent_selection_is_unavailable | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_link_evidence_uses_captured_payload_and_exact_target_digest | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_publication.py | test_report_index_view_cannot_hide_an_authored_invalid_reference | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_projection_errors_propagate_without_fallback_or_publication[RG3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_projection_errors_propagate_without_fallback_or_publication[RG4] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_malformed_validate_all_retains_public_validator_findings | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_invalid_projection_validation_status_is_refused | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_acceptance_preview_preserves_ready_and_pending_selected_views[RG7] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_acceptance_preview_preserves_ready_and_pending_selected_views[RG8] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_acceptance_write_plans_complete_sources_and_selected_views | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_service_report_guards.py | test_report_dispatch_refuses_another_operation_family | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_draft_workspace_cannot_claim_completion_or_planning | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_inventory_publishes_a_current_snapshot_and_repeats_identically | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_contract_scenario_evidence_and_reports_stay_honest | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_confirmed_scope_with_evidence_completes_and_admits_planning | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_negative_states_never_produce_a_passing_gate[malformed] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_negative_states_never_produce_a_passing_gate[unreferenced] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_negative_states_never_produce_a_passing_gate[stale-profile] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_negative_states_never_produce_a_passing_gate[stale-payload] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_exit_codes_map_rejections_and_unavailability_distinctly[case0-2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_exit_codes_map_rejections_and_unavailability_distinctly[case1-2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_exit_codes_map_rejections_and_unavailability_distinctly[case2-2] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_exit_codes_map_rejections_and_unavailability_distinctly[case3-3] | FIX-NAMED | [P3-T7] |
| A | pytest ERROR | tests/discovery_runtime/test_public_source_workflow.py | test_exit_codes_map_rejections_and_unavailability_distinctly[case4-3] | FIX-NAMED | [P3-T7] |
| A | pester | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | claude-architecture-doc.requires .dev/engineering/claude-code-architecture.md to use the active PowerShell MCP contract | FIX-NAMED | [P3-T6] |
| A | pester | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | claude-architecture-doc.requires the architecture document to cover research sufficiency, main-thread orchestration, and full migration tables | FIX-NAMED | [P3-T6] |
| A | pester | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | claude-architecture-doc.requires the architecture document to describe the discovery controls and the planning prerequisite linkage (issue #980) | FIX-NAMED | [P3-T6] |
| A | pester | tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | claude-architecture-doc.requires the architecture document to keep .agents/skills/README.md documentation-only and not require .claude/skills/README.md | FIX-NAMED | [P3-T6] |
| A | pester | tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | Less-evidence contract (issue #1097, entry 0009).LEC-BASELINE-HELD-AUDIT-AGENTS keeps the baseline and comparison text | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | Less-evidence contract (issue #1097, entry 0009).LEC-BASELINE-HELD-TEMPLATE keeps the baseline and comparison text | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | Less-evidence contract (issue #1097, entry 0009).LEC-CROSS-CHECK-AUDIT-AGENTS names the CI Cross-check section | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | Less-evidence contract (issue #1097, entry 0009).LEC-CROSS-CHECK-TEMPLATE names the CI Cross-check section | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | Less-evidence contract (issue #1097, entry 0009).LEC-PYTHON-TOTAL-TEMPLATE reads the Python repo-wide total from the CI threshold step | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | Less-evidence contract (issue #1097, entry 0009).LEC-SCOPE-LISTING-TEMPLATE keeps the section 9 heading and drops both listing subsections | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | Parallel gate wording.Class sweep.PGW-SWEEP-SURFACES finds no removed-class token in any surface | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | Parallel gate wording.PGW-AUDIT-AGENTS carries the required wording and no forbidden wording | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | Parallel gate wording.PGW-AUDIT-TEMPLATE carries the required wording and no forbidden wording | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 | Planning contract wording.PCW-STANDING-RULE-AGENTS states the process-reduction ledger rule | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 | Planning contract wording.PCW-STANDING-RULE-AGENTS-BUNDLE states the process-reduction ledger rule | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 | Planning contract wording.PCW-STANDING-RULE-CLAUDE states the process-reduction ledger rule | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 | Planning contract wording.PCW-STANDING-RULE-CLAUDE-BUNDLE states the process-reduction ledger rule | FIX-NAMED | [P3-T9] |
| A | pester | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | Codex epic runtime configuration and distribution contracts.preserves the merged planner lifecycle boundary | FIX-NAMED | [P3-T6] (A30 pinned kickoff pattern) |
| A | pester | tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 | Committed process-reduction ledger chain.PRC-LEDGER-CHAIN-HOLDS reverts every entry newest-first with no error | FIX-NAMED | [P3-T4] (feature plan template bundle copy) |
