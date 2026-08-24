# Acceptance Traceability (P5-T7)

Timestamp: 2026-07-18T14-40

## spec.md `## Acceptance Criteria` mapping

1. Contract documented with all required and optional fields, domain-neutral names.
   - Evidence: `spec.md` `## Domain-Profile Field Contract` (required fields
     `profile_version`, `legacy_source.root`, `target.root`, `technology_stack.legacy`,
     `artifacts.root`; optional fields with defaults). Enforced neutral by
     `test_production_modules_are_domain_neutral`.
2. Dataclass-based typed loader parses a valid profile into a frozen `DomainProfile`.
   - Test: `test_parse_full_profile_populates_every_field`,
     `test_parse_minimal_profile_applies_every_default`.
3. Raises `DomainProfileError` for each missing required field with dotted path.
   - Test (parametrized): `missing_profile_version`, `missing_legacy_source`,
     `missing_legacy_source_root`, `missing_target_root`,
     `missing_technology_stack_legacy`, `missing_artifacts_root` in
     `test_parse_invalid_profile_raises`.
4. Raises on malformed input: YAML syntax (source label), non-mapping documents, type
   mismatches, empty required strings/lists, unsupported `profile_version`, unknown keys.
   - Test: `test_parse_malformed_yaml_syntax_reports_source_label`,
     `non_mapping_document`, `non_mapping_section`, `include_string_where_list`,
     `root_list_where_string`, `profile_version_string`, `empty_string_root`,
     `empty_legacy_list`, `unsupported_profile_version`, `unknown_top_level_key`,
     `unknown_key_legacy_source/target/technology_stack/artifacts`.
5. A single invalid profile with multiple defects produces one enumerated error.
   - Test: `test_parse_collects_multiple_defects_in_single_error`.
6. Parser-technology decision recorded and justified (PyYAML via `yaml.safe_load`).
   - Evidence: `spec.md` `## Specification Decision: PyYAML vs Hand-Rolled Frontmatter
     Regex`.
7. `dev.discovery.profile` console script exists as one `[tool.poetry.scripts]` line
   targeting `scripts.dev_tools.discovery.profile_cli:main`.
   - Evidence: `pyproject.toml` line
     `"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"`.
8. CLI loads/displays a resolved profile (exit 0), supports `--json`, exits 1 with the full
   error on stderr for missing/unreadable/invalid.
   - Test: `test_main_prints_resolved_text_and_exits_zero`,
     `test_main_minimal_profile_shows_applied_defaults`,
     `test_main_json_output_round_trips_and_exits_zero`,
     `test_main_missing_file_exits_one_with_stderr_message`,
     `test_main_malformed_profile_reports_all_errors_on_stderr`.
9. Loader and CLI production modules contain no domain-specific identifiers, verified by a
   contract test.
   - Test: `test_production_modules_are_domain_neutral` (scans `domain_profile.py`,
     `domain_profile_models.py`, `profile_cli.py`).
10. Tests satisfy quality-tier policy: pytest, line >= 85%, branch >= 75%, no temp files,
    mirrored test tree.
   - Evidence: `evidence/qa-gates/final-pytest-coverage.md`,
     `evidence/qa-gates/coverage-delta.md`; tests under
     `tests/scripts/dev_tools/discovery/` use `mem_fs_path` and inline YAML (no temp files).

## user-story.md scenarios mapping

- Scenario A (author a profile and view the resolved result, including `--json`):
  - Test: `test_main_prints_resolved_text_and_exits_zero`,
    `test_main_minimal_profile_shows_applied_defaults` (applied defaults visible),
    `test_main_json_output_round_trips_and_exits_zero`,
    `test_main_default_filename_resolution` (no-argument default filename).
- Scenario B (actionable error on malformed/incomplete profile; all defects in one pass;
  YAML syntax source label; missing-file path named):
  - Test: `test_main_malformed_profile_reports_all_errors_on_stderr`,
    `test_parse_collects_multiple_defects_in_single_error`,
    `test_parse_malformed_yaml_syntax_reports_source_label`,
    `test_main_missing_file_exits_one_with_stderr_message`,
    `test_load_domain_profile_missing_file_names_path`.

## File line counts (all added; every file < 500)

- `scripts/dev_tools/discovery/__init__.py`: 37
- `scripts/dev_tools/discovery/domain_profile.py`: 408
- `scripts/dev_tools/discovery/domain_profile_models.py`: 152
- `scripts/dev_tools/discovery/profile_cli.py`: 154
- `tests/scripts/dev_tools/discovery/__init__.py`: 0
- `tests/scripts/dev_tools/discovery/test_domain_profile.py`: 452
- `tests/scripts/dev_tools/discovery/test_profile_cli.py`: 180

Modified (not counted against the 500-line file limit for this feature's new code):
- `pyproject.toml`: one added `[tool.poetry.scripts]` line.

## Verdict

Every spec.md acceptance criterion and both user-story scenarios map to a passing test or
documented CLI behavior/spec evidence. All added files are under the 500-line limit.
