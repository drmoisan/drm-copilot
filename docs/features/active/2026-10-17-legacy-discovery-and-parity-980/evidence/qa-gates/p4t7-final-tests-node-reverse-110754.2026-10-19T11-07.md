# P4-T7 final tests-node-reverse

Timestamp: 2026-10-19T11-07
Command: `poetry run python -m pytest -v -o addopts= tests/discovery_runtime/analyzer/test_dependency_node_limits.py tests/discovery_runtime/analyzer/test_dependency_node.py --cov=drm_copilot_discovery.analyzer.dependency_node --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t7-final-node-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 5 of 7; exact source bindings, elapsed time and separate raw stream hashes are in the adjacent JSON.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 111 items

tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_public_contract_misuse_has_fixed_errors[format-yarn] PASSED [  0%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_public_contract_misuse_has_fixed_errors[format-invalid1] PASSED [  1%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_public_contract_misuse_has_fixed_errors[content-VALUE_SENTINEL] PASSED [  2%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_public_contract_misuse_has_fixed_errors[content-invalid3] PASSED [  3%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_public_contract_misuse_has_fixed_errors[limits-None] PASSED [  4%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_input_limits_precede_json_parser_allocation[max_bytes-1-{}] PASSED [  5%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_input_limits_precede_json_parser_allocation[max_nodes-63-{}] PASSED [  6%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_input_limits_precede_json_parser_allocation[max_lines-1-{\r\n"x":1\r}] PASSED [  7%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_aggregate_allocation_and_normalization_bounds_discard_complete_result[value0-limits0] PASSED [  8%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_aggregate_allocation_and_normalization_bounds_discard_complete_result[value1-limits1] PASSED [  9%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_aggregate_allocation_and_normalization_bounds_discard_complete_result[value2-limits2] PASSED [  9%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_aggregate_allocation_and_normalization_bounds_discard_complete_result[value3-limits3] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_aggregate_allocation_and_normalization_bounds_discard_complete_result[value4-limits4] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_lock_extraction_reserves_linear_work_across_records[1] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_lock_extraction_reserves_linear_work_across_records[5] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_lock_extraction_reserves_linear_work_across_records[20] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_unicode_and_escaped_identifiers_remain_redacted_and_budgeted[\xe9VALUE_SENTINEL] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_unicode_and_escaped_identifiers_remain_redacted_and_budgeted[\U0001f600VALUE_SENTINEL] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_unicode_and_escaped_identifiers_remain_redacted_and_budgeted[bad/"VALUE_SENTINEL] PASSED [ 17%]
tests/discovery_runtime/analyzer/test_dependency_node_limits.py::test_unicode_and_escaped_identifiers_remain_redacted_and_budgeted[~VALUE_SENTINEL] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-simple-name-dependencies] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-simple-name-devDependencies] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-simple-name-optionalDependencies] PASSED [ 20%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-simple-name-peerDependencies] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-@scope/name-dependencies] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-@scope/name-devDependencies] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-@scope/name-optionalDependencies] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[1.2.3-literal-@scope/name-peerDependencies] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-simple-name-dependencies] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-simple-name-devDependencies] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-simple-name-optionalDependencies] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-simple-name-peerDependencies] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-@scope/name-dependencies] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-@scope/name-devDependencies] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-@scope/name-optionalDependencies] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[^1.0 || ~2.0-constraint-@scope/name-peerDependencies] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-simple-name-dependencies] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-simple-name-devDependencies] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-simple-name-optionalDependencies] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-simple-name-peerDependencies] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-@scope/name-dependencies] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-@scope/name-devDependencies] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-@scope/name-optionalDependencies] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[*-constraint-@scope/name-peerDependencies] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-simple-name-dependencies] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-simple-name-devDependencies] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-simple-name-optionalDependencies] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-simple-name-peerDependencies] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-@scope/name-dependencies] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-@scope/name-devDependencies] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-@scope/name-optionalDependencies] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[-missing-@scope/name-peerDependencies] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-simple-name-dependencies] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-simple-name-devDependencies] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-simple-name-optionalDependencies] PASSED [ 49%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-simple-name-peerDependencies] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-@scope/name-dependencies] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-@scope/name-devDependencies] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-@scope/name-optionalDependencies] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_manifest_groups_preserve_declared_values_without_resolution[next-tag-@scope/name-peerDependencies] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_records_root_maps_and_edges_have_distinct_meanings[2] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_records_root_maps_and_edges_have_distinct_meanings[3] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_order_and_repeated_groups_are_deterministic_without_precedence PASSED [ 56%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[https://user:VALUE_SENTINEL@host/x-url] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[git+https://VALUE_SENTINEL-vcs] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[file:../VALUE_SENTINEL-local] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[workspace:VALUE_SENTINEL-workspace] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[npm:VALUE_SENTINEL@1-alias] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[${VALUE_SENTINEL}-dynamic] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_specifiers_are_classifications_without_target_text[VALUE_SENTINEL-unsupported] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[https://VALUE_SENTINEL/a] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[../VALUE_SENTINEL] PASSED [ 64%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[node_modules/] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[node_modules/@scope] PASSED [ 66%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[node_modules/Bad] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[node_modules/a/other/b] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsafe_locations_never_enter_anchors_or_identities[node_modules/a//node_modules/b] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_explicit_names_do_not_resolve_conflicting_location_identity[same-same-None] PASSED [ 70%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_explicit_names_do_not_resolve_conflicting_location_identity[other-None-dependency-ambiguous] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_explicit_names_do_not_resolve_conflicting_location_identity[https://VALUE_SENTINEL-None-dependency-redacted] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_metadata_only_links_and_explicit_names_remain_unevaluated PASSED [ 72%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsupported_controls_are_diagnosed_without_evaluation[workspaces] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsupported_controls_are_diagnosed_without_evaluation[overrides] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsupported_controls_are_diagnosed_without_evaluation[resolutions] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsupported_controls_are_diagnosed_without_evaluation[bundledDependencies] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_unsupported_controls_are_diagnosed_without_evaluation[bundleDependencies] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[None] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[value1] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[value2] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[value3] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[value4] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[value5] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_malformed_manifest_shape_never_returns_partial_candidates[value6] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value0-dependency-unsupported] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value1-dependency-unsupported] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value2-dependency-unsupported] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value3-dependency-malformed] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value4-dependency-malformed] PASSED [ 88%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value5-dependency-malformed] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value6-dependency-malformed] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value7-dependency-malformed] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value8-dependency-malformed] PASSED [ 91%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value9-dependency-malformed] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_lock_versions_and_selected_shapes_fail_closed[value10-dependency-malformed] PASSED [ 93%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_parser_errors_withhold_messages_keys_and_selected_secret_text[{"dependencies":{"x":"1","x":"VALUE_SENTINEL"}}-dependency-malformed] PASSED [ 94%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_parser_errors_withhold_messages_keys_and_selected_secret_text[{"VALUE_SENTINEL":NaN}-dependency-malformed] PASSED [ 95%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_parser_errors_withhold_messages_keys_and_selected_secret_text[{"VALUE_SENTINEL":Infinity}-dependency-malformed] PASSED [ 96%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_parser_errors_withhold_messages_keys_and_selected_secret_text[{"dependencies":-dependency-malformed] PASSED [ 97%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_parser_errors_withhold_messages_keys_and_selected_secret_text[\xffVALUE_SENTINEL-dependency-encoding] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_parser_errors_withhold_messages_keys_and_selected_secret_text[{"dependencies":{"x":"\ud800VALUE_SENTINEL"}}-dependency-encoding] PASSED [ 99%]
tests/discovery_runtime/analyzer/test_dependency_node.py::test_bom_empty_inputs_and_unicode_separator_are_honest_json PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                               Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_node.py     103      0     52      0   100%
------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                103      0     52      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t7-final-node-coverage.raw.json
============================= 111 passed in 0.35s =============================

```
