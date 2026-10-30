# docs-profile-and-artifact-schemas (Issue #1020) - Research

- Feature: 900001 of epic #1019 (documentation-estate-tooling), wave 0, band C3
- Branch: `feature/docs-profile-and-artifact-schemas-1020`
- Mode: preparation research only; no source, configuration or test file was changed
- Sources read: `docs/features/epics/documentation-estate-tooling/epic.md` (`## Shared Design`,
  `## Assumptions Pending Owner Confirmation`, `### Cross-feature conflict surface`, sections 900001
  through 900010), the feature `issue.md`, and every repository file cited below.
- Path note: the delegation named `research/research.md`. The SubagentStop hook
  `.claude/hooks/validate-task-researcher-output.ps1` (`Test-IsValidResearchFileName`) rejects that
  name, so this file uses the required `<timestamp>-<short-name>-research.md` form in the same
  `research/` folder.
- Assumption status: A1-A6 in the epic are provisional and unapproved. This research relies on A5
  (package placement `packages/docs-runtime`, import `drm_copilot_docs`, discovery reused as a
  library) and A6 (no MCP work in 900001). Where a recommendation depends on them it says so.

## 1. Current State Analysis

### 1.1 Discovery runtime surfaces 900001 reuses

All modules below exist under `packages/discovery-runtime/src/drm_copilot_discovery/` and were read.

| Module | Public symbols relevant to 900001 | Behavior |
|---|---|---|
| `analyzer/findings.py` | `row(**values) -> JsonObject`, `stable_id(prefix: str, value: JsonValue) -> str`, `tool`, `source_reference`, `diagnostic`, `seed_component` | `stable_id` returns `prefix + "-" + sha256(canonical_json(value)).hexdigest()`. Inputs are a caller label and a frozen JSON value; output is the label, a hyphen and 64 lowercase hex characters. `diagnostic` derives its own ID with `stable_id("diagnostic", row(code, path, analyzer))`. |
| `models.py` | `JsonObject`, `JsonValue`, `JsonScalar`, `canonical_json`, `to_plain_value`, `ParseLimits` | `canonical_json` renders `json.dumps(sort_keys=True, separators=(",", ":"), ensure_ascii=False, allow_nan=False)` plus LF, UTF-8 encoded. `JsonObject` is a frozen, key-sorted, deeply immutable mapping. |
| `findings.py` (package root) | `Finding`, `Severity`, `FindingCollector`, `child_pointer`, `validate_finding_path`, `ordered_findings`, `MAX_FINDINGS` | Wire-compatible diagnostics: code `^[A-Z][A-Z0-9_]*$`, severity `error`/`warning`/`info`, RFC 6901 pointer, related IDs and relative paths; `Finding.to_dict` gives the service-result finding shape. |
| `parsing.py` | `parse_document(content, *, format: "json" or "yaml", artifact_path, limits) -> ParsedDocument` | Bounded JSON/YAML parse with duplicate-key detection, returning an immutable value or findings. |
| `schema_validation.py` | `discovery_format_checker()`, `is_rfc3339_timestamp`, `is_http_evidence_uri`, `SchemaValidationResult`, `validate_document` | Uses `jsonschema.Draft202012Validator` with the `registry` from a `SchemaCatalog` and a format checker that registers only `date-time` and `uri`. `validate_document` is bound to the discovery catalog and cannot validate docs kinds. |
| `catalog.py` | `DIALECT`, `V2_URN`, `SchemaCatalog`, `load_catalog`, `schema_path`, `schema_aliases`, `CatalogError` | `SchemaCatalog.__post_init__` requires exactly the fixed discovery v1/v2 identity set, so docs schemas cannot be added to it. The registry is built with `referencing.Registry(retrieve=_deny_retrieval)` (offline), every `$ref` base must be a registered `$id`, nested `$id` is rejected, and any `format` other than `date-time` or `uri` is rejected. |
| `resources.py` | `read_resource(path, *, manifest, read_bytes)`, `load_resource_manifest`, `parse_resource_manifest`, `render_resource_manifest`, `validate_resource_path`, `ResourceError`, `RESOURCE_DIRECTORY`, `MANIFEST_FILENAME` | Reads hash-verified staged resources from the installed package through `importlib.resources`. `ResourceManifest` requires `runtime_version == drm_copilot_discovery.__version__` ("2.0.0"), so the manifest classes cannot be reused for a docs package with its own version. |
| `analyzer/registry.py` | `InventoryAdapter` (Protocol: `identifier` property, `analyze(capture) -> Analysis`), `builtin_analyzer_identities`, `normalized_analyzer_ids`, `select_analyzers`, `InventoryRegistry`, `InstalledInventoryRegistry` | Fixed identifier tuple `_BUILTIN_IDENTIFIERS`; profiles select inert identifiers; implementations load through literal lazy imports in `_generic_analyzer`; the full request is validated before any import. |
| `analyzer/pipeline.py` | `Analyzer` (legacy parse/classify/map/emit Protocol), `AnalyzerFileSystem`, `RealAnalyzerFileSystem`, `run_analyzer`, `run_inventory`, `plan_inventory` | Legacy staged contract; the module docstring states v2 adapters consume retained bytes and publication requires a guarded mutation. |
| `analyzer/input_capture.py` | `capture_inputs`, `capture_snapshot`, `exclusion_rules`, `exclusion_reason`, `pin_inventory_sources`, `MAX_CAPTURE_BYTES` | Bounded captured bytes and digests through injected readers; coupled to `ProfileV2` (the discovery profile), so 900001 does not call it. It is a 900003 concern (`snapshot_builder.py`). |
| `mutation_io.py` | `capture_workspace`, `MutationWriter`, `MutationPrimitives`, `GuardedMutationWriter`, `MutationArtifact`, `MutationResult`, `commit_mutation` | Single write boundary; consumed by 900005 (`mutation.py`), not by 900001. |
| `revision_rules.py` | `is_full_revision`, `RevisionInputs`, `RevisionValidation`, `validate_revisions` | Full 40/64-hex revision checks; 900005 pins. |
| `evidence_rules.py` | `EvidenceAssessment`, `EvidenceValidation`, `assess_evidence`, `validate_evidence` | Evidence reference semantics; 900005 pins. |

Import side effect: `drm_copilot_discovery.analyzer.findings` imports the package
`drm_copilot_discovery.analyzer`, whose `__init__.py` imports `analyzer.registry`, which imports
`analyzer.inventory` and `profile_v2`. These are pure imports with no I/O; the cost is import time
only.

Symbols 900001 imports (no discovery file is edited; all imports are absolute, matching the
`verify_import_closure` rule in `scripts/dev_tools/build_discovery_runtime.py`):

- `from drm_copilot_discovery.analyzer.findings import row, stable_id` (element identity).
- `from drm_copilot_discovery.models import JsonObject, JsonValue, ParseLimits, canonical_json, to_plain_value`.
- `from drm_copilot_discovery.findings import Finding, FindingCollector, child_pointer, validate_finding_path`.
- `from drm_copilot_discovery.parsing import parse_document`.
- `from drm_copilot_discovery.schema_validation import discovery_format_checker`.
- `from drm_copilot_discovery.catalog import DIALECT, V2_URN, CatalogError` (constants and error type only).
- `from drm_copilot_discovery.resources import read_resource, validate_resource_path` (to read the
  installed discovery `schemas/discovery/v2/common.schema.json`, hash-verified).

### 1.2 Discovery schemas and examples

- Dialect: every v2 schema declares `"$schema": "https://json-schema.org/draft/2020-12/schema"`.
- `$id` convention: `urn:drm-copilot:discovery:2.0.0:<kind>` (for example
  `urn:drm-copilot:discovery:2.0.0:common`).
- References: always the absolute URN plus a JSON pointer, for example
  `{"$ref": "urn:drm-copilot:discovery:2.0.0:common#/$defs/identifier"}`; local definitions use
  `#/$defs/<name>`.
- `$defs` naming: lowercase kebab-case (`relative-path`, `artifact-reference`,
  `coverage-disposition`, `validation-outcome`).
- Artifact header: required `$schema` (const equal to the `$id`), `schema_version` (const
  `"2.0.0"`), `artifact_kind` (const), `id` (common `identifier`), and `extensions` (common
  `extensions`). Objects are closed (`additionalProperties: false`), every property is listed in
  `required`, and inapplicable companion fields are `null` rather than absent.
- Conditional companions: `coverage-ledger.schema.json` `$defs/component` uses `allOf` of
  `if`/`then`/`else` blocks keyed on `disposition` (for example `excluded` requires
  `exclusion_rationale` text, and every other disposition requires it to be `null`).
- `common.schema.json` reusable definitions used below: `identifier`, `text`, `revision`, `sha256`,
  `timestamp` (`format: date-time`), `relative-path`, `path-or-glob`, `identifiers`, `paths`,
  `exclusion`, `exclusions`, `extensions`, `json-value`, `validation-outcome`, `confidence`.
- `validation-receipt.schema.json` binds `validation_result` to `findings` (pass: no `error`
  severity; fail: at least one `error`) and references `service-result#/$defs/finding`, whose
  required keys equal `Finding.to_dict`.
- Examples: `examples/discovery/v2/<kind>.example.yaml` (v1 uses `.example.json`). Invalid
  fixtures: `tests/fixtures/discovery_schemas/v2/<kind>.invalid.yaml`.
- Schema tests: `tests/schemas/discovery/` (no `__init__.py`), with shared helpers in
  `v2_schema_test_support.py` (`load_schema`, `load_fixture`, `schema_validator` building an
  offline `referencing.Registry` from the committed schema files, `schema_errors`). Tests such as
  `test_v2_common_schemas.py` assert `Draft202012Validator.check_schema`, the `$id`, closed
  objects, and that the packaged copy equals the canonical bytes
  (`read_resource(...) == (SCHEMAS / ...).read_bytes()`); several call
  `scripts.dev_tools.build_discovery_runtime.verify_schema_closure` for offline closure.

### 1.3 Package layout and toolchain

- `packages/discovery-runtime/pyproject.toml`: backend `poetry.core.masonry.api` (requires
  `poetry-core>=1.9.0`); name `drm-copilot-discovery`; version `2.0.0`;
  `packages = [{ include = "drm_copilot_discovery", from = "src" }]`; `include` lists `py.typed` and
  `_build_manifest.json`; its own `[tool.poetry.scripts]` declares every `dev.discovery.*` entry as
  `drm_copilot_discovery.cli:main_*`; dependencies `python >=3.10,<4.0`, `PyYAML >=6.0`,
  `jsonschema ^4.25.1`, `referencing >=0.37,<0.38`, `lxml >=5.3.0`.
- `packages/discovery-runtime/README.md` documents the staged `_resources/` tree, the build
  manifest, the builder commands and the wheel install line.
- Root `pyproject.toml`:
  - `[tool.poetry.dependencies]`: `drm-copilot-discovery = { path = "packages/discovery-runtime", develop = true }`.
  - `[tool.poetry.scripts]`: the same `dev.discovery.*` entries repeated, after `dev.collect-commit-context` and before `dev.fix-all`.
  - `[tool.poetry.group.dev.dependencies]`: pytest, pytest-cov, black, ruff, pyright, pyperclip, jsonschema, types-beautifulsoup4, types-requests. `hypothesis` is absent (see section 7).
  - `[tool.pytest.ini_options]`: `testpaths = ["tests"]`, `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, default (prepend) import mode.
  - `[tool.coverage.run] source = ["src", "scripts/dev_tools", "packages/discovery-runtime/src"]`.
  - `[tool.pyright] include = ["scripts", "src", "packages/discovery-runtime/src", "tests"]`, strict mode.
  - `[tool.ruff]`/`[tool.ruff.lint]`: repository-wide selection `E, F, I, B, UP, S, TID, TCH`; `tests/**/*` ignores `S101`; no `src` setting, so `drm_copilot_discovery` sorts as third-party (observed in `tests/discovery_runtime/test_package_contract.py`).
- `poetry.lock` records the discovery package as `[package.source] type = "directory"`,
  `url = "packages/discovery-runtime"`, `develop = true`.
- Package tests live in `tests/discovery_runtime/` (flat, named after the distribution folder, not
  mirroring `src/drm_copilot_discovery/`), with a mirrored subpackage folder
  `tests/discovery_runtime/analyzer/` that carries an `__init__.py`.
- `tests/discovery_runtime/test_package_contract.py`
  (`test_root_tooling_includes_the_local_runtime_for_types_and_coverage`) pins the discovery path
  dependency and its presence in `[tool.coverage.run]` and `[tool.pyright]`. Its assertions use
  `startswith`/`split` and are unaffected by appended docs entries.
- CI (`.github/workflows/_quality-checks.yml`): `poetry install`, `poetry check --lock` plus
  `git diff --exit-code poetry.lock`, `black --check .`, `ruff check`, `pyright`, the Codex
  generator check, `python -m scripts.dev_tools.check_quality_tiers`, `pytest --cov --cov-branch`,
  and `check_python_coverage_thresholds --min-line 85 --min-branch 75` on the JSON totals.
  `.github/workflows/_build-check.yml` runs `poetry build` for the root project and installs the
  resulting wheel in a fresh virtual environment.

### 1.4 Distribution to consumer repositories (verified mechanism)

The discovery runtime is not bundled inside the VSIX or the standalone MCP npm package:

- `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` asserts that `.vscodeignore`
  contains `**/*.py` and `resources/scripts/**`, and that `packages/mcp-server/prepack.cjs`
  `shouldCopy` rejects Python sources.
- The consumer installs a wheel built locally from this repository:
  `poetry run python -m scripts.dev_tools.build_discovery_runtime` stages resources and writes
  `dist/discovery/drm_copilot_discovery-<version>-py3-none-any.whl` (`dist/` is untracked), and
  the README instructs `python -I -m pip install <wheel>` into the trusted interpreter.
- The extension invokes the installed module only: `extensions/drm-copilot/src/discovery-runtime.ts`
  spawns `python -I -m drm_copilot_discovery.gateway` (`DISCOVERY_GATEWAY_MODULE`) and names
  `DISCOVERY_WHEEL_FILE_NAME` in install guidance when the module is missing.

Registration points that list the discovery runtime for building and distribution:

| File | Role |
|---|---|
| `packages/discovery-runtime/resource-manifest.json` | Allowlist of canonical resource roots and files copied into the package. |
| `packages/discovery-runtime/src/drm_copilot_discovery/_resources/` and its `manifest.json` | Staged schema and template copies plus a sorted SHA-256 manifest verified before any read. |
| `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json` | Installed-content identity of every source and resource file (gateway trust). |
| `scripts/dev_tools/build_discovery_runtime.py` | Builder: constants `PACKAGE_ROOT`, `SOURCE_ROOT`, `STAGE_ROOT`, `ALLOWLIST_PATH`, `RESOURCE_ROOTS = ("schemas/discovery", "docs/discovery/templates")`, `DEPENDENCY_IMPORTS`; functions `parse_allowlist`, `verify_schema_closure`, `make_resource_stage`, `verify_import_closure`, `stage_resources`, `build_wheel`, `main` (`--check`, `--stage-only`, `--output`). |
| `scripts/dev_tools/discovery_build_identity.py` | Build-identity staging used by the builder. |
| Root `pyproject.toml` | Path dependency, console scripts, coverage source, pyright include. |
| `quality-tiers.yml` | `packages/discovery-runtime` classified `T2`. |
| `extensions/drm-copilot/src/discovery-runtime.ts` | Wheel file name constant and gateway module name. |

Tests that pin these points: `extensions/drm-copilot/test/packaging/discovery-resources.test.ts`
(`names the Python wheel runtime requirement explicitly` reads only the discovery `pyproject.toml`
version), `tests/discovery_runtime/test_package_contract.py`, `tests/discovery_runtime/test_resources.py`,
`tests/scripts/dev_tools/test_build_discovery_runtime.py`, `test_build_discovery_runtime_io.py`,
`test_discovery_build_identity.py`, `tests/discovery_runtime/test_build_identity.py`, the schema tests
under `tests/schemas/discovery/`, and
`tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
(`test_committed_quality_tiers_yml_assigns_spec_tiers`).

The builder cannot be reused for docs without editing it: `ResourceAllowlist.__post_init__` rejects
any root outside `RESOURCE_ROOTS`, `verify_import_closure` treats every non-discovery,
non-allowlisted import as an undeclared dependency, and `build_wheel` hard-codes the discovery
package root and wheel name. `verify_schema_closure(resources: Mapping[str, bytes])` is generic and
importable unchanged.

CI does not run the discovery builder (`--check` appears in no workflow); freshness of staged
copies is enforced by the schema tests that compare `read_resource` output with the canonical
bytes.

### 1.5 CLI conventions

- One `cli.py` module holds zero-argument console wrappers `main_<command>() -> int`, each
  forwarding to `run_installed_cli(command)`, which composes injectable ports (`CliPorts`) and calls
  `run_cli(command, argv, *, ports, stdout, stderr, limits) -> int`. Argument parsing lives in
  `cli_arguments.py` (custom bounded parser, no argparse). Output streams are parameters, so tests
  pass `io.StringIO`.
- Exit codes: `0` success or help, `1` validation failure reported by the service, `2` invocation
  error, `3` runtime or output failure (`Literal[0, 1, 2, 3]` on `DiscoveryResult.exit_code` in
  `service_contracts.py`; `_failure` uses `2`/`3`). A top-level `except Exception` with
  `# noqa: BLE001` writes a fixed stderr line and returns `3`.
- Repository tooling CLIs under `scripts/dev_tools/` (for example `build_discovery_runtime.main`)
  use `argparse` with injected collaborators and return `int`.

### 1.6 Neutrality tests

- `tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py`: module-level
  `_BANNED_CONSUMER_IDENTIFIERS` tuple; each production module (including
  `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/` and `analyzer/optional/`) is read,
  lowercased and scanned for substrings in a `pytest.mark.parametrize` test per file; a positive
  control (`test_permitted_stack_literals_do_not_trip_the_ban`) proves permitted literals remain in
  scope.
- `tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py`: `_BANNED_SUBSTRINGS`
  tuple scanned over the analyzer framework, with AST-based exemptions for exact registry spans.
- `tests/scripts/dev_tools/discovery/test_domain_neutrality.py`: `DISALLOWED_TOKEN_PATTERN` regex
  applied to templates and to rendered v2 drafts.
- All three hard-code the banned tokens in the test module. None reads a configured list.

### 1.7 Origin/main state against the naming contract

Searches over the whole worktree (excluding `docs/features/`) for `schemas/docs/`, `examples/docs/`,
`packages/docs-*`, `tests/docs_runtime/`, `drm_copilot_docs`, `dev.docs.` and `urn:drm-copilot:docs`
returned no matches. Nothing on the branch conflicts with the naming contract.

## 2. Candidate Approaches

### 2.1 Distribution of the docs runtime

Selected: replicate the discovery staging pattern in a docs-owned builder.

- Add `packages/docs-runtime/resource-manifest.json` (allowlist of `schemas/docs/v1/*.schema.json`),
  staged copies under `packages/docs-runtime/src/drm_copilot_docs/_resources/schemas/docs/v1/` with a
  sorted SHA-256 `manifest.json`, a small `drm_copilot_docs/resources.py` (read through
  `importlib.resources`, verify size and SHA-256), and `scripts/dev_tools/build_docs_runtime.py`
  (`--check`, `--stage-only`, default builds `dist/docs/drm_copilot_docs-<version>-py3-none-any.whl`
  with `pip wheel --no-index --no-deps --no-build-isolation`).
- Reuse `scripts.dev_tools.build_discovery_runtime.verify_schema_closure` for closure, passing the
  docs schemas plus the canonical `schemas/discovery/v2/common.schema.json` bytes, and reuse
  `drm_copilot_discovery.resources.validate_resource_path` for path spelling.
- Staging enumerates only allowlisted files and does not reject unlisted files under
  `schemas/docs/v1/`, because 900002 adds `schemas/docs/v1/page-metadata.schema.json` for a separate
  package. 900006 appends that file to the docs allowlist only if `drm_copilot_docs` must validate
  it at runtime.
- Consumer installation: `python -I -m pip install dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl dist/docs/drm_copilot_docs-1.0.0-py3-none-any.whl`
  (both wheels built from this repository); the docs wheel declares `drm-copilot-discovery` as a
  version-range dependency so pip resolves it from the supplied discovery wheel.
- A build-identity manifest (`_build_manifest.json`) is not required: it exists for discovery
  gateway trust, and 900001 has no gateway.

Rationale: the naming contract fixes canonical schemas at `schemas/docs/v1/`, outside the package
root, and poetry-core can only package files inside the package directory, so installed copies must
be staged. This keeps discovery files unchanged.

Rejected alternatives:

- Generalize `build_discovery_runtime.py` to build both packages: edits discovery tooling and its
  pinned tests (`test_build_discovery_runtime*.py`), contrary to the epic non-goal of not changing
  discovery behavior, and enlarges the conflict surface.
- Store schemas only inside the package: violates the `schemas/docs/v1/` naming contract.
- Read schemas from a source checkout at runtime: fails in a consumer repository, which has no
  checkout of this repository.

### 2.2 Docs schema loading with references into discovery v2 common

Selected: `drm_copilot_docs/schema_validation.py` builds its own offline `referencing.Registry`
(`retrieve` raises `referencing.exceptions.NoSuchResource`) from the docs v1 schemas (read through
`drm_copilot_docs.resources`) plus discovery `common` (read through
`drm_copilot_discovery.resources.read_resource("schemas/discovery/v2/common.schema.json")`), checks
each schema with `Draft202012Validator.check_schema`, resolves every `$ref` eagerly, and validates
with `Draft202012Validator(schema, registry=..., format_checker=discovery_format_checker())`.
Parsing uses `parse_document`, and diagnostics use `Finding`/`FindingCollector`/`child_pointer`
with code `SCHEMA_INVALID` and pointers built from `error.absolute_path` (the same projection as
`_add_schema_errors`). Readers are injectable so tests stay in memory. The registry is built once per
process and cached by content, following the `_REGISTRY_CACHE` precedent in `catalog.py`.

Rejected alternatives: inject docs schemas into `SchemaCatalog` (its `__post_init__` rejects any
identity outside the fixed discovery set); copy discovery `common` into `schemas/docs/v1/` (a
second, drifting copy of the shared vocabulary).

### 2.3 Analyzer registry form

Selected: an append-only tuple of frozen `AnalyzerRegistration` records in `analyzer_contract.py`
holding string module and attribute names, loaded through an injectable `import_module` seam guarded
by a fixed module prefix (detailed in section 4.4). One line per analyzer keeps the 900003/900004
append conflict to adjacent lines.

Rejected alternative: discovery's literal `if identifier == ...` dispatch function; every new
analyzer edits a function body and a separate identifier tuple, which doubles the conflict surface
for two parallel wave-1 features.

## 3. Behavior Semantics

- `dev.docs.init`: emits a starter profile that validates against `docs-profile.schema.json` and
  the semantic checks. Default output is stdout (no write). `--output <relative path>` writes the
  file through one injected exclusive-create seam and refuses an existing file unless `--force`.
  `--repository-id <identifier>` sets `repository.id`; otherwise a neutral default identifier is
  used (no consumer name).
- `dev.docs.validate-profile [--profile <path>] [--format text|json]`: default path
  `docs/documentation-estate/docs-profile.json`. Exit `0` with no `error` findings; `1` when any
  schema or semantic finding has severity `error`, printing each finding's JSON pointer, field name
  and message (a missing required field reports the parent pointer and the jsonschema message
  `'<field>' is a required property`; semantic findings point at the offending field); `2` for
  usage errors (argparse failure caught, no `SystemExit` escapes); `3` for unreadable files or
  unavailable schema resources.
- Ordering: findings are sorted by `drm_copilot_discovery.findings.finding_key` through
  `FindingCollector`, so output is deterministic.
- Edge cases: empty file, invalid JSON, duplicate keys (reported by `parse_document`), YAML profile
  accepted when the extension is `.yaml`/`.yml` (the epic example is JSON), unknown analyzer
  identifier (error naming `/surface_selection/analyzers/<n>`), duplicate audience identifiers,
  a page owner or directory mode referencing an unknown audience or a mode outside the policy.

## 4. Requirements Mapping and Contract Design

### 4.1 Schema identity and reference form (recommended)

- `$schema`: `https://json-schema.org/draft/2020-12/schema`.
- `$id`: `urn:drm-copilot:docs:1.0.0:<name>`, where `<name>` is the file stem without
  `.schema.json` (for example `urn:drm-copilot:docs:1.0.0:docs-profile`).
- Header for every artifact schema: `$schema` (const equal to the `$id`), `schema_version` (const
  `"1.0.0"`), `artifact_kind` (const equal to `<name>`), `id`
  (`urn:drm-copilot:discovery:2.0.0:common#/$defs/identifier`), `extensions`
  (`urn:drm-copilot:discovery:2.0.0:common#/$defs/extensions`).
- Cross-family references use the absolute discovery URN:
  `{"$ref": "urn:drm-copilot:discovery:2.0.0:common#/$defs/relative-path"}`. Docs-internal shared
  references use `{"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/element-kind"}`; local ones use
  `#/$defs/<name>`. `$defs` names are kebab-case; property names are snake_case.
- Formats: only `date-time` (and `uri` if ever needed) because `discovery_format_checker` registers
  only those. A calendar date (`last_reviewed`) uses a pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`, with
  calendar validity checked in Python, not `format: date`.
- No nested `$id`, and no reference outside the docs v1 set plus discovery `common`.

Refinement of the epic file list: add `schemas/docs/v1/common.schema.json` (`$id`
`urn:drm-copilot:docs:1.0.0:common`) holding the docs shared vocabulary, mirroring discovery
`common`. It is definitions only (no artifact header, no example, cannot be selected as an
artifact kind). This is a file-list refinement permitted by the epic ("Each child's research may
refine file names"); it does not change the naming contract. If the orchestrator prefers not to add
a seventh file, the same `$defs` can live in `surface-inventory-snapshot.schema.json` and be
referenced from the other five (orchestrator to confirm).

### 4.2 Docs common `$defs`

| Definition | Shape |
|---|---|
| `element-kind` | `enum: ["cli-command", "cli-option", "http-route", "config-key", "public-symbol", "architecture-component"]` |
| `element-id` | string, pattern `^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$` (also matches discovery `identifier`) |
| `element-ids` | array, `uniqueItems`, items `element-id` |
| `disposition` | `enum: ["documented", "excluded", "deferred"]` |
| `parity-dimension` | `enum: ["exists", "accurate", "example_present", "owner_assigned", "diataxis_mode"]` |
| `parity-state` | `enum: ["pass", "fail", "not-assessed", "not-applicable"]` |
| `diataxis-mode` | `enum: ["tutorial", "how-to", "reference", "explanation"]` (900006 already uses `reference`; 900002 must use the same values) |
| `front-matter-field` | `enum: ["owner", "last_reviewed", "audience", "diataxis_mode", "surface_refs"]` |
| `review-date` | string, pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` |
| `docs-artifact-kind` | `enum: ["docs-profile", "surface-inventory-snapshot", "docs-coverage-ledger", "docs-parity-matrix", "docs-evidence-pin", "docs-validation-receipt"]` |
| `artifact-pin` | closed object, required `artifact_kind` (`docs-artifact-kind`), `path` (discovery `relative-path`), `sha256` (discovery `sha256`) |
| `page-binding` | closed object, required `page_path` (discovery `relative-path`), `anchor` (discovery `text` or `null`) |
| `actor` | closed object, required `kind` (`enum: ["human", "agent", "tool"]`), `id` (discovery `identifier`) |
| `finding` | closed object, required `code` (`^[A-Z][A-Z0-9_]*$`), `severity` (`error`/`warning`/`info`), `artifact_path` (discovery `relative-path` or `null`), `pointer` (RFC 6901 pattern as in discovery `service-result`), `related_ids` (discovery `identifiers`), `related_paths` (discovery `paths`), `message` (discovery `text`), `next_action` (discovery `text`); identical to `Finding.to_dict` |
| `diagnostic` | closed object, required `id`, `code`, `severity` (`information`/`warning`/`error`), `path` (relative path or `null`), `message`, `analyzer_id`, `blocking` (boolean), `extensions`; same shape as discovery `inventory-snapshot#/$defs/diagnostic` |

### 4.3 The six artifact schemas (field level)

All objects are closed; every listed property is required unless marked optional; "text" means
discovery `common#/$defs/text`, "identifier" means discovery `common#/$defs/identifier`.

`docs-profile` (`docs-profile.schema.json`):

| Field | Shape |
|---|---|
| header | as in 4.1 |
| `repository` | `{id: identifier}` |
| `audiences` | array `minItems 1`, `uniqueItems`, items `{id: identifier, description: text}` |
| `documentation_roots` | array `minItems 1`, items `{id: identifier, path: relative-path, audience_ids: identifiers}` |
| `surface_selection` | `{element_kinds: array minItems 1 uniqueItems of element-kind, source_roots: discovery paths minItems 1, exclusions: discovery exclusions, analyzers: identifiers}`; `analyzers` optional (absent means every registered analyzer for the selected kinds) |
| `page_owners` | array of `{path_or_glob: discovery path-or-glob, owner: identifier}` |
| `diataxis_policy` | `{modes: array minItems 1 uniqueItems of diataxis-mode, required_front_matter: array uniqueItems of front-matter-field, directory_modes: array of {path_or_glob, mode: diataxis-mode}}` |
| `completion_gates` | `{docs_complete: {required_dispositions_complete: const true, allow_deferred: boolean, max_stale_pages: integer minimum 0, required_parity_dimensions: array uniqueItems of parity-dimension}, integration_pr_gate: {enabled: boolean}}` (900008 reads `completion_gates.integration_pr_gate.enabled`, default `false` in the starter) |
| `artifact_paths` | `{inventory_snapshot, coverage_ledger, parity_matrix, evidence_pins, validation_receipt}`, each a relative path (900003 and 900005 read these) |

Profile dataclasses in `profile_models.py` (frozen, `kw_only`): `DocsProfile`, `Audience`,
`DocumentationRoot`, `SurfaceSelection`, `PageOwner`, `DiataxisPolicy`, `DirectoryMode`,
`DocsCompleteGate`, `IntegrationPrGate`, `CompletionGates`, `ArtifactPaths`. `profile.py` exposes
`parse_profile(content: bytes, *, format, artifact_path, registry=None) -> ProfileLoadResult`
(`profile: DocsProfile | None`, `findings: tuple[Finding, ...]`, `ok`), `starter_profile(*,
repository_id) -> JsonObject`, and `render_profile_json(value) -> str` (canonical, sorted, LF).
Semantic checks after schema validation: unique audience and root identifiers, audience references
resolve, directory modes are members of `diataxis_policy.modes`, analyzer identifiers exist in the
analyzer registry.

`surface-inventory-snapshot`:

| Field | Shape |
|---|---|
| header | as in 4.1 |
| `repository` | identifier |
| `revision` | discovery `revision` or `null` (working copy) |
| `profile_sha256` | discovery `sha256` of the canonical profile bytes |
| `analyzers` | array `uniqueItems` of `{id: identifier, version: text}` |
| `inputs` | array `uniqueItems` of `{path: relative-path, sha256: sha256, size: integer minimum 0}` (900003 AC: captured input digests) |
| `elements` | array `uniqueItems` of `element` |
| `diagnostics` | array of docs `diagnostic` |
| `captured_at` | discovery `timestamp` |
| `extensions` | discovery `extensions` |

`$defs/element`: `element_id` (element-id), `kind` (element-kind), `path` (relative-path),
`declaration` (text), `name` (text), `parent_id` (element-id or `null`), `analyzer_id`
(identifier), `source_sha256` (sha256), `line_range` (`{start, end}` integers minimum 1, or
`null`), `properties` (array of `{name: identifier, value: string|number|boolean|null}`; keys and
shapes only, never configuration values), `extensions`. Conditional: `kind: cli-option` requires
`parent_id` matching `^cli-command-`; every other kind allows `null` or an element-id.

`docs-coverage-ledger`:

| Field | Shape |
|---|---|
| header | as in 4.1 |
| `repository` | identifier |
| `snapshot_ref` | `artifact-pin` with `artifact_kind` const `surface-inventory-snapshot` |
| `entries` | array `uniqueItems` of `entry` |
| `extensions` | discovery `extensions` |

`$defs/entry`: `element_id`, `kind` (element-kind), `disposition`, `page_bindings` (array of
`page-binding`), `rationale` (text or `null`), `owner` (identifier or `null`), `target` (text or
`null`), `updated_by` (`actor`), `extensions`. Companion rules (`allOf` of `if`/`then`):
`documented` requires `page_bindings` `minItems 1` and `rationale`, `owner`, `target` all `null`;
`excluded` requires `rationale` text and `page_bindings` `maxItems 0`, `owner`/`target` `null`;
`deferred` requires `owner` identifier and `target` text, `page_bindings` `maxItems 0`, `rationale`
optional text or `null`. Completeness ("every inventoried element has a disposition") is semantic
(900005), not a schema rule.

`docs-parity-matrix`:

| Field | Shape |
|---|---|
| header | as in 4.1 |
| `repository` | identifier |
| `snapshot_ref` | `artifact-pin` (`surface-inventory-snapshot`) |
| `ledger_ref` | `artifact-pin` (`docs-coverage-ledger`) |
| `rows` | array `uniqueItems` of `row` |
| `extensions` | discovery `extensions` |

`$defs/row`: `element_id`, `kind` (element-kind), `page_path` (relative-path), `dimensions`
(closed object with exactly the five required keys `exists`, `accurate`, `example_present`,
`owner_assigned`, `diataxis_mode`, each a `dimension-result`), `extensions`.
`$defs/dimension-result`: `state` (parity-state), `rationale` (text or `null`), `evidence_pin_ids`
(discovery `identifiers`); `not-applicable` and `fail` require `rationale` text. An unknown
dimension is rejected by `additionalProperties: false`.

`docs-evidence-pin` (one collection document per repository, sorted by `pin_id`; 900005 to
confirm the collection form):

| Field | Shape |
|---|---|
| header | as in 4.1 |
| `repository` | identifier |
| `pins` | array `uniqueItems` of `pin` |
| `extensions` | discovery `extensions` |

`$defs/pin`: `pin_id` (identifier), `element_id`, `element_kind` (element-kind), `page_path`
(relative-path), `symbol` (text; the pinned declaration), `source_path` (relative-path),
`source_sha256` (sha256; compared with the current snapshot element to mark the page stale),
`revision` (discovery `revision` or `null`), `claim` (text or `null`), `pinned_at` (timestamp),
`pinned_by` (`actor`).

`docs-validation-receipt`:

| Field | Shape |
|---|---|
| header | as in 4.1 |
| `mode` | `enum: ["profile", "ledger", "matrix", "docs-complete"]` (900005 `validation.py` modes) |
| `repository` | identifier |
| `revision` | discovery `revision` (non-null; 900008 matches it against the head revision) |
| `inputs` | array `uniqueItems` of `artifact-pin` |
| `counts` | `{elements_total, undocumented, stale_pages}` (integers minimum 0), `by_disposition` (closed object, required keys `documented`, `excluded`, `deferred`), `by_kind` (closed object, required keys equal to the six element kinds) |
| `validation_result` | discovery `validation-outcome` |
| `findings` | array `uniqueItems` of docs `finding` |
| `issued_at` | timestamp |
| `writer` | `{tool: const "drm-copilot-docs", version: text}` |
| `extensions` | discovery `extensions` |

Rules copied from discovery `validation-receipt`: `pass` forbids `error` findings; `fail`
requires at least one `error` finding. An unknown disposition or kind is rejected through the
closed `by_disposition`/`by_kind` objects.

AC coverage: each artifact schema carries an element-kind or disposition field (profile
`surface_selection.element_kinds`, snapshot `elements[].kind`, ledger `entries[].kind` and
`disposition`, matrix `rows[].kind`, pin `element_kind`, receipt `counts.by_kind` and
`counts.by_disposition`), so the AC "rejects a missing required field and an unknown disposition or
element kind" is testable against all six.

### 4.4 Surface element model and analyzer contract

`surface_models.py`:

- `ElementKind = Literal[...]` with `ELEMENT_KINDS: tuple[ElementKind, ...]` in contract order.
- `element_identifier(*, kind: ElementKind, path: str, declaration: str) -> str` returns
  `stable_id(kind, row(kind=kind, path=path, declaration=declaration))`. Inputs: `kind` must be in
  `ELEMENT_KINDS`; `path` must pass `validate_finding_path` (same grammar as common
  `relative-path`); `declaration` must be non-blank with no leading or trailing whitespace and no
  control characters (no Unicode normalization, so identity is byte-exact). Output matches
  `element-id`. Because the hashed value is canonical JSON of three named members, concatenation
  ambiguities (for example `"a/b"` + `"c"` versus `"a"` + `"b/c"`) cannot collide.
- `declaration` conventions per kind (contract for 900003/900004): `cli-command` the full command
  path (`dev.docs.inventory`); `cli-option` the command path plus the long option
  (`dev.docs.inventory --analyzer`); `http-route` method plus route template (`GET /items/{id}`);
  `config-key` the dotted key path (`tool.poetry.scripts`); `public-symbol` the qualified name;
  `architecture-component` the package or module path.
- `SurfaceElement` (frozen, `kw_only`): `element_id`, `kind`, `path`, `declaration`, `name`,
  `parent_id`, `analyzer_id`, `source_sha256`, `line_range: tuple[int, int] | None`,
  `properties: JsonObject`; `__post_init__` recomputes and enforces `element_id`.
- `SurfaceDiagnostic` (frozen) mirroring the docs `diagnostic` shape, derived with
  `drm_copilot_discovery.analyzer.findings.diagnostic` or the same `stable_id("diagnostic", ...)`
  rule.
- `to_json(element) -> JsonObject` projecting to the snapshot `element` shape.

`analyzer_contract.py`:

- `SurfaceAnalyzer` (Protocol): `identifier: str` property; `element_kinds: tuple[ElementKind, ...]`
  property; `analyze(self, inputs: Mapping[str, bytes], *, selection: SurfaceSelection) ->
  SurfaceAnalysis`. Contract: pure, deterministic, no I/O, no mutation of inputs, inputs are
  captured bytes keyed by relative POSIX path, oversize inputs produce a diagnostic rather than a
  partial result (900003 AC).
- `SurfaceAnalysis` (frozen): `elements: tuple[SurfaceElement, ...]`,
  `diagnostics: tuple[SurfaceDiagnostic, ...]`, both sorted by identifier.
- `AnalyzerRegistration` (frozen): `identifier` (discovery `identifier` grammar),
  `element_kinds`, `module` (must start with `drm_copilot_docs.analyzers.`), `attribute`.
- `ANALYZER_REGISTRY: tuple[AnalyzerRegistration, ...] = ()` with a comment stating that
  900003/900004 append one entry per line at the end; order in source is not significant.
- `validate_registry(registry) -> tuple[Finding, ...]` (unique identifiers, identifier grammar,
  non-empty kinds within `ELEMENT_KINDS`, module prefix), `registered_identifiers(registry)`,
  `select_registrations(registry, *, kinds, analyzer_ids) -> tuple[AnalyzerRegistration, ...]`
  (full validation before any import, sorted output, `ValueError` naming the unknown identifier),
  and `load_analyzer(registration, *, import_module=importlib.import_module) -> SurfaceAnalyzer`
  (checks the loaded object's `identifier` and `element_kinds` equal the registration).
- Profiles select identifiers only; no profile can name a module, matching the discovery registry
  principle.

### 4.5 Required file changes

Create (production):
`packages/docs-runtime/pyproject.toml`, `README.md`, `resource-manifest.json`;
`packages/docs-runtime/src/drm_copilot_docs/__init__.py` (`__version__ = "1.0.0"`), `py.typed`,
`profile_models.py`, `profile.py`, `schema_validation.py`, `resources.py`, `surface_models.py`,
`analyzer_contract.py`, `cli.py`, and the staged `_resources/schemas/docs/v1/*.schema.json` plus
`_resources/manifest.json`; `scripts/dev_tools/build_docs_runtime.py`;
`schemas/docs/v1/common.schema.json` and the six artifact schemas; six examples under
`examples/docs/v1/` (`<name>.example.json`).

`packages/docs-runtime/pyproject.toml` content: backend `poetry.core.masonry.api`
(`poetry-core>=1.9.0`); name `drm-copilot-docs`; version `1.0.0`;
`packages = [{ include = "drm_copilot_docs", from = "src" }]`; `include` for `py.typed`;
`[tool.poetry.scripts]` `"dev.docs.init" = "drm_copilot_docs.cli:main_init"` and
`"dev.docs.validate-profile" = "drm_copilot_docs.cli:main_validate_profile"`; dependencies
`python = ">=3.10,<4.0"`, `drm-copilot-discovery = ">=2.0.0,<3.0.0"`, `jsonschema = "^4.25.1"`,
`referencing = ">=0.37,<0.38"`, `PyYAML = ">=6.0"` (only if YAML profiles are accepted). Whether
Poetry resolves the version-range dependency on `drm-copilot-discovery` through the root's
directory dependency without a lock conflict is orchestrator to confirm with `poetry lock` in the
item worktree.

Edit:

- Root `pyproject.toml`, four sections, each an append:
  1. `[tool.poetry.dependencies]`: `drm-copilot-docs = { path = "packages/docs-runtime", develop = true }` after the discovery line.
  2. `[tool.poetry.scripts]`: `"dev.docs.init" = "drm_copilot_docs.cli:main_init"` and `"dev.docs.validate-profile" = "drm_copilot_docs.cli:main_validate_profile"` after `"dev.discovery.doctor"`.
  3. `[tool.coverage.run] source`: add `"packages/docs-runtime/src"`.
  4. `[tool.pyright] include`: add `"packages/docs-runtime/src"`.
  No change to `[tool.pytest.ini_options]` (`testpaths = ["tests"]` already covers the new tests) or to Ruff, provided the property tests avoid `random` (section 5).
- `poetry.lock`: regenerated; must pass `poetry check --lock` and the `git diff --exit-code poetry.lock` step.
- `quality-tiers.yml`: add `packages/docs-runtime`. Without it, `check_quality_tiers` reports
  `QT008` (rule R1 discovers every folder holding a tracked `pyproject.toml`). Recommended tier
  `T2` (reusable models and validation installed in consuming repositories, the same rationale as
  discovery). Consequences: property tests per pure function, contract major-bump rule.
- `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
  (`test_committed_quality_tiers_yml_assigns_spec_tiers`): updated, because it asserts the
  elevated T1/T2 list equals only `packages/discovery-runtime`; the expected list becomes both
  packages. If the owner prefers `T3`, this test is unchanged and the T2 obligations do not
  apply.

Existing tests and their disposition:

| Test | Disposition |
|---|---|
| `tests/discovery_runtime/test_package_contract.py` | Unchanged; its root-pyproject assertions use `startswith`/`split` and tolerate appended entries. |
| `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` | Unchanged; reads only the discovery `pyproject.toml` and discovery constants; Python stays excluded from both distributables. |
| `tests/scripts/dev_tools/test_build_discovery_runtime.py`, `test_build_discovery_runtime_io.py`, `test_discovery_build_identity.py`, `tests/discovery_runtime/test_build_identity.py` | Unchanged; no discovery builder or manifest file is edited. |
| `tests/schemas/discovery/*` | Unchanged; they import `verify_schema_closure` only. |
| `tests/discovery_runtime/test_cli_errors.py`, `test_cli_dry_run.py` | Unchanged; they exercise discovery wrappers only. |
| `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` | Updated if tier `T2` (see above). |

The extension needs no change in 900001. 900007 decides whether to add a docs wheel constant next
to `DISCOVERY_WHEEL_FILE_NAME`.

## 5. Testing Implications

Final test paths (package tests follow the `tests/discovery_runtime/` precedent; schema tests
mirror `schemas/<family>/` as `tests/schemas/discovery/` does):

- `tests/docs_runtime/__init__.py` (required; see the import-mode note below)
- `tests/docs_runtime/test_profile.py`, `test_profile_properties.py`, `test_surface_models.py`,
  `test_analyzer_contract.py`, `test_cli.py`, `test_neutrality.py`
- `tests/docs_runtime/test_docs_schema_validation.py`, `test_docs_resources.py`,
  `test_docs_package_contract.py` (pyproject metadata, `py.typed`, root registration, staged copies
  equal canonical bytes)
- `tests/schemas/docs/test_docs_schemas_v1.py` (the epic wrote `tests/schemas/docs_schemas/`;
  `tests/schemas/docs/` mirrors `schemas/docs/` the way `tests/schemas/discovery/` mirrors
  `schemas/discovery/`; either satisfies the location rule)
- `tests/scripts/dev_tools/test_build_docs_runtime.py` (in-memory filesystem, following
  `MemoryFileSystem` in `test_build_discovery_runtime.py`)

Import-mode note: pytest runs in the default prepend mode. `tests/discovery_runtime/` has no
`__init__.py`, so its modules import under their bare names (`test_resources`,
`test_schema_validation`). A docs test with the same basename in another folder without
`__init__.py` fails collection with an import-file-mismatch error; 900002 also plans
`tests/docs_page_check/test_cli.py`. Adding `tests/docs_runtime/__init__.py` (modules import as
`docs_runtime.test_*`) and prefixing the resource and schema-validation tests with `docs_` avoids
both collisions. 900003 and 900006 subfolders (`tests/docs_runtime/analyzers/`,
`tests/docs_runtime/reference/`) need their own `__init__.py`.

Schema tests: `check_schema`, `$id`, closed root objects, every example validates, and for each
artifact schema one in-memory mutation deleting a required field and one setting an unknown
element kind or disposition must each produce errors; packaged copy equals canonical bytes; offline
closure through `verify_schema_closure` with discovery `common` included. No invalid fixture files
are needed (mutations are applied to a deep copy of the loaded example).

Property tests (T2 requires at least one per pure function): `hypothesis` is not a dependency (see
section 7). Use exhaustive `itertools.product`/`permutations` enumerations, the pattern in
`tests/discovery_runtime/test_package_contract.py` (`test_v1_profile_is_invariant_under_mapping_order`),
which needs no Ruff change. Seeded `random.Random` is the alternative used by
`tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`, but it requires a
`[tool.ruff.lint.per-file-ignores]` `S311` entry, another root `pyproject.toml` edit. Properties:
identifier determinism and injectivity over a product of all six kinds, paths with separators and
non-ASCII characters, and declarations including boundary concatenations; starter profile validity
for a product of repository identifiers; profile render round trip and key-order invariance;
registry selection order invariance under permutation.

CLI tests pass `io.StringIO` streams and in-memory read/write seams; assert exit codes 0/1/2/3 and
that the invalid-profile message names the failing pointer.

Coverage: measure with `--cov=drm_copilot_docs --cov-branch --cov-report=json:<path>` (dotted
module), and `--cov=scripts.dev_tools.build_docs_runtime` for the builder; read branch figures from
the JSON report.

## Numeric Derivation Evidence

The approved acceptance criteria carry no count; the enumerations below support the file list and
contract tables.

Docs v1 artifact schema family:

- Complete Family: docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt
- Exhaustive Search Scope: entire worktree, all files under docs/features/ for this feature and the epic manifest, plus all of schemas/ in the repository tree
- Inclusion Rules: artifact schemas that 900001 creates under schemas/docs/v1/ with an example each
- Exclusion Rules: the proposed definitions-only common.schema.json; page-metadata.schema.json owned by 900002
- Primary Search Strategy or Query Expression: read the epic 900001 Files (create) bullet listing docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt
- Primary Member Set: docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: read the issue.md Proposed Behavior bullet "Six schemas under schemas/docs/v1/" enumerating docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt, and a Glob of schemas/docs/** confirming none exists yet
- Cross-check Member Set: docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt
- Cross-check Count: 6
- Member-set Comparison: the normalized primary and cross-check member sets are equal

Other enumerations, each compared between the epic `### Naming contract` and `issue.md`
`## Proposed Behavior` (sets equal in every case): element kinds (6: `cli-command`, `cli-option`,
`http-route`, `config-key`, `public-symbol`, `architecture-component`); dispositions (3:
`documented`, `excluded`, `deferred`); parity dimensions (5: `exists`, `accurate`,
`example_present`, `owner_assigned`, `diataxis_mode`); front-matter fields (5: `owner`,
`last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`); console commands for 900001 (2:
`dev.docs.init`, `dev.docs.validate-profile`). Elevated T1/T2 entries in `quality-tiers.yml`: 1
today (`packages/discovery-runtime`), read from the file and confirmed by the assertion in
`test_committed_quality_tiers_yml_assigns_spec_tiers`; 2 after a `T2` classification.

## 6. Risks

- File size: no module approaches 500 lines if the split in 4.5 is kept (`schema_validation.py`,
  `profile.py` and `analyzer_contract.py` are the largest candidates). Schemas are JSON, not
  Markdown, and count as files; keep each schema under 500 lines by using `$defs`.
- Batch budget: the feature creates at least nine non-test Python production files
  (`__init__.py`, seven modules, `build_docs_runtime.py`). Direct mode denies the fourth with
  `PYTHON_LARGE_PATH_REQUIRED`. The preparation route in `artifacts/orchestration/orchestrator-state.json`
  exempts edits only in the item worktree that holds the checkpoint; an isolated executor worktree
  has no checkpoint (gitignored `artifacts/`), so execution must run in the item worktree or the
  checkpoint must select the `large` route there.
- Cross-feature conflicts: root `pyproject.toml` (900002, 900003, 900005, 900006, 900008 append to
  `[tool.poetry.scripts]`; 900002 also appends a path dependency, coverage source and pyright
  include), `poetry.lock` (900002), `quality-tiers.yml` and
  `test_quality_tiers_contract_classification.py` (900002 adds `packages/docs-page-check`, which is
  not listed in the epic conflict surface), `analyzer_contract.py` (900003, 900004). The Diataxis
  mode enum must agree between docs `common` and the 900002 `page-metadata.schema.json`.
- Freshness: CI does not run any runtime builder; stale staged copies are caught only by the
  test comparing `drm_copilot_docs.resources.read_resource` output with the canonical bytes.
- Naming contract on origin/main: no conflict found (section 1.7).

## Pre-Mortem

- **Review checklists**: a reviewer can flag a production path excluded from coverage, a missing `quality-tiers.yml` entry, or a schema that does not reject an unknown kind or disposition; the plan must list the `quality-tiers.yml` entry, the root `[tool.coverage.run]` source addition, and one rejection test per artifact schema.
- **Coverage**: `drm_copilot_docs` and `scripts/dev_tools/build_docs_runtime.py` could fall below 85% line or 75% branch because CLI and resource I/O wrappers are thin and untested; the plan must inject stream, reader and writer seams, measure with dotted `--cov` targets, and read branch figures from the JSON report.
- **Mirror parity**: not applicable as a mirror surface, because 900001 edits no `.claude`, `.github`, `.codex`, `.agents` or bundled resource file and changes no fact stated in the execution-environment brief; the staged `_resources` copies are the only duplicated files, and the plan must carry the byte-equality test for them.
- **File size**: a combined profile or schema-validation module could pass 500 lines; the plan must keep the module split in section 4.5 and route any growth into a new module with its own test file.
- **Test isolation**: duplicate test basenames under prepend import mode (`test_resources`, `test_schema_validation`, and 900002's `test_cli`) fail collection, and a process-wide schema registry cache could leak between tests; the plan must add `tests/docs_runtime/__init__.py`, prefix colliding names, build caches keyed by content (immutable), and record a reversed-order run of the new modules.
- **CI-only behavior**: CI fails on an out-of-sync `poetry.lock` (`poetry check --lock` and `git diff --exit-code poetry.lock`), on `QT008` from the tier check, and on Linux path handling; the plan must regenerate the lock in the item worktree, add the tier entry, and use POSIX relative paths with no drive letters in tests and examples.
- **Evidence**: gate artifacts written outside `<FEATURE>/evidence/<kind>/` or with plan-time stamps are rejected; the plan must write baseline, QA-gate and regression evidence under the canonical folders with write-time UTC stamps and record `SCRATCH` instead of host paths.

## 7. Answers to Specific Questions Not Covered Above

- Question 7 (hypothesis): not approved. The root `[tool.poetry.group.dev.dependencies]` lists
  pytest, pytest-cov, black, ruff, pyright, pyperclip, jsonschema, types-beautifulsoup4 and
  types-requests only; `poetry.lock` has no `hypothesis` package; no test imports it. Adding it
  needs owner approval under the dependency policy; the enumeration approach in section 5 avoids
  the need.
- Question 6 (neutrality): no test configures consumer identifiers; each hard-codes tokens. For
  `tests/docs_runtime/test_neutrality.py`, recommended form: a pure helper
  `find_identifier_occurrences(files: Mapping[str, str], identifiers: Sequence[str])` in the test
  module; a positive control proving a synthetic identifier injected into an in-memory mapping is
  detected; and a parametrized scan of every file under `packages/docs-runtime/src/` and
  `schemas/docs/` (read-only, as the discovery neutrality tests do). To avoid committing the
  originating consumer repository's name, the configured list can be stored as SHA-256 digests of
  lowercase word tokens, with the scan hashing each token of each file. The token digests are to be
  supplied by the orchestrator or owner (orchestrator to confirm the storage form).
- Question 8 (test location): `tests/schemas/` exists (`tests/schemas/discovery/`, no
  `__init__.py`). Package tests use `tests/<distribution folder with underscore>/` (for example
  `tests/discovery_runtime/`) rather than mirroring `packages/<name>/src/<import name>/`. Final
  paths are listed in section 5.

## 8. Items for the Orchestrator to Confirm

- Poetry resolution of `drm-copilot-docs` (range dependency on `drm-copilot-discovery`) alongside the
  root directory dependency, and the resulting `poetry.lock` diff.
- Acceptance of the `schemas/docs/v1/common.schema.json` refinement, the collection form of
  `docs-evidence-pin`, and tier `T2` for `packages/docs-runtime`.
- The digest list (or other storage form) for the configured consumer identifiers in the
  neutrality test.
- Coordination with 900002 on the Diataxis mode values and on the shared `quality-tiers.yml` and
  classification-test edits.
