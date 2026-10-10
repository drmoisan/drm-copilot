# Baseline: quality-tiers contract test names ([P0-T10])

Timestamp: 2026-10-09T20-58
Command: grep -n -E "^def test_" tests/scripts/dev_tools/test_quality_tiers_contract.py
EXIT_CODE: 0
Output Summary: 28 lines printed, at lines 48, 68, 82, 95, 114, 163, 174, 192, 206, 215, 224, 233, 253, 262, 271, 287, 299, 312, 350, 363, 373, 396, 406, 419, 434, 446, 460, 480 (matches the plan's expected line set exactly). Line 434 is the only definition without a `-> None` annotation (#734 CR-1).

## Verbatim output

```
48:def test_parse_quality_tiers_accepts_valid_manifest() -> None:
68:def test_parse_quality_tiers_accepts_root_path_entry() -> None:
82:def test_parse_quality_tiers_rejects_invalid_yaml_with_qt002() -> None:
95:def test_parse_quality_tiers_rejects_duplicate_top_level_key_with_qt002() -> None:
114:def test_parse_quality_tiers_rejects_non_mapping_root_with_qt002() -> None:
163:def test_parse_quality_tiers_rejects_schema_violation_with_qt003(text: str) -> None:
174:def test_parse_quality_tiers_keeps_valid_entries_alongside_qt003() -> None:
192:def test_quality_tier_error_renders_code_prefix() -> None:
206:def test_discover_projects_root_package_json_yields_root() -> None:
215:def test_discover_projects_csproj_directory_is_project() -> None:
224:def test_discover_projects_psd1_with_sibling_psm1_is_project() -> None:
233:def test_discover_projects_ignores_settings_psd1_without_sibling_psm1() -> None:
253:def test_discover_projects_ignores_excluded_roots(tracked_path: str) -> None:
262:def test_discover_projects_ignores_scripts_child_without_direct_code_file() -> None:
271:def test_discover_projects_discovers_nested_poshqc_and_scripts_powershell() -> None:
287:def test_discover_projects_discovers_claude_lib_child() -> None:
299:def test_discover_projects_discovers_hook_roots_only_with_tracked_file(
312:def test_discover_projects_empty_list_yields_empty_set() -> None:
350:def test_find_classification_errors_valid_manifest_returns_no_errors() -> None:
363:def test_find_entry_errors_reports_qt004_for_invalid_tier(tier: str) -> None:
373:def test_find_entry_errors_reports_qt005_for_duplicate_path() -> None:
396:def test_find_entry_errors_reports_qt006_for_malformed_path(path: str) -> None:
406:def test_find_classification_errors_reports_qt007_for_undiscovered_entry() -> None:
419:def test_find_classification_errors_reports_qt008_for_unclassified_project() -> None:
434:def test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry():
446:def test_find_classification_errors_accumulates_qt004_and_qt008() -> None:
460:def test_committed_quality_tiers_yml_matches_live_tree() -> None:
480:def test_committed_quality_tiers_yml_assigns_spec_tiers() -> None:
```

## Sorted function names (28)

1. test_committed_quality_tiers_yml_assigns_spec_tiers
2. test_committed_quality_tiers_yml_matches_live_tree
3. test_discover_projects_csproj_directory_is_project
4. test_discover_projects_discovers_claude_lib_child
5. test_discover_projects_discovers_hook_roots_only_with_tracked_file
6. test_discover_projects_discovers_nested_poshqc_and_scripts_powershell
7. test_discover_projects_empty_list_yields_empty_set
8. test_discover_projects_ignores_excluded_roots
9. test_discover_projects_ignores_scripts_child_without_direct_code_file
10. test_discover_projects_ignores_settings_psd1_without_sibling_psm1
11. test_discover_projects_psd1_with_sibling_psm1_is_project
12. test_discover_projects_root_package_json_yields_root
13. test_find_classification_errors_accumulates_qt004_and_qt008
14. test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry
15. test_find_classification_errors_reports_qt007_for_undiscovered_entry
16. test_find_classification_errors_reports_qt008_for_unclassified_project
17. test_find_classification_errors_valid_manifest_returns_no_errors
18. test_find_entry_errors_reports_qt004_for_invalid_tier
19. test_find_entry_errors_reports_qt005_for_duplicate_path
20. test_find_entry_errors_reports_qt006_for_malformed_path
21. test_parse_quality_tiers_accepts_root_path_entry
22. test_parse_quality_tiers_accepts_valid_manifest
23. test_parse_quality_tiers_keeps_valid_entries_alongside_qt003
24. test_parse_quality_tiers_rejects_duplicate_top_level_key_with_qt002
25. test_parse_quality_tiers_rejects_invalid_yaml_with_qt002
26. test_parse_quality_tiers_rejects_non_mapping_root_with_qt002
27. test_parse_quality_tiers_rejects_schema_violation_with_qt003
28. test_quality_tier_error_renders_code_prefix
