# docs-profile-and-artifact-schemas - Plan

- **Issue:** #1020
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 900001, wave 0, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T16-08
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature (AC sources: `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`)
- **Research:** `research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md`

## Required References

- Policy order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md` (and the `.github/instructions/` sources they mirror).
- Contracts: `spec.md` (normative shapes, symbols, exit codes) and the epic `docs/features/epics/documentation-estate-tooling/epic.md` `## Shared Design` (`### Naming contract (fixed for all children)`), which this plan restates and does not change.
- Environment: tool routes, launchers, command-text restrictions, batch budget, and CI shape are owned by the `execution-environment` skill and are not restated here.

## Execution Context

- Execution happens later, launched by `epic-orchestrator`, in this item worktree (branch `feature/docs-profile-and-artifact-schemas-1020`), where the orchestration checkpoint selects a batch-budget-exempt route (`execution-environment` `## Batch Budget`). The feature creates more than three non-test Python production files (`__init__.py`, seven `drm_copilot_docs` modules, `scripts/dev_tools/build_docs_runtime.py`), so it cannot run in direct mode or in an isolated subagent worktree.
- `SCRATCH` is `<session scratchpad>/issue-1020/`; every scratch file, coverage report, and helper lives under it with names starting `issue-1020-`. Evidence records the literal token `SCRATCH`, never a host path.
- `FEATURE` is `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`. Evidence files are named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match.
- `MERGE_BASE` is the output of `git merge-base origin/main HEAD`; every scope diff is anchored on it.
- Discovery runtime files are read-only for this feature: nothing under `packages/discovery-runtime/` or `schemas/discovery/`, and neither `scripts/dev_tools/build_discovery_runtime.py` nor `scripts/dev_tools/discovery_build_identity.py`, is edited.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md`, then `spec.md`, `user-story.md`, and the research file.
  - Acceptance: `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:`, and the list of files read.
- [ ] [P0-T2] Capture the formatting baseline with `poetry run black --check .` (check mode, no rewrite).
  - Acceptance: `FEATURE/evidence/baseline/baseline-black.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the `would be left unchanged` count or the files reported.
- [ ] [P0-T3] Capture the lint baseline with `poetry run ruff check .` (no `--fix`).
  - Acceptance: `FEATURE/evidence/baseline/baseline-ruff.<timestamp>.md` records the four fields; `Output Summary:` states `All checks passed!` or the finding count.
- [ ] [P0-T4] Capture the type-check baseline with `poetry run pyright`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pyright.<timestamp>.md` records the four fields and the error, warning, and information counts from the summary line.
- [ ] [P0-T5] Capture the test and coverage baseline in CI shape with `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1020-coverage-baseline.json --cov` (bare `--cov` last, so it measures the configured `[tool.coverage.run] source`).
  - Acceptance: `FEATURE/evidence/baseline/baseline-pytest-coverage.<timestamp>.md` records the four fields, the passed/failed counts, and numeric `totals.percent_statements_covered` and `totals.percent_branches_covered` read from the JSON report; it states that `drm_copilot_docs` and `scripts.dev_tools.build_docs_runtime` do not exist at baseline (new-code baseline: not present).
- [ ] [P0-T6] Capture the repository-gate baselines: `poetry run python -m scripts.dev_tools.check_quality_tiers` and `poetry check --lock`, one artifact per command.
  - Acceptance: `FEATURE/evidence/baseline/baseline-quality-tiers.<timestamp>.md` and `FEATURE/evidence/baseline/baseline-poetry-lock.<timestamp>.md` each record the four fields.

### Phase 1 — Canonical Docs v1 Schemas and Examples

- [ ] [P1-T1] Create `schemas/docs/v1/common.schema.json` (`$id` `urn:drm-copilot:docs:1.0.0:common`, definitions only, no artifact header) with every `$defs` entry in spec `### Docs \`common\` \`$defs\``: `element-kind`, `element-id`, `element-ids`, `disposition`, `parity-dimension`, `parity-state`, `diataxis-mode`, `front-matter-field`, `review-date`, `docs-artifact-kind`, `artifact-pin`, `page-binding`, `actor`, `finding`, `diagnostic`.
  - Behavior: kebab-case `$defs`, closed objects, cross-family `$ref` only to `urn:drm-copilot:discovery:2.0.0:common#/$defs/...`, no nested `$id`, no `format` other than `date-time`; `finding` key set equals `Finding.to_dict` in `drm_copilot_discovery.findings`.
  - Acceptance: verified by `tests/schemas/docs/test_docs_schemas_v1.py` in [P1-T5].
- [ ] [P1-T2] Create `schemas/docs/v1/docs-profile.schema.json` and `schemas/docs/v1/surface-inventory-snapshot.schema.json` per spec `### Artifact schema: \`docs-profile\`` and `### Artifact schema: \`surface-inventory-snapshot\``, plus `examples/docs/v1/docs-profile.example.json` and `examples/docs/v1/surface-inventory-snapshot.example.json`.
  - Behavior: artifact header (`$schema` const = `$id`, `schema_version` const `"1.0.0"`, `artifact_kind` const, `id`, `extensions`); profile `surface_selection.analyzers` optional; snapshot `$defs/element` with the `cli-option` parent rule. The example profile omits `surface_selection.analyzers` so it passes semantic checks with the empty registry; examples use POSIX relative paths, neutral identifiers, and computed `element-id` values.
  - Acceptance: verified in [P1-T5].
- [ ] [P1-T3] Create `schemas/docs/v1/docs-coverage-ledger.schema.json` and `schemas/docs/v1/docs-parity-matrix.schema.json` per the spec sections of the same names, plus `examples/docs/v1/docs-coverage-ledger.example.json` and `examples/docs/v1/docs-parity-matrix.example.json`.
  - Behavior: ledger disposition companion rules as an `allOf` of `if`/`then` (table in spec `### Artifact schema: \`docs-coverage-ledger\``); matrix `dimensions` closed with exactly the five parity keys; `fail` and `not-applicable` require `rationale` text. The ledger example has one entry per disposition.
  - Acceptance: verified in [P1-T5].
- [ ] [P1-T4] Create `schemas/docs/v1/docs-evidence-pin.schema.json` (collection form) and `schemas/docs/v1/docs-validation-receipt.schema.json`, plus `examples/docs/v1/docs-evidence-pin.example.json` and `examples/docs/v1/docs-validation-receipt.example.json`.
  - Behavior: receipt `counts.by_disposition` and `counts.by_kind` closed with exactly the three dispositions and six kinds; `validation_result` binding (`pass` forbids an `error` finding, `fail` requires one); `writer.tool` const `"drm-copilot-docs"`.
  - Acceptance: verified in [P1-T5].
- [ ] [P1-T5] Create `tests/schemas/docs/test_docs_schemas_v1.py` (no `__init__.py`; offline `referencing.Registry` built from the committed docs schemas plus `schemas/discovery/v2/common.schema.json`, mutations on deep copies, no fixture files) with tests `test_docs_schema_is_valid_draft_2020_12`, `test_docs_schema_id_matches_file_stem`, `test_artifact_schema_root_is_closed`, `test_example_validates_against_its_schema`, `test_missing_required_field_is_rejected`, `test_unknown_element_kind_or_disposition_is_rejected`, `test_ledger_disposition_companions_are_enforced`, `test_parity_fail_requires_rationale`, `test_snapshot_cli_option_requires_command_parent`, `test_receipt_result_binds_error_findings`, and `test_docs_schemas_close_offline_with_discovery_common` (calls `scripts.dev_tools.build_discovery_runtime.verify_schema_closure`).
  - Behavior: the example, missing-field, and unknown-kind-or-disposition tests are parametrized over the six artifact names (spec "Rejection coverage"); the `excluded`-without-rationale ledger case is rejected.
  - Acceptance: `poetry run pytest tests/schemas/docs -q` exits 0 with 0 failed; `FEATURE/evidence/regression-testing/phase1-docs-schemas.<timestamp>.md` records the four fields and the passed count.

### Phase 2 — Package Scaffold and Repository Registration

- [ ] [P2-T1] Create `packages/docs-runtime/pyproject.toml` (fields in spec `## Implementation Strategy`, including the two console scripts and `drm-copilot-discovery = ">=2.0.0,<3.0.0"`), `packages/docs-runtime/README.md` (staged resources, builder commands, the two-wheel `python -I -m pip install` line), `packages/docs-runtime/src/drm_copilot_docs/__init__.py` (`__version__ = "1.0.0"`), and `packages/docs-runtime/src/drm_copilot_docs/py.typed`.
  - Acceptance: the package `pyproject.toml` parses with `tomllib`; its assertions are proven by `test_package_pyproject_matches_runtime_contract` in [P5-T5].
- [ ] [P2-T2] Append to root `pyproject.toml`: `drm-copilot-docs = { path = "packages/docs-runtime", develop = true }` under `[tool.poetry.dependencies]`; `"dev.docs.init" = "drm_copilot_docs.cli:main_init"` and `"dev.docs.validate-profile" = "drm_copilot_docs.cli:main_validate_profile"` under `[tool.poetry.scripts]`; `"packages/docs-runtime/src"` in `[tool.coverage.run] source` and in `[tool.pyright] include`.
  - Existing tests: `tests/discovery_runtime/test_package_contract.py::test_root_tooling_includes_the_local_runtime_for_types_and_coverage` unchanged (its `startswith`/`split` assertions tolerate appended entries); `tests/scripts/dev_tools/test_build_discovery_runtime.py::test_project_metadata_matches_runtime_contract` and `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_cli_reference_lists_every_console_script` unchanged (they read only `packages/discovery-runtime/pyproject.toml`).
  - Acceptance: proven by the root-registration tests in [P5-T5]; `poetry run pytest tests/discovery_runtime/test_package_contract.py -q` exits 0.
- [ ] [P2-T3] Regenerate `poetry.lock` with `poetry lock`, commit `pyproject.toml` and `poetry.lock`, then run `poetry check --lock`, `poetry install`, and `git diff --exit-code HEAD -- poetry.lock`.
  - Behavior: the lock records `drm-copilot-docs` as a `directory` source (`packages/docs-runtime`, `develop = true`) beside the discovery entry; the docs range dependency on `drm-copilot-discovery` resolves to the root directory dependency.
  - Acceptance: all three commands exit 0; `FEATURE/evidence/other/poetry-lock-regeneration.<timestamp>.md` records each command with the four fields.
- [ ] [P2-T4] Add `packages/docs-runtime` with `tier: T2` and a neutral rationale to `quality-tiers.yml`, and update `test_committed_quality_tiers_yml_assigns_spec_tiers` in `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`.
  - Existing test disposition: updated, because it asserts the elevated T1/T2 list equals only `packages/discovery-runtime`; the expected list becomes `packages/discovery-runtime` and `packages/docs-runtime`, an `assigned["packages/docs-runtime"] == "T2"` assertion is added, and the docstring names both packages. `SPEC_TIER_ASSIGNMENTS` and its count are unchanged.
  - Acceptance: `poetry run python -m scripts.dev_tools.check_quality_tiers` exits 0 and `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract_classification.py -q` exits 0.

### Phase 3 — Distribution, Resources, and Schema Validation

- [ ] [P3-T1] Create `packages/docs-runtime/resource-manifest.json` (allowlist of the seven `schemas/docs/v1/*.schema.json` files), `scripts/dev_tools/build_docs_runtime.py`, and `tests/scripts/dev_tools/test_build_docs_runtime.py`.
  - Behavior: `main(argv, *, ...)` with injected filesystem, runner, `stdout`, `stderr`; `--check` compares staged copies and the staged `manifest.json` (sorted `{path, sha256, size}`, `runtime_version` = `drm_copilot_docs.__version__`) with canonical bytes and writes nothing; `--stage-only` stages; default builds `dist/docs/drm_copilot_docs-1.0.0-py3-none-any.whl` with `pip wheel --no-index --no-deps --no-build-isolation`. Staging enumerates only allowlisted files; it reuses `verify_schema_closure` and `drm_copilot_discovery.resources.validate_resource_path` unchanged. No `_build_manifest.json`.
  - Tests (in-memory filesystem following `MemoryFileSystem` in `tests/scripts/dev_tools/test_build_discovery_runtime.py`): `test_check_returns_zero_when_staged_copies_match`, `test_check_names_missing_staged_copy_on_stderr`, `test_check_names_differing_staged_copy_on_stderr`, `test_check_writes_no_file`, `test_stage_only_writes_copies_and_sorted_manifest`, `test_unlisted_schema_file_is_not_staged`, `test_allowlist_rejects_path_outside_docs_v1`, `test_build_wheel_invokes_offline_pip_wheel`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_build_docs_runtime.py -q` exits 0 with 0 failed.
- [ ] [P3-T2] Stage the installed copies with `poetry run python -m scripts.dev_tools.build_docs_runtime --stage-only` (one generator run), producing `packages/docs-runtime/src/drm_copilot_docs/_resources/schemas/docs/v1/*.schema.json` and `packages/docs-runtime/src/drm_copilot_docs/_resources/manifest.json`; then run `poetry run python -m scripts.dev_tools.build_docs_runtime --check`.
  - Acceptance: before the staged files are committed, `git status --porcelain --untracked-files=all -- packages/docs-runtime/src/drm_copilot_docs/_resources` lists the seven staged schemas and `manifest.json`; the `--check` run exits 0. `FEATURE/evidence/other/stage-docs-resources.<timestamp>.md` records both commands with the four fields.
- [ ] [P3-T3] Create `packages/docs-runtime/src/drm_copilot_docs/resources.py` (`RESOURCE_DIRECTORY`, `MANIFEST_FILENAME`, `ResourceError`, `read_resource(path, *, read_bytes=...)`) and `tests/docs_runtime/__init__.py` plus `tests/docs_runtime/test_docs_resources.py`.
  - Behavior: the manifest is read through the same seam; a read validates the path spelling, requires a manifest entry, and verifies size and SHA-256 and `runtime_version` before returning bytes.
  - Tests: `test_read_resource_returns_verified_bytes`, `test_read_resource_rejects_size_mismatch`, `test_read_resource_rejects_sha256_mismatch`, `test_read_resource_rejects_unlisted_path`, `test_read_resource_rejects_invalid_path_spelling`, `test_read_resource_rejects_runtime_version_mismatch`, `test_default_reader_reads_staged_resource`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_resources.py -q` exits 0 with 0 failed.
- [ ] [P3-T4] Create `packages/docs-runtime/src/drm_copilot_docs/schema_validation.py` (`DOCS_SCHEMA_NAMES`, `docs_schema_id`, `build_registry`, `validate_artifact`) and `tests/docs_runtime/test_docs_schema_validation.py`.
  - Behavior: offline registry whose `retrieve` raises `referencing.exceptions.NoSuchResource`; `check_schema` per schema; eager `$ref` resolution; cache keyed by resource content; `Draft202012Validator` with `discovery_format_checker()`; findings with code `SCHEMA_INVALID` and pointers from `error.absolute_path`; with `resources=None` reads installed docs copies and the discovery `common` through `drm_copilot_discovery.resources.read_resource`.
  - Tests: `test_docs_schema_id_for_each_name` (enumerated property), `test_build_registry_resolves_discovery_common_offline`, `test_build_registry_denies_remote_retrieval`, `test_build_registry_rejects_invalid_schema`, `test_registry_cache_is_keyed_by_content`, `test_validate_artifact_accepts_each_example`, `test_validate_artifact_reports_schema_invalid_with_pointer`, `test_validate_artifact_rejects_unknown_artifact_kind`, `test_validate_artifact_is_invariant_under_key_order` (permutation property), `test_validate_artifact_default_resources_reads_installed_copies`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_schema_validation.py -q` exits 0 with 0 failed.

### Phase 4 — Surface Element Model and Analyzer Contract

- [ ] [P4-T1] Create `packages/docs-runtime/src/drm_copilot_docs/surface_models.py` (`ElementKind`, `ELEMENT_KINDS`, `element_identifier`, `SurfaceElement`, `SurfaceDiagnostic`, `element_to_json`, `diagnostic_to_json`) and `tests/docs_runtime/test_surface_models.py`.
  - Behavior: `element_identifier` returns `stable_id(kind, row(kind=..., path=..., declaration=...))` from `drm_copilot_discovery.analyzer.findings`; `ValueError` naming the argument for an unknown kind, a path failing `validate_finding_path`, or a blank, padded, or control-character declaration; `SurfaceElement.__post_init__` enforces the recomputed `element_id`, the `cli-option` parent rule, and `1 <= start <= end`; `SurfaceDiagnostic.id` follows the `stable_id("diagnostic", ...)` rule of `drm_copilot_discovery.analyzer.findings.diagnostic`.
  - Tests: `test_element_identifier_is_deterministic_over_enumerated_inputs` and `test_element_identifier_is_injective_over_enumerated_inputs` (`itertools.product` over all six kinds, paths with separators and non-ASCII characters, declarations), `test_boundary_concatenations_do_not_collide`, `test_element_identifier_matches_element_id_pattern`, `test_element_identifier_rejects_invalid_arguments`, `test_surface_element_rejects_mismatched_element_id`, `test_cli_option_requires_cli_command_parent`, `test_line_range_bounds_are_enforced`, `test_element_to_json_validates_as_snapshot_element`, `test_diagnostic_to_json_round_trips_over_enumerated_inputs`, `test_diagnostic_id_follows_discovery_rule`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_surface_models.py -q` exits 0 with 0 failed.
- [ ] [P4-T2] Create `packages/docs-runtime/src/drm_copilot_docs/analyzer_contract.py` (`SurfaceAnalyzer` Protocol, `SurfaceAnalysis`, `AnalyzerRegistration`, `ANALYZER_REGISTRY = ()` with the append-one-entry-per-line source comment, `validate_registry`, `registered_identifiers`, `select_registrations`, `load_analyzer`) and `tests/docs_runtime/test_analyzer_contract.py`.
  - Behavior: per spec `### Analyzer contract (\`analyzer_contract.py\`)`; `load_analyzer` refuses a module outside `drm_copilot_docs.analyzers.` before calling the injected `import_module`; `select_registrations` validates the whole request before any import and is order-invariant.
  - Tests: `test_validate_registry_reports_duplicate_identifier`, `test_validate_registry_reports_module_outside_prefix`, `test_validate_registry_reports_identifier_outside_grammar`, `test_validate_registry_reports_empty_or_unknown_kinds`, `test_committed_registry_yields_no_findings`, `test_load_analyzer_refuses_module_outside_prefix_without_import` (recording fake asserts zero calls), `test_load_analyzer_rejects_mismatched_identifier_or_kinds`, `test_load_analyzer_returns_matching_analyzer`, `test_select_registrations_rejects_unknown_identifier_before_import`, `test_select_registrations_is_invariant_under_permutation`, `test_registered_identifiers_is_sorted_under_permutation`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_analyzer_contract.py -q` exits 0 with 0 failed.

### Phase 5 — Profile Loader, CLI, and Contract Tests

- [ ] [P5-T1] Create `packages/docs-runtime/src/drm_copilot_docs/profile_models.py` (the eleven frozen `kw_only` dataclasses named in spec `### Profile models and \`profile.py\` API`), `packages/docs-runtime/src/drm_copilot_docs/profile.py` (`parse_profile`, `ProfileLoadResult`, `starter_profile`, `render_profile_json`), and `tests/docs_runtime/test_profile.py`.
  - Behavior: parse through `parse_document`; validate through `validate_artifact` (`docs-profile`); semantic checks (unique audience and root identifiers, audience references resolve, directory modes within `diataxis_policy.modes`, analyzers registered, pointer `/surface_selection/analyzers/<n>`); dataclasses built only when no `error` finding; findings ordered through `FindingCollector`.
  - Tests: `test_example_profile_parses_ok`, `test_missing_audiences_reports_root_pointer_and_field`, `test_duplicate_audience_identifier_is_error`, `test_duplicate_documentation_root_identifier_is_error`, `test_unknown_audience_reference_is_error`, `test_directory_mode_outside_policy_is_error`, `test_unknown_analyzer_identifier_points_at_analyzer_index`, `test_empty_file_is_reported`, `test_invalid_json_is_reported`, `test_duplicate_keys_are_reported`, `test_yaml_profile_is_accepted`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_profile.py -q` exits 0 with 0 failed.
- [ ] [P5-T2] Create `tests/docs_runtime/test_profile_properties.py` with exhaustive enumerations (no `random`, no `hypothesis`): `test_starter_profile_is_valid_for_enumerated_repository_ids`, `test_render_profile_json_round_trips`, `test_render_profile_json_is_invariant_under_key_order`, `test_parse_profile_is_invariant_under_mapping_order`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_profile_properties.py -q` exits 0 with 0 failed.
- [ ] [P5-T3] Create `packages/docs-runtime/src/drm_copilot_docs/cli.py` (`main_init`, `main_validate_profile`, `run_cli(command, argv, *, ports, stdout, stderr)`) and `tests/docs_runtime/test_cli.py`.
  - Behavior: `argparse` with `SystemExit` caught; exit codes 0/1/2/3 per spec `### CLI`; `--output` writes through one exclusive-create port and refuses an existing file without `--force`; default `--profile` `docs/documentation-estate/docs-profile.json`; findings print pointer, field name, and message; a top-level handler writes a fixed stderr line and returns 3.
  - Tests (`io.StringIO` streams, in-memory ports): `test_init_prints_starter_profile_that_validates`, `test_init_output_writes_through_exclusive_create_port`, `test_init_output_refuses_existing_file_without_force`, `test_init_force_replaces_existing_file`, `test_init_rejects_invalid_repository_id`, `test_init_rejects_non_relative_output`, `test_init_self_validation_failure_exits_one`, `test_validate_profile_example_exits_zero`, `test_validate_profile_missing_audiences_exits_one_and_names_field`, `test_validate_profile_json_format`, `test_validate_profile_unknown_flag_exits_two`, `test_validate_profile_unreadable_file_exits_three`, `test_unexpected_exception_writes_fixed_line_and_exits_three`, `test_main_wrappers_delegate_to_run_cli`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_cli.py -q` exits 0 with 0 failed.
- [ ] [P5-T4] Create `tests/docs_runtime/test_neutrality.py` with the module-level tuple of the two configured digests stated in spec `## Implementation Strategy` (and no plaintext identifier), the pure helper `find_identifier_occurrences`, the read-only scan `test_docs_runtime_file_contains_no_configured_identifier` parametrized over every file under `packages/docs-runtime/src/` and `schemas/docs/` except files inside `__pycache__` directories (compiled bytecode written by earlier imports in the same session), the positive control `test_find_identifier_occurrences_detects_injected_token`, and `test_find_identifier_occurrences_ignores_unconfigured_tokens`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_neutrality.py -q` exits 0 with 0 failed and the positive control passes.
- [ ] [P5-T5] Create `tests/docs_runtime/test_docs_package_contract.py` with `test_staged_resource_bytes_equal_canonical_schema` and `test_staged_manifest_records_sha256_and_size` (both parametrized over `packages/docs-runtime/resource-manifest.json`), `test_root_pyproject_registers_docs_path_dependency`, `test_root_pyproject_registers_docs_console_scripts`, `test_root_tooling_includes_docs_runtime_for_coverage_and_pyright`, and `test_package_pyproject_matches_runtime_contract`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_package_contract.py -q` exits 0 with 0 failed.
- [ ] [P5-T6] Run the installed console scripts: `poetry run dev.docs.validate-profile --profile examples/docs/v1/docs-profile.example.json` and `poetry run dev.docs.init`.
  - Acceptance: both exit 0; `FEATURE/evidence/regression-testing/cli-smoke.<timestamp>.md` records each command with the four fields.

### Phase 6 — Final QA Loop and Self-Review

- [ ] [P6-T1] Run `poetry run black .` then `poetry run black --check .`.
  - Acceptance: the check prints `would be left unchanged` and no `would reformat` line and exits 0; if the write run printed `reformatted`, restart from [P6-T1]. `FEATURE/evidence/qa-gates/qa-black.<timestamp>.md` records the four fields.
- [ ] [P6-T2] Run `poetry run ruff check .` (no `--fix`).
  - Acceptance: prints `All checks passed!` and exits 0; on any finding, fix it and restart from [P6-T1]. `FEATURE/evidence/qa-gates/qa-ruff.<timestamp>.md` records the four fields.
- [ ] [P6-T3] Run `poetry run pyright`.
  - Acceptance: the summary reports `0 errors` and exits 0; otherwise fix and restart from [P6-T1]. `FEATURE/evidence/qa-gates/qa-pyright.<timestamp>.md` records the four fields.
- [ ] [P6-T4] Run the full suite in CI shape: `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1020-coverage-final.json --cov`, then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-1020-coverage-final.json --min-line 85 --min-branch 75`.
  - Acceptance: both exit 0 with 0 failed tests; `FEATURE/evidence/qa-gates/qa-pytest-coverage.<timestamp>.md` records the four fields, the passed count, and numeric `totals.percent_statements_covered` and `totals.percent_branches_covered`.
- [ ] [P6-T5] Measure new-code coverage with `poetry run pytest tests/docs_runtime tests/schemas/docs tests/scripts/dev_tools/test_build_docs_runtime.py --cov=drm_copilot_docs --cov=scripts.dev_tools.build_docs_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1020-coverage-new.json`.
  - Acceptance: exits 0; `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` records baseline totals (from [P0-T5]), post-change totals (from [P6-T4]), and, for every `drm_copilot_docs` module and `scripts/dev_tools/build_docs_runtime.py`, line and branch percentages read from each file's `summary` in the JSON report, each at least 85 line and 75 branch, plus the `drm_copilot_docs` aggregate. Any value below its floor is remediation-required, not PASS.
- [ ] [P6-T6] Run the reversed-order isolation check in one process over the new and changed Python test modules, passed in reverse sorted path order: `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`, `tests/scripts/dev_tools/test_build_docs_runtime.py`, `tests/schemas/docs/test_docs_schemas_v1.py`, `tests/docs_runtime/test_surface_models.py`, `tests/docs_runtime/test_profile_properties.py`, `tests/docs_runtime/test_profile.py`, `tests/docs_runtime/test_neutrality.py`, `tests/docs_runtime/test_docs_schema_validation.py`, `tests/docs_runtime/test_docs_resources.py`, `tests/docs_runtime/test_docs_package_contract.py`, `tests/docs_runtime/test_cli.py`, `tests/docs_runtime/test_analyzer_contract.py`.
  - Acceptance: exits 0 with 0 failed; `FEATURE/evidence/regression-testing/isolation-reversed-order.<timestamp>.md` records the four fields and the module order. An order dependence is fixed on both sides and the run repeated.
- [ ] [P6-T7] Re-run the lock gate on the committed tree: `poetry check --lock`, `poetry install`, `git diff --exit-code HEAD -- poetry.lock`.
  - Acceptance: all three exit 0; `FEATURE/evidence/qa-gates/qa-poetry-lock.<timestamp>.md` records each command with the four fields.
- [ ] [P6-T8] Run `poetry run python -m scripts.dev_tools.check_quality_tiers`.
  - Acceptance: exits 0; `FEATURE/evidence/qa-gates/qa-quality-tiers.<timestamp>.md` records the four fields.
- [ ] [P6-T9] Run `poetry run python -m scripts.dev_tools.build_docs_runtime --check` on the feature branch.
  - Acceptance: exits 0, and `git status --porcelain --untracked-files=all -- packages/docs-runtime` prints identical output immediately before and immediately after the `--check` run (no file written; both outputs are recorded); `FEATURE/evidence/qa-gates/qa-docs-builder-check.<timestamp>.md` records the four fields.
- [ ] [P6-T10] Verify scope and file size: `git diff --name-only MERGE_BASE HEAD -- packages/discovery-runtime schemas/discovery scripts/dev_tools/build_discovery_runtime.py scripts/dev_tools/discovery_build_identity.py` and `git status --porcelain -- packages/discovery-runtime schemas/discovery scripts/dev_tools/build_discovery_runtime.py scripts/dev_tools/discovery_build_identity.py`; physical line counts (`wc -l`) of every new production file under `packages/docs-runtime/src/drm_copilot_docs/` and `scripts/dev_tools/build_docs_runtime.py`.
  - Acceptance: both git commands print nothing; every listed production file is at most 500 lines. `FEATURE/evidence/qa-gates/qa-scope-and-size.<timestamp>.md` records the commands, `MERGE_BASE` derivation, outputs, and per-file counts.
- [ ] [P6-T11] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from `MERGE_BASE` and every AC in `spec.md` and `user-story.md`.
  - Acceptance: `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL, or N/A row per checklist item and per AC; a FAIL row is fixed, the loop re-run from [P6-T1], and the self-review rewritten; the plan does not complete with a FAIL row.

## Acceptance Criteria Traceability

| AC | Tasks | Proving tests or evidence |
|---|---|---|
| Spec AC1 / Story AC1 (examples validate; rejection) | P1-T1..P1-T5 | `test_example_validates_against_its_schema`, `test_missing_required_field_is_rejected`, `test_unknown_element_kind_or_disposition_is_rejected` |
| Spec AC2 / Story AC2 (validate-profile, init) | P5-T1, P5-T3, P5-T6 | `test_validate_profile_example_exits_zero`, `test_validate_profile_missing_audiences_exits_one_and_names_field`, `test_init_prints_starter_profile_that_validates`, `cli-smoke` |
| Spec AC3 / Story AC3 (identifiers) | P4-T1 | `test_element_identifier_is_deterministic_over_enumerated_inputs`, `test_element_identifier_is_injective_over_enumerated_inputs` |
| Spec AC4 / Story AC4 (neutrality) | P5-T4 | `test_docs_runtime_file_contains_no_configured_identifier`, `test_find_identifier_occurrences_detects_injected_token` |
| Spec AC5 / Story AC5 (coverage) | P6-T5 | `coverage-delta` |
| Spec AC6 / Story AC6 (staged copies) | P3-T2, P5-T5 | `test_staged_resource_bytes_equal_canonical_schema`, `test_staged_manifest_records_sha256_and_size` |
| Spec AC7 / Story AC6 (builder `--check`) | P3-T1, P6-T9 | `test_check_returns_zero_when_staged_copies_match`, `test_check_names_differing_staged_copy_on_stderr`, `test_check_writes_no_file`, `qa-docs-builder-check` |
| Spec AC8 / Story AC7 (root registration) | P2-T2, P5-T5 | `test_root_pyproject_registers_docs_path_dependency`, `test_root_pyproject_registers_docs_console_scripts`, `test_root_tooling_includes_docs_runtime_for_coverage_and_pyright` |
| Spec AC9 / Story AC7 (lock) | P2-T3, P6-T7 | `qa-poetry-lock` |
| Spec AC10 / Story AC8 (tier) | P2-T4, P6-T8 | `test_committed_quality_tiers_yml_assigns_spec_tiers`, `qa-quality-tiers` |
| Spec AC11 / Story AC9 (discovery unchanged) | P6-T10 | `qa-scope-and-size` |
| Spec AC12 / Story AC10 (registry) | P4-T2 | `test_validate_registry_reports_duplicate_identifier`, `test_validate_registry_reports_module_outside_prefix`, `test_load_analyzer_refuses_module_outside_prefix_without_import`, `test_committed_registry_yields_no_findings` |

## Pre-Mortem

- Review checklists: a reviewer flags a production path excluded from coverage, a missing tier entry, or a schema that does not reject an unknown kind or disposition. Prevented by [P2-T2] (coverage source, no exclusion), [P2-T4] (tier entry), the parametrized rejection tests in [P1-T5], and the template walk in [P6-T11].
- Coverage: thin CLI and resource wrappers could fall below 85% line or 75% branch. Prevented by injected stream, port, reader, runner, and `import_module` seams in [P3-T1], [P3-T3], [P4-T2], [P5-T3]; dotted `--cov=drm_copilot_docs` and `--cov=scripts.dev_tools.build_docs_runtime` in [P6-T5] with per-file branch figures read from the JSON report; the repository totals gate in [P6-T4].
- Mirror parity: not applicable as a customization mirror, because no `.claude`, `.github`, `.codex`, `.agents`, or `extensions/drm-copilot/resources/` file is edited and no fact in the execution-environment brief changes (no CI job, required context, tool route, or batch-budget rule). The only duplicated files are the staged `_resources` copies, pinned by `test_staged_resource_bytes_equal_canonical_schema` ([P5-T5]) and the builder `--check` ([P3-T2], [P6-T9]).
- File size: a combined profile or validation module could pass 500 lines. Prevented by the module split in [P3-T3]..[P5-T3], `$defs` reuse in the schemas, and the per-file count in [P6-T10]; growth goes into a new module with its own test file.
- Test isolation: duplicate test basenames under prepend import mode and a process-wide registry cache could leak between tests. Prevented by `tests/docs_runtime/__init__.py` and the `docs_` prefixes ([P3-T3], [P3-T4]), a content-keyed immutable cache ([P3-T4]), and the reversed-order single-process run of the new and changed Python modules in [P6-T6]. The seeded Jest shuffle and the seeded Pester file-order shuffles are not applicable: the plan touches no TypeScript and no PowerShell.
- CI-only behavior: CI fails on an out-of-sync `poetry.lock`, on `QT008` from the tier check, and on Linux path handling. Prevented by [P2-T3] and [P6-T7] (lock regenerated and checked after commit), [P2-T4] and [P6-T8], and POSIX relative paths with no drive letters in tests and examples. No test reads gitignored `artifacts/` state or `dist/`; the default-reader tests read the committed staged copies. `_build-check.yml` builds the root wheel with the new path dependency in the same pattern as the discovery package.
- Evidence: artifacts written outside `FEATURE/evidence/<kind>/` or with plan-time stamps are rejected. Every evidence-producing task names a canonical path with a write-time `<timestamp>`, records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and records `SCRATCH` rather than a host path.

## Test Plan

- Unit: `tests/docs_runtime/` (nine modules plus `__init__.py`), `tests/scripts/dev_tools/test_build_docs_runtime.py`.
- Integration: `tests/schemas/docs/test_docs_schemas_v1.py` (examples against schemas, offline closure into discovery v2 `common`); `test_docs_package_contract.py` (staged copies, root registration); [P5-T6] console-script smoke.
- Property (T2): enumerated `itertools.product`/`itertools.permutations` tests for `element_identifier`, `element_to_json`, `diagnostic_to_json`, `validate_registry`/`select_registrations`/`registered_identifiers`, `docs_schema_id`, `validate_artifact`, `starter_profile`, `render_profile_json`, `parse_profile`.
- Coverage evidence: baseline `FEATURE/evidence/baseline/baseline-pytest-coverage.<timestamp>.md`; post-change `FEATURE/evidence/qa-gates/qa-pytest-coverage.<timestamp>.md`; comparison `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- Assumptions A5 and A6 of the epic are relied on and remain provisional; if A5 is rejected, package path, import name, tier entry, and module paths change.
- `scripts.dev_tools.validate_json` (local `fix_all` only, not CI) resolves `$schema` by file path or URL, so it cannot resolve the `urn:` `$schema` of `examples/docs/v1/*.example.json`; the examples are validated by `tests/schemas/docs/test_docs_schemas_v1.py`. `validate_json` is out of scope and unchanged.
- `quality-tiers.yml` and `test_quality_tiers_contract_classification.py` are also edited by the sibling page-check feature; the append-only conflict is resolved in the later child's remediation loop.
