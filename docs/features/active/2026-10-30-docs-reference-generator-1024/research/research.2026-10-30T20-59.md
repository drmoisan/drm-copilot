# Research: docs-reference-generator (Issue #1024)

- Issue: #1024 (epic #1019 `documentation-estate-tooling`, epic child 900006, wave 1, band C3)
- Branch: `feature/docs-reference-generator-1024`
- Research timestamp: 2026-10-30T20-59 (UTC, read from an external time service because the
  researcher has no shell clock; the orchestrator may re-stamp if required)
- Scope: preparation only. Nothing is implemented. Upstream 1020 and 1021 exist on this branch only
  as prepared spec and plan documents; every 1020/1021 symbol below is "planned by 1020" or "planned
  by 1021" and must be re-confirmed against the merged code before 900006 executes.

## 0. Sources Read

| Source | Sections used |
|---|---|
| `docs/features/epics/documentation-estate-tooling/epic.md` | `## Shared Design` (`### Naming contract`, both `### Decisions recorded during preparation of ...` sections, `### Reuse of the merged discovery runtime`, `### Cross-feature conflict surface`), `### 900006 - docs-reference-generator`, `### 900007 - docs-mcp-tools`, `## Decomposition Rationale` |
| `docs/features/active/2026-10-30-docs-reference-generator-1024/issue.md` | full; `spec.md` and `plan.2026-10-30T16-54.md` in the same folder are unfilled templates |
| 1020 `spec.md` | `## Behavior`, `## Inputs / Outputs`, `### Docs common $defs`, `### Artifact schema: docs-profile`, `### Artifact schema: surface-inventory-snapshot`, `### Element identifier function and declaration conventions`, `### SurfaceElement and related models`, `### Profile models and profile.py API`, `### Schema validation and resources API`, `### CLI`, `## Constraints & Risks`, `## Implementation Strategy` |
| 1020 `plan.2026-10-30T16-08.md` | tasks P1-T1 to P5-T5 |
| 1020 `research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md` | `### 2.1 Distribution of the docs runtime`, import-mode note, property-test note |
| 1021 `spec.md` | `## Page-Metadata Schema`, `## Finding-Code Catalog`, `## Links, Anchors, and Slugs`, `## Diataxis Mode Rules`, `## Orphan Detection and Configuration`, `## API / CLI Surface`, `## Implementation Strategy`, `## Open Questions and Assumptions` |
| 1021 `plan.2026-10-30T16-13.md` | conventions block, `## Pre-Mortem`, tasks P2-T1 to P6-T2, P7-T1 |
| 1021 `research/research.2026-10-30T20-35.md` | Diataxis rationale, console entry pattern, open question 5 |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py` | `row`, `stable_id`, `diagnostic` |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py` | `MutationWriter`, `MutationPrimitives`, `GuardedMutationWriter`, `MutationArtifact`, `commit_mutation` |
| `packages/discovery-runtime/src/drm_copilot_discovery/findings.py` | `validate_finding_path`, `Finding`, `finding_key`, `FindingCollector` |
| `packages/discovery-runtime/src/drm_copilot_discovery/parsing.py` | `parse_document` |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli.py` | `CliPorts`, `_failure`, `_emit`, `run_cli` |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli_commands.py` | `--write` / `--dry-run` switch construction (`OPTIONAL_WRITES`, `INTRINSIC_WRITES`) |
| `schemas/discovery/v2/common.schema.json` | `$defs` `identifier`, `text`, `relative-path`, `path-or-glob` |
| `extensions/drm-copilot/src/discovery-runtime.ts`, `repo-automation-execute-discovery.ts` | MCP-to-Python invocation pattern |
| `tests/discovery_runtime/test_t2_properties.py` | `Draw`, `SEEDS` |
| `tests/conftest.py` | `mem_fs_path` |
| root `pyproject.toml` | `[tool.poetry.dependencies]`, `[tool.poetry.scripts]`, `[tool.pytest.ini_options]`, `[tool.coverage.run]`, `[tool.pyright]` |
| `quality-tiers.yml` | `packages/discovery-runtime` entry |
| PyMarkdown rule documentation `docs/rules/rule_md033.md` and `rule_md024.md` (GitHub `jackdewinter/pymarkdown`, fetched) | configuration tables |

## 1. Current State Analysis

### 1.1 Symbols consumed from 1020 (all planned by 1020)

Package `packages/docs-runtime`, import name `drm_copilot_docs`, version `1.0.0` (1020 spec
`## Behavior`).

`surface_models.py` (1020 spec `### Element identifier function and declaration conventions` and
`### SurfaceElement and related models`):

- `ElementKind` (a `Literal` of the six kinds) and `ELEMENT_KINDS: tuple[ElementKind, ...]` in the
  order `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`,
  `architecture-component`.
- `element_identifier(*, kind, path, declaration) -> str`: `stable_id(kind, row(kind=..., path=...,
  declaration=...))` from `drm_copilot_discovery.analyzer.findings`; result `<kind>-<64 hex>`.
  Verified on this branch: `stable_id(prefix, value)` returns `prefix + "-" + sha256(canonical_json(value))`
  and `row(**values)` returns a `JsonObject`.
- `SurfaceElement` (frozen, `kw_only`): `element_id`, `kind`, `path`, `declaration`, `name`,
  `parent_id`, `analyzer_id`, `source_sha256`, `line_range: tuple[int, int] | None`,
  `properties: JsonObject`. `__post_init__` recomputes the identifier and raises `ValueError` on
  mismatch, enforces the `cli-option` parent rule and `1 <= start <= end`.
- `element_to_json(element) -> JsonObject` (projection to snapshot `$defs/element`).
- Declaration conventions per kind (binding): `cli-command` full command path; `cli-option` command
  path, one space, long option; `http-route` upper-case method, one space, route template;
  `config-key` dotted key path; `public-symbol` qualified name; `architecture-component` package or
  module path.

Gap G1 (no snapshot loader). 1020 defines `element_to_json` but no inverse and no snapshot loader.
The snapshot `$defs/element.properties` is an array of `{name, value}` objects, while
`SurfaceElement.properties` is a `JsonObject`; the inverse mapping (array to mapping, rejecting a
duplicate `name`) is not specified upstream. 900005 (wave 1, parallel) will need the same loader.
Smallest resolution inside 900006: a pure module `drm_copilot_docs/reference/snapshot_input.py`
(file-name refinement permitted by the epic) that parses with `parse_document`, validates with
`validate_artifact(..., artifact_kind="surface-inventory-snapshot", ...)`, and constructs
`SurfaceElement` values, with a round-trip property `element_to_json(load(x)) == x`. Flag for the
epic: a shared loader in `drm_copilot_docs` would avoid a 900005 duplicate.

`profile_models.py` and `profile.py` (1020 spec `### Profile models and profile.py API`,
`### Artifact schema: docs-profile`):

- `parse_profile(content: bytes, *, format: Literal["json", "yaml"], artifact_path: str,
  registry=None) -> ProfileLoadResult`; `ProfileLoadResult.profile: DocsProfile | None`,
  `.findings`, `.ok`.
- Fields 900006 reads: `DocsProfile.repository` (`{id}`), `documentation_roots`
  (`DocumentationRoot`: `id`, `path`, `audience_ids`), `page_owners` (`PageOwner`:
  `path_or_glob`, `owner`), `diataxis_policy` (`DiataxisPolicy`: `modes`, `required_front_matter`,
  `directory_modes` of `DirectoryMode`: `path_or_glob`, `mode`), `artifact_paths.inventory_snapshot`.
  The 1020 spec states "900006 reads `diataxis_policy` and `page_owners`".
- Default profile path used by 1020: `docs/documentation-estate/docs-profile.json`; a `.yaml` or
  `.yml` extension selects YAML.

Gap G2 (no element-to-page mapping and no reference output root). The profile has no field that
maps elements to pages and no reference output directory. Smallest resolution inside 900006 (no
schema change): derive the reference directory from `diataxis_policy.directory_modes` (exactly one
entry with `mode: reference` whose `path_or_glob` contains no glob metacharacter), overridable by a
CLI `--output-dir`; map element kinds to fixed family page names (section 4.3). If the owner wants
a profile field instead, that is an epic-level change to the 1020 `docs-profile` schema.

Gap G3 (matching semantics undefined). 1020 does not define how `page_owners[*].path_or_glob` or
`directory_modes[*].path_or_glob` match a page path, nor precedence among several matches. 900005
(`owner_assigned` parity) needs the same rule. Proposed rule for 900006 (section 4.3), flagged as
an epic-level item so 900005 adopts the same rule.

Gap G4 (audience grammar mismatch, epic-level). Profile audience identifiers use discovery
`identifier` (`^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`, verified in
`schemas/discovery/v2/common.schema.json`), which admits `.` and `_`. The 1021 page-metadata
`audience` items use `^[a-z0-9][a-z0-9-]*$`. A valid profile audience such as `api_users` therefore
cannot appear in a page that passes the checker. 900006 cannot fix this; it reports an error
(`REFERENCE_AUDIENCE_INVALID`) naming the audience. Also `documentation_roots[*].audience_ids` may
be empty (discovery `identifiers` has no `minItems`), while page-metadata `audience` has
`minItems: 1`; 900006 reports `REFERENCE_AUDIENCE_MISSING`. Record both for epic resolution.

`schema_validation.py` (1020 spec `### Schema validation and resources API`): `validate_artifact(value,
*, artifact_kind, artifact_path, resources=None) -> tuple[Finding, ...]`, code `SCHEMA_INVALID`.
Used by `snapshot_input.py`.

CLI pattern (1020 spec `### CLI`): console scripts declared in both the root and the package
`pyproject.toml` as `"dev.docs.<name>" = "drm_copilot_docs.cli:main_<name>"`; each `main_*` is a
zero-argument wrapper returning `int` and delegating to `run_cli(command, argv, *, ports, stdout,
stderr) -> int` with injectable read and write ports; `argparse` with `SystemExit` caught; exit codes
`0` success or help, `1` validation failure, `2` invocation error, `3` runtime or output failure with
a fixed stderr line from a top-level handler. `--format text|json` selects output.

Discovery types reused unchanged (verified on this branch): `drm_copilot_discovery.findings.Finding`
(fields `code`, `message`, `next_action`, `severity`, `artifact_path`, `pointer`, `related_ids`,
`related_paths`; `related_ids` must match the identifier grammar, which element identifiers
satisfy), `finding_key`, `FindingCollector`, `validate_finding_path`;
`drm_copilot_discovery.parsing.parse_document(content, *, format, artifact_path=None, limits=None)`.

### 1.2 Symbols consumed from 1021 (all planned by 1021)

Package `packages/docs-page-check`, import name `drm_copilot_docs_check` (imports nothing from
`drm_copilot_docs`).

Page-metadata schema (1021 spec `## Page-Metadata Schema`), `$id`
`urn:drm-copilot:docs:1.0.0:page-metadata`, closed object:

| Field | Required | Constraint |
|---|---|---|
| `owner` | yes | string, `minLength 1`, `^\S(.*\S)?$` |
| `last_reviewed` | yes | string `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`, calendar-valid via `datetime.date.fromisoformat`; no clock comparison |
| `audience` | yes | array of string, `minItems 1`, `uniqueItems`, items `^[a-z0-9][a-z0-9-]*$` |
| `diataxis_mode` | yes | `tutorial`, `how-to`, `reference`, `explanation` |
| `surface_refs` | yes | array of string, `uniqueItems`, may be empty, items `^\S+$` |
| `title` | no | string, `minLength 1` |
| `extensions` | no | open object |

Front-matter parsing rules: block starts when line 1 is exactly `---`, ends at the next `---` or
`...`; BOM removed, CRLF normalized; `yaml.SafeLoader` subclass maps timestamps to source text and
rejects duplicate keys.

Finding codes (1021 spec `## Finding-Code Catalog`): `FRONT_MATTER_MISSING`,
`FRONT_MATTER_MALFORMED`, `FRONT_MATTER_FIELD_MISSING`, `FRONT_MATTER_FIELD_INVALID`,
`LINK_TARGET_MISSING`, `LINK_ANCHOR_MISSING`, `DIATAXIS_MODE_MISMATCH`, `PAGE_ORPHANED`.

Diataxis rules (1021 spec `## Diataxis Mode Rules`): for `reference`, only `DX-NO-INSTRUCTION`
applies (fails on a heading whose text starts, case-insensitively, with `how to ` or matches
`^step\s+[0-9]+\b`). `DX-GENERATED-REFERENCE` fails a generated block on any non-reference page.
Cross-feature constraint stated by 1021: 900006 must not emit headings beginning `How to` or
`Step <n>`.

Orphan rule (1021 spec `### Reachability`, `### CheckConfig`): breadth-first search from entry
pages (default `README.md`, `index.md` relative to `--root`, default root `docs`) over resolved
Markdown links; directory links resolve to `<dir>/README.md` then `<dir>/index.md`. A generated page
avoids `PAGE_ORPHANED` only if some reachable page links to it (or to its directory when it is a
`README.md` or `index.md`). The generator cannot guarantee this for a consumer; the integration
test supplies an entry page that links each generated page (section 4.3, open question Q3).

Link and anchor rules (1021 spec `## Links, Anchors, and Slugs`): relative links must resolve to a
page or to a path accepted by the injected `path_exists`; fragments must match a slug. The
generator therefore emits no links (source paths are rendered as code spans), which removes both
link codes from the generator's risk surface.

In-process checker API for the integration test:

- Spec-level seam (1021 spec `### Command`): `run_check(argv, *, stdout, stderr, read_tree,
  path_exists) -> int`, exit `0` when no findings; JSON output with `--format json` carries
  `"summary": {"finding_count": ...}`.
- Plan-level pure function (1021 plan P6-T1): `collect_findings(pages, config, *, path_exists,
  schema=None)` with `CheckConfig` from `config.py` (P2-T3: `parse_config(argv)`,
  `resolve_entry_pages(config, pages)`).
- The exact `read_tree` callable signature is not pinned by the 1021 spec (P6-T1 names
  `read_markdown_tree(base, root)` as the production reader). The 900006 plan must read the merged
  1021 `cli.py` before writing the integration test. Recommendation: drive `run_check` (the
  spec-level seam) with an in-memory `read_tree` and `frozenset(...).__contains__` as
  `path_exists`, and assert exit `0` plus `finding_count == 0`; do not run it under `mem_fs_path`,
  because that fixture patches `Path.read_bytes` and would intercept the packaged-schema read (1021
  plan P6-T2 records the same hazard).

### 1.3 Discovery runtime patterns (verified present on this branch)

- `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py`: identities are pure
  functions of canonical semantic data (`stable_id`), never timestamps; `diagnostic` derives its id
  from `(code, path, analyzer)`.
- `packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py`: the module never opens
  files; trusted adapters are injected (`MutationWriter`, `MutationPrimitives` with
  `create_exclusive` and `replace_if_digest(..., expected_sha256=...)`). `commit_mutation(plan, *,
  writer, dry_run=False)` performs fresh reads but no writes on dry run, reports
  `MutationArtifact.status` in `planned`, `created`, `updated`, `skipped`, `conflict`, preserves
  canonical output order, stops at the first failed write, and reports uncertain paths. The class
  itself is bound to the discovery snapshot and path policy, so 900006 adopts the pattern (status
  vocabulary, digest-guarded replace, exclusive create, stop on first failure), not the types.
- Dry-run convention: `cli_commands.py` adds a `--write` switch to optional-write operations and
  `--dry-run` to optional and intrinsic writers; without `--write` an optional writer writes
  nothing. 900006 is an optional writer, so `--write` alone matches the precedent and the epic AC.
- No Python module in the repository uses `difflib` (repository-wide search for `difflib` and
  `unified_diff` in `*.py` returned nothing); the dry-run diff in 900006 is a new use of the
  standard library, not a new dependency.

### 1.4 Seeded `Draw` generator

`tests/discovery_runtime/test_t2_properties.py` defines `SEEDS = (11, 23, 47, 101, 211)` and class
`Draw(seed)` with `integer(upper)`, `choice(options)`, `text(*, blank=False)`,
`shuffled(items)`; each draw hashes `f"{seed}:{counter}"` with SHA-256, so no randomness module is
used and Ruff `S311` does not apply. Usage: `@pytest.mark.parametrize("seed", SEEDS)` then
`draw = Draw(seed)`. 1021 re-implements the same class in `tests/docs_page_check/property_support.py`
(1021 plan P2-T2) rather than importing from another test tree. 1020 uses exhaustive `itertools`
enumerations instead. The epic decision for 1021 says "seeded `Draw` generator pattern"; the
decision for 1020 says `itertools` enumerations; both are compliant (no `hypothesis`).

### 1.5 Test layout and pytest configuration

- Root `[tool.pytest.ini_options]`: `testpaths = ["tests"]`, `addopts = "-ra
  --cov-report=lcov:artifacts/python/lcov.info"`, default (prepend) import mode.
- `tests/` has `conftest.py` and no `__init__.py`; `tests/discovery_runtime/` has no `__init__.py`.
  1020 creates `tests/docs_runtime/__init__.py` and its research states that 900006's
  `tests/docs_runtime/reference/` needs its own `__init__.py`. With both files, a module such as
  `tests/docs_runtime/reference/test_front_matter.py` imports as `docs_runtime.reference.test_front_matter`
  and does not collide with `tests/docs_page_check/test_front_matter.py`
  (`docs_page_check.test_front_matter`, because 1021 adds `tests/docs_page_check/__init__.py`).
- Cross-test-module import precedent: `test_t2_properties.py` imports
  `from tests.discovery_runtime.test_references import immutable`. A 900006 support module should be
  imported the same way (`from tests.docs_runtime.reference.property_support import Draw`), which
  Pyright (strict, `include` contains `tests`) resolves from the repository root.
- `[tool.coverage.run] source` currently lists `src`, `scripts/dev_tools`,
  `packages/discovery-runtime/src`; 1020 appends `packages/docs-runtime/src`, so 900006 adds nothing.
  Per-module measurement uses dotted modules: `--cov=drm_copilot_docs.reference
  --cov=drm_copilot_docs.cli_generate --cov-branch --cov-report=term-missing
  --cov-report=json:<path>`, branch figures read from the JSON report.

### 1.6 Root `pyproject.toml` and `quality-tiers.yml`

- Path dependency precedent: `drm-copilot-discovery = { path = "packages/discovery-runtime", develop =
  true }`. Script precedent: `"dev.discovery.<name>" = "drm_copilot_discovery.cli:main_<name>"`,
  block ending with `"dev.discovery.doctor"` followed by `"dev.fix-all"`.
- 1020 appends `drm-copilot-docs` (path dependency), `dev.docs.init`, `dev.docs.validate-profile`;
  1021 appends `drm-copilot-docs-check` and `"dev.docs.check"` after `"dev.discovery.doctor"`.
- 900006 appends one root script line: `"dev.docs.generate-reference" =
  "drm_copilot_docs.cli_generate:main"`, placed with the other `dev.docs.*` lines.
- File-list refinement: 1020 declares console scripts in both the root and the package
  `pyproject.toml` (1020 spec `### CLI`, `## Implementation Strategy`), so the wheel installed by a
  consumer exposes them. 900006 must also append the script to `packages/docs-runtime/pyproject.toml`;
  the epic lists only the root file.
- Lock: Poetry's lock `content-hash` covers dependency sections, not `[tool.poetry.scripts]`;
  adding a script likely needs no `poetry.lock` change, but `poetry install` is required to register
  the console script. The plan must run `poetry check --lock` to confirm (unverified here).
- Existing-test disposition (orchestrator to confirm against merged 1020 code):
  `tests/docs_runtime/test_docs_package_contract.py::test_root_pyproject_registers_docs_console_scripts`
  and `::test_package_pyproject_matches_runtime_contract` may assert an exact script set; the 900006
  plan must read them and either leave them unchanged (if they assert membership) or update them.
- `quality-tiers.yml` currently classifies `packages/discovery-runtime` as T2; 1020 adds
  `packages/docs-runtime` (T2). 900006 adds files inside that project and does not edit
  `quality-tiers.yml`. T2 obligations apply: zero untyped escape hatches, at least one property test
  per pure function.
- PyYAML is an approved root dependency (`PyYAML = ">=6.0"`) and is declared by the 1020 package
  `pyproject.toml`; `jsonschema` is a dev dependency at the root and a runtime dependency of the
  1020 package.

### 1.7 900007 wrapper contract (downstream)

- The established discovery MCP pattern (`extensions/drm-copilot/src/discovery-runtime.ts`) launches
  `python -I -m <fixed module>` without a shell, with a fixed `cwd`, and parses exactly one JSON
  document from stdout plus the process exit code; it never parses stdout sentences
  (`DISCOVERY_GATEWAY_MODULE`, `DiscoveryProcessLauncher.launch(executable, args, {cwd, stdin})`).
- `repo-automation-execute-discovery.ts` maps host inputs `write?: boolean` and `dryRun?: boolean` to
  the request and rejects retired fields before launch.
- 900007 AC: each tool "returns structured output including the exit code and findings" and
  rejects invalid input before any process starts.
- Consequences for 900006: the command module must be runnable as `python -I -m
  drm_copilot_docs.cli_generate` (a `__main__` guard; `if __name__ == .__main__.:` is already in
  root `[tool.coverage.report] exclude_lines`); with `--format json` it writes exactly one JSON
  document to stdout carrying findings and per-page results; paths are relative to the process
  working directory (the 1020 and 1021 commands use the same convention).

## 2. Candidate Approaches

### 2.1 Merge model for generated content

Selected: line-oriented marker blocks with element-identifier keys, strict full-line marker grammar,
fence-aware scanning, error on any structural anomaly, and in-place replacement that never moves
author prose.

- Advantages: prose outside blocks is untouched byte-for-byte; ids are the deterministic element
  identifiers already defined by 1020; the parser needs only the standard library; strict errors
  prevent silent loss when an author edits a marker.
- Limitations: an author who moves a block keeps that position (by design); a marker typed inside an
  indented code block is reported as malformed.

Rejected alternatives:

- Whole-page regeneration with a separate prose file: violates the AC that prose outside markers is
  preserved in the same page.
- Markdown AST round-trip (third-party parser): adds an unapproved dependency and re-serializes prose,
  which breaks byte preservation.

### 2.2 Front matter emission

Selected: hand-rendered YAML in which every value is a JSON scalar or JSON flow sequence
(`json.dumps(value, ensure_ascii=False)`), fixed key order; JSON is a subset of YAML flow syntax, so
the 1021 `SafeLoader` parses it, and quoting `last_reviewed` keeps it a string.

Rejected alternatives: `yaml.safe_dump` (output form depends on PyYAML version and style options;
unquoted dates and line folding complicate byte determinism); importing the 1021 checker at runtime
to validate (adds a runtime dependency on `drm_copilot_docs_check`, which has no wheel build in 1021
per its `## Non-Goals`, so consumers could not install it alongside the docs wheel).

### 2.3 Page plan source

Selected: fixed family pages in one reference directory derived from the profile, overridable by
`--output-dir` (section 4.3). Rejected: a new profile mapping field (changes the 1020 schema, an
epic-level change); one page per element (large page counts, many orphan links for consumers).

## 3. Behavior Semantics

- Determinism: identical profile bytes, snapshot bytes and existing page bytes yield identical
  output bytes, independent of element order in the snapshot. No clock is read; a new page's
  `last_reviewed` is the first ten characters of the snapshot `captured_at`.
- Dry run (default): reads inputs, computes every page, prints planned changes, writes nothing and
  never calls the write port.
- Write (`--write`): planning completes with no `error` finding before any write; writes then run
  in sorted path order and stop at the first failure.
- Removal: a block whose id is not among the page's planned elements is removed and reported (info
  finding `REFERENCE_BLOCK_REMOVED` and a `removed` list per page).
- Failure conditions (exit 1, nothing written): profile or snapshot validation errors; snapshot
  repository differs from profile repository; duplicate element identifiers; marker anomalies;
  invalid or conflicting existing front matter; unresolved owner; invalid or missing audience;
  unresolved or invalid output directory.
- Ordering: pages by path; blocks by family sort key with `element_id` as final tie-breaker;
  findings by `finding_key`.

## 4. Requirements Mapping

### 4.1 AC to design

| AC (epic `### 900006`) | Design element | Test strategy |
|---|---|---|
| Same snapshot twice is byte-identical (property) | pure renderers, sorted keys, LF only, single trailing newline, no clock | Draw-shuffled element order and repeated runs give identical bytes per page |
| Prose outside markers preserved; removed block removed and reported (property) | `markers.merge_blocks` | Draw-generated prose segments and block sets; idempotence; removal report |
| Every generated page passes `drm_copilot_docs_check` with zero findings (integration) | front matter conforms to page-metadata; code-span-only consumer text; no links; no instructional headings | in-memory page set (entry page linking each generated page) through `run_check` |
| Without `--write` nothing is written and changes are printed | `cli_generate` dry-run path never calls the write port | recording fake port asserts zero write calls; stdout holds the diff |
| Line >= 85%, branch >= 75% | per-module JSON coverage report | `--cov=drm_copilot_docs.reference --cov=drm_copilot_docs.cli_generate --cov-branch` |

### 4.2 Proposed module responsibilities

All under `packages/docs-runtime/src/drm_copilot_docs/` unless noted. Refinements beyond the epic
file list are marked (R).

- `reference/__init__.py`: package docstring; no logic.
- `reference/snapshot_input.py` (R): `load_snapshot(content: bytes, *, artifact_path: str) ->
  SnapshotLoadResult` (`repository`, `captured_at`, `elements: tuple[SurfaceElement, ...]`,
  `findings`). Uses `parse_document`, `validate_artifact`, constructs `SurfaceElement`; rejects
  duplicate `element_id` and duplicate property names with `REFERENCE_SNAPSHOT_INVALID`.
- `reference/page_plan.py`: `plan_pages(profile, elements, *, output_dir=None, captured_at) ->
  PagePlan` (pages, findings, unrendered counts by kind). Resolves output directory, owner, audience,
  mode conflicts; assigns elements to family pages; orders elements.
- `reference/markdown_text.py` (R): shared pure helpers used by the four renderers: `code_span(text)`
  (backtick-run-aware fence, padding when the text starts or ends with a backtick or both ends are
  spaces), `single_line(text)` (replace CR, LF and other control characters with a space and collapse
  runs), `property_lines(properties)`. Prevents copy-paste across renderers.
- `reference/render_cli.py`, `render_http.py`, `render_config.py`, `render_api.py`: pure
  `render_<family>_block(element, ...) -> tuple[str, ...]` (body lines of one block). Headings are
  always `## ` or `### ` followed by a code span, so no heading text can start with `how to ` or
  `step <n>`.
- `reference/markers.py`: grammar constants, `format_start(id)`, `format_end(id)`,
  `parse_body(text) -> ParsedBody | findings`, `merge_blocks(body, desired) -> MergeResult`
  (`text`, `added`, `updated`, `unchanged`, `removed`, `findings`).
- `reference/front_matter.py`: `split_front_matter(text)`, `read_existing(text) -> ExistingFrontMatter
  | findings` (SafeLoader subclass: timestamps as text, duplicate keys rejected), `render_front_matter(
  values) -> str`, constants equal to the page-metadata patterns (a test pins them against the
  canonical schema file).
- `reference/generation.py` (R): pure composition `generate_reference(profile, snapshot,
  existing_pages: Mapping[str, str | None], *, output_dir) -> GenerationResult` (per-page
  `PageChange` and findings). Keeps `cli_generate.py` thin.
- `reference/writer.py`: `PageChange` (`path`, `before`, `after`, `action`: `create`, `update`,
  `none`, block lists), `render_diff(change) -> str` (`difflib.unified_diff`, headers `a/<path>` and
  `b/<path>`, `/dev/null` for a new page, LF), `PagePort` protocol (`read_text(path) -> str | None`,
  `create(path, content)`, `replace(path, content, *, expected_sha256)`), `apply_changes(changes, *,
  port) -> WriteOutcome` (statuses `created`, `updated`, `skipped`, `conflict`; stop at first
  failure; uncertain path reported), and `FileSystemPagePort(base: Path)` (UTF-8 bytes, CRLF read as
  LF, `mkdir(parents=True, exist_ok=True)`, exclusive create through `touch(exist_ok=False)` then
  `write_bytes`, replace after re-reading and comparing SHA-256). `mem_fs_path` patches `touch`,
  `write_bytes`, `read_bytes` and `mkdir` but its `open` does not handle mode `x`, so the adapter
  must not use `open(..., "xb")`.
- `reference/report.py` (R): `build_report(...)`, `render_json(report)` (`json.dumps(sort_keys=True,
  indent=2, ensure_ascii=False) + "\n"`), `render_text(...)`.
- `cli_generate.py`: `GeneratePorts` (`read_bytes`, `pages: PagePort`), `run_generate(argv, *, ports,
  stdout, stderr) -> int`, `main() -> int`, `__main__` guard.

Each module is expected to stay well below 500 lines; `markers.py` and `page_plan.py` carry most
logic and are the files to watch.

### 4.3 Page-plan rules

- Families and file names (fixed, aligned with the 900009 page template names): `cli-command` and
  `cli-option` -> `cli-reference.md`; `http-route` -> `http-reference.md`; `config-key` ->
  `config-reference.md`; `public-symbol` -> `api-reference.md`. `architecture-component` is not
  rendered (narrative `architecture-overview` belongs to 900009) and is reported as an unrendered
  count, not an error.
- A family page is planned when the family has at least one element or the page already exists.
- Output directory: `--output-dir` if given; otherwise the single `diataxis_policy.directory_modes`
  entry with `mode: reference` and no `*`, `?` or `[` in `path_or_glob`; zero or several such
  entries without `--output-dir` gives `REFERENCE_OUTPUT_DIR_UNRESOLVED`. `reference` must be in
  `diataxis_policy.modes`.
- Coverage rule for a `path_or_glob` value E and page path P (proposed, epic item G3): P is covered
  when P equals E, P starts with E + `/`, or `fnmatch.fnmatchcase(P, E)` is true.
- Mode conflict: if P is covered by a `directory_modes` entry whose mode is not `reference`, or an
  existing page declares another `diataxis_mode`, report `REFERENCE_MODE_CONFLICT`.
- Owner: existing valid `owner` is preserved; otherwise the first `page_owners` entry in profile
  order covering P; none gives `REFERENCE_OWNER_UNRESOLVED`.
- Audience: existing valid `audience` is preserved; otherwise the sorted `audience_ids` of the
  documentation root with the longest `path` covering P; no covering root gives
  `REFERENCE_OUTPUT_OUTSIDE_ROOTS`; empty or pattern-violating ids give `REFERENCE_AUDIENCE_MISSING`
  or `REFERENCE_AUDIENCE_INVALID`.
- `last_reviewed`: existing value preserved; new page uses `captured_at[:10]`.
- `title`: existing preserved; new page uses a fixed English title (`CLI reference`, `HTTP
  reference`, `Configuration reference`, `API reference`).
- Generator-owned fields: `diataxis_mode` (`reference`) and `surface_refs` (sorted identifiers of the
  elements rendered on the page). `extensions` is preserved. Any other key, an invalid value or
  malformed YAML in an existing page gives `REFERENCE_FRONT_MATTER_INVALID`.
- Sort keys: CLI commands by `(declaration, element_id)`, each followed by its options by
  `(declaration, element_id)`; an option whose `parent_id` is absent from the snapshot is rendered
  after all commands and reported with the warning `REFERENCE_PARENT_MISSING`; HTTP by
  `(route template, method, element_id)`; config and API by `(declaration, path, element_id)`.
- New page skeleton: front matter, blank line, `# <title>`, blank line, blocks separated by one blank
  line, single trailing LF. The generator emits no links; entry-page linking is the consumer's
  responsibility, and the text report lists created pages with that reminder (open question Q3).

### 4.4 Rendering determinism rules

- LF only; output ends with exactly one LF; no trailing spaces; UTF-8 without BOM; existing CRLF
  input is normalized to LF before merging.
- All consumer-derived text (declarations, names, paths, property names and JSON-encoded property
  values) appears only inside code spans and after `single_line`; no consumer text starts a line, so
  no line can open an HTML block or form a marker.
- Lists instead of tables, which removes pipe escaping.
- Properties sorted by name; values rendered with `json.dumps(value, ensure_ascii=False,
  sort_keys=True)`.
- Line ranges rendered as `lines <start>-<end>` when present.

### 4.5 Numeric Derivation Evidence

Claim A: the snapshot has six element kinds, of which five are rendered and one
(`architecture-component`) is not.

- Complete Family: element kinds of the docs surface model.
- Exhaustive Search Scope: epic `## Shared Design` and the 1020 spec (the authorities for kinds).
- Inclusion Rules: every value of the element-kind enumeration.
- Exclusion Rules: ledger dispositions, parity dimensions and diagnostic codes.
- Primary Search Strategy or Query Expression: read the 1020 spec table `### Docs common $defs`,
  row `element-kind` enum.
- Primary Member Set: `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`,
  `architecture-component`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: read the epic `### Naming contract` bullet
  "Surface element kinds".
- Cross-check Member Set: `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`,
  `architecture-component`.
- Cross-check Count: 6.
- Member-set Comparison: identical sets. The rendered subset (five) follows from the four renderer
  files in Claim B, with `cli-command` and `cli-option` sharing `render_cli.py`.

Claim B: four family renderers.

- Complete Family: renderer modules planned for 900006.
- Exhaustive Search Scope: epic `### 900006 - docs-reference-generator` and `issue.md`.
- Inclusion Rules: files named `render_*.py`.
- Exclusion Rules: `page_plan.py`, `markers.py`, `front_matter.py`, `writer.py`, refinements (R).
- Primary Search Strategy or Query Expression: read the epic 900006 "Files (create)" list.
- Primary Member Set: `render_cli.py`, `render_http.py`, `render_config.py`, `render_api.py`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: read `issue.md` `## Proposed Behavior` renderer
  bullet.
- Cross-check Member Set: `render_cli.py`, `render_http.py`, `render_config.py`, `render_api.py`.
- Cross-check Count: 4.
- Member-set Comparison: identical sets.

## 5. Testing Implications

- Location: `tests/docs_runtime/reference/__init__.py` plus one test module per production module
  under `reference/` (`test_snapshot_input.py`, `test_page_plan.py`, `test_markdown_text.py`,
  `test_render_cli.py`, `test_render_http.py`, `test_render_config.py`, `test_render_api.py`,
  `test_markers.py`, `test_front_matter.py`, `test_generation.py`, `test_writer.py`,
  `test_report.py`), property modules (`test_markers_properties.py`, `test_render_properties.py`),
  the checker integration module (`test_checker_integration.py`), the support module
  `property_support.py` (Draw, following 1021's re-implementation precedent), and
  `tests/docs_runtime/test_cli_generate.py` (mirrors `cli_generate.py`; the epic text "tests under
  `tests/docs_runtime/reference/`" is refined by the mirror rule).
- No temporary files: pure modules receive strings, bytes and mappings; CLI tests inject
  `GeneratePorts` with in-memory fakes and `io.StringIO`; `FileSystemPagePort` is exercised under
  `mem_fs_path` only.
- Properties (T2, at least one per pure function), Draw-driven with `SEEDS`: render bytes invariant
  under element permutation; repeated generation identical; `merge_blocks` idempotent; non-blank prose
  lines outside markers unchanged for arbitrary drawn prose and block sets, and prose segments
  byte-identical when the block set is unchanged; `code_span` round-trips through a CommonMark-rule
  reference decoder written in the test; front matter rendered then parsed with `yaml.safe_load`
  equals the input mapping; marker grammar round-trip for every kind; `load_snapshot(element_to_json)`
  round-trip.
- Negative cases: each marker error class, malformed front matter, unknown front-matter key, owner
  unresolved, audience invalid or missing, output directory unresolved or outside roots, mode
  conflict, snapshot repository mismatch, duplicate element id, invalid snapshot, invocation errors,
  unreadable input (exit 3), write conflict (exit 3 with partial report).
- Integration: build profile and snapshot in memory, generate pages, add an entry
  `docs/README.md` (with conforming front matter) linking each generated page, then call `run_check`
  with an in-memory `read_tree`; assert exit `0` and zero findings. A second case regenerates over
  pages with author prose and re-checks.
- Schema pinning: a test reads the committed `schemas/docs/v1/page-metadata.schema.json` (read-only)
  and validates emitted front matter with `jsonschema.Draft202012Validator`, and asserts that
  `front_matter.py` pattern constants equal the schema patterns.

## 6. PyMarkdown md033 and Marker Design

- Verified from the PyMarkdown rule documentation (`docs/rules/rule_md033.md`): md033 is enabled by
  default; `allowed_elements` defaults to `!--,![CDATA[,!DOCTYPE`, described as allowing "the default
  `!--` (HTML comment)". HTML comments are therefore not reported by md033 under the default
  configuration. The 1021 base `.pymarkdown.json` (1021 spec `### Base configuration content`, plan
  P7-T1) enables the front-matter extension and configures only `md013`, so md033 keeps its default
  `allowed_elements`. This resolves 1021 open question 5 for md033 (Vale front-matter behavior is out
  of 900006 scope).
- Related, non-gating: md024 (`no-duplicate-heading`) is enabled with `siblings_only` default `False`
  (verified in `docs/rules/rule_md024.md`); two elements with the same declaration in different files
  produce equal headings and a PyMarkdown warning in a consumer that runs it. md013 line length 100
  applies to long list lines. Neither affects the `drm_copilot_docs_check` AC.
- Marker decision: markers are standalone lines, each surrounded by a blank line inside and outside
  the block, so each comment forms its own HTML block (type 2 ends on the line containing `-->`) and
  headings keep blank-line separation.

## 7. Pre-Mortem

- Review checklists: A reviewer can fail the work for a test that writes a file, a missing T2
  property test, an `exclude` entry for a production path, a consumer identifier in source, or a
  stale assertion in a 1020 contract test that pins the console-script set. Mitigation: in-memory
  ports in every test, a property test named per pure function in the plan, no coverage exclusions,
  the 1020 neutrality test run over the new files, and a plan task that reads and records the
  disposition of `test_root_pyproject_registers_docs_console_scripts` and
  `test_package_pyproject_matches_runtime_contract`.
- Coverage: CI checks only repository totals, so a weak module can hide. Mitigation: measure
  `--cov=drm_copilot_docs.reference --cov=drm_copilot_docs.cli_generate --cov-branch` with a JSON
  report and record per-file line and branch figures; `main()` is covered by monkeypatching
  `run_generate`; `FileSystemPagePort` is covered under `mem_fs_path`.
- Mirror parity: not applicable for customization mirrors (no `.claude`, `.agents`, `.codex` or
  `.github` file changes and no bundled resource). The only paired data is the front-matter pattern
  constants versus the 1021 schema, pinned by a test that reads the committed schema. The plan adds
  no CI job, tool route or batch-budget rule, so no execution-environment brief update is needed.
- File size: `markers.py`, `page_plan.py` and `cli_generate.py` are the largest candidates.
  Mitigation: shared helpers in `markdown_text.py`, composition in `generation.py`, reporting in
  `report.py`; the plan records physical line counts with a 500-line target and the 800-line hard
  limit.
- Test isolation: risks are a module-level schema cache, `mem_fs_path` intercepting the packaged
  schema read inside `run_check`, and basename collisions with `tests/docs_page_check/`. Mitigation:
  the integration test runs without `mem_fs_path`; `tests/docs_runtime/reference/__init__.py` exists;
  a reversed-order single-process run of the new modules is recorded under
  `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: CI runs Python 3.10 to 3.13 on Linux. Mitigation: POSIX paths only
  (`PurePosixPath`, no drive letters or backslashes), no `tomllib`, no 3.11-only syntax, explicit
  UTF-8 bytes writes (no platform newline translation), CRLF inputs built in memory because
  `.gitattributes` normalizes committed text to LF; `poetry check --lock` after the `pyproject.toml`
  edits.
- Evidence: every command artifact under `<FEATURE>/evidence/<kind>/` carries `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `Output Summary:`, a write-time UTC stamp, and no absolute path. More than
  three production Python files are created, so execution must run in the item worktree on the large
  route (epic decision for 1021; brief `## Batch Budget`); an isolated executor worktree would be
  denied the fourth file.

## Recommendations for spec

### CLI signature

```text
dev.docs.generate-reference [--profile PATH] [--snapshot PATH] [--output-dir PATH]
                            [--write] [--format text|json]
```

- Entry point `"dev.docs.generate-reference" = "drm_copilot_docs.cli_generate:main"` in the root and
  the `packages/docs-runtime` `pyproject.toml`; module runnable as `python -I -m
  drm_copilot_docs.cli_generate`.
- `--profile`: default `docs/documentation-estate/docs-profile.json` (1020 default); `.yaml`/`.yml`
  selects YAML.
- `--snapshot`: default `artifact_paths.inventory_snapshot` from the profile.
- `--output-dir`: default derived from the profile (section 4.3).
- `--write`: absent means dry run. No `--dry-run` flag (the discovery precedent adds `--dry-run` only
  where a command writes intrinsically).
- `--format`: `text` (default) or `json`, matching `dev.docs.validate-profile` and `dev.docs.check`.
  A separate `--json` flag is not justified; 900007 passes `--format json`.
- All paths are POSIX relative to the working directory, checked with `validate_finding_path`.

Exit codes:

| Code | Meaning |
|---|---|
| `0` | Planning produced no `error` finding; dry run printed the plan, or write mode completed every write. Warnings and info findings (removed blocks, missing parents) do not change the code. |
| `1` | At least one `error` finding during loading or planning; nothing written. |
| `2` | Invocation error (unknown flag, missing value, invalid `--format`, non-relative path). |
| `3` | Runtime or output failure: unreadable profile or snapshot, write failure or digest conflict (writing stops; earlier writes are reported), or an unexpected exception (fixed stderr line). |

Stdout:

- `--format json`, exit `0`, `1`, or `3` after planning: one document rendered with
  `json.dumps(sort_keys=True, indent=2, ensure_ascii=False) + "\n"`: `tool`
  (`dev.docs.generate-reference`), `report_version` (`1.0.0`), `mode` (`dry-run` or `write`), `ok`,
  `pages` (sorted by `path`; each `path`, `action` (`create`, `update`, `none`), `status`
  (`planned`, `skipped`, `created`, `updated`, `conflict`), `sha256_before` (or `null`),
  `sha256_after`, `blocks` with `added`, `updated`, `unchanged`, `removed` sorted id lists, and `diff`
  (unified diff text in dry run, `null` in write mode)), `findings` (`Finding.to_dict()` sorted by
  `finding_key`), `unrendered` (counts by kind), `uncertain_paths`, `summary` (page and block counts).
- `--format text`: per page one line `<action> <path> (+added ~updated -removed)`, then in dry run
  the unified diffs, then `<CODE> <message>` per finding, then a summary line
  `dev.docs.generate-reference: <n> page(s) to change, <m> unchanged; dry run, nothing written` (or
  `wrote <n> page(s)`).
- Exit `2` and pre-planning exit `3`: no stdout; one stderr line naming the problem.

### Marker grammar and merge algorithm

- Start line: exactly `<!-- docs:generated:start id=<element-id> -->`; end line: exactly
  `<!-- docs:generated:end id=<element-id> -->`; `<element-id>` matches the 1020 `element-id`
  pattern. Full-line match, no leading or trailing whitespace.
- Scanning skips front matter and fenced code blocks (backtick or tilde, three or more characters,
  up to three spaces of indent, closed by the same character with at least the same length, the 1021
  fence rule).
- Errors (each `error` finding naming the page and line; the page is not written and the run exits
  `1`): `REFERENCE_MARKER_MALFORMED` (a non-fenced line whose stripped text starts with
  `<!-- docs:generated:` but is not an exact marker, including an indented marker or a bad id);
  `REFERENCE_MARKER_DUPLICATE` (an id opened twice in a page); `REFERENCE_MARKER_UNBALANCED` (end
  without an open start, a start while another is open, or a start never closed);
  `REFERENCE_MARKER_MISMATCH` (end id differs from the open start id); `REFERENCE_MARKER_IN_FRONT_MATTER`.
- Merge for desired ordered blocks D on an existing body: blocks whose id is in D get their body
  replaced in place (`updated` or `unchanged`); blocks not in D are removed from start line to end
  line inclusive plus one following blank line when the preceding line is also blank (`removed`,
  reported); a new id is inserted after the nearest preceding member of D present in the page, else
  before the nearest following member, else appended at the end of the body after one blank line.
  Existing block order and all prose are never rearranged. A second merge with the same inputs
  returns identical text.
- Block layout: start marker, blank line, body lines, blank line, end marker.

### Open questions

- Q1 (epic, G4): align the page-metadata `audience` item pattern with the discovery `identifier`
  grammar, or restrict profile audience identifiers; until then 900006 reports
  `REFERENCE_AUDIENCE_INVALID` and `REFERENCE_AUDIENCE_MISSING`.
- Q2 (epic, G3): adopt the proposed `path_or_glob` coverage and first-match owner rule for 900005 as
  well.
- Q3 (owner): should 900006 also maintain a reference index page (for example `<output-dir>/README.md`)
  so that one link from a docs entry page prevents `PAGE_ORPHANED`? A generated index block has no
  element identifier, so it needs a reserved block id, which is a naming-contract change.
- Q4 (epic, G1): place the snapshot loader in `drm_copilot_docs` (shared with 900005) instead of
  `reference/snapshot_input.py`.
- Q5 (owner): a `--check` mode (exit `1` when any page would change) for CI drift detection; not
  required by the 900006 AC.
- Q6 (orchestrator, needs merged code): exact `read_tree` signature of 1021 `run_check`; whether the
  1020 contract tests pin an exact console-script set; whether `poetry check --lock` stays clean
  after adding the script line (Poetry content-hash scope, unverified here).
- Q7 (orchestrator): the research timestamp was read from an external time service, not from a
  host shell clock.
