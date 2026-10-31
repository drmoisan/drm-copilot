# docs-surface-analyzers-typescript-dotnet — Spec

- **Issue:** #1033
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 1033, wave 1, band C4)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft
- **Version:** 0.4 (owner decision P3: reconciliation with 1023 and 1020 v0.6)
- **Revision note (P3, 2026-10-31):** owner decision P3 authorizes one reconciliation revision.
  Precision-limit diagnostics now carry the 1023 `docs.precision-limit` marker with an
  `element_kind` (row C5 resolved in favor of 1023; C9 and OQ-2 resolved by 1023);
  `extension-finding-skipped` is no longer a precision limit; the registry anchor is
  `# --- 1033: TypeScript and .NET analyzers ---` (C6 and OQ-5 resolved by 1020 P1); registry suites
  assert membership only; the no-process, no-timer test rule is stated. Version 0.3 aligned with
  1020 v0.4 (digest path, `AnalysisMethod` rows, optional `-Selection` keys, empty-file behavior).
- **Work Mode:** full-feature
- **Research (primary design source):** `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/research/2026-10-30T22-45-docs-surface-analyzers-typescript-dotnet-research.md`
- **Binding upstream contracts:** epic `docs/features/epics/documentation-estate-tooling/epic.md` (sections `## Owner Directive: Implementation Language (2026-10-30, refined)`, `## Owner Decisions`, `### Amendment of 1020 required by D3 and D5`, `### PowerShell contracts from the re-preparation of 1020`, `### Command contract decisions from the first preparation of 1023`, `### Analyzer decisions from the first preparation of 1022`, `### Ledger contracts from the PowerShell preparation of 1023 (binding)`, `### 1033 - docs-surface-analyzers-typescript-dotnet`), 1020 `spec.md` version 0.6 `## Decisions Later Children Must Honor`, `### \`DocsSurface.psm1\`` and `### \`DocsAnalyzerRegistry.psm1\``, and 1023 `spec.md` `### Scanner precision limits (D3)` and `### #1022 and #1033 (PowerShell scanners) for precision-limit diagnostics`.

## Overview

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository so that a coverage ledger can prove that documentation stays in correspondence with the
code. Child 1020 defines the surface element model (`DocsSurface.psm1`), the analyzer registry and
analyzer contract (`DocsAnalyzerRegistry.psm1`) and the entry script `Invoke-DocsCommand.ps1`.
Child 1022 adds the PowerShell scanners for Python and configuration surfaces and the `inventory`
subcommand. A repository whose surface is written in TypeScript or C#/.NET has no analyzer today, so
its command-line commands and options, HTTP routes, exported symbols, public types and members, and
configuration keys cannot be inventoried, and stacks outside the built-in set have no path to bring
externally produced results into the inventory.

This feature adds PowerShell lexical scanners for those surfaces and an importer for discovery
extension-result manifests. Under the owner's implementation-language rule, logic pushed down to
destination repositories is PowerShell or bash. Under owner decision D3 the PowerShell text scanner
is the always-available baseline and keeps a documented precision limit; native TypeScript and C#
analyzers are later, optional children and are not part of this feature.

The feature adds analyzers only. It adds no subcommand: the analyzers run behind 1022's `inventory`
subcommand through 1020's registry.

## Behavior

- Create PowerShell modules under `.claude/lib/docs/`, each mirrored byte-identically to
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` and listed once in the
  Claude `pack-manifests/core.json`:
  - `DocsScannerCommon.psm1`: shared pure helpers (input selection, token-span helpers, literal
    extraction, route-template joining, diagnostic aggregation, declaration-lines digest fallback,
    the machine-readable precision-limit table).
  - `DocsTypeScriptTokens.psm1`: bounded TypeScript tokenizer (with `DocsTypeScriptJsx.psm1` only if
    the JSX state machine would push the tokenizer past 500 logical lines).
  - `DocsCSharpTokens.psm1`: bounded C# tokenizer.
  - `DocsAnalyzerTypeScriptCli.psm1` (`typescript-cli`): Commander and yargs commands and options.
  - `DocsAnalyzerTypeScriptHttp.psm1` (`typescript-http`): Express and Fastify routes.
  - `DocsAnalyzerTypeScriptExports.psm1` (`typescript-exports`): exported symbols.
  - `DocsAnalyzerDotnetHttp.psm1` (`dotnet-http`): attribute routes and minimal-API `Map*` routes.
  - `DocsAnalyzerDotnetConfig.psm1` (`dotnet-config`): `appsettings*.json` keys, never values.
  - `DocsAnalyzerDotnetApi.psm1` (`dotnet-public-api`): public types and members.
  - `DocsAnalyzerExtensionImport.psm1` (`extension-import`): discovery extension-result manifests
    for other stacks, validated against the captured inputs and merged as inert data.
- Module name refinement: the epic names the import module `DocsExtensionImport.psm1`. 1020's
  `Test-DocsAnalyzerRegistration` rejects a registered `Module` whose leaf does not match
  `DocsAnalyzer*.psm1` and a `Function` outside `^Invoke-DocsAnalyzer[A-Za-z]+$`, so that name
  cannot be registered. This feature uses `DocsAnalyzerExtensionImport.psm1` with
  `Invoke-DocsAnalyzerExtensionImport`. The rename is a refinement of a module name, which the epic
  permits research to make; the naming contract `Docs<Area>.psm1` is preserved.
  `DocsScannerCommon.psm1` is an additional refinement module under the same contract.
- Register the seven analyzers as rows directly under the `# --- 1033: TypeScript and .NET
  analyzers ---` anchor of the scanner table `$script:DocsAnalyzerRow` in `DocsAnalyzerRegistry.psm1`
  (anchor text as committed by 1020 v0.6; see C6 and OQ-5), and nowhere else. The identifiers are distinct from 1022's `python-cli`, `python-http`,
  `python-public-api`, `config-files` and `python-architecture`.
- Every element carries the analysis method field defined by the 1020 amendment (C1) with value
  `scanner` for the six built-in scanners, and a digest over the declaration's source lines, not the
  whole file (D5; C2). Imported elements follow OQ-1.
- A construct the scanner cannot classify is reported as a non-blocking diagnostic with a fixed code
  and is never guessed. The set of such codes is the scanner precision limit (`## Scanner Precision
  Limit`); each such diagnostic carries the `docs.precision-limit` marker with its `element_kind`,
  and the coverage ledger (1023) records it as a `deferred` entry with an owner (C5, C9, OQ-2).
- An input above the size bound, an undecodable input, a lexical error or a token, depth or key
  bound overflow yields a blocking diagnostic and no element from that file; other files still
  produce elements.
- Extension-result manifest import validates the manifest and every digest it declares against the
  captured inputs. Any failed check rejects the whole manifest with one blocking diagnostic and
  contributes no element. A manifest that passes every check is merged as inert data.
- Analyzers are read-only, lexical, bounded and deterministic. They never read files, execute,
  compile or install consumer code, call a process, read the clock or the environment, or invoke a
  command by a computed name.

## Inputs / Outputs

- Inputs (per analyzer call, all in memory):
  - `-CapturedInput <object[]>`: records built by 1020's `New-DocsCapturedInput -Path -Bytes
    [-MaxBytes]` with keys `path`, `sha256`, `size`, `text`, `diagnostic`. The inventory (1022)
    builds them after applying profile exclusions. `text` is `$null` for an oversize or undecodable
    input. Analyzers never decode bytes.
  - `-Selection <object>`: a hashtable (shape C3) whose keys this feature reads are
    `source_roots` (POSIX relative paths), `repository_id` (identifier), `revision` (40 or 64
    lowercase hex, or `$null`) and `registered_analyzer_ids` (string array). Every key is optional,
    because 1020 types `-Selection` as `<object>` without a shape and the 1022 inventory (step 7 of
    its `### Inventory command and snapshot builder`) defines no key: an absent or empty
    `source_roots` gives repository-relative module paths; an absent `repository_id` or `revision`
    yields the non-blocking unverified diagnostic of `## Extension-Result Manifest Import` step 3;
    an absent `registered_analyzer_ids` triggers the in-function registry import.
- Outputs: `@{ Elements = @(...); Diagnostics = @(...) }` per the 1020 analyzer contract.
  - Elements are built with `New-DocsSurfaceElement`, carry `analyzer_id` equal to the registration
    `Id`, a non-null `line_range`, the analysis method (C1) and the declaration-lines digest (C2),
    and are sorted by `element_id` (ordinal).
  - Diagnostics are built with `New-DocsDiagnostic` (docs `diagnostic` shape) and sorted by `id`
    (ordinal). At most one diagnostic exists per `(analyzer_id, code, path)`, which is the key of the
    diagnostic `id`; its message states the occurrence count and the first line number and never
    quotes source text.
- Configuration keys and defaults (module constants, overridable only through function parameters in
  tests):

| Bound | Default | Exceeded |
|---|---|---|
| Input size | 1 MiB (1048576 bytes), applied by `New-DocsCapturedInput` (C4) | `input-over-bound`, blocking, no element from the file |
| Tokens per file | 250000 | `token-limit`, blocking, no element from the file |
| Bracket depth | 256 | `token-limit`, blocking, no element from the file (message names the depth bound) |
| Configuration keys per input | 10000 | `input-key-limit`, blocking, no element from the file |
| JSON depth (`dotnet-config`) | 64 | `json-invalid`, blocking, no element from the file |
| Re-export expansion depth | 16 | `ts-reexport-unresolved`, non-blocking, other exports of the file kept |

- Versioning: every registration row has `Version = '1.0.0'`. Changing, adding or removing a
  diagnostic code, a declaration form or a recognized construct increments the registration
  `Version` of the affected analyzer.
- Input selection (ordinal, case-insensitive suffix match on the POSIX path):

| Analyzer identifier | Selected inputs |
|---|---|
| `typescript-cli` | `*.ts`, `*.mts`, `*.cts`, excluding `*.d.ts`, `*.d.mts`, `*.d.cts` |
| `typescript-http` | same as `typescript-cli` |
| `typescript-exports` | `*.ts`, `*.tsx`, `*.mts`, `*.cts`, including declaration files |
| `dotnet-http` | `*.cs` |
| `dotnet-public-api` | `*.cs` |
| `dotnet-config` | basename matching `^appsettings(\.[^/]+)?\.json$` |
| `extension-import` | `*.json` whose parsed root has `artifact_kind` `extension-result-manifest` and `$schema` `urn:drm-copilot:discovery:2.0.0:extension-result-manifest`; the referenced `source_inputs` and `result_files` paths are looked up in the same captured set |

  JavaScript files (`*.js`, `*.mjs`, `*.cjs`, `*.jsx`) are not selected (OQ-3).

## API / CLI Surface

This feature adds no subcommand and no command-line flag. All functions are advanced functions with
`[CmdletBinding()]` and PascalCase parameters. "Pure" has 1020's meaning: no filesystem, clock,
process, environment or module-scope mutable state; inputs are strings, arrays and hashtables and are
not mutated. Every sibling import is a column-0 `Import-Module (Join-Path -Path $PSScriptRoot
-ChildPath '<literal>') -Force -ErrorAction Stop`. Every module follows the conventions pinned by
`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`. Every hash and canonical JSON call
goes through 1020's `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex` and `ConvertTo-DocsCanonicalJson`;
no module of this feature imports `.claude/lib/discovery-validation/` directly.

### `DocsScannerCommon.psm1` (pure)

| Function | Parameters | Returns |
|---|---|---|
| `Select-DocsScannerInput` | `-CapturedInput <object[]> -Suffix <string[]> [-ExcludeSuffix <string[]>] [-BasenamePattern <string>]` | Matching inputs sorted by `path` (ordinal) |
| `Get-DocsScannerModulePath` | `-Path <string> -SourceRoot <string[]>` | Path relative to the longest matching source root, extension removed (repository-relative when no root matches) |
| `Get-DocsScannerMatchingClose` | `-Tokens <object[]> -OpenIndex <int>` | Index of the matching close bracket, or `-1` |
| `Get-DocsScannerCallArgument` | `-Tokens <object[]> -OpenIndex <int>` | Top-level argument spans `@{ Start; End }` of a call |
| `Get-DocsScannerLiteral` | `-Tokens <object[]> -Span <hashtable>` | Decoded value of a single non-dynamic string literal or a literal-only `+` concatenation, else `$null` |
| `Join-DocsRouteTemplate` | `-Prefix <string> -Template <string>` | Joined template beginning with `/`, single `/` between segments, case kept |
| `New-DocsScannerDiagnosticSet` | none | Empty ordinal aggregation map |
| `Add-DocsScannerDiagnostic` | `-Set <hashtable> -Code <string> -Path <string> -Line <int> [-Blocking <bool>]` | Updates count and first line for `(code, path)` |
| `ConvertTo-DocsScannerDiagnostic` | `-Set <hashtable> -AnalyzerId <string>` | Diagnostic records sorted by `id`: a `(AnalyzerId, code)` pair that is a row of `Get-DocsScannerPrecisionLimit` is built with `New-DocsScannerPrecisionLimitDiagnostic` and that row's `element_kind`; every other code is built with `New-DocsDiagnostic` and carries no `docs.precision-limit` key |
| `New-DocsScannerPrecisionLimitDiagnostic` | `-AnalyzerId <string> -Code <string> -Path <string> -Message <string> -ElementKind <string>` | The record of `New-DocsDiagnostic -Code -Path -Message -AnalyzerId -Severity warning` with `extensions['docs.precision-limit']` set to the ordered map `@{ element_kind = <ElementKind> }` (the `extensions` member is created as an empty ordered map first when the record has none or it is `$null`; any other `extensions` key is kept). Throws for a `$null` or empty `-Path` and for an `-ElementKind` that is not a docs element kind. 1020's `New-DocsDiagnostic` has no extensions parameter, so the marker is set on the returned record; no 1020 file is edited (C5) |
| `Get-DocsScannerDeclarationText` | `-Text <string> -LineRange <int[]>` | Normalized declaration text per `### Declaration-lines span and digest`; created and exported only when 1020 does not provide `ConvertTo-DocsDeclarationText` (C2; 1020 v0.4 provides it) |
| `Get-DocsDeclarationSha256` | `-Text <string> -LineRange <int[]>` | Lowercase hex digest; created and exported only when 1020 does not provide a function of the same contract (C2; 1020 v0.4 provides it in `DocsSurface.psm1`) |
| `Get-DocsScannerPrecisionLimit` | none | One ordered row per `(analyzer_id, code)` of `## Scanner Precision Limit`: `analyzer_id`, `code`, `element_kind`, `construct`, `consequence` |

### `DocsTypeScriptTokens.psm1` (pure)

- `ConvertTo-DocsTypeScriptToken -Text <string> [-Jsx] [-MaxTokens <int> = 250000] [-MaxDepth <int>
  = 256]` returns `@{ Tokens; Diagnostics }`. `-Jsx` is set by callers for `.tsx` inputs.
- Token record (ordered hashtable, shared with the C# tokenizer): `Kind` (`identifier`, `keyword`,
  `string`, `template`, `number`, `regex`, `punct`), `Text` (source spelling), `Value` (decoded value
  for `string` and for a `template` without substitutions; `$null` otherwise), `Dynamic` (`$true` for
  a template with substitutions), `Start` (offset), `Line` (1-based), `EndLine`, `Depth` (bracket
  depth at the token). Comments produce no token.
- Lexical rules: one leading U+FEFF and a line-1 hashbang are skipped; `//` and `/* */` comments
  (line counting kept); `'...'` and `"..."` with escapes (`\n`, `\t`, `\\`, quote escapes, `\x`,
  `\u{...}`, line continuation), a raw newline in an ordinary string is a lexical error; template
  literals with a `${ ... }` substitution stack (nested templates and braces); regular-expression
  literals when the previous significant token is absent, a punctuator other than `)`, `]`, `}`, or
  one of `return`, `typeof`, `instanceof`, `in`, `of`, `new`, `delete`, `void`, `throw`, `case`, `do`,
  `else`, `yield`, `await`, with `[...]` classes that may contain `/` and trailing flags; numbers
  with `_` separators, hex, octal, binary and BigInt `n`; identifiers including `#private` and
  Unicode escapes; decorators `@`.
- JSX (`-Jsx` only): `<` followed by an identifier or `>` where an expression can start begins an
  element; element depth, attribute strings, `{...}` expression children (normal tokenizer with brace
  counting), text runs (an apostrophe is not a string delimiter), closing and self-closing tags.
  `<T,>` and `<T extends ...>` are type parameters.
- Diagnostics (no analyzer identifier yet; analyzers re-emit them under their own identifier):
  `ts-lexical-invalid` and `token-limit`, each blocking.
- Implementation constraint: the scanner advances with `\G`-anchored .NET `[regex]` matches, one
  pattern per lexical state, so the PowerShell loop runs once per token, not once per character.

### `DocsCSharpTokens.psm1` (pure)

- `ConvertTo-DocsCSharpToken -Text <string> [-MaxTokens <int> = 250000] [-MaxDepth <int> = 256]`
  returns `@{ Tokens; HasConditional; Diagnostics }` with the shared token record.
- Lexical rules: `//`, `///`, `/* */` comments; a line whose first non-whitespace character is `#`
  produces no token, and both branches of `#if`/`#else` are tokenized without evaluation
  (`HasConditional` is `$true` when any `#if` exists); character literals; regular strings with
  escapes; verbatim `@"..."` with doubled quotes; interpolated `$"..."`, `$@"..."`, `@$"..."` with
  holes and `{{` escapes (`Dynamic` when a hole exists); raw strings `"""..."""` with quote-run length
  and `$$` brace width (a single-line raw string decodes to its content); the `u8` suffix;
  `@`-verbatim identifiers and `\u` escapes (decoded `Value`, `Text` preserved); contextual keywords
  (`record`, `partial`, `required`, `file`) as identifiers.
- Diagnostics: `csharp-lexical-invalid` and `token-limit`, each blocking.

### Analyzer functions (pure; 1020 analyzer contract)

Each analyzer is `Invoke-DocsAnalyzer<Name> -CapturedInput <object[]> -Selection <object>` and returns
`@{ Elements; Diagnostics }`. It throws only for a contract violation in its own arguments (for
example a `$null` `-CapturedInput`), never for content.

| Module | Function | Imports (literal joins) |
|---|---|---|
| `DocsAnalyzerTypeScriptCli.psm1` | `Invoke-DocsAnalyzerTypeScriptCli` | `DocsTypeScriptTokens.psm1`, `DocsScannerCommon.psm1`, `DocsSurface.psm1` |
| `DocsAnalyzerTypeScriptHttp.psm1` | `Invoke-DocsAnalyzerTypeScriptHttp` (pass 1: per-file routes, routers and plugins; pass 2: cross-file mount resolution) | same |
| `DocsAnalyzerTypeScriptExports.psm1` | `Invoke-DocsAnalyzerTypeScriptExports` | same |
| `DocsAnalyzerDotnetHttp.psm1` | `Invoke-DocsAnalyzerDotnetHttp` | `DocsCSharpTokens.psm1`, `DocsScannerCommon.psm1`, `DocsSurface.psm1` |
| `DocsAnalyzerDotnetConfig.psm1` | `Invoke-DocsAnalyzerDotnetConfig` | `DocsScannerCommon.psm1`, `DocsSurface.psm1` |
| `DocsAnalyzerDotnetApi.psm1` | `Invoke-DocsAnalyzerDotnetApi` | `DocsCSharpTokens.psm1`, `DocsScannerCommon.psm1`, `DocsSurface.psm1` |
| `DocsAnalyzerExtensionImport.psm1` | `Invoke-DocsAnalyzerExtensionImport`; `Test-DocsExtensionManifest -ManifestText <string> -ManifestPath <string> -CapturedInput <object[]> -Selection <object> -RegisteredAnalyzerId <string[]>` returning `@{ Ok; Diagnostics; Manifest; ResultDocument }` | `DocsScannerCommon.psm1`, `DocsSurface.psm1`, `DocsJson.psm1`, and `DocsAnalyzerRegistry.psm1` only when `Selection.registered_analyzer_ids` is absent |

Common analyzer rules:

- Inputs are processed in ordinal `path` order; a selected input whose `text` is `$null` yields one
  blocking `input-over-bound` or `input-undecodable` diagnostic (chosen from the captured
  diagnostic's code) under the analyzer's own identifier and no element.
- Identical element identities in one call keep the first site by line and emit a non-blocking
  `duplicate-declaration` (TypeScript overload signatures are merged and not reported).
- A declaration that `Get-DocsElementId` rejects is skipped with non-blocking `declaration-invalid`.
- Each analyzer module's comment-based help `.NOTES` names `Get-DocsScannerPrecisionLimit` as the
  shipped statement of its precision limit.

### Registry rows (edit of `DocsAnalyzerRegistry.psm1`)

One row per line, inserted directly under the `# --- 1033: TypeScript and .NET analyzers ---`
anchor of the scanner table `$script:DocsAnalyzerRow` (1020 v0.6; any `# --- 900NNN:` anchor is
rejected), in the 1020 row form `[pscustomobject]@{ Id; Version; AnalysisMethod; ElementKinds;
Module; Function }` with `Version = '1.0.0'`, `AnalysisMethod = 'scanner'` (the field name and value
as committed by 1020; C6) and `Module = (Join-Path -Path $PSScriptRoot -ChildPath '<leaf>')`.
Registry uniqueness is on (`Id`, `AnalysisMethod`), and `Invoke-DocsAnalyzer` rejects output whose
`analysis_method` differs from the row's `AnalysisMethod`:

| `Id` | `AnalysisMethod` | `ElementKinds` | `Module` leaf | `Function` |
|---|---|---|---|---|
| `typescript-cli` | `scanner` | `cli-command`, `cli-option` | `DocsAnalyzerTypeScriptCli.psm1` | `Invoke-DocsAnalyzerTypeScriptCli` |
| `typescript-http` | `scanner` | `http-route` | `DocsAnalyzerTypeScriptHttp.psm1` | `Invoke-DocsAnalyzerTypeScriptHttp` |
| `typescript-exports` | `scanner` | `public-symbol` | `DocsAnalyzerTypeScriptExports.psm1` | `Invoke-DocsAnalyzerTypeScriptExports` |
| `dotnet-http` | `scanner` | `http-route` | `DocsAnalyzerDotnetHttp.psm1` | `Invoke-DocsAnalyzerDotnetHttp` |
| `dotnet-config` | `scanner` | `config-key` | `DocsAnalyzerDotnetConfig.psm1` | `Invoke-DocsAnalyzerDotnetConfig` |
| `dotnet-public-api` | `scanner` | `public-symbol` | `DocsAnalyzerDotnetApi.psm1` | `Invoke-DocsAnalyzerDotnetApi` |
| `extension-import` | `scanner` | `cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`, `architecture-component` | `DocsAnalyzerExtensionImport.psm1` | `Invoke-DocsAnalyzerExtensionImport` |

No existing line of the registry changes; no row is added under any other anchor.

## Recognition Rules

### Declaration strings (1020 per-kind convention)

| Kind | 1020 convention | Form used by this feature |
|---|---|---|
| `cli-command` | full command path | `<root> <sub> ...`, for example `tool serve` |
| `cli-option` | command path, one space, long option | `tool serve --port`; a positional argument is spelled as its bare name (`tool serve file`) with property `positional: true`; a single-character yargs key is `-k` |
| `http-route` | upper-case method, one space, route template | `GET /items/:id` (Express and Fastify parameters verbatim); `GET /api/Items/{id:int}` (ASP.NET constraints verbatim); method `ANY` for every-method registrations (`app.all`, Fastify `all`, minimal-API `Map`) with property `framework_method` |
| `config-key` | dotted key path | `Logging.LogLevel."Microsoft.AspNetCore"`: a segment matching `^[A-Za-z0-9_-]+$` stays bare; any other segment is double-quoted with `"` and `\` escaped; an array member contributes `[]` (C10) |
| `public-symbol` | qualified name | TypeScript: module path from `Get-DocsScannerModulePath`, `.`, export name (`utils/strings.camelCase`; `default` for a default export). C#: `Namespace.Type.Member` with nested types dotted, source-spelled type parameters, and method parameter types with whitespace removed and `ref`, `out`, `in`, `params` kept (`Ns.Repository<T>.Find<TKey>(TKey)`), so overloads stay distinct |

Element identity also includes `path`, so a declaration needs to be unique only within one file.
Element `name`: the last command word (`cli-command`), the long option or positional name
(`cli-option`), the handler identifier when the handler is a named reference, else the template
(`http-route`), the last key segment (`config-key`), the export or member name (`public-symbol`).

### Declaration-lines span and digest

| Element source | `line_range` |
|---|---|
| CLI and HTTP registration calls | Line of the receiver token of the registering call through the line of its matching `)` (inline handlers included) |
| Attribute routes | First attribute line of the action through the line of the method header's closing `)` |
| TypeScript functions, classes, variables | The `export` line (decorators above included) through the line of the body-opening `{`, the terminating `;`, or the initializer start |
| TypeScript interfaces, type aliases, enums | Whole construct through its closing `}` or `;` |
| C# types | First attribute or modifier line through the line of the body-opening `{` |
| C# members | First attribute or modifier line through the line of the body-opening `{`, `=>`, or terminating `;` |
| Configuration keys | The key's line, start and end equal (raw line text; OQ-4 superseded, see below) |
| Imported findings | The finding's `source.line_range` |

Declaration-lines digest byte rule (C2): 1020 v0.4 `#### Declaration-lines digest (D5)` (one
leading U+FEFF removed; CRLF then CR normalized to LF; one trailing LF removed; lines `start..end`
selected, each followed by one LF; UTF-8 without BOM; `Get-DocsSha256Hex`). A line-ending conversion
therefore does not change a digest; an edit outside `line_range` does not change it; an edit inside
does. The digest is produced only by `New-DocsSurfaceElement -SourceText <captured text> -LineRange`;
an analyzer never computes, masks or supplies it, because `Invoke-DocsAnalyzer` recomputes it with
`Get-DocsDeclarationSha256` over the captured text and rejects a differing digest. For `config-key`
the digest therefore covers the raw key line, including its value literal; the OQ-4 masking default
is superseded by this rule and the concern is re-raised to the coordinator as a 1020 contract
question (`## Owner Questions`, OQ-4).

### `typescript-cli` (Commander and yargs)

Root name: a literal `new Command('x')`, `.name('x')` (Commander) or `.scriptName('x')` (yargs) on the
root receiver (property `name_source: literal`); otherwise `Get-DocsScannerModulePath` of the file
(`name_source: module`).

| Framework | Classified | Diagnostic |
|---|---|---|
| Commander | Root receivers: `program` imported from `commander`, `new Command(...)`, a variable assigned from either. `.command('name <arg> [opt]')`: first word is the command; remaining words are positional `cli-option` elements. In a chain, `.command(...)` returns the subcommand, so later `.option` or `.argument` calls apply to it; `.command('name', 'description')` returns the parent. `const sub = program.command('x')` tracks `sub`; `.addCommand(tracked)` parents a tracked command. `.option('-p, --port <n>')` (long flag from the `--` part, property `short` from the `-` part), `.requiredOption(...)` (`required: true`), `.addOption(new Option('--x'))` inline, `.argument('<file>')` (positional) | Non-literal or dynamic command or option strings, registration inside a loop body, spread arguments: `cli-dynamic-registration`. `.addCommand` with an untracked or imported receiver, `.command` on an untracked receiver: `cli-unbound-registration` |
| yargs | Root: `yargs(...)` or `yargs` imported from `yargs`, chained. `.command('serve [port]', ...)` (first word is the name; `$0` is the root); `.command({ command: 'x' \| ['x', 'alias'], ... })`; builder third argument as an arrow function whose parameter receives `.option` and `.positional`, or as an object literal whose keys are options; `.option('port', {...})` and `.options({ a: {...} })` (multi-character key `--key`, single-character key `-k`); `.positional('port', ...)` | `.command(require(...))`, `.command(importedModule)`, `.commandDir(...)`: `cli-command-module-unresolved`. Non-literal names and computed object keys: `cli-dynamic-registration` |

### `typescript-http` (Express and Fastify)

| Framework | Classified | Diagnostic |
|---|---|---|
| Express | Receivers: results of `express()`, `express.Router()` and `Router()` (import-aware). `<receiver>.<method>(path, ...)` for `get`, `post`, `put`, `delete`, `patch`, `options`, `head`, and `all` (`ANY`); an array of literal paths yields one element per path; `router.route(path).get(...).post(...)` chains. Mounts `app.use('/prefix', router)` and `router.use('/prefix', subRouter)` compose prefixes when the router is tracked in the same file or is the default or named export of a relative import that resolves to a captured input (`./x` to `x.ts`, `x.tsx`, `x.mts`, `x.cts`, `x/index.ts`); a router mounted n times yields n elements; a router never mounted keeps its own template with property `mounted: false` | Regex or non-literal path: `http-dynamic-route`, no element. Non-literal prefix: route kept with the segment rendered `<dynamic>`, property `prefix_resolved: false`, `http-prefix-dynamic`. `app.use(prefix, untrackedIdentifier)`: `http-mount-unresolved`. `app.use(middlewareCall(...))` is ignored without a diagnostic |
| Fastify | Receivers: results of `Fastify()` and `fastify()`, and the first parameter of a plugin function passed to `.register`. `<receiver>.<method>(url, [opts], handler)` for the same method set; `.route({ method: 'GET' \| ['GET', 'POST'], url: '/x' })` (also `path`); `.register(plugin, { prefix: '/v1' })` with an inline function, a same-file named function or the default export of a resolvable relative import; `fp(fn)` from `fastify-plugin` treated as `fn` | Non-literal method or url: `http-dynamic-route`. Non-literal prefix: `<dynamic>` rule, `http-prefix-dynamic`. Plugin from a package import: `http-mount-unresolved` |

The method token is upper-case; the implicit `HEAD` for `GET` is not emitted.

### `typescript-exports`

Classified (one `public-symbol` per exported name, property `symbol_kind` in `function`,
`async-function`, `generator`, `class`, `abstract-class`, `variable`, `interface`, `type`, `enum`,
`namespace`, `reexport`): `export function`, `export async function`, `export function*`,
`export class`, `export abstract class`, `export const`/`let`/`var` with simple declarators,
`export const { a, b } = ...` with simple identifiers, `export interface`, `export type X =`,
`export enum`, `export const enum`, `export declare ...`, `export namespace N { export ... }` (nested
names `N.f`), `export default ...` (name `default`, property `local_name` for a named default),
`export { a, b as c }`, `export { a as default }`, `export type { A }` (`type_only: true`),
`export { x } from './y'` and `export * as ns from './y'` (property `reexport_from`),
`export * from './y'` expanded from a resolvable relative module with a visited set and depth bound
16; overload signatures of one function yield one element with property `overloads`.

Diagnostics: `export * from 'package'`, an unresolvable relative specifier, a re-export cycle or a
depth overflow: `ts-reexport-unresolved`. Destructuring with defaults, rest or nested patterns:
`ts-export-pattern-unsupported`. `export =`: `ts-export-assignment`, with element `default` and
property `export_form: assignment`. `declare module 'x' { ... }` and `declare global` bodies:
`ts-ambient-module`, skipped. CommonJS `module.exports` or `exports.x` in a TypeScript file:
`ts-commonjs-export`, skipped.

### `dotnet-http`

| Construct | Classified | Diagnostic |
|---|---|---|
| Attribute routing | Controller class: name ending in `Controller`, or `[ApiController]` or `[Controller]` attribute, or base `Controller` or `ControllerBase`. Class `[Route("api/[controller]")]` prefix; action attributes `[HttpGet]`, `[HttpGet("{id}")]`, `[HttpPost]`, `[HttpPut]`, `[HttpDelete]`, `[HttpPatch]`, `[HttpHead]`, `[HttpOptions]`, `[Route("x")]` combined with a verb attribute, `[AcceptVerbs("GET", "POST")]`; `Name =` and `Order =` ignored. `[controller]` is the class name without `Controller`; `[action]` is the method name without an `Async` suffix; `[area]` comes from a literal `[Area("x")]` on the class. A template beginning `/` or `~/` overrides the class prefix. Multiple route or verb attributes yield one element per combination. Literal-only `+` concatenation folds | `[Route(Constants.X)]`, `nameof(...)`, interpolated strings with holes: `http-dynamic-route`. `[area]` without a literal `[Area]`: `http-route-token-unresolved`. A verb attribute in a class with no route whose base is not `Controller` or `ControllerBase`: `dotnet-route-inherited-unresolved`. `MapControllerRoute` and `MapDefaultControllerRoute`: `dotnet-conventional-routing-unresolved` |
| Minimal APIs | `<receiver>.MapGet`, `MapPost`, `MapPut`, `MapDelete`, `MapPatch("/x", ...)`; `MapMethods("/x", new[] { "GET", "HEAD" }, ...)` and `["GET"]` collection expressions; `Map("/x", ...)` as `ANY`; `var g = app.MapGroup("/api")` and chained `.MapGroup("/a").MapGroup("/b")` compose prefixes, including nested group variables | Non-literal template or method list: `http-dynamic-route`. Group with a non-literal prefix: `<dynamic>` rule, `http-prefix-dynamic`. A `Map*` call on a method parameter: route kept without prefix, `prefix_resolved: false`, `http-receiver-unresolved`. `MapHub<T>`, `MapGrpcService<T>`, `MapHealthChecks`, `MapFallback`, `MapRazorPages`: `http-endpoint-kind-unsupported`, once per kind and file |

Templates are normalized to begin with `/`; case is kept as written. A file with `#if` also yields
non-blocking `csharp-conditional-compilation`.

### `dotnet-config`

- Validity gate: `System.Text.Json.JsonDocument.Parse` with `CommentHandling = Skip`,
  `AllowTrailingCommas = $true`, `MaxDepth = 64`. A lexical JSONC key walker in the same module
  supplies key lines, because `JsonDocument` carries no line numbers.
- Elements: one `config-key` per object member path, with properties `value_type` (`object`,
  `array`, `string`, `number`, `boolean`, `null`), `configuration_path` (colon form, for example
  `Logging:LogLevel:Default`) and `environment` (the middle segment of `appsettings.<name>.json`, when
  present). Keys of objects inside arrays are unioned under `[]`. No value is read into output.
- Diagnostics: invalid JSON or a non-object root: `json-invalid`, blocking, no element. An empty or
  whitespace-only selected `appsettings*.json` is invalid JSON and yields exactly one blocking
  `json-invalid` and no element. A duplicate member at one path: `duplicate-declaration`, the
  element keeps the first line. More than 10000 keys: `input-key-limit`, blocking, no element.

### `dotnet-public-api`

- Classified types (`public`): `class`, `record`, `record struct`, `struct`, `interface`, `enum`,
  `delegate`, in file-scoped or block namespaces (nested); nested types whose effective accessibility
  through the containing chain is public; a `partial` type yields one type element at the ordinally
  first path among its parts (property `partial_parts`), members in the file that declares them.
- Classified members of public types with `public`, `protected` or `protected internal`
  accessibility (property `accessibility`): methods (including `static`, `abstract`, `virtual`,
  `override`, `async`, extension methods), constructors (`Ns.Type.Type(int)`), properties, indexers
  (`Ns.Type.this[int]`), fields and `const`, events, operators and conversion operators; interface
  members; enum members (`symbol_kind: enum-member`); positional record parameters as properties.
  Property `symbol_kind` in `class`, `record`, `struct`, `interface`, `enum`, `delegate`, `method`,
  `constructor`, `property`, `indexer`, `field`, `constant`, `event`, `operator`, `enum-member`.
- Excluded without a diagnostic: types with no modifier, `internal`, `private`, `file`; members
  `private`, `internal`, `private protected`; explicit interface implementations.
- Diagnostics: members inside `#if` regions declared twice: `duplicate-declaration`; a declaration
  the scanner cannot delimit (unbalanced braces, unsupported syntax): `csharp-declaration-unrecognized`
  with no element for that declaration; a file with `#if`: `csharp-conditional-compilation`.

## Scanner Precision Limit

This section is normative. Each row is a construct class that the scanner reports instead of
classifying. Every code is a lowercase identifier, emitted at most once per
`(analyzer_id, code, path)`, with the occurrence count and first line in the message.
`Get-DocsScannerPrecisionLimit` returns exactly these rows.

Emission contract (1023 `### #1022 and #1033 (PowerShell scanners) for precision-limit
diagnostics`, owner decision P3; C5). Every diagnostic whose `(analyzer_id, code)` is a row of the
table below is built by `New-DocsScannerPrecisionLimitDiagnostic` and:

- has `analyzer_id` equal to the registered scanner identifier (registry row `AnalysisMethod`
  `scanner`) and `path` equal to the relative path of the input file, never `$null`;
- carries `extensions` containing the key `docs.precision-limit` with the value
  `{"element_kind": "<element kind>"}`, where the kind is the row's `Element kind` column: the
  element kind the scanner would have emitted had it classified the construct;
- has severity `warning` (blocking `false`). A precision-limit diagnostic reports a construct the
  scanner left unclassified, which the ledger must record as a `deferred` entry, so it uses the
  non-blocking severity above `information`, which 1020 reserves for non-blocking notices; both are
  permitted by 1020's `New-DocsDiagnostic` contract.

Diagnostics for every other condition, including oversize and undecodable inputs and every code in
the list of codes that are not precision limits below, carry no `docs.precision-limit` key.

Ledger representation (C9, OQ-2, resolved by 1023 `### Scanner precision limits (D3)`): 1023 reads
only marked diagnostics and records one `deferred` ledger entry per `(analyzer_id, code, path)`,
keyed from the marked diagnostic: its element id is `Get-DocsElementId` over the marker's
`element_kind`, the diagnostic `path` and the diagnostic `id` as the declaration, and the entry's
`kind` is the marker's `element_kind`. Because the diagnostic `id` is derived from
`(analyzer_id, code, path)`, one entry covers every occurrence of that code in that file. Closing a
row is the purpose of the later, optional native TypeScript or C# analyzer.

Element-kind rule: each row has exactly one element kind, fixed per `(analyzer_id, code)`, so the
marker and the ledger entry are deterministic. For an analyzer with one element kind, that kind is
used. For `typescript-cli`, `cli-dynamic-registration` covers both command and option names and is
assigned `cli-command`, because an option is declared on a command and the per-file entry stands
for the unclassified command surface of that file; the other two `typescript-cli` rows concern
command definitions only.

| Analyzer id | Diagnostic code | Element kind | Construct | Why it is not classified | Consequence |
|---|---|---|---|---|---|
| `typescript-cli` | `cli-dynamic-registration` | `cli-command` | Non-literal or template-with-substitution command or option names, registration in a loop body, spread arguments, computed object keys | The name exists only at run time; a lexical scanner cannot evaluate expressions | No element |
| `typescript-cli` | `cli-unbound-registration` | `cli-command` | `.addCommand` or `.command` on a receiver that is not tracked in the file | Receiver identity needs data-flow or cross-module type information | No element |
| `typescript-cli` | `cli-command-module-unresolved` | `cli-command` | yargs `.command(require(...))`, `.command(importedModule)`, `.commandDir(...)` | The command definition lives in another module or directory loaded at run time | No element |
| `typescript-http` | `http-dynamic-route` | `http-route` | Regex or non-literal path, non-literal method or url | The template exists only at run time | No element |
| `typescript-http` | `http-prefix-dynamic` | `http-route` | Mount or plugin prefix that is not a literal | The prefix exists only at run time | Element with a `<dynamic>` segment and `prefix_resolved: false` |
| `typescript-http` | `http-mount-unresolved` | `http-route` | `use` with an untracked router, plugin from a package import | Resolution needs module resolution outside the captured relative set | Routes of the mounted router keep their own template (`mounted: false`) or are absent when the router is not captured |
| `typescript-exports` | `ts-reexport-unresolved` | `public-symbol` | `export *` from a package, an unresolvable relative specifier, a cycle, depth above 16 | Needs package resolution or unbounded expansion | Re-exported names absent; other exports kept |
| `typescript-exports` | `ts-export-pattern-unsupported` | `public-symbol` | Exported destructuring with defaults, rest or nested patterns | Binding names need pattern evaluation beyond simple identifiers | No element for the pattern |
| `typescript-exports` | `ts-export-assignment` | `public-symbol` | `export =` | The exported shape is the assigned expression | Element `default` with `export_form: assignment` |
| `typescript-exports` | `ts-ambient-module` | `public-symbol` | `declare module 'x' { ... }`, `declare global` | Ambient declarations describe another module's surface | No element |
| `typescript-exports` | `ts-commonjs-export` | `public-symbol` | `module.exports`, `exports.x` in a TypeScript file | Run-time assignment, not a declaration | No element |
| `dotnet-http` | `http-dynamic-route` | `http-route` | `[Route(Constants.X)]`, `nameof(...)`, interpolated templates with holes, non-literal minimal-API template or method list | Constant folding and interpolation need semantic analysis | No element |
| `dotnet-http` | `http-prefix-dynamic` | `http-route` | `MapGroup` with a non-literal prefix | The prefix exists only at run time | Element with a `<dynamic>` segment and `prefix_resolved: false` |
| `dotnet-http` | `http-receiver-unresolved` | `http-route` | `Map*` on a method parameter (`IEndpointRouteBuilder` or `RouteGroupBuilder` extension method) | The caller's group prefix needs call-graph analysis | Element without prefix, `prefix_resolved: false` |
| `dotnet-http` | `http-route-token-unresolved` | `http-route` | `[area]` without a literal `[Area]` | The token value is not in the file | No element |
| `dotnet-http` | `http-endpoint-kind-unsupported` | `http-route` | `MapHub<T>`, `MapGrpcService<T>`, `MapHealthChecks`, `MapFallback`, `MapRazorPages` | The endpoint set is generated by the framework | No element |
| `dotnet-http` | `dotnet-route-inherited-unresolved` | `http-route` | Verb attribute in a class with no route whose base is not `Controller` or `ControllerBase` | The prefix is inherited from a base class in another file | No element |
| `dotnet-http` | `dotnet-conventional-routing-unresolved` | `http-route` | `MapControllerRoute`, `MapDefaultControllerRoute` | Conventional routes are computed from controller discovery at run time | No element |
| `dotnet-http` | `csharp-conditional-compilation` | `http-route` | File containing `#if` | Branches are not evaluated; both are scanned | Elements from both branches; duplicates reported as `duplicate-declaration` |
| `dotnet-public-api` | `csharp-declaration-unrecognized` | `public-symbol` | Declaration the scanner cannot delimit | Unsupported syntax or unbalanced braces | No element for that declaration |
| `dotnet-public-api` | `csharp-conditional-compilation` | `public-symbol` | File containing `#if` | Branches are not evaluated; both are scanned | Elements from both branches; duplicates reported as `duplicate-declaration` |

Limits without a diagnostic code: JavaScript files are not selected (OQ-3); a UTF-16 source is
undecodable under strict UTF-8 and yields blocking `input-undecodable`; `dotnet-config` has no
precision-limit row because it parses the complete JSON document.

`extension-finding-skipped` is not a precision limit (P3). The skipped finding was produced by an
external adapter, not by the docs scanner, and its kind is by definition either not a docs element
kind or lacks the declaration or line range a docs element needs, so no deterministic
`element_kind` exists. It stays a non-blocking diagnostic (`warning`) without the marker and is
listed below.

Codes that are not precision limits (blocking unless stated; none carries the
`docs.precision-limit` key): `input-over-bound`, `input-undecodable`, `ts-lexical-invalid`,
`csharp-lexical-invalid`, `token-limit`, `json-invalid`, `input-key-limit`, the extension rejection
codes below, and the non-blocking `declaration-invalid`, `duplicate-declaration`,
`extension-finding-skipped`, `extension-repository-unverified` and `extension-revision-unverified`.

## Extension-Result Manifest Import

Selection and parsing: a selected input is parsed with `ConvertFrom-DocsJsonText` (duplicate keys
rejected). Discovery schemas are not pushed down, so validation is a PowerShell structural check of
the closed key set and constants of `schemas/discovery/v2/extension-result-manifest.schema.json`, not
`Test-Json`.

Validation order. The first failing check rejects the whole manifest with one blocking diagnostic
whose `path` is the manifest path, and the manifest contributes no element:

| Step | Check | Rejection code |
|---|---|---|
| 1 | Closed key set and constants (`$schema`, `schema_version` `2.0.0`, `artifact_kind`), field shapes, manifest `id` unique across selected manifests | `extension-manifest-invalid` |
| 2 | `manifest_sha256` equals `Get-DocsSha256Hex` of `ConvertTo-DocsCanonicalJson` of the manifest without its root `manifest_sha256` member (a canonical-JSON failure, such as a fractional number, is reported under step 1's code) | `extension-manifest-digest-mismatch` |
| 3 | When `Selection.repository_id` is present and non-null, `repository.id` equals it (when it is absent or null, non-blocking `extension-repository-unverified` and the check continues); when `Selection.revision` is present and non-null, `repository.revision` equals it (when it is absent or null, non-blocking `extension-revision-unverified` and the check continues). A `-Selection` carrying neither key, which is what the 1022 inventory passes today (C3), therefore accepts a valid manifest with the two unverified diagnostics | `extension-repository-mismatch` |
| 4 | `adapter.id` is not a registered docs analyzer identifier and is unique across selected manifests | `extension-adapter-invalid` |
| 5a | Every `source_inputs[].path` is a captured input | `extension-input-not-captured` |
| 5b | Every `source_inputs[]` `sha256` and `size` equal the captured input's | `extension-input-digest-mismatch` |
| 6a | Every `result_files[]` path is a captured input with equal `sha256` and `size` | `extension-result-digest-mismatch` |
| 6b | Each referenced result document parses and has the referenced `id`, `artifact_kind`, `schema_version`, the manifest's repository and revision, and `tool` and `analyzers` equal to the adapter | `extension-result-invalid` |
| 7 | Every finding's `analyzer` equals the adapter, `source.path` is a declared source input with equal `sha256`, and `line_range` lies within the captured text's physical line count | `extension-finding-source-mismatch` |

`input_manifest_sha256` is carried as an opaque value and is not verified: it is computed by the
discovery runtime from the discovery profile, which the docs lib does not have.

Merge as inert data (step 8, after every check passes):

- Nothing from the manifest is executed, imported or invoked, and no adapter-supplied identity is
  trusted: values are copied as data.
- A finding becomes one element when its `kind` is a docs element kind and `source.symbol` and
  `source.line_range` are present: `path` is `source.path`; `declaration` is `source.symbol`;
  `name` is the string property `name` when present, else the declaration; `element_id` is recomputed
  with `Get-DocsElementId`; `analyzer_id` is `extension-import`; the declaration-lines digest is
  computed by the docs lib from the captured source text, never taken from the adapter; properties
  `adapter_id`, `adapter_version`, `classification`, `confidence` and `finding_id` are copied as
  scalars, and `classification` and `confidence` are never upgraded.
- A `cli-option` finding needs a `parent_symbol` property (and optional `parent_path`, default the
  same path) to compute its parent `cli-command` identifier.
- For `config-key`, only the `value_type` property is copied, so an adapter cannot pass a
  configuration value through.
- Manifest and result-file diagnostics are copied with their `blocking` flags under analyzer
  `extension-import`.
- Analysis method of imported elements: OQ-1 (provisional default: the manifest root `extensions`
  key `docs.analysis-method` with value `native` or `scanner`; `scanner` when absent).
- Collision with a built-in element of the same `element_id` is resolved by 1022's inventory merge,
  not by this analyzer (C8; provisional default: built-in wins, imported element dropped with a
  non-blocking diagnostic).

## Data & State

- Element identity is 1020's `Get-DocsElementId` over `{declaration, kind, path}`; no other identity
  source is used.
- Output order: elements by `element_id`, diagnostics by `id`, ordinal; inputs iterated by ordinal
  path; every hashtable whose keys reach output is enumerated through an ordinal key sort. Shuffling
  `-CapturedInput` produces identical output bytes.
- No clock, random source, environment variable, file read or module-scope cache.
- Configuration values never enter output as text: `dotnet-config` emits key paths and shapes only;
  the importer copies only `value_type` for `config-key`. The `config-key` digest is 1020's
  declaration-lines digest of the raw key line (OQ-4 superseded by D5; `### Declaration-lines span
  and digest`).
  Source string literals appear in output only where they are the declaration (route templates,
  option and command names).
- Persistence: none. The inventory snapshot that contains these elements is written by 1022.
- Migration or backfill: none.

## Constraints & Risks

- Language rule: every artifact is PowerShell, JSON or Markdown; no Python or TypeScript file is
  created or edited. Any artifact that cannot follow the rule is an owner question, not a decision;
  none was found (`## Artifact Classification`).
- PowerShell 7 built-ins only (epic A8): `System.Text.Json` and .NET `[regex]`; no third-party module.
- Contract churn: 1020 (D3/D5 amendment) and 1022 are re-prepared concurrently. Every consumed 1020
  or 1022 symbol is a contract dependency (`## Contract Dependencies on 1020 and 1022`). The plan's
  first phase re-reads the merged 1020 amendment and the re-prepared 1022 spec and records the final
  name of each consumed symbol before any module is written.
- Precision: lexical scanning is less precise than a parser; unclassified constructs surface as the
  documented precision limit.
- Performance: a per-character PowerShell loop over 1 MiB is slow; tokenizers use `\G`-anchored
  regex matches per lexical state.
- File size: new files have no baseline entry; production files stay at or below 500 logical lines
  (1020's criterion for `.claude/lib/docs/`). The TypeScript tokenizer, the TypeScript HTTP analyzer
  and the .NET API analyzer are the largest candidates; `DocsScannerCommon.psm1` and, if needed,
  `DocsTypeScriptJsx.psm1` are planned splits.
- Dynamic invocation: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  rejects `&` on a variable or expression and `Invoke-Expression` in `.claude/lib`; no analyzer calls
  a function by a computed name.
- Import cycle: `DocsAnalyzerExtensionImport.psm1` imports `DocsAnalyzerRegistry.psm1` only when
  `Selection.registered_analyzer_ids` is absent; the plan verifies that the registry seam's `-Force`
  import of the analyzer does not re-enter the registry module in a way that breaks either module.
- Shared append-only edit points with 1022 and 900011: `DocsAnalyzerRegistry.psm1`, its mirror, and
  `core.json`; conflicts are resolved in this feature's remediation loop.
- Existing tests changed by this feature: none expected. 1020 v0.6 (owner decision P1) made its
  `DocsAnalyzerRegistry.Tests.ps1` a membership suite with no row-count assertion, so this feature
  does not edit it. Only if the suite as merged still contains a row-count or empty-registry
  assertion does this feature replace that assertion with anchor presence plus membership
  (disposition: updated, recorded in the plan) (C6).
- Test isolation: suites remove every imported `Docs*` and `DiscoveryEncoding` module in `AfterAll`.
- CI-only behavior: `.gitattributes` converts committed CRLF to LF, so CRLF and BOM fixtures are
  built in code.
- Batch budget: the production file count exceeds the direct-mode cap; execution runs on the large
  route in the item worktree.
- Execution prerequisite: 1020 with its D3/D5 amendment merged into the epic integration branch.

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); D = epic `### Artifact classes for this epic` (schema, configuration, data, test
and documentation rows). "Avoid new Python" applies to every row.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsScannerCommon.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsTypeScriptTokens.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsTypeScriptJsx.psm1` (only if the tokenizer would exceed 500 logical lines) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsCSharpTokens.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerDotnetConfig.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerDotnetApi.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerExtensionImport.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (edit: rows under the 1033 anchor) | pushed-down helper/lib | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/<each file above>` (create, or edit for the registry mirror) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit: append each new `.claude/lib/docs/` file) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsScannerCommon.Tests.ps1`, `DocsTypeScriptTokens.Tests.ps1`, `DocsTypeScriptJsx.Tests.ps1` (conditional), `DocsCSharpTokens.Tests.ps1`, `DocsAnalyzerTypeScriptCli.Tests.ps1`, `DocsAnalyzerTypeScriptHttp.Tests.ps1`, `DocsAnalyzerTypeScriptExports.Tests.ps1`, `DocsAnalyzerDotnetHttp.Tests.ps1`, `DocsAnalyzerDotnetConfig.Tests.ps1`, `DocsAnalyzerDotnetApi.Tests.ps1`, `DocsAnalyzerExtensionImport.Tests.ps1`, `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1`, `DocsScannerContract.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/Docs.ScannerTestSupport.psm1` (in-memory captured-input and manifest builders) | test | PowerShell (Pester support) | D |
| `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` (conditional edit: only if the merged suite still contains a row-count or empty-registry assertion, which 1020 v0.6 removes; that assertion becomes anchor presence plus membership) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/**` (spec, user story, plan, research, evidence) | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, schema file, Python file or TypeScript file is
created or edited. `quality-tiers.yml`, `config/poshqc-scan.json` and `config/poshqc-coverage.json`
are not edited (1020 adds `.claude/lib/docs` as T3; the PoshQC configuration already covers
`.claude/lib` and `tests/scripts`). Every artifact follows the language rule; no owner exception is
needed.

## Contract Dependencies on 1020 and 1022

Each dependency names the recommended default the plan uses until the upstream specification fixes
it. A divergent upstream decision is adopted and recorded in the plan; it does not change this
feature's scope.

| ID | Dependency | Recommended default used by the plan |
|---|---|---|
| C1 | `analysis_method` on snapshot elements (D3 amendment of 1020): field name, enum and `New-DocsSurfaceElement` parameter | Required element field `analysis_method` with enum `native`, `scanner`, set through `-AnalysisMethod` |
| C2 | Declaration-lines digest (D5): storage field and byte rule | `source_sha256` is redefined as the digest over the `line_range` lines (file digest stays in snapshot `inputs[].sha256`); `line_range` non-null for every scanner element; byte rule as in `### Declaration-lines span and digest`; the functions live in 1020 `DocsSurface.psm1` (1020 v0.4: `ConvertTo-DocsDeclarationText` and `Get-DocsDeclarationSha256 -Text -LineRange`), else `DocsScannerCommon.psm1` creates `Get-DocsScannerDeclarationText` and `Get-DocsDeclarationSha256` with the same contract; the digest is set only through `New-DocsSurfaceElement -SourceText` |
| C3 | Shape of `-Selection` | The profile `surface_selection` hashtable plus `repository_id`, `revision` and `registered_analyzer_ids`, requested from the 1022 inventory through a coordinator item (plan `## Open Questions / Notes`); 1022 step 7 defines no key today, so the plan records each key as PRESENT or ABSENT and every key is optional on this feature's side (`## Inputs / Outputs`) |
| C4 | `New-DocsCapturedInput`: `-MaxBytes` default, BOM handling, codes and `analyzer_id` for oversize and undecodable inputs | Default 1048576 supplied by the inventory; one leading U+FEFF stripped before decoding; codes `input-over-bound` and `input-undecodable`; analyzers re-emit under their own identifier |
| C5 | Precision-limit marker: 1020 v0.6 `New-DocsDiagnostic` takes `-Severity error\|warning\|information` and has no extensions parameter; 1023 requires the `docs.precision-limit` marker | Resolved in favor of 1023 (owner decision P3): every precision-limit diagnostic carries `extensions` with the key `docs.precision-limit` and value `{"element_kind": "<element kind>"}` (the row's `Element kind` in `## Scanner Precision Limit`), `path` never `$null`, severity `warning` (blocking `false`); `New-DocsScannerPrecisionLimitDiagnostic` in `DocsScannerCommon.psm1` builds the record with `New-DocsDiagnostic` and sets the marker on its `extensions` member, so no 1020 file is edited; diagnostics for other conditions carry no such key |
| C6 | Registry: anchor literal; the row method field (1020: `AnalysisMethod`, value `scanner`); 1020's registry suite; the `DocsAnalyzer*.psm1` leaf rule | Resolved by 1020 v0.6 (owner decision P1): the anchor is `# --- 1033: TypeScript and .NET analyzers ---` in `$script:DocsAnalyzerRow`, and any `# --- 900NNN:` anchor is rejected; every row carries `AnalysisMethod = 'scanner'`; registry suites assert membership only (anchor and scanner table exist, rows found by `Id` and `AnalysisMethod` in `Get-DocsAnalyzerRegistration`), never a row count or exclusivity count of the committed table; 1020's suite is edited only if it still contains a row-count assertion; use `DocsAnalyzerExtensionImport.psm1` |
| C7 | `diagnostic.code` grammar in docs common (1020 lists `code` without a type) | Discovery identifier grammar; this feature's codes use lowercase words joined by `-` |
| C8 | Inventory merge precedence for an imported element colliding with a built-in element (1022 `DocsInventory.psm1`) | Built-in wins; imported element dropped with a non-blocking diagnostic |
| C9 | Ledger representation of the scanner precision limit as `deferred` with an owner (1023) | Resolved by 1023 `### Scanner precision limits (D3)`: one `deferred` entry per `(analyzer_id, code, path)`, keyed from the marked diagnostic (element id over the marker's `element_kind`, the diagnostic `path` and the diagnostic `id`); this feature guarantees stable codes, the marker (C5), `## Scanner Precision Limit` and `Get-DocsScannerPrecisionLimit` |
| C10 | Cross-child consistency with the re-prepared 1022: config key quoting and `[]` array segments, `<dynamic>` prefix rendering, shared codes `declaration-invalid`, `duplicate-declaration`, `input-over-bound`, `input-undecodable` | The strings in this specification; agreed in the epic `### Analyzer decisions` section |

The JSON envelope schema of D5 does not affect this feature, which adds no subcommand.

## Decisions Later Children Must Honor

- Analyzer identifiers `typescript-cli`, `typescript-http`, `typescript-exports`, `dotnet-http`,
  `dotnet-config`, `dotnet-public-api` and `extension-import` are reserved. A later native TypeScript
  or C# analyzer emits the same element kinds, declarations and declaration-lines digests for every
  construct both classify, so ledger pins stay valid when the analysis method changes (as 900011 does
  for Python), and records `analysis_method: native`.
- Diagnostic codes are lowercase words joined by `-` (within the discovery identifier grammar).
  Codes are stable: changing, adding or removing one increments the analyzer's registration
  `Version`. The shared codes `input-over-bound`, `input-undecodable`, `declaration-invalid` and
  `duplicate-declaration` keep one meaning across analyzers.
- Precision-limit rows are `(analyzer_id, code)` pairs, each with one fixed `element_kind`.
  `Get-DocsScannerPrecisionLimit` is the machine-readable source and `## Scanner Precision Limit` is
  the normative text. Precision-limit diagnostics are non-blocking `warning` diagnostics, emitted at
  most once per `(analyzer_id, code, path)` with a non-null `path`, and carry `extensions` with the
  key `docs.precision-limit` and value `{"element_kind": "<element kind>"}` (C5, owner decision
  P3); no other diagnostic carries that key. 1023 records one `deferred` entry per
  `(analyzer_id, code, path)` keyed from the marked diagnostic (C9). A later native TypeScript or C#
  analyzer emits elements, not marked diagnostics, for the constructs it classifies.
- Registry rows of this feature live under `# --- 1033: TypeScript and .NET analyzers ---`; a suite
  asserts membership only, never a row count of the committed registry tables.
- Declaration forms per kind and the declaration-lines byte rule in `## Recognition Rules` apply to
  every TypeScript and .NET analyzer, scanner or native.
- Extension-result manifests are imported only through `extension-import`: every declared digest is
  verified against captured inputs; any failure rejects the whole manifest with one blocking
  diagnostic and no element; accepted findings are copied as inert data with recomputed identifiers
  and digests; an adapter identifier may not equal a registered docs analyzer identifier;
  `input_manifest_sha256` is not verified.
- The rejection codes in `## Extension-Result Manifest Import` and the `docs.analysis-method`
  extensions key (subject to OQ-1) are part of the import contract.

## Owner Questions

OQ-2 and OQ-5 are resolved (owner decisions P3 and P1). The others are not decided; each
provisional default is used by the plan until the owner answers, and an answer may change the
affected criteria through a specification revision.

1. **OQ-1 - Analysis method of imported elements.** D3 allows `native` or `scanner`, but an element
   imported from an extension-result manifest was produced by neither the docs scanner nor a docs
   native analyzer. Options: (a) add a third value such as `imported` to the 1020 enum; (b) let the
   manifest declare it through the extensions key `docs.analysis-method` (`native` or `scanner`),
   with `scanner` when absent as the conservative assumption; (c) always record `scanner`.
   Provisional default: (b).
2. **OQ-2 - Ledger representation of the precision limit.** The ledger is keyed by element
   identifier, and an unclassified construct has no element. Should 1023 record the precision limit
   as a ledger section keyed by `(analyzer_id, diagnostic code)`, should the ledger schema accept a
   diagnostic identifier, or should the precision limit be recorded only in documentation with no
   ledger entry? Status: resolved by 1023 and owner decision P3. 1023 `### Scanner precision limits
   (D3)` records one `deferred` entry per `(analyzer_id, code, path)` in the existing ledger entry
   shape, keyed from the diagnostic marked with `docs.precision-limit` and its `element_kind` (C5,
   C9).
3. **OQ-3 - JavaScript sources.** Express, Fastify, Commander and yargs code is often plain
   JavaScript (`*.js`, `*.mjs`, `*.cjs`, `*.jsx`), which the same tokenizer can read. Should
   JavaScript inputs be selected in this feature? Provisional default: out of scope, listed as a
   limit without a diagnostic code in `## Scanner Precision Limit`.
4. **OQ-4 - Digest of a configuration key line.** D5 requires the element digest to cover the
   declaration's lines, and the analyzer guarantee forbids value leakage. A digest over a raw
   `appsettings*.json` line includes the configuration value and allows a low-entropy value to be
   confirmed by hashing guesses. Should the `config-key` digest cover the line with values replaced
   by their type names, the raw line, or only the key path and value type? Status: the masking
   default is superseded by 1020 v0.4 D5, under which `New-DocsSurfaceElement -SourceText` is the
   only digest path and `Invoke-DocsAnalyzer` rejects a digest that differs from the recomputation
   over the raw captured text; this feature hashes the raw key line and re-raises the question to
   the coordinator as a 1020 contract question (a masked-text rule would have to live in 1020's
   `ConvertTo-DocsDeclarationText`). Provisional default in effect: the raw line.
5. **OQ-5 - Anchor numbering.** Should registry anchors carry manifest placeholder numbers or
   issue numbers? Status: resolved by 1020 v0.6 (owner decision P1): every anchor carries the real
   issue number, any `# --- 900NNN:` anchor is rejected, and this feature's anchor is
   `# --- 1033: TypeScript and .NET analyzers ---` as committed by 1020 (C6). The earlier default
   of keeping the placeholder text is superseded.

## Non-Goals

- Native TypeScript and C# analyzers (TypeScript compiler API, Roslyn). They are later, optional
  children under D3; this feature is the baseline scanner.
- The `inventory` subcommand, snapshot assembly, profile exclusions, captured-input construction and
  the inventory merge (1022).
- The coverage ledger representation of the precision limit (1023).
- JavaScript inputs (OQ-3), Razor, Blazor, gRPC service definitions, SignalR hubs, OpenAPI documents,
  `.csproj` or `launchSettings.json` surfaces, and environment-specific configuration providers other
  than `appsettings*.json`.
- Calling the Python discovery runtime, the TypeScript compiler, Roslyn, Node.js or `dotnet`.
- Verifying `input_manifest_sha256` of extension manifests.
- Any change to discovery schemas, the discovery runtime or `.claude/lib/discovery-validation/`.
- Any Python or TypeScript code.

## Implementation Strategy

- Phase order (recommended): confirm the merged 1020 amendment and re-prepared 1022 contracts and
  record C1-C10 outcomes; `DocsScannerCommon.psm1`; the two tokenizers; the six scanners; the
  importer; registry rows and the registry membership suite (plus the conditional 1020 suite edit,
  C6); mirrors and `core.json` entries in the same
  task as each module; cross-cutting contract suite; coverage, isolation and contract-test evidence.
- Fixtures are single-quoted here-strings inside the suites, converted to captured inputs with 1020's
  `New-DocsCapturedInput` over in-memory bytes; CRLF, BOM and oversize variants are built in code.
- Dependency changes: none. Logging: none (diagnostics are data). Rollout: additive; destination
  repositories receive the analyzers through the existing Claude push-down and select them by
  identifier in the profile (or by default through element kinds).

## Numeric Derivation Reference

The acceptance criteria enumerate the seven analyzer identifiers and the new production module
names. Both are supported by complete `## Numeric Derivation Evidence` records in the research file
(claim N3 for the analyzer identifiers, claim N2 for the production modules). No other count is
asserted.

## Acceptance Criteria

All Pester suites named below live under `tests/scripts/claude-lib/docs/` and run in CI in the
required check `poshqc / PowerShell QC` (Windows shards with coverage). Fixtures are in memory.
No test starts a process, waits on a real timer or resolves an executable on PATH; every input is
built in memory.

- [ ] `DocsTypeScriptTokens.Tests.ps1` and `DocsCSharpTokens.Tests.ps1` assert token kinds, decoded `Value`, `Dynamic`, `Line` and `Depth` for each lexical state (escapes, template substitution nesting, regex versus division, JSX text with an apostrophe, verbatim, interpolated and raw strings, directive lines, BOM and hashbang), and assert that a lexical error and a token or depth overflow each yield one blocking diagnostic (`ts-lexical-invalid`, `csharp-lexical-invalid`, `token-limit`) (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerTypeScriptCli.Tests.ps1`: in-memory Commander and yargs fixtures yield the expected `cli-command` and `cli-option` elements, asserting declaration (for example `tool serve` and `tool serve --port`), `parent_id`, `name`, properties (`short`, `required`, `positional`, `name_source`) and `line_range`, including multi-line chained calls and yargs builder functions (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerTypeScriptHttp.Tests.ps1`: in-memory Express and Fastify fixtures yield the expected `http-route` elements, including path arrays, `route()` chains, `ANY` for `all`, a router mounted from a second in-memory file through a relative import, an unmounted router with `mounted: false`, Fastify `route({...})` objects and `register` prefixes (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerTypeScriptExports.Tests.ps1`: an in-memory fixture covering each classified export form yields one `public-symbol` per exported name with the module-path qualified declaration and `symbol_kind`, expands `export *` from a relative module, stops at a re-export cycle with `ts-reexport-unresolved`, and merges overload signatures into one element with `overloads` (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerDotnetHttp.Tests.ps1`: in-memory C# fixtures yield the expected `http-route` elements for attribute routing (class prefix, `[controller]`, `[action]`, literal `[area]`, `/` and `~/` overrides, multiple verbs, `AcceptVerbs`) and minimal APIs (`MapGet` through `MapPatch`, `MapMethods`, `Map` as `ANY`, nested `MapGroup` prefixes) (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerDotnetConfig.Tests.ps1`: an in-memory `appsettings.json` and `appsettings.Development.json` with comments and trailing commas yield one `config-key` per member path with the quoted-segment and `[]` declaration rule, `value_type`, `configuration_path` and `environment`; every configuration value in the fixture is a distinctive string that occurs nowhere in the canonical JSON of the analyzer output (keys only, no values) (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerDotnetApi.Tests.ps1`: in-memory C# fixtures yield the expected `public-symbol` elements for public types (file-scoped and block namespaces, nested types, generics, a `partial` type split across two in-memory paths) and members (overloaded methods with distinct declarations, constructors, indexers, operators, enum members, positional record parameters), and yield no element for `internal`, `private`, `private protected`, `file` and explicit interface implementations (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerExtensionImport.Tests.ps1`: a valid manifest built in memory (its `manifest_sha256` computed in the test with `ConvertTo-DocsCanonicalJson` and `Get-DocsSha256Hex`) is merged as inert data: each mappable finding becomes an element with `analyzer_id` `extension-import`, a recomputed `element_id`, a declaration-lines digest computed from the captured text, `adapter_id`, `adapter_version`, `classification`, `confidence` and `finding_id` copied unchanged, and only `value_type` copied for `config-key`; unmappable findings yield one non-blocking `extension-finding-skipped` whose `extensions` has no `docs.precision-limit` key (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerExtensionImport.Tests.ps1`: a manifest whose `source_inputs[]` `sha256` does not match the captured input is rejected with exactly one blocking `extension-input-digest-mismatch` diagnostic and contributes no element; one mutation per validation step yields that step's code (`extension-manifest-invalid`, `extension-manifest-digest-mismatch`, `extension-repository-mismatch`, `extension-adapter-invalid`, `extension-input-not-captured`, `extension-result-digest-mismatch`, `extension-result-invalid`, `extension-finding-source-mismatch`) and no element; a valid manifest validated with a `-Selection` that carries neither `repository_id` nor `revision` is accepted with exactly the two non-blocking diagnostics `extension-repository-unverified` and `extension-revision-unverified` (CI: `poshqc / PowerShell QC`).
- [ ] `DocsScannerContract.Tests.ps1`: for each of the seven analyzers, two runs over identical captured inputs, and runs over input orders shuffled with a seeded `[System.Random]` (seed printed on failure), produce byte-identical canonical JSON of `@{ Elements; Diagnostics }` (CI: `poshqc / PowerShell QC`).
- [ ] `DocsScannerContract.Tests.ps1`: for each analyzer, a selected captured input with `text` `$null` because it exceeds the 1 MiB bound yields one blocking `input-over-bound` diagnostic under that analyzer's identifier and no element from that path, an undecodable input yields `input-undecodable`, and a lexical error in one file does not remove the elements of another file (CI: `poshqc / PowerShell QC`).
- [ ] `DocsScannerContract.Tests.ps1`: every `(analyzer_id, code)` row returned by `Get-DocsScannerPrecisionLimit` is emitted by at least one in-memory fixture as a non-blocking `warning` diagnostic with the consequence stated in `## Scanner Precision Limit` (no element, or an element with a `<dynamic>` segment and `prefix_resolved: false`), at most once per `(analyzer_id, code, path)`, with a non-null `path`, with `extensions` containing the key `docs.precision-limit` whose value is exactly `{"element_kind": <the row's element_kind>}`, and with a message containing the occurrence count and first line and no fixture source text; every diagnostic emitted by the fixtures whose code is listed under the codes that are not precision limits (including `input-over-bound`, `input-undecodable` and `extension-finding-skipped`) has no `docs.precision-limit` key; every non-blocking code emitted by the fixtures that is not listed under the codes that are not precision limits is a row of the table (CI: `poshqc / PowerShell QC`).
- [ ] `DocsScannerContract.Tests.ps1`: every element produced by the six built-in scanners records `analysis_method` `scanner` and a declaration-lines digest with a non-null `line_range`; editing a line outside `line_range` leaves the digest unchanged, editing a line inside changes it, and an LF and a CRLF variant built in code yield equal digests; every element passes `ConvertFrom-DocsSurfaceElement`; and for each of the six built-in scanners, 1020 `Invoke-DocsAnalyzer` with an in-memory registration row (`AnalysisMethod` `scanner`) and the `-ImportModule` seam returns the scanner's elements with no rejection finding (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1` asserts membership only: the registry source text contains the anchor line `# --- 1033: TypeScript and .NET analyzers ---` inside the scanner table `$script:DocsAnalyzerRow`, and contains no `# --- 900NNN:` anchor; `Get-DocsAnalyzerRegistration` contains a row found by `Id` and `AnalysisMethod` `scanner` for each of `typescript-cli`, `typescript-http`, `typescript-exports`, `dotnet-http`, `dotnet-config`, `dotnet-public-api` and `extension-import`, with the module leaves and functions of `### Registry rows`; none of these identifiers equals `python-cli`, `python-http`, `python-public-api`, `config-files` or `python-architecture`; `Test-DocsAnalyzerRegistration` returns no finding; and each of these seven rows appears in the source text after the 1033 anchor line and before the next anchor line or the end of the scanner table. The suite asserts no row count and no exclusivity of the committed tables (CI: `poshqc / PowerShell QC`).
- [ ] `DocsAnalyzerRegistry.Tests.ps1` (1020's suite): 1020 v0.6 already makes it a membership suite, so this feature leaves it unmodified and it passes with the appended rows; only if the merged suite still contains a row-count or empty-registry assertion does this feature replace that assertion with anchor presence plus membership, and the plan records the edit (CI: `poshqc / PowerShell QC`).
- [ ] `## Scanner Precision Limit` in this specification lists one row per `(analyzer_id, code)` with the element kind, the construct and why it is not classified, states that the coverage ledger records it as a `deferred` entry with an owner, and `DocsScannerCommon.Tests.ps1` asserts that `Get-DocsScannerPrecisionLimit` returns rows with exactly the keys `analyzer_id`, `code`, `element_kind`, `construct` and `consequence`, ordered by `analyzer_id` then `code`, whose `analyzer_id` values are registered identifiers and whose `element_kind` values are docs element kinds listed in that row's registered `ElementKinds`; and that `New-DocsScannerPrecisionLimitDiagnostic` returns a `warning` record with `blocking` `false` whose `extensions['docs.precision-limit']` equals `{"element_kind": <ElementKind>}`, keeps any other `extensions` key, and throws for a `$null` or empty `-Path` and for an `-ElementKind` that is not a docs element kind (CI: `poshqc / PowerShell QC`).
- [ ] The push-down copy of every new or edited file under `.claude/lib/docs/` is byte-identical to its source and listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: 1020's `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` passes (CI: `poshqc / PowerShell QC`), and the existing contract tests `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass unmodified (CI: `quality-checks7 / Code Quality & Tests`).
- [ ] Every new module passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and 1020's `DocsNeutrality.Tests.ps1` unmodified, and no production file under `.claude/lib/docs/` created by this feature exceeds 500 logical lines (CI: `poshqc / PowerShell QC`).
- [ ] No Python or TypeScript file is added or modified: `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`, and the plan carries the artifact classification table of `## Artifact Classification`.
- [ ] No test creates a temporary file: no file this feature adds or edits under `tests/scripts/claude-lib/docs/` contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`.
- [ ] Pester line coverage is at least 85% for each new production module (`DocsScannerCommon.psm1`, `DocsTypeScriptTokens.psm1`, `DocsTypeScriptJsx.psm1` when created, `DocsCSharpTokens.psm1`, `DocsAnalyzerTypeScriptCli.psm1`, `DocsAnalyzerTypeScriptHttp.psm1`, `DocsAnalyzerTypeScriptExports.psm1`, `DocsAnalyzerDotnetHttp.psm1`, `DocsAnalyzerDotnetConfig.psm1`, `DocsAnalyzerDotnetApi.psm1`, `DocsAnalyzerExtensionImport.psm1`), read from the PoshQC coverage report with no production file excluded from measurement, recorded under `<FEATURE>/evidence/coverage/` (no branch-coverage gate applies to Pester).
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` (Windows shards, coverage) and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head.

## Definition of Done

- [ ] Acceptance criteria mapped to named Pester suites or commands in the plan
- [ ] C1-C10 outcomes recorded in the plan against the merged 1020 amendment and re-prepared 1022 specification
- [ ] Edge cases covered by tests: empty input set, empty file, CRLF and BOM variants, oversize and undecodable inputs, lexical errors, token, depth and key bounds, duplicate declarations, re-export cycle, partial types across files, every extension rejection code
- [ ] Docs suites pass in three seeded shuffled file-order runs in one process and in a fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Toolchain pass completed (format, PSScriptAnalyzer lint, architecture and contract tests, Pester) in a single clean pass
- [ ] Forbidden-token scan over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage for each tokenizer and analyzer over in-memory fixtures
- [ ] Determinism over identical bytes; size-bound and unclassifiable-construct diagnostics
- [ ] Extension-result manifest import with matching and mismatching digests
