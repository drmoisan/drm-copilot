# p4t9-core-focused10 pytest

Timestamp: 2026-10-19T13-26

Command: .\.venv\Scripts\python.exe -m pytest -o addopts= tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py -v --tb=short --cov=drm_copilot_discovery.extension_results --cov=drm_copilot_discovery.extension_validation --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t9-core-focused10-coverage.json

EXIT_CODE: 1

Output Summary: Scoped pytest; elapsed 130.149 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 125 items

tests/discovery_runtime/test_extension_results.py::test_valid_bundle_preserves_versions_uncertainty_and_bytes PASSED [  0%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path0-3.0.0-SCHEMA] PASSED [  1%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path1-untrusted.module-SCHEMA] PASSED [  2%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path2-repository-IDENTITY] PASSED [  3%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path3-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-SOURCE] PASSED [  4%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path4-ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff-DIGEST] PASSED [  4%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path5-value5-SOURCE] PASSED [  5%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path6-docs/guide.md-SOURCE] PASSED [  6%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path7-0-SOURCE] PASSED [  7%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path8-src/member.json-PATH] PASSED [  8%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path9-../member.json-SCHEMA] PASSED [  8%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[manifest-path10-wrong-id-MEMBER] PASSED [  9%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path11-other-DIGEST] PASSED [ 10%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path12-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-DIGEST] PASSED [ 11%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path13-ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff-DIGEST] PASSED [ 12%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path14-8-IDENTITY] PASSED [ 12%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path15-repository-IDENTITY] PASSED [ 13%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path16-8-IDENTITY] PASSED [ 14%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path17-ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff-SOURCE] PASSED [ 15%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path18-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-SOURCE] PASSED [ 16%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path19-docs/guide.md-SOURCE] PASSED [ 16%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path20-verified-SCHEMA] PASSED [ 17%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path21-verified-SCHEMA] PASSED [ 18%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path22-value22-SOURCE] PASSED [ 19%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path23-value23-SOURCE] PASSED [ 20%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path24-missing-REFERENCE] PASSED [ 20%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path25-missing-REFERENCE] PASSED [ 21%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path26-value26-ACCOUNTING] PASSED [ 22%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path27-999-ACCOUNTING] PASSED [ 23%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path28-docs/other.md-ACCOUNTING] PASSED [ 24%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path29-value29-ACCOUNTING] PASSED [ 24%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path30-value30-ACCOUNTING] PASSED [ 25%]
tests/discovery_runtime/test_extension_results.py::test_invalid_claims_fail_closed[member-path31-value31-COLLISION] PASSED [ 26%]
tests/discovery_runtime/test_extension_results.py::test_selection_is_an_explicit_configured_tuple[selection0] PASSED [ 27%]
tests/discovery_runtime/test_extension_results.py::test_selection_is_an_explicit_configured_tuple[selection1] PASSED [ 28%]
tests/discovery_runtime/test_extension_results.py::test_selection_is_an_explicit_configured_tuple[selection2] PASSED [ 28%]
tests/discovery_runtime/test_extension_results.py::test_selection_is_an_explicit_configured_tuple[selection3] PASSED [ 29%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[manifest-hash] PASSED [ 30%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[member-hash] PASSED [ 31%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[missing-member] PASSED [ 32%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[category] PASSED [ 32%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[missing-pin] PASSED [ 33%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[changed-pin] PASSED [ 34%]
tests/discovery_runtime/test_extension_results.py::test_transport_and_independent_pin_failures[malformed-json] PASSED [ 35%]
tests/discovery_runtime/test_extension_results.py::test_line_ranges_share_cached_physical_bounds PASSED [ 36%]
tests/discovery_runtime/test_extension_results.py::test_generic_artifact_capture_remains_compatible PASSED [ 36%]
tests/discovery_runtime/test_extension_results.py::test_unexplained_capture_exclusion_has_fixed_input_error PASSED [ 37%]
tests/discovery_runtime/test_extension_results.py::test_diagnostic_link_work_has_an_independent_operation_ceiling[100-0-True] PASSED [ 38%]
tests/discovery_runtime/test_extension_results.py::test_diagnostic_link_work_has_an_independent_operation_ceiling[0-100-True] PASSED [ 39%]
tests/discovery_runtime/test_extension_results.py::test_diagnostic_link_work_has_an_independent_operation_ceiling[100-63-True] PASSED [ 40%]
tests/discovery_runtime/test_extension_results.py::test_diagnostic_link_work_has_an_independent_operation_ceiling[100-64-True] PASSED [ 40%]
tests/discovery_runtime/test_extension_results.py::test_diagnostic_link_work_has_an_independent_operation_ceiling[100-65-False] PASSED [ 41%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_merge_reconstructs_complete_core_and_external_rows PASSED [ 42%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_empty_selection_retains_exact_builtin_output PASSED [ 43%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_incomplete_external_diagnostics_remain_blocking_data[False-False] PASSED [ 44%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_incomplete_external_diagnostics_remain_blocking_data[False-True] FAILED [ 44%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_incomplete_external_diagnostics_remain_blocking_data[True-False] PASSED [ 45%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_incomplete_external_diagnostics_remain_blocking_data[True-True] PASSED [ 46%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_invalid_diagnostic_ownership_cannot_weaken_core[analyzer_id-repository-IDENTITY] PASSED [ 47%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_invalid_diagnostic_ownership_cannot_weaken_core[path-other/source.cs-SOURCE] PASSED [ 48%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_invalid_diagnostic_ownership_cannot_weaken_core[blocking-False-ACCOUNTING] PASSED [ 48%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_core_pin_failure_is_preserved_without_falsely_validating_documentation PASSED [ 49%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_core_component_collision_fails_without_overwriting PASSED [ 50%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_merge_does_not_trust_public_validation_carriers PASSED [ 51%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_untyped_snapshot_is_rejected_before_analysis[None] PASSED [ 52%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_untyped_snapshot_is_rejected_before_analysis[True] PASSED [ 52%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_untyped_snapshot_is_rejected_before_analysis[snapshot] PASSED [ 53%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_load_blockers_precede_valid_extension_claims PASSED [ 54%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_carriers_are_immutable_descriptions_with_checked_field_types[manifest_sha256-x] PASSED [ 55%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_carriers_are_immutable_descriptions_with_checked_field_types[input_manifest_sha256-GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG] PASSED [ 56%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_carriers_are_immutable_descriptions_with_checked_field_types[adapter-None] PASSED [ 56%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_carriers_are_immutable_descriptions_with_checked_field_types[result_files-value3] PASSED [ 57%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_carriers_are_immutable_descriptions_with_checked_field_types[result_files-value4] PASSED [ 58%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_carriers_are_immutable_descriptions_with_checked_field_types[analysis-None] PASSED [ 59%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_bytes-0] PASSED [ 60%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_bytes--1] PASSED [ 60%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_bytes-True] PASSED [ 61%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_bytes-1.5] PASSED [ 62%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_bytes-1] PASSED [ 63%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_bytes-None] PASSED [ 64%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_records-0] PASSED [ 64%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_records--1] PASSED [ 65%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_records-True] PASSED [ 66%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_records-1.5] PASSED [ 67%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_records-1] PASSED [ 68%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_records-None] PASSED [ 68%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_nodes-0] PASSED [ 69%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_nodes--1] PASSED [ 70%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_nodes-True] PASSED [ 71%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_nodes-1.5] PASSED [ 72%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_nodes-1] PASSED [ 72%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_nodes-None] PASSED [ 73%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_depth-0] PASSED [ 74%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_depth--1] PASSED [ 75%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_depth-True] PASSED [ 76%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_depth-1.5] PASSED [ 76%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_depth-1] PASSED [ 77%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_resource_limits_require_positive_exact_integers[max_depth-None] PASSED [ 78%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[None] PASSED [ 79%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[True] PASSED [ 80%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[False] PASSED [ 80%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[3] PASSED [ 81%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[-42] PASSED [ 82%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[1.25] PASSED [ 83%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[\xe9\U00010348"\n\x01] PASSED [ 84%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[value7] PASSED [ 84%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_utf8_json_reservation_matches_canonical_boundary[value8] PASSED [ 85%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[record] PASSED [ 86%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[depth] PASSED [ 87%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[node] PASSED [ 88%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[invalid-record] PASSED [ 88%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[nonfinite] PASSED [ 89%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[non-json] PASSED [ 90%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_independent_traversal_record_and_numeric_limits[integer] PASSED [ 91%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_raw_member_aggregate_is_independent_of_each_document_limit PASSED [ 92%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_manifest_member_paths_use_portable_containment[../escape] PASSED [ 92%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_manifest_member_paths_use_portable_containment[CON] PASSED [ 93%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_manifest_member_paths_use_portable_containment[C:/outside] PASSED [ 94%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_manifest_member_paths_use_portable_containment[docs/migration/discovery/inventory-other/member.json] PASSED [ 95%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_reused_member_paths_and_result_ids_are_rejected PASSED [ 96%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_merge_metadata_errors_remain_fixed_and_nonpublishing PASSED [ 96%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_capture_index_count_is_bounded_before_projection FAILED [ 97%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_unreadable_accounting_requires_a_blocking_diagnostic PASSED [ 98%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_metadata_budget_precedes_builtin_emission[timestamp] PASSED [ 99%]
tests/discovery_runtime/test_extension_inventory_merge.py::test_metadata_budget_precedes_builtin_emission[author] PASSED [100%]

================================== FAILURES ===================================
____ test_incomplete_external_diagnostics_remain_blocking_data[False-True] ____
tests\discovery_runtime\test_extension_inventory_merge.py:144: in test_incomplete_external_diagnostics_remain_blocking_data
    checked = validate_extension_results(changed)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:214: in validate_extension_results
    return _validated(ExtensionValidation(snapshot), manifest_paths)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:198: in _validated
    return tuple(_manifest(context, path) for path in sorted(selected))
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:198: in <genexpr>
    return tuple(_manifest(context, path) for path in sorted(selected))
                 ^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:131: in _manifest
    file, document = context.read(path, "extension-result-manifest")
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:290: in read
    raise ExtensionResultError("EXTENSION_SCHEMA")
E   drm_copilot_discovery.extension_validation.ExtensionResultError: EXTENSION_SCHEMA: extension data does not satisfy the captured contract
____________ test_capture_index_count_is_bounded_before_projection ____________
tests\discovery_runtime\test_extension_inventory_merge.py:434: in test_capture_index_count_is_bounded_before_projection
    profile = replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
E   TypeError: ProfileV2.__init__() got an unexpected keyword argument 'document'
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py        122      0     46      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py     197      1     92      1    99%   218
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            319      1    138      1    99%
Coverage JSON written to file SCRATCH\p4t9-core-focused10-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_extension_inventory_merge.py::test_incomplete_external_diagnostics_remain_blocking_data[False-True]
FAILED tests/discovery_runtime/test_extension_inventory_merge.py::test_capture_index_count_is_bounded_before_projection
================== 2 failed, 123 passed in 129.38s (0:02:09) ==================
```
