# docs-surface-analyzers-python-config (Issue #1022) - Research

- Feature: child 900003 of epic #1019 (documentation-estate-tooling), wave 1, band C4; placeholder 900003 is replaced by #1022
- Branch: `feature/docs-surface-analyzers-python-config-1022` (based on the epic integration branch; contains `origin/main` plus the prepared, unexecuted feature folder of #1020)
- Mode: preparation research only. No source, configuration or test file was changed.
- Sources read: `docs/features/epics/documentation-estate-tooling/epic.md` (whole file), the #1022 `issue.md` and template `spec.md`, the #1020 `spec.md`, `plan.2026-10-30T16-08.md` and `research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md`, and every repository file cited below.
- Citation convention: "verified" means read on the current tree; "planned by 1020" means stated in the #1020 spec or plan and not yet present on the tree (`packages/docs-runtime/` does not exist on this branch); "proposal" means a name or rule this research introduces because 1020 leaves it unnamed.
- Assumption status: A1-A6 in the epic are provisional and unapproved. This design depends on A1 (Python/configuration analyzers are a separate feature from TypeScript/.NET), A5 (package `packages/docs-runtime`, import `drm_copilot_docs`, discovery reused as a library) and A6 (no MCP work here). If A5 is rejected, every module path below changes.

## 1. Current State Analysis

### 1.1 Upstream contracts planned by 1020 (consumed, not re-created)

All symbols below are planned by 1020 (spec `## API / CLI Surface` and plan Phase 4/5). None exists on the tree yet.

| Module (planned by 1020) | Symbols #1022 consumes |
|---|---|
| `drm_copilot_docs/surface_models.py` | `ElementKind` (`Literal` of the six kinds), `ELEMENT_KINDS` (tuple in contract order), `element_identifier(*, kind, path, declaration) -> str` (returns `stable_id(kind, row(kind=..., path=..., declaration=...))`; `ValueError` naming the argument for an unknown kind, a path failing `validate_finding_path`, or a blank, padded or control-character declaration), `SurfaceElement` (frozen, `kw_only`: `element_id`, `kind`, `path`, `declaration`, `name`, `parent_id`, `analyzer_id`, `source_sha256`, `line_range: tuple[int, int] \| None`, `properties: JsonObject`; `__post_init__` recomputes the identifier, enforces the `cli-option` parent rule and `1 <= start <= end`), `SurfaceDiagnostic` (frozen, `kw_only`, docs `diagnostic` shape, `id` follows `stable_id("diagnostic", ...)`), `element_to_json`, `diagnostic_to_json` |
| `drm_copilot_docs/analyzer_contract.py` | `SurfaceAnalyzer` Protocol (`identifier` and `element_kinds` read-only properties; `analyze(self, inputs: Mapping[str, bytes], *, selection: SurfaceSelection) -> SurfaceAnalysis`; contract: pure, deterministic, no I/O, inputs not mutated, inputs keyed by POSIX relative path, an over-bound input yields a diagnostic rather than a partial result), `SurfaceAnalysis` (frozen: `elements` sorted by `element_id`, `diagnostics` sorted by `id`), `AnalyzerRegistration` (frozen, `kw_only`: `identifier`, `element_kinds`, `module` with prefix `drm_copilot_docs.analyzers.`, `attribute`), `ANALYZER_REGISTRY: tuple[AnalyzerRegistration, ...] = ()`, `validate_registry`, `registered_identifiers`, `select_registrations(registry, *, kinds, analyzer_ids)`, `load_analyzer(registration, *, import_module=importlib.import_module)` |
| `drm_copilot_docs/profile_models.py`, `profile.py` | `DocsProfile`, `SurfaceSelection` (`element_kinds`, `source_roots`, `exclusions`, `analyzers: tuple[str, ...] \| None`), `ArtifactPaths.inventory_snapshot`; `parse_profile(content, *, format, artifact_path, registry=None) -> ProfileLoadResult` (`profile`, `findings`, `ok`) |
| `drm_copilot_docs/schema_validation.py` | `validate_artifact(value, *, artifact_kind, artifact_path, resources=None) -> tuple[Finding, ...]` (code `SCHEMA_INVALID`) |
| `drm_copilot_docs/cli.py` | Conventions only: zero-argument `main_*() -> int` wrappers delegating to `run_cli(command, argv, *, ports, stdout, stderr) -> int`; `argparse` with `SystemExit` caught; exit codes 0/1/2/3; a top-level handler writes a fixed stderr line and returns 3 |
| `drm_copilot_docs/__init__.py` | `__version__ = "1.0.0"` |

`surface-inventory-snapshot.schema.json` (planned by 1020, spec `### Artifact schema: surface-inventory-snapshot`), required fields:

- Header: `$schema` (const `urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot`), `schema_version` (const `"1.0.0"`), `artifact_kind` (const `surface-inventory-snapshot`), `id` (discovery `identifier`), `extensions`.
- `repository` (identifier); `revision` (discovery `revision`, a full 40- or 64-hex Git object id, or `null` for a working copy). This is the revision pin.
- `profile_sha256` (sha256 of the canonical profile bytes).
- `analyzers`: unique array of closed `{id: identifier, version: text}`.
- `inputs`: unique array of closed `{path: relative-path, sha256: sha256, size: integer >= 0}`. These are the captured input digests the acceptance criterion requires.
- `elements`: unique array of `$defs/element` (closed): `element_id`, `kind`, `path`, `declaration` (text), `name` (text), `parent_id` (element-id or `null`), `analyzer_id`, `source_sha256`, `line_range` (`{start, end}` or `null`), `properties` (array of closed `{name: identifier, value: string | number | boolean | null}`; keys and shapes only), `extensions`. Conditional: `kind: cli-option` requires `parent_id` matching `^cli-command-`.
- `diagnostics`: array of docs `diagnostic` (`id`, `code`, `severity` in `information`/`warning`/`error`, `path` or `null`, `message`, `analyzer_id`, `blocking`, `extensions`); same shape as discovery `schemas/discovery/v2/inventory-snapshot.schema.json` `$defs/diagnostic` (verified), where `code` uses the discovery `identifier` grammar (lowercase kebab, not upper snake).
- `captured_at` (timestamp).

Declaration conventions (planned by 1020, binding on #1022): `cli-command` full command path; `cli-option` command path, one space, long option; `http-route` upper-case method, one space, route template; `config-key` dotted key path; `public-symbol` qualified name; `architecture-component` package or module path.

Discovery `identifier` grammar (verified, `schemas/discovery/v2/common.schema.json` `$defs/identifier`): `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`. It constrains analyzer identifiers, diagnostic codes, the snapshot `id` and every `properties[].name`.

Items 1020 leaves unnamed or ambiguous, with the #1022 proposal:

| Gap in 1020 | Proposal for #1022 |
|---|---|
| Whether `AnalyzerRegistration.attribute` names a class or an instance. `load_analyzer` "checks that the loaded object's `identifier` and `element_kinds` equal the registration", which a class with `@property` members cannot satisfy. | Proposal: `attribute` names a module-level analyzer instance, for example `PYTHON_CLI_ANALYZER = PythonCliAnalyzer()`. |
| A factory for `SurfaceDiagnostic` (whether `id` is caller-supplied and validated or computed). | Proposal: an analyzers-internal helper `make_diagnostic(*, code, path, message, analyzer_id, severity, blocking) -> SurfaceDiagnostic` computing `id = stable_id("diagnostic", row(code=code, path=path, analyzer=analyzer_id))`, the discovery `analyzer.findings.diagnostic` rule. |
| Diagnostic identity collides for two diagnostics with the same code, path and analyzer. | Proposal: analyzers emit at most one diagnostic per `(code, path, analyzer_id)`; the message states the occurrence count and the first line. |
| `SurfaceElement` has no `extensions` field, so analyzers cannot attach structured data; `element_to_json` presumably emits `{}`. | Proposal: structured data (dependency edges) is encoded as indexed scalar properties (section 4.6). Optional epic-level request: 1020 adds `extensions: JsonObject` to `SurfaceElement`. |
| The type of `SurfaceSelection.exclusions`. | Proposal: whatever 1020 chooses, `cli_inventory.py` converts each entry to a discovery `JsonObject` with `path_or_glob` and `rationale` for `exclusion_reason`. Preflight confirms the field type. |
| How `profile_sha256` ("canonical profile bytes") is computed; `ProfileLoadResult` carries no raw JSON value. | Proposal: `sha256(canonical_json(parse_document(content, format=...).value))` using discovery `parsing.parse_document` and `models.canonical_json`. |
| `select_registrations` behavior when an explicitly requested analyzer's kinds do not intersect `kinds`. | Proposal: `cli_inventory.py` rejects such a request with exit 2 before calling the analyzer. |
| The "one entry per line" registry rule conflicts with Black (line length 88): a full `AnalyzerRegistration(...)` call exceeds 88 characters and Black splits it. | Proposal: each entry is one Black-formatted multi-line block appended at the tuple end (section 4.8). |

### 1.2 Discovery runtime reuse (verified)

All paths below are under `packages/discovery-runtime/src/drm_copilot_discovery/`. No discovery file is edited.

| Module and symbols | Behavior (verified) | Callable from in-memory mappings without filesystem? | Reuse decision |
|---|---|---|---|
| `analyzer/input_capture.py`: `capture_inputs(profile: ProfileV2, *, workspace_root, metadata, read_bytes, repository_files=())`, `capture_snapshot`, `exclusion_rules(profile: ProfileV2)`, `exclusion_reason(path, rules)`, `pin_inventory_sources`, `MAX_CAPTURE_BYTES = 268435456` | `capture_inputs` requires a configured discovery `ProfileV2` (`require_configured`), an absolute `workspace_root`, a `SnapshotIO` bound to the profile, and per-file limits from `profile.analyzers.max_file_bytes`; aggregate budget `min(source_files * max_file_bytes, MAX_CAPTURE_BYTES)`. `exclusion_reason` is pure: ordered case-sensitive `fnmatchcase` over `JsonObject` rules with `path_or_glob` and `rationale`; a trailing `/**` also excludes the directory itself. | `capture_inputs`: no (needs `ProfileV2` and a workspace). `exclusion_reason`: yes, pure. | Reuse `exclusion_reason` (pure) and the constant `MAX_CAPTURE_BYTES` as the aggregate bound. Do not call `capture_inputs`; the docs profile is not a `ProfileV2`, and constructing one would be a discovery behavior dependency. |
| `analyzer/models.py`: `InventoryInput`, `InventoryCapture`, `Analysis`; `snapshot.py`: `SnapshotFile(path, content, category)` with `sha256` property and `entry()` returning `{path, sha256, size, category}` | `SnapshotFile.__post_init__` validates the path through `path_models.relative_path` and requires `bytes`. `InventoryCapture` requires `ProfileV2`. | `SnapshotFile`: yes. `InventoryCapture`: no. | Reuse `SnapshotFile(path=..., content=..., category="source")` as the captured-input record; its `sha256` and `len(content)` populate snapshot `inputs`. This is the "discovery input capture" reuse the epic names. |
| `path_models.py`: `relative_path`, `check_path_collisions` | Pure POSIX relative-path validation; collision check rejects duplicates and case or Unicode ancestor aliases. | Yes. | Reuse to validate mapping keys before analysis. |
| `analyzer/findings.py`: `row(**values)`, `stable_id(prefix, value)`, `diagnostic(code, path, message, *, analyzer="repository", blocking=True)`, `tool`, `source_reference`, `pinned_matches` | `stable_id` returns `prefix + "-" + sha256(canonical_json(value))`. `diagnostic` severity is only `error` or `warning`, and its `analyzer_id` defaults to `repository`. | Yes, pure. | Reuse `row` and `stable_id` (through 1020 `element_identifier` and the diagnostic helper). Do not call `diagnostic` directly: docs diagnostics need `information` severity and a docs analyzer id. |
| `analyzer/registry.py`: `InventoryAdapter`, `builtin_analyzer_identities`, `normalized_analyzer_ids`, `select_analyzers`, `_generic_analyzer` | Pattern: profiles select inert identifiers; the full request is validated before any import; implementations load through literal lazy imports. Bound to `ProfileV2`. | Pattern only. | 1020 already mirrors the pattern in `select_registrations` and `load_analyzer`; #1022 uses those. |
| `analyzer/pipeline.py`: `Analyzer` (legacy parse/classify/map/emit), `AnalyzerFileSystem`, `RealAnalyzerFileSystem`, `run_analyzer`, `run_inventory`, `plan_inventory` | Legacy staged contract with a real filesystem port. | No. | Not reused. Its `RealAnalyzerFileSystem.walk_files` is a precedent for the thin enumeration port only. |
| `analyzer/dependency_python.py`: `parse_python_dependencies(content: bytes, *, format: Literal["requirements", "setup-cfg"], limits: DependencyLimits) -> DependencyResult` | Parses requirements lines and `setup.cfg` `options.install_requires` / `options.extras_require` into sanitized `DependencyCandidate` records (`name`, `version`, `role`, `anchor.line`, `extras`, `markers`). It does not parse Python source and extracts no module or import edges. Any unsupported line (`-r`, `-e`, options, `attr:`) raises `DependencyInputError` and discards the whole file. `DependencyLimits` defaults: `max_bytes=1_048_576`, `max_lines=100_000`. | Yes, pure (bytes in, immutable result out). | Reuse for declared external dependencies only (section 4.6). Import edges need new `ast` code. The epic wording "dependency edges reusing `dependency_python`" is only partly achievable: `dependency_python` supplies package-to-distribution declarations, not module-to-module edges. |
| `analyzer/configuration.py` (`ConfigurationAnalyzer`, `_format`) and `analyzer/configuration_input.py` (`parse_configuration(content, *, format: "json"\|"xml"\|"ini", max_bytes, max_keys, max_depth=64, max_text_bytes=None) -> tuple[ConfigurationKey, ...]`, `ConfigurationKey(name, pointer, kind, line, conditional, origin_pointer)`, `ConfigurationInputError(code)`) | Key-only extraction; values never retained; TOML explicitly unsupported (`_format` returns `"unsupported"` for `.toml`); no YAML and no `.env`. JSON keys come back as RFC 6901 pointers with `line=None`. | `parse_configuration`: yes, pure. `ConfigurationAnalyzer.analyze`: no (needs `InventoryCapture`). | Reuse the value-free design. Do not call `parse_configuration` for JSON Schema, because it walks every object key including `default`, `enum` and `examples` members. Section 4.5 walks only `properties`. |
| `parsing.py`: `parse_document(content: bytes \| str, *, format: Literal["json", "yaml"], artifact_path=None, limits: ParseLimits \| None = None) -> ParsedDocument` (`value`, `findings`, `source_sha256`, `format`); `models.py`: `ParseLimits` (`document_bytes` default 16 MiB, `nesting_depth` 64, `artifact_records` 100000, `findings` 100), `canonical_json`, `JsonObject` | Bounded JSON and YAML (PyYAML `SafeLoader`, compose only). Rejects duplicate keys, merge keys (`<<`), non-JSON scalar tags (unquoted YAML timestamps, binary), alias cycles and non-object roots; returns no partial value on any error. Keys are sorted; no line information survives. | Yes, pure. | Reuse for JSON Schema and YAML parsing, and `canonical_json` for snapshot rendering. |
| `revision_rules.py`: `is_full_revision(value) -> bool`; `repository_reader.py`: `full_revision`, `LocalGitReader(workspace_root, repository_id, run)`, `RepositoryReader`; `gateway_local.py`: `run_local_git` | `is_full_revision` accepts exactly 40 or 64 lowercase hex, the same grammar as the snapshot `revision`. `LocalGitReader.identity()` runs `git rev-parse` through an injected `GitCommand`. `validate_revisions` is bound to `DiscoverySnapshot`. | `is_full_revision`: yes, pure. `LocalGitReader`: only with an injected `run`. | Reuse `is_full_revision` to validate the `--revision` pin. `LocalGitReader` is a rejected alternative (section 2.3). |

Changes to discovery that would be needed for deeper reuse, all out of scope: `capture_inputs` accepting a non-`ProfileV2` scope; TOML support in `configuration_input`; import-edge extraction in `dependency_python`. None is required by the recommended design.

### 1.3 Repository toolchain facts (verified)

- Root `pyproject.toml`: `python = ">=3.10,<4.0"`; runtime dependencies include `PyYAML = ">=6.0"`, `click = ">=8.1"`, `typer = ">=0.9.0"`; dev group lists pytest, pytest-cov, black, ruff, pyright, pyperclip, jsonschema, types-beautifulsoup4, types-requests. No `tomli`, `ruamel.yaml` or `hypothesis` is declared.
- `poetry.lock`: `pyyaml` 6.0.3 (group `main`); `tomli` 2.4.0 in group `dev` with marker `python_version == "3.10"` (a transitive development dependency, not a declared one); `click` 8.3.1; `typer` 0.21.1. FastAPI and Flask are absent, which does not matter because the analyzers never import consumer frameworks.
- 1020 plans `PyYAML = ">=6.0"` as a dependency of `packages/docs-runtime/pyproject.toml` (spec `## Implementation Strategy`), so YAML parsing through discovery `parse_document` adds no dependency.
- TOML on Python 3.10: `tomllib` is standard library only from 3.11. Repository precedent for the fallback: `scripts/dev_tools/generate_codex_agent_variants.py` (`sys.version_info` check, `import tomli as tomllib`) and `scripts/dev_tools/discovery_build_identity.py` (`import_module("tomllib")` with `ModuleNotFoundError` fallback to `tomli`); test `tests/scripts/dev_tools/test_discovery_build_identity.py` drives the fallback by patching `sys.modules`.
- `[tool.poetry.scripts]` is the root script table; existing `dev.*` entries run from `dev.atomic-executor` through `dev.validate-json`, with the `dev.discovery.*` block after `dev.collect-commit-context` and before `dev.fix-all`. 1020 appends `dev.docs.init` and `dev.docs.validate-profile` after `dev.discovery.doctor`.
- Black and Ruff line length 88, target `py310`; Ruff selects `E, F, I, B, UP, S, TID, TCH`; `tests/**/*` ignores `S101` only. Pyright strict, `pythonVersion = "3.12"`.
- `[tool.pytest.ini_options]`: `testpaths = ["tests"]`, default prepend import mode; `tests/conftest.py` provides `mem_fs_path` (in-memory `pathlib.Path` patching) and a subprocess guard scoped to another module.
- `quality-tiers.yml` exists; 1020 adds `packages/docs-runtime` as T2. T2 obligations: zero untyped escape hatches, at least one property test per pure function, contract major-bump rule, determinism retry rate below 1%.
- `tests/discovery_runtime/analyzer/` carries `__init__.py`; 1020 adds `tests/docs_runtime/__init__.py`, so `tests/docs_runtime/analyzers/__init__.py` imports as `docs_runtime.analyzers.*` and cannot collide with `analyzer.test_*`.

## 2. Candidate Approaches

### 2.1 Python surface extraction

Selected: **standard-library `ast` with a per-module import alias table and flow-insensitive receiver tracking.** Each module is parsed once with `ast.parse(content_bytes)`; bytes are passed directly so PEP 263 coding cookies and the BOM are honored. Nodes are visited with `ast.walk` and explicit work lists, never a recursive visitor, so deep nesting cannot raise `RecursionError` in analyzer code. An import table maps local names to qualified names (`argparse.ArgumentParser`, `click.group`, `typer.Typer`, `fastapi.APIRouter`, `flask.Blueprint`) from `import x`, `import x as y` and `from x import y as z`. Calls and decorators are recognized only when their callee resolves through that table or through a tracked receiver variable. Nothing is imported or executed.

Rejected alternatives: regular-expression scanning (cannot distinguish strings, comments and nested calls reliably); importing consumer modules and reading framework objects (executes consumer code, violating the epic NFR); a third-party parser such as LibCST (not an approved dependency).

### 2.2 TOML parsing on Python 3.10

Selected: **resolve `tomllib`, else `tomli`, through an injected `import_module` seam; when neither is importable, each `pyproject.toml` yields one diagnostic and no elements.** This follows the `discovery_build_identity.py` precedent. In this repository's Poetry environment `tomli` is present on 3.10 through the dev group, so CI on 3.10 exercises the real parser. A consumer on 3.10 without `tomli` gets a diagnostic, not a failure.

Rejected alternatives: declaring `tomli = {version = ">=1.1", python = "<3.11"}` in `packages/docs-runtime/pyproject.toml` (a new direct dependency; requires owner approval and a `poetry.lock` change; recorded as an open question); a hand-written lexical TOML key scanner (multi-line strings, inline tables and arrays of tables make a bounded scanner error-prone).

### 2.3 Revision pin

Selected: **an explicit `--revision <full object id>` flag validated by `is_full_revision`; absent means `revision: null` (working copy).** No Git process is started by the docs package. CI callers (900008) pass the checked-out commit.

Rejected alternative: `LocalGitReader(...).identity()` with `run_local_git` to read `HEAD`. It records a revision without proving that the working-copy bytes equal the blobs at that revision; proving it needs one `read_file` per input (three Git processes each). It can be added later without a schema change.

### 2.4 YAML keys

Selected: **discovery `parse_document(..., format="yaml")`** (PyYAML approved through the root and planned docs package dependencies). Rejected: a bounded lexical YAML key scanner (flow mappings, block scalars and anchors make it unreliable; it would be a second YAML grammar).

## 3. Behavior Semantics

### 3.1 Analyzer set and identifiers (proposal)

| Analyzer identifier | Module | Element kinds | Inputs it reads |
|---|---|---|---|
| `python-cli` | `drm_copilot_docs.analyzers.python_cli` | `cli-command`, `cli-option` | `*.py`; `pyproject.toml` (script tables only, for command naming) |
| `python-http` | `drm_copilot_docs.analyzers.python_http` | `http-route` | `*.py` |
| `python-public-api` | `drm_copilot_docs.analyzers.python_public_api` | `public-symbol` | `*.py` |
| `config-files` | `drm_copilot_docs.analyzers.config_files` | `config-key` | `pyproject.toml`, `.env` family, JSON Schema files, `*.yaml`/`*.yml` |
| `python-architecture` | `drm_copilot_docs.analyzers.architecture` | `architecture-component` | `*.py`, `__init__.py`, `requirements*.txt`, `setup.cfg`, `pyproject.toml` (dependency names only) |

Refinement relative to the epic file list: console-script entries in `pyproject.toml` become `cli-command` elements owned by `python-cli`, not by `config-files`. Reason: one analyzer then owns every `cli-command`, so a command declared in a script table and implemented with argparse, Click or Typer yields one command element with its options parented to it, instead of two elements for one command. The TOML script-table reader lives in `config_toml.py` and is shared. `config-files` still covers the `pyproject.toml` tool tables. This is a file-responsibility refinement permitted by the epic; it does not change the naming contract.

### 3.2 Inputs, size bound and failure rules

- Per-input byte bound (proposal): `MAX_INPUT_BYTES = 1_048_576` (1 MiB), matching discovery `DependencyLimits.max_bytes`. Discovery's own per-file default is 16 MiB (`domain-profile.schema.json` `max_file_bytes` default `16777216`), which is high for `ast` memory use on Python source. The docs profile schema (planned by 1020) has no size field, so the bound is a module constant; making it configurable needs an epic-level schema change.
- Aggregate bounds (proposal): at most `MAX_INPUT_FILES = 50_000` inputs and `MAX_CAPTURE_BYTES` (discovery, 256 MiB) total. Exceeding either aborts the run with exit 3 and no snapshot.
- Over-bound input: the I/O layer reads at most `MAX_INPUT_BYTES + 1` bytes. The snapshot builder treats any input longer than `MAX_INPUT_BYTES` as over bound: it is omitted from `inputs` (a digest of truncated bytes would be false), it is passed to no analyzer, and exactly one diagnostic is emitted: code `input-over-bound`, severity `error`, `blocking: true`, `analyzer_id` `docs-inventory`, `path` the input path. Every analyzer also checks the bound itself (the 1020 contract), emitting its own `input-over-bound` diagnostic with its analyzer id when called directly as a library.
- Parse failure (Python `SyntaxError` or `ValueError`, TOML decode error, JSON or YAML findings, `.env` encoding error): one diagnostic (`python-syntax-invalid`, `toml-invalid`, `json-invalid`, `yaml-invalid`, `env-encoding-invalid`), severity `error`, blocking, and no elements from that input. Messages are fixed text and never quote source or values.
- Python grammar depends on the running interpreter: `ast.parse` on 3.10 rejects 3.12 syntax (PEP 695). The snapshot therefore depends on the interpreter for such files; documented, and test fixtures use 3.10 syntax only.
- Dynamic registration (receiver or argument not a literal or not resolvable): one `warning`, non-blocking diagnostic per `(code, path, analyzer)` with an occurrence count, and no element for the dynamic site. Statically resolvable sites in the same file still produce elements; this is per-site, not a truncated result.
- Invalid declaration (for example a route literal containing a control character): `element_identifier` raises `ValueError`; the site is skipped with diagnostic `declaration-invalid`.
- Duplicate element identity (same kind, path and declaration twice): keep the first by line, emit `duplicate-declaration` (warning).

### 3.3 Ordering and determinism

- Analyzers iterate `sorted(inputs)` and never iterate a `set` of strings without sorting (string hashing is randomized per process).
- Each `SurfaceAnalysis` is sorted (`elements` by `element_id`, `diagnostics` by `id`); the builder merges, de-duplicates and re-sorts; `inputs` by `path`; `analyzers` by `id`.
- Snapshot `id` (proposal): `stable_id("surface-inventory", row(repository=..., revision=..., profile_sha256=..., analyzers=..., inputs=...))`, which excludes `captured_at`.
- `captured_at` comes from an injected clock (`Callable[[], datetime]`, UTC, rendered RFC 3339). Byte identity is defined for identical input bytes, identical profile, identical revision and identical clock value.
- Rendering: `canonical_json(value)` (sorted keys, compact separators, `ensure_ascii=False`, LF terminated, UTF-8). With `--output`, the same bytes are written.

## 4. Requirements Mapping and Design

### 4.1 `python_cli` (argparse, Click, Typer)

Root-name resolution, in order (proposal):

1. Literal name in source: argparse `ArgumentParser(prog="x")`; Click `@click.group(name="x")` or `@click.command("x")`; `typer.Typer(name="x")`. Property `name_source: "literal"`.
2. Console script: script tables `[project.scripts]`, `[project.gui-scripts]` and `[tool.poetry.scripts]` in any `pyproject.toml` in the input mapping. Each entry yields a `cli-command` at the `pyproject.toml` path with declaration equal to the script name and property `table` (for example `project.scripts`). The target `module:attribute` is used internally only and never exported. A parser root attaches to the script when the target module resolves to exactly one input (`<module path>.py` or `<module path>/__init__.py`, matched as a path suffix after the source root) and the attribute names the Click or Typer root object, or the function whose body constructs the argparse root. On a unique match, the root's subcommands and options are parented to the script element. Otherwise the root is unattached.
3. Fallback: the module dotted name relative to the containing `selection.source_roots` entry (`src/pkg/cli.py` with root `src` becomes `pkg.cli`). Property `name_source: "module"`.

| Framework | Reliably extractable | Dynamic, becomes a diagnostic | Elements and declaration |
|---|---|---|---|
| argparse | `p = argparse.ArgumentParser(...)` and aliases; `s = p.add_subparsers(...)`; `c = s.add_parser("name", ...)` (nested); `p.add_argument("--long", "-s", ...)` and positional `p.add_argument("file")`; `add_argument_group` and `add_mutually_exclusive_group` receivers map to their parser; literal `required=`, `action=`, `help=` | Non-literal option strings, `*args`, `add_parser` with a non-literal name, `add_parser` inside a loop, `parents=[...]` (`cli-parents-unresolved`), `add_argument` or `add_parser` on an untracked receiver such as a parser passed into a helper function (`cli-unbound-registration`) | `cli-command` per parser: declaration = root name, then space-separated subcommand names (`tool sync`). `cli-option` per argument: declaration = command path, one space, first `--` string, else the first `-` string, else the bare positional name (proposal for positionals: `tool sync file`, property `positional: true`). |
| Click | `@click.command(...)` and `@click.group(...)` on a function (alias-aware, including `from click import command`); `@<group>.command(...)` and `@<group>.group(...)` where `<group>` is a tracked group function name; `<group>.add_command(<tracked>, name="x")`; `@click.option("--x/--no-x", "-x", "dest")` and `@click.argument("name")` decorators on the same function | `cls=` custom classes, lazy or plugin groups, `click.Group(...)` or `click.Command(...)` constructed objects, `add_command` with a non-literal or untracked argument | Command name from `name=` literal, else the function name lower-cased with `_` replaced by `-` (Click 7.0) and the suffixes `-command`, `-cmd`, `-group`, `-grp` removed (Click 8.2.0; both verified against the Click changelog). Click option strings split at `/`; the long option is the first `--` part. Declarations as for argparse. |
| Typer | `app = typer.Typer(...)`; `@app.command(...)`; `@app.callback()` (root-level options); `app.add_typer(sub, name="x")`; `typer.run(func)`; parameters: `typer.Option(...)` or `typer.Argument(...)` as a default or inside `Annotated[...]`; a parameter without a default is an argument, a parameter with a plain default is an option `--<name with - for _>` | `add_typer` without a literal name and without a literal `Typer(name=)`, commands registered through non-decorator calls, parameter declarations built from variables | Command name from `name=` literal, else the function name lower-cased with `_` replaced by `-` (Typer naming rule, not verified in this research; the plan's tests pin the chosen rule). A Typer app with exactly one command and no callback runs that command as the root; property `single_command: true`. Boolean options declare `--x` (the generated `--no-x` is not a separate element). |

Properties (proposal): `framework` (`argparse`, `click`, `typer`, `console-script`), `name_source`, `positional`, `required`, `action`, `short` (short option string), `help` (literal help text only), `has_default` (boolean). Default values are never exported. `line_range` comes from the call or decorator node (`lineno`, `end_lineno`).

### 4.2 `python_http` (FastAPI, Flask)

Two passes over all `*.py` inputs. Pass 1, per module: route sites and router or app objects with their own prefixes. Pass 2: resolve mount edges across modules through the import table and compose full templates.

| Framework | Reliably extractable | Dynamic, becomes a diagnostic | Composition rule |
|---|---|---|---|
| FastAPI | `FastAPI(...)` and `APIRouter(prefix="/x")`; decorators `.get .post .put .patch .delete .options .head .trace` with a literal path; `.api_route(path, methods=[...])` (default `GET`); `.add_api_route(path, endpoint, methods=[...])`; `.include_router(router, prefix="/y")` on an app or router; `.websocket(path)` (proposal: method token `WEBSOCKET`, property `protocol: websocket`) | Non-literal path or methods, non-literal prefix (`settings.API_PREFIX`), routers from modules outside the inputs, `.mount(...)` sub-applications (`http-mount-unresolved`), decorators on untracked receivers whose first argument is a string beginning with `/` (`http-unbound-route`; plain `.get(` calls on untracked receivers are ignored because `dict.get` is common) | Full template = include prefixes (outermost first) + router `prefix` + route path. A router included `n` times yields `n` elements. A router never included keeps its own prefix, property `mounted: false`. An unresolvable prefix segment is rendered as `<dynamic>` (for example `GET <dynamic>/items/{item_id}`), property `prefix_resolved: false`, so identity stays stable and the gap is visible. |
| Flask | `Flask(...)`; `Blueprint("name", __name__, url_prefix="/x")`; `@x.route(path, methods=[...])` (default `GET`; Flask's automatic `HEAD` and `OPTIONS` are not emitted); `.get .post .put .patch .delete` shortcuts (Flask 2.0); `.add_url_rule(path, ..., methods=[...])`; `.register_blueprint(bp, url_prefix="/y")` on an app or parent blueprint | Non-literal arguments; class-based views registered through `as_view` without literal `methods` (`http-method-view-unresolved`); blueprints from modules outside the inputs | The `url_prefix` given to `register_blueprint` replaces the blueprint's own `url_prefix`; nested blueprint prefixes concatenate. Converters such as `<int:id>` are kept verbatim. |

Declaration: `<METHOD> <template>`, one element per method. Element `path` is the file containing the route site. `name` is the handler function name when the site is a decorator on a `def`, else the template. Properties: `framework`, `mounted`, `prefix_resolved`, `protocol`.

### 4.3 `python_public_api`

- Module qualified name derives from the path relative to the containing `selection.source_roots` entry. A module whose path has a segment beginning with `_` (other than `__init__`) or a segment that is not a Python identifier is not public and yields no elements (one `information` diagnostic `module-not-importable` for the non-identifier case).
- Literal `__all__` forms: `__all__ = [...]` or `(...)` of string constants; `__all__: list[str] = [...]`; `__all__ += [...]`; `__all__.extend([...])`; `__all__.append("x")`, applied in statement order at module top level. Elements are the names in the final `__all__`, property `basis: "all"`, property `symbol_kind` from the top-level binding (`function`, `async-function`, `class`, `variable`, `import`), or `unresolved` with a warning `public-api-name-unresolved` when no binding exists.
- Non-literal `__all__` (computed concatenation, comprehension, star-unpacking of another module's `__all__`): warning `public-api-dynamic-all`, then fall back to the naming rule, property `basis: "naming"`. This choice is a proposal: the alternative (no elements for the module) hides the module from the inventory.
- Naming rule (no `__all__`): top-level `def`, `async def`, `class`, and `Name` targets of `Assign` or `AnnAssign` whose name does not begin with `_`, including those inside top-level `if` and `try` bodies (all branches). Imported names are not public under the naming rule.
- Declaration: the qualified name (`pkg.mod.name`). Class members are out of scope in this feature.

### 4.4 `config_files`: `pyproject.toml` and `.env`

- `pyproject.toml` (basename match only): parsed through the resolved TOML loader (section 2.2). Every key under `tool.*` yields a `config-key`, excluding script tables (owned by `python-cli`) and dependency subtrees (`tool.poetry.dependencies`, `tool.poetry.dev-dependencies`, `tool.poetry.group.*.dependencies`, `tool.poetry.extras`), which `python-architecture` reads. `[project]` and `[build-system]` are not configuration. Arrays of tables use the segment `[]` (`tool.x.items[].name`).
- Declaration quoting (proposal): segments matching `^[A-Za-z0-9_-]+$` stay bare; any other segment is a TOML basic string with `"` and `\` escaped (`tool.poetry.scripts."dev.docs.inventory"` style), so `a."b.c"` and `a.b.c` cannot collide. The same rule applies to JSON Schema and YAML key paths.
- Shape (proposal): property `value_type` in `table`, `array`, `string`, `integer`, `float`, `boolean`, `datetime` (TOML); property `format` (`toml`). No value is read into an element.
- `.env` family (basename `.env`, `.env.<suffix>`, or `<name>.env`): bounded lexical scan. Lines are decoded UTF-8 (BOM allowed); blank and `#` lines skipped; optional `export ` prefix; key grammar `^[A-Za-z_][A-Za-z0-9_]*$` before `=`. A value opening a quote that does not close on its line consumes lines until the closing quote, so a multi-line value never becomes a key. Unrecognized lines yield one warning `env-line-unrecognized` with a count. The key is sliced before `=`; the value text is never bound to a variable that reaches output. Declaration = key; `line_range` = the line; property `format: env`.
- Risk: a real `.env` holds secrets, and the snapshot records its SHA-256 in `inputs` and `source_sha256` (the schema requires both). A digest of a low-entropy secret file can be confirmed offline. Recommendation: consumers exclude real `.env` files through profile `exclusions` and keep `.env.example` in scope; 900010 onboarding and the 1020 starter profile should carry that exclusion (open question).

### 4.5 `config_files`: JSON Schema and YAML

- JSON Schema detection (proposal): basename ends `.schema.json`, or a `.json` input whose parsed root has a `$schema` string containing `json-schema.org`. Other JSON files are ignored by this analyzer.
- Walk (proposal): root `properties` members, recursing into nested `properties`, `items.properties` (segment `[]`), `allOf`/`anyOf`/`oneOf` members (union; property `conditional: true` for `anyOf` and `oneOf`), and local `$ref` targets (`#/$defs/...`, `#/definitions/...`) up to depth 16 with a visited-pointer set. A cycle, remote `$ref` or depth overflow yields a warning `json-schema-ref-unresolved` and no expansion of that branch. `default`, `enum`, `const`, `examples` and `pattern` are never read into output.
- JSON Schema shape: property `schema_type` (the literal `type` string, or `multiple` for an array of types, or absent), `required` (boolean from the parent's `required` list), `format: json-schema`.
- YAML: `parse_document(content, format="yaml", artifact_path=path, limits=ParseLimits(document_bytes=MAX_INPUT_BYTES))`. Every mapping key path yields a `config-key`; sequences contribute `[]`; property `value_type` in `object`, `array`, `string`, `integer`, `number`, `boolean`, `null`; `format: yaml`.
- YAML limits inherited from `parse_document` (verified): multi-document streams, merge keys, unquoted timestamps and other non-JSON tags, and non-mapping roots reject the whole file. These become `yaml-invalid` diagnostics. Real-world YAML (Kubernetes manifests with `---`, workflow files with timestamps) may hit them; documented.
- Per-input key bound (proposal): `MAX_KEYS_PER_INPUT = 10_000`; overflow yields `input-key-limit` (error, blocking) and no elements for that input.
- Value redaction: values are parsed in memory by `tomllib`/`tomli`/`parse_document` and discarded; element `properties` hold only `value_type`, `schema_type`, `required`, `conditional`, `format`. "Shape" means these type names.

### 4.6 `architecture`

- `architecture-component` for each package (directory holding `__init__.py`) and each module, declaration = dotted name, property `component_kind` (`package`, `module`).
- Import edges come from new `ast` code (`Import`, `ImportFrom` including relative imports resolved against the module's package, at any nesting level). Only internal targets that resolve to an input module or package are kept (longest dotted-prefix match). `importlib.import_module` and `__import__` calls are not followed.
- Edge encoding (proposal, forced by the scalar `properties` shape and the absence of an `extensions` field on `SurfaceElement`): property `import_count` (integer) and properties `import-0001`, `import-0002`, ... whose values are the target dotted names in sorted order. Bound: 1000 edges per component; overflow yields `architecture-edge-limit` (warning) and the count only.
- External dependencies (reusing `parse_python_dependencies`): `requirements*.txt` (`format="requirements"`) and `setup.cfg` (`format="setup-cfg"`) yield `architecture-component` elements with `component_kind: external-dependency`, declaration = the sanitized distribution name, properties `ecosystem: python` and `role`. Version constraints are not exported. `DependencyInputError` becomes one diagnostic with the error's fixed `code` (`dependency-unsupported` and similar, already in identifier grammar) and no elements for that file. `pyproject.toml` `[project] dependencies` (PEP 508 name part) and `tool.poetry.dependencies` keys are read through the shared TOML loader.

### 4.7 `snapshot_builder` and `cli_inventory`

`snapshot_builder.py` (pure, proposal):

- `build_snapshot(inputs: Mapping[str, bytes], *, profile: DocsProfile, profile_sha256: str, registrations: Sequence[AnalyzerRegistration], analyzers: Sequence[SurfaceAnalyzer], revision: str | None, captured_at: datetime) -> JsonObject`: validates keys (`relative_path`, `check_path_collisions`), applies the over-bound rule, records `inputs` through `SnapshotFile`, runs each analyzer on the in-bound mapping, filters elements to `profile.surface_selection.element_kinds`, de-duplicates, sorts, projects through `element_to_json`/`diagnostic_to_json`, and assembles the header and body.
- `render_snapshot(value: JsonObject) -> bytes`: `canonical_json`.

`cli_inventory.py` (thin I/O, proposal):

- Console script (root and package `pyproject.toml`): `"dev.docs.inventory" = "drm_copilot_docs.cli_inventory:main_inventory"`. `main_inventory() -> int` delegates to `run_inventory_cli(argv, *, ports: InventoryPorts, stdout, stderr, clock) -> int`.
- `dev.docs.inventory [--profile <path>] [--analyzer <id>]... [--revision <full object id>] [--output <relative path>]`, parsed with `argparse` (1020 convention), `SystemExit` caught.
- `--profile` default `docs/documentation-estate/docs-profile.json` (1020 default). `--analyzer <id>` is repeatable; when present it replaces `surface_selection.analyzers`; every id must be registered (`select_registrations` raises `ValueError` naming the first unknown id, mapped to exit 2) and must produce at least one kind in `element_kinds` (exit 2 otherwise); absent means the profile list, or every registered analyzer whose kinds intersect `element_kinds`. `--revision` must satisfy `is_full_revision` (exit 2 otherwise). `--output` writes the rendered bytes through an injected write port and replaces an existing file; without it the snapshot goes to stdout.
- `InventoryPorts` (frozen dataclass): `read_bytes(path: str, limit: int) -> bytes | None` (reads at most `limit` bytes; `None` for missing), `list_files(root: str, limit: int) -> tuple[str, ...]` (relative POSIX paths, symlinks not followed, sorted, raises on more than `limit`), `write_bytes(path: str, data: bytes) -> None`. The real implementations use `pathlib` relative to the current directory and are the only I/O in the feature.
- Flow: read and parse the profile (`parse_profile`; profile findings exit 1); compute `profile_sha256`; enumerate `source_roots`; drop paths matching `exclusion_reason`; read each file with limit `MAX_INPUT_BYTES + 1`; select and load analyzers (`select_registrations`, `load_analyzer`); `build_snapshot`; self-validate with `validate_artifact(..., artifact_kind="surface-inventory-snapshot")`; emit.
- Exit codes: 0 snapshot emitted with no blocking diagnostic; 1 snapshot emitted with at least one blocking diagnostic, invalid profile, or failed self-validation (defect guard, no output); 2 invocation error; 3 runtime failure (unreadable profile, aggregate bound exceeded, write failure, unexpected exception through the top-level handler with `# noqa: BLE001 - CLI top-level error handling`, a pre-authorized pattern). A one-line summary (`elements`, `diagnostics`, `blocking`) goes to stderr.

### 4.8 Registry entries (append-only shape, proposal)

Appended at the end of `ANALYZER_REGISTRY` in `analyzer_contract.py`, in identifier order, each as one Black-formatted block:

```python
    AnalyzerRegistration(
        identifier="config-files",
        element_kinds=("config-key",),
        module="drm_copilot_docs.analyzers.config_files",
        attribute="CONFIG_FILES_ANALYZER",
    ),
```

The other four follow the same shape: `python-architecture` (`("architecture-component",)`, `...analyzers.architecture`, `PYTHON_ARCHITECTURE_ANALYZER`), `python-cli` (`("cli-command", "cli-option")`, `...analyzers.python_cli`, `PYTHON_CLI_ANALYZER`), `python-http` (`("http-route",)`, `...analyzers.python_http`, `PYTHON_HTTP_ANALYZER`), `python-public-api` (`("public-symbol",)`, `...analyzers.python_public_api`, `PYTHON_PUBLIC_API_ANALYZER`). No existing line of `analyzer_contract.py` is edited. Sibling 900004 appends its own blocks after the same last line; the textual conflict is resolved in the later child's remediation loop (epic `### Cross-feature conflict surface`). The root `pyproject.toml` edit is one appended line after the 1020 `dev.docs.*` entries.

### 4.9 Module split (proposal, each production file below 500 lines)

| File under `packages/docs-runtime/src/drm_copilot_docs/` | Responsibility | Estimate (lines) |
|---|---|---|
| `analyzers/__init__.py` | Package docstring only | 10 |
| `analyzers/_bounds.py` | `MAX_INPUT_BYTES`, `MAX_INPUT_FILES`, `MAX_KEYS_PER_INPUT`, `make_diagnostic`, over-bound check, an `AnalysisBuilder` that de-duplicates and sorts into `SurfaceAnalysis` | 180 |
| `analyzers/_python_source.py` | Safe `ast.parse`, module naming from source roots, `ImportTable`, literal helpers (`literal_str`, `literal_str_sequence`) | 260 |
| `analyzers/python_cli.py` | `PythonCliAnalyzer`, command tree model, root-name resolution, `PYTHON_CLI_ANALYZER` | 300 |
| `analyzers/python_cli_argparse.py`, `python_cli_click.py`, `python_cli_typer.py` | Per-framework extraction into the shared command tree | 280 each |
| `analyzers/python_http.py` | `PythonHttpAnalyzer`, mount resolution, template composition | 300 |
| `analyzers/python_http_fastapi.py`, `python_http_flask.py` | Per-framework route and mount site extraction | 240 each |
| `analyzers/python_public_api.py` | `PythonPublicApiAnalyzer` | 260 |
| `analyzers/config_keys.py` | Key-path quoting, declaration assembly, shape names | 120 |
| `analyzers/config_toml.py` | TOML loader resolution, tool-table walk, script-table reader shared with `python_cli` | 260 |
| `analyzers/config_env.py`, `config_json_schema.py`, `config_yaml.py` | Per-format key extraction | 150, 260, 150 |
| `analyzers/config_files.py` | `ConfigFilesAnalyzer` dispatch by file name | 180 |
| `analyzers/architecture.py` | `ArchitectureAnalyzer`, components, import edges, external dependencies | 340 |
| `analyzers/snapshot_builder.py` | `build_snapshot`, `render_snapshot` | 280 |
| `cli_inventory.py` | `main_inventory`, `run_inventory_cli`, `InventoryPorts`, real ports | 320 |

The epic names `python_cli.py` and `python_http.py`; the per-framework helper modules are a permitted refinement. The feature creates more than three non-test Python production files, so execution needs the batch-budget-exempt large route in the item worktree (`execution-environment` `## Batch Budget`).

## 5. Testing Implications

- Layout: `tests/docs_runtime/analyzers/__init__.py`; one module per production module (`test_bounds.py`, `test_python_source.py`, `test_python_cli.py`, `test_python_cli_argparse.py`, `test_python_cli_click.py`, `test_python_cli_typer.py`, `test_python_http.py`, `test_python_http_fastapi.py`, `test_python_http_flask.py`, `test_python_public_api.py`, `test_config_keys.py`, `test_config_toml.py`, `test_config_env.py`, `test_config_json_schema.py`, `test_config_yaml.py`, `test_config_files.py`, `test_architecture.py`, `test_snapshot_builder.py`, `test_registrations.py`); a properties module `test_analyzer_properties.py` (split into `test_snapshot_properties.py` if it nears 500 lines); and `tests/docs_runtime/test_cli_inventory.py`.
- Fixtures are in-memory `bytes` constants in the test modules (Python sources, `pyproject.toml`, `.env`, JSON Schema, YAML). CRLF cases use `\r\n` escapes inside literals, because `.gitattributes` `* text=auto eol=lf` normalizes committed files. No test creates a file; CLI tests use `io.StringIO` streams, in-memory `InventoryPorts`, and a fixed clock.
- Acceptance criterion 1: one positive fixture per framework and format asserting the exact declarations and parent links, plus one dynamic case per framework asserting the diagnostic code and the absence of an element.
- Acceptance criterion 2 (property tests with `itertools`, no `random`, no `hypothesis`): `itertools.permutations` of the fixture mapping insertion order yields byte-identical `render_snapshot` output; two builds over the same bytes and clock are identical; every `element_id` equals `element_identifier(kind, path, declaration)`; elements are sorted and unique.
- Acceptance criterion 3: an `itertools.product` over formats (TOML, `.env`, JSON Schema, YAML) and marker values placed in every value position (including JSON Schema `default`, `enum`, `examples`) asserts the marker bytes never appear in the rendered snapshot.
- Acceptance criterion 4: `itertools.product` over the five analyzers and sizes `MAX_INPUT_BYTES - 1`, `MAX_INPUT_BYTES`, `MAX_INPUT_BYTES + 1` asserts the over-bound case yields exactly one `input-over-bound` diagnostic, no element with that path, and no `inputs` entry.
- Acceptance criterion 5: `validate_artifact` returns no finding for the built fixture snapshot, and `inputs[*].sha256` equals `hashlib.sha256` of each in-bound fixture input.
- T2 property obligation: at least one enumerated property test per pure public function (key-path quoting round trip and injectivity; module naming over source-root permutations; template composition associativity over prefix products; Click and Typer name derivation over a name product; `.env` key extraction invariant under value content; `build_snapshot` permutation invariance).
- TOML fallback: `config_toml.resolve_toml_loads(import_module=...)` tested with fakes for `tomllib` present, only `tomli` present, and neither present (diagnostic `toml-parser-unavailable`); real parsing runs on every CI interpreter.
- Registry: `test_registrations.py` asserts the five entries, `validate_registry(ANALYZER_REGISTRY) == ()`, and that `load_analyzer` with the real `importlib.import_module` returns an object whose `identifier` and `element_kinds` match.
- Coverage: `--cov=drm_copilot_docs.analyzers --cov=drm_copilot_docs.cli_inventory --cov-branch --cov-report=json:SCRATCH/issue-1022-coverage.json`; per-file line and branch figures read from the JSON report.
- Isolation: a reversed-order single-process run of the new test modules. No module-level cache in production code (the TOML loader is resolved per call or per analyzer instance).

## Numeric Derivation Evidence

The approved acceptance criteria in the #1022 `issue.md` carry no count. Two enumerations support the design and the fixture list.

Analyzer registrations appended by #1022:

- Complete Family: analyzer modules under `packages/docs-runtime/src/drm_copilot_docs/analyzers/` that implement `SurfaceAnalyzer` for #1022
- Exhaustive Search Scope: the epic section `### 900003 - docs-surface-analyzers-python-config (wave 1, C4)` file list and the #1022 `issue.md` `## Proposed Behavior` bullets, every module named in either
- Inclusion Rules: a module that produces surface elements from inputs
- Exclusion Rules: `analyzers/__init__.py`, `snapshot_builder.py` (assembles, does not analyze), `cli_inventory.py` (I/O), and the helper modules proposed in section 4.9 (not registered)
- Primary Search Strategy or Query Expression: read the epic 900003 `Files (create)` sentence and list each `analyzers/<name>.py` with an extraction responsibility
- Primary Member Set: python_cli, python_http, python_public_api, config_files, architecture
- Primary Count: 5
- Cross-check Search Strategy or Query Expression: read each bullet of `issue.md` `## Proposed Behavior` and keep bullets describing extraction (excluding `snapshot_builder.py` and `cli_inventory.py`)
- Cross-check Member Set: python_cli, python_http, python_public_api, config_files, architecture
- Cross-check Count: 5
- Member-set Comparison: the normalized primary and cross-check member sets are equal

Input families named by acceptance criterion 1:

- Complete Family: input frameworks and formats each analyzer fixture must cover
- Exhaustive Search Scope: acceptance criterion 1 in the epic 900003 section and in `issue.md`
- Inclusion Rules: every framework or format named in the criterion text
- Exclusion Rules: none
- Primary Search Strategy or Query Expression: tokenize the epic criterion text after "covering"
- Primary Member Set: argparse, Click, Typer, FastAPI, Flask, pyproject.toml, .env, JSON Schema, YAML
- Primary Count: 9
- Cross-check Search Strategy or Query Expression: tokenize the `issue.md` `## Acceptance Criteria (early draft)` first item after "covering"
- Cross-check Member Set: argparse, Click, Typer, FastAPI, Flask, pyproject.toml, .env, JSON Schema, YAML
- Cross-check Count: 9
- Member-set Comparison: the normalized primary and cross-check member sets are equal

## 6. Risks

- Upstream dependency: #1020 is planned, not executed. Phase 0 of the #1022 plan must verify every symbol in section 1.1 on the integration branch and stop if any differs. A 1020 test that uses a sample "unknown" analyzer id against the default registry (`test_unknown_analyzer_identifier_points_at_analyzer_index`) breaks if its sample id equals one of the five ids here; preflight checks the literal.
- Identity stability: declaration rules (root naming, quoting, `<dynamic>` segments) are part of element identity. Changing them later orphans ledger entries, which under T2 is a contract change; the analyzer `version` in the snapshot should change with any such rule change.
- Lexical limits: dynamic registration, cross-package routers, settings-driven prefixes and YAML features outside `parse_document` produce diagnostics rather than elements.
- `.env` digests (section 4.4) and the 3.10 TOML fallback for consumers without `tomli` (section 2.2).
- Append-only conflicts in `analyzer_contract.py` (900004) and the root `pyproject.toml` script table (900002, 900005, 900006, 900008).

## Pre-Mortem

- **Review checklists**: a reviewer flags a configuration value reaching output, a broad `except`, an unauthorized suppression, or a production path excluded from coverage. The plan must carry the value-redaction property test, catch only `SyntaxError`, `ValueError`, `DependencyInputError` and the TOML decode error in analyzers, limit `# noqa: BLE001` to the CLI top-level handler, and add no coverage exclusion.
- **Coverage**: per-framework extractors have many branches, and the I/O ports in `cli_inventory.py` can fall below 75% branch coverage. The plan must pair each recognized form with a dynamic-form test, inject `InventoryPorts` and the clock, measure with dotted `--cov` targets, and read per-file branch figures from the JSON report.
- **Mirror parity**: not applicable, because no `.claude`, `.github`, `.codex`, `.agents` or `extensions/drm-copilot/resources/` file is edited and no fact in the execution-environment brief changes (a new console script and Python modules are not brief facts).
- **File size**: `python_cli.py`, `python_http.py` and `architecture.py` could pass 500 lines if per-framework logic is inlined. The plan must keep the section 4.9 split and record `wc -l` counts for every new production and test file.
- **Test isolation**: a module-level loader cache or `set` iteration order could make results depend on test order or hash seed. The plan must avoid production caches, sort every collection before output, and record a reversed-order single-process run of the new test modules.
- **CI-only behavior**: CI runs Python 3.10 (no `tomllib`, no PEP 695 grammar) on Linux (case-sensitive paths) with `eol=lf` checkout. The plan must route TOML through the fallback seam, keep fixture sources 3.10-compatible, use POSIX relative paths only, and express CRLF cases as escapes inside byte literals.
- **Evidence**: gate artifacts outside `<FEATURE>/evidence/<kind>/` or with plan-time stamps are rejected. The plan must write baseline, QA-gate and regression evidence under the canonical folders with write-time UTC stamps and record `SCRATCH` instead of host paths.

## Automation Feasibility

All steps are automatable. The analyzers are pure functions over in-memory mappings, so every acceptance criterion is proven by Pytest without network, subprocess or temporary files. The size bound, redaction and determinism criteria are enumerated property tests. Schema conformance uses the 1020 `validate_artifact` function. The console script is exercised in-process with injected ports, and one smoke run (`poetry run dev.docs.inventory --profile examples/docs/v1/docs-profile.example.json`) is a deterministic command. The registry and `pyproject.toml` edits are text appends checked by tests. Formatting, lint, type checking, coverage thresholds and file-size counts are existing command-line gates. No step needs human judgment, except the open questions below, which are owner decisions and not execution steps.

## 7. Items for the Orchestrator to Confirm

- Whether `tomli` should become a declared dependency of `packages/docs-runtime` with a `python < 3.11` marker (owner approval and a `poetry.lock` change), or remain an undeclared fallback with a diagnostic.
- Whether 1020's starter profile or 900010's onboarding should exclude real `.env` files by default.
- Whether 1020 should add an `extensions` field to `SurfaceElement` (an epic-level change), which would replace the indexed `import-NNNN` properties.
- The 1020 interpretation of `AnalyzerRegistration.attribute` (instance versus class) and of the "one entry per line" registry rule under Black.
- The `dev.docs.inventory` behavior for `--analyzer` ids whose kinds do not intersect the profile's `element_kinds` (proposed exit 2).
- Python-version and grammar dependence: whether the snapshot should record the interpreter version (no schema field exists today).
