# docs-surface-analyzers-typescript-dotnet (Issue #1033) - Research

- Issue: #1033 (epic #1019 child, manifest placeholder 900004, wave 1, band C4)
- Feature folder: `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/`
- Researched: 2026-10-30
- Scope of this artifact: research only. Planning, specification and execution are done by other agents.
- Environment facts (tool routes, CI shape, batch budget, isolation checks) are not restated; they are in `.claude/skills/execution-environment/SKILL.md` and are cited by heading.

## Sources and Verification Status

Requirements sources read in full or by section:

- `docs/features/epics/documentation-estate-tooling/epic.md` (whole file), including `## Owner Directive: Implementation Language (2026-10-30, refined)`, `### Artifact classes for this epic`, `## Owner Decisions`, `### Amendment of 1020 required by D3 and D5`, `### PowerShell contracts from the re-preparation of 1020`, `### Command contract decisions from the first preparation of 1023`, `### Analyzer decisions from the first preparation of 1022`, `### 900004 - docs-surface-analyzers-typescript-dotnet`.
- `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` (version 0.3): `### Module conventions`, `### DocsJson.psm1`, `### DocsFinding.psm1`, `### DocsSurface.psm1`, `#### Element identifiers`, `### DocsAnalyzerRegistry.psm1`, `### Entry script`, `### Docs common $defs`, `### Artifact schema: surface-inventory-snapshot`, `### Artifact schema: docs-coverage-ledger`, `## Decisions Later Children Must Honor`, `## Acceptance Criteria`.
- `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md` (version 0.1, withdrawn Python design; read for language-independent decisions only).
- `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/spec.md` (Python-era version) and its research file (for ledger entry shape only).

Status labels used below:

- **verified in tree**: the path or symbol was read in this worktree.
- **planned by 1020 (not in tree)**: the symbol is stated in 1020 `spec.md` or epic.md; `.claude/lib/docs/` does not exist in this worktree (Glob for `.claude/lib/docs/**` returned nothing). 1020 is being amended concurrently (D3/D5), so every such symbol is subject to that amendment.
- **not found**: searched and absent.

Note on anchor numbering: 1020 `spec.md` still uses manifest placeholders in anchors and prose. `# --- 900003: Python and configuration analyzers ---` is the anchor of the child now numbered 1022, and `# --- 900004: TypeScript and .NET analyzers ---` is the anchor of this child (issue #1033). This research uses the anchor text exactly as 1020 states it (`900004`) and lists the renumbering as a contract dependency.

## Current State

- `.claude/lib/docs/`: not found (1020 not executed).
- `tests/scripts/claude-lib/docs/`: not found.
- `quality-tiers.yml`: no `.claude/lib/docs` entry (verified in tree; every existing `.claude/lib/<area>` entry is `tier: T3`, for example `.claude/lib/mermaid` and `.claude/lib/discovery-validation`). 1020 adds the `.claude/lib/docs` entry as T3.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: carries the 15 `.claude/lib/discovery-validation/*` files and the 4 `.claude/lib/mermaid/*.psm1` files (verified in tree); no `.claude/lib/docs/` entry.
- The feature folder's existing `spec.md` is the promoted issue text with template placeholders, and `plan.2026-10-30T18-39.md` is the unfilled plan template (verified in tree). Neither constrains this research.

## Research Question 1 - Reuse Inventory

### `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` (verified in tree)

| Function | Exported | Behavior | Use in this child |
|---|---|---|---|
| `Get-DiscoverySha256Hex -Text` | yes | Lowercase hex SHA-256 of the UTF-8 bytes of a string | Reached only through 1020 `Get-DocsSha256Hex` (planned by 1020) |
| `Get-DiscoveryBytesSha256Hex -Bytes` | yes | Lowercase hex SHA-256 of raw bytes | Reached through 1020 `Get-DocsBytesSha256Hex`; extension result-file and source-input digest comparison |
| `ConvertTo-DiscoveryCanonicalJson -Value` | yes | Sorted keys (ordinal), compact, trailing LF; integers only (throws `AUTHORIZATION_INPUT_INVALID` on a fractional number); accepts hashtables, ordered dictionaries and PSCustomObjects | Reached through 1020 `ConvertTo-DocsCanonicalJson`; recomputation of an extension manifest's `manifest_sha256` |
| `ConvertTo-DiscoveryJsonString`, `ConvertTo-DiscoveryCanonicalFragment` | no | Internal helpers | none |

- Strict UTF-8 decoding is not an exported function anywhere in `.claude/lib/discovery-validation/`. The pattern `[System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)` appears inline in `DiscoveryCapability.psm1`, `DiscoveryPlanning.psm1` and `DiscoveryStartRecord.psm1` (verified in tree). 1020's `New-DocsCapturedInput` (planned by 1020) owns strict decoding for the docs lib, so the analyzers receive decoded `text` and never decode bytes themselves.
- `DiscoveryManifest.psm1` (verified in tree) exports strict decoding of the discovery input manifest (`ConvertFrom-DiscoveryInputManifest`, `Get-DiscoveryInputManifestDigest`, `Compare-DiscoveryInputManifest`). Its shape (`entries`, `missing_paths`, `source_repositories`, `target_repositories`, `sha256`) is the `service-result` input manifest, not the extension-result manifest, so it is not reused. It is an imitation reference for strict key-set checking (`Get-DiscoverySortedPropertyNameList` compared with a fixed comma-joined key list).

Importability from `.claude/lib/docs/`: 1020 already imports `../discovery-validation/DiscoveryEncoding.psm1` from `DocsJson.psm1` with a literal join (planned by 1020, import graph in `### Module conventions`), and `DiscoveryEncoding.psm1` is listed in Claude `core.json` (verified in tree), so the dependency closure stays inside core. This child does not import any discovery-validation module directly. Every hash and canonical JSON call goes through the 1020 wrappers (`Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex`, `ConvertTo-DocsCanonicalJson`), as `## Decisions Later Children Must Honor` requires for digests.

### `.claude/lib/mermaid/MermaidLineScanner.psm1` (verified in tree)

The module is a quote-aware, single-line Mermaid scanner. The parts that carry over as a pattern:

- Index-aligned masking (`Get-MermaidQuoteMaskedText`, `Get-MermaidLabelMaskedText`): non-code characters are replaced by spaces so later regex scans cannot match inside literals, and offsets stay aligned with the source.
- An ordered scan record (`Get-MermaidLineScan` returns an `[ordered]` hashtable with a `Class` field including `Unclassifiable`), which is the same "classify or report" posture the analyzers need.
- Module conventions: help block with the `imports its siblings with -ErrorAction Stop` sentence, `Set-StrictMode -Version Latest` then `$ErrorActionPreference = 'Stop'`, a literal `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'MermaidGrammar.psm1') -Force -ErrorAction Stop`, and an explicit `Export-ModuleMember -Function` list.

The functions themselves are not reusable: Mermaid has no escape system, uses `%%` comments and treats backslash as an ordinary character, which is wrong for TypeScript and C#. The scanners imitate the pattern and do not import the module.

### Python discovery runtime (design reference only, never called)

- `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/source_text.py` (`_Masker`, `strip_comments_and_strings`): C# masking of comments, char literals, regular, verbatim (`@"..."`, doubled quotes), interpolated (`$"..."`, `{{` escape, nested holes with brace depth), raw (`"""..."""`, exact quote-run length, `$$` brace width) strings, with recovery at a physical newline for ordinary unterminated literals and masking to end of file for unterminated multi-line constructs. Verified in tree.
- `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_tokens.py` (`decode_source`, `tokenize_csharp`): directive lines (`#...`) are skipped without evaluating branches, `@` verbatim identifiers and `\u`/`\U` identifier escapes are honored, a token limit (100000) and NUL/surrogate rejection apply. Verified in tree.

The docs C# tokenizer differs in one essential respect: discovery masks string contents away, but the docs analyzers need the decoded value of string literals (route templates, option names). The docs tokenizer therefore emits string tokens with their decoded value and flags, rather than masking.

## Research Question 2 - Extension-Result Manifest

### Schema facts (`schemas/discovery/v2/extension-result-manifest.schema.json`, verified in tree)

- Required root fields: `$schema` (const `urn:drm-copilot:discovery:2.0.0:extension-result-manifest`), `schema_version` (const `2.0.0`), `artifact_kind` (const `extension-result-manifest`), `id` (identifier), `adapter` (`inventory-snapshot#/$defs/tool`: closed `{id, version}`), `repository` (`common#/$defs/repository-reference`: closed `{id, revision}` with a non-null 40- or 64-hex revision), `input_manifest_sha256` (sha256), `source_inputs` (array of `source-snapshot-manifest#/$defs/payload`: closed `{path, sha256, size}`), `result_files` (array of `#/$defs/result-file`), `manifest_sha256` (sha256 "of the canonical manifest excluding this field"), `generated_at`, `generated_by`, `diagnostics` (array of `inventory-snapshot#/$defs/diagnostic`), `extensions`.
- `result-file`: closed `{artifact_kind: const "inventory-snapshot", id, schema_version: const "2.0.0", path, sha256, size}`. Elements are not inline: they live in the referenced `inventory-snapshot` documents.
- `anyOf`: at least one result file, or at least one blocking diagnostic.

### Where findings live (`schemas/discovery/v2/inventory-snapshot.schema.json`, verified in tree)

- `findings[]` is closed: `finding_id`, `component_id`, `kind` (identifier), `source` (`{repository, revision, path, sha256, symbol?, line_range?}`), `analyzer` (tool), `classification` (`detected` or `inferred`), `confidence`, `properties` (array of `{name: identifier, value: scalar}`), `extensions`.
- `components[]` and `relationships[]` carry component and edge data; `diagnostics[]` has the same `{id, code, severity, path, message, analyzer_id, blocking, extensions}` shape as the docs `diagnostic` definition (1020 docs common, planned by 1020).
- `common.schema.json` (verified in tree): `identifier` pattern `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`; `extensions` keys must match `^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$` (at least one `.` or `-` separator, no underscore), so a snake_case name such as `analysis_method` cannot be an extensions key. This supports 1020 adding `analysis_method` as a first-class element field.

### How the Python runtime validates (design reference, verified in tree)

`extension_results.py` `_manifest` and `extension_validation.py` `ExtensionValidation`:

1. Read and schema-validate the manifest; manifest `id` unique.
2. Reject an `adapter.id` equal to a built-in analyzer identity (`EXTENSION_IDENTITY`); adapter id unique.
3. `repository.id` and `repository.revision` must equal the profile repository (`EXTENSION_SOURCE`).
4. `input_manifest_sha256` must equal the runtime's own `extension_input_digest` and `manifest_sha256` must equal `extension_manifest_digest(document)` (canonical JSON of the document minus the root `manifest_sha256` member) (`EXTENSION_DIGEST`).
5. `source_inputs`: count equals the captured source set; each path captured once; `sha256` and `size` equal both the captured bytes and the pin (`EXTENSION_SOURCE`).
6. Each `result_files` member: file bytes `sha256`/`size` equal the reference; `id`, `artifact_kind`, `schema_version` equal the reference; repository, revision and `scan_configuration_sha256` agree (`EXTENSION_DIGEST`); `tool` and `analyzers` equal the adapter (`EXTENSION_IDENTITY`); every finding `source.sha256` equals the captured bytes and `line_range` lies within the physical line count (`EXTENSION_SOURCE`); duplicate property names rejected (`EXTENSION_COLLISION`).
7. Merge: built-in rows are authoritative; an imported row whose identity collides with a built-in row fails (`EXTENSION_COLLISION`); classifications and confidence are preserved and never upgraded.

`input_manifest_sha256` is computed from `extension_input_projection(capture)`, which includes the discovery profile document, exclusions and repository pins (`extension_inputs.py`, verified in tree). The docs helpers have no discovery profile, so this digest cannot be recomputed by the docs lib and is carried as an opaque value.

### What "merged as inert data" maps to in the docs snapshot (recommended)

- Inert: no code is run, no adapter-supplied identity is trusted, values are copied as data, and imported rows never override built-in rows.
- Mapping: a discovery finding becomes one docs element when its `kind` equals a docs element kind (`cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`, `architecture-component`; all satisfy the discovery identifier grammar), its `source.symbol` is present (becomes `declaration`) and its `source.line_range` is present. `path` is `source.path`; `name` is the string property `name` when present, else the declaration; `element_id` is recomputed with `Get-DocsElementId`; `analyzer_id` is the docs import analyzer identifier (required by `Invoke-DocsAnalyzer`, which checks `analyzer_id` equals the registration `Id`); the adapter `id` and `version`, `classification`, `confidence` and the source `finding_id` are kept as scalar properties; the declaration-lines digest is computed by the docs lib from the captured source bytes, not taken from the adapter. A `cli-option` needs a `parent_symbol` property (and optional `parent_path`, default the same path) to compute the parent `cli-command` identifier; otherwise it is skipped with a diagnostic. For `config-key`, only a `value_type` property is copied, so an adapter cannot leak a configuration value through properties.
- Not imported: findings of other kinds, findings without `symbol` or `line_range`, components and relationships. Each manifest yields one non-blocking diagnostic stating the skipped count per reason.
- Collision with a built-in element of the same `element_id` is resolved by the inventory merge (1022 `DocsInventory.psm1`), not by the analyzer, because an analyzer sees only its own output. Recommended rule: the built-in element wins and the imported one is dropped with a diagnostic. This is a contract dependency on 1022.

## Research Question 3 - Analyzer Guarantees (`docs/engineering/legacy-discovery-and-parity/analyzers.md`, verified in tree)

| Guarantee | Statement in the document | Application to these scanners |
|---|---|---|
| Captured inputs | Each run captures the bounded bytes it reads and records their digests | Analyzers read only `CapturedInput` records built by `New-DocsCapturedInput` (planned by 1020); the inventory records `inputs[].{path, sha256, size}`; extension import compares adapter-declared digests with these records |
| Deterministic identities | Identifiers derive from path and declaration; reruns over the same bytes produce identical snapshots | `Get-DocsElementId` (planned by 1020) over `{declaration, kind, path}`; analyzers iterate inputs in ordinal path order and return elements sorted by `element_id`; no hashtable enumeration order reaches output |
| No value leakage | Configuration analyzers emit keys and shapes, never values | `dotnet-config` emits key paths and `value_type` only; string literal values from source code are used only where they are the declaration (route templates, option names); see owner question OQ-4 on the digest of a configuration line |
| Bounded parsing | Size and count limits; an over-limit input is a diagnostic, not a partial result | 1 MiB per input (epic `### Analyzer decisions from the first preparation of 1022`); token and nesting bounds per tokenizer; a tokenizer failure yields a blocking diagnostic and no element from that file |
| Diagnostics over guesses | What cannot be classified is recorded in `diagnostics` | Dynamic registration, computed templates, non-literal arguments and unresolved re-exports become diagnostics; these form the documented precision limit |

The document's `## Extending` section states that separately produced inventories enter through `extension-result-manifest` documents and are merged "as inert data", which is the source of this child's import requirement.

## Research Question 4 - Lexical Recognition Rules

### Shared token model (both tokenizers)

Each tokenizer returns `@{ Tokens; Diagnostics }`. A token is an ordered hashtable: `Kind` (`identifier`, `keyword`, `string`, `template`, `number`, `regex`, `punct`), `Text` (source spelling), `Value` (decoded string value for `string`; `$null` otherwise), `Dynamic` (`$true` for a template literal with substitutions or an interpolated C# string with holes), `Start` (offset), `Line` (1-based), `EndLine`, `Depth` (bracket depth at the token). Comments and C# directive lines produce no token. A shared token shape lets common helpers (argument splitting at depth, matching close bracket, literal extraction) serve both languages.

Performance: a character-by-character PowerShell loop over 1 MiB is slow. The tokenizers should advance with `\G`-anchored .NET `[regex]` matches (one compiled pattern per lexical state, matched at the current offset) so the per-character work runs in .NET and the PowerShell loop runs once per token.

### TypeScript tokenizer (`DocsTypeScriptTokens.psm1`) requirements

- Byte-order mark: strip a leading U+FEFF if `New-DocsCapturedInput` leaves it (contract dependency C4). Hashbang `#!` on line 1 is skipped.
- Comments `//` and `/* */` (block comments span lines and keep line counting).
- Strings `'...'` and `"..."` with escapes (`\n`, `\t`, `\\`, quote escapes, `\x`, `\u{...}`, line continuation); a raw newline inside an ordinary string is a lexical error for the file.
- Template literals with `${ ... }` substitution stack (nested templates and braces inside substitutions); a template without substitutions is a literal with `Value`; with substitutions it is `Dynamic`.
- Regular-expression literals: `/` begins a regex when the previous significant token is absent, a punctuator other than `)`, `]`, `}`, or one of the keywords `return`, `typeof`, `instanceof`, `in`, `of`, `new`, `delete`, `void`, `throw`, `case`, `do`, `else`, `yield`, `await`; character classes `[...]` may contain `/`; flags follow.
- `.tsx` only: JSX element scanning when `<` is followed by an identifier or `>` in a position where an expression can start, with element depth, attribute strings, `{...}` expression children (re-entering the normal tokenizer with brace counting), text runs (an apostrophe in JSX text is not a string delimiter) and closing or self-closing tags. `<T,>` and `<T extends ...>` are type parameters, not JSX.
- Numbers (separators `_`, hex, octal, binary, BigInt `n`), identifiers including `#private` and Unicode escapes, decorators `@`.
- Bounds: input text already within 1 MiB; at most 250000 tokens per file (recommended default) and bracket depth at most 256; exceeding either is a blocking diagnostic and no element from that file.

### C# tokenizer (`DocsCSharpTokens.psm1`) requirements

- Comments `//`, `///`, `/* */`.
- Preprocessor directives: a line whose first non-whitespace character is `#` produces no token (as `csharp_tokens.py` does); branches of `#if`/`#else` are both tokenized and not evaluated. A file containing `#if` yields one non-blocking diagnostic `csharp-conditional-compilation`; duplicate declarations from both branches fall under the duplicate-declaration rule.
- Character literals; regular strings with escapes; verbatim `@"..."` with doubled quotes; interpolated `$"..."`, `$@"..."`, `@$"..."` with holes and `{{` escapes; raw strings `"""..."""` with quote-run length and `$$` brace width; UTF-8 suffix `u8`. Single-line raw strings decode to their content; a multi-line raw string is a literal but analyzers treat it as unsupported for route templates (diagnostic).
- Identifiers including `@`-verbatim identifiers and `\u` escapes (decoded value kept, `Text` preserved), contextual keywords (`record`, `partial`, `required`, `file`) as identifiers resolved by the analyzer.
- Bounds as for TypeScript.

### Declaration strings (1020 `#### Element identifiers`, planned by 1020)

| Kind | 1020 convention | TypeScript/.NET form (recommended) |
|---|---|---|
| `cli-command` | full command path | `<root> <sub> ...`, for example `tool serve` |
| `cli-option` | command path, one space, long option | `tool serve --port`; positional `tool serve <file>` spelled as the bare argument name (`tool serve file`), property `positional: true` |
| `http-route` | upper-case method, one space, route template | `GET /items/:id` (Express and Fastify parameters kept verbatim), `GET /api/Items/{id:int}` (ASP.NET constraints kept verbatim); method `ANY` for "every method" registrations (`app.all`, Fastify `all`, minimal-API `Map`), with property `framework_method` |
| `config-key` | dotted key path | `Logging.LogLevel."Microsoft.AspNetCore"`: segments matching `^[A-Za-z0-9_-]+$` stay bare, other segments are double-quoted with `"` and `\` escaped, array members contribute `[]` (the rule of the withdrawn 1022 spec; cross-child consistency dependency on the re-prepared 1022) |
| `public-symbol` | qualified name | TypeScript: module path relative to the containing source root, extension removed, then `.` and the export name (`utils/strings.camelCase`; `default` for a default export). C#: `Namespace.Type.Member` with nested types dotted, source-spelled type parameters (`Ns.Repository<T>.Find<TKey>(TKey)`), and method parameter types with whitespace removed and `ref`/`out`/`in`/`params` kept, so overloads stay distinct |

Element identity also includes `path`, so a declaration only needs to be unique within one file.

### `typescript-cli` (`DocsAnalyzerTypeScriptCli.psm1`; Commander and yargs)

Root name resolution: a literal `new Command('x')`, `.name('x')` (Commander) or `.scriptName('x')` (yargs) on the root receiver (`name_source: literal`); otherwise the module path relative to the containing source root (`name_source: module`), mirroring the withdrawn 1022 fallback.

| Framework | Classified | Diagnostic (non-blocking warning unless stated) |
|---|---|---|
| Commander | Root receivers: `program` imported from `commander`, `new Command(...)`, a variable assigned from either. `.command('name <arg> [opt]')` (first word is the name; the remaining words are positional `cli-option` elements). Chains: `.command(...)` returns the subcommand, so later `.option`/`.argument` calls in the same chain apply to it; `.command('name', 'description')` (stand-alone executable form) returns the parent. `const sub = program.command('x')` tracks `sub`. `.addCommand(tracked)` parents a tracked command. `.option('-p, --port <n>')` (long flag is the first `--` part, `short` property from the `-` part), `.requiredOption(...)` (`required: true`), `.addOption(new Option('--x'))` inline, `.argument('<file>')` (positional) | Non-literal or `Dynamic` command or option strings (`cli-dynamic-registration`); registration inside a loop body; `.addCommand` with an untracked or imported receiver (`cli-unbound-registration`); spread arguments; `.command` on a receiver that is not tracked |
| yargs | Root: `yargs(...)` or `yargs` imported from `yargs`, chained. `.command('serve [port]', ...)` (name is the first word; `$0` is the root); `.command({ command: 'x' \| ['x', 'alias'], ... })` object literal; builder third argument as an arrow function whose parameter is the receiver for `.option`/`.positional` inside its body, or as an object literal whose keys are options; `.option('port', {...})` and `.options({ a: {...} })` keys (multi-character keys become `--key`, single-character `-k`); `.positional('port', ...)` (positional) | `.command(require(...))`, `.command(importedModule)` and `.commandDir(...)` (`cli-command-module-unresolved`); non-literal names; computed object keys |

### `typescript-http` (`DocsAnalyzerTypeScriptHttp.psm1`; Express and Fastify)

| Framework | Classified | Diagnostic |
|---|---|---|
| Express | Receivers: `express()` results and `express.Router()`/`Router()` results (import-aware). `<receiver>.<method>(path, ...)` for `get post put delete patch options head` and `all` (method `ANY`); array of literal paths yields one element per path; `router.route(path).get(...).post(...)` chains. Mounts `app.use('/prefix', router)` and `router.use('/prefix', subRouter)`: prefix composition across files when the router is a tracked object in the same file or the default or named export of a relative import that resolves to a captured input (`./x` to `x.ts`, `x.tsx`, `x.mts`, `x.cts`, `x/index.ts`); a router mounted n times yields n elements; a router never mounted keeps its own template with property `mounted: false` | Regex or non-literal paths (`http-dynamic-route`, no element); non-literal prefix: route kept with the segment rendered `<dynamic>`, property `prefix_resolved: false`, warning `http-prefix-dynamic` (1022 rule D9, so identity stays stable); `app.use(prefix, untrackedIdentifier)` (`http-mount-unresolved`); `app.use(middlewareCall(...))` is ignored without a diagnostic |
| Fastify | Receivers: `Fastify()`/`fastify()` results, and the first parameter of a plugin function passed to `.register`. `<receiver>.<method>(url, [opts], handler)` for the same method set; `.route({ method: 'GET' \| ['GET', 'POST'], url: '/x' })` object literal (also `path`); `.register(plugin, { prefix: '/v1' })` with an inline function, a same-file named function, or the default export of a resolvable relative import; `fp(fn)` from `fastify-plugin` treated as `fn` | Non-literal method or url; `register` with a non-literal prefix (`<dynamic>` rule); plugins from package imports (`http-mount-unresolved`) |

Method token is upper-case; the automatic `HEAD` for `GET` is not emitted. Element `name` is the handler identifier when the handler is a named reference, otherwise the template.

### `typescript-exports` (`DocsAnalyzerTypeScriptExports.psm1`)

| Classified (one `public-symbol` element per exported name) | Diagnostic |
|---|---|
| `export function`, `export async function`, `export function*`, `export class`, `export abstract class`, `export const`/`let`/`var` with one or more simple declarators, `export const { a, b } = ...` with simple identifiers, `export interface`, `export type X =`, `export enum`, `export const enum`, `export declare ...`, `export namespace N { export ... }` (nested names `N.f` through brace-depth tracking), `export default ...` (name `default`; `local_name` property for a named default), `export { a, b as c }`, `export { a as default }`, `export type { A }` (`type_only: true`), `export { x } from './y'` and `export * as ns from './y'` (property `reexport_from`), `export * from './y'` expanded from a resolvable relative module with a visited set and depth bound 16; overload signatures of one function emit one element with an `overloads` count | `export * from 'package'` or an unresolvable relative specifier (`ts-reexport-unresolved`); re-export cycle or depth overflow (`ts-reexport-unresolved`); destructuring with defaults, rest or nested patterns (`ts-export-pattern-unsupported`); `export =` (`ts-export-assignment`, element `default` with `export_form: assignment`); `declare module 'x' { ... }` and `declare global` bodies (`ts-ambient-module`, skipped); CommonJS `module.exports`/`exports.x` in a `.ts` file (`ts-commonjs-export`, skipped) |

Property `symbol_kind` (`function`, `async-function`, `generator`, `class`, `abstract-class`, `variable`, `interface`, `type`, `enum`, `namespace`, `reexport`).

### `dotnet-http` (`DocsAnalyzerDotnetHttp.psm1`)

| Construct | Classified | Diagnostic |
|---|---|---|
| Attribute routing | Controller class: name ending in `Controller`, or `[ApiController]`/`[Controller]` attribute, or base `Controller`/`ControllerBase`. Class `[Route("api/[controller]")]` prefix; action attributes `[HttpGet]`, `[HttpGet("{id}")]`, `[HttpPost]`, `[HttpPut]`, `[HttpDelete]`, `[HttpPatch]`, `[HttpHead]`, `[HttpOptions]`, `[Route("x")]` combined with a verb attribute, `[AcceptVerbs("GET", "POST")]`; `Name =`/`Order =` named arguments ignored. Token replacement: `[controller]` is the class name without the `Controller` suffix; `[action]` is the method name without an `Async` suffix (ASP.NET Core default); `[area]` from a literal `[Area("x")]` on the class. A template beginning with `/` or `~/` overrides the class prefix. Multiple route or verb attributes yield one element per combination. Literal-only `+` concatenation folds | `[Route(Constants.X)]`, `nameof(...)`, interpolated strings with holes (`http-dynamic-route`); `[area]` without a literal `[Area]` (`http-route-token-unresolved`); verb attribute on a class with no route whose base is not `Controller`/`ControllerBase` (`dotnet-route-inherited-unresolved`); `MapControllerRoute`/`MapDefaultControllerRoute` conventional routing (`dotnet-conventional-routing-unresolved`) |
| Minimal APIs | `<receiver>.MapGet/MapPost/MapPut/MapDelete/MapPatch("/x", ...)`; `MapMethods("/x", new[] { "GET", "HEAD" }, ...)` (also `["GET"]` collection expressions); `Map("/x", ...)` as `ANY`; `var g = app.MapGroup("/api")` and chained `.MapGroup("/a").MapGroup("/b")` compose prefixes, including nested group variables | Non-literal template or method list (`http-dynamic-route`); group with non-literal prefix (`<dynamic>` rule, `http-prefix-dynamic`); a `Map*` call on a method parameter (`IEndpointRouteBuilder` or `RouteGroupBuilder` extension method): route kept without prefix, property `prefix_resolved: false`, warning `http-receiver-unresolved`; `MapHub<T>`, `MapGrpcService<T>`, `MapHealthChecks`, `MapFallback`, `MapRazorPages` (`http-endpoint-kind-unsupported`, one per kind and file) |

Templates are normalized to begin with `/`; case is kept as written.

### `dotnet-config` (`DocsAnalyzerDotnetConfig.psm1`)

- Inputs: basename matching `^appsettings(\.[^/]+)?\.json$` (ordinal, case-insensitive), for example `appsettings.json`, `appsettings.Development.json`. Property `environment` from the middle segment when present.
- Parsing: `System.Text.Json.JsonDocument.Parse` with `CommentHandling = Skip`, `AllowTrailingCommas = $true`, `MaxDepth = 64` as the validity gate (the .NET configuration JSON provider accepts comments and trailing commas). `JsonDocument` carries no line numbers and `Utf8JsonReader` is a ref struct that PowerShell cannot use, so a small lexical JSONC key walker in the same module supplies key lines.
- Elements: one `config-key` per object member path, declaration per the quoting rule above, array members as `[]` (keys of objects inside arrays are unioned), property `value_type` (`object`, `array`, `string`, `number`, `boolean`, `null`) and `configuration_path` (colon form, for example `Logging:LogLevel:Default`, which is how .NET addresses the key). Values are never read into output.
- Diagnostics: invalid JSON (`json-invalid`, blocking, no elements); non-object root (`json-invalid`); duplicate member at one path (`duplicate-declaration`; .NET keeps the last value, the element keeps the first line); per-input key bound 10000 (`input-key-limit`, blocking; value from the withdrawn 1022 spec).

### `dotnet-public-api` (`DocsAnalyzerDotnetApi.psm1`)

| Classified | Diagnostic or exclusion |
|---|---|
| Types `class`, `record`, `record struct`, `struct`, `interface`, `enum`, `delegate` with `public` accessibility, inside file-scoped (`namespace X;`) or block namespaces (nested); nested types whose effective accessibility through the containing chain is public; `partial` types: one type element at the ordinally first path among the parts (property `partial_parts`), members in the file that declares them; generics with source-spelled type parameters | Types with no modifier, `internal`, `private`, `file` (excluded, no diagnostic) |
| Members of public types with `public`, `protected` or `protected internal` accessibility (property `accessibility`): methods (including `static`, `abstract`, `virtual`, `override`, `async`, extension methods), constructors (`Ns.Type.Type(int)`), properties, indexers (`Ns.Type.this[int]`), fields and `const`, events, operators and conversion operators; interface members (implicitly public); enum members (`symbol_kind: enum-member`); positional record parameters as properties | `private`, `internal`, `private protected` members (excluded); explicit interface implementations (excluded); members inside `#if` regions declared twice (`duplicate-declaration`); a declaration the scanner cannot delimit (unbalanced braces, unsupported syntax) yields `csharp-declaration-unrecognized` with a count and first line, and no element for that declaration |

Property `symbol_kind` (`class`, `record`, `struct`, `interface`, `enum`, `delegate`, `method`, `constructor`, `property`, `indexer`, `field`, `constant`, `event`, `operator`, `enum-member`).

### Declaration-lines span (for the D5 digest)

| Element source | `line_range` |
|---|---|
| CLI and HTTP registration calls | From the line of the receiver token of the registering call through the line of its matching `)` (inline handlers included) |
| Attribute routes | From the first attribute line of the action through the line of the method header's closing `)` |
| TypeScript exports: functions, classes, variables | From the `export` line (decorators above included) through the line of the body-opening `{` or the terminating `;` or initializer start |
| TypeScript interfaces, type aliases, enums | Whole construct through its closing `}` or `;` (the shape is the surface) |
| C# types | First attribute or modifier line through the line of the body-opening `{` (members are separate elements) |
| C# members | First attribute or modifier line through the line of the body-opening `{`, `=>`, or terminating `;` |
| Configuration keys | The key's line (see OQ-4) |
| Imported findings | The finding's `source.line_range` |

## Research Question 5 - Precision-Limit Documentation

Ledger facts:

- The 1020 ledger entry (planned by 1020, `### Artifact schema: docs-coverage-ledger`) is keyed by `element_id` (pattern `^(?:cli-command|...)-[0-9a-f]{64}$`). `deferred` requires `owner` (identifier) and `target` (text), `page_bindings` `maxItems 0`, `rationale` text or `null`.
- 1023's spec (Python era) adds `DOCS_LEDGER_OWNER_REQUIRED`, `DOCS_LEDGER_TARGET_REQUIRED` and `DOCS_DEFERRED_NOT_ALLOWED`; its coverage report lists `deferred: [{element_id, owner, target}]`.
- A grep for "precision limit" across `docs/features/` finds only this child's issue, spec and user story, the epic and the promoted potential entry. No child defines how a ledger entry refers to a precision limit.

Gap: a construct the scanner reports as a diagnostic has no element and therefore no `element_id`, so it cannot be a ledger entry under the current schema. The ledger representation of "the precision limit, deferred with an owner" is a 1023 (and possibly 1020) contract, not something this child can define. This is recorded as contract dependency C9 and owner question OQ-2.

What this child must supply so 1023 can record it:

1. Stable diagnostic codes. Every unclassifiable-construct diagnostic uses a fixed lowercase identifier code (discovery identifier grammar, which the docs `diagnostic.code` copies), is non-blocking (`warning`), and is emitted at most once per `(analyzer_id, code, path)`, which is exactly the key of the docs diagnostic `id` (`New-DocsDiagnostic`, planned by 1020). The message states the occurrence count and first line and never quotes source text. Changing a code changes the analyzer registration `Version`.
2. A normative statement in the spec: a `## Scanner Precision Limit` section with one row per `(analyzer_id, code)`: construct class, consequence (no element, or element with `<dynamic>` segment or `prefix_resolved: false`), and the later optional native analyzer that would close it. This is the document the ledger's `deferred` rationale cites.
3. A pointer in each analyzer module's comment-based help `.NOTES` to that spec section, so the shipped lib carries the statement in the destination repository.
4. Optional machine-readable form (recommended only if 1023 asks for it): a pure exported function `Get-DocsScannerPrecisionLimit` in `DocsScannerCommon.psm1` returning the same rows. A per-analyzer function looked up by name is not recommended, because calling a function by a computed name is a dynamic invocation that `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` rejects in `.claude/lib` (detection class 3; verified in tree).

Proposed precision-limit codes (non-blocking unless stated): `cli-dynamic-registration`, `cli-unbound-registration`, `cli-command-module-unresolved`, `http-dynamic-route`, `http-prefix-dynamic`, `http-mount-unresolved`, `http-receiver-unresolved`, `http-route-token-unresolved`, `http-endpoint-kind-unsupported`, `dotnet-route-inherited-unresolved`, `dotnet-conventional-routing-unresolved`, `ts-reexport-unresolved`, `ts-export-pattern-unsupported`, `ts-export-assignment`, `ts-ambient-module`, `ts-commonjs-export`, `csharp-declaration-unrecognized`, `csharp-conditional-compilation`. Input and integrity codes (blocking, not precision limits): `input-over-bound`, `input-undecodable`, `ts-lexical-invalid`, `csharp-lexical-invalid`, `token-limit`, `json-invalid`, `input-key-limit`, and the extension rejection codes below. Shared with 1022's former set: `declaration-invalid`, `duplicate-declaration`.

## Research Question 6 - Size Bound, Captured Input, Input Selection

- Size bound: 1 MiB per input (epic `### Analyzer decisions from the first preparation of 1022`); a larger input is a diagnostic. 1020 states `New-DocsCapturedInput -Path -Bytes [-MaxBytes]` (planned by 1020) returns `@{ path; sha256; size; text; diagnostic }`, decodes strictly as UTF-8, and sets `text` to `$null` with a diagnostic for an oversize or undecodable input. 1020 does not state the default of `-MaxBytes`, the diagnostic code, the diagnostic's `analyzer_id`, or whether a BOM is removed (contract dependency C4). The inventory (1022) builds captured inputs; the analyzers never read files.
- Analyzer behavior for a selected input with `text` `$null`: emit one blocking diagnostic with the analyzer's own `analyzer_id` (`input-over-bound` or `input-undecodable`, chosen from the captured diagnostic's code) and no element, so an analyzer called directly, for example from a Pester test, still reports the gap. UTF-16 C# files are therefore undecodable under strict UTF-8 and are a documented limit.
- `-Selection`: 1020 types it as `<object>` and does not define its shape (verified: no definition in 1020 `spec.md`, plan or addendum research). The analyzers need `source_roots` (module path for TypeScript qualified names and Commander/yargs root fallback), the profile `repository.id` and the snapshot `revision` (extension import checks). Recommended shape: the profile `surface_selection` hashtable plus `repository_id` and `revision` keys, built by the 1022 inventory. Contract dependency C3.
- Input selection: the registry row has no glob column, so each analyzer selects its inputs from the full `CapturedInput` array by path. Recommended rules (ordinal, case-insensitive suffix match on the POSIX path):

| Analyzer identifier | Selected inputs |
|---|---|
| `typescript-cli` | `*.ts`, `*.mts`, `*.cts`, excluding `*.d.ts`, `*.d.mts`, `*.d.cts` |
| `typescript-http` | same as `typescript-cli` |
| `typescript-exports` | `*.ts`, `*.tsx`, `*.mts`, `*.cts`, including declaration files |
| `dotnet-http` | `*.cs` |
| `dotnet-public-api` | `*.cs` |
| `dotnet-config` | basename `appsettings.json` or `appsettings.<name>.json` |
| `extension-import` | `*.json` whose text contains `"extension-result-manifest"` and whose parsed root has `artifact_kind` `extension-result-manifest` and the discovery v2 `$schema` URN; referenced `source_inputs` and `result_files` paths are looked up in the same captured set |

JavaScript files (`*.js`, `*.mjs`, `*.cjs`, `*.jsx`) are not selected (owner question OQ-3). Exclusions are applied by the inventory from the profile before analyzers run.

## Research Question 7 - Push-Down and Test Infrastructure

- `core.json` (verified in tree): `{ "name": "core", "label": "Core (always included)", "paths": [...] }`. Each new `.claude/lib/docs/` file is appended to `paths`; 1020 requires every file under `.claude/lib/docs/` (PowerShell and data) to be listed exactly once and mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Contract tests (verified in tree): `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates distributable files with `rglob` and checks bundle equality; `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (`test_bundled_claude_files_are_listed_in_some_pack_manifest`) checks every bundled file is manifested; `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (`test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`) checks every `$PSScriptRoot` dependency is in core plus the owning pack and that every occurrence is a recognized form. All three enumerate new files automatically; none needs editing. `Docs.Manifest.Tests.ps1` is planned by 1020 (not in tree).
- `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (verified in tree) discovers every `*.psm1` under `.claude/lib` recursively and asserts module-scope fail-fast, guarded sibling imports, the help-block sentence, unchanged caller preference and the hard file-size limit. New modules are picked up automatically.
- `config/poshqc-scan.json` (verified): `scanFolders` `["scripts", "tests/powershell", "tests/scripts"]`, so `tests/scripts/claude-lib/docs/*.Tests.ps1` is discovered and sharded automatically.
- `config/poshqc-coverage.json` (verified): `roots` include `.claude/lib`, so `.claude/lib/docs/*.psm1` enters the coverage population automatically. Neither config file changes.
- `quality-tiers.yml`: `.claude/lib/docs` is added by 1020 as T3 (not in tree yet); this child adds no entry. T3 carries no property-test density or mutation obligation (`.claude/rules/quality-tiers.md`).
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` with `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (verified): scan roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`. Detection class 3 reports `&` on a variable that is not a `[scriptblock]` parameter of the same function, `&` on an expression, and `Invoke-Expression` or its alias. Interpreter names inside string literals and comments are not reported. The analyzers need no dynamic invocation: tokenizer and helper calls are static, and the only seam (`-ImportModule`) is 1020's.
- File size (`.claude/rules/general-code-change.md`, `config/file-size-baseline.json` verified present): new files are not in the baseline, so the 800-line hard limit applies outright; 1020's own criterion holds its files to 500 logical lines. Candidates near 500: `DocsTypeScriptTokens.psm1` (JSX and template states), `DocsAnalyzerTypeScriptHttp.psm1` (two frameworks plus cross-file mounts), `DocsAnalyzerDotnetApi.psm1`. The plan should pre-split rather than react: for example `DocsTypeScriptJsx.psm1` for the JSX state machine and `DocsScannerCommon.psm1` for shared helpers.
- Existing Pester pattern `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1` (verified): `#Requires -Version 7.0`, Pester 5, `BeforeAll` imports the module by a path relative to `$PSScriptRoot`, single-quoted string fixtures, no file reads, no processes, no temporary files, no mocks.

## Research Question 8 - CI

- The new suites run in the PowerShell shard jobs `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` on `windows-latest`, with coverage merged and shard completeness verified by the required aggregator `poshqc / PowerShell QC` (brief `## CI Shape and Required Checks`). `poshqc / PowerShell hook suites (Linux)` runs only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, so these suites never run on Linux.
- The Python contract tests above run in `quality-checks7 / Code Quality & Tests (<python-version>)`.
- The plan alters no fact the brief states: no job, matrix entry, required context, tool route or batch-budget rule changes. No brief-update task is needed.

## Research Question 9 - Existing Tests That Assert Behavior This Child Changes

- 1020 acceptance criterion (spec `## Acceptance Criteria`) and plan task text: "The committed analyzer registry has no rows and carries the 900003 and 900004 anchors" (`tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1`, planned by 1020). The epic (`### Analyzer decisions from the first preparation of 1022`) states that contract tests enumerating registered analyzers assert membership, not set equality, but this criterion asserts an empty row set. It fails as soon as 1022 or this child appends a row. Either 1020's amendment rewrites it as anchor presence plus membership, or this child's plan names the test with disposition "updated: the empty-registry assertion becomes anchor presence and `Test-DocsAnalyzerRegistration` returning no finding" (contract dependency C6).
- `Test-DocsProfileSemantic` (`DOCS_ANALYZER_UNKNOWN`) defaults its known identifiers to `Get-DocsAnalyzerRegistration`; new rows make the new identifiers valid in profiles and change no existing expectation. `New-DocsStarterProfile` omits `surface_selection.analyzers`, so it is unaffected.
- `Docs.Manifest.Tests.ps1` (planned by 1020) asserts set equality between files on disk and manifest entries; it stays green only if every new file is manifested and mirrored in the same change.
- `DocsNeutrality.Tests.ps1` (planned by 1020) scans every file under `.claude/lib/docs/`; new modules must contain no configured consumer identifier.
- No existing test in the tree references any symbol this child creates (none of the planned module names exists).

## Research Question 10 - Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down helpers and libs are PowerShell or bash); D = epic `### Artifact classes for this epic` (schema, configuration, data, test, documentation rows).

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsTypeScriptTokens.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsCSharpTokens.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerDotnetConfig.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerDotnetApi.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerExtensionImport.psm1` (epic name `DocsExtensionImport.psm1`; rename recommended below) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsScannerCommon.psm1` (recommended addition) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsTypeScriptJsx.psm1` (only if the tokenizer passes 500 lines) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (edit: rows under the 900004 anchor) | pushed-down helper/lib | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/<each file above>` | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/<Module>.Tests.ps1` per module, plus a registration test for the appended rows | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/**` | documentation | Markdown | D |

Every artifact follows the language rule. No MCP tool, extension command, hook, skill, agent, Python file or TypeScript file is created or edited. No artifact needs an owner exception.

## Candidate Approaches

### Approach A (selected): token-stream scanners with a shared token shape and a shared helper module

- Two tokenizers produce a common token record; analyzers recognize call shapes and declaration shapes over tokens with bracket-depth tracking; a shared pure module holds input selection, argument splitting, literal extraction, template joining, diagnostic aggregation and the declaration-lines digest (if 1020 does not supply it).
- Advantages: string values are decoded once and correctly (escapes, verbatim, raw); comments and literals can never produce false matches; argument lists spanning lines are handled; depth tracking supports chains, builders, nested namespaces and plugin scopes; one recognition helper set serves seven analyzers.
- Limitations: more code than line regexes; tokenizer correctness is the main risk and needs dense fixtures.
- Alignment: follows the "classify or report" pattern of `MermaidLineScanner.psm1` and the discovery runtime's tokenize-then-recognize design; pure functions over strings and hashtables as 1020 requires.

### Rejected alternatives

- Line-oriented regular expressions over masked text (the Mermaid approach applied directly): cannot follow multi-line calls, chains or builders, and masking removes the string values the declarations need.
- Calling the TypeScript compiler, Roslyn or the Python discovery runtime: violates A7/A8 and the language rule; native analyzers are later, optional children (D3).

## Recommended Module and Function Design

All functions are advanced functions with `[CmdletBinding()]`; all analyzer and tokenizer functions are pure (no filesystem, clock, process, environment or module-scope mutable state). Every sibling import is a column-0 `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '<literal>') -Force -ErrorAction Stop`.

| Module | Exports (recommended) | Imports |
|---|---|---|
| `DocsScannerCommon.psm1` | `Select-DocsScannerInput -CapturedInput -Suffix [-ExcludeSuffix]`; `Get-DocsScannerModulePath -Path -SourceRoot`; `Get-DocsScannerCallArgument -Tokens -OpenIndex` (top-level argument spans); `Get-DocsScannerMatchingClose -Tokens -OpenIndex`; `Get-DocsScannerLiteral -Tokens -Span` (single literal or literal-only concatenation, else `$null`); `Join-DocsRouteTemplate -Prefix -Template`; `New-DocsScannerDiagnosticSet` and `Add-DocsScannerDiagnostic` / `ConvertTo-DocsScannerDiagnostic` (count and first line per `(code, path)`, then `New-DocsDiagnostic`); `Get-DocsDeclarationSha256 -Text -LineRange` only if 1020's amendment does not provide it; optional `Get-DocsScannerPrecisionLimit` | `DocsSurface.psm1`, `DocsJson.psm1` (1020) |
| `DocsTypeScriptTokens.psm1` | `ConvertTo-DocsTypeScriptToken -Text [-Jsx] [-MaxTokens 250000] [-MaxDepth 256]` returning `@{ Tokens; Diagnostics }` | `DocsScannerCommon.psm1` |
| `DocsCSharpTokens.psm1` | `ConvertTo-DocsCSharpToken -Text [-MaxTokens] [-MaxDepth]` returning `@{ Tokens; HasConditional; Diagnostics }` | `DocsScannerCommon.psm1` |
| `DocsAnalyzerTypeScriptCli.psm1` | `Invoke-DocsAnalyzerTypeScriptCli -CapturedInput -Selection` | tokens, common, `DocsSurface.psm1` |
| `DocsAnalyzerTypeScriptHttp.psm1` | `Invoke-DocsAnalyzerTypeScriptHttp -CapturedInput -Selection` (two passes: per-file route and router collection, then cross-file mount resolution) | same |
| `DocsAnalyzerTypeScriptExports.psm1` | `Invoke-DocsAnalyzerTypeScriptExports -CapturedInput -Selection` | same |
| `DocsAnalyzerDotnetHttp.psm1` | `Invoke-DocsAnalyzerDotnetHttp -CapturedInput -Selection` | C# tokens, common, `DocsSurface.psm1` |
| `DocsAnalyzerDotnetConfig.psm1` | `Invoke-DocsAnalyzerDotnetConfig -CapturedInput -Selection` | common, `DocsSurface.psm1` |
| `DocsAnalyzerDotnetApi.psm1` | `Invoke-DocsAnalyzerDotnetApi -CapturedInput -Selection` | C# tokens, common, `DocsSurface.psm1` |
| `DocsAnalyzerExtensionImport.psm1` | `Invoke-DocsAnalyzerExtensionImport -CapturedInput -Selection`; `Test-DocsExtensionManifest` (pure, returns `@{ Ok; Diagnostics; Manifest }`) | common, `DocsSurface.psm1`, `DocsJson.psm1` |

Rename rationale: 1020's `Test-DocsAnalyzerRegistration` (planned by 1020) rejects a `Module` leaf that does not match `DocsAnalyzer*.psm1` and a `Function` outside `^Invoke-DocsAnalyzer[A-Za-z]+$`. `DocsExtensionImport.psm1` as named in the epic cannot be registered. `DocsAnalyzerExtensionImport.psm1` keeps the `Docs<Area>.psm1` naming contract; the epic permits research to refine module names. The epic's child specification should be updated to the new name in the same change.

Registry rows (one per line, under `# --- 900004: TypeScript and .NET analyzers ---`, `Version = '1.0.0'`):

| `Id` | `ElementKinds` | `Module` leaf | `Function` |
|---|---|---|---|
| `typescript-cli` | `cli-command`, `cli-option` | `DocsAnalyzerTypeScriptCli.psm1` | `Invoke-DocsAnalyzerTypeScriptCli` |
| `typescript-http` | `http-route` | `DocsAnalyzerTypeScriptHttp.psm1` | `Invoke-DocsAnalyzerTypeScriptHttp` |
| `typescript-exports` | `public-symbol` | `DocsAnalyzerTypeScriptExports.psm1` | `Invoke-DocsAnalyzerTypeScriptExports` |
| `dotnet-http` | `http-route` | `DocsAnalyzerDotnetHttp.psm1` | `Invoke-DocsAnalyzerDotnetHttp` |
| `dotnet-config` | `config-key` | `DocsAnalyzerDotnetConfig.psm1` | `Invoke-DocsAnalyzerDotnetConfig` |
| `dotnet-public-api` | `public-symbol` | `DocsAnalyzerDotnetApi.psm1` | `Invoke-DocsAnalyzerDotnetApi` |
| `extension-import` | all six kinds | `DocsAnalyzerExtensionImport.psm1` | `Invoke-DocsAnalyzerExtensionImport` |

All identifiers differ from 1022's (`python-cli`, `python-http`, `python-public-api`, `config-files`, `python-architecture`) and from the discovery analyzer identifiers in `analyzers.md` (`dotnet`, `configuration`, `csharp-symbols`, and others), and all satisfy the identifier grammar.

Element construction: every element is built with `New-DocsSurfaceElement` (planned by 1020) with `-AnalyzerId` equal to the row `Id`, `-LineRange` always set, `analysis_method` `scanner` (or the import rule below), and the declaration-lines digest in the field the 1020 amendment selects (C1, C2). Each analyzer returns elements sorted by `element_id` and diagnostics sorted by `id`, de-duplicates identical identities by keeping the first site by line (`duplicate-declaration` warning; TypeScript overload signatures are not reported), and skips a declaration that fails `Get-DocsElementId` validation with `declaration-invalid`.

Extension import validation order (any failure rejects the whole manifest with one blocking diagnostic and contributes no element):

| Step | Check | Code |
|---|---|---|
| 1 | Parse with `ConvertFrom-DocsJsonText` (duplicate keys rejected) and check the closed key set and constants of the manifest; discovery schemas are not pushed down, so this is a PowerShell structural check, not `Test-Json` | `extension-manifest-invalid` |
| 2 | Recompute `manifest_sha256` as `Get-DocsSha256Hex` of `ConvertTo-DocsCanonicalJson` of the manifest without the root `manifest_sha256` member (a fractional number makes canonical JSON throw, which is reported as invalid) | `extension-manifest-digest-mismatch` |
| 3 | `repository.id` equals `Selection.repository_id`; when `Selection.revision` is non-null, `repository.revision` equals it (when null, a non-blocking `extension-revision-unverified` warning) | `extension-repository-mismatch` |
| 4 | `adapter.id` is not a registered docs analyzer identifier and is unique across the selected manifests | `extension-adapter-invalid` |
| 5 | Every `source_inputs[]` path is a captured input with equal `sha256` and `size` | `extension-input-not-captured`, `extension-input-digest-mismatch` |
| 6 | Every `result_files[]` path is a captured input with equal `sha256` and `size`; the referenced document parses, has the referenced `id`, `artifact_kind`, `schema_version`, the manifest's repository and revision, and `tool` and `analyzers` equal to the adapter | `extension-result-digest-mismatch`, `extension-result-invalid` |
| 7 | Every finding's `analyzer` equals the adapter, `source.path` is a declared source input with equal `sha256`, and `line_range` lies within the captured text's physical line count | `extension-finding-source-mismatch` |
| 8 | Map findings as described under Research Question 2; copy manifest and result-file diagnostics with their `blocking` flags | (skips: `extension-finding-skipped`, non-blocking) |

`input_manifest_sha256` is not verified (it depends on the discovery profile, which the docs lib does not have); the spec should state this explicitly.

## Contract Dependencies on 1020 (and Concurrent Children)

| ID | Dependency | Options | Recommended default |
|---|---|---|---|
| C1 | `analysis_method` field on the snapshot element (D3 amendment): field name, enum and a `New-DocsSurfaceElement` parameter | (a) required element field `analysis_method` with enum `native`, `scanner`, set through `-AnalysisMethod`; (b) a property row | (a), as epic `### Amendment of 1020` states |
| C2 | Declaration-lines digest (D5): where it is stored and the exact byte rule | (a) redefine `source_sha256` as the digest over the `line_range` lines, keep the file digest in `inputs[].sha256`, and make `line_range` non-null for every scanner element; (b) add `declaration_sha256` and keep `source_sha256` as the file digest | (a): 1023 pins already compare `source_sha256` as an opaque value, so pins become declaration-level with no field rename. Byte rule: the decoded text of physical lines `start..end`, each line's terminator (CR, LF or CRLF) removed, joined with LF plus one trailing LF, UTF-8 encoded, hashed with `Get-DocsSha256Hex`; line-ending conversions then do not stale pins. The function (for example `Get-DocsDeclarationSha256 -Text -LineRange`) should live in 1020 `DocsSurface.psm1` so 1022, 1033 and 900011 agree byte for byte |
| C3 | Shape of `-Selection` | (a) profile `surface_selection` plus `repository_id` and `revision`, built by the 1022 inventory; (b) analyzer-specific options | (a) |
| C4 | `New-DocsCapturedInput`: `-MaxBytes` default, BOM handling, diagnostic code and `analyzer_id` for oversize and undecodable inputs | 1020 or 1022 pins them | Default 1048576 set by the inventory; strip one leading U+FEFF before decoding; codes `input-over-bound` and `input-undecodable`; analyzers re-emit under their own identifier |
| C5 | `New-DocsDiagnostic` has no `information` severity (only `error` when blocking, else `warning`) and no extensions parameter | (a) accept warning-only non-blocking diagnostics; (b) add a severity parameter | (a) for this child; no extension marker is needed because precision limits are identified by `(analyzer_id, code)` |
| C6 | Registry: anchor literal (`900004` versus issue number 1033); the 1020 criterion "registry has no rows"; the `DocsAnalyzer*.psm1` leaf rule | 1020 amendment renumbers or keeps placeholders; rewrites the empty-registry assertion as anchor presence plus membership | Keep the anchor text as committed by 1020; this child's plan names `DocsAnalyzerRegistry.Tests.ps1` with an explicit disposition |
| C7 | `diagnostic.code` grammar in docs common | 1020 table lists `code` without a type | Discovery identifier grammar (lowercase), as discovery `inventory-snapshot#/$defs/diagnostic` uses |
| C8 | Inventory merge precedence for an imported element that collides with a built-in element (1022) | built-in wins; import wins; fail | Built-in wins, imported element dropped with a non-blocking diagnostic (mirrors the discovery runtime's "built-in result is authoritative") |
| C9 | Ledger representation of the scanner precision limit as `deferred` with an owner (1023, possibly 1020 schema) | (a) a ledger section keyed by `(analyzer_id, code)`; (b) a schema change allowing a diagnostic identifier in place of `element_id`; (c) per-element `deferred` entries only | Decided by 1023's re-preparation; this child guarantees stable codes and the spec table |
| C10 | Cross-child consistency with the re-prepared 1022: config key quoting and `[]` array segments, `<dynamic>` prefix rendering, diagnostic code names shared by both children (`declaration-invalid`, `duplicate-declaration`, `input-over-bound`) | Shared constants in 1020 or duplicated text | Agree the strings in the epic `### Analyzer decisions` section |

The JSON envelope schema (`docs-command-envelope.schema.json`, D5) does not affect this child: it adds no subcommand.

## Behavior Semantics and Requirements Mapping

- Success: each analyzer returns `@{ Elements; Diagnostics }` with every element valid under `ConvertFrom-DocsSurfaceElement` and the registration's kinds; `Invoke-DocsAnalyzer` (planned by 1020) re-verifies kinds, `analyzer_id` and identifiers.
- Failure: a lexical error, an over-bound input or a token or depth overflow yields a blocking diagnostic and no element from that file; other files still produce elements. An analyzer never throws for content; it throws only for a contract violation in its own arguments.
- Ordering: inputs processed in ordinal path order; output sorted by `element_id` and diagnostic `id`; shuffling `CapturedInput` order does not change output bytes.
- Determinism: no clock, no random source, no hashtable enumeration order in output (ordinal sorts of keys before iteration).

Acceptance mapping (issue criteria to tests):

| Issue criterion | Verification |
|---|---|
| Expected elements for in-memory TypeScript and C# fixtures | One Pester suite per analyzer with single-quoted here-string fixtures per framework construct, asserting declarations, kinds, parents, properties and line ranges |
| Extension manifest digest mismatch rejected; match merged as inert data | `DocsAnalyzerExtensionImport.Tests.ps1`: a valid manifest built in memory (digest computed in the test with `ConvertTo-DocsCanonicalJson` and `Get-DocsSha256Hex`), then one mutation per validation step |
| Byte-identical reruns; size-bound and unclassifiable diagnostics | Per-analyzer determinism test over shuffled input order with a seeded `[System.Random]` (seed printed on failure); captured inputs with `text` `$null`; one fixture per precision-limit code |
| `analysis_method: scanner` and declaration-lines digest | Assert the field on every element; assert that editing a line outside `line_range` leaves the digest unchanged and editing inside changes it; CRLF variant built in code (`"`r`n"`), not committed |
| Distinct identifiers under the 900004 anchor only | Registration test: rows present, `Test-DocsAnalyzerRegistration` returns no finding, no identifier in the 1022 set, rows located between the 900004 anchor and the next anchor or closing delimiter |
| Precision limit documented | Spec section present; a test that every precision-limit code in the spec table is emitted by at least one fixture |
| No new Python or TypeScript; classification table | Diff name check in the plan; classification table above |
| Pester line coverage at least 85% | PoshQC coverage report per file |

## Numeric Derivation Evidence

### Claim N1: production PowerShell modules named for this child in the epic (9)

- Complete Family: the files listed under `Files (create)` for this child.
- Exhaustive Search Scope: `docs/features/epics/documentation-estate-tooling/epic.md` section `### 900004 - docs-surface-analyzers-typescript-dotnet`, and `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/issue.md` section `## Proposed Behavior`.
- Inclusion Rules: any `.psm1` file name stated as created by this child.
- Exclusion Rules: the edited `DocsAnalyzerRegistry.psm1`; bundle mirror copies; test files.
- Primary Search Strategy or Query Expression: read the epic section's `Files (create)` paragraph and list every backticked `.psm1` name.
- Primary Member Set: `DocsTypeScriptTokens.psm1`, `DocsAnalyzerTypeScriptCli.psm1`, `DocsAnalyzerTypeScriptHttp.psm1`, `DocsAnalyzerTypeScriptExports.psm1`, `DocsCSharpTokens.psm1`, `DocsAnalyzerDotnetHttp.psm1`, `DocsAnalyzerDotnetConfig.psm1`, `DocsAnalyzerDotnetApi.psm1`, `DocsExtensionImport.psm1`.
- Primary Count: 9.
- Cross-check Search Strategy or Query Expression: read the issue's `## Proposed Behavior` bullets (grouped by TypeScript, C#/.NET and other stacks) and list every parenthesized backticked `.psm1` name.
- Cross-check Member Set: `DocsTypeScriptTokens.psm1`, `DocsAnalyzerTypeScriptCli.psm1`, `DocsAnalyzerTypeScriptHttp.psm1`, `DocsAnalyzerTypeScriptExports.psm1`, `DocsCSharpTokens.psm1`, `DocsAnalyzerDotnetHttp.psm1`, `DocsAnalyzerDotnetConfig.psm1`, `DocsAnalyzerDotnetApi.psm1`, `DocsExtensionImport.psm1`.
- Cross-check Count: 9.
- Member-set Comparison: the normalized sets are identical (same nine names, no duplicate, no extra).

### Claim N2: production PowerShell modules in the recommended design (10, or 11 with the conditional JSX split)

- Complete Family: modules in `## Recommended Module and Function Design`.
- Exhaustive Search Scope: that table and the `## Research Question 10` classification table of this file.
- Inclusion Rules: created `.psm1` files under `.claude/lib/docs/`, excluding the conditional `DocsTypeScriptJsx.psm1`.
- Exclusion Rules: as N1.
- Primary Search Strategy or Query Expression: N1's set with `DocsExtensionImport.psm1` replaced by `DocsAnalyzerExtensionImport.psm1`, plus `DocsScannerCommon.psm1`.
- Primary Member Set: the eight unchanged N1 names, `DocsAnalyzerExtensionImport.psm1`, `DocsScannerCommon.psm1`.
- Primary Count: 10.
- Cross-check Search Strategy or Query Expression: the `.claude/lib/docs/` rows of the classification table marked create, excluding the conditional row and the edit row.
- Cross-check Member Set: `DocsTypeScriptTokens.psm1`, `DocsAnalyzerTypeScriptCli.psm1`, `DocsAnalyzerTypeScriptHttp.psm1`, `DocsAnalyzerTypeScriptExports.psm1`, `DocsCSharpTokens.psm1`, `DocsAnalyzerDotnetHttp.psm1`, `DocsAnalyzerDotnetConfig.psm1`, `DocsAnalyzerDotnetApi.psm1`, `DocsAnalyzerExtensionImport.psm1`, `DocsScannerCommon.psm1`.
- Cross-check Count: 10.
- Member-set Comparison: identical sets. With the registry edit and one bundle copy per file, the change touches at least 22 production PowerShell files, which exceeds the direct-mode batch cap (brief `## Batch Budget`).

### Claim N3: registry rows appended (7)

- Complete Family: analyzer identifiers this child registers.
- Exhaustive Search Scope: the registry-row table of this file and the input-selection table under Research Question 6.
- Inclusion Rules: one row per registered analyzer identifier.
- Exclusion Rules: tokenizer and common modules (not registrable under the `DocsAnalyzer*.psm1` and `Invoke-DocsAnalyzer*` rules).
- Primary Search Strategy or Query Expression: list the `Id` column of the registry-row table.
- Primary Member Set: `typescript-cli`, `typescript-http`, `typescript-exports`, `dotnet-http`, `dotnet-config`, `dotnet-public-api`, `extension-import`.
- Primary Count: 7.
- Cross-check Search Strategy or Query Expression: list the `Analyzer identifier` column of the input-selection table.
- Cross-check Member Set: `typescript-cli`, `typescript-http`, `typescript-exports`, `dotnet-http`, `dotnet-public-api`, `dotnet-config`, `extension-import`.
- Cross-check Count: 7.
- Member-set Comparison: identical sets after ordinal sorting.

## Testing Implications

- One Pester suite per production module under `tests/scripts/claude-lib/docs/`, mirroring the module name (`DocsTypeScriptTokens.Tests.ps1`, ...), plus a registration suite for the appended rows. Fixtures are single-quoted here-strings inside the suites (or committed fixture data under `tests/scripts/claude-lib/docs/fixtures/` read as data); no temporary files, no processes, no mocks of the code under test.
- Captured inputs in tests are built with 1020's `New-DocsCapturedInput` from in-memory bytes, so the tests exercise the same contract as the inventory.
- Tokenizer tests cover each lexical state and its boundary: escapes, template substitution nesting, regex versus division, JSX text with apostrophes, verbatim and raw strings with quote runs, interpolation holes with nested strings, directives, token and depth limits.
- Analyzer tests cover positive constructs, each diagnostic code, multi-line calls, chained calls, cross-file resolution (relative import mounts, re-export expansion with a cycle), partial types across two paths, and value non-leakage (a configuration fixture whose values are distinctive strings; assert they occur nowhere in the serialized output).
- Determinism: shuffled input order with a seeded RNG; two runs compared as canonical JSON text.
- Suites remove every imported `Docs*` and `DiscoveryEncoding` module in `AfterAll` (1020 constraint), because the shard and single-process runs share a session.
- T3: no property-test density obligation; a seeded property test for the declaration-lines digest invariance (lines outside the range) is still recommended because it is cheap.

## Pre-Mortem

- **Review checklists**: a reviewer can fail the change for a Selection, digest or `analysis_method` usage that diverges from 1020's amended contract, or for an analyzer identifier or diagnostic code that conflicts with 1022. Mitigation: the plan's first phase re-reads the merged 1020 amendment and the re-prepared 1022 spec and records each consumed symbol with its final name; C1-C10 are acceptance prerequisites, not assumptions.
- **Coverage**: the PoshQC report could show a module below 85% because tokenizer error paths and JSX states are rarely hit by happy-path fixtures. Mitigation: one fixture per lexical error and per precision-limit code; per-file coverage read from `artifacts/pester/powershell-coverage.xml` (brief `## PowerShell Route and PoshQC MCP Limits`), never from an MCP summary.
- **Mirror parity**: a module edited after its bundle copy was made, or a new file missing from `core.json`, fails `Docs.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py` or `test_push_down_claude_pack_manifest_completeness.py`. Mitigation: the plan copies every bundle file as the last step of each module task and runs the three contract tests plus `test_push_down_pack_manifest_dependency_closure.py` before review; the plan alters no brief fact, so no brief-update task is needed.
- **File size**: the TypeScript tokenizer, the TypeScript HTTP analyzer or the .NET API analyzer could pass 500 lines (guidance) or approach 800 (hard block; new files have no baseline entry). Mitigation: pre-split into `DocsScannerCommon.psm1` and, if needed, `DocsTypeScriptJsx.psm1`; the plan records a line budget per module and checks logical line counts with `@(Get-Content -LiteralPath <path>).Count`, not `Measure-Object -Line`.
- **Test isolation**: modules imported with `-Force` by both the registry seam and the suites can leak across suites in a shard or single-process run. Mitigation: `AfterAll` removal of every `Docs*` and `DiscoveryEncoding` module; three seeded shuffled file-order runs of the touched suites and one fresh single-process run over `tests/scripts` recorded under the feature's `evidence/regression-testing/` (brief `## Test Isolation Checks`).
- **CI-only behavior**: the shards run on `windows-latest` with the runner's PowerShell; `.gitattributes` `* text=auto eol=lf` turns a committed CRLF fixture into LF, so a line-ending test passes locally and fails in CI or the reverse. Mitigation: build CRLF and BOM fixtures in code; avoid any dependency on gitignored `artifacts/` state; assert no wall-clock behavior.
- **Evidence**: an AC that cites a count or coverage figure from a PoshQC MCP result is unsatisfiable, and an evidence file at a non-canonical path is rejected. Mitigation: counts from `artifacts/pester/pester-junit.xml`, coverage from the PoshQC XML; every artifact under the feature's `evidence/<kind>/` with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`, stamped at write time.

## Automation Feasibility

No human interaction is required for research, planning or execution of this child. All inputs are repository files; every test uses in-memory fixtures; validation runs through the PoshQC module and the existing Python contract tests. Execution needs the large or preparation route in the item worktree because the production file count exceeds the direct-mode batch cap (see N2 and the brief's `## Batch Budget`). Execution cannot start before 1020 (with its D3/D5 amendment) is merged into the epic integration branch, and it should start after the re-prepared 1022 fixes Selection, inventory merge precedence and the shared diagnostic codes. The owner questions below have provisional defaults, so none blocks planning.

## Owner Questions

- **OQ-1 - Analysis method of imported elements.** D3 allows `native` or `scanner`, but an element imported from an extension-result manifest was produced by neither the docs scanner nor a docs native analyzer. Options: (a) add a third value such as `imported` to the 1020 enum; (b) let the manifest declare it through an extensions key such as `docs.analysis-method` (`native` or `scanner`), with `scanner` when absent as the conservative assumption; (c) always record `scanner`. Which should apply? Research leans to (b) because it keeps the two-value enum.
- **OQ-2 - Ledger representation of the precision limit.** The ledger is keyed by element identifier, and an unclassified construct has no element. Should 1023 record the precision limit as a ledger section keyed by `(analyzer_id, diagnostic code)`, should the ledger schema accept a diagnostic identifier, or should the precision limit be recorded only in documentation with no ledger entry? (Contract dependency C9.)
- **OQ-3 - JavaScript sources.** The child is scoped to TypeScript. Express, Fastify, Commander and yargs code is often plain JavaScript (`*.js`, `*.mjs`, `*.cjs`, `*.jsx`), which the same tokenizer can read. Should JavaScript inputs be selected in this child, or stay out of scope (provisional default) and be listed in the precision limit?
- **OQ-4 - Digest of a configuration key line.** D5 requires the element digest to cover the declaration's lines, and the analyzer guarantee forbids value leakage. A digest over an `appsettings*.json` line includes the configuration value and allows a low-entropy value to be confirmed by hashing guesses. Should the `config-key` digest cover the line with the value replaced by its type name (research default), the raw line, or only the key path and value type?
- **OQ-5 - Anchor numbering.** 1020 commits the registry anchor `# --- 900004: TypeScript and .NET analyzers ---` and the dispatch anchors with manifest placeholders, while this child is now issue #1033. Should 1020's amendment renumber the anchors to issue numbers, or do the placeholders stay as committed text? (Contract dependency C6.)
