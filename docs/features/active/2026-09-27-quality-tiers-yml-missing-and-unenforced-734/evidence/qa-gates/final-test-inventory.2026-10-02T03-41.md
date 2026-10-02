# P8-T20 Failure-Code and Discovery-Boundary Test Inventory (pass 2)

Timestamp: 2026-10-02T03-41
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py --collect-only -q
EXIT_CODE: 0
Output Summary: `61 tests collected`. Every code QT001 through QT009 has at least one node ID, and every P1-T2 discovery test is collected. File prefixes: C = tests/scripts/dev_tools/test_check_quality_tiers.py, Q = tests/scripts/dev_tools/test_quality_tiers_contract.py.

Per code:

- qt001: C::test_main_returns_one_with_qt001_when_manifest_missing
- qt002: C::test_main_returns_one_with_qt002_and_skips_git_for_invalid_yaml; Q::test_parse_quality_tiers_rejects_invalid_yaml_with_qt002; Q::test_parse_quality_tiers_rejects_duplicate_top_level_key_with_qt002; Q::test_parse_quality_tiers_rejects_non_mapping_root_with_qt002
- qt003: Q::test_parse_quality_tiers_rejects_schema_violation_with_qt003 (10 ids: missing-version, version-not-one, projects-empty, projects-not-list, entry-not-mapping, missing-key, unknown-key, non-string-value, empty-value, unknown-top-level-key); Q::test_parse_quality_tiers_keeps_valid_entries_alongside_qt003
- qt004: Q::test_find_entry_errors_reports_qt004_for_invalid_tier (T5, t3); Q::test_find_classification_errors_accumulates_qt004_and_qt008; C::test_main_reports_qt004_and_qt008_in_one_run
- qt005: Q::test_find_entry_errors_reports_qt005_for_duplicate_path
- qt006: Q::test_find_entry_errors_reports_qt006_for_malformed_path (absolute, drive-letter, backslash, trailing-slash, dotdot-segment, leading-dot-segment)
- qt007: Q::test_find_classification_errors_reports_qt007_for_undiscovered_entry; Q::test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry
- qt008: Q::test_find_classification_errors_reports_qt008_for_unclassified_project; Q::test_find_classification_errors_accumulates_qt004_and_qt008; C::test_main_returns_one_with_qt008_when_entry_removed; C::test_main_reports_qt004_and_qt008_in_one_run
- qt009: C::test_main_returns_one_with_qt009_when_runner_raises_oserror; C::test_main_returns_one_with_qt009_when_git_exits_nonzero; C::test_main_returns_one_with_qt009_when_git_not_found; C::test_main_reports_entry_errors_alongside_qt009

Discovery boundaries (all ten P1-T2 tests collected):

- Q::test_discover_projects_root_package_json_yields_root
- Q::test_discover_projects_csproj_directory_is_project
- Q::test_discover_projects_psd1_with_sibling_psm1_is_project
- Q::test_discover_projects_ignores_settings_psd1_without_sibling_psm1
- Q::test_discover_projects_ignores_excluded_roots (resources package.json, tests/fixtures csproj, docs package.json, node_modules package.json)
- Q::test_discover_projects_ignores_scripts_child_without_direct_code_file
- Q::test_discover_projects_discovers_nested_poshqc_and_scripts_powershell
- Q::test_discover_projects_discovers_claude_lib_child
- Q::test_discover_projects_discovers_hook_roots_only_with_tracked_file (.claude/hooks, .codex/hooks)
- Q::test_discover_projects_empty_list_yields_empty_set
