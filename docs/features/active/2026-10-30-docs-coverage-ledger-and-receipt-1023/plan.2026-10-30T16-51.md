# docs-coverage-ledger-and-receipt - Plan

- **Issue:** #1023
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 900005, wave 1, band C4)
- **Depends on:** #1020 (docs-profile-and-artifact-schemas; planned, not executed when this plan was written)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T16-51
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature (AC sources: `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`)
- **Research:** `research/2026-10-30T20-59-docs-coverage-ledger-and-receipt-research.md`

## Required References

- Policy order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md` (and the `.github/instructions/` sources they mirror).
- Contracts: `spec.md` (normative command contracts, exit codes, envelope, receipt, write boundary) and the epic `docs/features/epics/documentation-estate-tooling/epic.md` sections `### Naming contract (fixed for all children)`, `### Decisions recorded during preparation of 1020 (binding on later children)` and `### 900005 - docs-coverage-ledger-and-receipt (wave 1, C4)`, which this plan consumes and does not change.
- #1020 contracts are cited by file and symbol from `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` and `plan.2026-10-30T16-08.md`. This plan never re-creates or edits a #1020 production module or schema.
- Environment: tool routes, launchers, command-text restrictions, the batch budget, hook context, and CI shape are owned by the `execution-environment` skill and are not restated here.
- The requirement originates in one consumer repository; no identifier of that repository appears in any file this plan creates.

## Execution Context

- Precondition A (dependency): #1020 is merged into `epic/documentation-estate-tooling-integration`, and this branch (`feature/docs-coverage-ledger-and-receipt-1023`) is updated from that integration branch before [P0-T1]. [P0-T2] proves the merged #1020 surface and halts the run when it differs.
- Precondition B (route): the feature creates sixteen non-test Python production modules under `packages/docs-runtime/src/drm_copilot_docs/`, which exceeds the direct-mode cap in the `execution-environment` skill section `## Batch Budget`. Execution therefore runs in the item worktree whose orchestration checkpoint selects the `large` route, never in an isolated subagent worktree.
- `FEATURE` is `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023`. Evidence files are named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match.
- `SCRATCH` is `<session scratchpad>/issue-1023/`; every scratch file, helper script, and coverage report lives under it with names starting `issue-1023-`. Evidence records the literal token `SCRATCH`, never a host path.
- `MERGE_BASE` is the output of `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`; every scope diff is anchored on it, because this feature's base is the integration branch, not `main`.
- `DOCS_SRC` abbreviates `packages/docs-runtime/src/drm_copilot_docs`; `DOCS_TESTS` abbreviates `tests/docs_runtime`.
- Plan validation: the installed `mcp__drm-copilot__validate_orchestration_artifacts` tool (`artifact_type: plan`), or the branch-current Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py` with its `plan` subcommand, per the `execution-environment` section `## MCP Surfaces Run the Installed Extension`.
- Read-only for this feature: everything under `packages/discovery-runtime/`, `schemas/discovery/`, and `schemas/docs/`, and the #1020 modules `surface_models.py`, `profile_models.py`, `profile.py`, `schema_validation.py`, `resources.py`, `analyzer_contract.py`, `cli.py`. `poetry.lock` is unchanged (no new dependency).

## Design Notes (refinements recorded for review)

- `DocsCliPorts` carries the four spec fields (`read_bytes`, `list_pages`, `store`, `clock`) plus one optional field `schema_resources: Mapping[str, bytes] | None = None`, passed to every `validate_artifact` and `validation.validate` call. This satisfies the spec non-functional requirement that tests do not depend on installed resources; the installed-ports factory leaves it `None`. If the merged #1020 `cli.py` port type already provides a reader, `DocsCliPorts` reuses that reader type ([P0-T2] records the name).
- `ValidationOutcome.receipt` is `None` only when the profile does not load (spec `### dev.docs.validate`: no receipt can be built).
- `mutation.py` adds `ArtifactStoreConflict`, the exception an `ArtifactStore` raises for an existing path on create or a digest mismatch on replace, because the spec Protocol methods return `None`.
- `parity_rules.py` adds the pure helpers `remove_rows` and `drop_pin_id` so `cli_ledger.py` holds no matrix logic and stays below the 500-line guidance.
- `DOCS_TESTS/ledger_test_support.py` is a test-only support module (precedent `tests/discovery_runtime/cli_test_support.py`): in-memory fixture builders, `schema_resources()` from the canonical schema bytes, `RecordingArtifactStore`, a fixed clock, `memory_ports`, and `invoke`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads, #1020 Re-Verification, and Baseline Capture

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md`, then `spec.md`, `user-story.md`, the research file, and the epic sections named in `## Required References`.
  - Acceptance: `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:`, and the list of files read.
- [ ] [P0-T2] Re-verify against the merged tree every #1020 file and symbol this plan consumes: `DOCS_SRC/__init__.py` (`__version__`); `surface_models.py` (`ElementKind`, `ELEMENT_KINDS`, `element_identifier`, `SurfaceElement`, `element_to_json`); `profile_models.py` (`DocsProfile`, `ArtifactPaths` with `inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`, `validation_receipt`; `CompletionGates`, `DocsCompleteGate` with `allow_deferred`, `max_stale_pages`, `required_parity_dimensions`; `PageOwner` with `path_or_glob`, `owner`; the documentation-roots field); `profile.py` (`parse_profile`, `ProfileLoadResult`); `schema_validation.py` (`DOCS_SCHEMA_NAMES`, `docs_schema_id`, `build_registry`, `validate_artifact` and the key form of its `resources` mapping); `resources.py` (`read_resource`); `cli.py` (`run_cli`, its ports type, and whether it contains a filesystem write primitive); the seven `schemas/docs/v1/*.schema.json` files and the field names in research `### 1.1`; `DOCS_TESTS/__init__.py`; `DOCS_TESTS/test_neutrality.py` (scan scope); `DOCS_TESTS/test_docs_package_contract.py` (`test_root_pyproject_registers_docs_console_scripts`, `test_package_pyproject_matches_runtime_contract`); the root `pyproject.toml` entry `"dev.docs.validate-profile"`; and the `packages/docs-runtime` entry in `quality-tiers.yml`.
  - Behavior: read-only. The record also states, for each of the two contract tests, whether it asserts presence of entries, an exact script set, or a fixed target module, and lists every test under `tests/` that reads `packages/docs-runtime/pyproject.toml` or `packages/docs-runtime/README.md` (search by file name).
  - Acceptance: `FEATURE/evidence/baseline/phase0-1020-contract-verification.<timestamp>.md` has one row per file and symbol marked `PRESENT`, `MISSING`, or `RENAMED`, plus the port type name, the `resources` key form, the contract-test assertion shapes, and the #1020 modules holding write primitives. Every row `PRESENT` is required to continue; any `MISSING` or `RENAMED` row stops the run as `BLOCKED at [P0-T2]` with no later task started, and a changed schema field is reported as an epic-level change.
- [ ] [P0-T3] Capture the formatting baseline with `poetry run black --check .` (check mode, no rewrite).
  - Acceptance: `FEATURE/evidence/baseline/baseline-black.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the `would be left unchanged` count or the files reported.
- [ ] [P0-T4] Capture the lint baseline with `poetry run ruff check --no-fix .`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-ruff.<timestamp>.md` records the four fields; `Output Summary:` states `All checks passed!` or the finding count.
- [ ] [P0-T5] Capture the type-check baseline with `poetry run pyright`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pyright.<timestamp>.md` records the four fields and the error, warning, and information counts from the summary.
- [ ] [P0-T6] Capture the test and coverage baseline with `poetry run pytest --cov=drm_copilot_docs --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1023-coverage-baseline.json`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-pytest-coverage.<timestamp>.md` records the four fields, passed and failed counts, and numeric `totals.percent_statements_covered` and `totals.percent_branches_covered` from the JSON report; it states that none of the sixteen modules this plan creates exists at baseline (new-code baseline: not present).
- [ ] [P0-T7] Capture the lock baseline with `poetry check --lock`.
  - Acceptance: `FEATURE/evidence/baseline/baseline-poetry-lock.<timestamp>.md` records the four fields.

### Phase 1 — Snapshot View, Ledger Models, and Ledger Rules

- [ ] [P1-T1] Create `DOCS_SRC/snapshot_view.py` (`SnapshotView`, `snapshot_view`), `DOCS_TESTS/ledger_test_support.py` (snapshot, profile, ledger, matrix, and pin builders with element ids computed by `element_identifier`; `schema_resources()` reading canonical `schemas/docs/v1/` and `schemas/discovery/v2/common.schema.json` bytes in the key form recorded by [P0-T2]), and `DOCS_TESTS/test_snapshot_view.py`.
  - Behavior: `snapshot_view(value, *, artifact_path, source_sha256) -> tuple[SnapshotView | None, tuple[Finding, ...]]` builds one `SurfaceElement` per element, keyed by `element_id`; a constructor `ValueError` becomes `DOCS_SNAPSHOT_ELEMENT_INVALID` at pointer `/elements/<n>`; non-object values are traversed defensively and reported, never raised.
  - Tests: `test_snapshot_view_builds_elements_by_id`, `test_tampered_element_id_is_reported`, `test_cli_option_without_parent_is_reported`, `test_non_object_elements_are_reported_not_raised`, `test_snapshot_view_is_invariant_under_element_order` (`itertools.permutations`).
  - Acceptance: `poetry run pytest tests/docs_runtime/test_snapshot_view.py -q` exits 0 with 0 failed.
- [ ] [P1-T2] Create `DOCS_SRC/ledger_models.py` (`PageBinding`, `Actor`, `ArtifactPinRef`, `LedgerEntry`, `CoverageLedger`, `ledger_from_json`, `ledger_to_json`) and `DOCS_TESTS/test_ledger_models.py`.
  - Behavior: frozen `kw_only` dataclasses; `ledger_to_json` sorts entries by `element_id` and bindings by `page_path` then `anchor`; `ledger_from_json` raises `ValueError` naming the pointer of a malformed entry.
  - Tests: `test_ledger_round_trips_through_json`, `test_ledger_to_json_sorts_entries_and_bindings`, `test_ledger_from_json_rejects_malformed_entry`, `test_ledger_to_json_validates_against_schema`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_ledger_models.py -q` exits 0 with 0 failed.
- [ ] [P1-T3] Create `DOCS_SRC/ledger_rules.py` with `validate_ledger(value, *, snapshot, artifact_path)` and the validation tests in `DOCS_TESTS/test_ledger_rules.py`.
  - Behavior: emits the spec `### Finding codes` rows raised by `ledger_rules` (`DOCS_LEDGER_MISSING_DISPOSITION` naming kind, declaration, and element id with `related_ids` and `related_paths`; duplicate, orphan, kind mismatch, the four companion codes; `DOCS_LEDGER_SNAPSHOT_REF` as warning), ordered through `FindingCollector`.
  - Tests: `test_missing_disposition_names_kind_declaration_and_id`, `test_duplicate_entry_is_reported`, `test_orphan_entry_is_reported`, `test_kind_mismatch_is_reported`, `test_companion_findings_per_disposition` (parametrized over the four companion codes), `test_snapshot_ref_digest_drift_is_warning`, `test_malformed_ledger_value_yields_findings_not_exception`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_ledger_rules.py -q` exits 0 with 0 failed.
- [ ] [P1-T4] Add `apply_disposition(...)` and `remove_entry(...)` to `DOCS_SRC/ledger_rules.py` with tests in `DOCS_TESTS/test_ledger_rules.py`.
  - Behavior: pure; `apply_disposition` replaces the whole entry (kind from the snapshot element, sorted bindings, `updated_by` actor); `remove_entry` raises `LookupError` for an absent element; inputs are never mutated.
  - Tests: `test_apply_disposition_replaces_entry_and_sorts_bindings`, `test_apply_disposition_records_actor_and_kind_from_element`, `test_apply_disposition_does_not_mutate_input`, `test_remove_entry_removes_only_named_element`, `test_remove_entry_unknown_element_raises_lookup_error`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_ledger_rules.py -q` exits 0 with 0 failed.

### Phase 2 — Evidence Pins and Staleness

- [ ] [P2-T1] Create `DOCS_SRC/evidence_pins.py` (`EvidencePin`, `PinCollection`, `pin_identifier`, `pin_from_element`, `pins_from_json`, `pins_to_json`, `validate_pins`) and `DOCS_TESTS/test_evidence_pins.py`.
  - Behavior: `pin_identifier` is `stable_id("pin", row(element_id=..., page_path=..., symbol=...))`; `pin_from_element` copies the element fields, snapshot revision, claim, clock value, and actor; `pins_to_json` sorts by `pin_id`; `validate_pins` raises `DOCS_PIN_INCONSISTENT` when `element_identifier(kind=element_kind, path=source_path, declaration=symbol)` differs from `element_id` or `pin_id` differs from its derivation.
  - Tests: `test_pin_identifier_is_stable_for_element_and_page`, `test_pin_identifier_is_injective_over_enumerated_inputs` (`itertools.product`), `test_pin_from_element_copies_element_fields`, `test_pins_round_trip_and_sort_by_pin_id`, `test_validate_pins_reports_tampered_element_id`, `test_validate_pins_reports_pin_id_drift`, `test_pins_to_json_validates_against_schema`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_evidence_pins.py -q` exits 0 with 0 failed.
- [ ] [P2-T2] Create `DOCS_SRC/staleness.py` (`PinStatus`, `PinAssessment`, `StalePage`, `assess_pin`, `stale_pages`) and `DOCS_TESTS/test_staleness.py`.
  - Behavior: per spec `### Staleness`: `element-missing`, `digest-changed`, or `current` by digest equality only; a page is stale exactly when one of its pins is not `current`; records sorted by `page_path` then `pin_id`; pin `revision` is never compared.
  - Tests: `test_assess_pin_reports_digest_changed`, `test_assess_pin_reports_element_missing`, `test_assess_pin_reports_current_for_equal_digest`, `test_revision_difference_alone_is_not_stale`, `test_stale_pages_groups_non_current_pins_by_page`, `test_page_with_only_current_pins_is_not_stale`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_staleness.py -q` exits 0 with 0 failed.

### Phase 3 — Parity Matrix, Scoring, and Ledger Properties

- [ ] [P3-T1] Create `DOCS_SRC/parity_models.py` (`PARITY_DIMENSIONS`, `DimensionResult`, `ParityRow`, `ParityMatrix`, `matrix_from_json`, `matrix_to_json`) and `DOCS_TESTS/test_docs_parity_models.py`.
  - Behavior: rows sorted by `element_id` then `page_path`; `evidence_pin_ids` sorted; exactly the five dimensions.
  - Tests: `test_parity_dimensions_match_schema_enumeration`, `test_matrix_round_trips_through_json`, `test_matrix_to_json_sorts_rows`, `test_matrix_from_json_rejects_missing_dimension`, `test_matrix_to_json_validates_against_schema`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_parity_models.py -q` exits 0 with 0 failed.
- [ ] [P3-T2] Create `DOCS_SRC/parity_rules.py` with `validate_matrix(value, *, ledger, pins, snapshot, page_paths, page_owners, artifact_path)` and the validation tests in `DOCS_TESTS/test_docs_parity_rules.py`.
  - Behavior: emits the spec rows raised by `parity_rules` (`DOCS_MATRIX_LEDGER_REF` warning; unbound row, missing row, duplicate row, unknown pin, accuracy unpinned, exists inconsistent, owner inconsistent with `fnmatch.fnmatchcase` over `page_owners`).
  - Tests: `test_unbound_row_is_reported`, `test_documented_binding_without_row_is_reported`, `test_duplicate_row_is_reported`, `test_unknown_or_foreign_pin_is_reported`, `test_accurate_pass_without_pin_is_reported`, `test_exists_pass_for_absent_page_is_reported`, `test_owner_assigned_pass_without_matching_owner_is_reported`, `test_owner_glob_match_satisfies_owner_assigned`, `test_ledger_ref_digest_drift_is_warning`, `test_consistent_matrix_yields_no_findings`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_parity_rules.py -q` exits 0 with 0 failed.
- [ ] [P3-T3] Add `set_dimension(...)`, `remove_rows(...)`, and `drop_pin_id(...)` to `DOCS_SRC/parity_rules.py` with tests in `DOCS_TESTS/test_docs_parity_rules.py`.
  - Behavior: `set_dimension` creates an absent row (other dimensions `not-assessed`, rationale `null`, no pin ids), sets the named dimension's state and rationale, and sets its `evidence_pin_ids` to the sorted ids of pins for the element and page; `remove_rows` drops rows for an element (optionally one page); `drop_pin_id` removes one id from every row.
  - Tests: `test_set_dimension_creates_row_with_not_assessed_defaults`, `test_set_dimension_derives_sorted_pin_ids_from_pins`, `test_set_dimension_updates_only_named_dimension`, `test_remove_rows_drops_element_page_rows`, `test_drop_pin_id_removes_reference_from_every_row`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_parity_rules.py -q` exits 0 with 0 failed.
- [ ] [P3-T4] Create `DOCS_SRC/parity_scoring.py` (`DimensionScore`, `score_matrix`) and `DOCS_TESTS/test_parity_scoring.py`.
  - Behavior: integer counts per dimension; `score_basis_points` is `(10000 * pass) // (pass + fail + not_assessed)`, or `None` when that denominator is 0; no float is produced.
  - Tests: `test_score_basis_points_uses_integer_floor`, `test_score_is_null_when_only_not_applicable`, `test_counts_sum_to_row_count_for_enumerated_assignments` (`itertools.product` over the four states for up to three rows), `test_score_matrix_contains_no_float`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_parity_scoring.py -q` exits 0 with 0 failed.
- [ ] [P3-T5] Create `DOCS_TESTS/test_ledger_properties.py` with enumerated properties (no `random`, no `hypothesis`).
  - Tests: `test_missing_disposition_findings_name_exact_complement` (`itertools.combinations` over every subset of the six-element snapshot), `test_disposition_companion_findings_equal_companion_table` (`itertools.product` over three dispositions and presence of bindings, rationale, owner, target), `test_staleness_status_product_property` ({present, absent} by {equal, different} digests), `test_page_stale_iff_any_pin_not_current`, `test_ledger_output_is_invariant_under_entry_permutation`, `test_matrix_output_is_invariant_under_row_permutation`, `test_pin_output_is_invariant_under_pin_permutation` (each `itertools.permutations`, comparing `canonical_json` bytes and findings).
  - Acceptance: `poetry run pytest tests/docs_runtime/test_ledger_properties.py -q` exits 0 with 0 failed.

### Phase 4 — Receipt and Validation Modes

- [ ] [P4-T1] Create `DOCS_SRC/receipt.py` (`receipt_identifier`, `receipt_counts`, `build_receipt`) and `DOCS_TESTS/test_receipt.py`.
  - Behavior: every field in spec `### Receipt`; `id` is `stable_id("docs-validation-receipt", row(mode=..., repository=..., revision=..., inputs=..., validation_result=...))`; `inputs` sorted by `artifact_kind` then `path`; `validation_result` computed before the findings bound; `counts` carries every disposition and kind key.
  - Tests: `test_receipt_identifier_matches_stable_id_derivation`, `test_receipt_identifier_ignores_issued_at_and_tracks_members` (`itertools.product` over variants of the five members and two `issued_at` values), `test_receipt_counts_cover_every_disposition_and_kind`, `test_receipt_counts_are_zero_in_profile_mode`, `test_build_receipt_inputs_pin_raw_bytes_sorted`, `test_validation_result_fails_on_error_beyond_findings_bound`, `test_build_receipt_validates_against_schema` (pass and fail).
  - Acceptance: `poetry run pytest tests/docs_runtime/test_receipt.py -q` exits 0 with 0 failed.
- [ ] [P4-T2] Create `DOCS_SRC/validation.py` (`ValidationMode`, `ValidationInputs`, `ValidationOutcome`, `validate`) implementing the `profile` and `ledger` modes, with `DOCS_TESTS/test_validation.py`.
  - Behavior: `ValidationInputs` holds the profile path, raw bytes keyed by POSIX relative path, and the page-path set; an absent artifact yields `DOCS_INPUT_UNREADABLE`; artifacts parse through `parse_document` and validate through `validate_artifact`; `DOCS_REVISION_MISMATCH`; a naive or non-UTC `issued_at` and a built receipt failing its schema raise `ValueError`.
  - Tests: `test_profile_mode_reports_parse_profile_findings`, `test_profile_mode_unloadable_profile_returns_no_receipt`, `test_ledger_mode_reports_absent_ledger_as_input_unreadable`, `test_ledger_mode_reports_schema_invalid_ledger`, `test_ledger_mode_reports_missing_disposition`, `test_revision_mismatch_is_reported`, `test_naive_issued_at_is_rejected`, `test_validate_is_pure_with_supplied_resources`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_validation.py -q` exits 0 with 0 failed.
- [ ] [P4-T3] Add the `matrix` and `docs-complete` modes to `DOCS_SRC/validation.py` with tests in `DOCS_TESTS/test_validation.py`.
  - Behavior: `matrix` adds matrix and pin schema checks, `validate_matrix`, `validate_pins`, and `DOCS_PAGE_STALE` as warning; `docs-complete` adds `DOCS_DEFERRED_NOT_ALLOWED`, `DOCS_PARITY_REQUIRED_DIMENSION` (`fail` and `not-assessed` fail; `pass` and `not-applicable` satisfy), `DOCS_PAGE_MISSING`, stale severity per `max_stale_pages`, and `DOCS_SNAPSHOT_UNPINNED`.
  - Tests: `test_matrix_mode_reports_stale_page_as_warning`, `test_matrix_mode_reports_parity_and_pin_findings`, `test_docs_complete_deferred_not_allowed`, `test_docs_complete_required_dimension_states` (parametrized over the four states), `test_docs_complete_page_missing`, `test_docs_complete_stale_severity_follows_max_stale_pages` (count below, equal to, above the limit), `test_docs_complete_null_snapshot_revision_is_unpinned`, `test_docs_complete_complete_fixture_passes`, `test_every_mode_includes_previous_mode_checks`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_validation.py -q` exits 0 with 0 failed.

### Phase 5 — Write Boundary

- [ ] [P5-T1] Create `DOCS_SRC/mutation.py` core (`ArtifactStore`, `ArtifactStoreConflict`, `PlannedArtifactWrite`, `ArtifactWriteResult`, `MutationOutcome`, `plan_artifact_writes`, `commit_artifact_writes`), add `RecordingArtifactStore` to `DOCS_TESTS/ledger_test_support.py`, and create `DOCS_TESTS/test_mutation.py`.
  - Behavior: planning is pure and marks unchanged bytes `skipped`; commit runs in ascending path order, defaults to dry run (statuses `planned`/`skipped`, no store write call), creates an absent file with `create_exclusive`, replaces with `replace_if_digest` against the digest read at planning time, maps `ArtifactStoreConflict` to `conflict`, stops at the first failure, and lists earlier written paths.
  - Tests: `test_plan_marks_unchanged_document_skipped`, `test_dry_run_makes_no_store_write_call`, `test_commit_creates_absent_document_exclusively`, `test_commit_replaces_when_digest_matches`, `test_commit_digest_mismatch_reports_conflict_and_stops`, `test_commit_lists_written_paths_on_failure`, `test_plan_is_invariant_under_document_order`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_mutation.py -q` exits 0 with 0 failed.
- [ ] [P5-T2] Add `LocalArtifactStore` to `DOCS_SRC/mutation.py` with tests in `DOCS_TESTS/test_mutation.py`.
  - Behavior: per spec `### Write boundary`: `os.open` with `O_CREAT | O_EXCL` for create; a staged sibling file plus `os.replace` after a digest re-check for replace; the staged file is unlinked on failure; paths pass `validate_finding_path` and resolve against the working directory.
  - Tests (every `os` function the adapter calls is monkeypatched, as `tests/discovery_runtime/test_mutation_filesystem.py` does; no file is opened): `test_local_create_uses_exclusive_flags`, `test_local_create_existing_file_is_conflict`, `test_local_replace_rechecks_digest_before_replace`, `test_local_replace_digest_mismatch_is_conflict_without_write`, `test_local_replace_unlinks_staged_file_on_failure`, `test_local_store_rejects_non_relative_path`, `test_local_read_absent_returns_none`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_mutation.py -q` exits 0 with 0 failed.

### Phase 6 — Coverage Report

- [ ] [P6-T1] Create `DOCS_SRC/coverage_report.py` (`build_coverage_report`, `render_coverage_text`) and `DOCS_TESTS/test_docs_coverage_report.py`.
  - Behavior: `result` sections per spec `### dev.docs.coverage` (`totals` from `receipt_counts`, `undocumented`, `deferred`, `stale_pages`, `parity` from `score_matrix`); an absent ledger, matrix, or pin collection is treated as empty; text lines per the spec line shapes. Read-only.
  - Tests: `test_report_lists_undocumented_elements_sorted`, `test_report_with_empty_ledger_lists_every_element`, `test_report_lists_deferred_entries`, `test_report_lists_stale_pages_with_pin_status`, `test_report_parity_counts_sum_to_row_count`, `test_report_contains_no_float`, `test_render_coverage_text_line_shapes`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_coverage_report.py -q` exits 0 with 0 failed.

### Phase 7 — CLI Support and the Three Commands

- [ ] [P7-T1] Create `DOCS_SRC/cli_support.py` (`DocsCliPorts`, the installed-ports factory, exit-code constants, common-option and value-grammar helpers, `SystemExit`-safe parsing, envelope and text emission, the `DOCS_CLI_ARGUMENTS`, `DOCS_CLI_RUNTIME`, and `DOCS_MUTATION_FAILED` findings, input loading), add `memory_ports` and `invoke` to `DOCS_TESTS/ledger_test_support.py`, and create `DOCS_TESTS/test_cli_support.py`.
  - Behavior: spec `### Shared CLI conventions`, `### Exit codes`, `### Output envelope`, and `### Text format`; the factory is the only constructor of `LocalArtifactStore`; a naive or non-UTC clock value is a runtime failure.
  - Tests: `test_envelope_keys_and_ok_flag` (parametrized over exit codes), `test_envelope_findings_are_ordered_and_bounded`, `test_render_text_lines_and_summary`, `test_arguments_failure_has_single_finding_and_null_result`, `test_runtime_failure_writes_fixed_stderr_line`, `test_parse_arguments_converts_system_exit`, `test_path_option_rejects_absolute_or_parent_path`, `test_revision_option_rejects_short_or_uppercase_hex`, `test_installed_ports_construct_local_store`, `test_naive_clock_value_is_runtime_failure`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_cli_support.py -q` exits 0 with 0 failed.
- [ ] [P7-T2] Create `DOCS_SRC/cli_coverage.py` (`main_coverage`, `run_coverage_cli`) and `DOCS_TESTS/test_cli_coverage.py`.
  - Behavior: spec `### dev.docs.coverage`; never calls the `ArtifactStore`; findings empty on exit 0.
  - Tests: `test_coverage_success_exits_zero_with_result_sections`, `test_coverage_absent_ledger_lists_every_element_exit_zero`, `test_coverage_absent_snapshot_exits_one_input_unreadable`, `test_coverage_schema_invalid_snapshot_exits_one`, `test_coverage_makes_zero_store_calls`, `test_coverage_invalid_arguments_exit_two` (unknown option, missing value, invalid `--profile` path), `test_coverage_read_failure_exits_three`, `test_coverage_help_reads_no_input`, `test_coverage_json_output_is_byte_identical_across_runs`, `test_coverage_text_output_ends_with_summary`, `test_main_coverage_delegates_to_run_coverage_cli`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_cli_coverage.py -q` exits 0 with 0 failed.
- [ ] [P7-T3] Create `DOCS_SRC/cli_ledger.py` (`main_update_ledger`, `run_ledger_cli`) with the argument grammar, the per-operation permitted-option table, `set-disposition`, `remove-entry`, validation before planning, and dry-run planning, plus `DOCS_TESTS/test_cli_ledger.py`.
  - Behavior: spec `### dev.docs.update-ledger`; an operation fails (exit 1, nothing planned) only when its `error` findings contain one absent before it, compared on every field except `pointer`; a created document carries the #1020 header with `id` `stable_id(<artifact_kind>, row(repository=...))`.
  - Tests: `test_set_disposition_dry_run_plans_ledger_write`, `test_set_disposition_dropping_binding_removes_rows_and_pins`, `test_set_disposition_excluded_without_rationale_exits_one_without_writes`, `test_preexisting_errors_do_not_block_valid_update`, `test_set_disposition_orphan_element_exits_one`, `test_remove_entry_removes_entry_rows_and_pins`, `test_remove_entry_unknown_element_is_target_invalid`, `test_option_outside_operation_set_exits_two` (parametrized per operation), `test_invalid_values_exit_two` (unknown option, missing `--operation`, invalid `--element`, `--actor-id`, `--page`, repeated `--page`), `test_created_document_carries_header_with_stable_id`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_cli_ledger.py -q` exits 0 with 0 failed.
- [ ] [P7-T4] Add `pin`, `unpin`, `set-dimension`, `sync-refs`, and the `--write` commit path to `DOCS_SRC/cli_ledger.py` with tests in `DOCS_TESTS/test_cli_ledger.py`.
  - Behavior: per the spec operation semantics; `--write` commits through `mutation.commit_artifact_writes`; a commit failure exits 3 with one `DOCS_MUTATION_FAILED` finding naming the conflicting and already-written paths.
  - Tests: `test_pin_creates_pin_from_snapshot_element`, `test_pin_replaces_existing_pin_and_clears_staleness`, `test_unpin_removes_pin_and_matrix_references`, `test_set_dimension_creates_row_and_derives_pin_ids`, `test_sync_refs_sets_snapshot_and_ledger_digests`, `test_unknown_pin_or_binding_is_target_invalid`, `test_write_creates_absent_document_exclusively`, `test_write_replaces_when_digest_matches`, `test_write_conflict_exits_three_with_mutation_failed`, `test_dry_run_makes_zero_store_write_calls`, `test_update_ledger_json_output_is_byte_identical_across_runs`, `test_update_ledger_text_output_ends_with_summary`, `test_update_ledger_read_failure_exits_three`, `test_update_ledger_help_reads_no_input`, `test_main_update_ledger_delegates_to_run_ledger_cli`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_cli_ledger.py -q` exits 0 with 0 failed.
- [ ] [P7-T5] Create `DOCS_SRC/cli_validate.py` (`main_validate`, `run_validate_cli`) and `DOCS_TESTS/test_cli_validate.py`.
  - Behavior: spec `### dev.docs.validate`; without `--write-receipt` no store call in any mode; with it, plans only the `docs-validation-receipt` kind at `artifact_paths.validation_receipt` on pass and on fail.
  - Tests: `test_every_mode_receipt_validates_and_pins_revision` (four modes by pass and fail), `test_validate_without_write_receipt_makes_zero_store_calls` (each mode), `test_write_receipt_persists_on_pass_and_fail`, `test_write_receipt_plans_only_receipt_kind`, `test_write_receipt_conflict_exits_three`, `test_validate_docs_complete_null_revision_exits_one`, `test_unloadable_profile_exits_one_with_null_result`, `test_invalid_revision_exits_two_before_reading`, `test_missing_mode_exits_two` (parametrized with an unknown option as a second case; each case asserts one `DOCS_CLI_ARGUMENTS` finding and `result` `null`), `test_validate_read_failure_exits_three`, `test_validate_help_reads_no_input`, `test_validate_json_output_is_byte_identical_across_runs`, `test_validate_text_output_has_receipt_line_and_summary`, `test_main_validate_delegates_to_run_validate_cli`.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_cli_validate.py -q` exits 0 with 0 failed.

### Phase 8 — Console-Script Registration and Package Documentation

- [ ] [P8-T1] Append to root `pyproject.toml` `[tool.poetry.scripts]`, after the #1020 docs entries: `"dev.docs.coverage" = "drm_copilot_docs.cli_coverage:main_coverage"`, `"dev.docs.update-ledger" = "drm_copilot_docs.cli_ledger:main_update_ledger"`, `"dev.docs.validate" = "drm_copilot_docs.cli_validate:main_validate"`.
  - Existing tests (search of `tests/` for `pyproject.toml`, `tool.poetry.scripts`, and `dev.docs.`): `tests/discovery_runtime/test_package_contract.py::test_root_tooling_includes_the_local_runtime_for_types_and_coverage` unchanged (reads the dependency line and the coverage and pyright tables); `tests/scripts/dev_tools/discovery/test_init_cli.py::test_console_script_registered_in_pyproject` unchanged (substring presence of the discovery entry); `tests/scripts/dev_tools/test_ruff_config_alignment.py` and `tests/scripts/dev_tools/test_pyright_config_alignment.py` unchanged (tool tables only); `DOCS_TESTS/test_docs_package_contract.py::test_root_pyproject_registers_docs_console_scripts` unchanged when [P0-T2] recorded presence assertions, otherwise updated to add the three entries because the docs script set grows by design.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_package_contract.py tests/discovery_runtime/test_package_contract.py -q` exits 0 with 0 failed.
- [ ] [P8-T2] Append the same three entries to `packages/docs-runtime/pyproject.toml` `[tool.poetry.scripts]`.
  - Existing tests: `DOCS_TESTS/test_docs_package_contract.py::test_package_pyproject_matches_runtime_contract` unchanged when [P0-T2] recorded presence assertions; updated when it asserts an exact script set or pins every target to `drm_copilot_docs.cli`, so that it accepts the three `cli_coverage`, `cli_ledger`, and `cli_validate` targets and still asserts each target is callable. `tests/scripts/dev_tools/test_build_discovery_runtime.py::test_project_metadata_matches_runtime_contract` and `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_cli_reference_lists_every_console_script` unchanged (they read only `packages/discovery-runtime/pyproject.toml`); every other reader of `packages/docs-runtime/pyproject.toml` listed by [P0-T2] is named in the evidence with its disposition.
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_package_contract.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py -q` exits 0 with 0 failed; `FEATURE/evidence/other/script-table-test-dispositions.<timestamp>.md` lists every test named in [P8-T1] and [P8-T2] with its disposition.
- [ ] [P8-T3] Run `poetry check --lock`, `poetry install`, `git status --porcelain -- poetry.lock`, and the smoke commands `poetry run dev.docs.coverage --help`, `poetry run dev.docs.update-ledger --help`, `poetry run dev.docs.validate --help`.
  - Acceptance: every command exits 0, the status command prints nothing (lock unchanged; script tables are outside the lock content hash), and each help output starts with its `usage:` line; `FEATURE/evidence/regression-testing/cli-smoke.<timestamp>.md` records each command with the four fields.
- [ ] [P8-T4] Add a section to `packages/docs-runtime/README.md` documenting the three commands, their exit codes, the JSON envelope keys, and receipt persistence through `--write-receipt` (spec Definition of Done).
  - Acceptance: the README section names `dev.docs.coverage`, `dev.docs.update-ledger`, `dev.docs.validate`, and `--write-receipt`; any README reader listed by [P0-T2] passes when run with `poetry run pytest <that test file> -q`.

### Phase 9 — Integration, Write-Boundary, and Contract Tests

- [ ] [P9-T1] Create `DOCS_TESTS/test_docs_complete_integration.py` over one in-memory fixture (profile with `allow_deferred` false and `max_stale_pages` 0; snapshot pinned to a full revision; one element without a ledger entry; one pin whose digest differs from its element), with read ports backed by the same mapping the recording store writes.
  - Tests: `test_docs_complete_passes_on_complete_fixture` (exit 0, `pass` receipt), `test_docs_complete_fails_naming_undocumented_element_and_stale_page` (exit 1, `fail` receipt valid against the schema, findings naming the element declaration and element id and the stale page path), `test_docs_complete_passes_after_entry_added_and_pin_refreshed` (`run_ledger_cli` `set-disposition --write` and `pin --write`, then exit 0 with a `pass` receipt).
  - Acceptance: `poetry run pytest tests/docs_runtime/test_docs_complete_integration.py -q` exits 0 with 0 failed.
- [ ] [P9-T2] Create `DOCS_TESTS/test_write_boundary.py` with the pure AST helper `find_write_primitives(source)` and the module-level `WRITE_ALLOWLIST` (one reason per entry: `mutation.py` from this feature plus each #1020 module [P0-T2] recorded as holding a write primitive).
  - Tests: `test_write_primitives_appear_only_in_allowlisted_modules` (parametrized over every `.py` file under `DOCS_SRC` outside `__pycache__`), `test_allowlist_entries_exist_and_carry_reasons`, `test_commit_artifact_writes_is_referenced_only_from_cli_ledger_and_cli_validate`, `test_local_artifact_store_is_constructed_only_in_cli_support`, `test_serializers_are_not_referenced_from_validate_or_coverage_cli`, `test_scan_helper_detects_write_in_source_string` (positive control over an in-memory source containing `Path(p).write_text(x)`), `test_feature_test_modules_avoid_temporary_files_and_randomness` (parametrized over the nineteen test modules and `ledger_test_support.py`: no import of `tempfile`, `hypothesis`, or `random`; no `tmp_path` or `tmp_path_factory` parameter).
  - Acceptance: `poetry run pytest tests/docs_runtime/test_write_boundary.py -q` exits 0 with 0 failed and the positive control passes.
- [ ] [P9-T3] Run the #1020 contract suites with the new modules in scope: `poetry run pytest tests/docs_runtime/test_neutrality.py tests/docs_runtime/test_docs_package_contract.py tests/docs_runtime/test_cli.py -q`.
  - Acceptance: exits 0 with 0 failed, and the node IDs printed by `poetry run pytest tests/docs_runtime/test_neutrality.py --collect-only -q` (the `-q` run above prints no parameter IDs) include `test_docs_runtime_file_contains_no_configured_identifier` parameters for the sixteen new modules; `FEATURE/evidence/regression-testing/contract-suites.<timestamp>.md` records the four fields and the passed count.

### Phase 10 — Final QA Loop, Scope Checks, and Self-Review

- [ ] [P10-T1] Run `poetry run black .` then `poetry run black --check .`.
  - Acceptance: the check prints `would be left unchanged` with no `would reformat` line and exits 0; if the write run printed `reformatted`, restart from [P10-T1]. `FEATURE/evidence/qa-gates/qa-black.<timestamp>.md` records the four fields.
- [ ] [P10-T2] Run `poetry run ruff check --no-fix .`.
  - Acceptance: prints `All checks passed!` and exits 0; on any finding, fix it and restart from [P10-T1]. The only suppression is `# noqa: BLE001 - CLI top-level error handling` in the three CLI modules, per `.claude/rules/python-suppressions.md`. `FEATURE/evidence/qa-gates/qa-ruff.<timestamp>.md` records the four fields.
- [ ] [P10-T3] Run `poetry run pyright`.
  - Acceptance: the summary reports `0 errors` and exits 0; otherwise fix and restart from [P10-T1]. `FEATURE/evidence/qa-gates/qa-pyright.<timestamp>.md` records the four fields.
- [ ] [P10-T4] Run the full suite in CI shape: `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1023-coverage-final.json --cov`, then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-1023-coverage-final.json --min-line 85 --min-branch 75`.
  - Acceptance: both exit 0 with 0 failed tests; `FEATURE/evidence/qa-gates/qa-pytest-coverage.<timestamp>.md` records the four fields, the passed count, and numeric totals for statements and branches.
- [ ] [P10-T5] Measure new-code coverage with `poetry run pytest tests/docs_runtime --cov=drm_copilot_docs --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1023-coverage-new.json`.
  - Acceptance: exits 0; `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` records the baseline `drm_copilot_docs` totals ([P0-T6]), the post-change `drm_copilot_docs` totals from this run's JSON report (the same `--cov=drm_copilot_docs` scope as the baseline), the repository totals ([P10-T4]), and for each of the sixteen new modules the line and branch percentages read from that file's `summary` in the JSON report, each at least 85 for lines and 75 for branches. A value below its floor is remediation-required, not PASS.
- [ ] [P10-T6] Run the reversed-order isolation check in one process: `poetry run pytest -q` with the module paths passed explicitly in reverse sorted path order: `test_write_boundary.py`, `test_validation.py`, `test_staleness.py`, `test_snapshot_view.py`, `test_receipt.py`, `test_parity_scoring.py`, `test_mutation.py`, `test_ledger_rules.py`, `test_ledger_properties.py`, `test_ledger_models.py`, `test_evidence_pins.py`, `test_docs_parity_rules.py`, `test_docs_parity_models.py`, `test_docs_package_contract.py`, `test_docs_coverage_report.py`, `test_docs_complete_integration.py`, `test_cli_validate.py`, `test_cli_support.py`, `test_cli_ledger.py`, `test_cli_coverage.py` (all under `DOCS_TESTS`).
  - Acceptance: exits 0 with 0 failed; `FEATURE/evidence/regression-testing/isolation-reversed-order.<timestamp>.md` records the four fields and the module order. An order dependence is fixed on both sides and the run repeated.
- [ ] [P10-T7] Re-run the lock gate on the committed tree: `poetry check --lock`, `git diff --exit-code MERGE_BASE HEAD -- poetry.lock`, and `git status --porcelain -- poetry.lock`.
  - Acceptance: the first two exit 0 and the status command prints nothing; `FEATURE/evidence/qa-gates/qa-poetry-lock.<timestamp>.md` records each command with the four fields.
- [ ] [P10-T8] Verify scope: `git diff --name-only MERGE_BASE HEAD -- packages/discovery-runtime schemas/discovery schemas/docs` plus the seven read-only #1020 module paths under `DOCS_SRC`, and `git status --porcelain --untracked-files=all` over the same pathspecs.
  - Acceptance: both commands print nothing; `FEATURE/evidence/qa-gates/qa-scope.<timestamp>.md` records the `MERGE_BASE` derivation, both commands and outputs, and the full changed-file list from `git diff --name-status MERGE_BASE HEAD` and `git status --porcelain --untracked-files=all`.
- [ ] [P10-T9] Verify file size: logical line counts (`wc -l`) of every file this feature created under `DOCS_SRC` and `DOCS_TESTS`, then run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` alone through the branch-current PowerShell route of the `execution-environment` skill (`## PowerShell Route and PoshQC MCP Limits`), reading pass and fail counts from the result file.
  - Acceptance: no created file exceeds 800 lines, each production module is at most 500 lines or carries a split recorded in the evidence, and the gate suite reports 0 failed; `FEATURE/evidence/qa-gates/qa-file-size.<timestamp>.md` records per-file counts and the suite result.
- [ ] [P10-T10] Run the forbidden-token search with a `sh` script `SCRATCH/issue-1023-forbidden-token-scan.sh` that collects every created or changed path from `git diff --name-only MERGE_BASE HEAD` and `git status --porcelain --untracked-files=all` (status columns stripped, deleted paths dropped), removes this plan file `FEATURE/plan.2026-10-30T16-51.md` from the list, and runs `grep -n -E '[Rr][Gg][Ff]|[Ff][Oo][Rr][Ee][Cc][Aa][Ss][Tt]'` over the remaining files.
  - Behavior: the bracketed pattern matches both tokens in any letter case. The plan file is excluded explicitly because it carries the pattern text; the pattern text holds neither token contiguously, so the exclusion removes no real occurrence.
  - Acceptance: grep prints no line and exits 1; `FEATURE/evidence/qa-gates/qa-forbidden-tokens.<timestamp>.md` records the four fields with `ExpectedExitCode: 1`, the scanned file count, and the stated exclusion. Any match is removed and the loop restarts from [P10-T1].
- [ ] [P10-T11] Check off each delivered criterion in `spec.md` and `user-story.md` `## Acceptance Criteria` per the `acceptance-criteria-tracking` skill (`## Check-Off Protocol`), one item at a time after its mapped test or evidence passes.
  - Acceptance: every criterion mapped in `## Acceptance Criteria Traceability` is `[x]` with criterion text unchanged; `FEATURE/evidence/qa-gates/ac-status.<timestamp>.md` carries the `### Acceptance Criteria Status` summary with total, checked, and remaining counts.
- [ ] [P10-T12] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from `MERGE_BASE` and every AC in `spec.md` and `user-story.md`.
  - Acceptance: `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL, or N/A row per checklist item and per AC; a FAIL row is fixed, the loop re-run from [P10-T1], and the self-review rewritten; the plan does not complete with a FAIL row.

## Acceptance Criteria Traceability

Spec criteria are S1-S27 and user-story criteria U1-U17, numbered in document order.

| AC | Tasks | Proving tests or evidence |
|---|---|---|
| S1, U10 | P1-T3, P3-T5 | `test_missing_disposition_names_kind_declaration_and_id`, `test_companion_findings_per_disposition` |
| S2, U3 | P2-T2 | `test_assess_pin_reports_digest_changed`, `test_assess_pin_reports_element_missing`, `test_revision_difference_alone_is_not_stale` |
| S3 | P3-T5 | `test_staleness_status_product_property`, `test_page_stale_iff_any_pin_not_current` |
| S4, U9 | P9-T1 | `test_docs_complete_passes_on_complete_fixture`, `test_docs_complete_fails_naming_undocumented_element_and_stale_page` |
| S5 | P9-T1 | `test_docs_complete_passes_after_entry_added_and_pin_refreshed` |
| S6, U14 | P4-T1, P7-T5 | `test_every_mode_receipt_validates_and_pins_revision`, `test_build_receipt_validates_against_schema` |
| S7, U14 | P4-T1, P7-T5 | `test_receipt_identifier_matches_stable_id_derivation`, `test_receipt_identifier_ignores_issued_at_and_tracks_members` |
| S8 | P4-T1 | `test_build_receipt_inputs_pin_raw_bytes_sorted` |
| S9, U12 | P4-T2, P4-T3, P7-T5 | `test_docs_complete_null_snapshot_revision_is_unpinned`, `test_revision_mismatch_is_reported`, `test_validate_docs_complete_null_revision_exits_one` |
| S10 | P4-T3 | `test_docs_complete_deferred_not_allowed`, `test_docs_complete_required_dimension_states`, `test_docs_complete_page_missing`, `test_docs_complete_stale_severity_follows_max_stale_pages` |
| S11, U8 | P9-T2 | `test_write_primitives_appear_only_in_allowlisted_modules`, `test_commit_artifact_writes_is_referenced_only_from_cli_ledger_and_cli_validate`, `test_scan_helper_detects_write_in_source_string` |
| S12, U15 | P7-T2, P7-T4, P7-T5 | `test_coverage_makes_zero_store_calls`, `test_validate_without_write_receipt_makes_zero_store_calls`, `test_write_receipt_plans_only_receipt_kind`, `test_dry_run_makes_zero_store_write_calls` |
| S13, U7 | P5-T1, P7-T4 | `test_write_creates_absent_document_exclusively`, `test_write_replaces_when_digest_matches`, `test_write_conflict_exits_three_with_mutation_failed` |
| S14, U5 | P7-T3 | `test_set_disposition_excluded_without_rationale_exits_one_without_writes`, `test_preexisting_errors_do_not_block_valid_update` |
| S15 | P7-T3, P7-T4 | operation tests in `test_cli_ledger.py`, `test_option_outside_operation_set_exits_two` |
| S16, U13, U16 | P7-T1..P7-T5 | per-command exit 0/1/2/3, `*_help_reads_no_input`, `test_parse_arguments_converts_system_exit`, `test_invalid_revision_exits_two_before_reading` |
| S17, U13 | P7-T1..P7-T5 | `test_envelope_keys_and_ok_flag`, `*_json_output_is_byte_identical_across_runs` |
| S18 | P7-T1..P7-T5 | `test_render_text_lines_and_summary`, `*_text_output_*` tests |
| S19, U1 | P3-T4, P6-T1, P7-T2 | `test_counts_sum_to_row_count_for_enumerated_assignments`, `test_coverage_success_exits_zero_with_result_sections` |
| S20 | P3-T5 | `test_missing_disposition_findings_name_exact_complement`, the three permutation tests |
| S21 | P3-T5 | `test_disposition_companion_findings_equal_companion_table` |
| S22 | P8-T1..P8-T3, P10-T7 | `test_root_pyproject_registers_docs_console_scripts`, `test_package_pyproject_matches_runtime_contract`, `qa-poetry-lock` |
| S23 | P9-T3 | `test_docs_runtime_file_contains_no_configured_identifier`, `contract-suites` |
| S24 | P9-T2 | `test_feature_test_modules_avoid_temporary_files_and_randomness` |
| S25 | P10-T8 | `qa-scope` |
| S26, U17 | P10-T5 | `coverage-delta` |
| S27 | P10-T9 | `qa-file-size` |
| U2 | P7-T2 | `test_coverage_absent_ledger_lists_every_element_exit_zero` |
| U4 | P7-T3, P7-T4 | `test_set_disposition_dry_run_plans_ledger_write`, `test_write_creates_absent_document_exclusively` |
| U6 | P2-T1, P7-T4 | `test_pin_identifier_is_stable_for_element_and_page`, `test_pin_replaces_existing_pin_and_clears_staleness` |
| U11 | P7-T5 | `test_write_receipt_persists_on_pass_and_fail` |

## Pre-Mortem

- Review checklists: a reviewer flags a finding that does not name its element or page, a receipt that fails its schema, a CLI write without `--write`, or an unauthorized suppression. Prevented by the naming assertions in [P1-T3] and [P9-T1], schema validation of every emitted receipt in [P4-T1] and [P7-T5], the zero-call recording-store tests in [P7-T2], [P7-T4], [P7-T5], the single pre-authorized `BLE001` form in [P10-T2], and the template walk in [P10-T12].
- Coverage: I/O-bearing modules (`mutation.py`, `cli_support.py`, the three CLIs) could fall below 85% line or 75% branch. Prevented by injected ports and `schema_resources`, monkeypatched `os` functions in [P5-T2], dotted `--cov=drm_copilot_docs` with `--cov-branch` and per-file JSON figures in [P10-T5], and the repository totals gate in [P10-T4]. No production path is excluded from measurement.
- Mirror parity: not applicable as a customization mirror, because no `.claude`, `.github`, `.codex`, `.agents`, or `extensions/drm-copilot/resources/` file is edited and no fact in the execution-environment brief changes (no CI job, required context, tool route, or batch-budget rule), so no brief-update task is needed. The one duplicated declaration is the script list in the root and package `pyproject.toml`, updated together in [P8-T1] and [P8-T2] and asserted by the #1020 contract tests.
- File size: `validation.py`, `parity_rules.py`, `cli_ledger.py`, and their test modules are the largest candidates. Prevented by the module split (matrix helpers in `parity_rules.py`, shared CLI code in `cli_support.py`, fixtures in `ledger_test_support.py`) and the per-file count and repository gate in [P10-T9]; growth past 500 lines goes into a new module with its own test file.
- Test isolation: shared fixtures and the #1020 content-keyed schema registry cache could leak state between modules. Prevented by builders that return fresh values per call, explicit `schema_resources` mappings, no temporary files ([P9-T2] asserts it), and the reversed-order single-process run of the new and changed Python test modules in [P10-T6]. The seeded Jest shuffle and the seeded Pester file-order shuffles are not applicable: no TypeScript or PowerShell file is touched ([P10-T9] only runs an existing Pester gate).
- CI-only behavior: CI fails on Linux path handling, an out-of-sync `poetry.lock`, and Windows-only `os.open` flags. Prevented by POSIX relative paths without drive letters in every fixture, no new dependency with the lock checked in [P8-T3] and [P10-T7], and adapter tests that assert flags through monkeypatched `os` functions instead of opening files. No test reads gitignored `artifacts/` state.
- Evidence: artifacts outside `FEATURE/evidence/<kind>/`, with plan-time stamps, or with host paths are rejected. Every evidence task names a canonical path with a write-time `<timestamp>`, records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records `SCRATCH` instead of a host path; [P0-T2] blocks the run before any code if the #1020 surface differs.

## Size Justification

The plan has 48 tasks, above the 40-task guideline, because the epic assigns sixteen production modules and three console commands with normative exit-code, envelope, receipt, and write-boundary contracts to this one child, and each module carries its own test module and binary acceptance. Splitting the item would separate the receipt from the validation modes and the write boundary from its only callers, which the downstream MCP and CI children consume as one contract.

## Test Plan

- Unit: nineteen modules under `DOCS_TESTS` plus `ledger_test_support.py`.
- Integration: `test_docs_complete_integration.py` ([P9-T1]); the #1020 contract suites ([P9-T3]); console-script smoke ([P8-T3]).
- Property (T2): enumerated `itertools` tests in [P1-T1], [P2-T1], [P3-T4], [P3-T5], [P4-T1], [P5-T1].
- Coverage evidence: baseline `FEATURE/evidence/baseline/baseline-pytest-coverage.<timestamp>.md`; post-change `FEATURE/evidence/qa-gates/qa-pytest-coverage.<timestamp>.md`; comparison `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- Spec A-1 (`DOCS_SNAPSHOT_UNPINNED` on a working-copy snapshot) and A-2 (receipt persisted only with `--write-receipt`) are implemented as written and isolated to `validation.py` and `cli_validate.py`.
- Spec Q1 (meaning of element `source_sha256`) does not change code: digests are compared for equality only. Q3 is answered by [P0-T2]. Q2 and Q4 are report-only.
- Append-only conflicts in both `[tool.poetry.scripts]` tables with sibling children are resolved in the later child's remediation loop.
