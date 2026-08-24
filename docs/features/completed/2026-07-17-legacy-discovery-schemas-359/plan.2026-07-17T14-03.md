# legacy-discovery-schemas — Plan

- **Issue:** #359
- **Parent:** epic legacy-discovery-and-parity (child feature #9002, C3, Wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-03
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Required References

- Repository tone/policy: `.github/copilot-instructions.md`
- General code change: `.github/instructions/general-code-change.instructions.md` (mirror: `.claude/rules/general-code-change.md`)
- General unit test: `.github/instructions/general-unit-test.instructions.md` (mirror: `.claude/rules/general-unit-test.md`)
- Python code change: `.github/instructions/python-code-change.instructions.md` (mirror: `.claude/rules/python.md`)
- Python unit test: `.github/instructions/python-unit-test.instructions.md`
- Quality tiers: `.claude/rules/quality-tiers.md`
- Authoritative design source: `spec.md` (this feature folder)
- Requirements sources: `spec.md` and `user-story.md`
- Research: `research/research.2026-07-17.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Summary

This feature ships three deliverables and no new production Python:

1. Seven versioned JSON Schema documents at repo-root `schemas/discovery/v1/` (Draft 2020-12, self-contained `$defs`, no cross-file `$ref`, `$id` identifier-only, domain-neutral fields, regex timestamp patterns, top-level `additionalProperties: false`).
2. The schema-versioning convention embodied by those files (the `vN/` layout, in-schema `version`, instance-level `schema_version` pattern `^1\.\d+\.\d+$`, `$schema`/`$id` strategy); the convention prose is authoritative in `spec.md`.
3. Conforming fixtures at `examples/discovery/v1/<artifact>.example.json` (governed) and non-conforming fixtures at `tests/fixtures/discovery_schemas/v1/<artifact>.invalid.json` (intentionally ungoverned), exercised by tests under `tests/schemas/discovery/`.

Out of scope (do not plan or implement): deterministic per-artifact validators (#9003) and the domain-profile configuration contract (#9001). No change to `scripts/dev_tools/validate_json.py` or `scripts/dev_tools/json_config.py`.

## Evidence Location Invariant

All evidence artifacts for this feature MUST be written under the canonical scheme
`docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/<kind>/`.
Non-canonical `artifacts/`-rooted evidence paths (for example `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`) are prohibited and must be rejected and substituted. `<ts>` in artifact filenames denotes the ISO-8601 `yyyy-MM-ddTHH-mm` stamp recorded at execution time.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture and Policy Compliance

- [x] [P0-T1] Read the policy files in the required order (`.github/copilot-instructions.md`; `.github/instructions/general-code-change.instructions.md`; `.github/instructions/general-unit-test.instructions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`) and record the read in a Phase 0 policy-read artifact.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/other/phase0-instructions-read.<ts>.md` exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read.
- [x] [P0-T2] Capture the Black formatting baseline by running `poetry run black --check .` and recording the result.
  - Command: `poetry run black --check .`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-black.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (files-would-reformat count).
- [x] [P0-T3] Capture the Ruff lint baseline by running `poetry run ruff check .` and recording the result.
  - Command: `poetry run ruff check .`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-ruff.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error count).
- [x] [P0-T4] Capture the Pyright type-check baseline by running `poetry run pyright` and recording the result.
  - Command: `poetry run pyright`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-pyright.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning count).
- [x] [P0-T5] Capture the Pytest coverage baseline by running the coverage-enabled suite and recording numeric coverage.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-pytest-coverage.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the numeric baseline headline (passed count, line coverage percent, branch coverage percent).
- [x] [P0-T6] Capture the JSON governance baseline by running `poetry run dev.validate-json` and recording the result.
  - Command: `poetry run dev.validate-json`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-validate-json.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (governed-file count and pass/fail signal for the pre-change governed set).

### Phase 1 — Schema Authoring (schemas/discovery/v1/)

- [x] [P1-T1] Create the directory `schemas/discovery/v1/` and author `schemas/discovery/v1/evidence-reference.schema.json` (the shared leaf) with required `id`, `kind` (enum `file | log | trace | test_run | screenshot | recording | document | dataset | url | other`), `location`, `captured_at` (timestamp regex), `description`; optional `content_hash` (`{algorithm, value}`), `tool`, `metadata`.
  - Acceptance: file declares `$schema: "https://json-schema.org/draft/2020-12/schema"`, `$id: "schemas/discovery/v1/evidence-reference.schema.json"`, `version: "1.0.0"`, `title`, `description`; top-level `type: object`, `additionalProperties: false`; requires `$schema`, `schema_version` (pattern `^1\.\d+\.\d+$`), and `id`; `captured_at` uses the ISO-8601 regex `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$`; the shared id grammar `^[a-z0-9][a-z0-9._-]*$` is duplicated in `$defs`; no cross-file `$ref`.
- [x] [P1-T2] Author `schemas/discovery/v1/feature-contract.schema.json` with required `id`, `title`, `description`, `status` (enum `draft | reviewed | approved | deprecated`), `acceptance_criteria` (array `minItems: 1` of `{id, statement, verification: enum(manual | automated | characterization)}`); optional `workflows` (`{id, name, steps: [string]}`), `source_refs` (`{path, symbol?, line_start?, line_end?}`), `depends_on` (Feature Contract id values), `evidence_refs`, `tags`, `metadata`.
  - Acceptance: file carries the versioning keywords and top-level shape from P1-T1; every `*_id`/`*_ids`/`*_ref`/`*_refs` field uses the shared id pattern from `$defs`; no cross-file `$ref`; no domain-specific vocabulary.
- [x] [P1-T3] Author `schemas/discovery/v1/coverage-ledger.schema.json` with required `id`, `generated_at` (timestamp regex), `subject`, `entries` (array of `{unit_id, unit_kind: enum(module | namespace | type | file | component | other), status: enum(not_started | in_discovery | contracted | characterized | excluded), feature_ids?}`), `summary` (`{total_units: integer >= 0, covered_units: integer >= 0}`); optional per-entry `evidence_refs`, `notes`; optional top-level `metadata`.
  - Acceptance: file carries the versioning keywords and top-level shape from P1-T1; integer bounds `minimum: 0` on `total_units`/`covered_units`; reference fields use the shared id pattern; no cross-file `$ref`; no domain-specific vocabulary.
- [x] [P1-T4] Author `schemas/discovery/v1/runtime-characterization-scenario.schema.json` with required `id`, `feature_id`, `title`, `preconditions` (array of strings), `stimulus` (`{description, inputs?}`), `observed_behavior` (`{description, outputs?}`), `observation_method` (enum `log | trace | debugger | instrumented | manual | other`), `evidence_refs` (`minItems: 1`); optional `determinism` (enum `deterministic | nondeterministic | unknown`), `variations` (array of `{description, observed_behavior}`), `metadata`.
  - Acceptance: file carries the versioning keywords and top-level shape from P1-T1; `evidence_refs` has `minItems: 1`; reference fields use the shared id pattern; no cross-file `$ref`; no domain-specific vocabulary.
- [x] [P1-T5] Author `schemas/discovery/v1/parity-matrix.schema.json` with required `id`, `generated_at` (timestamp regex), `source_label`, `target_label`, `rows` (array of `{feature_id, parity_status: enum(not_started | in_progress | behavioral_parity | intentional_divergence | deferred | out_of_scope), verification: enum(none | manual | automated)}`); optional per-row `criterion_id`, `evidence_refs`, `decision_refs`, `notes`; optional top-level `summary`, `metadata`.
  - Acceptance: file carries the versioning keywords and top-level shape from P1-T1; reference fields use the shared id pattern; `source_label`/`target_label` are generic strings with no domain vocabulary; no cross-file `$ref`.
- [x] [P1-T6] Author `schemas/discovery/v1/unspecified-behavior-record.schema.json` with required `id`, `title`, `description`, `category` (enum `undocumented | contradictory | ambiguous | environment_dependent`), `discovery_context`, `resolution_status` (enum `open | under_review | resolved`), `evidence_refs` (`minItems: 1`); optional `feature_id`, `decision_ref`, `metadata`.
  - Acceptance: file carries the versioning keywords and top-level shape from P1-T1; `evidence_refs` has `minItems: 1`; reference fields use the shared id pattern; no cross-file `$ref`; no domain-specific vocabulary.
- [x] [P1-T7] Author `schemas/discovery/v1/product-decision-record.schema.json` with required `id`, `title`, `decision`, `status` (enum `proposed | accepted | superseded | rejected`), `rationale`; optional `decided_at` (timestamp regex), `alternatives` (array of `{description, reason_rejected}`), `feature_ids`, `behavior_record_ids`, `evidence_refs`, `superseded_by`, `metadata`.
  - Acceptance: file carries the versioning keywords and top-level shape from P1-T1; reference fields use the shared id pattern; no cross-file `$ref`; no domain-specific vocabulary.
- [x] [P1-T8] Verify the seven schema files are domain-neutral and self-contained by searching the tree for prohibited vocabulary and cross-file references.
  - Command: `rg -i "taskmaster|tmw|outlook|vsto|email|task-management" schemas/discovery/v1/` (expect zero matches) and a `$ref` scan confirming every `$ref` begins with `#/`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/schema-neutrality-check.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` showing zero prohibited-term matches and no non-local `$ref`.

### Phase 2 — Conforming Fixtures (examples/discovery/v1/)

- [x] [P2-T1] Author `examples/discovery/v1/evidence-reference.example.json` exercising all required fields plus `content_hash` and `tool`, with alphabetically sorted keys and `"$schema": "../../../schemas/discovery/v1/evidence-reference.schema.json"` (three ascents).
  - Acceptance: keys are alphabetically sorted (no jq `--sort-keys` churn); `schema_version` matches `^1\.\d+\.\d+$`; the relative `$schema` resolves to the schema file without touching cache or network.
- [x] [P2-T2] Author `examples/discovery/v1/feature-contract.example.json` exercising all required fields plus `workflows`, `source_refs`, and `evidence_refs`, with sorted keys and the three-ascent relative `$schema`.
  - Acceptance: sorted keys; `schema_version` matches the v1 pattern; `acceptance_criteria` has at least one item; cross-reference fields are plain string identifiers matching the shared id pattern.
- [x] [P2-T3] Author `examples/discovery/v1/coverage-ledger.example.json` exercising required fields plus per-entry `evidence_refs` and `notes`, with sorted keys and the three-ascent relative `$schema`.
  - Acceptance: sorted keys; `summary.total_units` and `summary.covered_units` are integers `>= 0`; `feature_ids` are plain string identifiers.
- [x] [P2-T4] Author `examples/discovery/v1/runtime-characterization-scenario.example.json` exercising required fields plus `determinism` and `variations`, with sorted keys and the three-ascent relative `$schema`.
  - Acceptance: sorted keys; `evidence_refs` has at least one item; `observation_method` is a valid enum value.
- [x] [P2-T5] Author `examples/discovery/v1/parity-matrix.example.json` exercising required fields plus row optionals and top-level `summary`, with sorted keys and the three-ascent relative `$schema`.
  - Acceptance: sorted keys; every row has `feature_id`, `parity_status`, and `verification` with valid enum values; `source_label`/`target_label` are generic.
- [x] [P2-T6] Author `examples/discovery/v1/unspecified-behavior-record.example.json` exercising required fields plus `feature_id` and `decision_ref`, with sorted keys and the three-ascent relative `$schema`.
  - Acceptance: sorted keys; `evidence_refs` has at least one item; `category` and `resolution_status` are valid enum values.
- [x] [P2-T7] Author `examples/discovery/v1/product-decision-record.example.json` exercising required fields plus `alternatives` and `superseded_by`, with sorted keys and the three-ascent relative `$schema`.
  - Acceptance: sorted keys; `status` is a valid enum value; reference fields are plain string identifiers.

### Phase 3 — Non-Conforming Fixtures (tests/fixtures/discovery_schemas/v1/)

- [x] [P3-T1] Author `tests/fixtures/discovery_schemas/v1/feature-contract.invalid.json` that omits the required `acceptance_criteria` property, declaring `"$schema": "../../../../schemas/discovery/v1/feature-contract.schema.json"` (four ascents).
  - Acceptance: the fixture is otherwise well-formed; expected `Draft202012Validator` signal contains `is a required property`; the file is outside the governed globs.
- [x] [P3-T2] Author `tests/fixtures/discovery_schemas/v1/coverage-ledger.invalid.json` with a wrong-type violation (`summary.total_units` is a string), declaring the four-ascent relative `$schema`.
  - Acceptance: expected signal is a type mismatch at the nested `summary.total_units` path; the file is outside the governed globs.
- [x] [P3-T3] Author `tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json` with an enum violation (`observation_method: "guesswork"`), declaring the four-ascent relative `$schema`.
  - Acceptance: expected signal contains `is not one of`; the file is outside the governed globs.
- [x] [P3-T4] Author `tests/fixtures/discovery_schemas/v1/parity-matrix.invalid.json` with an array-item violation (one `rows` item lacks `parity_status`), declaring the four-ascent relative `$schema`.
  - Acceptance: expected signal is a required-property error at a `rows[...]` index; the file is outside the governed globs.
- [x] [P3-T5] Author `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json` with a pattern violation (`id: "Behavior Record #1"` — uppercase and spaces), declaring the four-ascent relative `$schema`.
  - Acceptance: expected signal contains `does not match`; the file is outside the governed globs.
- [x] [P3-T6] Author `tests/fixtures/discovery_schemas/v1/product-decision-record.invalid.json` with an `additionalProperties: false` violation (unknown top-level key such as `approved_by_manager`), declaring the four-ascent relative `$schema`.
  - Acceptance: expected signal contains `Additional properties are not allowed`; the file is outside the governed globs.
- [x] [P3-T7] Author `tests/fixtures/discovery_schemas/v1/evidence-reference.invalid.json` with a `schema_version` major mismatch (`"2.0.0"` against the v1 pattern), declaring the four-ascent relative `$schema`.
  - Acceptance: expected signal is a pattern failure on `schema_version`; the file is outside the governed globs.

### Phase 4 — Tests (tests/schemas/discovery/)

- [x] [P4-T1] Create `tests/schemas/discovery/test_v1_schema_documents.py` with a `pytest.mark.parametrize` case over the seven schema files that `json.loads` each and calls `Draft202012Validator.check_schema(schema)` offline.
  - Acceptance: repo-root resolved via `Path(__file__).resolve().parents[N]` (not CWD); all seven parametrized cases pass; no network I/O and no cache writes.
- [x] [P4-T2] Add convention-assertion tests to `tests/schemas/discovery/test_v1_schema_documents.py` verifying, per schema file: `$schema` equals the Draft 2020-12 URI; `$id` equals the repo-relative path of the file; `version` major equals `1`; `title` and `description` present; top-level `additionalProperties` is `false`; `schema_version` is required with the `^1\.\d+\.\d+$` pattern; every `*_id`/`*_ids`/`*_ref`/`*_refs` field uses the shared id pattern.
  - Acceptance: parametrized assertions pass for all seven schema files; the "version field mismatch" and "missing `$schema`" convention conditions are asserted at the schema-document level.
- [x] [P4-T3] Create `tests/schemas/discovery/test_v1_fixtures.py` with a parametrized positive-conformance test that calls `validate_file(<repo>/examples/discovery/v1/<name>.example.json, cache_dir)` for each conforming fixture and asserts `ok is True`.
  - Acceptance: `cache_dir` is an in-memory path (for example `mem_fs_path / "cache"`) that the relative-`$schema` branch never touches; all seven positive cases pass; no disk writes.
- [x] [P4-T4] Add a parametrized negative-conformance test to `tests/schemas/discovery/test_v1_fixtures.py` that calls `validate_file` on each `tests/fixtures/discovery_schemas/v1/<name>.invalid.json` and asserts `ok is False` and that `msg` contains the expected violation substring from the Fixture Design table.
  - Acceptance: all seven negative cases assert the correct distinct-violation substring (`is a required property`, nested type mismatch, `is not one of`, `rows` required-property error, `does not match`, `Additional properties are not allowed`, `schema_version` pattern failure) on the `jsonschema` path.
- [x] [P4-T5] Add a governed-discovery test to `tests/schemas/discovery/test_v1_fixtures.py` asserting that `iter_governed_files(repo_root)` includes every conforming fixture path under `examples/discovery/v1/` and excludes every non-conforming fixture path under `tests/fixtures/discovery_schemas/v1/`.
  - Acceptance: the test passes; it directly covers the "governed-glob discovery" seeded condition.
- [x] [P4-T6] Add `missing $schema` and non-object-root negative tests to `tests/schemas/discovery/test_v1_fixtures.py`, driven through `validate_file` (using committed fixtures or in-memory `mem_fs_path` cases per house style).
  - Acceptance: the `missing $schema` case returns the `missing $schema` message; the non-object-root case is rejected; both tests pass and cover the seeded versioning-convention edge cases.

### Phase 5 — Final QA Loop and Coverage Verification

- [x] [P5-T1] Run Black formatting and record the result. If files are reformatted, restart the toolchain loop from this task.
  - Command: `poetry run black .`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-black.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; final recorded run reports no files reformatted. This task is unconditional.
- [x] [P5-T2] Run Ruff linting and record the result. If Ruff fails or auto-fixes files, remediate and restart the loop from P5-T1.
  - Command: `poetry run ruff check .`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-ruff.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; final recorded run reports zero errors. This task is unconditional.
- [x] [P5-T3] Run Pyright type checking and record the result. If Pyright fails, remediate and restart the loop from P5-T1.
  - Command: `poetry run pyright`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-pyright.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; final recorded run reports zero errors. This task is unconditional.
- [x] [P5-T4] Run the coverage-enabled Pytest suite and record numeric post-change coverage. If tests fail or any prior stage changed files, remediate and restart the loop from P5-T1.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-pytest-coverage.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric post-change line and branch coverage percentages and the passed-test count. This task is unconditional.
- [x] [P5-T5] Run the JSON governance check and record the result. If it fails, remediate and restart the loop from P5-T1.
  - Command: `poetry run dev.validate-json`
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-validate-json.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` confirming the seven conforming fixtures under `examples/discovery/v1/` are discovered and validate cleanly (exit 0). This task is unconditional.
- [x] [P5-T6] Verify the coverage threshold and no-regression contract by comparing baseline coverage (P0-T5) with post-change coverage (P5-T4) and the new/changed-code coverage.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/coverage-delta.<ts>.md` records baseline line/branch coverage, post-change line/branch coverage, and new/changed-code coverage; confirms line coverage `>= 85%` and branch coverage `>= 75%` and no regression on changed lines. If any required coverage value is unavailable, the outcome is remediation-required and MUST NOT be reported as PASS.

## Acceptance Criteria Mapping

| Source AC | Plan tasks |
|---|---|
| spec.md: seven schemas at `schemas/discovery/v1/` | P1-T1..P1-T7, P4-T1 |
| spec.md: versioning convention embodied (`vN/` layout, `version` major==N, `schema_version` pattern, `$schema`/`$id` strategy) | P1-T1..P1-T7, P4-T2, P4-T6 |
| spec.md: no cross-file `$ref` / self-contained `$defs` | P1-T1..P1-T8 |
| spec.md: `type: object`, top-level `additionalProperties: false` + `metadata`; domain-neutral | P1-T1..P1-T8, P4-T2 |
| spec.md: cross-references are plain string ids; timestamps use regex not `format` | P1-T1..P1-T7, P4-T2 |
| spec.md: schema files intentionally ungoverned (no meta-schema fetch / no `.cache/` dirt) | P1-T1..P1-T7, P4-T1, P5-T5 |
| spec.md/user-story: conforming + non-conforming fixture per schema | P2-T1..P2-T7, P3-T1..P3-T7 |
| spec.md: conforming fixtures governed, sorted keys, validate cleanly | P2-T1..P2-T7, P4-T3, P4-T5, P5-T5 |
| spec.md: non-conforming fixtures ungoverned, asserted via `validate_file` | P3-T1..P3-T7, P4-T4, P4-T5 |
| spec.md: each non-conforming fixture is a distinct violation class | P3-T1..P3-T7, P4-T4 |
| spec.md: instance `$schema` scheme-less relative paths (3/4 ascents), no cache/network | P2-T1..P2-T7, P3-T1..P3-T7, P4-T3 |
| spec.md/user-story: no new production Python; no change to `validate_json.py`/`json_config.py`; tests drive `check_schema` and `validate_file` | P4-T1..P4-T6, P5-T3, P5-T4 |
| spec.md/user-story: tests satisfy quality-tier policy (line >= 85%, branch >= 75%), deterministic and offline | P0-T5, P4-T1..P4-T6, P5-T4, P5-T6 |
| user-story: additive minor non-breaking; cross-major mismatch rejected | P1-T1..P1-T7, P3-T7, P4-T2, P4-T4 |
| spec.md seeded: each schema validates conforming, rejects non-conforming | P2-*, P3-*, P4-T3, P4-T4 |
| spec.md seeded: governed-glob discovery includes conforming, excludes non-conforming | P4-T5 |
| spec.md seeded: versioning edge cases (`schema_version` major mismatch, missing `$schema`) | P3-T7, P4-T2, P4-T6 |

## Test Plan

- Unit (schema documents): parametrized `Draft202012Validator.check_schema` over the seven schema files plus convention assertions (`tests/schemas/discovery/test_v1_schema_documents.py`).
- Unit (fixtures): parametrized positive conformance for the seven `examples/discovery/v1/` fixtures and parametrized negative conformance for the seven `tests/fixtures/discovery_schemas/v1/` fixtures, plus `missing $schema` and non-object-root negatives (`tests/schemas/discovery/test_v1_fixtures.py`).
- Governed discovery: `iter_governed_files` inclusion/exclusion assertions.
- Integration/CLI: `poetry run dev.validate-json` confirms the seven conforming fixtures validate cleanly and the JSON gate stays green.
- Coverage evidence:
  - Baseline: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/baseline/baseline-pytest-coverage.<ts>.md`
  - Post-change: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/qa-pytest-coverage.<ts>.md`
  - Comparison: `docs/features/active/2026-07-17-legacy-discovery-schemas-359/evidence/qa-gates/coverage-delta.<ts>.md`

## Open Questions / Notes

- No new production Python is added; coverage thresholds are computed over existing production code, and the new tests exercise existing `validate_json.py` paths (`validate_file`, `iter_governed_files`), which may increase measured coverage but must not reduce it.
- The enum/pattern/`additionalProperties`/type negatives are enforced only on the real `jsonschema` path (a dev-group dependency present under pytest); the built-in fallback validator is a degraded mode and is not the contract.
- All fixture and schema references are scheme-less relative paths; validation is fully offline and produces no `.cache/` writes.
