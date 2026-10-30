# 2026-10-30-docs-surface-analyzers-python-config — Spec

- **Issue:** #1022
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T16-46
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate-tooling epic (#1019) needs an inventory of the documentable surface of a
destination repository before a coverage ledger, parity matrix or reference pages can be built. Issue
#1020 defines the surface element model, the analyzer protocol and registry table, and the
`surface-inventory-snapshot` schema, but no analyzer yet produces surface elements. Without analyzers
for Python command-line interfaces, HTTP routes, public APIs, configuration files and architecture, the
`dev.docs.inventory` command cannot report what a Python repository exposes, and documentation drift
must be counted by hand.

This feature is child 900003 of epic #1019 (wave 1, complexity band C4; placeholder 900003 is
replaced by #1022). It adds five read-only, lexical, bounded and deterministic analyzers, a pure
snapshot builder and the thin `dev.docs.inventory` command to `packages/docs-runtime`
(`drm_copilot_docs`). It consumes the contracts planned by #1020 and does not re-create them.

Design source: `research/2026-10-30T20-47-docs-surface-analyzers-python-config-research.md` in this
feature folder. Binding inputs: the epic manifest `docs/features/epics/documentation-estate-tooling/epic.md`
sections `### Naming contract (fixed for all children)`,
`### Decisions recorded during preparation of 1020 (binding on later children)` and
`### 900003 - docs-surface-analyzers-python-config (wave 1, C4)`, and the orchestrator decisions in
`## Decisions` below.

## Behavior

Five analyzers, each a module-level instance implementing the #1020 `SurfaceAnalyzer` protocol:

| Analyzer identifier | Module (`drm_copilot_docs.analyzers.`) | Instance attribute | Element kinds | Inputs read |
|---|---|---|---|---|
| `python-cli` | `python_cli` | `PYTHON_CLI_ANALYZER` | `cli-command`, `cli-option` | `*.py`; `pyproject.toml` script tables only |
| `python-http` | `python_http` | `PYTHON_HTTP_ANALYZER` | `http-route` | `*.py` |
| `python-public-api` | `python_public_api` | `PYTHON_PUBLIC_API_ANALYZER` | `public-symbol` | `*.py` |
| `config-files` | `config_files` | `CONFIG_FILES_ANALYZER` | `config-key` | `pyproject.toml` `[tool.*]` tables, template-style env files, JSON Schema files, `*.yaml` and `*.yml` |
| `python-architecture` | `architecture` | `PYTHON_ARCHITECTURE_ANALYZER` | `architecture-component` | `*.py`, `requirements*.txt`, `setup.cfg`, `pyproject.toml` dependency declarations |

General rules for every analyzer:

- Lexical only. Python sources are parsed with the standard-library `ast` module from bytes (so PEP
  263 coding cookies and a BOM are honored). No consumer module is imported, executed, compiled to
  bytecode for execution, or installed. Calls and decorators are recognized only when the callee
  resolves through a per-module import alias table (`import x`, `import x as y`,
  `from x import y as z`) or through a tracked receiver variable. Nodes are visited with `ast.walk`
  and explicit work lists, never a recursive visitor.
- Pure. `analyze(inputs, *, selection)` reads only the supplied `Mapping[str, bytes]`, does not mutate
  it, iterates `sorted(inputs)`, never iterates an unsorted `set` of strings, and holds no
  module-level cache.
- Bounded. Each analyzer checks the per-input byte bound itself (the #1020 contract), so it behaves
  correctly when called directly as a library.
- Diagnostics are emitted at most once per `(code, path, analyzer_id)`; the message states the
  occurrence count and the first line number. Messages are fixed text and never quote source text or
  configuration values.
- A site whose declaration fails `element_identifier` validation is skipped with diagnostic
  `declaration-invalid`. A repeated identity (same kind, path and declaration) keeps the first site by
  line and emits `duplicate-declaration` (warning).

### `python-cli` (argparse, Click, Typer, console scripts)

Root command name resolution, in order:

1. A literal name in source: argparse `ArgumentParser(prog="x")`; Click `@click.group(name="x")` or
   `@click.command("x")`; `typer.Typer(name="x")`. Property `name_source: literal`.
2. A console script: each entry of `[project.scripts]`, `[project.gui-scripts]` and
   `[tool.poetry.scripts]` in any `pyproject.toml` input yields one `cli-command` at that
   `pyproject.toml` path, declaration equal to the script name, properties `framework: console-script`
   and `table` (for example `project.scripts`). The `module:attribute` target is used internally only
   and is never exported. When the target module resolves to exactly one input (`<module path>.py`
   or `<module path>/__init__.py`, matched as a path suffix after a source root) and the attribute
   names the Click or Typer root object, or the function whose body constructs the argparse root,
   the root's subcommands and options are parented to the script element. Otherwise the root stays
   unattached.
3. Fallback: the module dotted name relative to the containing `selection.source_roots` entry
   (`src/pkg/cli.py` with root `src` becomes `pkg.cli`). Property `name_source: module`.

| Framework | Recognized forms | Declarations |
|---|---|---|
| argparse | `argparse.ArgumentParser(...)` and aliases; `add_subparsers(...)`; `add_parser("name", ...)` (nested); `add_argument("--long", "-s", ...)` and positional `add_argument("file")`; `add_argument_group` and `add_mutually_exclusive_group` receivers mapped to their parser; literal `required=`, `action=`, `help=` | `cli-command` per parser: root name, then space-separated subcommand names (`tool sync`). `cli-option` per argument: command path, one space, the first `--` string, else the first `-` string, else the positional name (`tool sync file`, property `positional: true`). |
| Click | `@click.command(...)`, `@click.group(...)` (alias-aware, including `from click import command`); `@<group>.command(...)` and `@<group>.group(...)` on a tracked group; `<group>.add_command(<tracked>, name="x")`; `@click.option(...)` and `@click.argument(...)` on the same function | Command name from a literal `name=`, else the function name lower-cased with `_` replaced by `-` and the suffixes `-command`, `-cmd`, `-group`, `-grp` removed. Option strings split at `/`; the long option is the first `--` part. |
| Typer | `typer.Typer(...)`; `@app.command(...)`; `@app.callback()` (root-level options); `app.add_typer(sub, name="x")`; `typer.run(func)`; parameters declared with `typer.Option(...)` or `typer.Argument(...)` as a default or inside `Annotated[...]`; a parameter without a default is an argument, a parameter with a plain default is an option `--<name with _ replaced by ->` | Command name from a literal `name=`, else the function name with underscores converted to hyphens (decision D11). A Typer app with exactly one command and no callback runs that command as the root (property `single_command: true`). A boolean option declares `--x`; the generated `--no-x` is not a separate element. |

Properties: `framework` (`argparse`, `click`, `typer`, `console-script`), `name_source`,
`positional`, `required`, `action`, `short`, `help` (literal help text only), `has_default`
(boolean). Default values are never exported. `line_range` comes from the call or decorator node.
Every `cli-option` has a `parent_id` that is a `cli-command` element identifier.

Dynamic forms (decision D9) yield a warning, non-blocking diagnostic and no element for that site:
non-literal option strings or command names, `*args`, `add_parser` inside a loop
(`cli-dynamic-registration`); `parents=[...]` (`cli-parents-unresolved`); registration on an
untracked receiver (`cli-unbound-registration`); Click `cls=` custom classes, lazy groups and
constructed `click.Group(...)` objects; Typer `add_typer` without a literal name. Statically
resolvable sites in the same file still produce elements.

### `python-http` (FastAPI, Flask)

Two passes over all `*.py` inputs: pass 1 collects route sites and app or router objects with their
own prefixes per module; pass 2 resolves mount edges across modules through the import table and
composes full templates.

| Framework | Recognized forms | Composition |
|---|---|---|
| FastAPI | `FastAPI(...)`, `APIRouter(prefix="/x")`; decorators `.get .post .put .patch .delete .options .head .trace` with a literal path; `.api_route(path, methods=[...])` (default `GET`); `.add_api_route(path, endpoint, methods=[...])`; `.include_router(router, prefix="/y")`; `.websocket(path)` (method token `WEBSOCKET`, property `protocol: websocket`) | Template = include prefixes (outermost first) + router `prefix` + route path. A router included `n` times yields `n` elements. A router never included keeps its own prefix, property `mounted: false`. |
| Flask | `Flask(...)`; `Blueprint("name", __name__, url_prefix="/x")`; `@x.route(path, methods=[...])` (default `GET`; automatic `HEAD` and `OPTIONS` are not emitted); `.get .post .put .patch .delete` shortcuts; `.add_url_rule(path, ..., methods=[...])`; `.register_blueprint(bp, url_prefix="/y")` | A `url_prefix` given to `register_blueprint` replaces the blueprint's own; nested blueprint prefixes concatenate. Converters such as `<int:id>` are kept verbatim. |

Declaration: `<METHOD> <template>`, one element per method. Element `path` is the file containing
the route site; `name` is the handler function name for a decorator on a `def`, else the template.
Properties: `framework`, `mounted`, `prefix_resolved`, `protocol`.

Dynamic forms (decision D9): a non-literal route path or method list yields `http-dynamic-route`
(warning) and no element. A non-literal prefix (for example `settings.API_PREFIX`) or a router from
a module outside the inputs does not drop the route: the unresolved prefix segment is rendered as the
literal `<dynamic>` (for example `GET <dynamic>/items/{item_id}`), property `prefix_resolved: false`,
and a warning `http-prefix-dynamic` is emitted, so the identity stays stable and the gap is visible.
`.mount(...)` sub-applications yield `http-mount-unresolved`; class-based views without literal
`methods` yield `http-method-view-unresolved`; a decorator on an untracked receiver whose first
argument is a string beginning with `/` yields `http-unbound-route` (plain `.get(` calls on untracked
receivers are ignored).

### `python-public-api`

- Module qualified name derives from the path relative to the containing `selection.source_roots`
  entry. A module with a path segment beginning with `_` (other than `__init__`) is not public and
  yields no elements; a segment that is not a Python identifier yields one `information` diagnostic
  `module-not-importable` and no elements.
- Literal `__all__` forms, applied in statement order at module top level: `__all__ = [...]` or
  `(...)` of string constants, `__all__: list[str] = [...]`, `__all__ += [...]`,
  `__all__.extend([...])`, `__all__.append("x")`. Elements are the names in the final `__all__`,
  property `basis: all`, property `symbol_kind` (`function`, `async-function`, `class`, `variable`,
  `import`) from the top-level binding, or `unresolved` with warning `public-api-name-unresolved`.
- Non-literal `__all__` (decision D9): warning `public-api-dynamic-all`, then the naming rule applies
  with property `basis: naming`.
- Naming rule (no `__all__`): top-level `def`, `async def`, `class` and `Name` targets of `Assign` or
  `AnnAssign` not beginning with `_`, including inside top-level `if` and `try` bodies (all branches).
  Imported names are not public under the naming rule. Class members are out of scope.
- Declaration: the qualified name (`pkg.mod.name`).

### `config-files`

Key-path declarations: segments matching `^[A-Za-z0-9_-]+$` stay bare; any other segment is written
as a TOML basic string with `"` and `\` escaped, so `a."b.c"` and `a.b.c` cannot collide. Arrays
contribute the segment `[]`. The same quoting applies to TOML, JSON Schema and YAML key paths. No
configuration value is read into an element; "shape" means the type names below.

- `pyproject.toml` (basename match): parsed through the injected TOML loader (decision D4). Every key
  under `tool.*` yields a `config-key`, excluding the console-script table `tool.poetry.scripts`
  (owned by `python-cli`, decision D2) and the dependency subtrees `tool.poetry.dependencies`,
  `tool.poetry.dev-dependencies`, `tool.poetry.group.*.dependencies` and `tool.poetry.extras`
  (read by `python-architecture`). `[project]` and `[build-system]` are not configuration.
  Properties `value_type` (`table`, `array`, `string`, `integer`, `float`, `boolean`, `datetime`)
  and `format: toml`.
- Env files (decision D5): only the template-style basenames `.env.example`, `.env.sample`,
  `.env.template` and `.env.dist` are read. Every other env-family file (a plain `.env`, and by
  extension `.env.<other suffix>` and `<name>.env`) is not captured, not hashed and not passed to
  any analyzer, and yields one `information` diagnostic `env-file-not-captured` naming the path. The
  template scan is bounded and lexical: UTF-8 (BOM allowed); blank and `#` lines skipped; optional
  `export ` prefix; key grammar `^[A-Za-z_][A-Za-z0-9_]*$` before `=`; a value opening a quote that
  does not close on its line consumes lines until the closing quote, so a multi-line value never
  becomes a key. Unrecognized lines yield one warning `env-line-unrecognized` with a count. The value
  text is never bound to a name that reaches output. Declaration = key; `line_range` = the line;
  property `format: env`.
- JSON Schema: a basename ending `.schema.json`, or a `.json` input whose parsed root has a `$schema`
  string containing `json-schema.org`; other JSON files are ignored. Parsed with discovery
  `parse_document(..., format="json")`. The walk follows root `properties`, nested `properties`,
  `items.properties` (segment `[]`), `allOf`/`anyOf`/`oneOf` members (property `conditional: true`
  for `anyOf` and `oneOf`) and local `$ref` targets (`#/$defs/...`, `#/definitions/...`) up to depth
  16 with a visited-pointer set; a cycle, remote `$ref` or depth overflow yields warning
  `json-schema-ref-unresolved`. `default`, `enum`, `const`, `examples` and `pattern` are never read
  into output. Properties `schema_type` (the literal `type` string, `multiple`, or absent),
  `required` (boolean) and `format: json-schema`.
- YAML: `parse_document(content, format="yaml", artifact_path=path,
  limits=ParseLimits(document_bytes=MAX_INPUT_BYTES))`. Every mapping key path yields a `config-key`;
  properties `value_type` (`object`, `array`, `string`, `integer`, `number`, `boolean`, `null`) and
  `format: yaml`. Inputs that `parse_document` rejects (multi-document streams, merge keys, unquoted
  timestamps, non-mapping roots) yield `yaml-invalid` and no elements.
- Per-input key bound `MAX_KEYS_PER_INPUT = 10_000`; overflow yields `input-key-limit` (error,
  blocking) and no elements for that input.

### `python-architecture`

- One `architecture-component` per package (directory holding `__init__.py`) and per module,
  declaration = dotted name, property `component_kind` (`package` or `module`).
- Import edges (decision D3) come from new `ast` code over `Import` and `ImportFrom` nodes at any
  nesting level, with relative imports resolved against the module's package. Only internal targets
  that resolve to an input module or package are kept (longest dotted-prefix match).
  `importlib.import_module` and `__import__` calls are not followed. Edges are stored as indexed
  scalar properties on the source component: `import_count` (integer) and `import-0001`,
  `import-0002`, ... whose values are target dotted names in sorted order. Bound: 1000 edges per
  component; overflow yields warning `architecture-edge-limit` and keeps the count only.
- External dependency declarations reuse
  `drm_copilot_discovery.analyzer.dependency_python.parse_python_dependencies` for
  `requirements*.txt` (`format="requirements"`) and `setup.cfg` (`format="setup-cfg"`).
  `pyproject.toml` `[project] dependencies` (PEP 508 name part) and `tool.poetry.dependencies` keys
  are read through the shared TOML loader. Each yields an `architecture-component` with
  `component_kind: external-dependency`, declaration = the sanitized distribution name, properties
  `ecosystem: python` and `role`. Version constraints are not exported. A `DependencyInputError`
  becomes one diagnostic carrying the error's own code and no elements for that file.

### Snapshot builder

`snapshot_builder.build_snapshot(...)` validates mapping keys with discovery
`path_models.relative_path` and `check_path_collisions`, applies the over-bound rule, withholds
non-template env files, records each in-bound input through discovery `snapshot.SnapshotFile`
(`category="source"`; its `sha256` and content length populate `inputs`), runs each selected analyzer
on the in-bound mapping, filters elements to `profile.surface_selection.element_kinds`, merges,
de-duplicates and sorts, projects through #1020 `element_to_json` and `diagnostic_to_json`, and
assembles the `surface-inventory-snapshot` document. `render_snapshot(value)` returns discovery
`models.canonical_json` bytes (sorted keys, compact separators, UTF-8, LF terminated).

## Inputs / Outputs

- Inputs:
  - CLI flags of `dev.docs.inventory` (see `## API / CLI Surface`).
  - The docs profile (`--profile`, JSON or YAML), read through #1020 `parse_profile`.
  - Files under `surface_selection.source_roots`, minus paths matched by
    `surface_selection.exclusions` through discovery `analyzer.input_capture.exclusion_reason`.
  - No environment variable is read.
- Outputs:
  - One `surface-inventory-snapshot` JSON document, to stdout or to `--output`.
  - One summary line on stderr: element count, diagnostic count, blocking count.
- Bounds:

| Constant | Value | Location | Effect when exceeded |
|---|---|---|---|
| `MAX_INPUT_BYTES` | `1_048_576` (1 MiB) per input | `analyzers/_bounds.py` (docs constant; discovery `MAX_CAPTURE_BYTES` is 256 MiB and is not reused for this bound) | One `input-over-bound` error diagnostic; the input contributes no element and no `inputs` entry |
| `MAX_INPUT_FILES` | `50_000` inputs per run | `analyzers/_bounds.py` | Run aborts with exit 3 and no snapshot |
| `MAX_CAPTURE_BYTES` | 256 MiB aggregate | reused from discovery `analyzer.input_capture` | Run aborts with exit 3 and no snapshot |
| `MAX_KEYS_PER_INPUT` | `10_000` | `analyzers/_bounds.py` | `input-key-limit`, no elements for that input |

- Versioning: each snapshot `analyzers[].version` is `drm_copilot_docs.__version__`. Declaration
  rules (root naming, key quoting, `<dynamic>` segments) are part of element identity; a later
  change to them is a T2 contract change and must change the recorded version.

## API / CLI Surface

### Console script

Appended to root `pyproject.toml` `[tool.poetry.scripts]` after the #1020 `dev.docs.*` entries, and
to `packages/docs-runtime/pyproject.toml`:

`"dev.docs.inventory" = "drm_copilot_docs.cli_inventory:main_inventory"`

`main_inventory() -> int` delegates to
`run_inventory_cli(argv, *, ports: InventoryPorts, stdout, stderr, clock) -> int`, following the
#1020 `cli.py` conventions (`argparse`, `SystemExit` caught and never escaping).

`dev.docs.inventory [--profile <path>] [--analyzer <id>]... [--revision <full object id>] [--output <relative path>]`

- `--profile`: default `docs/documentation-estate/docs-profile.json`; format from the extension
  (`.json` or `.yaml`/`.yml`).
- `--analyzer <id>`: repeatable; when present it replaces `surface_selection.analyzers`. Every id
  must be registered (an unknown id exits 2 with a message naming it, from `select_registrations`).
  An id whose analyzer produces none of the profile's `element_kinds` exits 2 with a message naming
  the id (decision D7). Absent: the profile list, or every registered analyzer whose kinds intersect
  `element_kinds`.
- `--revision`: must satisfy discovery `revision_rules.is_full_revision` (exit 2 otherwise); absent
  records `revision: null` (working copy). The docs package starts no Git process.
- `--output`: a POSIX relative path; the rendered bytes are written through the injected write port
  and replace an existing file. Absent: the snapshot goes to stdout.

`InventoryPorts` (frozen dataclass): `read_bytes(path: str, limit: int) -> bytes | None` (reads at
most `limit` bytes; `None` for missing), `list_files(root: str, limit: int) -> tuple[str, ...]`
(relative POSIX paths, symlinks not followed, sorted, raises on more than `limit`),
`write_bytes(path: str, data: bytes) -> None`. The real implementations in `cli_inventory.py` are
the only I/O in this feature.

Flow: parse the profile; compute `profile_sha256`; enumerate `source_roots`; drop excluded paths;
withhold non-template env files without reading them; read each remaining file with limit
`MAX_INPUT_BYTES + 1`; select and load analyzers (`select_registrations`, `load_analyzer`);
`build_snapshot`; self-validate with `validate_artifact(...,
artifact_kind="surface-inventory-snapshot")`; emit.

| Exit code | Meaning |
|---|---|
| `0` | Snapshot emitted with no blocking diagnostic, or help |
| `1` | Snapshot emitted with at least one blocking diagnostic; invalid profile (profile findings printed, no snapshot); or failed self-validation (defect guard, no snapshot) |
| `2` | Invocation error: unknown flag, missing value, unknown `--analyzer` id, `--analyzer` id with no selected kind, `--revision` not a full object id, `--output` or `--profile` not a POSIX relative path |
| `3` | Runtime failure: unreadable profile, aggregate bound exceeded, write failure, or an unexpected exception caught by the top-level handler (`# noqa: BLE001 - CLI top-level error handling`), which writes a fixed stderr line |

Example invocations:

- `poetry run dev.docs.inventory --profile examples/docs/v1/docs-profile.example.json` prints a
  snapshot and exits 0 or 1 depending on blocking diagnostics.
- `poetry run dev.docs.inventory --analyzer python-cli --revision <40-hex id> --output build/inventory.json`.
- `poetry run dev.docs.inventory --analyzer not-registered` exits 2 naming `not-registered`.

### Registry entries

Appended at the end of `ANALYZER_REGISTRY` in `analyzer_contract.py`, in identifier order, each as
its own Black-formatted multi-line block; no existing line of the file is edited:

```python
    AnalyzerRegistration(
        identifier="config-files",
        element_kinds=("config-key",),
        module="drm_copilot_docs.analyzers.config_files",
        attribute="CONFIG_FILES_ANALYZER",
    ),
```

The other four follow the same shape with the values in the `## Behavior` table.

### Diagnostics

All diagnostics use the #1020 docs `diagnostic` shape; codes use the discovery `identifier` grammar.

| Code | Severity | Blocking | Emitted by |
|---|---|---|---|
| `input-over-bound` | error | yes | builder (`analyzer_id` `docs-inventory`) and each analyzer when called directly |
| `input-key-limit` | error | yes | `config-files` |
| `python-syntax-invalid`, `toml-invalid`, `json-invalid`, `yaml-invalid`, `env-encoding-invalid` | error | yes | the analyzer parsing the input |
| `toml-parser-unavailable` | error | yes | each analyzer reading a TOML input when no loader resolves |
| `env-file-not-captured` | information | no | builder (`docs-inventory`); `config-files` when called directly |
| `cli-dynamic-registration`, `cli-parents-unresolved`, `cli-unbound-registration` | warning | no | `python-cli` |
| `http-dynamic-route`, `http-prefix-dynamic`, `http-mount-unresolved`, `http-method-view-unresolved`, `http-unbound-route` | warning | no | `python-http` |
| `public-api-dynamic-all`, `public-api-name-unresolved` | warning | no | `python-public-api` |
| `module-not-importable` | information | no | `python-public-api` |
| `env-line-unrecognized`, `json-schema-ref-unresolved` | warning | no | `config-files` |
| `architecture-edge-limit` | warning | no | `python-architecture` |
| `declaration-invalid`, `duplicate-declaration` | warning | no | any analyzer |
| dependency error codes from `DependencyInputError` | error | yes | `python-architecture` |

## Data & State

- Snapshot document fields (schema planned by #1020, `### Artifact schema: surface-inventory-snapshot`):
  header (`$schema` `urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot`, `schema_version`
  `"1.0.0"`, `artifact_kind`, `id`, `extensions` `{}`); `repository` = profile `repository.id`;
  `revision`; `profile_sha256`; `analyzers` sorted by `id`; `inputs` sorted by `path`; `elements`
  sorted by `element_id`; `diagnostics` sorted by `id`; `captured_at`.
- Snapshot `id`: `stable_id("surface-inventory", row(repository=..., revision=...,
  profile_sha256=..., analyzers=..., inputs=...))`; it excludes `captured_at`.
- `profile_sha256`: `sha256(canonical_json(parse_document(content, format=...).value))` using
  discovery `parsing.parse_document` and `models.canonical_json` (decision D10).
- `captured_at`: from an injected clock (`Callable[[], datetime]`, UTC, RFC 3339). Byte identity is
  defined for identical input bytes, profile, revision, analyzer selection and clock value.
- Invariants: every `element_id` equals `element_identifier(kind=..., path=..., declaration=...)`;
  elements are unique; every `cli-option` parent is a `cli-command`; every `inputs[].sha256` is the
  SHA-256 of the exact in-bound bytes passed to the analyzers; no over-bound or withheld input
  appears in `inputs` or as an element `path`.
- No caching, persistence or migration. The only write is the optional `--output` file.

## Decisions

### Orchestrator decisions on the research open questions (binding)

- **D1 Analyzer identifiers and registry shape.** Identifiers `python-cli`, `python-http`,
  `python-public-api`, `config-files`, `python-architecture`. Each is appended to
  `ANALYZER_REGISTRY` as its own Black-formatted entry at the end of the tuple. `attribute` names a
  module-level analyzer instance (for example `PYTHON_CLI_ANALYZER = PythonCliAnalyzer()`).
- **D2 Console-script ownership.** `[project.scripts]` and `[tool.poetry.scripts]` (and
  `[project.gui-scripts]` under the same rule) are owned by `python-cli` and yield `cli-command`
  elements. `config-files` owns `[tool.*]` table keys, template env keys, JSON Schema `properties`
  and YAML keys. This is a refinement of the epic file list (which lists "scripts" under
  `config_files.py`), not a naming-contract change.
- **D3 Import edges.** Import edges come from new `ast` code. `drm_copilot_discovery.analyzer.dependency_python`
  is reused only for external dependency declarations, because it parses requirement and
  `setup.cfg` declarations and extracts no module edges. Discovery behavior is not changed. Edges are
  indexed scalar properties on the `architecture-component` element; no `extensions` field is added
  to `SurfaceElement` and no epic-level change is requested.
- **D4 TOML.** No new dependency. An injected loader seam
  (`config_toml.resolve_toml_loads(*, import_module=importlib.import_module)`) resolves `tomllib`,
  then `tomli`. When neither is importable, each TOML input yields `toml-parser-unavailable` and no
  elements. Tests inject the loader so results do not depend on the interpreter version.
- **D5 Env files.** Only `.env.example`, `.env.sample`, `.env.template` and `.env.dist` are read.
  A plain `.env` file is not captured, not hashed, and yields one `information` diagnostic naming the
  path. This spec applies the same handling to other non-template env-family names
  (`.env.<suffix>`, `<name>.env`), because they carry the same secret-file risk. Keys only; values
  are never stored. The docs profile schema has no field to opt into plain `.env` capture, so no
  opt-in exists in this feature.
- **D6 Size bound.** 1 MiB per input. Discovery `MAX_CAPTURE_BYTES` is 256 MiB, so a docs constant
  `MAX_INPUT_BYTES = 1_048_576` is defined in `analyzers/_bounds.py`. An over-bound input yields one
  error diagnostic and contributes no elements. Aggregate limits: `MAX_INPUT_FILES = 50_000` and
  discovery `MAX_CAPTURE_BYTES` total, exceeding either exits 3 with no snapshot.
- **D7 Non-intersecting `--analyzer`.** An id whose analyzer produces none of the profile's selected
  element kinds exits 2 (usage error) with a message naming the id.
- **D8 Python syntax errors.** A file that fails `ast.parse` yields one `python-syntax-invalid`
  diagnostic and no elements from it. The interpreter version is not recorded in the snapshot (the
  schema is closed); fixture sources use Python 3.10 grammar.
- **D9 Dynamic registration.** Non-literal names, computed prefixes and non-literal `__all__` yield a
  warning diagnostic. An unresolvable route prefix is rendered as `<dynamic>` so identity stays
  stable.
- **D10 Gaps in the #1020 spec.** Resolved in this feature's own modules: the diagnostic factory
  `analyzers/_bounds.make_diagnostic(*, code, path, message, analyzer_id, severity, blocking)`
  computing `id = stable_id("diagnostic", row(code=code, path=path, analyzer=analyzer_id))`; the
  `profile_sha256` computation in `## Data & State`; conversion of each
  `SurfaceSelection.exclusions` entry to a discovery `JsonObject` with `path_or_glob` and `rationale`
  in `cli_inventory.py`, whatever type #1020 delivers; and the instance meaning of `attribute`
  (D1). The only edits to #1020 files are the appended `ANALYZER_REGISTRY` entries and the appended
  `dev.docs.inventory` script line in root `pyproject.toml` (plus the script line in
  `packages/docs-runtime/pyproject.toml`). Anything else that would require editing a #1020 file is
  out of scope and is a dependency on #1020 as delivered.
- **D11 Typer default command naming.** The function name with underscores converted to hyphens,
  unless an explicit name is given. Fixtures cover both explicit and default names.

## Constraints & Risks

- The naming contract in the epic manifest `## Shared Design` section is fixed; this feature does
  not change it.
- Analyzers never execute, compile for execution or install consumer code; dynamic registration is
  not visible to a lexical analyzer and surfaces as a diagnostic.
- Execution depends on #1020 merging into the epic integration branch. The plan's first phase
  verifies every consumed #1020 symbol (`surface_models.py`: `ElementKind`, `ELEMENT_KINDS`,
  `element_identifier`, `SurfaceElement`, `SurfaceDiagnostic`, `element_to_json`,
  `diagnostic_to_json`; `analyzer_contract.py`: `SurfaceAnalyzer`, `SurfaceAnalysis`,
  `AnalyzerRegistration`, `ANALYZER_REGISTRY`, `validate_registry`, `registered_identifiers`,
  `select_registrations`, `load_analyzer`; `profile_models.py` and `profile.py`: `DocsProfile`,
  `SurfaceSelection`, `ArtifactPaths`, `parse_profile`; `schema_validation.py`: `validate_artifact`;
  `__init__.py`: `__version__`; `schemas/docs/v1/surface-inventory-snapshot.schema.json`) and stops
  if any differs. A #1020 test that uses a sample unknown analyzer id must not collide with the five
  ids above.
- `analyzer_contract.py` is also extended by the TypeScript/.NET analyzer feature (900004); edits are
  append-only. The root `pyproject.toml` scripts table is shared with sibling features and is edited
  append-only. Textual conflicts are resolved in the later child's remediation loop.
- Discovery runtime files under `packages/discovery-runtime/` and `schemas/discovery/` are not
  edited; reuse is library calls only (`exclusion_reason`, `MAX_CAPTURE_BYTES`, `SnapshotFile`,
  `relative_path`, `check_path_collisions`, `row`, `stable_id`, `parse_python_dependencies`,
  `parse_document`, `ParseLimits`, `canonical_json`, `is_full_revision`).
- No test creates temporary files. Fixtures are in-memory `bytes` constants; CRLF cases use `\r\n`
  escapes inside literals because `.gitattributes` normalizes committed files to LF.
- Property tests use deterministic `itertools` enumerations; `hypothesis` is not approved.
- Lexical limits: dynamic registration, cross-package routers, settings-driven prefixes and YAML
  features outside `parse_document` produce diagnostics rather than elements.
- Python grammar depends on the running interpreter (3.10 rejects PEP 695 syntax); such files yield
  `python-syntax-invalid` on older interpreters.
- A template env file's SHA-256 is recorded in `inputs`; plain `.env` files are never read, so no
  digest of a secrets file is produced.
- `packages/docs-runtime` is T2 in `quality-tiers.yml`: zero untyped escape hatches and at least one
  property test per pure public function.

## Implementation Strategy

- Implementation scope: new analyzer package, snapshot builder and CLI module in
  `packages/docs-runtime`; append-only edits to `analyzer_contract.py`, root `pyproject.toml` and
  `packages/docs-runtime/pyproject.toml`.
- Module split (each production file below 500 lines), under
  `packages/docs-runtime/src/drm_copilot_docs/`:

| File | Responsibility |
|---|---|
| `analyzers/__init__.py` | Package docstring only |
| `analyzers/_bounds.py` | `MAX_INPUT_BYTES`, `MAX_INPUT_FILES`, `MAX_KEYS_PER_INPUT`, `make_diagnostic`, over-bound check, `AnalysisBuilder` (de-duplicate and sort into `SurfaceAnalysis`) |
| `analyzers/_python_source.py` | Safe `ast.parse`, module naming from source roots, `ImportTable`, literal helpers |
| `analyzers/python_cli.py` | `PythonCliAnalyzer`, command tree, root-name resolution, `PYTHON_CLI_ANALYZER` |
| `analyzers/python_cli_argparse.py`, `python_cli_click.py`, `python_cli_typer.py` | Per-framework extraction into the shared command tree |
| `analyzers/python_http.py` | `PythonHttpAnalyzer`, mount resolution, template composition, `PYTHON_HTTP_ANALYZER` |
| `analyzers/python_http_fastapi.py`, `python_http_flask.py` | Per-framework route and mount extraction |
| `analyzers/python_public_api.py` | `PythonPublicApiAnalyzer`, `PYTHON_PUBLIC_API_ANALYZER` |
| `analyzers/config_keys.py` | Key-path quoting, declaration assembly, shape names |
| `analyzers/config_toml.py` | `resolve_toml_loads`, tool-table walk, script-table reader shared with `python_cli` |
| `analyzers/config_env.py`, `config_json_schema.py`, `config_yaml.py` | Per-format key extraction; env-file classification |
| `analyzers/config_files.py` | `ConfigFilesAnalyzer` dispatch by file name, `CONFIG_FILES_ANALYZER` |
| `analyzers/architecture.py` | `ArchitectureAnalyzer`, components, import edges, external dependencies, `PYTHON_ARCHITECTURE_ANALYZER` |
| `analyzers/snapshot_builder.py` | `build_snapshot`, `render_snapshot` |
| `cli_inventory.py` | `main_inventory`, `run_inventory_cli`, `InventoryPorts`, real ports |

  The per-framework helper modules refine the epic file list; they are not registered.
- Tests: `tests/docs_runtime/analyzers/__init__.py`, one test module per production module above
  (`test_bounds.py` through `test_snapshot_builder.py`), `test_registrations.py`,
  `test_analyzer_properties.py` (split into `test_snapshot_properties.py` if it nears 500 lines),
  and `tests/docs_runtime/test_cli_inventory.py`.
- Dependency changes: none. PyYAML is already planned for `packages/docs-runtime` by #1020; TOML
  uses `tomllib` or an already-present `tomli` through the injected seam (D4).
- Error handling: analyzers catch only `SyntaxError`, `ValueError`, `DependencyInputError` and the
  TOML decode error; the only broad handler is the CLI top-level handler.
- Logging/telemetry: none beyond the stderr summary line.
- Rollout: the command is new; no flag or staged rollout. The feature creates more than three
  non-test production files, so execution uses the batch-budget-exempt large route in the item
  worktree.

## Acceptance Criteria

- [ ] Each of the five analyzers (`python-cli`, `python-http`, `python-public-api`, `config-files`, `python-architecture`) emits exactly the expected elements (kind, path, declaration, name, `parent_id`) for an in-memory fixture covering the nine input families argparse, Click, Typer, FastAPI, Flask, `pyproject.toml`, `.env` (template-style), JSON Schema and YAML, asserted by tests under `tests/docs_runtime/analyzers/`.
- [ ] `python-cli` fixtures assert argparse nested subcommands and positional arguments, Click group and command naming (including suffix removal), Typer explicit and default command names (default = function name with underscores converted to hyphens), and console-script entries from `[project.scripts]` and `[tool.poetry.scripts]` with the attached root's options parented to the script element; every `cli-option` has a `cli-command` parent.
- [ ] `python-http` fixtures assert FastAPI router prefix and `include_router` composition, Flask blueprint `url_prefix` replacement and nesting, one element per method, and that an unresolvable prefix yields a route declared with the literal `<dynamic>` segment, property `prefix_resolved: false`, and an `http-prefix-dynamic` warning.
- [ ] `python-public-api` fixtures assert literal `__all__` forms (assignment, annotated assignment, `+=`, `extend`, `append`), the naming rule when `__all__` is absent, exclusion of `_`-prefixed modules and names, and a `public-api-dynamic-all` warning with `basis: naming` fallback for a non-literal `__all__`.
- [ ] `python-architecture` fixtures assert package and module components, internal import edges (including relative imports) stored as `import_count` plus sorted `import-NNNN` properties on the source component, and external dependency components from `requirements*.txt`, `setup.cfg` and `pyproject.toml` with no version constraint exported.
- [ ] Every dynamic registration form named in this spec (non-literal names or paths, computed prefixes, non-literal `__all__`, untracked receivers) yields a warning, non-blocking diagnostic with the specified code, and statically resolvable sites in the same file still produce their elements.
- [ ] A Python input that fails `ast.parse` yields exactly one `python-syntax-invalid` diagnostic and no elements from that file, and the snapshot contains no interpreter-version field.
- [ ] Re-running `build_snapshot` and `render_snapshot` over identical bytes, profile, revision and clock produces a byte-identical snapshot, proven by an `itertools.permutations` property test over input mapping insertion order and repeated builds; every `element_id` equals `element_identifier(kind, path, declaration)` and elements are sorted and unique.
- [ ] No configuration value is exported: an `itertools.product` property test over TOML, template env, JSON Schema and YAML inputs, with marker values in every value position (including JSON Schema `default`, `enum`, `const` and `examples`), asserts that no marker byte sequence appears in the rendered snapshot and that element properties contain only key and shape names.
- [ ] A plain `.env` file (and any non-template env-family file) under a source root is not read by `dev.docs.inventory`, has no `inputs` entry and no element, and yields exactly one `information` diagnostic `env-file-not-captured` naming its path; only `.env.example`, `.env.sample`, `.env.template` and `.env.dist` produce `config-key` elements.
- [ ] An input above `MAX_INPUT_BYTES` (1 MiB) yields exactly one `input-over-bound` error diagnostic, no element with that path and no `inputs` entry, proven by an `itertools.product` test over the five analyzers and sizes `MAX_INPUT_BYTES - 1`, `MAX_INPUT_BYTES` and `MAX_INPUT_BYTES + 1`; exceeding `MAX_INPUT_FILES` or the aggregate `MAX_CAPTURE_BYTES` exits 3 with no snapshot.
- [ ] The TOML loader seam resolves `tomllib`, then `tomli`, and when neither is importable each TOML input yields `toml-parser-unavailable` and no elements; tests cover all three cases with injected fakes and pass on every CI interpreter.
- [ ] The built fixture snapshot validates against `surface-inventory-snapshot.schema.json` through #1020 `validate_artifact` with no finding, and each `inputs[].sha256` equals `hashlib.sha256` of the corresponding in-bound fixture bytes with `size` equal to its length.
- [ ] `dev.docs.inventory` exits 0 for a fixture with no blocking diagnostic, 1 when a blocking diagnostic is present or the profile is invalid, 2 for invocation errors, and 3 for runtime failures, each asserted in-process with injected `InventoryPorts`, `io.StringIO` streams and a fixed clock.
- [ ] `dev.docs.inventory --analyzer <id>` restricts the snapshot to the named analyzers; an unregistered id exits 2 with a message naming it; an id whose analyzer produces none of the profile's selected element kinds exits 2 with a message naming the id; `--revision` rejects a value that is not a full object id with exit 2.
- [ ] The five registrations are appended at the end of `ANALYZER_REGISTRY` as Black-formatted blocks with no existing line of `analyzer_contract.py` changed; `validate_registry(ANALYZER_REGISTRY)` returns no finding; `load_analyzer` with the real `importlib.import_module` returns, for each entry, a module-level instance whose `identifier` and `element_kinds` equal the registration.
- [ ] The root `pyproject.toml` gains exactly one appended line `"dev.docs.inventory" = "drm_copilot_docs.cli_inventory:main_inventory"` after the #1020 `dev.docs.*` entries, with no other line of that file changed.
- [ ] No file under `packages/discovery-runtime/` or `schemas/discovery/` is changed, verified by an empty `git diff` against the integration branch base for those paths.
- [ ] Analyzer modules call none of `exec`, `eval`, `__import__` or `importlib.import_module`, and fixtures that import FastAPI and Flask are analyzed successfully although neither package is installed.
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs.analyzers` and `drm_copilot_docs.cli_inventory`, read per file from a JSON coverage report, with no production path excluded from measurement.
- [ ] Every new production file is below 500 lines, no new test creates a temporary file, and the new test modules pass in a reversed-order single-process run.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: each analyzer, snapshot builder, size bound, value redaction, CLI.
- [ ] Integration scenarios: snapshot validates against the inventory snapshot schema.
- [ ] CLI/API examples: `dev.docs.inventory --analyzer <id>`.
