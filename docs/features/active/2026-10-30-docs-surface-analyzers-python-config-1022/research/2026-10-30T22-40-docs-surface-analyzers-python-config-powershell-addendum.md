# docs-surface-analyzers-python-config (Issue #1022) - PowerShell Design Addendum Research

- Feature: child 1022 of epic #1019 (documentation-estate-tooling), wave 1, band C4; depends on 1020.
- Branch: `feature/docs-surface-analyzers-python-config-1022`.
- Planning cycle: new cycle under owner decision D1 (fresh allowance of one planner revision and the single-pass preflight).
- Mode: preparation research only. No source, configuration or test file was changed.
- Supersedes: every Python-package statement in `research/2026-10-30T20-47-docs-surface-analyzers-python-config-research.md`, `spec.md`, `user-story.md` and `plan.2026-10-30T16-46.md` of this folder (module paths under `packages/docs-runtime`, `ast`, `tomllib`, discovery Python reuse, `dev.docs.inventory`, Pytest, Black, `analyzer_contract.py`, `pyproject.toml` edits). Those files describe the withdrawn design; this addendum is the design source for the re-prepared spec and plan.
- Sources read in full: `docs/features/epics/documentation-estate-tooling/epic.md`; 1020 `spec.md` (version 0.3); this folder's `issue.md`, `spec.md`, earlier research and plan headings; `.claude/skills/execution-environment/SKILL.md`.
- Citation convention: "verified" means read on this branch; "planned by 1020" means stated in the 1020 spec and absent from the tree; "amended 1020" means stated by the epic `### Amendment of 1020 required by D3 and D5` and not yet present in the 1020 spec; "proposal" means introduced here.

## 1. Current State Analysis

### 1.1 Upstream state on this branch (verified)

- `.claude/lib/docs/` does not exist (glob `.claude/lib/docs/**` returned no file). Every 1020 symbol below is planned, not delivered. The 1022 plan depends on 1020 executing and merging into `epic/documentation-estate-tooling-integration` with the D3/D5 amendment applied (section 4.8).
- 1020 spec `### Module conventions`: pure functions take strings and hashtables; command modules never write output or call `exit`; every `$PSScriptRoot` use is the literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'`; conventions pinned by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (verified present).
- 1020 symbols 1022 consumes (planned by 1020): `ConvertFrom-DocsJsonText`, `ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex` (`DocsJson.psm1`); `New-DocsFinding`, `New-DocsCommandResult`, `Get-DocsOrderedFinding` (`DocsFinding.psm1`); `Test-DocsArtifactText`, `Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet` (`DocsSchema.psm1`); `Get-DocsElementKind`, `Test-DocsRelativePath`, `Test-DocsFullRevision`, `Get-DocsStableId`, `Get-DocsElementId`, `New-DocsSurfaceElement`, `ConvertFrom-DocsSurfaceElement`, `New-DocsDiagnostic` (`DocsSurface.psm1`); `Get-DocsAnalyzerRegistration`, `Select-DocsAnalyzerRegistration`, `New-DocsCapturedInput`, `Invoke-DocsAnalyzer` (`DocsAnalyzerRegistry.psm1`); `ConvertFrom-DocsProfileText` (`DocsProfile.psm1`); the command context members `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow` and the dispatch-table row form (`Invoke-DocsCommand.ps1`).
- Analyzer function contract (1020 spec `### DocsAnalyzerRegistry.psm1`): `Invoke-DocsAnalyzer<Name> -CapturedInput <object[]> -Selection <object>` returns `@{ Elements = @(...); Diagnostics = @(...) }`; pure; an unclassifiable or oversize input yields a diagnostic rather than a partial result. `Test-DocsAnalyzerRegistration` requires a `Module` leaf `DocsAnalyzer*.psm1` inside `.claude/lib/docs/` and a `Function` matching `^Invoke-DocsAnalyzer[A-Za-z]+$`.
- `New-DocsCapturedInput -Path -Bytes [-MaxBytes]` returns `@{ path; sha256; size; text; diagnostic }` with strict UTF-8 decoding; an oversize or undecodable input carries a diagnostic and `text` `$null`. The diagnostic codes it uses are not named in the 1020 spec (UNVERIFIED; section 7).

### 1.2 Conflicts between the current 1020 spec text and the epic amendment (verified by reading both)

| # | 1020 spec text (version 0.3) | Epic amendment or later decision | Consequence for 1022 |
|---|---|---|---|
| K1 | Registry and dispatch anchors use placeholders: `# --- 900003: Python and configuration analyzers ---`, `# --- 900003: inventory ---`, `# --- 900006: generate-reference ---` | Placeholder 900003 is issue 1022 and 900006 is 1024 (epic manifest `features`) | The plan names the anchor by the literal text the executed 1020 carries; Phase 0 reads it and stops if neither the `1022` nor the `900003` label exists. |
| K2 | Registry carries 900003 and 900004 anchors only | Amendment adds a 900011 anchor in `DocsAnalyzerRegistry.psm1` | 1022 inserts rows under its own anchor only and never touches the 900011 anchor. |
| K3 | `-Json` envelope "has no schema file" (`#### Exit codes and the -Json envelope`) | D5: `schemas/docs/v1/docs-command-envelope.schema.json` | 1022 tests validate the `inventory` envelope against that schema through whatever validation function the amended 1020 exposes (section 4.7). |
| K4 | Snapshot `$defs/element` is closed and has no `analysis_method` | Amendment adds `analysis_method` (`native` or `scanner`) on inventory elements | 1022 sets `analysis_method: scanner` on every element (section 4.5). |
| K5 | Element `source_sha256` is described only as `sha256` | D5: an element digest covers the declaration's source lines, not the whole file | Proposal: the amended field carries the declaration-lines digest, and the whole-file digest stays in `inputs[].sha256` (section 4.4). 1023 compares pins against element `source_sha256` (1020 `### Artifact schema: docs-evidence-pin`), so this placement keeps 1023 unchanged. |
| K6 | `New-DocsDiagnostic` sets severity `error` when blocking, otherwise `warning`; no `information` | Epic `### Analyzer decisions from the first preparation of 1022`: non-template env files "produce one informational diagnostic"; the docs `diagnostic` schema allows `information` | Either the amended 1020 adds a `-Severity` parameter, or 1022 emits these diagnostics as non-blocking `warning`. Item for the orchestrator (section 7). |
| K7 | `Invoke-DocsCommand.ps1` exit-2 rule: usage errors are detected by `ConvertFrom-DocsCommandArgument` before the command function runs | 1022 needs exit 2 for an unknown `-Analyzer` identifier and a malformed `-Revision`, which only the command knows | `New-DocsCommandResult -ExitCode` accepts 2, so the command function returns exit 2 with one `DOCS_CLI_ARGUMENTS` finding; preflight confirms the amended 1020 allows this. |

## 2. Candidate Approaches

### 2.1 Python surface extraction in PowerShell

Selected: **a regex-anchored tokenizer (`\G` alternation over a compiled `[regex]`) producing a flat token list, a logical-line builder over that list, and per-framework site recognizers that match token sequences.** Every token carries line and column, so declaration line spans and the digest come directly from tokens. Advancing by whole regex matches keeps a 1 MiB input to a bounded number of match calls; a character loop in PowerShell would be slow enough to push single unit tests past the brief's 10-second line (`## Test Runtime`).

Rejected: per-line scanning in the style of `Get-MermaidLineScan` alone (Python strings, brackets and backslash continuations span lines, so a line scanner cannot find statement boundaries); regular expressions applied to whole source text (cannot separate strings, comments and nested calls); invoking a Python interpreter (forbidden for the baseline by the language rule and by `enforcement-hooks-no-python-invocation.Tests.ps1`; reserved for 900011 under D3).

### 2.2 TOML, YAML and JSON key extraction without new modules (A8)

Selected: **bounded key scanners for a documented TOML and YAML subset, and a position scanner for JSON run after `ConvertFrom-DocsJsonText` has validated the document.** Every construct outside the subset is a deterministic diagnostic with no elements for that input (section 3). No owner question is raised under A8, because the scanners work within the recorded precision limit.

Rejected: `ConvertFrom-Json` or `ConvertFrom-DocsJsonText` alone for JSON Schema (neither returns line positions, which the declaration digest needs); `System.Text.Json.Utf8JsonReader` (a by-reference struct, which PowerShell cannot hold in a variable; UNVERIFIED by probe on this branch, preflight confirms); a third-party YAML or TOML module (A8).

## 3. Precision Limit (Behavior Semantics)

This section is the complete, deterministic list the coverage ledger (1023) records as the scanner's `deferred` entry with an owner. Each construct is in exactly one of three classes: **classified** (produces elements), **diagnostic** (produces the named diagnostic and no element for that site or input), or **undetectable** (no element and no diagnostic; listed in section 3.8 so the ledger entry names it).

Diagnostic rules common to every analyzer:

- Codes use the identifier grammar of `schemas/discovery/v2/common.schema.json` `$defs/identifier` (verified: `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`), which the docs `diagnostic.code` inherits (1020 `### Docs common $defs`; discovery `inventory-snapshot.schema.json` `$defs/diagnostic` verified).
- `New-DocsDiagnostic` derives `id` from `{analyzer, code, path}`, so at most one diagnostic exists per code, path and analyzer. The message states the occurrence count and the first line number and never quotes source text or values.
- Severity: "blocking" diagnostics are `error`; all others are non-blocking `warning` (or `information` if K6 is resolved that way).
- "Site" means one registration call, decorator or binding; "input" means the whole file. Statically classifiable sites in an input still produce elements when another site in the same input yields a site-level diagnostic. An input-level diagnostic removes every element of that input.

### 3.1 Shared Python lexer (`DocsPythonTokens.psm1`, `DocsPythonSyntax.psm1`)

Classified: UTF-8 source with an optional BOM; a PEP 263 cookie naming `utf-8`, `utf8` or `utf_8` (case-insensitive) on line 1 or 2; every Python token class listed in section 4.2; tab indentation expanded to the next multiple of 8; Unicode identifiers.

| Construct | Code | Level | Blocking |
|---|---|---|---|
| Bytes that are not strict UTF-8 (1020 `New-DocsCapturedInput`) | code owned by 1020 (proposal `input-encoding-invalid`) | input | yes |
| Input above 1 MiB (1020 `New-DocsCapturedInput -MaxBytes 1048576`) | code owned by 1020 (proposal `input-over-bound`) | input | yes |
| A coding cookie naming any other encoding | `python-encoding-unsupported` | input | yes |
| Unterminated single-, double- or triple-quoted string, unbalanced bracket, or backslash continuation at end of input | `python-lexer-unterminated` | input | yes |
| A character outside the token grammar outside strings and comments (for example `$`, `?`, backtick), bracket depth above 64, or f-string replacement fields nested more than two levels | `python-lexer-unclassified` | input | yes |
| More than 262,144 tokens in one input | `python-token-limit` | input | yes |
| A dedent to a column not on the indentation stack | `python-indentation-invalid` | input | yes |
| A declaration-forming identifier containing a non-ASCII character (the scanner applies no NFKC normalization, while the Python parser does) | `python-identifier-non-ascii` | site | no |
| A string in a declaration position that is a bytes or f-string, carries a backslash in a non-raw string, or is implicitly concatenated with such a part | the owning analyzer's dynamic code (3.2 to 3.5) | site | no |
| `from <framework> import *` where `<framework>` is `argparse`, `click`, `typer`, `fastapi` or `flask` | `python-import-star-framework` | site | no |
| A framework module imported inside a `def` or `class` body | `python-import-nested-framework` | site | no |
| An import alias or tracked receiver name bound to two different targets in one input | `python-binding-ambiguous` | site | no |

Import alias table (classified): `import m`, `import m as a`, `import m.sub`, `from m import n`, `from m import n as a`, parenthesized multi-line `from` imports, at indentation 0 or inside top-level `if`, `elif`, `else`, `try`, `except` and `finally` blocks. Receiver tracking (classified): `NAME = <constructor>(...)` and `NAME: T = <constructor>(...)` at any indentation, flow-insensitive per input.

### 3.2 `python-cli` (argparse, Click, Typer, console-script tables)

Classified:

- argparse: `ArgumentParser(...)` through the alias table (literal `prog=`); `S = P.add_subparsers(...)`; `C = S.add_parser("name", ...)` nested to any depth; `P.add_argument("--long", "-s", ...)` and positional `P.add_argument("name")`; `add_argument_group` and `add_mutually_exclusive_group` receivers mapped to their parser; literal `required=`, `action=`, `help=`.
- Click: `@click.command`, `@click.group` with or without parentheses (alias-aware, including `from click import command`); `@G.command(...)` and `@G.group(...)` on a tracked group function; `G.add_command(F)` and `G.add_command(F, name="x")` with `F` a tracked command function; `@click.option(...)` and `@click.argument(...)` on the same function.
- Typer: `typer.Typer(...)` (literal `name=`); `@app.command(...)`; `@app.callback(...)`; `app.add_typer(sub, name="x")`; `typer.run(func)`; parameters declared with `typer.Option(...)` or `typer.Argument(...)` as a default or inside `Annotated[...]`, a plain default (option), or no default (argument).
- Console scripts: entries of `[project.scripts]`, `[project.gui-scripts]` and `[tool.poetry.scripts]` whose value is a one-line basic or literal string `module.path:attr`.

| Construct | Code | Level |
|---|---|---|
| Non-literal command name, option string or argument name (variable, f-string, escaped string, concatenation with a non-literal, `*args`, `**kwargs`) | `cli-dynamic-registration` | site |
| A registration site inside a `for` or `while` body or a comprehension | `cli-registration-in-loop` | site |
| `.add_argument(`, `.add_parser(`, `.add_subparsers(`, `.add_command(`, `.add_typer(`, or a `@X.command`, `@X.group`, `@X.callback` decorator on a receiver that is not tracked in the input (function parameter, attribute such as `self.parser`, call result) | `cli-unbound-registration` | site |
| `parents=[...]` on `ArgumentParser` or `add_parser` | `cli-parents-unresolved` | site |
| Click `cls=`, constructed `click.Group(...)`, `click.Command(...)`, `click.CommandCollection(...)`, lazy or plugin groups, Typer `cls=` | `cli-custom-class` | site |
| A decorator name bound in the input to a framework call or a list of them (shared option decorators), or a decorator applied by call (`click.command()(f)`) | `cli-decorator-indirect` | site |
| A Typer parameter whose default or annotation is not one of the classified forms | `cli-typer-parameter-unresolved` | site |
| A script-table entry that is not a one-line string (Poetry inline-table form, multi-line string) or whose key is a quoted key with escapes | `cli-console-script-unsupported` | site |

Rules that are not limits (both scanner and native apply them): argparse `aliases=` are not emitted; generated `--help`, `--version` and `--no-x` options are not emitted; an unattached console script keeps property `attached: false`.

### 3.3 `python-http` (FastAPI, Flask)

Classified: `FastAPI(...)`, `APIRouter(prefix="/x")`, `Flask(...)`, `Blueprint("name", __name__, url_prefix="/x")` receivers; FastAPI `.get .post .put .patch .delete .options .head .trace` decorators with a literal path, `.api_route(path, methods=[...])`, `.add_api_route(path, endpoint, methods=[...])`, `.websocket(path)`, `.include_router(router, prefix="/y")`; Flask `.route(path, methods=[...])`, `.get .post .put .patch .delete` shortcuts, `.add_url_rule(path, ..., methods=[...])`, `.register_blueprint(bp, url_prefix="/y")`; cross-input mount resolution through the alias table (`from pkg.mod import router`, `from . import mod` then `mod.router`).

| Construct | Code | Level |
|---|---|---|
| Non-literal route path or method list | `http-dynamic-route` | site |
| Non-literal mount or router prefix (route still emitted with the literal segment `<dynamic>` and property `prefix_resolved: false`) | `http-prefix-dynamic` | site |
| A route registration inside a `for` or `while` body or a comprehension | `http-route-in-loop` | site |
| `.mount(...)`, or `include_router`/`register_blueprint` of a router that is not a tracked receiver in the inputs (module outside the inputs, attribute chain, call result) | `http-mount-unresolved` | site |
| A decorator on an untracked receiver whose first argument is a literal string beginning with `/` | `http-unbound-route` | site |
| `add_url_rule(..., view_func=X.as_view(...))` without literal `methods`, and class-based route helpers | `http-method-view-unresolved` | site |
| A router inclusion cycle, or composition depth above 16 (routes keep their own prefix with `mounted: false`) | `http-include-unresolved` | site |

### 3.4 `python-public-api`

Classified: module qualified name from the path relative to the containing `surface_selection.source_roots` entry; literal `__all__` forms at indentation 0 in statement order (`__all__ = [...]` or `(...)` of plain strings, `__all__: list[str] = [...]`, `__all__ += [...]`, `__all__.extend([...])`, `__all__.append("x")`); when `__all__` is absent, the naming rule: top-level `def`, `async def`, `class`, and simple or chained `NAME =`, `NAME: T =`, `NAME: T` targets not beginning with `_`, including inside top-level `if`, `try`, `except`, `else` and `finally` bodies. A module with a path segment beginning with `_` (other than `__init__`) is not public and yields nothing.

| Construct | Code | Level |
|---|---|---|
| `__all__` built by concatenation, comprehension, `list(...)`, star-unpacking, a non-literal element, or modified inside a function, loop, or top-level `if`/`try` block (fallback: naming rule, property `basis: naming`) | `public-api-dynamic-all` | input (fallback, not removal) |
| A name in `__all__` with no top-level binding (element kept, `symbol_kind: unresolved`) | `public-api-name-unresolved` | site |
| `from x import *` at top level in a module with a literal `__all__` | `public-api-star-import` | input (informative) |
| One name defined in several top-level branches (first by line is emitted) | `public-api-conditional-definition` | site |
| Tuple or list unpacking target at top level | `public-api-unpacking-target` | site |
| A path segment that is not a Python identifier | `public-api-module-not-importable` | input |

### 3.5 `python-architecture`

Classified: a package component per directory holding `__init__.py` among the inputs; a module component per `*.py` input; internal import edges from `Import` and `ImportFrom` statements at any indentation (including `TYPE_CHECKING` blocks), relative imports resolved against the module's package, longest dotted-prefix match against input modules and packages; edges stored as `import_count` plus `import-0001`, `import-0002`, ... in sorted order, bound 1000 per component.

| Construct | Code | Level |
|---|---|---|
| `importlib.import_module(`, `__import__(`, `importlib.util.spec_from_file_location(` (not followed) | `architecture-dynamic-import` | site |
| A relative import that climbs above the source root or appears in a module outside any package | `architecture-relative-import-unresolved` | site |
| More than 1000 edges on one component (count kept, edges dropped) | `architecture-edge-limit` | site |
| A path segment that is not a Python identifier (no component) | `architecture-module-name-invalid` | input |

Rules that are not limits: PEP 420 namespace directories are not package components; external distribution dependencies are out of scope for 1022 (the epic 1022 file list names packages, modules and import edges only).

### 3.6 `config-files`

Key-path declaration quoting (all formats): a segment matching `^[A-Za-z0-9_-]+$` stays bare; any other segment is a TOML basic string with `"` and `\` escaped; arrays contribute the segment `[]`. Values are never retained; properties carry only shape names (`value_type`, `schema_type`, `required`, `conditional`, `format`).

TOML (`pyproject.toml` by basename; keys under `tool.*` except `tool.poetry.scripts` and the dependency subtrees `tool.poetry.dependencies`, `tool.poetry.dev-dependencies`, `tool.poetry.group.*.dependencies`, `tool.poetry.extras`). Classified: comments; `[table]` and `[[array.of.tables]]` headers with bare, quoted and dotted keys; `key = value` with bare, quoted and dotted keys; values skipped by extent (basic, literal, multi-line basic and multi-line literal strings, arrays spanning lines with comments, one-line inline tables, numbers, booleans, date-times).

| Construct | Code | Level | Blocking |
|---|---|---|---|
| Unterminated string or array, malformed header, key without `=`, duplicate key or table redefinition, multi-line inline table (TOML 1.1) | `toml-invalid` | input | yes |
| Inline-table value (the key is emitted with `value_type: table`; inner keys are not) | `toml-inline-table-not-expanded` | site | no |
| A quoted key containing a backslash escape | `toml-key-escape-unsupported` | site | no |

Environment templates (`.env.example`, `.env.sample`, `.env.template`, `.env.dist` only). Classified: blank and `#` lines; optional `export ` prefix; key grammar `^[A-Za-z_][A-Za-z0-9_]*$` before `=`; a quoted value that does not close on its line consumes lines until the closing quote.

| Construct | Code | Level | Blocking |
|---|---|---|---|
| Any other env-family file (`.env`, `.env.<other>`, `<name>.env`): not read, not hashed | `env-file-not-captured` (emitted by `docs-inventory`) | input | no (`information` if K6 allows) |
| A line that is not blank, a comment or a key line | `env-line-unrecognized` | site | no |
| A quoted value still open at end of input | `env-invalid` | input | yes |
| A key repeated (first kept) | `env-key-duplicate` | site | no |

JSON Schema (basename ending `.schema.json`, or a `.json` input whose root `$schema` string contains `json-schema.org`). Classified: root `properties`, nested `properties`, object-form `items.properties` (segment `[]`), `allOf`/`anyOf`/`oneOf` members (property `conditional: true` for `anyOf` and `oneOf`), local `$ref` to `#/$defs/...` and `#/definitions/...` up to depth 16 with a visited set.

| Construct | Code | Level | Blocking |
|---|---|---|---|
| Any `ConvertFrom-DocsJsonText` finding (invalid JSON, duplicate key, depth) | `json-invalid` | input | yes |
| Remote `$ref`, missing target, cycle, or depth above 16 | `json-schema-ref-unresolved` | site | no |
| `if`/`then`/`else`, `not`, `patternProperties`, schema-valued `additionalProperties`, `dependentSchemas`, `prefixItems`, `unevaluatedProperties` (keys beneath are not enumerated) | `json-schema-keyword-not-expanded` | site | no |

YAML (`*.yaml`, `*.yml`). Classified subset: block mappings; block sequences (segment `[]`, mapping items inside sequences); plain, single-quoted and escape-free double-quoted keys; comments; block scalars `|` and `>` with chomping and indentation indicators; one optional `---` before the first content line and an optional final `...`; single-line scalar values and plain multi-line continuation lines that contain no `: `; single-line flow collections as values.

| Construct | Code | Level | Blocking |
|---|---|---|---|
| Tab indentation, a dedent to an unknown column, an unterminated quoted scalar, a continuation line containing `: ` | `yaml-invalid` | input | yes |
| A second document (`---` after content, content after `...`) | `yaml-multi-document` | input | no |
| Anchors `&x`, aliases `*x`, merge keys `<<` | `yaml-anchor-alias` | input | no |
| Tags (`!x`, `!!x`), complex keys (`? `), directives (`%YAML`), flow collections spanning lines | `yaml-unsupported` | input | no |
| A single-line flow collection as a value (key emitted with `value_type` `object` or `array`; inner keys are not) | `yaml-flow-collection-not-expanded` | site | no |
| A double-quoted key containing an escape | `yaml-key-escape-unsupported` | site | no |
| A root that is not a mapping | `yaml-root-not-mapping` | input | no |

Any format: more than 10,000 keys in one input yields `config-key-limit` (input, blocking).

### 3.7 Inventory-level diagnostics (`analyzer_id` `docs-inventory`)

| Construct | Code | Blocking |
|---|---|---|
| A declaration rejected by `Get-DocsElementId` (`DOCS_IDENTITY_INPUT_INVALID`) | `declaration-invalid` | no |
| Two sites with the same kind, path and declaration (first by line kept) | `duplicate-declaration` | no |
| More than 50,000 inputs or more than 256 MiB in total | none: exit 3 with `DOCS_CLI_RUNTIME`, no snapshot | n/a |

### 3.8 Undetectable constructs (no element, no diagnostic)

Registration through `getattr`, `setattr`, `globals()` or `sys.modules`; code produced by `exec`, `eval` or code generation; registration in files outside `surface_selection.source_roots` or matched by `exclusions`; plugin entry points other than the three script tables; user-defined decorators that wrap framework decorators under a bare name (`@my_route("/x")`); frameworks outside argparse, Click, Typer, FastAPI and Flask (for example Starlette `Route` lists or Django URL configurations); PEP 695 `type` alias statements as public symbols; import edges hidden in strings.

## 4. Requirements Mapping and Design

### 4.1 Module layout under `.claude/lib/docs/` (question A)

All files are pushed-down PowerShell libraries. Estimates are proposal figures; the plan records `@(Get-Content -LiteralPath <path>).Count` for each file, and any module estimated above 450 lines is split before execution.

| File | Exports | Pure | Est. lines |
|---|---|---|---|
| `DocsSourceText.psm1` | `ConvertTo-DocsSourceLine` (normalization, section 4.4), `Get-DocsDeclarationDigest -Line <string[]> -Span <int[][]>`, `ConvertTo-DocsKeyPathDeclaration -Segment <string[]>`, `Get-DocsModuleDottedName -Path -SourceRoot <string[]>`, `New-DocsDiagnosticAggregate` and `Add-DocsDiagnosticOccurrence` (one diagnostic per code, path and analyzer with count and first line), `Select-DocsUniqueElement` (`duplicate-declaration`) | yes | 300 |
| `DocsPythonTokens.psm1` | `Get-DocsPythonToken -Text <string>` returning `@{ Tokens; Diagnostics }` | yes | 400 |
| `DocsPythonSyntax.psm1` | `Get-DocsPythonLogicalLine -Token <object[]>`, `Get-DocsPythonImportTable`, `Get-DocsPythonReceiverTable`, `Read-DocsPythonCall` (callee chain, positional and keyword arguments, literal classification), `ConvertFrom-DocsPythonStringToken` (literal value or `$null`), `Get-DocsPythonDefinitionHeader` (decorators, name, header span, parameters with spans), `Get-DocsPythonEnclosingBlock` (loop, def, class detection) | yes | 450 |
| `DocsTomlKeys.psm1` | `Get-DocsTomlKey -Text <string>` returning key paths with spans and value types, `Get-DocsTomlScriptEntry` (script tables for `python-cli`) | yes | 400 |
| `DocsPythonCliArgparse.psm1`, `DocsPythonCliClick.psm1`, `DocsPythonCliTyper.psm1` | `Get-DocsArgparseCommandSite`, `Get-DocsClickCommandSite`, `Get-DocsTyperCommandSite`: per-framework sites into a shared command-tree record | yes | 300 each |
| `DocsAnalyzerPythonCli.psm1` | `Invoke-DocsAnalyzerPythonCli`, `Resolve-DocsCliRootName`, `ConvertTo-DocsCliElement` | yes | 400 |
| `DocsPythonHttpSites.psm1` | `Get-DocsFastApiRouteSite`, `Get-DocsFlaskRouteSite`, `Get-DocsHttpMountSite` | yes | 400 |
| `DocsAnalyzerPythonHttp.psm1` | `Invoke-DocsAnalyzerPythonHttp`, `Resolve-DocsHttpTemplate` (composition, `<dynamic>`) | yes | 350 |
| `DocsAnalyzerPythonApi.psm1` | `Invoke-DocsAnalyzerPythonApi`, `Get-DocsPublicApiAllName`, `Get-DocsPublicApiBinding` | yes | 400 |
| `DocsYamlKeys.psm1` | `Get-DocsYamlKey -Text <string>` | yes | 400 |
| `DocsJsonSchemaKeys.psm1` | `Get-DocsJsonMemberSpan -Text <string>` (position scanner over validated JSON), `Get-DocsJsonSchemaKey -Value <IDictionary> -MemberSpan <object>` | yes | 400 |
| `DocsAnalyzerConfigFiles.psm1` | `Invoke-DocsAnalyzerConfigFiles`, `Get-DocsEnvTemplateKey`, `Test-DocsEnvTemplatePath`, `Get-DocsConfigFileFormat` | yes | 350 |
| `DocsAnalyzerArchitecture.psm1` | `Invoke-DocsAnalyzerPythonArchitecture`, `Get-DocsPythonImportEdge` | yes | 350 |
| `DocsInventorySnapshot.psm1` | `New-DocsInventorySnapshot` (merge, sort, header, `id`, `profile_sha256`), `Get-DocsInventorySelection` (source roots, exclusions, env withholding, aggregate bounds, all over path lists) | yes | 400 |
| `DocsInventory.psm1` | `Invoke-DocsInventoryCommand -Argument -Context` (the only function using the command context) | no (command) | 250 |

The analyzer function names follow the registry grammar; the Architecture module keeps the epic file name while its function and identifier carry the `python-` prefix. Only `Invoke-DocsInventoryCommand` touches I/O, and only through `Context.ListFile`, `Context.ReadBytes`, `Context.ReadText`, `Context.UtcNow` and `Context.WriteText`; it never calls `Write-DocsFileText` directly (1020 `### Entry script`). If the amended 1020 provides a declaration-digest function in `DocsSurface.psm1`, `Get-DocsDeclarationDigest` is not created and the plan consumes the 1020 function.

### 4.2 Bounded Python lexer (question B)

Token classes, matched in this order by one `\G`-anchored alternation:

1. `NEWLINE` (`\r\n`, `\r`, `\n`; already normalized to LF by section 4.4); a newline at bracket depth 0 not preceded by a continuation ends the logical line.
2. `CONTINUATION` (backslash immediately before a newline).
3. `COMMENT` (`#` to end of line).
4. `STRING`: optional prefix from `r`, `u`, `b`, `f`, `br`, `rb`, `fr`, `rf` in any letter case; quote `'`, `"`, `'''` or `"""`; triple-quoted strings span lines; backslash escapes are skipped in non-raw strings and in raw strings the backslash still protects the quote; f-strings track replacement-field braces and nested strings up to two levels (beyond is `python-lexer-unclassified`). The token records `Prefix`, `IsTriple`, `HasEscape`, `IsBytes`, `IsFormat`.
5. `NAME`: `[\p{L}\p{Nl}_][\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}]*`; keywords (`def`, `class`, `async`, `import`, `from`, `as`, `for`, `while`, `if`, `elif`, `else`, `try`, `except`, `finally`, `with`, `lambda`, `return`) are `NAME` tokens with `IsKeyword`.
6. `NUMBER` (skipped by extent).
7. `OP`: brackets `( ) [ ] { }` (with running depth, bound 64), `@`, `:`, `,`, `.`, `=`, `+=`, `->`, `:=`, `**`, `*`, and every other Python operator.
8. Whitespace (spaces, tabs, form feed) between tokens.

`Get-DocsPythonLogicalLine` groups tokens into logical lines with `StartLine`, `EndLine`, `Indent` (column of the first token, tabs to multiples of 8, form feed resetting the column) and `Tokens`. Decorators are logical lines whose first token is `@`; a definition header is the logical line whose first non-`async` token is `def` or `class`, ending at the `:` at depth 0; "top-level" means `Indent` 0. Statements separated by `;` at depth 0 are split into separate simple statements.

Reuse of `.claude/lib/mermaid/MermaidLineScanner.psm1` (verified file and exports): the pattern is reused, not the functions. Reused elements: index-aligned masking of quoted spans (`Get-MermaidQuoteMaskedText`), separate bracket-delta accounting (`Get-MermaidBracketDelta`), an ordered-dictionary scan record with a `Class` field that includes an explicit `Unclassifiable` value (`Get-MermaidLineScan`), pure functions with no I/O and no input mutation, and the module header conventions. The Mermaid functions themselves are not callable for Python because Mermaid treats a backslash as an ordinary character (stated in that module's header) while Python strings use escapes and span lines.

### 4.3 Declaration strings per kind (question D, part 1)

These strings are the identity input and are binding on 900011 for every construct both analyzers classify.

| Kind | Declaration | Rules |
|---|---|---|
| `cli-command` | root name, then space-separated subcommand names | Root name order: (1) the console-script name when the root is attached; (2) a literal `prog=`, Click `name=` or first positional string, or `typer.Typer(name=)`; (3) the module dotted name relative to the containing source root. Click default name: function name lower-cased, `_` replaced by `-`, then one trailing `-command`, `-cmd`, `-group` or `-grp` removed (carried from the earlier research, which verified it against the Click changelog). Typer default name: function name with `_` replaced by `-` (earlier decision D11; lower-casing UNVERIFIED and pinned by tests). This order changes the earlier spec, which put the literal first; the change prevents a duplicate root when a script is attached. |
| `cli-option` | command path, one space, option | Option = the first string beginning `--` (Click strings are split at `/` first), else the first string beginning `-`, else the positional or argument name as written. Typer default option: `--` plus the parameter name with `_` replaced by `-`; a boolean option declares `--x`. |
| `http-route` | upper-case method, one space, template | One element per distinct method, sorted. FastAPI template: verbatim concatenation of include prefixes (outermost first), router prefix and path. Flask template: when a prefix applies, `prefix.TrimEnd('/') + '/' + rule.TrimStart('/')` (UNVERIFIED against Flask source; pinned by tests). An unresolved segment is the literal `<dynamic>`. WebSocket method token `WEBSOCKET`. Defaults: `GET`; Flask automatic `HEAD` and `OPTIONS` are not emitted. |
| `public-symbol` | `<module dotted name>.<name>` | `__init__.py` uses the package name. |
| `architecture-component` | dotted module or package name | |
| `config-key` | quoted key path (section 3.6) | TOML paths start at the root table (`tool.x.y`). Scanner-only. |

Other element fields that 900011 reproduces: `path` (the file holding the declaring site; `pyproject.toml` for a console script), `name` (last declaration segment for CLI, configuration and architecture kinds; handler function name for a decorator route, otherwise the template; symbol name for `public-symbol`), `parent_id` (`cli-option` to its command; a subcommand to its parent command; `null` otherwise), `line_range` (the contiguous span below or `null`), `source_sha256` (the digest below), and `properties` under the same emission rules.

### 4.4 Declaration-lines digest (question D, part 2; D5)

Normalization (`ConvertTo-DocsSourceLine`):

1. Decode the captured bytes as strict UTF-8 (undecodable input is the 1020 diagnostic; no element).
2. Remove one leading U+FEFF.
3. Replace `\r\n` with `\n`, then each remaining `\r` with `\n`. No other character is a line break (form feed, U+2028, U+2029 and U+0085 are not).
4. Split on `\n`; when the text ends with `\n`, drop the final empty element. Lines are numbered from 1. Trailing whitespace and tabs are kept; no Unicode normalization is applied.

Digest input: for each span `[start, end]` in order, lines `start` through `end`, each followed by one `\n`, concatenated; digest = lowercase hex SHA-256 of the UTF-8 bytes (`Get-DocsSha256Hex -Text`). The value is stored in element `source_sha256` (K5). An element with an empty span list has the digest of the empty string.

Spans per kind (a "statement span" runs from the line of the statement's first token to the line of its last token, including bracket and backslash continuations and any triple-quoted string inside it; a "header span" runs from the line of a given decorator's `@` to the line of the `:` that ends the `def` or `class` header):

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

Reproduction notes for 900011 (Python, standard library only): decode with `bytes.decode("utf-8")`, apply the same three normalization steps, and split with `str.split("\n")`, never `str.splitlines()`, which also splits on form feed and U+2028. Statement spans equal `stmt.lineno` through `stmt.end_lineno`. Decorator start lines and the header `:` line come from the `tokenize` module, because `ast` gives the decorator expression line (after `@`) and no line for the header colon. Typer parameter spans equal `arg.lineno` through the larger of the annotation and default `end_lineno`.

### 4.5 Element identifiers and `analysis_method` (questions D and E)

- Identifier (1020 `#### Element identifiers`): `<kind>-` plus the lowercase hex SHA-256 of the UTF-8 bytes of `canonical_json({"declaration": D, "kind": K, "path": P})` followed by one line feed, computed by `Get-DocsElementId` through `Get-DocsStableId` and `ConvertTo-DocsCanonicalJson`, which delegates to `ConvertTo-DiscoveryCanonicalJson` in `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` (verified: exported; sorts keys by ordinal code point; escapes only the quote, the backslash and C0 controls; refuses non-integer numbers; appends a single LF). Python reproduction: `json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n"`; sort order agrees for keys made of ASCII letters, which the three fixed keys are. The module header states byte agreement with the Python runtime's `canonical_json`.
- `analysis_method`: every 1022 element records `analysis_method: scanner`. Proposal for the amended schema and registry (dependent on the 1020 amendment): the field is a required member of snapshot `$defs/element`; registry rows gain `AnalysisMethod`; 1022 rows carry `'scanner'`; `Invoke-DocsAnalyzer` rejects output whose `analysis_method` differs from the row; `analyzers[]` entries also record the method so a snapshot states which method ran per identifier.
- Replacement by 900011: for `python-cli`, `python-http`, `python-public-api` and `python-architecture`, the registry selection (amended 1020) returns the native row when the 900011 availability probe succeeds and the scanner row otherwise. Because declarations, paths and digests follow sections 4.3 and 4.4, identifiers and `source_sha256` are equal across methods, so ledger entries and pins stay valid. `config-files` has no native row and stays scanner-only. 1022's `DocsInventory.psm1` calls the registry selection and does not choose methods itself, so 900011 does not edit 1022 files.
- Shared fixture: `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` (test data, committed, read in place; not a temporary file). Content: `inputs` (path to source text, with CRLF, CR and BOM cases expressed as JSON escapes so the `.gitattributes` `eol=lf` rule cannot alter them), `expected_elements` (kind, path, declaration, element_id, name, parent declaration, line_range, source_sha256, properties, analysis_method `scanner`) and `expected_diagnostics` (code, path, analyzer_id). Coverage: every classified form and every diagnostic row of sections 3.1 to 3.5, plus `pyproject.toml` script tables. Golden identifiers and digests are recorded once from an independent computation in `<FEATURE>/evidence/other/`. 1022's Pester suite asserts equality; 900011's Python tests read the same file and add their own expectations for constructs the scanner reports as diagnostics, without editing it. A separate `config-surface-corpus.json` covers section 3.6 and is not used by 900011.

### 4.6 Registration (question F)

- `DocsAnalyzerRegistry.psm1`: five rows inserted directly under the 1022 anchor (K1), one row per line, in identifier order, for example `[pscustomobject]@{ Id = 'config-files'; Version = '1.0.0'; ElementKinds = @('config-key'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerConfigFiles.psm1'); Function = 'Invoke-DocsAnalyzerConfigFiles' }` plus `AnalysisMethod = 'scanner'` if the amendment adds it. The others: `python-architecture` (`architecture-component`, `DocsAnalyzerArchitecture.psm1`, `Invoke-DocsAnalyzerPythonArchitecture`), `python-cli` (`cli-command`, `cli-option`; `DocsAnalyzerPythonCli.psm1`; `Invoke-DocsAnalyzerPythonCli`), `python-http` (`http-route`; `DocsAnalyzerPythonHttp.psm1`; `Invoke-DocsAnalyzerPythonHttp`), `python-public-api` (`public-symbol`; `DocsAnalyzerPythonApi.psm1`; `Invoke-DocsAnalyzerPythonApi`).
- `Invoke-DocsCommand.ps1`: one row under the 1022 anchor: `[pscustomobject]@{ Name = 'inventory'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsInventory.psm1'); Function = 'Invoke-DocsInventoryCommand'; Option = @{ Profile = 'value'; Analyzer = 'multi'; Revision = 'value'; Write = 'switch' } }`.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (verified): its scan roots include `.claude/lib` (`EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1`, `$script:ScanRoot`), the allowlist is empty (`It 'ships an empty allowlist'`), and detection class 3 (`It 'detects an ampersand-invoked variable that is not a scriptblock parameter'`, `It 'detects an ampersand-invoked expression in the command position'`) reports any `&` call through a variable or expression unless the variable is a `[scriptblock]`-typed parameter declared in the same file (`It 'reports no finding for a scriptblock-parameter seam invocation'`). 1022 modules therefore contain no `&` call through a variable, member or expression; dynamic dispatch stays inside 1020's registry and entry script. Any seam a 1022 function needs is a `[scriptblock]` parameter of that function.
- Dependency expression in the plan: Phase 0 verifies on the integration branch that 1020 is merged with the amendment: each consumed function exists with the stated parameters, the snapshot schema has `analysis_method`, the envelope schema file exists, and the 1022 anchors exist in both files. Any mismatch stops execution and is reported; the plan never creates or edits a 1020 file other than the two anchored insertions and the `core.json` append.

### 4.7 `inventory` command, exit codes and envelope (question G)

- Flow of `Invoke-DocsInventoryCommand`: read the profile through `ConvertFrom-DocsProfileText` (findings exit 1; absent profile exit 1 with the 1020 `DOCS_PROFILE_MISSING` behavior); validate `-Revision` with `Test-DocsFullRevision` (exit 2 otherwise; absent means `revision: null`, which 1023's `docs-complete` rejects with `DOCS_SNAPSHOT_UNPINNED`); select rows with `Select-DocsAnalyzerRegistration` (an unknown `-Analyzer` exits 2 with one `DOCS_CLI_ARGUMENTS` finding naming it; K7); list files under each source root with `Context.ListFile`; apply `exclusions` with the epic path rule (exact, prefix plus `/`, or case-sensitive glob; first match wins); withhold non-template env files without reading them; read each remaining file with `Context.ReadBytes` and wrap it with `New-DocsCapturedInput -MaxBytes 1048576`; invoke each row with `Invoke-DocsAnalyzer`; build the snapshot with `New-DocsInventorySnapshot` and `Context.UtcNow`; self-validate with `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'` (failure is a defect guard, exit 3 `DOCS_CLI_RUNTIME`).
- Writes: dry run by default; with `-Write`, the snapshot text (`ConvertTo-DocsJsonText -Indented`) goes to profile `artifact_paths.inventory_snapshot` through `Context.WriteText` with mode `overwrite` when the file exists, else `create`.
- Exit codes: 0 when no blocking diagnostic exists; 1 when any blocking diagnostic exists (one `DOCS_INVENTORY_BLOCKING_DIAGNOSTIC` error finding per blocking diagnostic, `related_paths` its path) or the profile is invalid; 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `null`; 3 with exactly one `DOCS_CLI_RUNTIME` finding (aggregate bound, read failure other than absence, defect guard).
- `result`: `{snapshot, snapshot_path, written}`. All snapshot numbers are integers, so `ConvertTo-DocsCanonicalJson` can render the envelope.
- Envelope validation: Pester asserts the `-Json` output of every exit path validates against `schemas/docs/v1/docs-command-envelope.schema.json` through the amended 1020 validation function; if the amended 1020 exposes none, the test calls `Test-Json` with the self-contained runtime copy under `.claude/lib/docs/schemas/v1/` (D5 fallback).

### 4.8 Push-down, manifest and tier (question H)

- Mirror: each new `.claude/lib/docs/*.psm1` file is copied byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (verified shape: `name` `core`, `label`, `paths` array of repository-relative strings; existing entries include `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` and the four `.claude/lib/mermaid/*.psm1` files). Each new file is appended to `paths` after the 1020 docs entries. The 1022 files are not listed in `pack-manifests/python.json` (verified shape: `name`, `label`, `paths`): the scanner is PowerShell and always available (D3).
- Contract tests to run (brief `## Contract Tests That Pin Mirrored Files`; files verified present): `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (every literal `$PSScriptRoot` join must resolve to a manifested file in core), and 1020's planned `Docs.Manifest.Tests.ps1`.
- Tier: `quality-tiers.yml` (verified: `version: 1`, `projects` of `{path, tier, rationale}`; every `.claude/lib/<name>` folder is classified under rule R4 in `scripts/dev_tools/quality_tiers_contract.py`). 1020 adds `.claude/lib/docs` at T3; 1022 adds no entry because its files live in that folder.

### 4.9 Reuse of `.claude/lib/discovery-validation/` (question K)

- Reused indirectly through 1020 wrappers: `ConvertTo-DiscoveryCanonicalJson`, `Get-DiscoverySha256Hex`, `Get-DiscoveryBytesSha256Hex` (`DiscoveryEncoding.psm1`, verified exports). 1022 modules import `DocsJson.psm1` and `DocsSurface.psm1`, never `DiscoveryEncoding.psm1` directly, so the cross-area import stays in one 1020 module.
- Not reused: the other discovery-validation modules (verified function lists) handle host payloads, authorization, observation and receipts; none offers lexing, key scanning or path matching needed here.
- No docs helper calls the Python discovery runtime: 1022 files contain no interpreter invocation, enforced by the existing guard test (section 4.6). The discovery Python modules cited in the earlier research are design references only (epic `### Reuse`).
- Optional import of a discovery inventory snapshot JSON (epic 1022 file list, "optional"): not designed here, because mapping discovery `component` records (`component_type`, `source`, `classification`) onto docs `architecture-component` declarations has no stated rule. Item for the orchestrator (section 7).

## 5. Artifact Classification (question J)

Rule references: R1 = language-rule clause (1) (pushed-down helpers and libs are PowerShell or bash); D = epic `### Artifact classes for this epic` (schema, configuration, data, test and documentation rows).

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsSourceText.psm1`, `DocsPythonTokens.psm1`, `DocsPythonSyntax.psm1`, `DocsTomlKeys.psm1`, `DocsPythonCliArgparse.psm1`, `DocsPythonCliClick.psm1`, `DocsPythonCliTyper.psm1`, `DocsAnalyzerPythonCli.psm1`, `DocsPythonHttpSites.psm1`, `DocsAnalyzerPythonHttp.psm1`, `DocsAnalyzerPythonApi.psm1`, `DocsYamlKeys.psm1`, `DocsJsonSchemaKeys.psm1`, `DocsAnalyzerConfigFiles.psm1`, `DocsAnalyzerArchitecture.psm1`, `DocsInventorySnapshot.psm1`, `DocsInventory.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (edit: rows under the 1022 anchor) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row under the 1022 anchor) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` copies of every created or edited file above | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/<Module>.Tests.ps1` (one per new module) and `DocsInventoryProperties.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json`, `config-surface-corpus.json` | test (fixture data) | JSON | D |
| `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/**` (spec, user story, plan, research, evidence) | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, Python file or TypeScript file is created or edited. Owner questions on language: none; every artifact follows the language rule.

## 6. Testing Implications (question I)

- Location: `tests/scripts/claude-lib/docs/`, one suite per module, following `tests/scripts/claude-lib/mermaid/` (verified). `config/poshqc-scan.json` (verified: `test.scanFolders` includes `tests/scripts`) already discovers them, and `config/poshqc-coverage.json` (verified: `roots` includes `.claude/lib`) already measures them; neither file changes.
- CI: the shard jobs `poshqc / PowerShell QC shard 1` to `3` (`_poshqc.yml`, `runs-on: windows-latest`, `Invoke-PoshQCTest -ShardIndex -ShardCount`, verified) run the suites with coverage; the required aggregator is `poshqc / PowerShell QC`. Line coverage of at least 85% per new file is read from `artifacts/pester/powershell-coverage.xml`; no branch gate applies to Pester.
- In-memory inputs only: analyzers receive captured-input records built by `New-DocsCapturedInput` from in-test strings; the command suite uses 1020's in-memory context from `Docs.TestSupport.psm1`. No `TestDrive`, `New-TemporaryFile`, temp path or `$env:TEMP` (forbidden by `.claude/hooks/check-powershell-test-purity.ps1`, verified patterns). The two corpus files are committed data read in place.
- Line endings: CRLF and CR cases are built in test code with `` "`r`n" `` and `` "`r" `` or stored as JSON escapes, never as committed CRLF files.
- Property-style tests, at least one per pure exported function, with a seeded `[System.Random]` whose seed is printed on failure (1020 precedent): determinism (two calls equal); byte-identical snapshot under permuted input order and repeated builds with a fixed clock; every `element_id` equals `Get-DocsElementId` of its fields; digest invariance under trailing-newline presence and CRLF/LF/CR variants; digest change when any line inside the span changes and no change when a line outside it changes; value redaction (marker values in every value position never appear in the snapshot); key-path quoting injectivity; size bound at 1048575, 1048576 and 1048577 bytes (a single comment or key line, so the lexer consumes it in one match).
- Every diagnostic row in section 3 has one test asserting the code, the absence of an element for the site or input, and the survival of classified sites in the same input.
- Isolation: suites import modules with `-Force` and remove them in `AfterAll`; three seeded shuffled single-process runs and one fresh single-process run over `tests/scripts` (brief `## Test Isolation Checks`).

## 7. Items for the Orchestrator

1. K5: confirm the amended 1020 stores the declaration-lines digest in element `source_sha256` (whole-file digest in `inputs[].sha256`).
2. K6: `information` severity for `env-file-not-captured`: add `-Severity` to `New-DocsDiagnostic` in the 1020 amendment, or accept non-blocking `warning`.
3. Registry provider model for D3 (section 4.5): `AnalysisMethod` on rows, per-identifier native-or-scanner selection in `Select-DocsAnalyzerRegistration`, and `analysis_method` on `analyzers[]`; these belong to the 1020 amendment.
4. Whether the amended 1020 provides a declaration-digest function (then `Get-DocsDeclarationDigest` is not created in 1022).
5. Ownership of the shared path-or-glob matcher used by 1022, 1023 and 1024 (one function in 1020 avoids three copies).
6. 1023's single-write-boundary test must allow `Context.WriteText` from `DocsInventory.psm1` for the snapshot.
7. Scope: external distribution dependencies and the optional discovery-snapshot import are excluded from 1022 (sections 3.5 and 4.9); confirm, or assign them to a later child.
8. Root-name order change for console scripts (section 4.3) relative to the withdrawn spec.

## 8. UNVERIFIED Items

- Every amended-1020 contract (analysis_method field, digest rule text, envelope schema file, 900011 anchor, back-filled anchor labels): stated in the epic only; the 1020 spec on this branch does not carry them.
- The diagnostic codes `New-DocsCapturedInput` emits for oversize and undecodable input.
- PowerShell's inability to use `System.Text.Json.Utf8JsonReader` (by-reference struct): not probed on this branch.
- Typer lower-casing of default command and option names; Flask prefix joining; the Click suffix list (carried from the earlier research).
- `Test-Json` behavior for the envelope schema on the CI `windows-latest` PowerShell version.

## Numeric Derivation Evidence

Analyzer registrations appended by 1022:

- Complete Family: analyzer registry rows 1022 inserts under its anchor in `DocsAnalyzerRegistry.psm1`
- Exhaustive Search Scope: epic `### Analyzer decisions from the first preparation of 1022` and epic `### 1022 - docs-surface-analyzers-python-config (wave 1, C4)` `Files (create)`
- Inclusion Rules: an analyzer identifier, or a module whose leaf begins `DocsAnalyzer`
- Exclusion Rules: `DocsPythonTokens.psm1` and `DocsInventory.psm1` (not analyzers); helper modules proposed in section 4.1
- Primary Search Strategy or Query Expression: read the identifier list in `### Analyzer decisions from the first preparation of 1022`
- Primary Member Set: python-cli, python-http, python-public-api, config-files, python-architecture
- Primary Count: 5
- Cross-check Search Strategy or Query Expression: list each `DocsAnalyzer*.psm1` file in the 1022 `Files (create)` sentence and map it to its identifier
- Cross-check Member Set: DocsAnalyzerPythonCli (python-cli), DocsAnalyzerPythonHttp (python-http), DocsAnalyzerPythonApi (python-public-api), DocsAnalyzerConfigFiles (config-files), DocsAnalyzerArchitecture (python-architecture)
- Cross-check Count: 5
- Member-set Comparison: the normalized identifier sets are equal

Analyzer identifiers replaceable by 900011:

- Complete Family: 1022 analyzer identifiers that the native analyzer covers
- Exhaustive Search Scope: epic `### 900011 - docs-surface-analyzer-python-native (wave 2, C3)` and epic `### Analyzer decisions from the first preparation of 1022`
- Inclusion Rules: identifiers analyzing Python source
- Exclusion Rules: `config-files` (scanner-only per the 900011 scope split)
- Primary Search Strategy or Query Expression: read the parenthesized list in the 900011 `Scope split with 1022` paragraph
- Primary Member Set: python-cli, python-http, python-public-api, python-architecture
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: filter the 1022 identifier list for the prefix `python-`
- Cross-check Member Set: python-cli, python-http, python-public-api, python-architecture
- Cross-check Count: 4
- Member-set Comparison: the normalized sets are equal

Input families named by the epic acceptance criterion:

- Complete Family: frameworks and formats the in-memory fixture must cover
- Exhaustive Search Scope: the first acceptance criterion of epic `### 1022` and of `issue.md` `## Acceptance Criteria (early draft)`
- Inclusion Rules: every framework or format named after "covering"
- Exclusion Rules: none
- Primary Search Strategy or Query Expression: tokenize the epic criterion after "covering"
- Primary Member Set: argparse, Click, Typer, FastAPI, Flask, pyproject.toml, .env, JSON Schema, YAML
- Primary Count: 9
- Cross-check Search Strategy or Query Expression: tokenize the `issue.md` first criterion after "covering"
- Cross-check Member Set: argparse, Click, Typer, FastAPI, Flask, pyproject.toml, .env, JSON Schema, YAML
- Cross-check Count: 9
- Member-set Comparison: the normalized sets are equal

## Pre-Mortem

- **Review checklists**: a reviewer finds case-insensitive PowerShell defaults treating Python names `App` and `app` as one (`-eq`, `-like`, `-contains`, `@{}` keys), a configuration value in a property, or an `&` call through a variable. The plan must require `-ceq`, `-clike`, `-cmatch`, ordinal dictionaries and `[StringComparer]::Ordinal` sorting in every 1022 module, carry the redaction property test, and run `enforcement-hooks-no-python-invocation.Tests.ps1`.
- **Coverage**: recognizers have many branches and the diagnostic rows multiply them; a module below 85% lines fails `poshqc / PowerShell QC`. The plan must pair each classified form with its diagnostic test, measure per file from `artifacts/pester/powershell-coverage.xml`, and exclude no production file.
- **Mirror parity**: a bundle copy differing from its source, a file missing from `core.json`, or a non-literal `$PSScriptRoot` join fails the three push-down contract tests and `Docs.Manifest.Tests.ps1`. The plan must copy after the last edit of each file and run those tests in the final loop. No execution-environment brief fact changes, so no brief-update task is needed.
- **File size**: the CLI and lexer modules can exceed 500 lines once diagnostics are added. The plan must keep the section 4.1 split, record physical line counts with `@(Get-Content -LiteralPath <path>).Count`, and split any module reaching 500 lines into a new module with its own suite, mirror copy and manifest entry.
- **Test isolation**: dot-sourced entry scripts and `-Force` imports leave modules loaded across suites in one shard. The plan must remove modules in `AfterAll`, avoid module-scope mutable state, and record three seeded shuffled runs plus a fresh single-process run under `<FEATURE>/evidence/regression-testing/`.
- **CI-only behavior**: CI runs Pester on `windows-latest` with the runner's PowerShell and `Test-Json` version, and checks out with `eol=lf`; culture-sensitive `Sort-Object` can reorder output on another host culture. The plan must build CRLF cases in code or JSON escapes, sort with the ordinal comparer, and assert codes and pointers rather than `Test-Json` message text.
- **Evidence**: golden identifiers and digests computed by the code under test prove nothing, and evidence outside `<FEATURE>/evidence/<kind>/` or with plan-time stamps is rejected. The plan must record the golden vectors from an independent hash computation under `<FEATURE>/evidence/other/` and stamp every artifact with the UTC write time.

## Automation Feasibility

All acceptance criteria are automatable with Pester over in-memory inputs and two committed fixture files: element emission, every diagnostic row, determinism, digests, redaction, the size bound, schema and envelope validation, registration and exit codes. The push-down contract tests, the Python-invocation guard and the file-size gate are existing command-line checks. Golden vectors need one independent hash computation by the executor, recorded as evidence. No step requires human judgment except the orchestrator items in section 7, which are contract decisions to settle before the plan is finalized.
