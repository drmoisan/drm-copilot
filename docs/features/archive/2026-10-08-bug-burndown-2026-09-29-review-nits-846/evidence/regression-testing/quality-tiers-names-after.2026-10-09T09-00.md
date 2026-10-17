# Regression: quality-tiers test names after CR-1 and CR-2 ([P2-T4])

Timestamp: 2026-10-09T21-12
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --collect-only -q
EXIT_CODE: 0
Output Summary: 51 tests collected in 0.19s. Baseline-Collected 47 + 4 = 51 (three new QT003 schema params and one new QT002 test). PASS.

```
51 tests collected in 0.19s
```

## Block 2

Command: grep -h -E "^def test_" tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py
EXIT_CODE: 0
Output Summary: 29 definition lines printed (19 in the contract module, 10 in the classification module).

```
def test_parse_quality_tiers_accepts_valid_manifest() -> None:
def test_parse_quality_tiers_accepts_root_path_entry() -> None:
def test_parse_quality_tiers_rejects_invalid_yaml_with_qt002() -> None:
def test_parse_quality_tiers_rejects_duplicate_top_level_key_with_qt002() -> None:
def test_parse_quality_tiers_rejects_non_mapping_root_with_qt002() -> None:
def test_parse_quality_tiers_non_scalar_key_reports_qt002() -> None:
def test_parse_quality_tiers_rejects_schema_violation_with_qt003(text: str) -> None:
def test_parse_quality_tiers_keeps_valid_entries_alongside_qt003() -> None:
def test_quality_tier_error_renders_code_prefix() -> None:
def test_discover_projects_root_package_json_yields_root() -> None:
def test_discover_projects_csproj_directory_is_project() -> None:
def test_discover_projects_psd1_with_sibling_psm1_is_project() -> None:
def test_discover_projects_ignores_settings_psd1_without_sibling_psm1() -> None:
def test_discover_projects_ignores_excluded_roots(tracked_path: str) -> None:
def test_discover_projects_ignores_scripts_child_without_direct_code_file() -> None:
def test_discover_projects_discovers_nested_poshqc_and_scripts_powershell() -> None:
def test_discover_projects_discovers_claude_lib_child() -> None:
def test_discover_projects_discovers_hook_roots_only_with_tracked_file(
def test_discover_projects_empty_list_yields_empty_set() -> None:
def test_find_classification_errors_valid_manifest_returns_no_errors() -> None:
def test_find_entry_errors_reports_qt004_for_invalid_tier(tier: str) -> None:
def test_find_entry_errors_reports_qt005_for_duplicate_path() -> None:
def test_find_entry_errors_reports_qt006_for_malformed_path(path: str) -> None:
def test_find_classification_errors_reports_qt007_for_undiscovered_entry() -> None:
def test_find_classification_errors_reports_qt008_for_unclassified_project() -> None:
def test_find_classification_errors_empty_projects_reports_qt007() -> None:
def test_find_classification_errors_accumulates_qt004_and_qt008() -> None:
def test_committed_quality_tiers_yml_matches_live_tree() -> None:
def test_committed_quality_tiers_yml_assigns_spec_tiers() -> None:
```

## Name-by-name comparison against the [P0-T10] sorted list (28 names)

Each of the 28 baseline names was compared with the 29 names above.

- Present in both (27): every baseline name except item 14.
- Removed (1): `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry`
- Added (2): `test_find_classification_errors_empty_projects_reports_qt007`, `test_parse_quality_tiers_non_scalar_key_reports_qt002`

Arithmetic: 28 - 1 + 2 = 29. Collected 51 = 47 + 4.

Acceptance (AC-2): collected count equals Baseline-Collected + 4; 29 names; exactly one removed and exactly two added. PASS.
