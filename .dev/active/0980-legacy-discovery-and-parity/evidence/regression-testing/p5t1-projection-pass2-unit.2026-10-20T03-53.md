# p5t1-projection-pass2-unit

Timestamp: 2026-10-20T03-53
Command: poetry run pytest tests/discovery_runtime/test_validation_modes.py tests/discovery_runtime/test_agent_output.py tests/discovery_runtime/test_mutation_plan.py -o addopts= -v --cov=drm_copilot_discovery.validation --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage.json
EXIT_CODE: 1
Output Summary: scoped unit; duration 924.432 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 136 items

tests/discovery_runtime/test_validation_modes.py::test_initialized_draft_is_structural_success_but_not_completion[discovery-complete] PASSED [  0%]
tests/discovery_runtime/test_validation_modes.py::test_initialized_draft_is_structural_success_but_not_completion[parity-complete] PASSED [  1%]
tests/discovery_runtime/test_validation_modes.py::test_initialized_draft_is_structural_success_but_not_completion[planning] PASSED [  2%]
tests/discovery_runtime/test_validation_modes.py::test_confirmed_empty_scope_can_complete_without_synthetic_features[structural] PASSED [  2%]
tests/discovery_runtime/test_validation_modes.py::test_confirmed_empty_scope_can_complete_without_synthetic_features[discovery-complete] PASSED [  3%]
tests/discovery_runtime/test_validation_modes.py::test_confirmed_empty_scope_can_complete_without_synthetic_features[parity-complete] PASSED [  4%]
tests/discovery_runtime/test_validation_modes.py::test_confirmed_empty_scope_can_complete_without_synthetic_features[planning] PASSED [  5%]
tests/discovery_runtime/test_validation_modes.py::test_planning_obeys_explicit_profile_prerequisite[none-True] PASSED [  5%]
tests/discovery_runtime/test_validation_modes.py::test_planning_obeys_explicit_profile_prerequisite[discovery-complete-False] PASSED [  6%]
tests/discovery_runtime/test_validation_modes.py::test_planning_obeys_explicit_profile_prerequisite[parity-complete-False] PASSED [  7%]
tests/discovery_runtime/test_validation_modes.py::test_absent_snapshot_fails_closed_in_every_mode[structural] PASSED [  8%]
tests/discovery_runtime/test_validation_modes.py::test_absent_snapshot_fails_closed_in_every_mode[agent-output] PASSED [  8%]
tests/discovery_runtime/test_validation_modes.py::test_absent_snapshot_fails_closed_in_every_mode[discovery-complete] PASSED [  9%]
tests/discovery_runtime/test_validation_modes.py::test_absent_snapshot_fails_closed_in_every_mode[parity-complete] PASSED [ 10%]
tests/discovery_runtime/test_validation_modes.py::test_absent_snapshot_fails_closed_in_every_mode[planning] PASSED [ 11%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[missing-profile] PASSED [ 11%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[malformed-profile] PASSED [ 12%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[profile-mismatch] PASSED [ 13%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[missing-descriptor] PASSED [ 13%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[parsed-mismatch] PASSED [ 14%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[v1] PASSED [ 15%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[wrong-kind] PASSED [ 16%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[bad-unreferenced] PASSED [ 16%]
tests/discovery_runtime/test_validation_modes.py::test_all_retained_inputs_are_checked_before_graph_success[pins] PASSED [ 17%]
tests/discovery_runtime/test_validation_modes.py::test_loader_findings_are_preserved_and_deterministically_sorted PASSED [ 18%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] PASSED [ 19%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-absent-root] PASSED [ 19%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-absent-report] PASSED [ 20%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-initialized-root] PASSED [ 21%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-absent-root] PASSED [ 22%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-absent-report] PASSED [ 22%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[id] PASSED [ 23%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[mode] PASSED [ 24%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[extra] PASSED [ 25%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[agent-output] PASSED [ 25%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[coverage] PASSED [ 26%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[discovery_result] PASSED [ 27%]
tests/discovery_runtime/test_validation_modes.py::test_authored_report_contract_cannot_replace_recomputation[completion_findings] PASSED [ 27%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [ 28%]
tests/discovery_runtime/test_validation_modes.py::test_semantic_digest_tracks_changed_source_bytes PASSED [ 29%]
tests/discovery_runtime/test_validation_modes.py::test_semantic_digest_preserves_non_output_missing_inputs[src/missing.cs] PASSED [ 30%]
tests/discovery_runtime/test_validation_modes.py::test_semantic_digest_preserves_non_output_missing_inputs[docs/migration/discovery/reports-neighbor/input.json] PASSED [ 30%]
tests/discovery_runtime/test_validation_modes.py::test_composed_warning_findings_are_bounded_and_truncation_blocks[1-True] PASSED [ 31%]
tests/discovery_runtime/test_validation_modes.py::test_composed_warning_findings_are_bounded_and_truncation_blocks[120-False] PASSED [ 32%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile] FAILED [ 33%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[loader] PASSED [ 33%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-False] PASSED [ 34%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-True] PASSED [ 35%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-False] PASSED [ 36%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-True] PASSED [ 36%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-False] PASSED [ 37%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-True] PASSED [ 38%]
tests/discovery_runtime/test_agent_output.py::test_all_four_roles_validate_only_their_exact_supplied_outputs[legacy-parity-analyst] PASSED [ 38%]
tests/discovery_runtime/test_agent_output.py::test_all_four_roles_validate_only_their_exact_supplied_outputs[runtime-characterization-analyst] PASSED [ 39%]
tests/discovery_runtime/test_agent_output.py::test_all_four_roles_validate_only_their_exact_supplied_outputs[requirements-reconciler] PASSED [ 40%]
tests/discovery_runtime/test_agent_output.py::test_all_four_roles_validate_only_their_exact_supplied_outputs[migration-coverage-reviewer] PASSED [ 41%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[completion-report] PASSED [ 41%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[coverage-report] PASSED [ 42%]
tests/discovery_runtime/test_agent_output.py::test_unrelated_stable_report_does_not_break_incremental_outputs PASSED [ 43%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[role] PASSED [ 44%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[invocation] PASSED [ 44%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[workspace] PASSED [ 45%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[checksum] PASSED [ 46%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[profile] PASSED [ 47%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[stored] PASSED [ 47%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[malformed] PASSED [ 48%]
tests/discovery_runtime/test_agent_output.py::test_manifest_cannot_override_independent_invocation_bindings[unknown-role] PASSED [ 49%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[missing] PASSED [ 50%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[kind] PASSED [ 50%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[id] PASSED [ 51%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[format] PASSED [ 52%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[path] PASSED [ 52%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[precondition] PASSED [ 53%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[duplicate] PASSED [ 54%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[manifest-omitted] PASSED [ 55%]
tests/discovery_runtime/test_agent_output.py::test_exact_required_output_rows_cannot_be_broadened_or_substituted[forbidden] PASSED [ 55%]
tests/discovery_runtime/test_agent_output.py::test_ungranted_captured_input_changes_fail_output_validation[addition] PASSED [ 56%]
tests/discovery_runtime/test_agent_output.py::test_ungranted_captured_input_changes_fail_output_validation[deletion] PASSED [ 57%]
tests/discovery_runtime/test_agent_output.py::test_ungranted_captured_input_changes_fail_output_validation[bytes] PASSED [ 58%]
tests/discovery_runtime/test_agent_output.py::test_ungranted_captured_input_changes_fail_output_validation[category] PASSED [ 58%]
tests/discovery_runtime/test_agent_output.py::test_role_context_cannot_be_reused_as_root_mode_authority[structural] PASSED [ 59%]
tests/discovery_runtime/test_agent_output.py::test_role_context_cannot_be_reused_as_root_mode_authority[discovery-complete] PASSED [ 60%]
tests/discovery_runtime/test_agent_output.py::test_role_context_cannot_be_reused_as_root_mode_authority[parity-complete] PASSED [ 61%]
tests/discovery_runtime/test_agent_output.py::test_role_context_cannot_be_reused_as_root_mode_authority[planning] PASSED [ 61%]
tests/discovery_runtime/test_agent_output.py::test_role_output_needs_context_and_reviewer_needs_exact_review_mode PASSED [ 62%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[proposed-proposed-True-None] PASSED [ 63%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[approved-approved-True-None] PASSED [ 63%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[proposed-proposed-False-OUTPUT_UNSELECTED] PASSED [ 64%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[proposed-approved-True-OUTPUT_APPROVAL] PASSED [ 65%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[approved-proposed-True-OUTPUT_APPROVAL] PASSED [ 66%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[approved-None-True-OUTPUT_APPROVAL] PASSED [ 66%]
tests/discovery_runtime/test_agent_output.py::test_selected_proposals_and_protected_approval_history[None-approved-True-OUTPUT_APPROVAL] PASSED [ 67%]
tests/discovery_runtime/test_agent_output.py::test_opaque_payload_must_be_nonempty_and_exactly_granted[False] PASSED [ 68%]
tests/discovery_runtime/test_agent_output.py::test_opaque_payload_must_be_nonempty_and_exactly_granted[True] PASSED [ 69%]
tests/discovery_runtime/test_agent_output.py::test_digest_ignores_own_checksum_but_preserves_output_order PASSED [ 69%]
tests/discovery_runtime/test_mutation_plan.py::test_planner_projects_complete_valid_graph_and_preserves_originals PASSED [ 70%]
tests/discovery_runtime/test_mutation_plan.py::test_plan_permutation_and_repeatability_property PASSED [ 71%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[content] PASSED [ 72%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[kind] PASSED [ 72%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[id] PASSED [ 73%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[digest] PASSED [ 74%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[grant] PASSED [ 75%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[duplicate] PASSED [ 75%]
tests/discovery_runtime/test_mutation_plan.py::test_invalid_proposals_never_change_valid_existing_bytes[missing] PASSED [ 76%]
tests/discovery_runtime/test_mutation_plan.py::test_unchanged_bytes_are_explicit_skips PASSED [ 77%]
tests/discovery_runtime/test_mutation_plan.py::test_role_output_uses_exact_accepted_validator[legacy-parity-analyst] PASSED [ 77%]
tests/discovery_runtime/test_mutation_plan.py::test_role_output_uses_exact_accepted_validator[runtime-characterization-analyst] PASSED [ 78%]
tests/discovery_runtime/test_mutation_plan.py::test_role_output_uses_exact_accepted_validator[requirements-reconciler] PASSED [ 79%]
tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[role] PASSED [ 80%]
tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[workspace] PASSED [ 80%]
tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[baseline] PASSED [ 81%]
tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[manifest] PASSED [ 82%]
tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[unrequested] PASSED [ 83%]
tests/discovery_runtime/test_mutation_plan.py::test_unsafe_or_misclassified_paths_fail_before_write[src/changed.py] PASSED [ 83%]
tests/discovery_runtime/test_mutation_plan.py::test_unsafe_or_misclassified_paths_fail_before_write[config/discovery.json] PASSED [ 84%]
tests/discovery_runtime/test_mutation_plan.py::test_unsafe_or_misclassified_paths_fail_before_write[../escape] PASSED [ 85%]
tests/discovery_runtime/test_mutation_plan.py::test_unsafe_or_misclassified_paths_fail_before_write[docs/migration/discovery/reports/arbitrary.json] PASSED [ 86%]
tests/discovery_runtime/test_mutation_plan.py::test_parser_findings_are_retained_in_graph_rejection PASSED [ 86%]
tests/discovery_runtime/test_mutation_plan.py::test_change_rejects_malformed_original_digests[short] PASSED [ 87%]
tests/discovery_runtime/test_mutation_plan.py::test_change_rejects_malformed_original_digests[AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA] PASSED [ 88%]
tests/discovery_runtime/test_mutation_plan.py::test_change_rejects_malformed_original_digests[gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg] PASSED [ 88%]
tests/discovery_runtime/test_mutation_plan.py::test_values_reject_mutability_and_metadata_ambiguity PASSED [ 89%]
tests/discovery_runtime/test_mutation_plan.py::test_bounded_empty_and_oversized_changes_fail PASSED [ 90%]
tests/discovery_runtime/test_mutation_plan.py::test_directory_enumeration_permutations_preserve_capture PASSED [ 91%]
tests/discovery_runtime/test_mutation_plan.py::test_opaque_grants_cannot_create_structured_records[evidence-payload] PASSED [ 91%]
tests/discovery_runtime/test_mutation_plan.py::test_opaque_grants_cannot_create_structured_records[acceptance-view] PASSED [ 92%]
tests/discovery_runtime/test_mutation_plan.py::test_report_view_requires_exact_structured_peer[False] PASSED [ 93%]
tests/discovery_runtime/test_mutation_plan.py::test_report_view_requires_exact_structured_peer[True] PASSED [ 94%]
tests/discovery_runtime/test_mutation_plan.py::test_projection_replays_only_captured_git_objects[none] PASSED [ 94%]
tests/discovery_runtime/test_mutation_plan.py::test_projection_replays_only_captured_git_objects[missing] PASSED [ 95%]
tests/discovery_runtime/test_mutation_plan.py::test_projection_replays_only_captured_git_objects[oversized] PASSED [ 96%]
tests/discovery_runtime/test_mutation_plan.py::test_projection_refuses_uncaptured_profile_bytes PASSED [ 97%]
tests/discovery_runtime/test_mutation_plan.py::test_capture_rejects_metadata_changes_during_loading PASSED [ 97%]
tests/discovery_runtime/test_mutation_plan.py::test_coverage_report_mutations_reject_forged_projection_fields[coverage] PASSED [ 98%]
tests/discovery_runtime/test_mutation_plan.py::test_coverage_report_mutations_reject_forged_projection_fields[discovery_result] PASSED [ 99%]
tests/discovery_runtime/test_mutation_plan.py::test_coverage_report_mutations_reject_forged_projection_fields[completion_findings] PASSED [100%]

================================== FAILURES ===================================
_ test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
fault = 'missing-profile'

    @pytest.mark.parametrize("fault", ["missing-profile", "loader"])
    def test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts(
        snapshot_catalog: SchemaCatalog, fault: str
    ) -> None:
        """For fault (str), project blockers without trusting invalid population bytes."""
        snapshot = no_scope_snapshot(snapshot_catalog)
        if fault == "missing-profile":
>           snapshot = replace(snapshot, manifest=replace(snapshot.manifest, files=()))
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_validation_modes.py:384:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...aaaaaaaaaaaaaaaaaaaaaaaaaaaa'), origin_path=None)), repository_files=(), checkout=None, excluded_paths=(), findings=())

    def __post_init__(self) -> None:
        """Freeze collections and require every parsed artifact to have raw bytes."""
        artifacts = tuple(sorted(self.artifacts, key=lambda item: item.path))
        check_path_collisions(item.path for item in artifacts)
        captured = {item.path for item in self.manifest.files}
        if any(item.path not in captured for item in artifacts):
>           raise ValueError("Every parsed artifact requires captured input bytes")
E           ValueError: Every parsed artifact requires captured input bytes

packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:215: ValueError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                 Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py     146      1     50      1    99%   187
----------------------------------------------------------------------------------------------------------------
TOTAL                                                                  146      1     50      1    99%
Coverage JSON written to file SCRATCH/coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile]
================== 1 failed, 135 passed in 922.63s (0:15:22) ==================
```
