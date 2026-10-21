# P6-T1 publication repair tests

Timestamp: 2026-10-21T09-57

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov=drm_copilot_discovery.migration_capture --cov=drm_copilot_discovery.mutation_plan --cov=drm_copilot_discovery.migration_conversion -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-capture-repair-093334-tests-coverage.json tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[coverage-ledger] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[evidence-reference] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[feature-contract] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[parity-matrix] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[product-decision] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[runtime-characterization-scenario] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[unspecified-behavior] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[unknown] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest tests/discovery_runtime/test_migration_capture.py::test_migration_capture_empty_selection_preserves_original_io tests/discovery_runtime/test_migration_capture.py::test_migration_capture_retains_exact_files_and_trusted_ports tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_invalid_selection[duplicate] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_invalid_selection[traversal] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_invalid_selection[link] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_changed_originals[changed] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_changed_originals[missing] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_conflicting_observations tests/discovery_runtime/test_migration_capture.py::test_migration_capture_reserves_before_reads[file-count] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_reserves_before_reads[work] tests/discovery_runtime/test_migration_capture.py::test_migration_capture_reserves_before_reads[bytes] tests/discovery_runtime/test_mutation_plan.py::test_values_reject_mutability_and_metadata_ambiguity tests/discovery_runtime/test_mutation_plan.py::test_planner_projects_complete_valid_graph_and_preserves_originals tests/discovery_runtime/test_mutation_plan.py::test_projection_refuses_uncaptured_profile_bytes tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short] tests/discovery_runtime/test_migration_unknowns.py::test_every_original_field_remains_untrusted_metadata[coverage-ledger] tests/discovery_runtime/test_migration_unknowns.py::test_legacy_claims_do_not_become_verified_target_state[coverage-ledger-fields4] tests/discovery_runtime/test_coverage_scope.py::test_trusted_pin_mismatch_is_rejected_even_when_documents_agree[coverage-ledger]`

EXIT_CODE: 0

Output Summary: PASS; 1420.024 seconds; 40 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 40 items

tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[coverage-ledger] PASSED [  2%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[evidence-reference] PASSED [  5%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[feature-contract] PASSED [  7%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[parity-matrix] PASSED [ 10%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[product-decision] PASSED [ 12%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[runtime-characterization-scenario] PASSED [ 15%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[unspecified-behavior] PASSED [ 17%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[unknown] PASSED [ 20%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] PASSED [ 22%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] PASSED [ 25%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] PASSED [ 27%]
tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] PASSED [ 30%]
tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] PASSED [ 32%]
tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files PASSED [ 35%]
tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest PASSED [ 37%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_empty_selection_preserves_original_io PASSED [ 40%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_retains_exact_files_and_trusted_ports PASSED [ 42%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_invalid_selection[duplicate] PASSED [ 45%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_invalid_selection[traversal] PASSED [ 47%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_invalid_selection[link] PASSED [ 50%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_changed_originals[changed] PASSED [ 52%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_changed_originals[missing] PASSED [ 55%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_rejects_conflicting_observations PASSED [ 57%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_reserves_before_reads[file-count] PASSED [ 60%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_reserves_before_reads[work] PASSED [ 62%]
tests/discovery_runtime/test_migration_capture.py::test_migration_capture_reserves_before_reads[bytes] PASSED [ 65%]
tests/discovery_runtime/test_mutation_plan.py::test_values_reject_mutability_and_metadata_ambiguity PASSED [ 67%]
tests/discovery_runtime/test_mutation_plan.py::test_planner_projects_complete_valid_graph_and_preserves_originals PASSED [ 70%]
tests/discovery_runtime/test_mutation_plan.py::test_projection_refuses_uncaptured_profile_bytes PASSED [ 72%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[coalesced] PASSED [ 75%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[count-exhausted] PASSED [ 77%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[read-exhausted] PASSED [ 80%]
tests/discovery_runtime/test_migration_capture.py::test_capture_checks_exact_capacity_and_original_bytes[byte-conflict] PASSED [ 82%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-exact] PASSED [ 85%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[count-short] PASSED [ 87%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-exact] PASSED [ 90%]
tests/discovery_runtime/test_migration_capture.py::test_projection_reserves_exact_merged_capacity_before_retention[bytes-short] PASSED [ 92%]
tests/discovery_runtime/test_migration_unknowns.py::test_every_original_field_remains_untrusted_metadata[coverage-ledger] PASSED [ 95%]
tests/discovery_runtime/test_migration_unknowns.py::test_legacy_claims_do_not_become_verified_target_state[coverage-ledger-fields4] PASSED [ 97%]
tests/discovery_runtime/test_coverage_scope.py::test_trusted_pin_mismatch_is_rejected_even_when_documents_agree[coverage-ledger] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py        120      4     44      4    95%   45, 76, 83, 119
packages\discovery-runtime\src\drm_copilot_discovery\migration_conversion.py      76      6     26      6    88%   42, 52, 68, 104, 247, 295
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py            214     21     96     15    86%   80, 118, 158, 205-210, 330, 362, 366, 379, 410, 420, 425, 429, 440, 444, 471, 478
packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py        111     41     28      6    62%   92, 112-160, 177-232, 265, 326, 349, 351, 354
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            521     72    194     31    84%
Coverage JSON written to file SCRATCH\p6t1-capture-repair-093334-tests-coverage.json
======================= 40 passed in 1419.28s (0:23:39) =======================

```
