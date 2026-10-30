# P6-T1 renderer tests

Timestamp: 2026-10-20T14-52

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.service_contracts,drm_copilot_discovery.service_serialization,drm_copilot_discovery.service_request_rules -m pytest -v --tb=short --maxfail=6 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service_request_rules.py tests/discovery_runtime/test_service_failures.py tests/schemas/discovery/test_v2_service_result_failures.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 104.294 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 116 items

tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[init] PASSED [  0%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[configure] PASSED [  1%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[profile] PASSED [  2%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[inventory] PASSED [  3%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[new-contract] PASSED [  4%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[new-scenario] PASSED [  5%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[update-artifact] PASSED [  6%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[link-evidence] PASSED [  6%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-profile] PASSED [  7%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-feature-contract] PASSED [  8%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-coverage-ledger] PASSED [  9%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-runtime-scenario] PASSED [ 10%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-parity-matrix] PASSED [ 11%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-unspecified-behavior] PASSED [ 12%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-product-decision] PASSED [ 12%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-evidence-reference] PASSED [ 13%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-decisions] PASSED [ 14%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[validate-all] PASSED [ 15%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[coverage-report] PASSED [ 16%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[parity-report] PASSED [ 17%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[completion-report] PASSED [ 18%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[generate-acceptance] PASSED [ 18%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[snapshot-export] PASSED [ 19%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[snapshot-import] PASSED [ 20%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[import-inventory] PASSED [ 21%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[migrate] PASSED [ 22%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[doctor] PASSED [ 23%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[read-source] PASSED [ 24%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[prepare-agent] PASSED [ 25%]
tests/discovery_runtime/test_service_request_rules.py::test_all_fixed_operations_parse_without_dispatch[finalize-agent] PASSED [ 25%]
tests/discovery_runtime/test_service_request_rules.py::test_invalid_requests_retain_only_recognized_context[operation-secret-command] PASSED [ 26%]
tests/discovery_runtime/test_service_request_rules.py::test_invalid_requests_retain_only_recognized_context[mode-secret-mode] PASSED [ 27%]
tests/discovery_runtime/test_service_request_rules.py::test_invalid_requests_retain_only_recognized_context[inputs-value2] PASSED [ 28%]
tests/discovery_runtime/test_service_request_rules.py::test_invalid_requests_retain_only_recognized_context[dry_run-1] PASSED [ 29%]
tests/discovery_runtime/test_service_request_rules.py::test_invalid_requests_retain_only_recognized_context[id-../secret] PASSED [ 30%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[init-inputs0] PASSED [ 31%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[configure-inputs1] PASSED [ 31%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[configure-inputs2] PASSED [ 32%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[new-scenario-inputs3] PASSED [ 33%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[snapshot-export-inputs4] PASSED [ 34%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[inventory-inputs5] PASSED [ 35%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[update-artifact-inputs6] PASSED [ 36%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[update-artifact-inputs7] PASSED [ 37%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[read-source-inputs8] PASSED [ 37%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[read-source-inputs9] PASSED [ 38%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[read-source-inputs10] PASSED [ 39%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[read-source-inputs11] PASSED [ 40%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[profile-inputs12] PASSED [ 41%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[new-contract-inputs13] PASSED [ 42%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[migrate-inputs14] PASSED [ 43%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[migrate-inputs15] PASSED [ 43%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[link-evidence-inputs16] PASSED [ 44%]
tests/discovery_runtime/test_service_request_rules.py::test_operation_conditions_fail_before_any_service_io[update-artifact-inputs17] PASSED [ 45%]
tests/discovery_runtime/test_service_request_rules.py::test_migration_requires_complete_initialization_identity[system_id] PASSED [ 46%]
tests/discovery_runtime/test_service_request_rules.py::test_migration_requires_complete_initialization_identity[system_name] PASSED [ 47%]
tests/discovery_runtime/test_service_request_rules.py::test_migration_requires_complete_initialization_identity[system_role] PASSED [ 48%]
tests/discovery_runtime/test_service_request_rules.py::test_migration_requires_complete_initialization_identity[repository_id] PASSED [ 49%]
tests/discovery_runtime/test_service_request_rules.py::test_modes_flags_and_format_cannot_be_silently_ignored[doctor-write-True] PASSED [ 50%]
tests/discovery_runtime/test_service_request_rules.py::test_modes_flags_and_format_cannot_be_silently_ignored[doctor-dry_run-True] PASSED [ 50%]
tests/discovery_runtime/test_service_request_rules.py::test_modes_flags_and_format_cannot_be_silently_ignored[doctor-format-markdown] PASSED [ 51%]
tests/discovery_runtime/test_service_request_rules.py::test_modes_flags_and_format_cannot_be_silently_ignored[profile-mode-planning] PASSED [ 52%]
tests/discovery_runtime/test_service_request_rules.py::test_modes_flags_and_format_cannot_be_silently_ignored[completion-report-mode-agent-output] PASSED [ 53%]
tests/discovery_runtime/test_service_request_rules.py::test_modes_flags_and_format_cannot_be_silently_ignored[inventory-mode-planning] PASSED [ 54%]
tests/discovery_runtime/test_service_request_rules.py::test_valid_conditional_controls_and_role_context FAILED [ 55%]
tests/discovery_runtime/test_service_failures.py::test_result_roundtrip_is_detached_schema_valid_and_uses_installed_seam PASSED [ 56%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[ok-True] PASSED [ 56%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[exit_code-1] PASSED [ 57%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[exit_code-3] PASSED [ 58%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[operation-unknown] PASSED [ 59%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[mode-unknown] PASSED [ 60%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[artifacts-value5] PASSED [ 61%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[summary-value6] PASSED [ 62%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[input_manifest-value7] PASSED [ 62%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[runtime-value8] PASSED [ 63%]
tests/discovery_runtime/test_service_failures.py::test_result_constructor_rejects_false_or_untyped_claims[exit_code-True] PASSED [ 64%]
tests/discovery_runtime/test_service_failures.py::test_partial_failure_requires_real_context_and_preserves_original_hashes PASSED [ 65%]
tests/discovery_runtime/test_service_failures.py::test_artifact_contract_rejects_unsafe_file_claims[path-../report] PASSED [ 66%]
tests/discovery_runtime/test_service_failures.py::test_artifact_contract_rejects_unsafe_file_claims[kind-directory] PASSED [ 67%]
tests/discovery_runtime/test_service_failures.py::test_artifact_contract_rejects_unsafe_file_claims[status-unknown] PASSED [ 68%]
tests/discovery_runtime/test_service_failures.py::test_artifact_contract_rejects_unsafe_file_claims[sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA] PASSED [ 68%]
tests/discovery_runtime/test_service_failures.py::test_artifact_contract_rejects_unsafe_file_claims[content-1] PASSED [ 69%]
tests/discovery_runtime/test_service_failures.py::test_artifact_contract_rejects_unsafe_file_claims[content-\ud800] PASSED [ 70%]
tests/discovery_runtime/test_service_failures.py::test_runtime_identity_consistency_is_strict[package_version-1.0.0] PASSED [ 71%]
tests/discovery_runtime/test_service_failures.py::test_runtime_identity_consistency_is_strict[schema_version-3.0.0] PASSED [ 72%]
tests/discovery_runtime/test_service_failures.py::test_runtime_identity_consistency_is_strict[policy_version-True] PASSED [ 73%]
tests/discovery_runtime/test_service_failures.py::test_runtime_identity_consistency_is_strict[policy_version-0] PASSED [ 74%]
tests/discovery_runtime/test_service_failures.py::test_runtime_identity_consistency_is_strict[build_sha256-fake] PASSED [ 75%]
tests/discovery_runtime/test_service_failures.py::test_runtime_identity_consistency_is_strict[policy_sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA] PASSED [ 75%]
tests/discovery_runtime/test_service_failures.py::test_typed_runtime_and_invocation_failures_have_fixed_actionable_findings PASSED [ 76%]
tests/discovery_runtime/test_service_failures.py::test_authority_is_explicit_typed_and_does_not_mint_grants PASSED [ 77%]
tests/discovery_runtime/test_service_failures.py::test_request_budget_rejects_before_canonical_encoding PASSED [ 78%]
tests/discovery_runtime/test_service_failures.py::test_manifest_budget_rejects_before_hash_projection PASSED [ 79%]
tests/discovery_runtime/test_service_failures.py::test_wire_limits_reject_malformed_and_expensive_values_without_partial_copy PASSED [ 80%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_null_context_cannot_describe_success_or_semantic_completion[operation] PASSED [ 81%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_null_context_cannot_describe_success_or_semantic_completion[mode] PASSED [ 81%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_null_context_cannot_describe_success_or_semantic_completion[runtime] PASSED [ 82%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_null_context_cannot_describe_success_or_semantic_completion[input_manifest] PASSED [ 83%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_preexecution_failure_preserves_recognized_context[None-None-2] PASSED [ 84%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_preexecution_failure_preserves_recognized_context[inventory-None-2] PASSED [ 85%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_preexecution_failure_preserves_recognized_context[None-planning-2] PASSED [ 86%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_preexecution_failure_preserves_recognized_context[inventory-structural-2] PASSED [ 87%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_preexecution_failure_preserves_recognized_context[inventory-structural-3] PASSED [ 87%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[missing-key] PASSED [ 88%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[unknown-operation] PASSED [ 89%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[unknown-mode] PASSED [ 90%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[exit3-unknown] PASSED [ 91%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[artifacts] PASSED [ 92%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[counts] PASSED [ 93%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[validation] PASSED [ 93%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[receipt] PASSED [ 94%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[invocation] PASSED [ 95%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[pointer] PASSED [ 96%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[action] PASSED [ 97%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[runtime-shape] PASSED [ 98%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_failure_branch_rejects_partial_claims_and_ambiguous_context[manifest-shape] PASSED [ 99%]
tests/schemas/discovery/test_v2_service_result_failures.py::test_real_context_allows_partial_write_failure PASSED [100%]

================================== FAILURES ===================================
______________ test_valid_conditional_controls_and_role_context _______________
tests\discovery_runtime\test_service_request_rules.py:290: in test_valid_conditional_controls_and_role_context
    assert parsed(document, snapshot_catalog).operation == operation
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_service_request_rules.py:116: in parsed
    return parse_service_request(
packages\discovery-runtime\src\drm_copilot_discovery\service_contracts.py:391: in parse_service_request
    raise ServiceRequestError(
E   drm_copilot_discovery.service_contracts.ServiceRequestError: SERVICE_REQUEST: request requires correction
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_request_rules.py::test_valid_conditional_controls_and_role_context
================== 1 failed, 115 passed in 101.95s (0:01:41) ==================

```
