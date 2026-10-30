# P4-T4 final tests-reverse

Timestamp: 2026-10-19T06-41
Command: `poetry run python -m pytest -v -o addopts= tests/discovery_runtime/analyzer/test_configuration_input.py tests/discovery_runtime/analyzer/test_configuration.py --cov=drm_copilot_discovery.analyzer.configuration --cov=drm_copilot_discovery.analyzer.configuration_input --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/p4t4-final-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 5 of 7; exact source bindings, timestamps and raw output hashes are in the adjacent JSON.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 91 items

tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-["VALUE_SENTINEL"]-configuration-json-root] PASSED [  1%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-{"K":"VALUE_SENTINEL",}-configuration-json-invalid] PASSED [  2%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-{"K":1,"\u004b":"VALUE_SENTINEL"}-configuration-json-invalid] PASSED [  3%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-{"K":NaN}-configuration-json-invalid] PASSED [  4%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-{"K":Infinity}-configuration-json-invalid] PASSED [  5%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-{"K":"\xffVALUE_SENTINEL"}-configuration-json-invalid] PASSED [  6%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[json-{"K":"\ud800VALUE_SENTINEL"}-configuration-json-invalid] PASSED [  7%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[xml-<VALUE_SENTINEL/>-configuration-xml-root] PASSED [  8%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[xml-<settings><setting name="K">VALUE_SENTINEL</bad>-configuration-xml-invalid] PASSED [  9%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[xml-<!DOCTYPE settings [<!ENTITY x "VALUE_SENTINEL">]><settings/>-configuration-xml-invalid] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[xml-<settings xmlns:x="http://www.w3.org/2001/XInclude"><x:include href="VALUE_SENTINEL"/></settings>-configuration-xml-invalid] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[xml-<settings><setting value="VALUE_SENTINEL"/></settings>-configuration-xml-key] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[ini-K=VALUE_SENTINEL-configuration-ini-section-required] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[ini-[S]\nK=VALUE_SENTINEL\nK=second-configuration-ini-invalid] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[ini-[S]\nK=VALUE_SENTINEL\n[S]\nB=x-configuration-ini-invalid] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[ini-[S]\nVALUE_SENTINEL-configuration-ini-invalid] PASSED [ 17%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[ini-[S]\nK=\xffVALUE_SENTINEL-configuration-encoding] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_failures_never_expose_source_through_error_surfaces[ini-[S]\nK=\x00VALUE_SENTINEL-configuration-encoding] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_defaults_continuations_and_case_have_physical_anchors[\n] PASSED [ 20%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_defaults_continuations_and_case_have_physical_anchors[\r\n] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_defaults_continuations_and_case_have_physical_anchors[\r] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_budgets_reject_partial_output[json-{"A":1,"B":2}-1-64] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_budgets_reject_partial_output[json-{"A":{"B":1}}-100-1] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_budgets_reject_partial_output[xml-<settings><setting name="A"/></settings>-1-64] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_budgets_reject_partial_output[xml-<settings><setting name="A"/></settings>-100-1] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_budgets_reject_partial_output[ini-[S]\nA=1-1-64] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_parser_budgets_reject_partial_output[ini-[DEFAULT]\nA=1\n[S]-3-64] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_byte_budget_and_invalid_caller_limits_fail_explicitly PASSED [ 30%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_repeated_long_json_prefixes_fail_within_a_finite_text_budget[64] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_repeated_long_json_prefixes_fail_within_a_finite_text_budget[128] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_repeated_long_json_prefixes_fail_within_a_finite_text_budget[256] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_pointer_expansion_is_charged_before_construction[plain] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_pointer_expansion_is_charged_before_construction[\u03a9/~] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_pointer_expansion_is_charged_before_construction[Control\n\t"\\] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_pointer_expansion_is_charged_before_construction[\U0001f680/~] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_inherited_ini_paths_cannot_exceed_accumulated_text_reservations PASSED [ 39%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_internal_spaces_use_only_the_fixed_linear_matcher[False-1024] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_internal_spaces_use_only_the_fixed_linear_matcher[False-2048] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_internal_spaces_use_only_the_fixed_linear_matcher[False-4096] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_internal_spaces_use_only_the_fixed_linear_matcher[True-1024] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_internal_spaces_use_only_the_fixed_linear_matcher[True-2048] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_ini_internal_spaces_use_only_the_fixed_linear_matcher[True-4096] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_many_ini_lines_have_linear_aggregate_match_input[=] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_many_ini_lines_have_linear_aggregate_match_input[:] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_invalid_encoded_text_budgets_fail_as_caller_errors[0] PASSED [ 49%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_invalid_encoded_text_budgets_fail_as_caller_errors[-1] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_invalid_encoded_text_budgets_fail_as_caller_errors[True] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_configuration_input.py::test_invalid_encoded_text_budgets_fail_as_caller_errors[67108865] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_configuration.py::test_fixtures_project_only_identifiers_with_valid_provenance[config.json-keys0] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_configuration.py::test_fixtures_project_only_identifiers_with_valid_provenance[application.config-keys1] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_configuration.py::test_fixtures_project_only_identifiers_with_valid_provenance[settings.settings-keys2] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_configuration.py::test_fixtures_project_only_identifiers_with_valid_provenance[settings.ini-keys3] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[APPSETTINGS.JSON-{"K":1}] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[appsettings.a.json-{"K":1}] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[settings.json-{"K":1}] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[config.json-{"K":1}] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[a.CONFIG-<configuration><appSettings><add key="K"/></appSettings></configuration>] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[a.settings-<SettingsFile><Settings><Setting Name="K"/></Settings></SettingsFile>] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[settings.xml-<settings><setting name="K"/></settings>] PASSED [ 64%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[configuration.xml-<configuration><appSettings><add key="K"/></appSettings></configuration>] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_configuration.py::test_finite_supported_filename_families[a.INI-[S]\nK=VALUE_SENTINEL] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[data.json] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[source.cs] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[appsettings..json] PASSED [ 70%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[other.xml] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[source.py] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[config.yaml] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_configuration.py::test_unrelated_files_are_ignored_without_payload_diagnostics[settings] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_configuration.py::test_json_uses_exact_pointer_segments_without_inventing_lines PASSED [ 75%]
tests/discovery_runtime/analyzer/test_configuration.py::test_malformed_and_unsupported_selected_inputs_fail_closed[config.json-{"K":"VALUE_SENTINEL",}] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_configuration.py::test_malformed_and_unsupported_selected_inputs_fail_closed[settings.xml-<settings><setting name="K" value="VALUE_SENTINEL"/></bad>] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_configuration.py::test_malformed_and_unsupported_selected_inputs_fail_closed[settings.ini-[S]\nVALUE_SENTINEL] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_configuration.py::test_malformed_and_unsupported_selected_inputs_fail_closed[settings.toml-K="VALUE_SENTINEL"] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_configuration.py::test_repeated_default_headers_keep_distinct_declaration_ids PASSED [ 81%]
tests/discovery_runtime/analyzer/test_configuration.py::test_value_and_condition_changes_do_not_define_semantic_ids[config.json-{"K":"VALUE_SENTINEL_1"}-{"K":["VALUE_SENTINEL_2"]}] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_configuration.py::test_value_and_condition_changes_do_not_define_semantic_ids[settings.xml-<settings condition="VALUE_SENTINEL_1"><setting name="K">one</setting></settings>-<settings condition="VALUE_SENTINEL_2">\n<setting name="K">two</setting></settings>] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_configuration.py::test_value_and_condition_changes_do_not_define_semantic_ids[settings.ini-[S]\nK=VALUE_SENTINEL_1-[S]\n\nK=VALUE_SENTINEL_2] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_configuration.py::test_excluded_and_unreadable_inputs_do_not_leak_read_rationales PASSED [ 85%]
tests/discovery_runtime/analyzer/test_configuration.py::test_missing_immutable_provenance_is_low_confidence_and_blocking PASSED [ 86%]
tests/discovery_runtime/analyzer/test_configuration.py::test_aggregate_output_limit_drops_partial_claims[1-payloads0] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_configuration.py::test_aggregate_output_limit_drops_partial_claims[2-payloads1] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_configuration.py::test_text_overflow_rejects_before_projecting_an_excess_batch[base] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_configuration.py::test_text_overflow_rejects_before_projecting_an_excess_batch[findings] PASSED [ 91%]
tests/discovery_runtime/analyzer/test_configuration.py::test_text_overflow_rejects_before_projecting_an_excess_batch[parser] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_configuration.py::test_text_overflow_rejects_before_projecting_an_excess_batch[astral] PASSED [ 93%]
tests/discovery_runtime/analyzer/test_configuration.py::test_complete_serialized_projection_fits_the_documented_byte_bound[False-\u03a9/~] PASSED [ 94%]
tests/discovery_runtime/analyzer/test_configuration.py::test_complete_serialized_projection_fits_the_documented_byte_bound[False-Control\n\t"\\] PASSED [ 95%]
tests/discovery_runtime/analyzer/test_configuration.py::test_complete_serialized_projection_fits_the_documented_byte_bound[False-\U0001f680/~] PASSED [ 96%]
tests/discovery_runtime/analyzer/test_configuration.py::test_complete_serialized_projection_fits_the_documented_byte_bound[True-\u03a9/~] PASSED [ 97%]
tests/discovery_runtime/analyzer/test_configuration.py::test_complete_serialized_projection_fits_the_documented_byte_bound[True-Control\n\t"\\] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_configuration.py::test_complete_serialized_projection_fits_the_documented_byte_bound[True-\U0001f680/~] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                   Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py            89      0     32      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration_input.py     204      3     90      6    97%   199->222, 208->210, 216->222, 324, 382, 386
----------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                    293      3    122      6    98%
Coverage JSON written to file SCRATCH/p4t4-final-coverage.raw.json
============================= 91 passed in 54.38s =============================

```
