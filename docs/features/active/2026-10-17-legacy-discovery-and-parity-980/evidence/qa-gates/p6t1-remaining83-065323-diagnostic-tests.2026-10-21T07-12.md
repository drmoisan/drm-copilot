# P6-T1 final diagnostic-tests

Timestamp: 2026-10-21T07-12

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider @SCRATCH\p6t1-remaining83-065323-nodes.txt`

EXIT_CODE: 1

Output Summary: FAIL; 1133.678 seconds; 78 passed nodes; timeout=False.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 83 items

tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[document] PASSED [  1%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[text] PASSED [  2%]
tests/discovery_runtime/test_service_boundaries.py::test_context_invalid_or_unavailable_inputs_fail_explicitly[strings] PASSED [  3%]
tests/discovery_runtime/test_service_boundaries.py::test_direct_publication_context_cannot_derive_host_grants[host] PASSED [  4%]
tests/discovery_runtime/test_service_boundaries.py::test_direct_publication_context_cannot_derive_host_grants[invocation_ref] PASSED [  6%]
tests/discovery_runtime/test_service_boundaries.py::test_direct_publication_context_cannot_derive_host_grants[authorization_ref] PASSED [  7%]
tests/discovery_runtime/test_service_boundaries.py::test_interrupted_publication_preserves_actual_conflict_and_failure PASSED [  8%]
tests/discovery_runtime/test_service_boundaries.py::test_bootstrap_interruption_retains_directory_effects_without_file_digest FAILED [  9%]
tests/discovery_runtime/test_service_boundaries.py::test_native_operations_remain_unavailable_without_a_verified_provider[prepare-agent] PASSED [ 10%]
tests/discovery_runtime/test_service_boundaries.py::test_native_operations_remain_unavailable_without_a_verified_provider[finalize-agent] PASSED [ 12%]
tests/discovery_runtime/test_service_boundaries.py::test_failed_freshness_preserves_observation_without_second_read PASSED [ 13%]
tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction[False] PASSED [ 14%]
tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction[True] PASSED [ 15%]
tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings[False] PASSED [ 16%]
tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings[True] PASSED [ 18%]
tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[True] PASSED [ 19%]
tests/discovery_runtime/test_service_publication.py::test_new_contract_uses_real_plan_and_honest_file_effects[False] PASSED [ 20%]
tests/discovery_runtime/test_service_publication.py::test_nonempty_provider_grants_are_never_expanded[extra] PASSED [ 21%]
tests/discovery_runtime/test_service_publication.py::test_nonempty_provider_grants_are_never_expanded[wrong-id] PASSED [ 22%]
tests/discovery_runtime/test_service_publication.py::test_nonempty_provider_grants_are_never_expanded[wrong-path] PASSED [ 24%]
tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[coverage-report] PASSED [ 25%]
tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[parity-report] PASSED [ 26%]
tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[completion-report] PASSED [ 27%]
tests/discovery_runtime/test_service_publication.py::test_pure_report_format_does_not_publish[json] PASSED [ 28%]
tests/discovery_runtime/test_service_publication.py::test_pure_report_format_does_not_publish[markdown] PASSED [ 30%]
tests/discovery_runtime/test_service_publication.py::test_pure_report_format_does_not_publish[both] PASSED [ 31%]
tests/discovery_runtime/test_service_publication.py::test_validate_all_defaults_to_paired_reports_and_rejects_outside_root PASSED [ 32%]
tests/discovery_runtime/test_service_publication.py::test_malformed_core_cannot_publish_a_diagnostic_report PASSED [ 33%]
tests/discovery_runtime/test_service_publication.py::test_explicit_bootstrap_preserves_actual_directory_and_file_units[True] PASSED [ 34%]
tests/discovery_runtime/test_service_publication.py::test_explicit_bootstrap_preserves_actual_directory_and_file_units[False] PASSED [ 36%]
tests/discovery_runtime/test_service_publication.py::test_configuration_preserves_protected_effect_accounting[activate] PASSED [ 37%]
tests/discovery_runtime/test_service_publication.py::test_configuration_preserves_protected_effect_accounting[deactivate] PASSED [ 38%]
tests/discovery_runtime/test_service_publication.py::test_scenario_creation_keeps_unknown_expectation_and_unexecuted_state PASSED [ 39%]
tests/discovery_runtime/test_service_publication.py::test_exact_replacement_requires_identity_cas_path_and_explicit_approval[None] PASSED [ 40%]
tests/discovery_runtime/test_service_publication.py::test_exact_replacement_requires_identity_cas_path_and_explicit_approval[stale] PASSED [ 42%]
tests/discovery_runtime/test_service_publication.py::test_exact_replacement_requires_identity_cas_path_and_explicit_approval[outside] PASSED [ 43%]
tests/discovery_runtime/test_service_publication.py::test_exact_replacement_requires_identity_cas_path_and_explicit_approval[wrong-kind] PASSED [ 44%]
tests/discovery_runtime/test_service_publication.py::test_exact_replacement_requires_identity_cas_path_and_explicit_approval[approval] PASSED [ 45%]
tests/discovery_runtime/test_service_publication.py::test_acceptance_preview_retains_structured_sources_and_pending_views[legacy-characterization] PASSED [ 46%]
tests/discovery_runtime/test_service_publication.py::test_acceptance_preview_retains_structured_sources_and_pending_views[target-acceptance] PASSED [ 48%]
tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] PASSED [ 49%]
tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] FAILED [ 50%]
tests/discovery_runtime/test_service_publication.py::test_malformed_captured_transport_never_becomes_publication_authority[snapshot-import] PASSED [ 51%]
tests/discovery_runtime/test_service_publication.py::test_malformed_captured_transport_never_becomes_publication_authority[import-inventory] PASSED [ 53%]
tests/discovery_runtime/test_service_publication.py::test_failed_initialization_retains_conflicting_path_without_fake_digest PASSED [ 54%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] FAILED [ 55%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] FAILED [ 56%]
tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest FAILED [ 57%]
tests/discovery_runtime/test_service_publication.py::test_report_index_view_cannot_hide_an_authored_invalid_reference PASSED [ 59%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields0] PASSED [ 60%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields1] PASSED [ 61%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields2] PASSED [ 62%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields3] PASSED [ 63%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields4] PASSED [ 65%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[host] PASSED [ 66%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[invocation_ref] PASSED [ 67%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[authorization_ref] PASSED [ 68%]
tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success PASSED [ 69%]
tests/discovery_runtime/test_service.py::test_profile_operations_preserve_v2_and_actual_manifest[profile] PASSED [ 71%]
tests/discovery_runtime/test_service.py::test_profile_operations_preserve_v2_and_actual_manifest[validate-profile] PASSED [ 72%]
tests/discovery_runtime/test_service.py::test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[True] PASSED [ 73%]
tests/discovery_runtime/test_service.py::test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[False] PASSED [ 74%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[list] PASSED [ 75%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read] PASSED [ 77%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[search] PASSED [ 78%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] PASSED [ 79%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-coverage-ledger] PASSED [ 80%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-runtime-scenario] PASSED [ 81%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-parity-matrix] PASSED [ 83%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-unspecified-behavior] PASSED [ 84%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-product-decision] PASSED [ 85%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-evidence-reference] PASSED [ 86%]
tests/discovery_runtime/test_service.py::test_inventory_selection_retains_captured_source_hash[None] PASSED [ 87%]
tests/discovery_runtime/test_service.py::test_inventory_selection_retains_captured_source_hash[selector1] PASSED [ 89%]
tests/discovery_runtime/test_service.py::test_source_without_independent_selection_is_unavailable PASSED [ 90%]
tests/discovery_runtime/test_service.py::test_doctor_uses_verified_runtime_without_claiming_native_capability PASSED [ 91%]
tests/discovery_runtime/test_service.py::test_decision_validation_preserves_complete_graph_result PASSED [ 92%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields0] PASSED [ 93%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields1] PASSED [ 95%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields2] PASSED [ 96%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields3] PASSED [ 97%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields4] PASSED [ 98%]
tests/discovery_runtime/test_service.py::test_provider_mismatch_has_actionable_unavailable_context PASSED [100%]

================================== FAILURES ===================================
__ test_bootstrap_interruption_retains_directory_effects_without_file_digest __
tests\discovery_runtime\test_service_boundaries.py:363: in test_bootstrap_interruption_retains_directory_effects_without_file_digest
    assert result.artifacts == () and result.input_manifest is not None
E   AssertionError: assert ((ServiceArtif...content=None)) == ()
E
E     Left contains 6 more items, first extra item: ServiceArtifact(path='docs/migration/discovery/coverage-ledger.json', kind='coverage-ledger', status='planned', sha256='5020514418b1c12fc3f9f0b172b71d97de9188057a206f880bb5aa656fe22951', content=None)
E
E     Full diff:
E     - ()
E     + (
E     +     ServiceArtifact(...
E
E     ...Full output truncated (42 lines hidden), use '-vv' to show)
_ test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] _
tests\discovery_runtime\test_service_publication.py:334: in test_snapshot_export_uses_authored_identity_and_complete_original_capture
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='REPORT_RESULT', message='Report fields disagree with recomputed input results.', next_action='Correct the inputs and validate the requested mode.', severity='error', artifact_path='docs/migration/discovery/reports/validation-report.json', pointer='', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='snapshot-export', mode='structural', ok=False, exit_code=1, findings=(Finding(code='REPORT_RESULT', message='Report fields disagree with recomputed input results.', next_action='Correct the inputs and validate the requested mode.', severity='error', artifact_path='docs/migration/discovery/reports/validation-report.json', pointer='', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='config/discovery.json', content=b'{\n  "enabled": true,\n  "profile_path": "docs/migration/discovery/domain-profile.yaml",\n  "required_runtime_major": 2,\n  "schema_version": "2.0.0"\n}\n', category='activation'), SnapshotFile(path='docs/migration/discovery/coverage-ledger.json', content=b'{"$schema":"urn:drm-copilot:discovery:2.0.0:coverage-ledger","artifact_kind":"coverage-ledger","components":[],"extensions":{},"id":"ledger-consumer-system","inventory_snapshot_refs":[],"repository":"consumer-repository","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"...lients","cancellation","environment_constraints","failure","inputs","mobile","observable_outputs","offline","online","ordering","preconditions","security_permissions","side_effects","state_transitions","timing","trigger"],"evidence_refs":[],"extensions":{},"feature_refs":[{"artifact_kind":"feature-contract","id":"feature"}],"id":"unknown-feature-feature","impact":"Characterization and acceptance expectations remain unresolved.","question":"What legacy behavior applies to the unresolved dimensions of feature?","rationale":null,"resolution_basis":null,"resolution_evidence_refs":[],"schema_version":"2.0.0","status":"open"}],"schema_version":"2.0.0"}\n', category='artifact')), missing_paths=(), source_repositories=(RepositoryIdentity(id='consumer-repository', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),), target_repositories=(RepositoryIdentity(id='consumer-repository', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),)), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
____ test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] _____
tests\discovery_runtime\test_service_publication.py:403: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='SERVICE_KIND', message='The requested operation could not satisfy its contract.', next_action='Correct the reported input or trusted configuration.', severity='error', artifact_path=None, pointer='/inputs', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=2, findings=(Finding(code='SERVICE_KIND', message='The requested operation could not satisfy its contract.', next_action='Correct the reported input or trusted configuration.', severity='error', artifact_path=None, pointer='/inputs', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
____ test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] ____
tests\discovery_runtime\test_service_publication.py:403: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='SERVICE_KIND', message='The requested operation could not satisfy its contract.', next_action='Correct the reported input or trusted configuration.', severity='error', artifact_path=None, pointer='/inputs', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=2, findings=(Finding(code='SERVICE_KIND', message='The requested operation could not satisfy its contract.', next_action='Correct the reported input or trusted configuration.', severity='error', artifact_path=None, pointer='/inputs', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
______ test_link_evidence_uses_captured_payload_and_exact_target_digest _______
tests\discovery_runtime\test_service_publication.py:438: in test_link_evidence_uses_captured_payload_and_exact_target_digest
    assert result.ok, result.findings
E   AssertionError: (Finding(code='SNAPSHOT_UNRECOGNIZED', message='Unrecognized file in a configured artifact location.', next_action='Correct the input and reload the complete snapshot.', severity='error', artifact_path='docs/migration/discovery/evidence/capture.txt', pointer='', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = DiscoveryResult(operation='link-evidence', mode='structural', ok=False, exit_code=2, findings=(Finding(code='SNAPSHOT_UNRECOGNIZED', message='Unrecognized file in a configured artifact location.', next_action='Correct the input and reload the complete snapshot.', severity='error', artifact_path='docs/migration/discovery/evidence/capture.txt', pointer='', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='config/discovery.json', content=b'{\n  "enabled": true,\n  "profile_path": "docs/migration/discovery/domain-profile.yaml",\n  "required_runtime_major": 2,\n  "schema_version": "2.0.0"\n}\n', category='activation'), SnapshotFile(path='docs/migration/discovery/coverage-ledger.json', content=b'{"$schema":"urn:drm-copilot:discovery:2.0.0:coverage-ledger","artifact_kind":"coverage-ledger","components":[],"extensions":{},"id":"ledger-consumer-system","inventory_snapshot_refs":[],"repository":"consumer-repository","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","sch...value":"c1c5b3571fb5b5641631d085e69ed43ba7c499ab90821ef394dab3c86ee2e32c"},"confidence":"high","environment":{"client_id":null,"extensions":{},"id":"environment-alpha","operating_mode":"online","platform":"generic"},"evidence_id":"proof","evidence_type":"runtime","extensions":{},"id":"proof","notes":"Manual pre-state and post-state capture in an isolated synthetic environment.","path":"docs/migration/discovery/evidence/capture.txt","repository":"consumer-repository","revision":null,"runtime_artifact":{"capture_method":"manual","path":"docs/migration/discovery/evidence/capture.txt"},"schema_version":"2.0.0","timestamp":"2026-01-01T00:00:00Z"}\n', category='documentation')), missing_paths=(), source_repositories=(RepositoryIdentity(id='consumer-repository', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),), target_repositories=(RepositoryIdentity(id='consumer-repository', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),)), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_boundaries.py::test_bootstrap_interruption_retains_directory_effects_without_file_digest
FAILED tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True]
FAILED tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True]
FAILED tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False]
FAILED tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest
================== 5 failed, 78 passed in 1133.35s (0:18:53) ==================

```
