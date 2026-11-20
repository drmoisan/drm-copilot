# Code Review — legacy-discovery-schemas (#359)

- Timestamp: 2026-07-18T10-44
- Reviewer: feature-review agent
- Branch: `feature/legacy-discovery-schemas-359` (HEAD `b69a84e1`) vs `origin/epic/legacy-discovery-and-parity-integration`
- Files reviewed: 7 schema documents, 7 conforming fixtures, 7 non-conforming fixtures, 2 test modules

## 1. Domain Neutrality — PASS

- Independent scan re-run in this review: `rg -i "taskmaster|tmw|outlook|vsto|email|task-management"` across `schemas/discovery/v1/`, `examples/discovery/v1/`, `tests/fixtures/discovery_schemas/v1/`, and `tests/schemas/discovery/` — zero matches (exit 1). This is a wider scope than the executor's P1-T8 scan, which covered schemas only.
- Manual read of every field name, enum value, `title`, and `description` in all seven schemas confirms strictly generic legacy-discovery vocabulary (`unit_kind: module|namespace|type|file|component|other`, `source_label`/`target_label` as generic strings, etc.). Fixture values use neutral placeholders (`feature-alpha`, `legacy baseline`, `modern target`).
- Occurrences of TaskMaster/TMW in `spec.md`/`user-story.md` are requirement prose describing external consumers, not schema content; they are permitted.

## 2. Self-Contained `$defs` / No Cross-File `$ref` — PASS

- Every `$ref` in all seven schemas is `#/$defs/...`-rooted. Verified three ways: manual read; the executor's traversal evidence (`evidence/qa-gates/schema-neutrality-check.2026-07-18T10-12.md`: 38 refs, 0 non-local); and the automated test `test_no_cross_file_ref` (`test_v1_schema_documents.py` lines 237–244), which passed in this review's run.
- The shared `identifier`, `timestamp`, and `metadata` `$defs` are duplicated verbatim into each schema, as the spec's self-containment rule requires.

## 3. Top-Level Shape — PASS

- All seven schemas declare `"type": "object"` and top-level `"additionalProperties": false`, require `$schema`, `schema_version`, and `id`, and expose a single free-form `metadata` extension point. Enforced by `test_top_level_additional_properties_is_false` and `test_schema_requires_instance_schema_field`.
- Nested objects (`content_hash`, `summary`, `stimulus`, `observed_behavior`, array item shapes) also close their shapes with `additionalProperties: false`, except the deliberately free-form `metadata`, `stimulus.inputs`, `observed_behavior.outputs`, and parity-matrix `summary` objects, each of which the spec designates as free-form.

## 4. Versioning Convention Correctness — PASS

- `$schema` is exactly the Draft 2020-12 meta-schema URI in all seven documents (matches `Draft202012Validator`).
- `$id` equals the repo-relative path of each file (identifier-only; never dereferenced) — enforced by `test_schema_id_equals_repo_relative_path`.
- `version: "1.0.0"` with major equal to the `v1` directory in all seven — enforced by `test_schema_version_major_equals_one`.
- Instance `schema_version` is required with pattern `^1\.\d+\.\d+$` (major pinned, minor/patch free) in all seven — enforced by `test_schema_version_required_and_major_pinned`. The cross-major rejection path is exercised end-to-end by `evidence-reference.invalid.json` (`schema_version: "2.0.0"`).
- Instance `$schema` values are scheme-less relative paths: three ascents from `examples/discovery/v1/`, four ascents from `tests/fixtures/discovery_schemas/v1/` — verified in every fixture; compatible with `validate_json.py`'s `_load_schema` relative branch (no cache, no network).
- Timestamps are enforced by explicit ISO-8601 regex (`$defs/timestamp`), not `format: date-time`, matching the FormatChecker-less validator construction.

## 5. Fixture Quality — PASS

- **Conforming fixtures** exercise all required fields plus the planned optionals per schema (for example `feature-contract.example.json` includes `workflows`, `source_refs`, `evidence_refs`; `coverage-ledger.example.json` includes per-entry `evidence_refs`/`notes` on one entry and omits them on the other, exercising optionality both ways). Keys are alphabetically sorted in all seven files (verified by read), so the governed jq `--sort-keys` formatter produces no churn. All seven validate cleanly through `dev.validate-json` (re-run in this review: 8 `: ok`, 0 failures).
- **Non-conforming fixtures** implement seven distinct violation classes exactly as designed in the spec's Fixture Design table:
  1. `feature-contract.invalid.json` — missing required `acceptance_criteria`.
  2. `coverage-ledger.invalid.json` — wrong type at nested `summary.total_units` (`"ten"`).
  3. `runtime-characterization-scenario.invalid.json` — enum violation (`observation_method: "guesswork"`).
  4. `parity-matrix.invalid.json` — array-item violation (second row lacks `parity_status`).
  5. `unspecified-behavior-record.invalid.json` — identifier pattern violation (`id: "Behavior Record #1"`).
  6. `product-decision-record.invalid.json` — `additionalProperties: false` violation (`approved_by_manager`).
  7. `evidence-reference.invalid.json` — `schema_version` major mismatch (`"2.0.0"`).
- Each is otherwise well-formed, so the intended violation is the only failure and the asserted diagnostic substring is unambiguous.

## 6. Test Determinism and Offline Behavior — PASS

- Re-run in this review: `poetry run pytest tests/schemas/discovery/ -q` — 87 passed in 0.39 s.
- No wall-clock reads, no randomness, no `setTimeout`/sleep equivalents, no network access: meta-validation uses the bundled Draft 2020-12 meta-schemas; instance validation takes the relative-`$schema` direct-read branch; the cache directory passed to `validate_file` is an in-memory `mem_fs_path` child that the code path never touches.
- No temporary files: in-memory negative cases (`test_missing_schema_returns_missing_message`, `test_non_object_root_is_rejected`) write only into the patched in-memory path store.
- Substring assertions target stable parts of `Draft202012Validator` diagnostics (`is a required property`, `is not of type`, `is not one of`, `does not match`, `Additional properties are not allowed`), resilient to message-detail drift.
- Typing is clean under Pyright strict mode; the untyped `jsonschema` import is isolated behind a single `Any`-typed adapter (`_check_schema`) with the pre-authorized `import-untyped` suppression, keeping Unknown types out of test bodies.

## 7. Test Design Observations

- `_collect_reference_fields` recursively enforces the shared identifier grammar on every `*_id`/`*_ids`/`*_ref`/`*_refs` property, including nested array-item properties, with `source_refs` as the single documented locator exception (`test_v1_schema_documents.py` lines 56–58) — this matches the spec's explicit statement that `source_refs` holds locators, not cross-reference identifiers.
- The governed-discovery test asserts both inclusion of all seven conforming fixtures and exclusion of all seven non-conforming fixtures, directly covering the seeded governed-glob condition.

## Findings

| # | Classification | Finding |
|---|---|---|
| CR-1 | Non-Blocking | The `timestamp` `$def` is duplicated into all seven schemas but is unreferenced in four of them (`feature-contract`, `runtime-characterization-scenario`, `unspecified-behavior-record`, and `evidence-reference` uses it; `feature-contract`, `runtime-characterization-scenario`, `unspecified-behavior-record` do not declare timestamp fields). This is a deliberate uniformity choice under the self-containment rule and is valid Draft 2020-12; a future minor revision could drop unused `$defs` entries per schema. No action required. |
| CR-2 | Non-Blocking | `parity-matrix.schema.json` exposes a free-form top-level `summary` object (line 102–105) in addition to `metadata`, so this schema has two unconstrained extension points. This matches the spec's Per-Schema Field Design (section 5 lists optional top-level `summary`), so it is spec-conformant; if downstream reports (#9010) need deterministic summary keys, a constrained `summary` shape would be an additive v1 minor change. No action required. |

## Code Review Result

- Blocking findings: **0**
- Non-Blocking findings: **2** (CR-1, CR-2; both informational, no action required)
- Code review verdict: **PASS**
