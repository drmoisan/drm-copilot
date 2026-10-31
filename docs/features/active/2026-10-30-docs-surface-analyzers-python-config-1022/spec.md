# 2026-10-30-docs-surface-analyzers-python-config — Spec

- **Issue:** #1022
- **Parent (optional):** epic #1019 (documentation-estate-tooling), child 1022, wave 1, band C4
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T22-55
- **Status:** Draft
- **Version:** 0.2

## Revision Note

This is the PowerShell re-preparation of issue #1022 under owner decision D1 (a new planning cycle
with a fresh allowance of one planner revision and the single-pass preflight). The Python package
design of version 0.1 (a `packages/docs-runtime` analyzer package, a `dev.docs.inventory` Poetry
console script, a `cli_inventory.py` module, `ast`- and `tomllib`-based parsing, reuse of the Python
discovery runtime, Pytest suites and `pyproject.toml` edits) is withdrawn in full and is not an
input to the plan. This version replaces it with a PowerShell text-scanner design under
`.claude/lib/docs/`, behind `Invoke-DocsCommand.ps1 -Command inventory`.

Design source: `research/2026-10-30T22-40-docs-surface-analyzers-python-config-powershell-addendum.md`
in this feature folder. Binding inputs: the epic manifest
`docs/features/epics/documentation-estate-tooling/epic.md` (`## Owner Directive: Implementation
Language (2026-10-30, refined)` and its artifact-class table, `## Owner Decisions`, `### Amendment
of 1020 required by D3 and D5`, `### PowerShell contracts from the re-preparation of 1020`,
`### Command contract decisions from the first preparation of 1023`, `### Analyzer decisions from
the first preparation of 1022`, `### 1022 - docs-surface-analyzers-python-config` and
`### 900011 - docs-surface-analyzer-python-native`), the 1020 spec
`docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`
(`## Decisions Later Children Must Honor`), and the orchestrator decisions recorded in
`## Decisions` below. The 1020 spec on this branch does not yet carry the D3/D5 amendment; where
this spec cites an amended contract, the epic text is the source and `## Dependency on 1020`
states how the plan verifies it.

## Overview

The documentation-estate-tooling epic (#1019) needs an inventory of the documentable surface of a
destination repository before a coverage ledger, parity matrix or reference pages can be built.
Issue #1020 defines the surface element model, the analyzer registry, the command entry script and
the `surface-inventory-snapshot` schema, but no analyzer produces surface elements. Without
analyzers for Python command-line interfaces, HTTP routes, public APIs, configuration files and
architecture, the documentation tooling cannot report what a Python repository exposes, and
documentation drift must be counted by hand.

This feature adds five read-only, lexical, bounded and deterministic PowerShell text scanners for
Python and configuration surfaces, a pure snapshot builder, and the `inventory` subcommand of
`.claude/lib/docs/Invoke-DocsCommand.ps1`. Under owner decision D3 this scanner is the
always-available baseline: it needs PowerShell 7.4 only, runs in every destination repository, and
keeps a documented precision limit (`## Precision Limit`) that the coverage ledger (1023) records
as a `deferred` entry with an owner. The Python-native analyzer (child 900011, wave 2, python pack
only) later replaces the scanner for the four Python identifiers when the python pack and an
interpreter are available, and reproduces this feature's identity and digest contracts
(`## Contracts for 900011 and Later Children`).

The feature consumes the contracts planned by 1020 and does not re-create them. It edits no 1020
file except the anchored row insertions in `DocsAnalyzerRegistry.psm1` and `Invoke-DocsCommand.ps1`
and the append to the Claude `pack-manifests/core.json`.

## Behavior

### Analyzers

| Analyzer identifier | Module | Function | Element kinds | Inputs selected (by path, pure) |
|---|---|---|---|---|
| `python-cli` | `DocsAnalyzerPythonCli.psm1` | `Invoke-DocsAnalyzerPythonCli` | `cli-command`, `cli-option` | `*.py`; script tables of every `pyproject.toml` |
| `python-http` | `DocsAnalyzerPythonHttp.psm1` | `Invoke-DocsAnalyzerPythonHttp` | `http-route` | `*.py` |
| `python-public-api` | `DocsAnalyzerPythonApi.psm1` | `Invoke-DocsAnalyzerPythonApi` | `public-symbol` | `*.py` |
| `config-files` | `DocsAnalyzerConfigFiles.psm1` | `Invoke-DocsAnalyzerConfigFiles` | `config-key` | `pyproject.toml` `[tool.*]` keys, template env files, JSON Schema files, `*.yaml`, `*.yml` |
| `python-architecture` | `DocsAnalyzerArchitecture.psm1` | `Invoke-DocsAnalyzerPythonArchitecture` | `architecture-component` | `*.py` |

The Architecture module keeps the epic file name while its function and identifier carry the
`python-` prefix.

### Rules for every analyzer

- Contract: `Invoke-DocsAnalyzer<Name> -CapturedInput <object[]> -Selection <object>` returns
  `@{ Elements = @(...); Diagnostics = @(...) }` (1020 analyzer function contract). Pure,
  deterministic, no I/O, inputs not mutated, no module-scope mutable state.
- Lexical only. No consumer code is imported, executed, compiled or installed, and no interpreter
  or external process is started. Calls and decorators are recognized only when the callee
  resolves through the per-input import alias table or a tracked receiver (`## Precision Limit`,
  shared lexer).
- Case-sensitive and ordinal. Every comparison of source text uses `-ceq`, `-cne`, `-clike`,
  `-cmatch` or ordinal dictionaries, and every sort uses `[StringComparer]::Ordinal`, so Python
  names `App` and `app` stay distinct and output does not depend on the host culture.
- No dynamic dispatch. No `&` call through a variable, member or expression appears in a 1022
  module (enforced by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`);
  any seam is a `[scriptblock]`-typed parameter declared in the same file.
- Every element is built with 1020 `New-DocsSurfaceElement` and records `analysis_method: scanner`,
  `source_sha256` equal to the declaration-lines digest, and `line_range` per
  `## Contracts for 900011 and Later Children`.
- Diagnostics are built with 1020 `New-DocsDiagnostic`, at most one per `(analyzer, code, path)`;
  the message states the occurrence count and the first line number and never quotes source text
  or configuration values.
- No configuration value, default value, literal argument value other than declaration-forming
  names, or environment value reaches an element. Properties carry names and shapes only.

### `python-cli`

- argparse: `ArgumentParser(...)` (literal `prog=`), `add_subparsers(...)`, `add_parser("name", ...)`
  nested to any depth, `add_argument("--long", "-s", ...)` and positional `add_argument("name")`,
  `add_argument_group` and `add_mutually_exclusive_group` receivers mapped to their parser.
- Click: `@click.command` and `@click.group` with or without parentheses (alias-aware, including
  `from click import command`), `@G.command(...)` and `@G.group(...)` on a tracked group,
  `G.add_command(F)` and `G.add_command(F, name="x")`, `@click.option(...)` and
  `@click.argument(...)`.
- Typer: `typer.Typer(...)` (literal `name=`), `@app.command(...)`, `@app.callback(...)`,
  `app.add_typer(sub, name="x")`, `typer.run(func)`, parameters declared with `typer.Option(...)` or
  `typer.Argument(...)` as a default or inside `Annotated[...]`, a plain default (option), or no
  default (argument). A boolean option declares `--x`; the generated `--no-x` is not emitted.
- Console scripts: each entry of `[project.scripts]`, `[project.gui-scripts]` and
  `[tool.poetry.scripts]` whose value is a one-line string `module.path:attr` yields one
  `cli-command` at that `pyproject.toml` path. When the target module resolves to exactly one input
  and the attribute names the Click or Typer root object, or the function that constructs the
  argparse root, that root is attached (its subcommands and options are parented to the script
  element); otherwise property `attached: false`. The `module:attr` target is used internally only
  and is never exported.
- argparse `aliases=` and generated `--help`, `--version` and `--no-x` options are not emitted.
- Properties: `framework` (`argparse`, `click`, `typer`, `console-script`), `name_source`
  (`console-script`, `literal`, `module`), `table`, `attached`, `positional`, `required`, `action`,
  `short`, `help` (literal help text only), `has_default` (boolean). Default values are never
  exported. Every `cli-option` has a `parent_id` that is a `cli-command` element identifier.

### `python-http`

- Receivers: `FastAPI(...)`, `APIRouter(prefix="/x")`, `Flask(...)`,
  `Blueprint("name", __name__, url_prefix="/x")`.
- FastAPI: `.get .post .put .patch .delete .options .head .trace` decorators with a literal path,
  `.api_route(path, methods=[...])`, `.add_api_route(path, endpoint, methods=[...])`,
  `.websocket(path)` (method token `WEBSOCKET`, property `protocol: websocket`),
  `.include_router(router, prefix="/y")`.
- Flask: `.route(path, methods=[...])`, `.get .post .put .patch .delete` shortcuts,
  `.add_url_rule(path, ..., methods=[...])`, `.register_blueprint(bp, url_prefix="/y")`; a
  `url_prefix` given to `register_blueprint` replaces the blueprint's own; converters such as
  `<int:id>` are kept verbatim; automatic `HEAD` and `OPTIONS` are not emitted.
- Two passes over all Python inputs: pass 1 collects route sites and receivers per input; pass 2
  resolves mounts across inputs through the import alias table (`from pkg.mod import router`,
  `from . import mod` then `mod.router`) and composes templates. A router included `n` times yields
  `n` elements; a router never included keeps its own prefix with property `mounted: false`.
- Default method `GET`. One element per distinct method. Properties: `framework`, `mounted`,
  `prefix_resolved`, `protocol`.

### `python-public-api`

- Module qualified name from the path relative to the containing `surface_selection.source_roots`
  entry; `__init__.py` uses the package name. A module with a path segment beginning with `_`
  (other than `__init__`) is not public and yields nothing.
- Literal `__all__` forms at indentation 0 in statement order (`__all__ = [...]` or `(...)` of
  plain strings, `__all__: list[str] = [...]`, `__all__ += [...]`, `__all__.extend([...])`,
  `__all__.append("x")`): elements are the names in the final list, property `basis: all`.
- Without `__all__`, the naming rule: top-level `def`, `async def`, `class`, and simple or chained
  `NAME =`, `NAME: T =`, `NAME: T` targets not beginning with `_`, including inside top-level `if`,
  `try`, `except`, `else` and `finally` bodies; property `basis: naming`. Imported names are not
  public under the naming rule. Class members are out of scope.
- Property `symbol_kind`: `function`, `async-function`, `class`, `variable`, `import`, or
  `unresolved`.

### `config-files`

- Key-path declaration quoting (all formats): a segment matching `^[A-Za-z0-9_-]+$` stays bare; any
  other segment is a TOML basic string with `"` and `\` escaped; arrays contribute the segment
  `[]`; segments are joined with `.`. Values are never retained.
- TOML: `pyproject.toml` by basename; every key under `tool.*`, excluding `tool.poetry.scripts`
  (owned by `python-cli`) and the dependency subtrees `tool.poetry.dependencies`,
  `tool.poetry.dev-dependencies`, `tool.poetry.group.*.dependencies` and `tool.poetry.extras`.
  `[project]` and `[build-system]` are not configuration. Properties `value_type` (`table`,
  `array`, `string`, `integer`, `float`, `boolean`, `datetime`) and `format: toml`.
- Environment templates: only `.env.example`, `.env.sample`, `.env.template` and `.env.dist` are
  read. Declaration = key; property `format: env`.
- JSON Schema: a basename ending `.schema.json`, or a `.json` input whose root `$schema` string
  contains `json-schema.org`; other JSON inputs are ignored. Walk: root `properties`, nested
  `properties`, object-form `items.properties` (segment `[]`), `allOf`/`anyOf`/`oneOf` members
  (property `conditional: true` for `anyOf` and `oneOf`), local `$ref` to `#/$defs/...` and
  `#/definitions/...` up to depth 16 with a visited set. `default`, `enum`, `const`, `examples` and
  `pattern` are never read into output. Properties `schema_type` (the literal `type` string,
  `multiple`, or absent), `required` (boolean) and `format: json-schema`.
- YAML (`*.yaml`, `*.yml`): every mapping key path in the classified subset; properties
  `value_type` (`object`, `array`, `string`, `integer`, `number`, `boolean`, `null`) and
  `format: yaml`.

### `python-architecture`

- One `architecture-component` per package (directory holding `__init__.py` among the inputs) and
  per module (`*.py` input); declaration = dotted name; property `component_kind` (`package` or
  `module`).
- Internal import edges from `import` and `from ... import` statements at any indentation
  (including `TYPE_CHECKING` blocks), relative imports resolved against the module's package,
  longest dotted-prefix match against input modules and packages. Edges are indexed scalar
  properties on the source component: `import_count` (integer) and `import-0001`, `import-0002`,
  ... whose values are target dotted names in ordinal order; bound 1000 per component.
- PEP 420 namespace directories are not package components. External distribution dependencies
  are out of scope (`## Out of Scope`).

### Inventory command and snapshot builder

`Invoke-DocsInventoryCommand -Argument <IDictionary> -Context <object>` in `DocsInventory.psm1` is
the only 1022 function that uses the 1020 command context, and only through `Context.ReadText`,
`Context.ReadBytes`, `Context.ListFile`, `Context.UtcNow` and `Context.WriteText`. It never calls
`Write-DocsFileText` directly, never prints output and never calls `exit`. Flow:

1. Read the profile (`-Profile`, default `docs/documentation-estate/docs-profile.json`) through
   `Context.ReadText` and `ConvertFrom-DocsProfileText`. An absent profile exits 1 with the 1020
   `DOCS_PROFILE_MISSING` behavior; profile findings exit 1 with no snapshot.
2. Validate `-Revision` with `Test-DocsFullRevision`; an invalid value exits 2. An absent
   `-Revision` records `revision: null`, which 1023's `docs-complete` rejects with
   `DOCS_SNAPSHOT_UNPINNED` (D5).
3. Select rows with `Select-DocsAnalyzerRegistration`, passing `-AnalyzerId` when `-Analyzer` is
   given (otherwise the profile's `surface_selection.analyzers`, or every registered analyzer whose
   kinds intersect `surface_selection.element_kinds`). An unknown identifier, or an identifier whose
   analyzer produces none of the profile's selected element kinds, exits 2 with a
   `DOCS_CLI_ARGUMENTS` finding naming it. Method selection (native or scanner) is performed by the
   registry selection of the amended 1020, not by 1022.
4. List files under each source root with `Context.ListFile`; apply `surface_selection.exclusions`
   with `Find-DocsPathOrGlobMatch` (`## API / CLI Surface`); withhold every non-template env-family
   file without reading it and emit `env-file-not-captured` for it.
5. Apply the aggregate bounds (more than 50,000 inputs, or more than 256 MiB in total, exits 3 with
   `DOCS_CLI_RUNTIME` and no snapshot).
6. Read each remaining file with `Context.ReadBytes` and wrap it with
   `New-DocsCapturedInput -MaxBytes 1048576`.
7. Invoke each selected row with `Invoke-DocsAnalyzer`, passing the full captured-input list.
8. Build the snapshot with `New-DocsInventorySnapshot` and `Context.UtcNow`, and self-validate it with
   `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'`; a failure is a defect guard
   that exits 3 with `DOCS_CLI_RUNTIME`.
9. Without `-Write`, write nothing (dry run). With `-Write`, write the snapshot text
   (`ConvertTo-DocsJsonText -Indented`) to the profile `artifact_paths.inventory_snapshot` through
   `Context.WriteText`, mode `overwrite` when the file exists, else `create`.

`New-DocsInventorySnapshot` merges analyzer outputs, filters elements to
`surface_selection.element_kinds`, removes duplicates (`duplicate-declaration`), sorts, and builds
the header, `id` and `profile_sha256` (`## Data & State`).

## Precision Limit

This section is the complete, deterministic list of what the scanner classifies, reports, and
cannot see. Each construct is in exactly one class: **classified** (produces elements),
**diagnostic** (produces the named diagnostic with the stated effect), or **undetectable** (no
element and no diagnostic). 1023 records this limit as one `deferred` coverage-ledger entry with an
owner and a target, naming the undetectable constructs below. Every element the scanner emits
records `analysis_method: scanner`.

Common rules:

- Codes follow the identifier grammar `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$` inherited by the docs
  `diagnostic.code`.
- Blocking diagnostics have severity `error`; non-blocking diagnostics have severity `warning`
  (decision 2). Any blocking diagnostic makes `inventory` exit 1.
- "Site" means one registration call, decorator or binding; "file" means the whole input. A
  site-level diagnostic removes only that site; statically classifiable sites in the same file
  still produce elements. An input-level diagnostic removes every element of that file unless the
  table states another effect.

### Shared Python lexer (`DocsPythonTokens.psm1`, `DocsPythonSyntax.psm1`)

Classified: UTF-8 source with an optional BOM; a PEP 263 coding cookie naming `utf-8`, `utf8` or
`utf_8` (case-insensitive) on line 1 or 2; every token class of the lexer (`## API / CLI Surface`);
tab indentation expanded to the next multiple of 8; Unicode identifiers. Import alias table:
`import m`, `import m as a`, `import m.sub`, `from m import n`, `from m import n as a`,
parenthesized multi-line `from` imports, at indentation 0 or inside top-level `if`, `elif`, `else`,
`try`, `except` and `finally` blocks. Receiver tracking: `NAME = <constructor>(...)` and
`NAME: T = <constructor>(...)` at any indentation, flow-insensitive per file.

| Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|
| Bytes that are not strict UTF-8 (1020 `New-DocsCapturedInput`) | owned by 1020 (proposed `input-encoding-invalid`) | input | yes | no element for the file; no `inputs` entry |
| Input above 1 MiB (1020 `New-DocsCapturedInput -MaxBytes 1048576`) | owned by 1020 (proposed `input-over-bound`) | input | yes | no element for the file; no `inputs` entry |
| A coding cookie naming any other encoding | `python-encoding-unsupported` | input | yes | no element for the file |
| Unterminated single-, double- or triple-quoted string, unbalanced bracket, or backslash continuation at end of input | `python-lexer-unterminated` | input | yes | no element for the file |
| A character outside the token grammar outside strings and comments (for example `$`, `?`, backtick), bracket depth above 64, or f-string replacement fields nested more than two levels | `python-lexer-unclassified` | input | yes | no element for the file |
| More than 262,144 tokens in one input | `python-token-limit` | input | yes | no element for the file |
| A dedent to a column not on the indentation stack | `python-indentation-invalid` | input | yes | no element for the file |
| A declaration-forming identifier containing a non-ASCII character (the scanner applies no NFKC normalization) | `python-identifier-non-ascii` | site | no | no element for the site |
| A string in a declaration position that is a bytes or f-string, carries a backslash in a non-raw string, or is implicitly concatenated with such a part | the owning analyzer's dynamic code | site | no | no element for the site |
| `from <framework> import *` where `<framework>` is `argparse`, `click`, `typer`, `fastapi` or `flask` | `python-import-star-framework` | site | no | no element for sites that resolve only through the star import |
| A framework module imported inside a `def` or `class` body | `python-import-nested-framework` | site | no | no element for sites that resolve only through the nested import |
| An import alias or tracked receiver name bound to two different targets in one input | `python-binding-ambiguous` | site | no | no element for sites on that name |

### `python-cli`

| Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|
| Non-literal command name, option string or argument name (variable, f-string, escaped string, concatenation with a non-literal, `*args`, `**kwargs`) | `cli-dynamic-registration` | site | no | no element for the site |
| A registration site inside a `for` or `while` body or a comprehension | `cli-registration-in-loop` | site | no | no element for the site |
| `.add_argument(`, `.add_parser(`, `.add_subparsers(`, `.add_command(`, `.add_typer(`, or a `@X.command`, `@X.group`, `@X.callback` decorator on an untracked receiver (function parameter, attribute such as `self.parser`, call result) | `cli-unbound-registration` | site | no | no element for the site |
| `parents=[...]` on `ArgumentParser` or `add_parser` | `cli-parents-unresolved` | site | no | no element for the inherited arguments; the parser itself is classified |
| Click `cls=`, constructed `click.Group(...)`, `click.Command(...)`, `click.CommandCollection(...)`, lazy or plugin groups, Typer `cls=` | `cli-custom-class` | site | no | no element for the site |
| A decorator name bound in the input to a framework call or a list of them, or a decorator applied by call (`click.command()(f)`) | `cli-decorator-indirect` | site | no | no element for the site |
| A Typer parameter whose default or annotation is not a classified form | `cli-typer-parameter-unresolved` | site | no | no element for the parameter |
| A script-table entry that is not a one-line string, or whose key is a quoted key with escapes | `cli-console-script-unsupported` | site | no | no element for the entry |

### `python-http`

| Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|
| Non-literal route path or method list | `http-dynamic-route` | site | no | no element for the site |
| Non-literal mount or router prefix | `http-prefix-dynamic` | site | no | route emitted with the literal segment `<dynamic>` and property `prefix_resolved: false` |
| A route registration inside a `for` or `while` body or a comprehension | `http-route-in-loop` | site | no | no element for the site |
| `.mount(...)`, or `include_router`/`register_blueprint` of a router that is not a tracked receiver in the inputs | `http-mount-unresolved` | site | no | no element for the mounted application's routes through that mount |
| A decorator on an untracked receiver whose first argument is a literal string beginning with `/` | `http-unbound-route` | site | no | no element for the site |
| `add_url_rule(..., view_func=X.as_view(...))` without literal `methods`, and class-based route helpers | `http-method-view-unresolved` | site | no | no element for the site |
| A router inclusion cycle, or composition depth above 16 | `http-include-unresolved` | site | no | routes keep their own prefix with property `mounted: false` |

### `python-public-api`

| Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|
| `__all__` built by concatenation, comprehension, `list(...)`, star-unpacking, a non-literal element, or modified inside a function, loop, or top-level `if`/`try` block | `public-api-dynamic-all` | input | no | fallback to the naming rule with property `basis: naming` (elements are not removed) |
| A name in `__all__` with no top-level binding | `public-api-name-unresolved` | site | no | element kept with `symbol_kind: unresolved` |
| `from x import *` at top level in a module with a literal `__all__` | `public-api-star-import` | input | no | informative; elements unchanged |
| One name defined in several top-level branches | `public-api-conditional-definition` | site | no | the first definition by line is emitted |
| Tuple or list unpacking target at top level | `public-api-unpacking-target` | site | no | no element for the unpacked names |
| A path segment that is not a Python identifier | `public-api-module-not-importable` | input | no | no element for the file |

### `python-architecture`

| Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|
| `importlib.import_module(`, `__import__(`, `importlib.util.spec_from_file_location(` | `architecture-dynamic-import` | site | no | the edge is not followed |
| A relative import that climbs above the source root or appears in a module outside any package | `architecture-relative-import-unresolved` | site | no | the edge is not recorded |
| More than 1000 edges on one component | `architecture-edge-limit` | site | no | `import_count` kept; edge properties dropped |
| A path segment that is not a Python identifier | `architecture-module-name-invalid` | input | no | no element for the file |

### `config-files`

TOML subset classified: comments; `[table]` and `[[array.of.tables]]` headers with bare, quoted and
dotted keys; `key = value` with bare, quoted and dotted keys; values skipped by extent (basic,
literal, multi-line basic and multi-line literal strings, arrays spanning lines with comments,
one-line inline tables, numbers, booleans, date-times).

Environment template subset classified: blank and `#` lines; optional `export ` prefix; key grammar
`^[A-Za-z_][A-Za-z0-9_]*$` before `=`; a quoted value that does not close on its line consumes
lines until the closing quote, so a multi-line value never becomes a key.

YAML subset classified: block mappings; block sequences (segment `[]`, mapping items inside
sequences); plain, single-quoted and escape-free double-quoted keys; comments; block scalars `|`
and `>` with chomping and indentation indicators; one optional `---` before the first content line
and an optional final `...`; single-line scalar values and plain multi-line continuation lines that
contain no `: `; single-line flow collections as values.

| Format | Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|---|
| TOML | Unterminated string or array, malformed header, key without `=`, duplicate key or table redefinition, multi-line inline table | `toml-invalid` | input | yes | no element for the file |
| TOML | Inline-table value | `toml-inline-table-not-expanded` | site | no | key emitted with `value_type: table`; inner keys not emitted |
| TOML | A quoted key containing a backslash escape | `toml-key-escape-unsupported` | site | no | no element for the key |
| env | Any other env-family file (`.env`, `.env.<other>`, `<name>.env`) | `env-file-not-captured` (analyzer `docs-inventory`) | input | no | file not read, not hashed, no `inputs` entry, no element |
| env | A line that is not blank, a comment or a key line | `env-line-unrecognized` | site | no | no element for the line |
| env | A quoted value still open at end of input | `env-invalid` | input | yes | no element for the file |
| env | A key repeated | `env-key-duplicate` | site | no | first occurrence kept |
| JSON Schema | Any `ConvertFrom-DocsJsonText` finding (invalid JSON, duplicate key, depth) | `json-invalid` | input | yes | no element for the file |
| JSON Schema | Remote `$ref`, missing target, cycle, or depth above 16 | `json-schema-ref-unresolved` | site | no | no element beneath the reference |
| JSON Schema | `if`/`then`/`else`, `not`, `patternProperties`, schema-valued `additionalProperties`, `dependentSchemas`, `prefixItems`, `unevaluatedProperties` | `json-schema-keyword-not-expanded` | site | no | keys beneath the keyword are not enumerated |
| YAML | Tab indentation, a dedent to an unknown column, an unterminated quoted scalar, a continuation line containing `: ` | `yaml-invalid` | input | yes | no element for the file |
| YAML | A second document (`---` after content, content after `...`) | `yaml-multi-document` | input | no | no element for the file |
| YAML | Anchors `&x`, aliases `*x`, merge keys `<<` | `yaml-anchor-alias` | input | no | no element for the file |
| YAML | Tags (`!x`, `!!x`), complex keys (`? `), directives (`%YAML`), flow collections spanning lines | `yaml-unsupported` | input | no | no element for the file |
| YAML | A single-line flow collection as a value | `yaml-flow-collection-not-expanded` | site | no | key emitted with `value_type` `object` or `array`; inner keys not emitted |
| YAML | A double-quoted key containing an escape | `yaml-key-escape-unsupported` | site | no | no element for the key |
| YAML | A root that is not a mapping | `yaml-root-not-mapping` | input | no | no element for the file |
| any | More than 10,000 keys in one input | `config-key-limit` | input | yes | no element for the file |

### Inventory level (`analyzer_id` `docs-inventory`)

| Construct | Code | Level | Blocking | Effect |
|---|---|---|---|---|
| A declaration rejected by `Get-DocsElementId` (`DOCS_IDENTITY_INPUT_INVALID`) | `declaration-invalid` | site | no | no element for the site |
| Two sites with the same kind, path and declaration | `duplicate-declaration` | site | no | the first site by line is kept |
| More than 50,000 inputs or more than 256 MiB in total | none (finding `DOCS_CLI_RUNTIME`) | run | n/a | exit 3, no snapshot |

### Undetectable constructs (no element, no diagnostic)

- Registration through `getattr`, `setattr`, `globals()` or `sys.modules`.
- Code produced by `exec`, `eval` or code generation.
- Registration in files outside `surface_selection.source_roots` or matched by `exclusions`.
- Plugin entry points other than the three console-script tables.
- User-defined decorators that wrap framework decorators under a bare name (`@my_route("/x")`).
- Frameworks outside argparse, Click, Typer, FastAPI and Flask (for example Starlette `Route` lists
  or Django URL configurations).
- PEP 695 `type` alias statements as public symbols.
- Import edges hidden in strings.

## Inputs / Outputs

- Inputs:
  - Options of `Invoke-DocsCommand.ps1 -Command inventory` (`## API / CLI Surface`).
  - The docs profile (JSON), read through `ConvertFrom-DocsProfileText`.
  - Files under `surface_selection.source_roots`, minus paths matched by
    `surface_selection.exclusions`, minus non-template env-family files.
  - No environment variable is read.
- Outputs:
  - `result` `{snapshot, snapshot_path, written}` in the 1020 command result; with `-Json`, the
    canonical envelope `{command, exit_code, findings, ok, result}` on stdout.
  - With `-Write`, the snapshot file at `artifact_paths.inventory_snapshot`.
- Bounds:

| Bound | Value | Effect when exceeded |
|---|---|---|
| Bytes per input | 1,048,576 (1 MiB) | 1020 over-bound diagnostic (blocking); no element and no `inputs` entry for that file |
| Inputs per run | 50,000 | exit 3, `DOCS_CLI_RUNTIME`, no snapshot |
| Bytes per run | 256 MiB | exit 3, `DOCS_CLI_RUNTIME`, no snapshot |
| Tokens per Python input | 262,144 | `python-token-limit` |
| Bracket depth | 64 | `python-lexer-unclassified` |
| Keys per configuration input | 10,000 | `config-key-limit` |
| Edges per architecture component | 1000 | `architecture-edge-limit` |
| JSON Schema `$ref` depth and HTTP composition depth | 16 | `json-schema-ref-unresolved`, `http-include-unresolved` |

- Versioning: each `analyzers[].version` is the registry row `Version` (`1.0.0`). Declaration
  strings, normalization and spans are part of element identity and digests; a later change to
  them is a contract change and must change the recorded version.

## API / CLI Surface

### Module layout (`.claude/lib/docs/`)

All modules are pushed-down PowerShell libraries. Every function except `Invoke-DocsInventoryCommand`
is pure: it takes strings and hashtables, returns new values, and performs no I/O. Every
`$PSScriptRoot` use is the literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'`. Modules
import 1020's `DocsJson.psm1` and `DocsSurface.psm1` and never `DiscoveryEncoding.psm1` directly.

| File | Exported functions |
|---|---|
| `DocsSourceText.psm1` | `ConvertTo-DocsSourceLine`, `Get-DocsDeclarationDigest -Line <string[]> -Span <int[][]>`, `ConvertTo-DocsKeyPathDeclaration -Segment <string[]>`, `Get-DocsModuleDottedName -Path -SourceRoot <string[]>`, `Find-DocsPathOrGlobMatch -Path <string> -Entry <object[]>`, `New-DocsDiagnosticAggregate`, `Add-DocsDiagnosticOccurrence`, `Select-DocsUniqueElement` |
| `DocsPythonTokens.psm1` | `Get-DocsPythonToken -Text <string>` returning `@{ Tokens; Diagnostics }` |
| `DocsPythonSyntax.psm1` | `Get-DocsPythonLogicalLine -Token <object[]>`, `Get-DocsPythonImportTable`, `Get-DocsPythonReceiverTable`, `Read-DocsPythonCall`, `ConvertFrom-DocsPythonStringToken`, `Get-DocsPythonDefinitionHeader`, `Get-DocsPythonEnclosingBlock` |
| `DocsTomlKeys.psm1` | `Get-DocsTomlKey -Text <string>`, `Get-DocsTomlScriptEntry` |
| `DocsPythonCliArgparse.psm1` | `Get-DocsArgparseCommandSite` |
| `DocsPythonCliClick.psm1` | `Get-DocsClickCommandSite` |
| `DocsPythonCliTyper.psm1` | `Get-DocsTyperCommandSite` |
| `DocsAnalyzerPythonCli.psm1` | `Invoke-DocsAnalyzerPythonCli`, `Resolve-DocsCliRootName`, `ConvertTo-DocsCliElement` |
| `DocsPythonHttpSites.psm1` | `Get-DocsFastApiRouteSite`, `Get-DocsFlaskRouteSite`, `Get-DocsHttpMountSite` |
| `DocsAnalyzerPythonHttp.psm1` | `Invoke-DocsAnalyzerPythonHttp`, `Resolve-DocsHttpTemplate` |
| `DocsAnalyzerPythonApi.psm1` | `Invoke-DocsAnalyzerPythonApi`, `Get-DocsPublicApiAllName`, `Get-DocsPublicApiBinding` |
| `DocsYamlKeys.psm1` | `Get-DocsYamlKey -Text <string>` |
| `DocsJsonSchemaKeys.psm1` | `Get-DocsJsonMemberSpan -Text <string>`, `Get-DocsJsonSchemaKey -Value <IDictionary> -MemberSpan <object>` |
| `DocsAnalyzerConfigFiles.psm1` | `Invoke-DocsAnalyzerConfigFiles`, `Get-DocsEnvTemplateKey`, `Test-DocsEnvTemplatePath`, `Get-DocsConfigFileFormat` |
| `DocsAnalyzerArchitecture.psm1` | `Invoke-DocsAnalyzerPythonArchitecture`, `Get-DocsPythonImportEdge` |
| `DocsInventorySnapshot.psm1` | `New-DocsInventorySnapshot`, `Get-DocsInventorySelection` |
| `DocsInventory.psm1` | `Invoke-DocsInventoryCommand -Argument -Context` (command; the only function using the command context) |

Every module stays below 500 lines; a module reaching 500 lines during execution is split into a
new module with its own suite, mirror copy and manifest entry.

`Find-DocsPathOrGlobMatch` returns the first entry (in profile order) whose `path_or_glob` matches
`Path`, or `$null`: an exact match, a prefix match where the entry plus `/` begins `Path`, or a
case-sensitive glob where `*` matches any run of characters other than `/`, `**` matches any run
including `/`, `?` matches one character other than `/`, and every other character is literal.

### Bounded Python lexer

`Get-DocsPythonToken` runs one `\G`-anchored compiled `[regex]` alternation over the normalized text
and produces a flat token list; every token carries line and column. Token classes, in match order:

1. `NEWLINE` (LF after normalization); a newline at bracket depth 0 not preceded by a continuation
   ends the logical line.
2. `CONTINUATION` (backslash immediately before a newline).
3. `COMMENT` (`#` to end of line).
4. `STRING`: optional prefix from `r`, `u`, `b`, `f`, `br`, `rb`, `fr`, `rf` in any letter case;
   quote `'`, `"`, `'''` or `"""`; triple-quoted strings span lines; backslash escapes are skipped in
   non-raw strings, and in raw strings a backslash still protects the quote; f-strings track
   replacement-field braces and nested strings up to two levels. Records `Prefix`, `IsTriple`,
   `HasEscape`, `IsBytes`, `IsFormat`.
5. `NAME`: `[\p{L}\p{Nl}_][\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}]*`; keywords (`def`, `class`,
   `async`, `import`, `from`, `as`, `for`, `while`, `if`, `elif`, `else`, `try`, `except`, `finally`,
   `with`, `lambda`, `return`) carry `IsKeyword`.
6. `NUMBER` (skipped by extent).
7. `OP`: brackets `( ) [ ] { }` with a running depth (bound 64), `@`, `:`, `,`, `.`, `=`, `+=`, `->`,
   `:=`, `**`, `*`, and every other Python operator.
8. Whitespace (spaces, tabs, form feed) between tokens.

`Get-DocsPythonLogicalLine` groups tokens into logical lines with `StartLine`, `EndLine`, `Indent`
(column of the first token, tabs to multiples of 8, form feed resetting the column) and `Tokens`.
Decorators are logical lines whose first token is `@`; a definition header is the logical line
whose first non-`async` token is `def` or `class`, ending at the `:` at depth 0; "top-level" means
`Indent` 0; statements separated by `;` at depth 0 are split. The scan-record pattern of
`.claude/lib/mermaid/MermaidLineScanner.psm1` (index-aligned quote masking, separate bracket-delta
accounting, an ordered scan record with an explicit `Unclassifiable` class) is reused as a pattern;
its functions are not called, because Mermaid treats a backslash as an ordinary character.

### Registration (1020 anchors)

- `DocsAnalyzerRegistry.psm1`: five rows inserted directly under the 1022 anchor (the executed 1020
  carries it as `1022` or as the placeholder `900003`; Phase 0 reads the literal), one row per line,
  in identifier order (`config-files`, `python-architecture`, `python-cli`, `python-http`,
  `python-public-api`), each declaring the scanner method in the field the amended row grammar
  defines (decision 3). Example:
  `[pscustomobject]@{ Id = 'config-files'; Version = '1.0.0'; ElementKinds = @('config-key'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerConfigFiles.psm1'); Function = 'Invoke-DocsAnalyzerConfigFiles' }`
  plus the method field. The other rows use the values in the `## Behavior` analyzer table. 1022
  never touches the 900004 or 900011 anchors.
- `Invoke-DocsCommand.ps1`: one row under the 1022 inventory anchor:
  `[pscustomobject]@{ Name = 'inventory'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsInventory.psm1'); Function = 'Invoke-DocsInventoryCommand'; Option = @{ Profile = 'value'; Analyzer = 'multi'; Revision = 'value'; Write = 'switch' } }`.

### `inventory` subcommand

`pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory [-Profile <relative path>] [-Analyzer <id>]... [-Revision <full object id>] [-Write] [-Json]`

| Exit code | Meaning | Findings |
|---|---|---|
| 0 | Snapshot built with no blocking diagnostic | none of severity `error` |
| 1 | Snapshot built with at least one blocking diagnostic (one `DOCS_INVENTORY_BLOCKING_DIAGNOSTIC` error finding per blocking diagnostic, `related_paths` its path); or invalid or absent profile (no snapshot) | as stated |
| 2 | Usage or input error: argument errors detected by 1020 `ConvertFrom-DocsCommandArgument`, an unknown `-Analyzer` identifier, an identifier whose analyzer produces none of the selected element kinds, a `-Revision` that is not a full object id, a non-relative `-Profile` | one `DOCS_CLI_ARGUMENTS`; `result` `null` |
| 3 | Runtime failure: aggregate bound exceeded, a read failure other than absence, a write failure, snapshot self-validation failure (defect guard), or an unexpected exception at the entry boundary | one `DOCS_CLI_RUNTIME`; `result` `null` |

- `result` on exit 0 and on exit 1 with a snapshot: `{snapshot, snapshot_path, written}`. All
  snapshot numbers are integers, so `ConvertTo-DocsCanonicalJson` can render the envelope.
- `-Json` envelope: canonical JSON `{command, exit_code, findings, ok, result}` with `command`
  `inventory`. Every exit path's envelope validates against
  `schemas/docs/v1/docs-command-envelope.schema.json` (D5) through the validation function the
  amended 1020 exposes; if it exposes none, the test calls `Test-Json` with the self-contained
  runtime copy under `.claude/lib/docs/schemas/v1/`.

Example invocations:

- `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Json`
  returns the dry-run snapshot in the envelope and exits 0 or 1.
- `... -Command inventory -Analyzer python-cli -Revision <40-hex id> -Write` writes a
  revision-pinned snapshot containing CLI elements only.
- `... -Command inventory -Analyzer not-registered` exits 2 with a `DOCS_CLI_ARGUMENTS` finding
  naming `not-registered`.

### Push-down and manifest

- Every created or edited `.claude/lib/docs/` file is copied byte-identically to
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` after its last edit.
- Every new file is appended to `paths` of
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` after the 1020
  docs entries. No 1022 file is listed in `pack-manifests/python.json`, because the scanner is
  PowerShell and always available (D3).
- `quality-tiers.yml` is not edited: 1020 classifies `.claude/lib/docs` at T3 and the 1022 files
  live in that folder.

## Data & State

- Snapshot fields (1020 `### Artifact schema: surface-inventory-snapshot`, with the amended
  `analysis_method`): header (`$schema` `urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot`,
  `schema_version` `"1.0.0"`, `artifact_kind`, `id`, `extensions` `{}`); `repository` = profile
  `repository.id`; `revision`; `profile_sha256`; `analyzers` sorted by `id` (each with `id`,
  `version`, and the method field if the amended schema defines one); `inputs` sorted by `path`;
  `elements` sorted by `element_id`; `diagnostics` sorted by `id`; `captured_at` from
  `Context.UtcNow`.
- Snapshot `id`: `Get-DocsStableId -Prefix 'surface-inventory'` over
  `{repository, revision, profile_sha256, analyzers, inputs}`; it excludes `captured_at`.
- `profile_sha256`: `Get-DocsSha256Hex` of `ConvertTo-DocsCanonicalJson` of the parsed profile.
- `inputs[]`: `{path, sha256, size}` for every captured input whose `text` is not `$null`; `sha256`
  is the whole-file digest of the exact bytes (`Get-DocsBytesSha256Hex`). Over-bound, undecodable
  and withheld env files have no `inputs` entry and no element.
- Element `source_sha256` is the declaration-lines digest, not the whole-file digest (decision 1).
- Byte identity holds for identical input bytes, profile, revision, analyzer selection and clock
  value, regardless of the order in which `Context.ListFile` returns paths.
- Invariants: every `element_id` equals `Get-DocsElementId` of its kind, path and declaration;
  elements are unique; every `cli-option` parent is a `cli-command`; every element records
  `analysis_method: scanner`; no over-bound, undecodable or withheld input appears in `inputs` or as
  an element `path`.
- No caching, persistence or migration. The only write is the optional `-Write` snapshot through
  `Context.WriteText`.

## Contracts for 900011 and Later Children

The Python-native analyzer (900011) reproduces every contract in this section exactly for every
construct both analyzers classify, so element identifiers and `source_sha256` values are equal
across methods and ledger entries and evidence pins stay valid when the method changes.

### Declaration string per kind

| Kind | Declaration | Rules |
|---|---|---|
| `cli-command` | root name, then space-separated subcommand names | Root-name order: (1) the console-script name when the root is attached; (2) a literal `prog=`, Click `name=` or first positional string, or `typer.Typer(name=)`; (3) the module dotted name relative to the containing source root. Click default name: function name lower-cased, `_` replaced by `-`, then one trailing `-command`, `-cmd`, `-group` or `-grp` removed. Typer default name: function name lower-cased with `_` replaced by `-`. |
| `cli-option` | command path, one space, option | Option = the first string beginning `--` (Click strings are split at `/` first), else the first string beginning `-`, else the positional or argument name as written. Typer default option: `--` plus the parameter name with `_` replaced by `-`; a boolean option declares `--x`. |
| `http-route` | upper-case method, one space, template | One element per distinct method, sorted. FastAPI template: verbatim concatenation of include prefixes (outermost first), router prefix and path. Flask template: when a prefix applies, `prefix.TrimEnd('/') + '/' + rule.TrimStart('/')`. An unresolved segment is the literal `<dynamic>`. WebSocket method token `WEBSOCKET`. Default `GET`; Flask automatic `HEAD` and `OPTIONS` are not emitted. |
| `public-symbol` | `<module dotted name>.<name>` | `__init__.py` uses the package name. |
| `architecture-component` | dotted module or package name | |
| `config-key` | quoted key path (`## Behavior`, `config-files`) | TOML paths start at the root table (`tool.x.y`). Scanner-only. |

The Typer lower-casing rule, the Flask prefix join and the Click suffix list are confirmed against
the published framework sources during planning; the fixture pins the rule as stated, and a
disagreement is resolved by revising this spec before execution, not by the executor.

### Source normalization and declaration-lines digest (D5)

Normalization (`ConvertTo-DocsSourceLine`):

1. Decode the captured bytes as strict UTF-8 (undecodable input is the 1020 diagnostic; no element).
2. Remove one leading U+FEFF.
3. Replace `\r\n` with `\n`, then each remaining `\r` with `\n`. No other character is a line break
   (form feed, U+2028, U+2029 and U+0085 are not).
4. Split on `\n`; when the text ends with `\n`, drop the final empty element. Lines are numbered
   from 1. Trailing whitespace and tabs are kept; no Unicode normalization is applied.

Digest (`Get-DocsDeclarationDigest`): for each span `[start, end]` in order, lines `start` through
`end`, each followed by one `\n`, concatenated; the digest is the lowercase hex SHA-256 of the
UTF-8 bytes (`Get-DocsSha256Hex -Text`). An empty span list yields the digest of the empty string.
The value is stored in element `source_sha256`.

A "statement span" runs from the line of the statement's first token to the line of its last
token, including bracket and backslash continuations and any triple-quoted string inside it. A
"header span" runs from the line of a given decorator's `@` to the line of the `:` that ends the
`def` or `class` header.

| Kind and site | Span | `line_range` |
|---|---|---|
| argparse root or subcommand | statement span of the `ArgumentParser(...)` or `add_parser(...)` statement | span |
| Click or Typer command, `typer.run` target | header span from the topmost decorator (or the `def` line when undecorated) | span |
| `typer.Typer(name=...)` root, `add_typer` subgroup | statement span | span |
| console-script command | the TOML entry span (key line through end of value) | span |
| argparse option | statement span of `add_argument(...)` | span |
| Click option or argument | from the decorator's `@` line to the line of its closing parenthesis | span |
| Typer parameter | from the parameter name token's line to the line of the parameter's last token before the separating comma or closing parenthesis | span |
| `http-route` decorator | header span starting at that route decorator | span |
| `http-route` call (`add_api_route`, `add_url_rule`) | statement span | span |
| `public-symbol` `def` or `class` | header span from the topmost decorator | span |
| `public-symbol` assignment or import binding | statement span of the first top-level binding | span |
| `public-symbol` unresolved | the line or lines of its string in `__all__` | span |
| `architecture-component` module or package (`__init__.py`) | every import statement span in source order, a line included once | `null` |
| `config-key` TOML key | key line through end of value; a table header runs to the last non-blank, non-comment line before the next header | span |
| `config-key` env key | the key line plus continuation lines of a multi-line quoted value | span |
| `config-key` JSON Schema property | member name line through the end of its value | span |
| `config-key` YAML key | key line through the last non-blank, non-comment line of its value block | span |

`line_range` "span" means `{start, end}` from the first line of the first span to the last line of
the last span.

Reproduction notes for 900011 (Python, standard library only): decode with `bytes.decode("utf-8")`,
apply the same normalization steps, and split with `str.split("\n")`, never `str.splitlines()`,
which also splits on form feed and U+2028. Statement spans equal `stmt.lineno` through
`stmt.end_lineno`. Decorator start lines and the header `:` line come from the `tokenize` module,
because `ast` gives the decorator expression line (after `@`) and no line for the header colon.
Typer parameter spans equal `arg.lineno` through the larger of the annotation and default
`end_lineno`.

### Element identifier

`element_id` = `<kind>-` plus the lowercase hex SHA-256 of the UTF-8 bytes of
`canonical_json({"declaration": D, "kind": K, "path": P})` followed by one line feed, computed by
1020 `Get-DocsElementId` through `Get-DocsStableId` and `ConvertTo-DocsCanonicalJson`, which
delegates to `ConvertTo-DiscoveryCanonicalJson` (keys sorted by ordinal code point; only the quote,
the backslash and C0 controls escaped; a single trailing LF). Python reproduction:
`json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n"`; sort order
agrees because the three keys are ASCII letters.

### Other element fields 900011 reproduces

- `path`: the file holding the declaring site (`pyproject.toml` for a console script).
- `name`: last declaration segment for CLI, configuration and architecture kinds; the handler
  function name for a decorator route, otherwise the template; the symbol name for
  `public-symbol`.
- `parent_id`: `cli-option` to its command; a subcommand to its parent command; `null` otherwise.
- `line_range` and `source_sha256` per the span table.
- `properties` under the emission rules of `## Behavior` (array of `{name, value}`, names and
  shapes only).
- `analyzer_id`: the registry identifier (`python-cli`, `python-http`, `python-public-api`,
  `python-architecture`).

### `analysis_method` and method replacement

- Every 1022 element records `analysis_method: scanner`; 1022 registry rows declare the scanner
  method.
- For `python-cli`, `python-http`, `python-public-api` and `python-architecture`, the amended 1020
  registry selection returns the 900011 native row when its availability probe succeeds and the
  1022 scanner row otherwise; the native analyzer records `analysis_method: native`.
  `config-files` has no native row and stays scanner-only.
- `DocsInventory.psm1` calls the registry selection and does not choose methods itself, so 900011
  edits no 1022 file.

### Shared fixtures

- `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` (committed test data, read in
  place): `inputs` (path to source text; CRLF, CR and BOM cases expressed as JSON escapes),
  `expected_elements` (kind, path, declaration, element_id, name, parent declaration, line_range,
  source_sha256, properties, `analysis_method: scanner`) and `expected_diagnostics` (code, path,
  analyzer_id). It covers every classified form and every diagnostic row of the shared lexer,
  `python-cli`, `python-http`, `python-public-api` and `python-architecture` tables of
  `## Precision Limit`, plus `pyproject.toml` script tables. 900011's Python tests read it without
  editing it and add their own expectations for constructs the scanner reports as diagnostics.
- `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json` covers the `config-files`
  table and is scanner-only; 900011 does not use it.
- Golden identifiers and digests in both files are recorded once from an independent hash
  computation (not the code under test), with the computation recorded under
  `<FEATURE>/evidence/other/`.

## Decisions

### Orchestrator decisions on the research section 7 items (binding)

1. **Digest placement.** The declaration-lines digest is stored in element `source_sha256`; the
   whole-file digest stays in `inputs[].sha256`. 1023 compares pins against `source_sha256` as
   opaque values, so 1023 is unchanged.
2. **Severity of `env-file-not-captured`.** Emitted as a non-blocking `warning` through 1020
   `New-DocsDiagnostic` as specified today. 1022 does not depend on an `information` severity; a
   later remediation may switch it if the 1020 amendment adds one (coordinator item C2).
3. **Native-or-scanner selection.** The mechanism (a method field on registry rows, selection in
   `Select-DocsAnalyzerRegistration`, the method on `analyzers[]`) belongs to the 1020 amendment.
   1022 rows declare the scanner method in whatever field the amended row grammar defines; Phase 0
   verifies the field exists (coordinator item C3).
4. **Digest function ownership.** 1022 owns `Get-DocsDeclarationDigest` in `DocsSourceText.psm1`; it
   is the reference implementation that 900011 reproduces in Python. 1020 should not add a
   competing digest function (coordinator item C4).
5. **Path-or-glob matcher.** Implemented by 1022 as the exported pure function
   `Find-DocsPathOrGlobMatch` in `DocsSourceText.psm1` (exact, prefix plus `/`, case-sensitive glob,
   first match wins) for its own exclusion handling. 1023 and 1024 may import it rather than copy
   it, or the coordinator may move it to 1020 (coordinator item C5).
6. **Write boundary.** 1023's single-write-boundary test must allow `Context.WriteText` from
   `DocsInventory.psm1` for the snapshot (coordinator item C6).
7. **Scope exclusions.** External distribution dependencies and the optional import of an existing
   discovery inventory snapshot JSON are excluded from 1022 and recorded under `## Out of Scope` as
   deferred (coordinator item C7).
8. **Console-script root-name order.** The console-script name comes first when the root is
   attached, then a literal name, then the module dotted name. This replaces the withdrawn order
   (literal first) and prevents a duplicate root when a script is attached.

### Language-independent decisions carried from the withdrawn design

- **Analyzer identifiers** `python-cli`, `python-http`, `python-public-api`, `config-files`,
  `python-architecture` (epic `### Analyzer decisions from the first preparation of 1022`).
- **Console-script ownership.** `[project.scripts]`, `[project.gui-scripts]` and
  `[tool.poetry.scripts]` belong to `python-cli`; `config-files` owns `[tool.*]` keys, template env
  keys, JSON Schema `properties` and YAML keys.
- **Environment files.** Only `.env.example`, `.env.sample`, `.env.template` and `.env.dist` are
  read. Every other env-family file (`.env`, `.env.<other>`, `<name>.env`) is not read, not hashed
  and not passed to any analyzer. The docs profile has no opt-in for plain `.env` capture.
- **Size bound.** 1 MiB per input; aggregate bounds 50,000 inputs and 256 MiB per run, exceeding
  either exits 3 with no snapshot.
- **Non-intersecting `-Analyzer`.** An identifier whose analyzer produces none of the profile's
  selected element kinds exits 2 naming it.
- **Dynamic registration.** Non-literal names, computed prefixes and non-literal `__all__` yield a
  diagnostic; an unresolvable route prefix is rendered as `<dynamic>` so identity stays stable.
- **Command-reported usage errors.** `Invoke-DocsInventoryCommand` returns exit 2 with one
  `DOCS_CLI_ARGUMENTS` finding through `New-DocsCommandResult -ExitCode 2` for usage errors only it
  can detect (unknown or non-intersecting `-Analyzer`, invalid `-Revision`, non-relative
  `-Profile`); Phase 0 confirms the amended 1020 permits this.

### Design decisions from the PowerShell research

- Python extraction uses a `\G`-anchored regex tokenizer, a logical-line builder and per-framework
  token-sequence recognizers (rejected: per-line scanning, whole-text regular expressions, invoking
  a Python interpreter).
- TOML, YAML and JSON keys use bounded key scanners for a documented subset, and a position scanner
  for JSON run after `ConvertFrom-DocsJsonText` has validated the document; constructs outside the
  subset are deterministic diagnostics (rejected: `ConvertFrom-Json` alone, which gives no line
  positions; `System.Text.Json.Utf8JsonReader`, a by-reference struct; a third-party module, A8).

## Out of Scope

- External distribution dependencies as `architecture-component` elements (requirements files,
  `setup.cfg`, `[project] dependencies`, `tool.poetry.dependencies`). Deferred; coordinator item C7
  assigns them to a later child or drops them.
- The optional import of an existing discovery inventory snapshot JSON into
  `python-architecture`. Deferred; no mapping rule from discovery `component` records to docs
  declarations is stated. Coordinator item C7.
- The Python-native analyzer (900011), TypeScript and .NET analyzers (900004), the coverage ledger
  (1023), reference generation (1024), MCP tools (900007) and CI enforcement (900008).
- Class members as public symbols; recording the PowerShell or Python version in the snapshot;
  reading Git history (`-Revision` is recorded as supplied).

## Dependency on 1020

- The plan's Phase 0 runs on the epic integration branch `epic/documentation-estate-tooling-integration`
  before any 1022 file is created, and verifies that 1020 executed with the D3/D5 amendment:
  - every consumed function exists with the stated parameters: `ConvertFrom-DocsJsonText`,
    `ConvertTo-DocsCanonicalJson`, `ConvertTo-DocsJsonText`, `Get-DocsSha256Hex`,
    `Get-DocsBytesSha256Hex` (`DocsJson.psm1`); `New-DocsFinding`, `New-DocsCommandResult` (accepting
    exit code 2 from a command function), `Get-DocsOrderedFinding` (`DocsFinding.psm1`);
    `Test-DocsArtifactText`, `Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet` (`DocsSchema.psm1`);
    `Get-DocsElementKind`, `Test-DocsRelativePath`, `Test-DocsFullRevision`, `Get-DocsStableId`,
    `Get-DocsElementId`, `New-DocsSurfaceElement`, `ConvertFrom-DocsSurfaceElement`,
    `New-DocsDiagnostic` (`DocsSurface.psm1`); `Get-DocsAnalyzerRegistration`,
    `Test-DocsAnalyzerRegistration`, `Select-DocsAnalyzerRegistration`, `New-DocsCapturedInput`,
    `Invoke-DocsAnalyzer` (`DocsAnalyzerRegistry.psm1`); `ConvertFrom-DocsProfileText`
    (`DocsProfile.psm1`); the command context members `ReadText`, `ReadBytes`, `TestFile`,
    `ListFile`, `WriteText`, `UtcNow`, the in-memory test context in `Docs.TestSupport.psm1`, and
    the dispatch-table row form (`Invoke-DocsCommand.ps1`);
  - the snapshot schema `$defs/element` has `analysis_method` (`native` | `scanner`) and the
    amended registry row grammar has a method field;
  - `schemas/docs/v1/docs-command-envelope.schema.json` exists, and the envelope validation
    function (or the self-contained runtime copy for the `Test-Json` fallback) is identified;
  - the 1022 anchors exist in `DocsAnalyzerRegistry.psm1` and `Invoke-DocsCommand.ps1` (literal
    `1022` or placeholder `900003` label, recorded verbatim);
  - the diagnostic codes `New-DocsCapturedInput` emits for over-bound and undecodable input are
    recorded;
  - `.claude/lib/docs` has no declaration-digest function competing with `Get-DocsDeclarationDigest`.
- Any mismatch stops execution and is reported to the coordinator; the plan does not work around
  a missing or different 1020 contract.
- 1022 edits no 1020 file except the anchored row insertions in `DocsAnalyzerRegistry.psm1` and
  `Invoke-DocsCommand.ps1` (and their mirror copies) and the append to `pack-manifests/core.json`.

## Artifact Classification

Rule references: R1 = language-rule clause (1) of the epic `## Owner Directive: Implementation
Language` (pushed-down helpers and libs are PowerShell or bash); D = the epic `### Artifact classes
for this epic` rows for schema/configuration/data, test and documentation.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsSourceText.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonTokens.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonSyntax.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsTomlKeys.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonCliArgparse.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonCliClick.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonCliTyper.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerPythonCli.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonHttpSites.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerPythonHttp.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerPythonApi.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsYamlKeys.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsJsonSchemaKeys.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerConfigFiles.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerArchitecture.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsInventorySnapshot.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsInventory.psm1` | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (edit: rows under the 1022 anchor) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row under the 1022 anchor) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` copies of every created or edited file above | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit: append) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/<Module>.Tests.ps1` (one per new module) and `DocsInventoryProperties.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json`, `config-surface-corpus.json` | test (fixture data) | JSON | D |
| `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/**` (spec, user story, plan, research, evidence) | documentation | Markdown | D |

No Python, TypeScript, hook, skill, agent, MCP tool or extension command file is created or
edited. The plan carries this table and adds a row for any file it introduces (for example a module
split), with the same class and rule.

## Owner Questions

None. Every artifact follows the language rule: all logic is PowerShell under `.claude/lib/docs/`,
and the Python-native analyzer permitted by D3 is delivered by 900011, not by this feature.

## Coordinator Items

| ID | Route to | Item |
|---|---|---|
| C1 | 1020 | State in the amendment that element `source_sha256` carries the declaration-lines digest and `inputs[].sha256` the whole-file digest (decision 1). |
| C2 | 1020 | If the amendment adds an `information` severity to `New-DocsDiagnostic`, a later remediation may switch `env-file-not-captured` to it; 1022 does not depend on it (decision 2). |
| C3 | 1020 | The native-or-scanner selection mechanism (method field on registry rows, per-identifier selection in `Select-DocsAnalyzerRegistration`, method on `analyzers[]`) belongs to the amendment; 1022 rows declare the scanner method in that field (decision 3). |
| C4 | 1020 | Do not add a declaration-digest function; 1022's `Get-DocsDeclarationDigest` is the reference implementation (decision 4). |
| C5 | 1023, 1024 (or 1020) | `Find-DocsPathOrGlobMatch` (exact, prefix plus `/`, case-sensitive glob with `*`, `**`, `?`, first match wins) is exported by 1022's `DocsSourceText.psm1`; 1023 and 1024 may import it instead of copying it, or the coordinator may move it to 1020 (decision 5). |
| C6 | 1023 | The single-write-boundary test must allow `Context.WriteText` from `DocsInventory.psm1` for the snapshot (decision 6). |
| C7 | epic | Assign external distribution dependencies and the optional discovery-snapshot import to a later child, or drop them (decision 7). |
| C8 | 1020 | Confirm that a command function may return exit 2 with one `DOCS_CLI_ARGUMENTS` finding for usage errors only the command can detect, and that the registry and dispatch anchors carry the label `1022` (placeholder `900003` in the current text). |
| C9 | 1020 | Name the diagnostic codes `New-DocsCapturedInput` emits for over-bound and undecodable input (proposed `input-over-bound`, `input-encoding-invalid`). |
| C10 | 1023 | Record the `## Precision Limit` of this spec as one `deferred` ledger entry with an owner and a target per scanner analyzer, carrying `analysis_method: scanner`. |
| C11 | 900011 | Reproduce `## Contracts for 900011 and Later Children` exactly and reuse `python-surface-corpus.json` without editing it. |

## Constraints & Risks

- The epic naming contract is fixed; this feature does not change it.
- The language rule binds every file: pushed-down logic is PowerShell under `.claude/lib/docs/`; no
  new third-party PowerShell module (A8); no call to the Python discovery runtime (A7).
- Lexical scanning is less precise than a parser. Every limit is a deterministic diagnostic or a
  listed undetectable construct (`## Precision Limit`), recorded by 1023 as `deferred`.
- Execution depends on 1020 merging into the integration branch with the D3/D5 amendment
  (`## Dependency on 1020`).
- Append-only conflicts in `DocsAnalyzerRegistry.psm1` (900004, 900011), `Invoke-DocsCommand.ps1`
  (1021, 1023, 1024, 900008) and `core.json` are resolved inside 1022's remediation loop.
- Performance: a character loop in PowerShell would be slow on 1 MiB inputs; the lexer advances by
  whole regex matches, and size-bound tests use one comment or key line so a single match consumes
  it.
- Case sensitivity: PowerShell defaults are case-insensitive (`-eq`, `-like`, `-contains`, `@{}`
  keys); every 1022 module uses case-sensitive operators, ordinal dictionaries and ordinal sorting.
- CI-only behavior: CI runs Pester on `windows-latest` with the runner's PowerShell and `Test-Json`
  version and checks out with `eol=lf`; tests build CRLF cases in code or JSON escapes and assert
  codes and pointers, not `Test-Json` message text.
- UNVERIFIED and confirmed during planning: every amended-1020 contract; the `New-DocsCapturedInput`
  diagnostic codes; the Typer lower-casing rule, the Flask prefix join and the Click suffix list;
  `Test-Json` behavior for the envelope schema on the CI PowerShell version.

## Implementation Strategy

- Phase 0: verify 1020 (`## Dependency on 1020`); stop on mismatch.
- Build order: `DocsSourceText.psm1`; lexer and syntax; TOML, YAML and JSON key scanners; the
  per-framework site modules and the five analyzers; `DocsInventorySnapshot.psm1`;
  `DocsInventory.psm1`; registry and dispatch rows; fixtures and golden vectors; mirror copies and
  `core.json`.
- Execution runs in the item worktree under the batch-budget-exempt route, because the feature
  creates more than three production files.
- Error handling: pure functions return diagnostics for source-text conditions and throw only for
  contract violations by the caller; the command converts unexpected exceptions to exit 3 through
  the 1020 entry boundary.
- Logging/telemetry: none beyond findings and diagnostics.
- Rollout: the subcommand is new; no flag or staged rollout.

### Testing

- Location: Pester suites under `tests/scripts/claude-lib/docs/`, one `<Module>.Tests.ps1` per new
  module plus `DocsInventoryProperties.Tests.ps1`, following `tests/scripts/claude-lib/mermaid/`.
  `config/poshqc-scan.json` and `config/poshqc-coverage.json` already discover and measure them and
  do not change.
- No temporary files: analyzers receive captured-input records built by `New-DocsCapturedInput`
  from in-test strings; the command suite uses 1020's in-memory context from
  `Docs.TestSupport.psm1`; the two corpus files are committed JSON read in place. No `TestDrive`,
  `New-TemporaryFile`, temp path or `$env:TEMP` (enforced by
  `.claude/hooks/check-powershell-test-purity.ps1`).
- Line endings: CRLF and CR cases are built in test code with `` "`r`n" `` and `` "`r" `` or stored
  as JSON escapes, never as committed CRLF files.
- Property-style tests: at least one per pure exported function, each with a seeded
  `[System.Random]` whose seed is printed in the failure message. Covered properties include
  determinism of repeated calls; byte-identical snapshots under permuted input order and repeated
  builds with a fixed clock; `element_id` equal to `Get-DocsElementId` of its fields; digest
  invariance under trailing-newline presence and CRLF/LF/CR variants; digest change when a line
  inside the span changes and no change when a line outside it changes; value redaction with marker
  values in every value position; key-path quoting injectivity; the size bound at 1,048,575,
  1,048,576 and 1,048,577 bytes.
- Every diagnostic row of `## Precision Limit` has a test asserting the code, the blocking flag and
  severity, the stated effect, and the survival of classified sites in the same input for
  site-level rows.
- Envelope: the command suite asserts that the `-Json` output of every exit path validates against
  `schemas/docs/v1/docs-command-envelope.schema.json`.
- Isolation: suites import modules with `-Force` and remove them in `AfterAll`; seeded shuffled
  single-process runs and a fresh single-process run over `tests/scripts` are recorded under
  `<FEATURE>/evidence/regression-testing/`.
- CI: the shard jobs `poshqc / PowerShell QC shard 1` to `poshqc / PowerShell QC shard 3`
  (`_poshqc.yml`, `runs-on: windows-latest`, `Invoke-PoshQCTest -ShardIndex -ShardCount`) run the
  suites with coverage; the required check `poshqc / PowerShell QC` aggregates them. Line coverage of
  at least 85% per new file is read from `artifacts/pester/powershell-coverage.xml`; no branch gate
  applies to Pester; no production file is excluded.
- Additional checks in the final loop: `enforcement-hooks-no-python-invocation.Tests.ps1`,
  `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, 1020's `Docs.Manifest.Tests.ps1`,
  and the push-down contract tests `test_push_down_claude_resource_contracts.py`,
  `test_push_down_claude_pack_manifest_completeness.py` and
  `test_push_down_pack_manifest_dependency_closure.py` (existing tests, run, not edited).

## Acceptance Criteria

- [ ] Each of the five analyzers (`python-cli`, `python-http`, `python-public-api`, `config-files`, `python-architecture`) emits exactly the expected elements (kind, path, declaration, `element_id`, name, `parent_id`, `line_range`, `source_sha256`, properties) for in-memory fixtures covering the nine input families argparse, Click, Typer, FastAPI, Flask, `pyproject.toml`, `.env` (template-style), JSON Schema and YAML, asserted by Pester suites under `tests/scripts/claude-lib/docs/` that read `fixtures/python-surface-corpus.json` and `fixtures/config-surface-corpus.json` in place.
- [ ] `python-cli` tests assert argparse nested subcommands and positional arguments, Click group and command naming including suffix removal, Typer explicit and default names, console-script entries from `[project.scripts]`, `[project.gui-scripts]` and `[tool.poetry.scripts]` with the console-script name used as the root of an attached command tree, `attached: false` for an unattached script, and a `cli-command` parent for every `cli-option`.
- [ ] `python-http` tests assert FastAPI `include_router` and router prefix composition, Flask `url_prefix` joining and replacement, one element per method, and that an unresolvable prefix yields a route declared with the literal `<dynamic>` segment, property `prefix_resolved: false` and an `http-prefix-dynamic` diagnostic.
- [ ] `python-public-api` tests assert the literal `__all__` forms (assignment, annotated assignment, `+=`, `extend`, `append`), the naming rule when `__all__` is absent, exclusion of `_`-prefixed modules and names, and the `public-api-dynamic-all` fallback with `basis: naming`; `python-architecture` tests assert package and module components and internal import edges (including relative imports) stored as `import_count` plus ordinally sorted `import-NNNN` properties, and that no external-dependency component is emitted.
- [ ] Every diagnostic row of `## Precision Limit` has a Pester test asserting its code, severity and blocking flag, its stated effect (no element for the site, no element for the file, or the stated alternative), and, for site-level rows, that classified sites in the same input still produce their elements.
- [ ] An input of 1,048,577 bytes yields the 1020 over-bound diagnostic with no element and no `inputs` entry for that path while 1,048,576 bytes is accepted, and a Python input containing an unclassifiable construct yields `python-lexer-unclassified` with no element from that file, so no partial or guessed result is produced.
- [ ] Re-running the inventory over identical bytes, profile, revision, analyzer selection and clock value produces a byte-identical snapshot, proven by a seeded property test in `DocsInventoryProperties.Tests.ps1` that permutes the order of `Context.ListFile` results and repeats builds, printing the seed on failure.
- [ ] No configuration value is exported: a seeded property test places marker values in every value position of TOML, template env, JSON Schema (including `default`, `enum`, `const`, `examples`) and YAML inputs and asserts that no marker appears in the snapshot text and that element properties carry only key and shape names.
- [ ] A non-template env-family file (`.env`, `.env.<other>`, `<name>.env`) under a source root is never passed to `Context.ReadBytes` (asserted by the in-memory context's call record), has no `inputs` entry and no element, and yields an `env-file-not-captured` non-blocking `warning` naming its path; only `.env.example`, `.env.sample`, `.env.template` and `.env.dist` produce `config-key` elements.
- [ ] The built fixture snapshot validates against `surface-inventory-snapshot.schema.json` through `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'` with no `error` finding, and each `inputs[].sha256` equals the SHA-256 of the corresponding whole-file fixture bytes with `size` equal to their length.
- [ ] Every element in every snapshot produced by the Pester suites records `analysis_method: scanner`, and every 1022 registry row declares the scanner method in the field defined by the amended registry row grammar.
- [ ] Every element's `source_sha256` equals `Get-DocsDeclarationDigest` over the spans defined in `## Contracts for 900011 and Later Children`, and a seeded property test asserts that changing any line inside an element's span changes its digest, changing a line outside every span leaves it unchanged, and CRLF, CR, LF and trailing-newline variants leave it unchanged.
- [ ] The golden `element_id` and `source_sha256` values in both corpus files were recorded from an independent hash computation documented under `<FEATURE>/evidence/other/`, and `python-surface-corpus.json` covers every classified form and every diagnostic row of the shared lexer, `python-cli`, `python-http`, `python-public-api` and `python-architecture` tables.
- [ ] `inventory` exits 0 for a fixture with no blocking diagnostic, 1 with a blocking diagnostic or an invalid or absent profile, 2 for an unknown `-Analyzer` identifier, an identifier with no selected element kind, an invalid `-Revision` or a non-relative `-Profile` (each with a `DOCS_CLI_ARGUMENTS` finding naming the value and `result` `null`), and 3 for an exceeded aggregate bound or a read failure (with `DOCS_CLI_RUNTIME`), each asserted through `Invoke-DocsCommandCli` with the 1020 in-memory context and a fixed clock.
- [ ] The `-Json` output of every `inventory` exit path (0, 1, 2 and 3) validates against `schemas/docs/v1/docs-command-envelope.schema.json`, asserted by the command suite.
- [ ] Without `-Write` the command makes no `Context.WriteText` call; with `-Write` it makes one `Context.WriteText` call to the profile `artifact_paths.inventory_snapshot` with mode `create` when the file is absent and `overwrite` when it exists; `DocsInventory.psm1` is the only 1022 module that references the command context.
- [ ] The five analyzer rows sit directly under the 1022 anchor of `DocsAnalyzerRegistry.psm1` and the `inventory` row under the 1022 anchor of `Invoke-DocsCommand.ps1`; a diff of the 1022 branch against the integration branch shows no other changed line in those files and no change to any other 1020 file except the `core.json` append; `Test-DocsAnalyzerRegistration` and `Test-DocsCommandTable` return no finding.
- [ ] Every created or edited `.claude/lib/docs/` file has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, every new file is listed in `pack-manifests/core.json` and none in `pack-manifests/python.json`, and `Docs.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] No file under `.claude/lib/docs/` contains an interpreter invocation or an `&` call through a variable, member or expression: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with its empty allowlist.
- [ ] Every pure exported function listed in the `## API / CLI Surface` module layout has at least one property-style Pester test using a seeded `[System.Random]` whose seed appears in the failure message.
- [ ] A fixture whose Python names differ only by letter case (for example `App` and `app`) yields distinct elements, and snapshot ordering equals ordinal ordering on a host whose culture sorts those strings differently.
- [ ] Pester line coverage is at least 85% for each new `.claude/lib/docs/` file, read from `artifacts/pester/powershell-coverage.xml` produced by the `poshqc / PowerShell QC shard` jobs on `windows-latest` and aggregated by the required check `poshqc / PowerShell QC`, with no production file excluded from measurement.
- [ ] No new test creates a temporary file (`.claude/hooks/check-powershell-test-purity.ps1` reports no violation), CRLF and CR cases exist only as JSON escapes or in-code strings, and every new production file is below 500 lines.
- [ ] The plan's artifact classification table lists every created or edited file with its class, language and permitting rule, and a diff of the 1022 branch against the integration branch contains no Python, TypeScript, hook, skill, agent, MCP tool or extension command file.
- [ ] Phase 0 evidence under `<FEATURE>/evidence/other/` records, before any 1022 production file is created, the verification of every item in `## Dependency on 1020`.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: each analyzer, the shared lexer and key scanners, snapshot builder, size bound, value redaction, declaration-lines digest, the `inventory` command.
- [ ] Integration scenarios: snapshot validates against the inventory snapshot schema; `-Json` envelope validates against the envelope schema.
- [ ] CLI/API examples: `Invoke-DocsCommand.ps1 -Command inventory -Analyzer <id>`.
