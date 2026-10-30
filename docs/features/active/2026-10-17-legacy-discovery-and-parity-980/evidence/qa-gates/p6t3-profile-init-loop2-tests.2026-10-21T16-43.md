# P6-T3 profile/init tests

Timestamp: 2026-10-21T16-42

Command: `WORKSPACE\.venv\Scripts\python.exe -m coverage run --branch --source=scripts.dev_tools.discovery.profile_cli,scripts.dev_tools.discovery.init_cli -m pytest -v --durations=10 --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/scripts/dev_tools/discovery/test_profile_cli.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_domain_profile.py`

EXIT_CODE: 0

Output Summary: PASS; 15.030 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 86 items

tests/scripts/dev_tools/discovery/test_profile_cli.py::test_parse_args_defaults_to_documented_filename PASSED [  1%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_parse_args_accepts_explicit_path_and_json_flag PASSED [  2%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_render_text_preserves_resolved_v1_values PASSED [  3%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_render_json_preserves_resolved_v1_structure PASSED [  4%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_render_minimal_profile_preserves_applied_defaults PASSED [  5%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_v1_reader_preserves_invalid_profile_diagnostics PASSED [  6%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_main_forwards_profile_selection_and_typed_exit[0] PASSED [  8%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_main_forwards_profile_selection_and_typed_exit[1] PASSED [  9%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_main_forwards_profile_selection_and_typed_exit[2] PASSED [ 10%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_main_forwards_profile_selection_and_typed_exit[3] PASSED [ 11%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_main_retains_installed_argument_selection[process] PASSED [ 12%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_main_retains_installed_argument_selection[explicit-empty] PASSED [ 13%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[missing-positional] PASSED [ 15%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[invalid-positional] PASSED [ 16%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[json] PASSED [ 17%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[mixed] PASSED [ 18%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[template] PASSED [ 19%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[force] PASSED [ 20%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_help_uses_installed_profile_options_without_providers PASSED [ 22%]
tests/scripts/dev_tools/discovery/test_profile_cli.py::test_module_entry_returns_installed_exit PASSED [ 23%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_requires_target_dir PASSED [ 24%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_defaults_template_root_and_force PASSED [ 25%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_parses_template_root_and_force PASSED [ 26%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_forwards_explicit_context_and_typed_exit[0] PASSED [ 27%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_forwards_explicit_context_and_typed_exit[1] PASSED [ 29%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_forwards_explicit_context_and_typed_exit[2] PASSED [ 30%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_forwards_explicit_context_and_typed_exit[3] PASSED [ 31%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_retains_installed_argument_selection[process] PASSED [ 32%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_retains_installed_argument_selection[explicit-empty] PASSED [ 33%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[positional] PASSED [ 34%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[template] PASSED [ 36%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[force] PASSED [ 37%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[canonical-template] PASSED [ 38%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[canonical-force] PASSED [ 39%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[identity] PASSED [ 40%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_help_uses_installed_options_without_providers PASSED [ 41%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_module_entry_returns_installed_exit PASSED [ 43%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_console_script_registered_in_pyproject PASSED [ 44%]
tests/scripts/dev_tools/discovery/test_init_cli.py::test_legacy_cli_reports_explicit_v2_migration_without_writes PASSED [ 45%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_default_profile_filename_constant PASSED [ 46%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_domain_profile_error_is_value_error PASSED [ 47%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_full_profile_populates_every_field PASSED [ 48%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_minimal_profile_applies_every_default PASSED [ 50%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_records_source_label_in_error PASSED [ 51%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[missing_profile_version] PASSED [ 52%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[missing_legacy_source] PASSED [ 53%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[missing_legacy_source_root] PASSED [ 54%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[missing_target_root] PASSED [ 55%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[missing_technology_stack_legacy] PASSED [ 56%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[missing_artifacts_root] PASSED [ 58%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[include_string_where_list] PASSED [ 59%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[root_list_where_string] PASSED [ 60%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[profile_version_string] PASSED [ 61%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[non_mapping_section] PASSED [ 62%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[empty_string_root] PASSED [ 63%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[empty_legacy_list] PASSED [ 65%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[unsupported_profile_version] PASSED [ 66%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[unknown_top_level_key] PASSED [ 67%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[unknown_key_legacy_source] PASSED [ 68%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[unknown_key_target] PASSED [ 69%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[unknown_key_technology_stack] PASSED [ 70%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[unknown_key_artifacts] PASSED [ 72%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[convention_non_string_value] PASSED [ 73%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[non_mapping_document] PASSED [ 74%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[optional_field_wrong_type] PASSED [ 75%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[list_element_wrong_type] PASSED [ 76%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[non_string_section_key] PASSED [ 77%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[convention_non_string_key] PASSED [ 79%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[non_string_top_level_key] PASSED [ 80%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[convention_empty_key] PASSED [ 81%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_invalid_profile_raises[conventions_non_mapping] PASSED [ 82%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_malformed_yaml_syntax_reports_source_label PASSED [ 83%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_empty_document_raises PASSED [ 84%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_parse_collects_multiple_defects_in_single_error PASSED [ 86%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_construct_legacy_source_empty_root_raises PASSED [ 87%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_construct_target_empty_root_raises PASSED [ 88%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_construct_technology_stack_empty_legacy_raises PASSED [ 89%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_construct_artifacts_empty_root_raises PASSED [ 90%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_construct_artifacts_empty_convention_key_raises PASSED [ 91%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_construct_domain_profile_wrong_version_raises PASSED [ 93%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_load_domain_profile_happy_path PASSED [ 94%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_load_domain_profile_missing_file_names_path PASSED [ 95%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_load_domain_profile_unreadable_path_raises PASSED [ 96%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_production_modules_are_domain_neutral[domain_profile] PASSED [ 97%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_production_modules_are_domain_neutral[domain_profile_models] PASSED [ 98%]
tests/scripts/dev_tools/discovery/test_domain_profile.py::test_production_modules_are_domain_neutral[profile_cli] PASSED [100%]

============================ slowest 10 durations =============================
1.14s call     tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[mixed]
1.11s call     tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[force]
1.11s call     tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[force]
1.05s call     tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[template]
1.05s call     tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[template]
1.02s setup    tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_requires_target_dir
0.91s call     tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[canonical-template]
0.91s call     tests/scripts/dev_tools/discovery/test_init_cli.py::test_legacy_cli_reports_explicit_v2_migration_without_writes
0.90s call     tests/scripts/dev_tools/discovery/test_init_cli.py::test_ambiguous_init_inputs_refuse_before_effects[positional]
0.90s call     tests/scripts/dev_tools/discovery/test_profile_cli.py::test_legacy_profile_inputs_refuse_before_effects[json]
============================= 86 passed in 14.38s =============================

```
