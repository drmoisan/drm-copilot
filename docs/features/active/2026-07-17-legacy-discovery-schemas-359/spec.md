# legacy-discovery-schemas — Spec

- **Issue:** #359
- **Parent (optional):** epic legacy-discovery-and-parity (child feature #9002, C3, Wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Overview

The legacy-discovery-and-parity epic requires machine-readable artifact shapes that every
downstream feature (validators #9003, reports #9010, init/templates #9005, the analyzer
framework #9006, acceptance-scenario generation #9009) and every external consumer repository
(`drmoisan/TaskMaster` as legacy source, `drmoisan/TMW` as modern target) consumes. Today the
repository has no domain/business JSON Schema files (only permissive `.vscode/schemas/*.schema.json`
editor stubs) and no schema-versioning convention. Downstream features cannot produce or validate
discovery artifacts without a stable, versioned, domain-neutral schema contract and a documented
versioning layout.

This feature is the shared contract every downstream epic feature consumes. It owns three things
and nothing more:

1. Seven versioned JSON schemas for the discovery artifact family.
2. The repository's schema-versioning convention (none exists today; this feature defines it).
3. Conforming and non-conforming example fixtures per schema.

Out of scope: the deterministic validators (feature #9003) and the domain-profile configuration
contract (feature #9001). This feature adds no production Python; it ships schema documents, JSON
fixtures, tests, and this specification.

## Schema-Versioning Convention (shared contract)

This section is the authoritative statement of the repository's schema-versioning convention. Every
schema consumer in the epic reuses it verbatim.

### 1. Directory layout

Schemas live at the repository root under `schemas/<family>/v<N>/<artifact>.schema.json`. This
feature creates the family `discovery` at major version `v1`:

```
schemas/discovery/v1/feature-contract.schema.json
schemas/discovery/v1/coverage-ledger.schema.json
schemas/discovery/v1/runtime-characterization-scenario.schema.json
schemas/discovery/v1/parity-matrix.schema.json
schemas/discovery/v1/unspecified-behavior-record.schema.json
schemas/discovery/v1/product-decision-record.schema.json
schemas/discovery/v1/evidence-reference.schema.json
```

`v<N>` is the **major** version. A breaking change creates a sibling `v2/` tree; a published `vN/`
tree is immutable for consumed schemas except for additive (minor/patch) changes. The `<family>`
segment generalizes the convention so future, unrelated schema families do not share one version
counter.

### 2. In-schema version fields

Each schema document declares:

- `$schema`: exactly `"https://json-schema.org/draft/2020-12/schema"`. This matches the
  `Draft202012Validator` used by `scripts/dev_tools/validate_json.py`. It is a meta-schema
  self-reference and is asserted offline in tests via `Draft202012Validator.check_schema`
  (see Testing Approach); it is never fetched at validation time because schema files are placed
  outside the governed globs (see File Placement).
- `$id`: the repository-root-relative path string of the schema file, for example
  `"schemas/discovery/v1/feature-contract.schema.json"`. The `$id` is an **identifier only and is
  never dereferenced**. No external domain is used, consistent with the repo-local-`$id` posture in
  `.claude/rules/orchestrator-state.md`. `validate_json.py` never resolves `$id`.
- `version`: a full semantic-version annotation string, for example `"1.0.0"`, whose **major
  component MUST equal the directory `N`**. Unknown keywords are valid Draft 2020-12 annotations.
- `title` and `description`: required documentation keywords.

### 3. Instance-level `schema_version` field

Every instance document carries a required `schema_version` string constrained by
`"pattern": "^1\\.\\d+\\.\\d+$"` (major pinned to the directory `N`; minor and patch free).

Rationale: a `const` pin would break every existing instance on an additive minor bump. Pinning
only the major component keeps additive evolution non-breaking while still making a cross-major
mismatch (for example `"2.0.0"` validated against a v1 schema) a schema-level rejection. This
directly implements the seeded "version field mismatch" test condition. Exact-version equality
checks are feature #9003 territory, not this feature.

### 4. Instance-level `$schema` self-reference

Every instance document (fixtures included) declares `$schema` as a **scheme-less relative path**
from the instance file to its schema file. Absolute Windows paths are prohibited: `urlparse("C:/...")`
parses the drive letter as a URI scheme and `validate_json.py`'s `_load_schema` rejects it. The
relative-path branch of `_load_schema` resolves the reference via `(base_path.parent / uri).resolve()`;
`..` segments and forward slashes work under `pathlib` on Windows. This branch reads the schema file
directly and touches neither the schema cache nor the network. Exact reference values are specified
under File Placement.

### 5. No cross-file `$ref`; self-contained `$defs`

Each schema file is fully self-contained. Internal reuse goes through `#/$defs/...` only. Cross-file
`$ref` (a `$ref` to another schema file) is prohibited. Reason: `validate_json.py`'s `_load_schema`
returns a single schema dict, and `Draft202012Validator` is constructed without a registry that maps
file paths to schemas, so an external-file `$ref` would fail at validation time. The shared identifier
grammar and any shared sub-shapes are therefore duplicated into each schema's `$defs` block.

## File Placement

| Artifact | Location | Governed by `validate_json.py`? |
|---|---|---|
| Schema files (7) | `schemas/discovery/v1/<artifact>.schema.json` | No (by design) |
| Conforming fixtures (7) | `examples/discovery/v1/<artifact>.example.json` | Yes (`examples/**/*.json`) |
| Non-conforming fixtures (7+) | `tests/fixtures/discovery_schemas/v1/<artifact>.invalid.json` | No (by design) |

### Schema files are intentionally ungoverned

Schema files are placed at the repository root under `schemas/`, which is **outside** the governed
globs in `scripts/dev_tools/json_config.py` (`scripts/**/*.json`, `docs/**/*.json`,
`examples/**/*.json`). This is deliberate. If a schema file were governed, `validate_json.py` would
treat it as an instance, read its `$schema` (`https://json-schema.org/draft/2020-12/schema`), and
take the `http(s)` branch of `_load_schema`, producing a first-run network fetch of the remote
Draft 2020-12 meta-schema and an untracked `.cache/schemas/<sha256>.json` file (`.cache/` is not
gitignored). Keeping schema files ungoverned avoids both effects. Meta-schema conformance of the
seven schema documents is asserted offline in this feature's tests instead (see Testing Approach).

### Conforming fixtures are governed

Conforming fixtures are placed under `examples/discovery/v1/`, which the existing `examples/**/*.json`
glob already covers. The `examples/` directory does not exist today; creating it activates governance
with zero machinery change. These fixtures are the canonical worked examples of each artifact shape,
and `dev.validate-json` discovers and validates them by default.

Formatting note: files under governed globs are subject to `format_json.py` / the "JSON: format" task
running jq `--sort-keys`. Conforming fixtures must be authored with alphabetically sorted keys to
avoid formatter churn.

### Non-conforming fixtures are intentionally ungoverned

Non-conforming fixtures are placed under `tests/fixtures/discovery_schemas/v1/`, which is **not**
governed (`tests/**` is outside the globs). This is deliberate and is the structural correction to
the issue's early-draft acceptance criterion. A governed non-conforming fixture would fail validation
by definition and would make `dev.validate-json` exit non-zero permanently. Additionally, the "missing
`$schema`" negative is structurally impossible under governance, because every governed file must
declare `$schema` (`validate_json.py` line 199). Non-conforming fixtures are exercised by this
feature's tests, which drive `validate_json.py`'s `validate_file` directly and assert rejection. This
placement follows repository precedent for committed negative fixtures (for example
`tests/fixtures/minor_audit_mode/`, `tests/fixtures/atomic_executor/`).

### Exact `$schema` reference values

- Conforming fixture `examples/discovery/v1/feature-contract.example.json` declares
  `"$schema": "../../../schemas/discovery/v1/feature-contract.schema.json"` (three ascents:
  `v1` → `discovery` → `examples` → repo root), and the analogous value for each of the other six
  artifacts.
- Non-conforming fixture `tests/fixtures/discovery_schemas/v1/feature-contract.invalid.json` declares
  `"$schema": "../../../../schemas/discovery/v1/feature-contract.schema.json"` (four ascents), and
  the analogous value for each of the other artifacts.

Both forms are scheme-less relative paths compatible with `_load_schema`, resolved against the
instance file's parent directory. Neither touches the schema cache or the network.

## Per-Schema Field Design

Suite-wide conventions (apply to all seven schemas):

- Field naming is `snake_case`, matching the orchestrator-state artifact convention.
- Every schema is `"type": "object"` with `"additionalProperties": false` at the top level for a
  deterministic shape, plus a single optional free-form `metadata` object (`"type": "object"`,
  additional properties allowed) as the sanctioned extension point for consumer repositories.
- Every instance requires `$schema` (string), `schema_version` (string, pattern `^1\.\d+\.\d+$`),
  and `id`.
- The shared identifier grammar is `"pattern": "^[a-z0-9][a-z0-9._-]*$"`, applied to every `id`
  value and every reference field. It is duplicated into each schema's `$defs` (self-containment
  rule).
- Cross-references between schemas are **plain string identifiers, never JSON Schema `$ref`**.
  `evidence_refs` arrays carry Evidence Reference `id` values; `feature_id`/`feature_ids` carry
  Feature Contract `id` values; `decision_ref`/`decision_refs` carry Product Decision Record `id`
  values; `behavior_record_ids` carry Unspecified Behavior Record `id` values. Referential integrity
  (whether the referenced artifact exists) is intentionally not expressible in JSON Schema and is
  deferred to the #9003 validators.
- Timestamps are `"type": "string"` with an explicit ISO-8601 regex, for example
  `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$`. `format: "date-time"` is not
  used for enforcement: `validate_json.py` constructs `Draft202012Validator` without a
  `FormatChecker`, so `format` is annotation-only and would not reject bad values. Patterns are
  required for enforced timestamp shapes.

Domain-neutrality invariant (hard epic invariant): no schema field, enum value, or description may
name a TaskMaster, TMW, Outlook, VSTO, email, or task-management concept. Vocabulary is strictly
generic legacy-discovery language. Real source/target names are supplied at runtime by the
domain-profile configuration (#9001), never encoded in a schema.

### 1. Evidence Reference (`evidence-reference.schema.json`)

The shared leaf that all other artifacts point at.

- Required: `id`; `kind` (enum: `file | log | trace | test_run | screenshot | recording | document | dataset | url | other`);
  `location` (string; a path or URI expressed in the consumer repository's own terms);
  `captured_at` (timestamp); `description`.
- Optional: `content_hash` (`{algorithm, value}`); `tool` (string); `metadata`.

### 2. Feature Contract (`feature-contract.schema.json`)

The contracted behavior of one legacy feature or workflow; the hub identifier space of the suite.

- Required: `id`; `title`; `description`; `status` (enum: `draft | reviewed | approved | deprecated`);
  `acceptance_criteria` (array, `minItems: 1`, of `{id, statement, verification: enum(manual | automated | characterization)}`).
- Optional: `workflows` (array of `{id, name, steps: [string]}`);
  `source_refs` (array of generic locators `{path, symbol?, line_start?, line_end?}`);
  `depends_on` (array of Feature Contract `id` values); `evidence_refs`; `tags`; `metadata`.

### 3. Coverage Ledger (`coverage-ledger.schema.json`)

Legacy implementation coverage of the discovery effort.

- Required: `id`; `generated_at` (timestamp); `subject` (string label for the covered corpus);
  `entries` (array of `{unit_id, unit_kind: enum(module | namespace | type | file | component | other), status: enum(not_started | in_discovery | contracted | characterized | excluded), feature_ids?}`);
  `summary` (`{total_units: integer >= 0, covered_units: integer >= 0}`).
- Optional (per entry): `evidence_refs`; `notes`. Optional (top level): `metadata`.

### 4. Runtime Characterization Scenario (`runtime-characterization-scenario.schema.json`)

One observed-behavior scenario.

- Required: `id`; `feature_id`; `title`; `preconditions` (array of strings);
  `stimulus` (`{description, inputs?}`); `observed_behavior` (`{description, outputs?}`);
  `observation_method` (enum: `log | trace | debugger | instrumented | manual | other`);
  `evidence_refs` (`minItems: 1` — a characterization without evidence is not a characterization).
- Optional: `determinism` (enum: `deterministic | nondeterministic | unknown`);
  `variations` (array of `{description, observed_behavior}`); `metadata`.

### 5. Parity Matrix (`parity-matrix.schema.json`)

Source-to-target parity status.

- Required: `id`; `generated_at` (timestamp); `source_label`; `target_label` (generic strings; the
  domain profile supplies real names at runtime);
  `rows` (array of `{feature_id, parity_status: enum(not_started | in_progress | behavioral_parity | intentional_divergence | deferred | out_of_scope), verification: enum(none | manual | automated)}`).
- Optional (per row): `criterion_id` (an acceptance-criterion id within the referenced Feature
  Contract); `evidence_refs`; `decision_refs`; `notes`. Optional (top level): `summary`; `metadata`.

### 6. Unspecified Behavior Record (`unspecified-behavior-record.schema.json`)

Undocumented, contradictory, or ambiguous behavior.

- Required: `id`; `title`; `description`;
  `category` (enum: `undocumented | contradictory | ambiguous | environment_dependent`);
  `discovery_context` (string); `resolution_status` (enum: `open | under_review | resolved`);
  `evidence_refs` (`minItems: 1`).
- Optional: `feature_id` (behavior may predate a contract); `decision_ref` (the resolving Product
  Decision Record `id`); `metadata`. The cross-field rule "resolved implies `decision_ref` present"
  is a semantic left to #9003.

### 7. Product Decision Record (`product-decision-record.schema.json`)

A reconciled product decision.

- Required: `id`; `title`; `decision` (string); `status` (enum: `proposed | accepted | superseded | rejected`);
  `rationale` (string).
- Optional: `decided_at` (timestamp); `alternatives` (array of `{description, reason_rejected}`);
  `feature_ids`; `behavior_record_ids`; `evidence_refs`; `superseded_by` (Product Decision Record
  `id`); `metadata`.

### Reference topology

Evidence Reference is the shared leaf (referenced by Feature Contract, Coverage Ledger entries,
Characterization Scenarios, Parity Matrix rows, Unspecified Behavior Records, and Product Decision
Records). Feature Contract is the hub identifier space (`feature_id`/`feature_ids` in Scenarios,
Ledger entries, Matrix rows, and Decision Records). Product Decision Record closes the loop from
Unspecified Behavior Records (`decision_ref`) and Parity Matrix divergences (`decision_refs`). All
links are plain string identifiers.

## Fixture Design

One conforming and one non-conforming fixture per schema. Each non-conforming fixture exercises a
distinct violation class so that downstream features (#9003 validators, #9010 reports) inherit a
varied negative corpus rather than seven copies of "missing required field".

| Schema | Conforming fixture exercises | Non-conforming fixture violation (distinct class) | Expected `Draft202012Validator` signal |
|---|---|---|---|
| Feature Contract | All required fields plus `workflows`, `source_refs`, `evidence_refs` | Missing required property (`acceptance_criteria` absent) | `'acceptance_criteria' is a required property` |
| Coverage Ledger | Required plus per-entry optionals | Wrong type (`summary.total_units` is a string) | type mismatch at the nested path |
| Runtime Characterization Scenario | Required plus `determinism`, `variations` | Enum violation (`observation_method: "guesswork"`) | `is not one of [...]` |
| Parity Matrix | Required plus row optionals plus `summary` | Array-item violation (one row lacks `parity_status`) | required-property error at `rows[1]` |
| Unspecified Behavior Record | Required plus `feature_id`, `decision_ref` | Pattern violation (`id: "Behavior Record #1"` — uppercase and spaces) | `does not match '^[a-z0-9]...'` |
| Product Decision Record | Required plus `alternatives`, `superseded_by` | `additionalProperties: false` violation (unknown top-level key) | `Additional properties are not allowed` |
| Evidence Reference | Required plus `content_hash`, `tool` | `schema_version` major mismatch (`"2.0.0"` against the v1 pattern) | pattern failure on `schema_version` |

Two additional negatives are test cases rather than committed governed files, because both are
handled by `validate_file` branches before schema evaluation: a fixture without `$schema` (returns
`missing $schema`) and a non-object root. These live under `tests/fixtures/discovery_schemas/v1/` or
as in-memory cases via the `mem_fs_path` fixture, matching existing test style.

Two authoring constraints: (1) conforming fixtures under `examples/` are subject to jq `--sort-keys`
formatting and must be authored with alphabetically sorted keys; (2) the enum/pattern/const/
`additionalProperties` negatives are rejected only when `jsonschema` is installed. Tests assert on
the real `jsonschema` path (a dev-group dependency, always present under pytest). The built-in
fallback validator is a degraded mode, not the contract.

## Testing Approach

No new production Python is added; the deterministic validators are feature #9003. There is no new
module, no `pyproject.toml` script, and no change to `validate_json.py` or `json_config.py`. Coverage
thresholds (line >= 85%, branch >= 75%) are computed over production code and are unaffected by adding
tests; the new tests exercise existing `validate_json.py` production paths. Tests rely on the dev-group
`jsonschema` dependency.

Test layout mirrors the artifact tree per the test-location policy:

- `tests/schemas/discovery/test_v1_schema_documents.py` — schema-document conformance:
  - Parametrized over the seven schema files: `json.loads` each, then
    `Draft202012Validator.check_schema(schema)`. This is offline; the `jsonschema`/`referencing`
    packages bundle the official Draft 2020-12 meta-schemas, so `check_schema` performs no network
    I/O. This is the meta-validation that placing schema files outside the governed globs would
    otherwise forgo.
  - Convention assertions: `$schema` equals the Draft 2020-12 URI; `$id` equals the repo-relative
    path of the file; `version` major equals the `v1` directory; `title` and `description` present;
    top-level `additionalProperties` is `false`; `schema_version` is required with the major-pinned
    pattern; every `*_id`/`*_ids`/`*_ref`/`*_refs` field uses the shared id pattern. These make the
    versioning convention machine-enforced rather than prose-only and cover the "version field
    mismatch" and "missing `$schema`" seeded edge cases at the convention level.
- `tests/schemas/discovery/test_v1_fixtures.py` — fixture conformance via the existing machinery:
  - Parametrized positive: `ok, msg = validate_file(<repo>/examples/discovery/v1/<name>.example.json, cache_dir)`;
    assert `ok is True`. `cache_dir` may be `mem_fs_path / "cache"`; the relative-`$schema` branch
    never touches it, so the test performs no disk writes. Reading committed repository files is not
    temporary-file usage (precedent: `tests/fixtures/**`).
  - Parametrized negative: `validate_file` on each
    `tests/fixtures/discovery_schemas/v1/<name>.invalid.json`; assert `ok is False` and that `msg`
    contains the expected violation signal from the Fixture Design table (substring assertions on the
    stable parts of the message, resilient to detail drift).
  - Governed-discovery test: `iter_governed_files(repo_root)` includes every conforming fixture path
    and none of the non-conforming ones, covering the restated "governed-glob discovery" condition.
  - `missing $schema` and non-object-root negatives driven through `validate_file`.
- Repo-root resolution inside tests uses `Path(__file__).resolve().parents[N]`, not the current
  working directory (existing precedent across `tests/scripts/dev_tools/`).

All tests are offline (relative `$schema` paths; `check_schema` uses bundled meta-schemas; no cache
writes), with no clocks and no randomness. The determinism-infrastructure rules impose no additional
machinery here.

## Constraints & Risks

- Domain neutrality is a hard epic invariant: no schema field, enum value, or description may name a
  domain concept (TaskMaster/TMW/Outlook/VSTO/email/task-management).
- Out of scope: deterministic validators (feature #9003) and the domain-profile configuration
  contract (feature #9001). This feature owns schema files, the versioning convention, and example
  fixtures only.
- Must reuse the existing `validate_json.py` machinery; no new schema-loading code.
- The instance `$schema` self-reference must be a scheme-less relative path compatible with
  `_load_schema`; absolute Windows paths are prohibited.
- Cross-file `$ref` is unresolvable under `validate_json.py`'s single-dict loading; schemas must be
  self-contained via `#/$defs`.
- Non-conforming fixtures must be placed outside the governed globs; a governed failing fixture would
  make `dev.validate-json` permanently non-zero.
- The enum/pattern/`additionalProperties` negatives require `jsonschema` at runtime; the built-in
  fallback validator does not enforce them and is a degraded mode.
- Cross-feature note (informational): epic scope item 10 requires schemas to be mirrored into
  `resources/` subtrees; that mirroring is owned by #9012 and does not constrain the primary placement
  chosen here. A single self-contained tree keeps that mirroring mechanical.

## Acceptance Criteria

- [x] Seven versioned JSON schemas exist at `schemas/discovery/v1/<artifact>.schema.json`, one per
      artifact (Feature Contract, Coverage Ledger, Runtime Characterization Scenario, Parity Matrix,
      Unspecified Behavior Record, Product Decision Record, Evidence Reference).
- [x] The schema-versioning convention is documented precisely in this spec as the shared contract:
      the `schemas/<family>/v<N>/<artifact>.schema.json` layout, the in-schema `version` field
      (semver, major equals `N`), the instance-level `schema_version` field and its `^1\.\d+\.\d+$`
      pattern, the `$schema` Draft 2020-12 meta-schema self-reference, and the `$id` identifier-only
      strategy.
- [x] The no-cross-file-`$ref` / self-contained-`$defs` rule is stated with its reason
      (`validate_json.py` loads a single schema dict and cannot resolve cross-file `$ref`).
- [x] Each schema is `"type": "object"` with top-level `"additionalProperties": false` plus a single
      optional free-form `metadata` object, and expresses generic, domain-neutral shapes with no
      TaskMaster/TMW/Outlook/VSTO/email/task-management-specific fields, enum values, or descriptions.
- [x] Cross-references between schemas use generic string identifiers only (never JSON Schema
      `$ref`), and timestamps use explicit regex patterns rather than `format: date-time`.
- [x] Schema files are placed at repo-root `schemas/discovery/v1/`, intentionally outside the
      `validate_json.py` governed globs, so no meta-schema network fetch or `.cache/` dirt is
      produced.
- [x] A conforming fixture and a non-conforming fixture exist for each of the seven schemas.
- [x] Conforming fixtures are placed at `examples/discovery/v1/<artifact>.example.json` (governed by
      the existing `examples/**/*.json` glob, no machinery change), are authored with sorted keys, and
      validate cleanly through `validate_json.py`.
- [x] Non-conforming fixtures are placed at
      `tests/fixtures/discovery_schemas/v1/<artifact>.invalid.json`, intentionally outside the
      governed globs, and are exercised by tests that assert rejection via `validate_file`. (This
      feature does not claim that all fixture locations fall under governed globs and validate
      cleanly; a governed failing fixture would make `dev.validate-json` permanently fail.)
- [x] Each non-conforming fixture exercises a distinct violation class per the Fixture Design table
      (missing required property; wrong type; enum violation; array-item violation; pattern violation;
      `additionalProperties` violation; `schema_version` major mismatch).
- [x] Instance `$schema` references are scheme-less relative paths compatible with `_load_schema`
      (three ascents from `examples/discovery/v1/`, four ascents from
      `tests/fixtures/discovery_schemas/v1/`), touching neither the cache nor the network.
- [x] No new production Python is added and no change is made to `validate_json.py` or
      `json_config.py`; tests under `tests/schemas/discovery/` drive
      `Draft202012Validator.check_schema` for offline meta-conformance and `validate_json.py`'s
      `validate_file` for conformance and non-conformance.
- [x] Tests satisfy repository quality-tier policy (line >= 85%, branch >= 75%) and are deterministic
      and offline.

## Seeded Test Conditions (from potential)

- [x] Each schema validates its conforming fixture and rejects its non-conforming fixture.
- [x] Governed-glob discovery includes the conforming fixtures and excludes the non-conforming
      fixtures.
- [x] Versioning-convention edge cases are covered (`schema_version` major mismatch, missing
      `$schema`).
