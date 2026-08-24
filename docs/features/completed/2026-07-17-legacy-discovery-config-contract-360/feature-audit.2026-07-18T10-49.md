# Feature Audit — legacy-discovery-config-contract (#360)

- Timestamp: 2026-07-18T10-49
- Branch: `feature/legacy-discovery-config-contract-360` (HEAD `a5209a71`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Work mode: `full-feature` (marker confirmed in `issue.md`: `- Work Mode: full-feature`)
- AC sources: `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria` (Scenarios A and B)

Test evidence below was independently verified by re-running the discovery test suite:
`poetry run pytest tests/scripts/dev_tools/discovery/ --cov=scripts/dev_tools/discovery --cov-branch` — 55 passed, exit 0.

## spec.md Acceptance Criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | Contract documented with all required fields (`profile_version`, `legacy_source.root`, `target.root`, `technology_stack.legacy`, `artifacts.root`) and optional fields with defaults, domain-neutral names | PASS | `spec.md` `## Domain-Profile Field Contract` documents the full field set with defaults; field names are domain-neutral; neutrality enforced by `test_production_modules_are_domain_neutral`. |
| 2 | Dataclass-based typed loader parses a valid profile into a frozen `DomainProfile` | PASS | `test_parse_full_profile_populates_every_field`, `test_parse_minimal_profile_applies_every_default`; five `frozen=True` dataclasses in `domain_profile_models.py`. |
| 3 | `DomainProfileError` for each missing required field, naming the dotted path | PASS | Parametrized cases `missing_profile_version`, `missing_legacy_source`, `missing_legacy_source_root`, `missing_target_root`, `missing_technology_stack_legacy`, `missing_artifacts_root` in `test_parse_invalid_profile_raises` — each asserts the dotted-path fragment. |
| 4 | `DomainProfileError` on malformed input: YAML syntax (source label), non-mapping documents, type mismatches, empty required strings/lists, unsupported `profile_version`, unknown keys | PASS | `test_parse_malformed_yaml_syntax_reports_source_label`; parametrized cases `non_mapping_document`, `non_mapping_section`, `include_string_where_list`, `root_list_where_string`, `profile_version_string`, `empty_string_root`, `empty_legacy_list`, `unsupported_profile_version`, `unknown_top_level_key`, `unknown_key_legacy_source`/`_target`/`_technology_stack`/`_artifacts`, plus non-string-key and convention-defect cases. |
| 5 | One invalid profile with multiple defects produces one `DomainProfileError` enumerating every defect | PASS | `test_parse_collects_multiple_defects_in_single_error` (three defects across three sections asserted in a single message). |
| 6 | Parser-technology decision recorded and justified (PyYAML via `yaml.safe_load`, citing the declared-unused dependency, both regex precedents' structural inability, `safe_load` safety) | PASS | `spec.md` `## Specification Decision: PyYAML vs Hand-Rolled Frontmatter Regex` cites all three justification points and rejected alternatives. Implementation uses `yaml.safe_load` only (`domain_profile.py:103`). |
| 7 | `dev.discovery.profile` console script exists as one `[tool.poetry.scripts]` line | PASS | Branch diff shows exactly one added line in `pyproject.toml`: `"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"`. |
| 8 | CLI loads/displays a resolved profile (exit 0), supports `--json`, exits 1 with full error on stderr for missing/unreadable/invalid profile | PASS | `test_main_prints_resolved_text_and_exits_zero`, `test_main_minimal_profile_shows_applied_defaults`, `test_main_json_output_round_trips_and_exits_zero`, `test_main_missing_file_exits_one_with_stderr_message`, `test_main_malformed_profile_reports_all_errors_on_stderr`; unreadable path covered at loader level by `test_load_domain_profile_unreadable_path_raises`. |
| 9 | No domain-specific identifiers in loader/CLI production modules, verified by contract test | PASS | `test_production_modules_are_domain_neutral` scans all three production modules for the six banned substrings; independently re-verified by reviewer grep (`taskmaster|tmw|outlook|vsto|email|task-management`, case-insensitive) — zero matches in `scripts/dev_tools/discovery/`. |
| 10 | Tests satisfy quality-tier policy: pytest, line >= 85%, branch >= 75%, no temp files, mirrored test tree | PASS | Reviewer re-run: package coverage — `domain_profile.py` 99.5% line / 98.7% branch; `domain_profile_models.py` 100%/100%; `profile_cli.py` 100%/100%; `__init__.py` 100%. Tests use inline YAML strings and the in-memory `mem_fs_path` fixture (`tests/conftest.py:146`); no `tmp_path` usage. Test tree `tests/scripts/dev_tools/discovery/` mirrors `scripts/dev_tools/discovery/`. |

spec.md AC: 10/10 PASS. All ten items were already checked `[x]` in `spec.md`; no check-off edits required.

## user-story.md Acceptance Criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Contract documented with all required and optional fields | PASS | Same as spec AC #1. |
| 2 | Dataclass-based typed loader parses a valid profile into a typed object | PASS | Same as spec AC #2. |
| 3 | Loader fails fast with specific errors on malformed input and missing required fields | PASS | Same as spec AC #3–#5. |
| 4 | Parser-technology decision made and justified in spec.md | PASS | Same as spec AC #6. |
| 5 | `dev.discovery.*` CLI entry point loads and displays a resolved profile | PASS | Same as spec AC #7–#8. |
| 6 | Core loader contains no domain-specific identifiers | PASS | Same as spec AC #9. |
| 7 | Tests satisfy quality-tier policy (pytest, line >= 85%, branch >= 75%) | PASS | Same as spec AC #10. |

user-story.md AC: 7/7 PASS. All seven items were already checked `[x]`; no check-off edits required.

## user-story.md Scenario Verification

### Scenario A — author a profile and view the resolved result

- Default-filename invocation: `test_main_default_filename_resolution` proves `main([])` resolves `discovery-profile.yaml` via `DEFAULT_PROFILE_FILENAME`. PASS.
- Resolved aligned `key: value` text with applied defaults, exit 0: `test_main_prints_resolved_text_and_exits_zero`, `test_main_minimal_profile_shows_applied_defaults` (defaults rendered as `(none)`). PASS.
- `--json` machine-readable rendering round-trips: `test_main_json_output_round_trips_and_exits_zero` (`json.loads` on stdout). PASS.

Scenario A verdict: PASS.

### Scenario B — actionable error on a malformed or incomplete profile

- All defects collected in one pass, single `DomainProfileError`, dotted paths: `test_parse_collects_multiple_defects_in_single_error`. PASS.
- Full multi-error message on stderr, exit 1: `test_main_malformed_profile_reports_all_errors_on_stderr` (asserts three dotted-path fragments on stderr). PASS.
- YAML syntax error includes source label and mark: `test_parse_malformed_yaml_syntax_reports_source_label`; the wrapped `yaml.YAMLError` message includes PyYAML's line/column mark. PASS.
- Missing or unreadable file names the path: `test_load_domain_profile_missing_file_names_path`, `test_main_missing_file_exits_one_with_stderr_message`, `test_load_domain_profile_unreadable_path_raises`. PASS.

Scenario B verdict: PASS.

## Out-of-Scope Confirmation

Per `spec.md` `### Out of scope` and the epic feature split, the following are owned by sibling features and were correctly NOT delivered here (their absence is not a gap): JSON schema files (#9002), `validate_*_text` standalone validators with subparser CLI (#9003), artifact-kind vocabulary validation (#9002/#9005), path existence/reachability checks (#9003/#9006). The branch diff contains none of these, and the loader stores `artifacts.conventions` keys without vocabulary validation, as specified.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/user-story.md`
- Total AC items: 17 (10 spec + 7 user-story)
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none

## Findings Summary

- FAIL: 0. PARTIAL: 0. UNVERIFIED: 0. All 17 acceptance criteria PASS with independently re-run test evidence.
