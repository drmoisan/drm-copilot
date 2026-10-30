# docs-profile-and-artifact-schemas — Spec

- **Issue:** #1020
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 900001, wave 0, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T20-45
- **Status:** Draft
- **Version:** 0.2
- **Research:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md`

## Overview

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
ledger, generator, MCP and enforcement features can be built in parallel. No documentation profile,
documentation artifact schema, surface element model or analyzer protocol exists in the repository
today. Without them, every downstream feature would invent its own shapes, and the coverage ledger,
parity matrix and `docs-complete` receipt could not be validated consistently. Framework code must also
stay domain-neutral: all repository specificity must be runtime configuration in a docs profile.

This feature delivers those contracts. Features 900003, 900004, 900005 and 900006 consume them
directly, and 900007 and 900008 consume them through the commands those features add. The
contracts below are therefore normative: a downstream feature that needs a different shape must
change this specification through an epic-level update rather than diverge locally.

The naming contract in the epic `## Shared Design` section is fixed and is restated, not changed,
here.

## Behavior

Create the `packages/docs-runtime` package (distribution `drm-copilot-docs`, import name
`drm_copilot_docs`, version `1.0.0`). It depends on the merged discovery runtime
(`packages/discovery-runtime`, `drm_copilot_discovery`) as a library. No discovery file is edited
and discovery behavior does not change. The package provides:

- Profile dataclasses (audiences, documentation roots, surface selection, page owners, Diataxis
  policy, completion gates, artifact paths) and a loader that validates a docs profile against the
  `docs-profile` schema and a set of semantic checks.
- Docs v1 schema loading through an offline registry that resolves references into discovery v2
  `common`.
- The surface element model: kinds `cli-command`, `cli-option`, `http-route`, `config-key`,
  `public-symbol`, `architecture-component`, with deterministic identifiers derived from kind,
  path and declaration through `drm_copilot_discovery.analyzer.findings.stable_id`.
- The `SurfaceAnalyzer` protocol and an append-only registry table (`ANALYZER_REGISTRY`) in
  `analyzer_contract.py`, empty in this feature, that 900003 and 900004 extend.
- One CLI module (`cli.py`) providing `dev.docs.init` (emit a starter profile) and
  `dev.docs.validate-profile`.
- Six artifact schemas under `schemas/docs/v1/`: `docs-profile`, `surface-inventory-snapshot`,
  `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`, `docs-validation-receipt`,
  with one example per artifact schema under `examples/docs/v1/<name>.example.json`.
- One definitions-only schema `schemas/docs/v1/common.schema.json` (`$id`
  `urn:drm-copilot:docs:1.0.0:common`) holding the docs shared vocabulary. It is not an artifact
  kind, carries no artifact header, and has no example. This is a file-list refinement permitted by
  the epic; it does not change the naming contract.
- Ledger dispositions `documented`, `excluded`, `deferred`; parity dimensions `exists`, `accurate`,
  `example_present`, `owner_assigned`, `diataxis_mode`; page front-matter fields `owner`,
  `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`.
- Distribution following the discovery runtime mechanism: a docs-owned builder stages hash-verified
  copies of the docs schemas inside the package and builds a wheel that a consumer repository
  installs alongside the discovery wheel.

## Inputs / Outputs

- Inputs:
  - A docs profile file (JSON; YAML accepted when the extension is `.yaml` or `.yml`). Default
    path for `dev.docs.validate-profile`: `docs/documentation-estate/docs-profile.json`.
  - CLI flags listed in `## API / CLI Surface`.
  - Installed resources: the staged docs schemas inside `drm_copilot_docs/_resources/` and the
    discovery `schemas/discovery/v2/common.schema.json` read through
    `drm_copilot_discovery.resources.read_resource` (hash-verified).
  - No environment variables are read.
- Outputs:
  - `dev.docs.init`: the starter profile as canonical JSON on stdout, or written to `--output`.
  - `dev.docs.validate-profile`: findings in text (default) or JSON on stdout; diagnostics for
    invocation and runtime failures on stderr.
  - Build output: `dist/docs/drm_copilot_docs-1.0.0-py3-none-any.whl` (untracked).
- Config keys and defaults: all repository specificity is profile data. Starter defaults are
  listed under `dev.docs.init`.
- Versioning and backward compatibility:
  - Schema family version `1.0.0`; every artifact carries `schema_version` const `"1.0.0"`.
  - With the T2 classification, a breaking change to any schema or to the public symbols in
    `## Data & State` requires a major version bump (`urn:drm-copilot:docs:2.0.0:*`,
    `schemas/docs/v2/`).
  - The docs package declares `drm-copilot-discovery = ">=2.0.0,<3.0.0"`.

## API / CLI Surface

### Schema identity and reference conventions

- `$schema`: `https://json-schema.org/draft/2020-12/schema` in every docs schema.
- `$id`: `urn:drm-copilot:docs:1.0.0:<name>`, where `<name>` is the file stem without
  `.schema.json` (for example `urn:drm-copilot:docs:1.0.0:docs-profile`).
- Artifact header, required in each of the six artifact schemas: `$schema` (const equal to the
  schema `$id`), `schema_version` (const `"1.0.0"`), `artifact_kind` (const equal to `<name>`),
  `id` (`urn:drm-copilot:discovery:2.0.0:common#/$defs/identifier`), `extensions`
  (`urn:drm-copilot:discovery:2.0.0:common#/$defs/extensions`).
- Cross-family references use the absolute discovery URN plus a JSON pointer, for example
  `{"$ref": "urn:drm-copilot:discovery:2.0.0:common#/$defs/relative-path"}`.
- Docs-internal shared references use the absolute docs URN, for example
  `{"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/element-kind"}`. Schema-local references
  use `#/$defs/<name>`.
- `$defs` names are kebab-case; property names are snake_case.
- Every object is closed (`additionalProperties: false`) and lists every property in `required`
  unless this specification marks it optional. Inapplicable companion fields are `null`, not
  absent.
- Formats: only `date-time` (and `uri` if required), because
  `drm_copilot_discovery.schema_validation.discovery_format_checker` registers only those. A
  calendar date uses the pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`; calendar validity is checked in
  Python.
- No nested `$id`. No reference outside the docs v1 set plus discovery v2 `common`. No remote
  retrieval: the registry `retrieve` callable raises `referencing.exceptions.NoSuchResource`.

In the tables below, "text", "identifier", "identifiers", "relative-path", "paths",
"path-or-glob", "exclusions", "revision", "sha256", "timestamp", "extensions" and
"validation-outcome" mean the definitions of those names in discovery v2 `common`.

### Docs `common` `$defs` (`urn:drm-copilot:docs:1.0.0:common`)

| Definition | Shape |
|---|---|
| `element-kind` | `enum: ["cli-command", "cli-option", "http-route", "config-key", "public-symbol", "architecture-component"]` |
| `element-id` | string, pattern `^(?:cli-command\|cli-option\|http-route\|config-key\|public-symbol\|architecture-component)-[0-9a-f]{64}$` (also satisfies discovery `identifier`) |
| `element-ids` | array, `uniqueItems`, items `element-id` |
| `disposition` | `enum: ["documented", "excluded", "deferred"]` |
| `parity-dimension` | `enum: ["exists", "accurate", "example_present", "owner_assigned", "diataxis_mode"]` |
| `parity-state` | `enum: ["pass", "fail", "not-assessed", "not-applicable"]` |
| `diataxis-mode` | `enum: ["tutorial", "how-to", "reference", "explanation"]` |
| `front-matter-field` | `enum: ["owner", "last_reviewed", "audience", "diataxis_mode", "surface_refs"]` |
| `review-date` | string, pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` |
| `docs-artifact-kind` | `enum: ["docs-profile", "surface-inventory-snapshot", "docs-coverage-ledger", "docs-parity-matrix", "docs-evidence-pin", "docs-validation-receipt"]` |
| `artifact-pin` | closed object: `artifact_kind` (`docs-artifact-kind`), `path` (relative-path), `sha256` (sha256) |
| `page-binding` | closed object: `page_path` (relative-path), `anchor` (text or `null`) |
| `actor` | closed object: `kind` (`enum: ["human", "agent", "tool"]`), `id` (identifier) |
| `finding` | closed object: `code` (pattern `^[A-Z][A-Z0-9_]*$`), `severity` (`enum: ["error", "warning", "info"]`), `artifact_path` (relative-path or `null`), `pointer` (RFC 6901 pointer, same pattern as discovery `service-result`), `related_ids` (identifiers), `related_paths` (paths), `message` (text), `next_action` (text). Key set equals `drm_copilot_discovery.findings.Finding.to_dict`. |
| `diagnostic` | closed object: `id` (identifier), `code`, `severity` (`enum: ["information", "warning", "error"]`), `path` (relative-path or `null`), `message` (text), `analyzer_id` (identifier), `blocking` (boolean), `extensions`. Same shape as discovery `inventory-snapshot#/$defs/diagnostic`. |

The `diataxis-mode` values are shared with 900002 (`page-metadata.schema.json`) and 900006
(`diataxis_mode: reference`); 900002 must use the same values.

### Artifact schema: `docs-profile` (`docs-profile.schema.json`)

| Field | Shape |
|---|---|
| header | as above |
| `repository` | closed object `{id: identifier}` |
| `audiences` | array `minItems 1`, `uniqueItems`, items closed `{id: identifier, description: text}` |
| `documentation_roots` | array `minItems 1`, items closed `{id: identifier, path: relative-path, audience_ids: identifiers}` |
| `surface_selection` | closed object: `element_kinds` (array `minItems 1`, `uniqueItems`, items `element-kind`), `source_roots` (paths, `minItems 1`), `exclusions` (exclusions), `analyzers` (identifiers; optional; absent means every registered analyzer whose kinds intersect `element_kinds`) |
| `page_owners` | array of closed `{path_or_glob: path-or-glob, owner: identifier}` |
| `diataxis_policy` | closed object: `modes` (array `minItems 1`, `uniqueItems`, items `diataxis-mode`), `required_front_matter` (array `uniqueItems`, items `front-matter-field`), `directory_modes` (array of closed `{path_or_glob: path-or-glob, mode: diataxis-mode}`) |
| `completion_gates` | closed object: `docs_complete` (closed `{required_dispositions_complete: const true, allow_deferred: boolean, max_stale_pages: integer minimum 0, required_parity_dimensions: array uniqueItems of parity-dimension}`), `integration_pr_gate` (closed `{enabled: boolean}`) |
| `artifact_paths` | closed object: `inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`, `validation_receipt`, each relative-path |

Semantic checks applied after schema validation (each an `error` finding with a pointer to the
offending field): audience identifiers unique; documentation root identifiers unique; every
`documentation_roots[*].audience_ids` member names a declared audience; every
`diataxis_policy.directory_modes[*].mode` is a member of `diataxis_policy.modes`; every
`surface_selection.analyzers` member is a registered analyzer identifier (error pointer
`/surface_selection/analyzers/<n>`). Consumers: 900003 reads `surface_selection` and
`artifact_paths.inventory_snapshot`; 900005 reads `completion_gates.docs_complete` and the other
`artifact_paths`; 900006 reads `diataxis_policy` and `page_owners`; 900008 reads
`completion_gates.integration_pr_gate.enabled`.

### Artifact schema: `surface-inventory-snapshot`

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `revision` | revision or `null` (working copy) |
| `profile_sha256` | sha256 of the canonical profile bytes |
| `analyzers` | array `uniqueItems` of closed `{id: identifier, version: text}` |
| `inputs` | array `uniqueItems` of closed `{path: relative-path, sha256: sha256, size: integer minimum 0}` |
| `elements` | array `uniqueItems` of `#/$defs/element` |
| `diagnostics` | array of docs `diagnostic` |
| `captured_at` | timestamp |

`$defs/element` (closed): `element_id` (element-id), `kind` (element-kind), `path`
(relative-path), `declaration` (text), `name` (text), `parent_id` (element-id or `null`),
`analyzer_id` (identifier), `source_sha256` (sha256), `line_range` (closed
`{start: integer minimum 1, end: integer minimum 1}` or `null`), `properties` (array of closed
`{name: identifier, value: string | number | boolean | null}`; keys and shapes only, never
configuration values), `extensions`. Conditional rule: `kind: cli-option` requires `parent_id`
matching `^cli-command-`; every other kind allows `null` or any element-id.

### Artifact schema: `docs-coverage-ledger`

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `snapshot_ref` | `artifact-pin` with `artifact_kind` const `surface-inventory-snapshot` |
| `entries` | array `uniqueItems` of `#/$defs/entry` |

`$defs/entry` (closed): `element_id` (element-id), `kind` (element-kind), `disposition`
(docs `disposition`), `page_bindings` (array of `page-binding`), `rationale` (text or `null`),
`owner` (identifier or `null`), `target` (text or `null`), `updated_by` (`actor`), `extensions`.

Disposition companion rules (`allOf` of `if`/`then` keyed on `disposition`):

| Disposition | `page_bindings` | `rationale` | `owner` | `target` |
|---|---|---|---|---|
| `documented` | `minItems 1` | `null` | `null` | `null` |
| `excluded` | `maxItems 0` | text | `null` | `null` |
| `deferred` | `maxItems 0` | text or `null` | identifier | text |

Completeness (every inventoried element has an entry) is a semantic rule owned by 900005, not a
schema rule.

### Artifact schema: `docs-parity-matrix`

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `snapshot_ref` | `artifact-pin` (`artifact_kind` const `surface-inventory-snapshot`) |
| `ledger_ref` | `artifact-pin` (`artifact_kind` const `docs-coverage-ledger`) |
| `rows` | array `uniqueItems` of `#/$defs/row` |

`$defs/row` (closed): `element_id` (element-id), `kind` (element-kind), `page_path`
(relative-path), `dimensions` (closed object whose required keys are exactly `exists`,
`accurate`, `example_present`, `owner_assigned`, `diataxis_mode`, each a
`#/$defs/dimension-result`), `extensions`. `$defs/dimension-result` (closed): `state`
(parity-state), `rationale` (text or `null`), `evidence_pin_ids` (identifiers); `fail` and
`not-applicable` require `rationale` text. An unknown dimension is rejected by
`additionalProperties: false`.

### Artifact schema: `docs-evidence-pin` (collection form)

One document per repository holds every pin, sorted by `pin_id`.

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `pins` | array `uniqueItems` of `#/$defs/pin` |

`$defs/pin` (closed): `pin_id` (identifier), `element_id` (element-id), `element_kind`
(element-kind), `page_path` (relative-path), `symbol` (text; the pinned declaration),
`source_path` (relative-path), `source_sha256` (sha256; 900005 compares it with the current
snapshot element to mark the bound page stale), `revision` (revision or `null`), `claim` (text or
`null`), `pinned_at` (timestamp), `pinned_by` (`actor`).

### Artifact schema: `docs-validation-receipt`

| Field | Shape |
|---|---|
| header | as above |
| `mode` | `enum: ["profile", "ledger", "matrix", "docs-complete"]` |
| `repository` | identifier |
| `revision` | revision (non-null; 900008 matches it against the head revision) |
| `inputs` | array `uniqueItems` of `artifact-pin` |
| `counts` | closed object: `elements_total`, `undocumented`, `stale_pages` (integers minimum 0), `by_disposition` (closed object whose required keys are exactly the three dispositions, integer values minimum 0), `by_kind` (closed object whose required keys are exactly the six element kinds, integer values minimum 0) |
| `validation_result` | validation-outcome |
| `findings` | array `uniqueItems` of docs `finding` |
| `issued_at` | timestamp |
| `writer` | closed `{tool: const "drm-copilot-docs", version: text}` |

Result binding copied from discovery `validation-receipt`: `pass` forbids any finding with
severity `error`; `fail` requires at least one. An unknown disposition or kind is rejected
through the closed `by_disposition` and `by_kind` objects.

Rejection coverage: each artifact schema carries an element-kind or disposition field (profile
`surface_selection.element_kinds`, snapshot `elements[].kind`, ledger `entries[].kind` and
`entries[].disposition`, matrix `rows[].kind`, pin `pins[].element_kind`, receipt
`counts.by_kind` and `counts.by_disposition`). In acceptance criterion 1, "each schema" means the
six artifact schemas; the definitions-only `common` schema has no root object and no example and
is verified through the artifact schemas that reference it.

### Element identifier function and declaration conventions (`surface_models.py`)

- `ElementKind = Literal["cli-command", "cli-option", "http-route", "config-key",
  "public-symbol", "architecture-component"]`; `ELEMENT_KINDS: tuple[ElementKind, ...]` in that
  order.
- `element_identifier(*, kind: ElementKind, path: str, declaration: str) -> str` returns
  `stable_id(kind, row(kind=kind, path=path, declaration=declaration))` using
  `drm_copilot_discovery.analyzer.findings`. The result is `<kind>-<64 lowercase hex>` and
  matches `element-id`.
- Input validation (`ValueError` naming the argument): `kind` in `ELEMENT_KINDS`; `path` passes
  `drm_copilot_discovery.findings.validate_finding_path` (POSIX relative path grammar); `declaration`
  non-blank, no leading or trailing whitespace, no control characters. No Unicode normalization
  is applied, so identity is byte-exact.
- Because the hashed value is canonical JSON of three named members, concatenation ambiguities
  (for example path `a/b` with declaration `c` versus path `a` with declaration `b/c`) cannot
  collide.
- Declaration conventions per kind (binding on 900003 and 900004):

| Kind | Declaration | Example |
|---|---|---|
| `cli-command` | full command path | `dev.docs.inventory` |
| `cli-option` | command path, one space, long option | `dev.docs.inventory --analyzer` |
| `http-route` | upper-case method, one space, route template | `GET /items/{id}` |
| `config-key` | dotted key path | `tool.poetry.scripts` |
| `public-symbol` | qualified name | `drm_copilot_docs.profile.parse_profile` |
| `architecture-component` | package or module path | `drm_copilot_docs.analyzers` |

### `SurfaceElement` and related models (`surface_models.py`)

- `SurfaceElement` (frozen dataclass, `kw_only`): `element_id: str`, `kind: ElementKind`,
  `path: str`, `declaration: str`, `name: str`, `parent_id: str | None`, `analyzer_id: str`,
  `source_sha256: str`, `line_range: tuple[int, int] | None`, `properties: JsonObject`.
  `__post_init__` recomputes `element_identifier(kind=..., path=..., declaration=...)` and raises
  `ValueError` when `element_id` differs; it also enforces the `cli-option` parent rule and
  `1 <= start <= end` for `line_range`.
- `SurfaceDiagnostic` (frozen, `kw_only`) mirroring the docs `diagnostic` shape; its `id` is
  derived with `stable_id("diagnostic", ...)` as in
  `drm_copilot_discovery.analyzer.findings.diagnostic`.
- `element_to_json(element: SurfaceElement) -> JsonObject` and
  `diagnostic_to_json(diagnostic: SurfaceDiagnostic) -> JsonObject` project to the snapshot
  `element` and docs `diagnostic` shapes.

### Analyzer contract (`analyzer_contract.py`)

- `SurfaceAnalyzer` (`typing.Protocol`):
  - `identifier: str` (read-only property),
  - `element_kinds: tuple[ElementKind, ...]` (read-only property),
  - `analyze(self, inputs: Mapping[str, bytes], *, selection: SurfaceSelection) -> SurfaceAnalysis`.
  - Contract: pure and deterministic; no I/O; inputs are not mutated; inputs are captured bytes
    keyed by POSIX relative path; an input above the size bound yields a diagnostic rather than a
    partial result.
- `SurfaceAnalysis` (frozen): `elements: tuple[SurfaceElement, ...]` sorted by `element_id`;
  `diagnostics: tuple[SurfaceDiagnostic, ...]` sorted by `id`.
- `AnalyzerRegistration` (frozen, `kw_only`): `identifier: str` (discovery `identifier`
  grammar), `element_kinds: tuple[ElementKind, ...]` (non-empty, members of `ELEMENT_KINDS`),
  `module: str` (must start with `drm_copilot_docs.analyzers.`), `attribute: str`.
- `ANALYZER_REGISTRY: tuple[AnalyzerRegistration, ...] = ()`. A source comment states that 900003
  and 900004 append one entry per line at the end of the tuple and that order in source is not
  significant. Profiles select identifiers only; no profile can name a module.
- Helper functions:
  - `validate_registry(registry: Sequence[AnalyzerRegistration]) -> tuple[Finding, ...]`:
    error findings for a duplicate identifier, an identifier outside the grammar, empty or
    unknown kinds, and a module outside the `drm_copilot_docs.analyzers.` prefix. The committed
    `ANALYZER_REGISTRY` returns no findings.
  - `registered_identifiers(registry) -> tuple[str, ...]`: sorted identifiers.
  - `select_registrations(registry, *, kinds: Sequence[ElementKind], analyzer_ids:
    Sequence[str] | None) -> tuple[AnalyzerRegistration, ...]`: validates the full request
    before any import; `ValueError` naming the first unknown identifier or invalid registry;
    output sorted by identifier and invariant under input permutation.
  - `load_analyzer(registration, *, import_module=importlib.import_module) -> SurfaceAnalyzer`:
    refuses a module outside the prefix before calling `import_module`; checks that the loaded
    object's `identifier` and `element_kinds` equal the registration.

### Profile models and `profile.py` API

- `profile_models.py` frozen `kw_only` dataclasses: `DocsProfile`, `Audience`,
  `DocumentationRoot`, `SurfaceSelection`, `PageOwner`, `DiataxisPolicy`, `DirectoryMode`,
  `DocsCompleteGate`, `IntegrationPrGate`, `CompletionGates`, `ArtifactPaths`. Field names equal
  the schema property names; sequences are tuples; `SurfaceSelection.analyzers` is
  `tuple[str, ...] | None`.
- `profile.py`:
  - `parse_profile(content: bytes, *, format: Literal["json", "yaml"], artifact_path: str,
    registry: Sequence[AnalyzerRegistration] | None = None) -> ProfileLoadResult`. Parses through
    `drm_copilot_discovery.parsing.parse_document` (bounded, duplicate keys rejected), validates
    against `docs-profile`, applies the semantic checks against `registry` (default
    `ANALYZER_REGISTRY`), and builds the dataclasses only when no `error` finding exists.
  - `ProfileLoadResult` (frozen): `profile: DocsProfile | None`, `findings: tuple[Finding, ...]`
    ordered through `FindingCollector`, `ok: bool` (true when no `error` finding).
  - `starter_profile(*, repository_id: str) -> JsonObject`: a profile that passes schema and
    semantic validation with the empty registry (it omits `surface_selection.analyzers`).
  - `render_profile_json(value: JsonValue) -> str`: canonical JSON (sorted keys, LF).

### Schema validation and resources API

- `schema_validation.py`: `DOCS_SCHEMA_NAMES` (the six artifact names plus `common`);
  `docs_schema_id(name: str) -> str`; `build_registry(resources: Mapping[str, bytes]) ->
  referencing.Registry` (pure, offline, `check_schema` on each schema, eager `$ref` resolution,
  cached by content); `validate_artifact(value: JsonValue, *, artifact_kind: str, artifact_path:
  str, resources: Mapping[str, bytes] | None = None) -> tuple[Finding, ...]` using
  `Draft202012Validator(..., format_checker=discovery_format_checker())`, finding code
  `SCHEMA_INVALID`, pointers from `error.absolute_path`. When `resources` is `None`, the installed
  docs schemas and the installed discovery `common` are read.
- `resources.py`: `RESOURCE_DIRECTORY = "_resources"`, `MANIFEST_FILENAME = "manifest.json"`,
  `ResourceError`, `read_resource(path: str, *, read_bytes=...) -> bytes`. The manifest lists
  sorted `{path, sha256, size}` entries and `runtime_version` equal to
  `drm_copilot_docs.__version__`; a read verifies size and SHA-256 before returning bytes.

### CLI

Console scripts (root and package `pyproject.toml`):
`"dev.docs.init" = "drm_copilot_docs.cli:main_init"`,
`"dev.docs.validate-profile" = "drm_copilot_docs.cli:main_validate_profile"`. Each wrapper is a
zero-argument function returning `int` that delegates to
`run_cli(command, argv, *, ports, stdout, stderr) -> int` with injectable read and write ports.
Argument parsing uses `argparse`; `SystemExit` from parsing is caught and never escapes.

`dev.docs.init [--repository-id <identifier>] [--output <relative path>] [--force]`:

- Without `--output`, prints the starter profile to stdout and writes no file.
- `--output` writes through one exclusive-create port and refuses an existing file unless
  `--force` is given.
- `--repository-id` sets `repository.id`; the default is the neutral identifier
  `example-repository`.

`dev.docs.validate-profile [--profile <path>] [--format text|json]`:

- Default `--profile`: `docs/documentation-estate/docs-profile.json`.
- Each finding prints its JSON pointer, field name and message. A missing required field reports
  the parent pointer and the message `'<field>' is a required property`; a semantic finding points
  at the offending field.

Exit codes (both commands):

| Code | Meaning |
|---|---|
| `0` | Success or help. For `validate-profile`, no `error` finding. |
| `1` | Validation failure: `validate-profile` found at least one `error` finding; `init` rendered a starter that failed self-validation (defect guard). |
| `2` | Invocation error: unknown flag, missing flag value, `--repository-id` outside the identifier grammar, `--output` or `--profile` not a POSIX relative path. |
| `3` | Runtime or output failure: unreadable profile, unavailable or hash-mismatched schema resource, `--output` target exists without `--force`, write failure. A top-level handler writes a fixed stderr line and returns `3`. |

Example invocations:

- `poetry run dev.docs.init` prints a starter profile and exits `0`.
- `poetry run dev.docs.validate-profile --profile examples/docs/v1/docs-profile.example.json`
  exits `0`.
- Validating a profile without `audiences` exits `1` and prints the root pointer (the empty
  RFC 6901 pointer) with the message `'audiences' is a required property`.

## Data & State

- Data transformations and invariants:
  - Element identity is a pure function of kind, path and declaration.
  - Profiles, snapshots, ledgers, matrices, pins and receipts are validated against closed
    schemas; all ordering is deterministic (findings by `finding_key`, elements by `element_id`,
    pins by `pin_id`).
  - Framework code and schemas contain no consumer-specific names; all repository specificity is
    profile data.
- Caching: the schema registry is built once per process and cached keyed by resource content
  (immutable), so tests with different in-memory resources do not share state.
- Persistence: this feature writes only the optional `--output` starter profile. Ledger and matrix
  writes belong to 900005.
- Distribution state:
  - `packages/docs-runtime/resource-manifest.json`: allowlist of `schemas/docs/v1/*.schema.json`
    files to stage. Staging enumerates only allowlisted files and does not reject other files in
    `schemas/docs/v1/` (900002 adds `page-metadata.schema.json` for its own package).
  - `packages/docs-runtime/src/drm_copilot_docs/_resources/schemas/docs/v1/` and
    `_resources/manifest.json`: staged copies plus a sorted SHA-256 manifest.
  - No `_build_manifest.json` is created; it exists for discovery gateway trust and this feature has
    no gateway.
- Migration or backfill: none.

## Constraints & Risks

- The naming contract in the epic manifest `## Shared Design` section is fixed; this feature may not
  change it.
- Downstream features consume these schemas and contracts, so they must be stated precisely.
- Reliance on assumption A5 (provisional, not approved by the owner): package placement in
  `packages/docs-runtime`, import name `drm_copilot_docs`, discovery reused as a library. If A5 is
  rejected, the package path, import name, distribution name, root registration, tier entry and
  every downstream module path in this specification change. A6 (no MCP work here) is also relied
  on. A1-A4 do not affect this feature.
- Consumer installation follows the discovery runtime mechanism: a docs-owned builder
  `scripts/dev_tools/build_docs_runtime.py` (`--check`, `--stage-only`, default builds
  `dist/docs/drm_copilot_docs-1.0.0-py3-none-any.whl` with `pip wheel --no-index --no-deps
  --no-build-isolation`), staged `_resources` copies with a SHA-256 manifest, and
  `drm_copilot_docs/resources.py`. A consumer runs `python -I -m pip install` with the discovery
  wheel and the docs wheel, both built from this repository. The builder reuses
  `scripts.dev_tools.build_discovery_runtime.verify_schema_closure` and
  `drm_copilot_discovery.resources.validate_resource_path` unchanged.
- Discovery runtime files and behavior are unchanged: no file under `packages/discovery-runtime/`
  or `schemas/discovery/`, and neither `scripts/dev_tools/build_discovery_runtime.py` nor
  `scripts/dev_tools/discovery_build_identity.py`, is edited.
- No test creates temporary files; pure cores take in-memory mappings and I/O stays in thin CLI modules.
- Shared append-only files (`pyproject.toml`, `poetry.lock`) are also edited by sibling features.
- `quality-tiers.yml` and `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
  are also edited by 900002 (which adds `packages/docs-page-check`). These files are not listed in the
  epic conflict surface. The conflict is append-only and is resolved in the later child's
  remediation loop.
- `analyzer_contract.py` is appended to by 900003 and 900004; the one-entry-per-line form keeps those
  conflicts to adjacent lines.
- Poetry resolution (unverified): whether Poetry resolves the docs package's range dependency on
  `drm-copilot-discovery` alongside the root directory dependency without a lock conflict has not
  been verified. Fallback: regenerate `poetry.lock` in the item worktree; `poetry check --lock`
  must pass and `git diff --exit-code poetry.lock` must be clean after `poetry install`.
- Freshness of staged copies: CI does not run any runtime builder. Stale copies are caught by the
  byte-equality test and by the builder `--check` mode.
- Batch budget: the feature creates more than three non-test Python production files, so execution
  must run on the large route in the item worktree that holds the orchestration checkpoint.
- Test collection: pytest runs in prepend import mode. `tests/docs_runtime/__init__.py` is required,
  and the resource and schema-validation tests carry a `docs_` prefix to avoid basename collisions
  with `tests/discovery_runtime/` and 900002 tests.
- The epic file list names `tests/schemas/docs_schemas/`; this feature uses `tests/schemas/docs/`,
  mirroring `schemas/docs/` as `tests/schemas/discovery/` mirrors `schemas/discovery/`. This is a
  file-list refinement, not a naming-contract change.
- Neutrality: the configured consumer identifiers are stored only as lowercase hex SHA-256 digests
  of lowercase word tokens, never as plaintext.

## Implementation Strategy

- Implementation scope:
  - Create `packages/docs-runtime/pyproject.toml` (backend `poetry.core.masonry.api`, requires
    `poetry-core>=1.9.0`; name `drm-copilot-docs`; version `1.0.0`;
    `packages = [{ include = "drm_copilot_docs", from = "src" }]`; `include` for `py.typed`; the
    two console scripts; dependencies `python = ">=3.10,<4.0"`,
    `drm-copilot-discovery = ">=2.0.0,<3.0.0"`, `jsonschema = "^4.25.1"`,
    `referencing = ">=0.37,<0.38"`, `PyYAML = ">=6.0"`), `README.md`, `resource-manifest.json`.
  - Create `packages/docs-runtime/src/drm_copilot_docs/`: `__init__.py` (`__version__ = "1.0.0"`),
    `py.typed`, `profile_models.py`, `profile.py`, `schema_validation.py`, `resources.py`,
    `surface_models.py`, `analyzer_contract.py`, `cli.py`, and the staged `_resources/` tree.
  - Create `scripts/dev_tools/build_docs_runtime.py`.
  - Create `schemas/docs/v1/common.schema.json` and the six artifact schemas, and six examples
    `examples/docs/v1/<name>.example.json`.
  - Edit root `pyproject.toml` (append only): `[tool.poetry.dependencies]`
    `drm-copilot-docs = { path = "packages/docs-runtime", develop = true }`; the two
    `[tool.poetry.scripts]` entries; `"packages/docs-runtime/src"` in `[tool.coverage.run] source`
    and in `[tool.pyright] include`.
  - Regenerate `poetry.lock`.
  - Edit `quality-tiers.yml`: classify `packages/docs-runtime` as `T2`. Update
    `test_committed_quality_tiers_yml_assigns_spec_tiers` so the expected elevated list contains
    `packages/discovery-runtime` and `packages/docs-runtime`.
- Tests:
  - `tests/docs_runtime/__init__.py`, `test_profile.py`, `test_profile_properties.py`,
    `test_surface_models.py`, `test_analyzer_contract.py`, `test_cli.py`, `test_neutrality.py`,
    `test_docs_schema_validation.py`, `test_docs_resources.py`, `test_docs_package_contract.py`.
  - `tests/schemas/docs/test_docs_schemas_v1.py`: `check_schema`, `$id`, closed roots, every
    example validates, and per artifact schema one in-memory mutation deleting a required field and
    one setting an unknown element kind or disposition, each producing errors; offline closure
    through `verify_schema_closure` with discovery `common` included.
  - `tests/scripts/dev_tools/test_build_docs_runtime.py` with an in-memory filesystem.
  - Property tests use exhaustive `itertools.product` and `itertools.permutations` enumerations
    (identifier determinism and injectivity across all element kinds, paths with separators and
    non-ASCII characters, and boundary concatenations; starter validity over repository
    identifiers; render round trip and key-order invariance; registry selection order
    invariance).
  - Neutrality test (`tests/docs_runtime/test_neutrality.py`): a module-level tuple of configured
    digests
    `bbddb9f7a8340215503f6089cb5364689432a9cfb261cd7683c4fe2f20760f6b` and
    `59f0db478528b4c446cfaf3d5b8a358dc500a6d97b29a215ee8c216a2f7174e2`; a pure helper tokenizes text
    (lowercase, split on non-alphanumeric characters), hashes each token with SHA-256 and reports
    matches; a parametrized read-only scan covers every file under `packages/docs-runtime/src/` and
    `schemas/docs/`; a positive control injects a synthetic token into an in-memory mapping, adds its
    digest to the configured set for that call, and asserts detection.
  - CLI tests pass `io.StringIO` streams and in-memory ports and assert exit codes `0`, `1`, `2`, `3`.
- Dependency changes: none new. `hypothesis` is not approved and is not added. The docs package
  declares only dependencies already in the root environment plus the local discovery package.
- Logging and telemetry: none added; CLI diagnostics go to stderr.
- Rollout: additive. No feature flag. Consumers opt in by installing the docs wheel.

## Acceptance Criteria

- [ ] Every example under `examples/docs/v1/` validates against its schema; each schema rejects a missing required field and an unknown disposition or element kind.
- [ ] `dev.docs.validate-profile` exits 0 for the example profile and non-zero with a message naming the failing field for an invalid profile; `dev.docs.init` emits a starter profile that validates.
- [ ] Element identifiers are deterministic (property test: same kind, path and declaration yield the same identifier; distinct inputs yield distinct identifiers).
- [ ] A neutrality test fails when a configured consumer identifier appears under `packages/docs-runtime/src/` or `schemas/docs/`.
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs`.
- [ ] For every schema file listed in `packages/docs-runtime/resource-manifest.json`, `drm_copilot_docs.resources.read_resource` returns bytes equal to the canonical file under `schemas/docs/v1/`, and `_resources/manifest.json` records that file's SHA-256 and size; a test in `tests/docs_runtime/test_docs_package_contract.py` asserts both.
- [ ] `scripts.dev_tools.build_docs_runtime.main(["--check"], ...)` returns 0 when every staged copy and the staged manifest match the canonical bytes, returns non-zero and names the drifted path on stderr when a staged copy is missing or differs, and writes no file in either case (in-memory filesystem test); `poetry run python -m scripts.dev_tools.build_docs_runtime --check` exits 0 on the feature branch.
- [ ] The root `pyproject.toml` contains `drm-copilot-docs = { path = "packages/docs-runtime", develop = true }` under `[tool.poetry.dependencies]`, the script entries `dev.docs.init = drm_copilot_docs.cli:main_init` and `dev.docs.validate-profile = drm_copilot_docs.cli:main_validate_profile` under `[tool.poetry.scripts]`, and `packages/docs-runtime/src` in both `[tool.coverage.run] source` and `[tool.pyright] include`; a test in `tests/docs_runtime/test_docs_package_contract.py` asserts each entry.
- [ ] `poetry check --lock` exits 0 with the committed `poetry.lock`, and `git diff --exit-code poetry.lock` reports no change after `poetry install`.
- [ ] `quality-tiers.yml` classifies `packages/docs-runtime` as `T2`; `python -m scripts.dev_tools.check_quality_tiers` exits 0 and the updated `test_committed_quality_tiers_yml_assigns_spec_tiers` passes.
- [ ] Discovery runtime files are unchanged: `git diff --name-only` between the merge base with `main` and the feature head returns no path under `packages/discovery-runtime/` or `schemas/discovery/` and neither `scripts/dev_tools/build_discovery_runtime.py` nor `scripts/dev_tools/discovery_build_identity.py`.
- [ ] `analyzer_contract.validate_registry` returns an `error` finding for a registry containing two registrations with the same identifier and for a registration whose `module` does not start with `drm_copilot_docs.analyzers.`; `load_analyzer` refuses such a registration without calling the injected `import_module`; the committed `ANALYZER_REGISTRY` yields no findings.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests (empty file, invalid JSON, duplicate keys, YAML profile, unknown analyzer identifier, duplicate audience identifiers, unknown audience reference, directory mode outside the policy)
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs`, measured with `--cov=drm_copilot_docs --cov-branch` and read from the JSON report
- [ ] Line coverage >= 85% and branch coverage >= 75% for `scripts.dev_tools.build_docs_runtime`, measured with `--cov=scripts.dev_tools.build_docs_runtime --cov-branch` and read from the JSON report
- [ ] At least one property test per pure function in `drm_copilot_docs` (T2 obligation)
- [ ] No production source file exceeds 500 lines
- [ ] Docs updated (`packages/docs-runtime/README.md`: staged resources, builder commands, wheel install line)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → architecture → test → contract → integration) in a single clean pass
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/<kind>/`

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: profile loading and validation, surface identities, analyzer registry, CLI.
- [ ] Integration scenarios: example artifacts validate against each schema; schema references resolve into discovery v2.
- [ ] CLI/API examples: `dev.docs.init`, `dev.docs.validate-profile`.
