# legacy-discovery-schemas (#359) — Research

- **Issue:** #359
- **Epic:** legacy-discovery-and-parity (child #9002, C3, Wave 0)
- **Date:** 2026-07-17
- **Author:** task-researcher
- **Scope:** Seven versioned JSON schemas, the repository schema-versioning convention, and conforming/non-conforming fixtures. Out of scope: deterministic validators (#9003), domain-profile config contract (#9001).

## 1. Current State Analysis (verified)

All findings below were verified by reading the files cited.

- **No domain schemas exist.** No repo-root `schemas/` tree and no `examples/` directory exist (glob checks returned no files). Only permissive editor stubs exist at `.vscode/schemas/*.schema.json` (four files, e.g. `tasks.schema.json` is `{"type": "object", "additionalProperties": true}` against draft-07).
- **Validation machinery.** `scripts/dev_tools/validate_json.py`:
  - `validate_file(path, cache_dir)` (line 167) loads a JSON file, requires the root to be an object, requires a string `$schema` (returns `missing $schema` otherwise, line 199), resolves the schema via `_load_schema`, and validates with `jsonschema.Draft202012Validator` when the `jsonschema` module is importable, else a minimal fallback.
  - `_load_schema(uri, cache_dir, base_path)` (line 130) supports exactly three strategies: (1) scheme-less relative path resolved against the *instance file's parent directory* (`(base_path.parent / uri).resolve()`, line 139); (2) `file://` URI; (3) `http(s)://` URI with a SHA-256-named disk cache at `<cache_dir>/<sha256(uri)>.json` and a live `urllib.request.urlopen` fetch on cache miss (lines 155–164).
  - The fallback validator `_collect_schema_errors` (line 82) supports only `type: object` root rejection, `required`, and `type: number` property checks. Keywords such as `enum`, `pattern`, `const`, `additionalProperties`, and array item schemas are enforced **only when `jsonschema` is installed**.
- **Governed globs.** `scripts/dev_tools/json_config.py`: `GOVERNED_GLOBS = ("scripts/**/*.json", "docs/**/*.json", "examples/**/*.json")`; `EXCLUDE_GLOBS` covers `data/**`, `artifacts/**`, `htmlcov/**`, `coverage*/**`, node_modules, `.venv`. A repo-root `schemas/` tree is **not** governed. `tests/**` is **not** governed.
- **Current governed set.** Exactly one governed JSON file exists today: `docs/features/completed/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase4-settings-pre.json`, declaring `$schema: https://json.schemastore.org/claude-code-settings.json` (validating it requires a network fetch or a pre-warmed cache). No CI workflow runs `dev.validate-json`; it is exposed as the Poetry script `dev.validate-json` (`pyproject.toml` line 69) and the VS Code task "JSON: validate" (`.vscode/tasks.json` lines 732–754).
- **Formatting coupling.** `scripts/dev_tools/format_json.py` iterates the same `iter_governed_files`; the VS Code task "JSON: format" runs jq `--sort-keys` over governed files. Any fixture placed under a governed glob will be key-sorted by the formatter; fixtures should be authored with sorted keys to avoid churn.
- **`jsonschema` availability.** `jsonschema = "^4.25.1"` is a **dev-group** dependency (`pyproject.toml` line 43, under `[tool.poetry.group.dev.dependencies]`). It is present in the pytest environment; `validate_json.py` degrades to the weak fallback if it is ever absent at runtime.
- **Cache hygiene.** `.cache/` is not listed in `.gitignore`. A meta-schema fetch triggered by `dev.validate-json` would create an untracked `.cache/schemas/<sha256>.json` file (working-tree dirt).
- **Test conventions.** `tests/scripts/dev_tools/test_validate_json.py` demonstrates the house style: `mem_fs_path` in-memory filesystem fixture (temp files prohibited by policy; `tests/conftest.py` line 146), monkeypatched `_load_schema`/`iter_governed_files`, direct calls to `validate_file`/`main`. Committed negative fixtures have strong precedent under `tests/fixtures/<module>/` (e.g. `tests/fixtures/minor_audit_mode/issue.malformed-marker.md`, `tests/fixtures/atomic_executor/plan_expect_fail.md`).
- **Repo-local `$id` constraint.** `.claude/rules/orchestrator-state.md` prohibits copying a schema with a foreign-origin `$id`; a repo-local `$id` and repo-local enforcement are the accepted pattern.
- **Cross-feature note (informational).** Epic scope item 10 requires schemas to be mirrored into `resources/` subtrees; that mirroring is owned by #9012 and does not constrain the primary placement chosen here, but the placement should be a single self-contained tree to keep mirroring mechanical.

## 2. RQ1 — Schema-Versioning Convention (recommendation)

**Recommended convention** (to be documented verbatim in `spec.md` as the shared contract):

1. **Directory layout:** `schemas/<family>/v<N>/<artifact>.schema.json` at the repository root. This feature creates the family `discovery`:
   ```
   schemas/discovery/v1/feature-contract.schema.json
   schemas/discovery/v1/coverage-ledger.schema.json
   schemas/discovery/v1/runtime-characterization-scenario.schema.json
   schemas/discovery/v1/parity-matrix.schema.json
   schemas/discovery/v1/unspecified-behavior-record.schema.json
   schemas/discovery/v1/product-decision-record.schema.json
   schemas/discovery/v1/evidence-reference.schema.json
   ```
   `v<N>` is the **major** version. Breaking changes create a sibling `v2/` tree; a published `vN/` tree is immutable for consumed schemas except for additive (minor/patch) changes.
2. **Version fields inside each schema document:**
   - `$schema`: `"https://json-schema.org/draft/2020-12/schema"` (matches the `Draft202012Validator` used by `validate_json.py`).
   - `$id`: the repo-root-relative path string, e.g. `"schemas/discovery/v1/feature-contract.schema.json"`. Documented as an identifier only, never dereferenced (no fake external domain, consistent with the repo-local-`$id` posture in `.claude/rules/orchestrator-state.md`). `validate_json.py` never resolves `$id`.
   - `version`: full semver annotation, e.g. `"1.0.0"`, whose major component MUST equal the directory `N`. (Unknown keywords are valid Draft 2020-12 annotations.)
   - `title` and `description`: required documentation keywords.
3. **Instance-side version field:** every instance document carries a required `schema_version` string constrained by `"pattern": "^1\\.\\d+\\.\\d+$"` (major pinned to the directory `N`; minor/patch free). Rationale: a `const` pin would break every existing instance on an additive minor bump; pinning only the major keeps additive evolution non-breaking while still making a cross-major mismatch (e.g. `"2.0.0"` against a v1 schema) a schema-level rejection — which directly implements the seeded test condition "version field mismatch". Exact-version equality checks are #9003 territory.
4. **Instance-side `$schema` self-reference:** a scheme-less **relative path** from the instance file to the schema file (see RQ2/RQ3). Absolute Windows paths are prohibited: `urlparse("C:/...")` parses the drive letter as a scheme and `_load_schema` rejects it.
5. **Self-containment rule:** each schema file is fully self-contained; internal reuse goes through `#/$defs/...` only. Cross-file `$ref` is prohibited because `_load_schema` returns a single dict and `Draft202012Validator` is constructed without a registry mapping file paths, so an external-file `$ref` would fail at validation time.

**Rejected alternatives:** (a) `schemas/v1/` without a family segment (the objective's literal sketch) — forces all future, unrelated schema families into one shared version counter; the family segment generalizes the convention that the epic says every schema consumer must reuse. (b) Per-schema versioning (`schemas/feature-contract/v1/…`) — the seven schemas cross-reference each other and evolve as a suite; per-schema counters multiply compatibility states with no current benefit.

## 3. RQ2 — Placement and Governed-Glob Compatibility (recommendation)

**Recommended placement:**

| Artifact | Location | Governed? |
|---|---|---|
| Schema files (7) | `schemas/discovery/v1/*.schema.json` | No (by design) |
| Conforming fixtures (7) | `examples/discovery/v1/<artifact>.example.json` | Yes (`examples/**/*.json`) |
| Non-conforming fixtures (7+) | `tests/fixtures/discovery_schemas/v1/<artifact>.invalid.json` | No (by design) |

**`$schema` reference strategy (relative paths, exact values):**
- Conforming fixture at `examples/discovery/v1/feature-contract.example.json` declares
  `"$schema": "../../../schemas/discovery/v1/feature-contract.schema.json"`
  (3 ascents: `v1` → `discovery` → `examples` → repo root). Verified against `_load_schema`: scheme-less URI, resolved via `(base_path.parent / uri).resolve()`; `..` segments and forward slashes work under `pathlib` on Windows.
- Non-conforming fixture at `tests/fixtures/discovery_schemas/v1/feature-contract.invalid.json` declares
  `"$schema": "../../../../schemas/discovery/v1/feature-contract.schema.json"` (4 ascents).
- Neither form touches the schema cache or the network (`_load_schema` relative-path branch reads the file directly).

**Option analysis:**
- **(a) Fixtures under `examples/` — selected for conforming fixtures.** The `examples/**/*.json` glob already exists in `json_config.py` but the directory does not; creating it activates governance with zero machinery change. Semantically correct: these are the canonical worked examples of each artifact shape. `dev.validate-json` will discover and validate them by default.
- **(b) Fixtures under `docs/` — rejected.** Mechanically workable but semantically a documentation tree; the only governed file there today is feature evidence. Feature folders move (`active/` → `completed/`), which would silently break relative `$schema` paths for anything colocated with feature docs.
- **(c) Extend `json_config.py` with `schemas/**/*.json` — rejected.** It edits the validation machinery this feature is instructed to reuse-not-modify, and it creates two concrete defects: (1) the seven schema files become governed instances whose `$schema` is the remote Draft 2020-12 meta-schema, introducing a first-run network fetch and untracked `.cache/` dirt (see RQ3); (2) any non-conforming fixture placed in a governed tree makes `dev.validate-json` permanently exit 1.

**Structural constraint that must be documented in spec.md:** the issue's draft acceptance criterion "schema and fixture locations fall under governed globs and validate cleanly" cannot hold for **non-conforming** fixtures — a governed non-conforming fixture fails validation by definition, and the "missing `$schema`" negative is *structurally impossible* under governance (every governed file must declare `$schema`, `validate_json.py` line 199). The criterion should be restated as: conforming fixtures are governed and validate cleanly; non-conforming fixtures are intentionally placed outside the governed globs (repo precedent: `tests/fixtures/<module>/`) and are exercised by tests driving `validate_file` directly, asserting rejection. This preserves the intent (fixtures are validated by the existing machinery) without making the repository's own JSON gate permanently red.

## 4. RQ3 — Meta-Schema Fetch Behavior (recommendation)

Verified behavior if a schema file landed under a governed glob: `validate_file` would treat it as an instance, read its `$schema` (`https://json-schema.org/draft/2020-12/schema`), and take the `http(s)` branch of `_load_schema` — cache lookup at `.cache/schemas/<sha256>.json`, then a live `urllib.request.urlopen` fetch on miss. Consequences: a first-run network dependency for `dev.validate-json`, and an untracked `.cache/` directory (not gitignored). Committing the cache file is unattractive (opaque SHA-256 filename, duplicate of a public document, silent staleness).

**Recommendation:** keep the schema files **outside** the governed globs (repo-root `schemas/`, exactly as the objective sketches). `validate_json.py` then never validates the schema documents as instances and never needs the remote meta-schema. Meta-schema conformance of the seven schema documents is instead asserted **offline** in this feature's tests via `jsonschema.Draft202012Validator.check_schema(schema_dict)`: the `jsonschema`/`referencing` packages bundle the official Draft 2020-12 meta-schemas (core/applicator/validation vocabularies), so `check_schema` performs no network I/O. This gives strictly stronger verification than routing schema files through `validate_file` (which would validate them against the meta-schema anyway) at zero network cost.

Note also that when fixtures use relative `$schema` paths, `validate_file` never creates the cache directory at all (cache `mkdir` happens only in the `http(s)` branch), so validating the fixtures is fully offline and side-effect-free.

## 5. RQ4 — Domain-Neutral Field Design (recommendation)

**Suite-wide conventions** (apply to all seven schemas; keep vocabulary strictly generic legacy-discovery language — no TaskMaster/TMW/Outlook/VSTO/email/task-management terms):

- Field naming: `snake_case` (matches the orchestrator-state artifact convention).
- Every schema: `"type": "object"`, `"additionalProperties": false` at the top level for deterministic shapes, with a single optional free-form `metadata` object (`"type": "object"`, additional properties allowed) as the sanctioned extension point for consumer repositories.
- Required in every instance: `$schema` (string), `schema_version` (string, pattern `^1\.\d+\.\d+$`), `id`.
- Shared identifier grammar (duplicated into each schema's `$defs` — self-containment rule): `"pattern": "^[a-z0-9][a-z0-9._-]*$"` for all `id` values and all reference fields.
- Cross-references are **plain string identifiers**, never JSON Schema `$ref`: `evidence_refs` arrays carry Evidence Reference `id` values; `feature_id`/`feature_ids` carry Feature Contract `id` values; `decision_ref(s)` carry Product Decision Record `id` values; `behavior_record_ids` carry Unspecified Behavior Record `id` values. Referential integrity (does the referenced artifact exist?) is intentionally *not* expressible in JSON Schema and is deferred to the #9003 validators.
- Timestamps: `"type": "string"` with an explicit ISO-8601 regex (e.g. `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$`). Important verified nuance: `validate_json.py` constructs `Draft202012Validator` **without** a `FormatChecker`, so `"format": "date-time"` is annotation-only and would NOT reject bad values; patterns are required for enforced timestamp shapes.

**Per-schema top-level design** (required fields listed first; everything else optional):

1. **Evidence Reference** (`evidence-reference.schema.json`) — the leaf all others point at.
   - Required: `id`, `kind` (enum: `file | log | trace | test_run | screenshot | recording | document | dataset | url | other`), `location` (string; path or URI in the consumer repo's terms), `captured_at` (timestamp), `description`.
   - Optional: `content_hash` (`{algorithm, value}`), `tool` (string), `metadata`.
2. **Feature Contract** (`feature-contract.schema.json`) — contracted behavior of one legacy feature/workflow.
   - Required: `id`, `title`, `description`, `status` (enum: `draft | reviewed | approved | deprecated`), `acceptance_criteria` (array, `minItems: 1`, of `{id, statement, verification: enum(manual | automated | characterization)}`).
   - Optional: `workflows` (array of `{id, name, steps: [string]}`), `source_refs` (array of generic locators `{path, symbol?, line_start?, line_end?}`), `depends_on` (array of feature ids), `evidence_refs`, `tags`, `metadata`.
3. **Coverage Ledger** (`coverage-ledger.schema.json`) — legacy implementation coverage of the discovery effort.
   - Required: `id`, `generated_at` (timestamp), `subject` (string label for the covered corpus), `entries` (array of `{unit_id, unit_kind: enum(module | namespace | type | file | component | other), status: enum(not_started | in_discovery | contracted | characterized | excluded), feature_ids?}`), `summary` (`{total_units: integer >= 0, covered_units: integer >= 0}`).
   - Optional per-entry: `evidence_refs`, `notes`. Optional top-level: `metadata`.
4. **Runtime Characterization Scenario** (`runtime-characterization-scenario.schema.json`) — one observed-behavior scenario.
   - Required: `id`, `feature_id`, `title`, `preconditions` (array of strings), `stimulus` (`{description, inputs?}`), `observed_behavior` (`{description, outputs?}`), `observation_method` (enum: `log | trace | debugger | instrumented | manual | other`), `evidence_refs` (`minItems: 1` — a characterization without evidence is not a characterization).
   - Optional: `determinism` (enum: `deterministic | nondeterministic | unknown`), `variations` (array of `{description, observed_behavior}`), `metadata`.
5. **Parity Matrix** (`parity-matrix.schema.json`) — source-to-target parity status.
   - Required: `id`, `generated_at`, `source_label`, `target_label` (generic strings; the domain profile supplies real names at runtime), `rows` (array of `{feature_id, parity_status: enum(not_started | in_progress | behavioral_parity | intentional_divergence | deferred | out_of_scope), verification: enum(none | manual | automated)}`).
   - Optional per-row: `criterion_id` (an acceptance-criterion id within the feature contract), `evidence_refs`, `decision_refs`, `notes`. Optional top-level: `summary`, `metadata`.
6. **Unspecified Behavior Record** (`unspecified-behavior-record.schema.json`) — undocumented/contradictory/ambiguous behavior.
   - Required: `id`, `title`, `description`, `category` (enum: `undocumented | contradictory | ambiguous | environment_dependent`), `discovery_context` (string), `resolution_status` (enum: `open | under_review | resolved`), `evidence_refs` (`minItems: 1`).
   - Optional: `feature_id` (behavior may predate a contract), `decision_ref` (the resolving Product Decision Record), `metadata`. (The rule "resolved implies decision_ref present" is a cross-field semantic left to #9003.)
7. **Product Decision Record** (`product-decision-record.schema.json`) — reconciled product decision.
   - Required: `id`, `title`, `decision` (string), `status` (enum: `proposed | accepted | superseded | rejected`), `rationale` (string).
   - Optional: `decided_at` (timestamp), `alternatives` (array of `{description, reason_rejected}`), `feature_ids`, `behavior_record_ids`, `evidence_refs`, `superseded_by` (decision id), `metadata`.

**Reference topology:** Evidence Reference is the shared leaf (referenced by Feature Contract, Coverage Ledger entries, Characterization Scenarios, Parity Matrix rows, Unspecified Behavior Records, Product Decision Records). Feature Contract is the hub identifier space (`feature_id`/`feature_ids` in Scenarios, Ledger entries, Matrix rows, Decision Records). Product Decision Record closes the loop from Unspecified Behavior Records (`decision_ref`) and Parity Matrix divergences (`decision_refs`).

## 6. RQ5 — Fixture Design (recommendation)

One conforming and one non-conforming fixture per schema; each non-conforming fixture exercises a **distinct violation class** so #9003 (validators) and #9010 (reports) inherit a varied negative corpus rather than seven copies of "missing required field":

| Schema | Conforming fixture exercises | Non-conforming fixture violation (distinct class) | Expected `Draft202012Validator` signal |
|---|---|---|---|
| Feature Contract | All required + `workflows`, `source_refs`, `evidence_refs` | Missing required property (`acceptance_criteria` absent) | `'acceptance_criteria' is a required property` |
| Coverage Ledger | Required + per-entry optionals | Wrong type (`summary.total_units` is a string; or `entries` is an object) | type mismatch at a nested path |
| Runtime Characterization Scenario | Required + `determinism`, `variations` | Enum violation (`observation_method: "guesswork"`) | `is not one of [...]` |
| Parity Matrix | Required + row optionals + `summary` | Array-item violation (one row lacks `parity_status`) | required-property error at `rows[1]` |
| Unspecified Behavior Record | Required + `feature_id`, `decision_ref` | Pattern violation (`id: "Behavior Record #1"` — uppercase/spaces) | `does not match '^[a-z0-9]...'` |
| Product Decision Record | Required + `alternatives`, `superseded_by` | `additionalProperties: false` violation (unknown top-level key, e.g. `approved_by_manager`) | `Additional properties are not allowed` |
| Evidence Reference | Required + `content_hash`, `tool` | `schema_version` major mismatch (`"2.0.0"` against v1 pattern) — the seeded "version field mismatch" condition | pattern failure on `schema_version` |

Additional negatives that are test-cases rather than governed files (both hit `validate_file` branches before schema evaluation): a fixture without `$schema` (returns `missing $schema`) and a non-object root. These live under `tests/fixtures/discovery_schemas/v1/` or as in-memory cases via `mem_fs_path`, matching existing test style.

Two authoring constraints, both verified: (1) conforming fixtures under `examples/` are subject to jq `--sort-keys` formatting — author them with alphabetically sorted keys; (2) the enum/pattern/const/additionalProperties negatives are rejected only when `jsonschema` is installed — the built-in fallback would pass them. Tests must therefore assert on the real `jsonschema` path (it is a dev dependency, always present under pytest); document that the fallback is a degraded mode, not the contract.

## 7. RQ6 — Testing Approach (recommendation)

**Production Python required: none.** The feature ships JSON schema documents, JSON fixtures, and spec documentation. No new module, no `pyproject.toml` script, no change to `validate_json.py`/`json_config.py`. Coverage thresholds (line >= 85%, branch >= 75%) are computed over production code and are unaffected by adding tests; the new tests exercise existing `validate_json.py` production paths.

**Test layout** (mirrors the artifact tree per test-location policy):
- `tests/schemas/discovery/test_v1_schema_documents.py` — schema-document conformance:
  - Parametrized over the seven files: `json.loads` each, then `Draft202012Validator.check_schema(schema)` (offline; bundled meta-schemas). This is the meta-validation that placement outside governed globs would otherwise forgo.
  - Convention assertions: `$schema` equals the Draft 2020-12 URI; `$id` equals the repo-relative path of the file; `version` major equals the `v1` directory; `title`/`description` present; top-level `additionalProperties` is `false`; `schema_version` is required with the major-pinned pattern; every `*_ref`/`*_refs`/`*_id`/`*_ids` field uses the shared id pattern. These tests make the versioning convention machine-enforced instead of prose-only, and they cover the "version field mismatch" and "missing `$schema`" seeded edge cases at the convention level.
- `tests/schemas/discovery/test_v1_fixtures.py` — fixture conformance via the existing machinery:
  - Parametrized positive: `ok, msg = validate_file(<repo>/examples/discovery/v1/<name>.example.json, cache_dir)`; assert `ok is True`. `cache_dir` can be `mem_fs_path / "cache"` — the relative-`$schema` branch never touches it, so the test performs no disk writes (reading committed repo files is not temporary-file usage; precedent: `tests/fixtures/**`).
  - Parametrized negative: `validate_file` on each `tests/fixtures/discovery_schemas/v1/<name>.invalid.json`; assert `ok is False` and that `msg` contains the expected violation signal from the RQ5 table (substring assertions on the stable parts of the `jsonschema` message, e.g. `"is a required property"`, `"is not one of"`, keeping tests resilient to message-detail drift).
  - Governed-discovery test: `iter_governed_files(repo_root)` includes every conforming fixture path and none of the non-conforming ones — directly covering the seeded condition "governed-glob discovery includes the new schema and fixture files" as restated in RQ2.
  - `missing $schema` and non-object-root negatives driven through `validate_file`.
- Repo-root resolution inside tests: derive it as `Path(__file__).resolve().parents[N]` (existing precedent across `tests/scripts/dev_tools/`), not from CWD.

**Determinism:** all tests are offline (relative `$schema` paths; `check_schema` uses bundled meta-schemas; no cache writes), no clocks, no randomness — the determinism-infrastructure rules impose no extra machinery here.

## 8. Requirements Mapping (acceptance criteria → design)

| Acceptance criterion (issue.md) | Design element |
|---|---|
| Seven versioned schemas with documented `vN/` layout | `schemas/discovery/v1/*.schema.json` (RQ1) |
| Versioning convention documented precisely in spec.md | RQ1 items 1–5 restated as the shared contract; plus the RQ2 governance restatement |
| Generic, domain-neutral shapes | RQ4 vocabulary; enforced by review — no schema field names a domain concept |
| Conforming and non-conforming fixtures per schema | RQ5 table; conforming in `examples/discovery/v1/`, non-conforming in `tests/fixtures/discovery_schemas/v1/` |
| Locations fall under governed globs and validate cleanly | Holds for conforming fixtures; **requires spec.md restatement** for schemas (deliberately ungoverned, RQ3) and non-conforming fixtures (cannot be governed and clean simultaneously, RQ2) |
| Tests satisfy quality-tier policy | RQ6: no production Python; tests exercise existing `validate_file` paths; coverage unaffected |

**State model:** none — this feature introduces no runtime state. **File changes:** 7 schema files, 7 conforming fixtures, 7+ non-conforming fixtures, 2 test modules, spec.md convention section. No changes to `scripts/dev_tools/**`.

## 9. Rejected Alternatives (summary)

- `schemas/v1/` (no family segment) and per-schema version directories — see RQ1.
- Fixtures under `docs/` — lifecycle moves break relative `$schema`; see RQ2(b).
- Extending `GOVERNED_GLOBS` with `schemas/**/*.json` — machinery edit, meta-schema network fetch, and permanent gate failure for governed negatives; see RQ2(c)/RQ3.
- Committing a pre-warmed `.cache/schemas/<sha>.json` meta-schema — opaque, stale-prone, unnecessary once schemas are ungoverned; see RQ3.
- Cross-file `$ref` to a shared definitions schema — unresolvable under `validate_json.py`'s single-dict loading; replaced by per-file `$defs` duplication; see RQ1 item 5.
- `const`-pinned `schema_version` — breaks all instances on additive minor bumps; replaced by major-pinned pattern; see RQ1 item 3.
- `format: "date-time"` for timestamp enforcement — annotation-only without a `FormatChecker`; replaced by explicit patterns; see RQ4.

## 10. Automation Feasibility

Not applicable. This research covers repository-local JSON schema files, fixtures, and pytest-driven validation only; it does not touch third-party UIs or external services. No human-interaction or unautomatable steps were identified.
