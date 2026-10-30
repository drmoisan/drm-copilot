# docs-profile-and-artifact-schemas — Spec

- **Issue:** #1020
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 1020, wave 0, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T22-15
- **Status:** Draft
- **Version:** 0.3 (re-preparation for the refined implementation-language rule)
- **Research (primary design source):** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md`
- **Research (language-independent sections only):** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md`

## Revision Note

Version 0.2 of this specification described a Python package (`packages/docs-runtime`,
`drm_copilot_docs`, `dev.docs.*` Poetry scripts, Python tests, `pyproject.toml` and `poetry.lock`
edits). That design is withdrawn by the epic `## Owner Directive: Implementation Language
(2026-10-30, refined)`. This version specifies the PowerShell design. Language-independent content
(schema field shapes, docs common `$defs`, element model, dispositions, parity dimensions,
front-matter fields) is kept and revised where the addendum research or the orchestrator probe
changes it. Where `issue.md` still describes the Python design, this file is authoritative.

## Overview

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
page-check, ledger, generator, MCP and enforcement features can be built in parallel. No
documentation profile, documentation artifact schema, surface element model or analyzer contract
exists in the repository today. Without them, every downstream feature would invent its own shapes,
and the coverage ledger, parity matrix and `docs-complete` receipt could not be validated
consistently. Framework code must also stay domain-neutral: all repository specificity is runtime
configuration in a docs profile.

This feature delivers those contracts as PowerShell modules under `.claude/lib/docs/`, which the
existing Claude push-down delivers to destination repositories, plus versioned JSON schemas and
examples. Features 1021, 900003, 900004, 1023, 900006 and 900008 consume the modules directly;
900007 consumes them through `Invoke-DocsCommand.ps1`. The contracts below are normative: a
downstream feature that needs a different shape changes this specification through an epic-level
update rather than diverging locally.

The epic `### Naming contract (fixed for all children)` is restated, not changed, here.

## Behavior

Create eight production PowerShell files under `.claude/lib/docs/` (see `## Numeric Derivation
Reference`): the six files named by the epic (`DocsProfile.psm1`, `DocsSchema.psm1`,
`DocsSurface.psm1`, `DocsAnalyzerRegistry.psm1`, `DocsProfileCommands.psm1`,
`Invoke-DocsCommand.ps1`) and two refinement modules (`DocsJson.psm1`, `DocsFinding.psm1`). They
provide:

- JSON reading through `System.Text.Json` into ordinal hashtables with duplicate-key detection, and
  deterministic serialization, canonical JSON and SHA-256 helpers that delegate to the existing
  `.claude/lib/discovery-validation/DiscoveryEncoding.psm1`.
- A finding model, deterministic finding order, command results, the `-Json` envelope and the text
  report.
- Schema loading, in-memory schema composition (epic Q1), artifact validation through `Test-Json`
  as the schema gate, and a PowerShell structural walk that produces field-naming findings with
  JSON pointers.
- The surface element model: kinds `cli-command`, `cli-option`, `http-route`, `config-key`,
  `public-symbol`, `architecture-component`, with deterministic identifiers derived from kind,
  path and declaration.
- The analyzer contract and an owner-anchored analyzer registry, empty in this feature, that 900003
  and 900004 extend.
- Profile parsing, schema and semantic validation, and a starter profile.
- The entry script `Invoke-DocsCommand.ps1 -Command <subcommand> [arguments]` with an
  owner-anchored dispatch table and the subcommands `init` and `validate-profile`.
- Six artifact schemas plus one definitions-only `common.schema.json` under `schemas/docs/v1/`,
  one example per artifact schema under `examples/docs/v1/`, and a byte-identical runtime copy of
  the schemas under `.claude/lib/docs/schemas/v1/` (owner question OQ-1).
- Push-down registration: every file under `.claude/lib/docs/` listed in the Claude core pack
  manifest and mirrored byte-identically to
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- `quality-tiers.yml` registration of `.claude/lib/docs` (owner question OQ-4).

No Python or TypeScript file is created or edited. No discovery runtime file, discovery schema or
`.claude/lib/discovery-validation/` file is edited. The Codex customization tree is not changed
(owner question OQ-2).

## Inputs / Outputs

- Inputs:
  - A docs profile file, JSON only. Default path `docs/documentation-estate/docs-profile.json`
    (`Get-DocsDefaultProfilePath`); `-Profile <relative path>` overrides it. YAML is not accepted:
    PowerShell 7 has no built-in YAML parser and epic assumption A8 forbids a new third-party
    module.
  - Arguments to `Invoke-DocsCommand.ps1` (see `### Entry script`).
  - Runtime schemas read from `.claude/lib/docs/schemas/v1/`, located with literal
    `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` joins. The same code path runs in this
    repository and in a destination repository.
  - No environment variable is read. The repository root is `-RepositoryRoot` when given, otherwise
    the current location; it is never derived from `$PSScriptRoot`.
- Outputs:
  - `init`: the starter profile and the planned writes in `result`; with `-Write`, the profile file
    and any template-table files (none in 1020).
  - `validate-profile`: findings and a result in text (default) or the `-Json` envelope on stdout;
    on exit 3, one fixed line on stderr.
- Versioning and compatibility:
  - Schema family version `1.0.0`; every artifact carries `schema_version` const `"1.0.0"`.
  - A breaking change to any schema or to an exported function contract in this specification
    requires a new family (`urn:drm-copilot:docs:2.0.0:*`, `schemas/docs/v2/`) and an epic-level
    update.
- Runtime prerequisite: PowerShell 7.4 or later (owner question OQ-3). Below 7.4 every subcommand
  exits 3 with `DOCS_RUNTIME_UNSUPPORTED`.

## API / CLI Surface

### Module conventions (all files under `.claude/lib/docs/`)

- Conventions pinned by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`: the help
  block contains the sentence token `imports its siblings with -ErrorAction Stop`;
  `Set-StrictMode -Version Latest` is followed immediately by `$ErrorActionPreference = 'Stop'`;
  every column-0 `Import-Module` carries `-ErrorAction Stop`.
- Every `$PSScriptRoot` use is the literal form `Join-Path -Path $PSScriptRoot -ChildPath
  '<literal>'`, so the existing recognized-form and dependency-closure tests
  (`tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`) see every sibling
  module, command module, schema and template target.
- Every function is an advanced function with `[CmdletBinding()]`; parameter names are PascalCase.
- "Pure" means no filesystem, clock, process, environment or module-scope mutable state. Pure
  functions take in-memory strings and hashtables. No module keeps a schema or composition cache.
- Command modules never write output and never call `exit`; only `Invoke-DocsCommand.ps1` does.

Import graph (literal joins):

| File | Role | Imports |
|---|---|---|
| `DocsJson.psm1` | Parsing, deterministic serialization, canonical JSON, SHA-256 | `../discovery-validation/DiscoveryEncoding.psm1` |
| `DocsFinding.psm1` | Finding model, ordering, bound, command result, envelope, text report | `DocsJson.psm1` |
| `DocsSchema.psm1` | Schema table, schema reading, composition, artifact validation, structural walk, version floor | `DocsJson.psm1`, `DocsFinding.psm1` |
| `DocsSurface.psm1` | Element kinds, path and revision grammar, stable and element identifiers, element and diagnostic records | `DocsJson.psm1`, `DocsFinding.psm1` |
| `DocsAnalyzerRegistry.psm1` | Analyzer contract, registration table, selection, captured inputs, invocation | `DocsSurface.psm1`, `DocsFinding.psm1` |
| `DocsProfile.psm1` | Profile parse, schema and semantic validation, starter profile | `DocsJson.psm1`, `DocsSchema.psm1`, `DocsFinding.psm1`, `DocsAnalyzerRegistry.psm1` |
| `DocsProfileCommands.psm1` | `init` and `validate-profile` command functions, init template table | `DocsProfile.psm1`, `DocsSchema.psm1`, `DocsFinding.psm1`, `DocsJson.psm1` |
| `Invoke-DocsCommand.ps1` | Entry: parameters, dispatch table, argument parsing, real command context, output, exit | `DocsFinding.psm1`, `DocsJson.psm1`; command modules imported only when their row is selected |

`DiscoveryEncoding.psm1` is already listed in the Claude core pack manifest, so the cross-area
import is closed under core.

### `DocsJson.psm1` (pure)

- `ConvertFrom-DocsJsonText -Text <string> [-ArtifactPath <string>] [-MaxDepth <int> = 64]` returns
  `@{ Value; Findings }`. Objects become hashtables with the ordinal comparer, integers `Int64`,
  other numbers `Double`, strings unchanged (no DateTime coercion). Findings: `DOCS_JSON_INVALID`
  (malformed text, including an empty file), `DOCS_JSON_DUPLICATE_KEY` (at the repeated member's
  pointer), `DOCS_JSON_TOO_DEEP`. `ConvertFrom-Json` is never used for artifacts.
- `ConvertTo-DocsJsonText -Value <object> [-Indented]` returns text with ordinal key order at every
  depth, relaxed escaping, LF line endings and one trailing LF. Used for files a person reads.
- `ConvertTo-DocsCanonicalJson -Value <object>` delegates to `ConvertTo-DiscoveryCanonicalJson`
  (compact, sorted keys, trailing LF).
- `Get-DocsSha256Hex -Text <string>` and `Get-DocsBytesSha256Hex -Bytes <byte[]>` delegate to
  `Get-DiscoverySha256Hex` and `Get-DiscoveryBytesSha256Hex`; output is lowercase hex.

### `DocsFinding.psm1` (pure)

- `New-DocsFinding -Code <string> -Severity <error|warning|info> -Message <string> -NextAction
  <string> [-ArtifactPath <string>] [-Pointer <string> = ''] [-RelatedId <string[]>] [-RelatedPath
  <string[]>]` returns an ordered hashtable with exactly the eight keys of the docs common
  `finding` definition. It enforces the code grammar `^[A-Z][A-Z0-9_]*$`, the RFC 6901 pointer
  grammar, the identifier grammar for related identifiers and the relative-path grammar for paths,
  and sorts and de-duplicates both related lists. An invalid argument throws.
- `Get-DocsChildPointer -Pointer <string> -Part <object>` escapes `~` and `/` per RFC 6901.
- `Get-DocsOrderedFinding -Finding <object[]> [-Limit <int> = 100]` returns findings sorted by
  artifact path (null as empty), pointer, code, related identifiers, related paths, severity,
  message, next action (ordinal comparison), de-duplicated, bounded at `Limit`, with one
  `FINDINGS_LIMIT` error finding appended when truncated.
- `Test-DocsFindingHasError -Finding <object[]>` returns `$true` when any finding has severity
  `error`.
- `New-DocsCommandResult -Command <string> -ExitCode <0|1|2|3> -Finding <object[]> [-Result
  <object>] [-Line <string[]>]` returns a `[pscustomobject]` with `Command`, `ExitCode`, `Findings`
  (ordered through `Get-DocsOrderedFinding`), `Result` and `Line`.
- `ConvertTo-DocsEnvelopeText -CommandResult <object>` returns the canonical JSON of the envelope
  (see `### Exit codes and the -Json envelope`).
- `ConvertTo-DocsReportText -CommandResult <object>` returns one line per finding
  (`<severity> <code> <artifact_path><pointer>: <message>`, path omitted when null), then the
  command-specific lines, then the summary line
  `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`.

### `DocsSchema.psm1`

- `Get-DocsSchemaName` (pure) returns the schema names in fixed order: `common`, `docs-profile`,
  `surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`,
  `docs-validation-receipt`, followed by the anchor comment `# --- 1021: page-metadata ---`.
- `Get-DocsSchemaPath` returns an ordered map of name to path, built from one literal join per
  file, for example `Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-profile.schema.json'`.
- `Read-DocsSchemaSet [-SchemaPath <IDictionary>] [-ReadText <scriptblock>]` is the module's only
  read and returns an ordered map of name to text.
- `Join-DocsSchemaText -SchemaText <string> -CommonSchemaText <string>` (pure) returns
  `@{ Text; Value; Findings }` per `### Schema composition`.
- `Get-DocsComposedSchemaSet -SchemaSet <IDictionary>` (pure) composes every artifact schema once per
  call and returns an ordered map of artifact kind to `@{ Text; Value }`; composition findings are
  returned alongside and make the set unusable (exit 3 at the command boundary).
- `Test-DocsArtifactText -ArtifactKind <string> -JsonText <string> -ComposedSchemaSet <IDictionary>
  [-ArtifactPath <string>]` (pure apart from the built-in `Test-Json`) returns ordered findings per
  `### Artifact validation`.
- `Get-DocsSchemaStructuralFinding -Schema <IDictionary> -Instance <object> -RootSchema
  <IDictionary> [-Pointer <string> = ''] [-ArtifactPath <string>]` (pure) is the structural walk
  per `### Structural walk`.
- `ConvertFrom-DocsSchemaErrorRecord -ErrorRecord <ErrorRecord> [-ArtifactPath <string>]` (pure)
  maps one `Test-Json` ErrorRecord to a `DOCS_SCHEMA_INVALID` finding whose pointer is the final
  ` at '<pointer>'` of the message when present, otherwise empty.
- `Get-DocsRuntimeVersionError [-PowerShellVersion <version> = $PSVersionTable.PSVersion]` (pure)
  returns the fail-closed message below 7.4, otherwise `$null` (precedent
  `Get-DiscoveryRuntimeVersionError` in `.claude/lib/discovery-validation/DiscoveryValidation.psm1`).

#### Schema composition (epic Q1 resolution)

Orchestrator probe (PowerShell 7.6.9, 2026-10-30): `Test-Json` rejects a cross-file `$ref` by
default; inline `#/$defs/...` refs work, including `$defs` keys containing `.` such as
`common.kind`; two calls with the same `$id` and different schema content do not collide.
Composition therefore relies only on inline refs, needs no `-FetchExternalReference` and no global
schema registry, and keeps one copy of the shared vocabulary.

`Join-DocsSchemaText`:

1. Parse both texts with `ConvertFrom-DocsJsonText`.
2. Copy every docs common `$defs/<name>` into the target `$defs` as `common.<name>`. A target that
   already defines a `$defs` key beginning with `common.` yields `DOCS_SCHEMA_COMPOSITION_CONFLICT`.
3. Rewrite every string-valued `$ref` keyword:
   - `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>` becomes `#/$defs/common.<name>`; a `<name>`
     absent from docs common yields `DOCS_SCHEMA_REF_UNRESOLVED`;
   - inside the copied definitions, `#/$defs/<name>` becomes `#/$defs/common.<name>`;
   - a target-local ref beginning with `#` is unchanged;
   - any other ref (another URN, a file name, any URI scheme) yields `DOCS_SCHEMA_REF_UNRESOLVED`
     and is never fetched.
   Only keys named `$ref` whose value is a string are rewritten; a `properties` member named
   `$schema` or `$ref` maps to an object and is not a keyword.
4. Remove the root `$id` from the composed schema; keep the root `$schema` for dialect selection.
   The probe shows no collision would occur; removal keeps the composed text free of any document
   identity and costs nothing.
5. Serialize with `ConvertTo-DocsJsonText`.

#### Artifact validation

Orchestrator probe (PowerShell 7.6.9, 2026-10-30): a failure inside a `$ref` target makes
`Test-Json` return `False` with zero ErrorRecords, and when several failures exist only one
ErrorRecord is written. Because composition places almost every field behind an inline `$ref`,
`Test-Json` messages cannot be relied on to name the failing field. Field naming therefore comes
from the PowerShell structural walk; `Test-Json` is the schema gate.

`Test-DocsArtifactText`:

1. Parse the instance with `ConvertFrom-DocsJsonText`. Any parse finding is returned and
   validation stops.
2. Run `Test-Json -Json <original text after BOM removal> -Schema <composed text> -ErrorAction
   SilentlyContinue -ErrorVariable <var>`.
3. Run `Get-DocsSchemaStructuralFinding` over the parsed instance with the composed schema value.
4. Result:
   - `Test-Json` `True` and no walk finding: no findings (valid).
   - Any walk finding: the walk findings are returned and `Test-Json` ErrorRecords are discarded.
     This includes the case where `Test-Json` returned `True` (fail closed; a test pins that the
     committed examples never reach this case).
   - `Test-Json` `False` and no walk finding: one `DOCS_SCHEMA_INVALID` finding per ErrorRecord
     through `ConvertFrom-DocsSchemaErrorRecord`, or, when there is no ErrorRecord, exactly one
     `DOCS_SCHEMA_INVALID` finding with pointer `''` and a message naming the artifact kind.
   - An unknown `ArtifactKind` throws `DOCS_SCHEMA_UNKNOWN_KIND`.

Tests assert finding codes, pointers and that messages contain the field name. They do not assert
JsonSchema.Net wording, which varies by PowerShell release.

#### Structural walk

`Get-DocsSchemaStructuralFinding` evaluates this keyword subset over the composed schema and returns
`error` findings, each with the instance pointer and a message that names the field (the last
pointer segment, or the property name for a missing or unknown property):

| Keyword | Behavior | Finding code |
|---|---|---|
| `$ref` (local `#/$defs/...` only) | Resolve in `RootSchema` and continue; expansion depth bounded at 64 | `DOCS_SCHEMA_TOO_DEEP` on overflow |
| `type` (string or array of names) | Compare with the JSON type of the value (`integer` accepts `Int64`) | `DOCS_SCHEMA_TYPE_MISMATCH` |
| `required` | Each absent name yields one finding at `<pointer>/<name>` | `DOCS_SCHEMA_REQUIRED_MISSING` |
| `properties` | Walk each present member with its subschema | — |
| `additionalProperties: false` | Each member not in `properties` yields one finding at its pointer | `DOCS_SCHEMA_PROPERTY_UNKNOWN` |
| `enum`, `const` | Value not allowed; message names the field and the allowed values | `DOCS_SCHEMA_VALUE_NOT_ALLOWED` |
| `items` | Walk each element at `<pointer>/<index>` | — |
| `minItems`, `maxItems` | Array length outside the bound | `DOCS_SCHEMA_ITEM_COUNT` |
| `allOf` | Walk every member at the same location | — |
| `if` / `then` / `else` | `if` holds when the walk of `if` yields no finding; then walk `then`, else walk `else` | — |
| `anyOf` | Holds when the walk of any branch yields no finding; otherwise one finding at the location | `DOCS_SCHEMA_NO_BRANCH_MATCH` |

Every other keyword (for example `pattern`, `uniqueItems`, `minimum`, `format`) is ignored by the
walk and enforced only by `Test-Json`. The walk is pure, has no cache and never mutates its inputs.
A later child that adds a schema whose failures must name a field keeps those constraints within
this subset or accepts a `DOCS_SCHEMA_INVALID` finding for them.

### `DocsSurface.psm1` (pure)

- `Get-DocsElementKind` returns the element kinds in contract order; `Test-DocsElementKind -Kind`.
- `Test-DocsRelativePath -Path` (POSIX relative path grammar, equal to docs common
  `relative-path`); `Test-DocsFullRevision -Revision` (40 or 64 lowercase hex).
- `Get-DocsStableId -Prefix <string> -Value <object>` returns `<prefix>-` plus the lowercase hex
  SHA-256 of `ConvertTo-DocsCanonicalJson -Value`. An `AUTHORIZATION_INPUT_INVALID: ...` error from
  `DiscoveryEncoding.psm1` is rethrown as `DOCS_IDENTITY_INPUT_INVALID: ...`.
- `Get-DocsElementId -Kind <string> -Path <string> -Declaration <string>` per
  `### Element identifiers`.
- `Test-DocsElementId -ElementId <string>` (docs common `element-id` pattern).
- `New-DocsSurfaceElement -Kind -Path -Declaration -Name -AnalyzerId -SourceSha256 [-ParentId]
  [-LineRange <int[]>] [-Property <IDictionary>] [-Extension <IDictionary>]` returns an ordered
  hashtable in the snapshot `element` shape with a computed `element_id`; `cli-option` requires a
  parent identifier beginning `cli-command-`; `LineRange` requires `1 <= start <= end`.
- `ConvertFrom-DocsSurfaceElement -Record <IDictionary>` re-verifies `element_id` and throws
  `DOCS_ELEMENT_ID_MISMATCH` for a record whose identifier differs from the recomputed one.
- `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Blocking <bool> = $true]` returns the docs
  `diagnostic` shape with `id` equal to `Get-DocsStableId -Prefix 'diagnostic' -Value
  @{ analyzer; code; path }`, severity `error` when blocking, otherwise `warning`.

#### Element identifiers

- Rule: `element_id = <kind> + "-" + lowercase hex SHA-256 of the UTF-8 bytes of
  canonical_json({"declaration": D, "kind": K, "path": P}) + "\n"`, computed as
  `Get-DocsStableId -Prefix $Kind -Value ([ordered]@{ kind = $Kind; path = $Path; declaration =
  $Declaration })`. This mirrors the discovery runtime's findings identity; `DiscoveryEncoding.psm1`
  documents byte agreement with that runtime.
- Input validation before hashing (throws `DOCS_IDENTITY_INPUT_INVALID` naming the argument): `Kind`
  is one of the element kinds; `Path` passes `Test-DocsRelativePath`; `Declaration` is non-blank,
  has no leading or trailing whitespace, no C0 control characters and no unpaired UTF-16 surrogate
  (checked with a throwing `UTF8Encoding`). No Unicode normalization is applied.
- Because the hashed value is canonical JSON of three named members, concatenation ambiguities (for
  example path `a/b` with declaration `c` versus path `a` with declaration `b/c`) cannot collide.
- Declaration conventions per kind (binding on 900003 and 900004):

| Kind | Declaration | Example |
|---|---|---|
| `cli-command` | full command path | `tool docs inventory` |
| `cli-option` | command path, one space, long option | `tool docs inventory --analyzer` |
| `http-route` | upper-case method, one space, route template | `GET /items/{id}` |
| `config-key` | dotted key path | `tool.settings.timeout` |
| `public-symbol` | qualified name | `example_pkg.module.function` |
| `architecture-component` | package or module path | `example_pkg.analyzers` |

### `DocsAnalyzerRegistry.psm1`

- `Get-DocsAnalyzerRegistration` (pure) returns the committed registration rows.
- `Test-DocsAnalyzerRegistration -Registration <object[]>` (pure) returns findings
  (`DOCS_ANALYZER_REGISTRATION_INVALID` with a pointer to the row and field): duplicate `Id`, `Id`
  outside the identifier grammar, empty `ElementKinds` or a kind outside `Get-DocsElementKind`,
  `Module` not resolving inside `.claude/lib/docs/` or without a `DocsAnalyzer*.psm1` leaf,
  `Function` not matching `^Invoke-DocsAnalyzer[A-Za-z]+$`, blank `Version`.
- `Select-DocsAnalyzerRegistration -Registration <object[]> -ElementKind <string[]> [-AnalyzerId
  <string[]>]` (pure) validates the whole request before any import, reports each unknown identifier
  as `DOCS_ANALYZER_UNKNOWN`, and returns rows sorted by `Id` (invariant under input order).
- `New-DocsCapturedInput -Path <string> -Bytes <byte[]> [-MaxBytes <int>]` (pure) returns
  `@{ path; sha256; size; text; diagnostic }`; strict UTF-8 decoding; an oversize or undecodable
  input carries a diagnostic and `text` `$null`.
- `Invoke-DocsAnalyzer -Registration <object> -CapturedInput <object[]> -Selection <object>
  [-ImportModule <scriptblock>]` imports the module through the seam (default `Import-Module -Name
  <path> -Force -ErrorAction Stop`), calls the analyzer function, validates the output (kinds within
  the registration, `analyzer_id` equal to `Id`, recomputed element identifiers) and returns
  `@{ Elements; Diagnostics }` sorted by identifier.
- Analyzer function contract (900003, 900004): `Invoke-DocsAnalyzer<Name> -CapturedInput
  <object[]> -Selection <object>` returns `@{ Elements = @(...); Diagnostics = @(...) }`; pure,
  deterministic, no I/O, inputs not mutated; an unclassifiable or oversize input yields a diagnostic
  rather than a partial result.
- Registry form (owner-anchored slots; 1020 commits no rows):

```powershell
$script:DocsAnalyzerRow = @(
    # --- 900003: Python and configuration analyzers ---
    # --- 900004: TypeScript and .NET analyzers ---
)
```

  Row form: `[pscustomobject]@{ Id = '<identifier>'; Version = '1.0.0'; ElementKinds = @('<kind>');
  Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzer<Name>.psm1'); Function =
  'Invoke-DocsAnalyzer<Name>' }`, one row per line. Profiles select analyzer identifiers only; no
  profile names a module.

### `DocsProfile.psm1`

- `Get-DocsDefaultProfilePath` returns `docs/documentation-estate/docs-profile.json`.
- `ConvertFrom-DocsProfileText -Text <string> -ArtifactPath <string> -ComposedSchemaSet
  <IDictionary> [-AnalyzerId <string[]>]` (pure) returns `@{ Profile; Findings; Ok }`: parse, then
  `Test-DocsArtifactText -ArtifactKind 'docs-profile'`, then semantic checks. `Profile` is the
  parsed ordinal hashtable with snake_case keys, `$null` when parse or schema validation fails.
  `Ok` is `$true` when no `error` finding exists. `AnalyzerId` defaults to the identifiers of
  `Get-DocsAnalyzerRegistration`.
- `Test-DocsProfileSemantic -Profile <IDictionary> -AnalyzerId <string[]>` (pure) returns `error`
  findings with a pointer to the offending field: `DOCS_PROFILE_AUDIENCE_DUPLICATE`,
  `DOCS_PROFILE_ROOT_DUPLICATE`, `DOCS_PROFILE_AUDIENCE_UNKNOWN`
  (`/documentation_roots/<n>/audience_ids/<m>`), `DOCS_PROFILE_MODE_NOT_IN_POLICY`
  (`/diataxis_policy/directory_modes/<n>/mode`), `DOCS_ANALYZER_UNKNOWN`
  (`/surface_selection/analyzers/<n>`).
- `New-DocsStarterProfile [-RepositoryId <string> = 'repository']` (pure) returns a profile that
  passes `ConvertFrom-DocsProfileText` with the committed (empty) registry; it omits
  `surface_selection.analyzers` and sets `completion_gates.integration_pr_gate.enabled` to `false`.

### `DocsProfileCommands.psm1`

- `Invoke-DocsInitCommand -Argument <IDictionary> -Context <object>`; options `RepositoryId`
  (value), `Profile` (value), `Write` (switch), `Force` (switch).
- `Invoke-DocsValidateProfileCommand -Argument <IDictionary> -Context <object>`; option `Profile`
  (value).
- `Get-DocsInitTemplate` (pure) returns the init template table: rows
  `[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/<file>');
  Destination = '<destination-relative path>' }` under the anchors
  `# --- 1021: page-check configuration ---` and `# --- 900008: docs workflow ---`. 1020 commits the
  mechanism and both anchors with no rows; the profile itself is generated by
  `New-DocsStarterProfile`, not copied.

`init` behavior (consumer configuration delivery decision):

- Without `-Write`: performs only destination existence checks, writes nothing, and returns exit 0
  with `result` `{profile, planned_writes: [{path, action}]}`, where `action` is `create`,
  `overwrite` (destination exists and `-Force` given) or `exists` (destination exists, no `-Force`).
- With `-Write`: every destination is checked first. If any exists and `-Force` is absent, the
  command exits 1 with one `DOCS_INIT_TARGET_EXISTS` finding per existing path and writes nothing.
  Otherwise it writes each file through `Context.WriteText` (`create`, or `overwrite` under
  `-Force`) and exits 0.
- `-RepositoryId` outside the identifier grammar or a non-relative `-Profile` is a usage error
  (exit 2).
- The starter profile is self-validated before it is returned; a self-validation failure is a
  defect guard that exits 3 with `DOCS_CLI_RUNTIME`.

`validate-profile` behavior:

- Reads the profile through `Context.ReadText`. An absent profile exits 1 with
  `DOCS_PROFILE_MISSING` (pointer `''`, artifact path the profile path).
- Exit 0 when `ConvertFrom-DocsProfileText` returns no `error` finding; exit 1 otherwise. Each
  finding names its JSON pointer and the failing field. Examples: a profile without `audiences`
  yields `DOCS_SCHEMA_REQUIRED_MISSING` at `/audiences`; an unknown element kind yields
  `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/surface_selection/element_kinds/<n>`; a duplicate key yields
  `DOCS_JSON_DUPLICATE_KEY`.
- `result` is `{profile_path, repository_id}` on exit 0 or 1 with a parsed profile, otherwise
  `null`.

### Entry script (`Invoke-DocsCommand.ps1`)

- Parameters: `-Command <string>`, `-Json` (switch), `-Help` (switch), `-RepositoryRoot <string>`,
  and `[Parameter(ValueFromRemainingArguments = $true)] [string[]] $CommandArgument`, with
  `[CmdletBinding(PositionalBinding = $false)]`. No parameter is Mandatory, so a missing `-Command`
  exits 2 instead of prompting. Orchestrator probe: arguments after `-Command` reach the
  `ValueFromRemainingArguments` parameter identically under `&` and `pwsh -File`.
- Functions: `Get-DocsCommandTable`, `Test-DocsCommandTable` (pure), `ConvertFrom-DocsCommandArgument
  -CommandArgument <string[]> -OptionSpec <IDictionary>` (pure), `New-DocsCommandContext
  -RepositoryRoot <string>`, `Write-DocsFileText` (the only filesystem write primitive), and
  `Invoke-DocsCommandCli -Command -Json -Help -RepositoryRoot -CommandArgument [-Context]` returning
  `@{ ExitCode; Stdout; Stderr }`.
- Guard: the top-level body runs only when `$MyInvocation.InvocationName -ne '.'`, so Pester
  dot-sources the script to load its functions without running it; the body writes `Stdout` and
  `Stderr` and calls `exit $outcome.ExitCode`.
- Command context (`[pscustomobject]`, built for real only by `New-DocsCommandContext`):
  `RepositoryRoot`; `ReadText` (`param($RelativePath)`, throws an item-not-found error for an absent
  file, strips a leading BOM); `ReadBytes`; `TestFile`; `ListFile` (`param($RelativeRoot)`, sorted
  relative POSIX paths); `WriteText` (`param($RelativePath, $Text, $Mode)`, `Mode` `create` or
  `overwrite`, UTF-8 without BOM, LF); `UtcNow`. Relative paths are checked with
  `Test-DocsRelativePath` before any context call.

#### Dispatch table

`Get-DocsCommandTable` returns rows from literal source lines, one row per line, with one anchor
comment per owner:

```powershell
$script:DocsCommandRow = @(
    # --- 1020: init, validate-profile ---
    [pscustomobject]@{ Name = 'init'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsInitCommand'; Option = @{ RepositoryId = 'value'; Profile = 'value'; Write = 'switch'; Force = 'switch' } }
    [pscustomobject]@{ Name = 'validate-profile'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsValidateProfileCommand'; Option = @{ Profile = 'value' } }
    # --- 1021: check ---
    # --- 900003: inventory ---
    # --- 1023: coverage, update-ledger, validate ---
    # --- 900006: generate-reference ---
    # --- 900008: surface-delta ---
)
```

- `Option` maps a PascalCase option name to `value`, `multi` (repeatable) or `switch`. The names
  `Command`, `Json`, `Help` and `RepositoryRoot` are reserved.
- `Test-DocsCommandTable` returns findings for a duplicate `Name`, a reserved option name, an option
  kind outside `value`/`multi`/`switch`, and a `Function` outside `^Invoke-Docs[A-Za-z]+Command$`.
- Command function contract: `Invoke-Docs<Area>Command -Argument <IDictionary> -Context <object>`
  returns the object from `New-DocsCommandResult`. Usage errors are detected by
  `ConvertFrom-DocsCommandArgument` before the command function runs.

#### Exit codes and the `-Json` envelope

| Code | Meaning in every subcommand |
|---|---|
| 0 | Success or `-Help`; no `error` finding |
| 1 | Findings: at least one `error` finding, or a command-specific failure condition (for example `DOCS_PROFILE_MISSING`, `DOCS_INIT_TARGET_EXISTS`) |
| 2 | Usage or input error detected before any read: missing or unknown `-Command`, unknown option, missing value, repeated non-`multi` option, value outside the option grammar, non-relative path. `findings` holds exactly one `DOCS_CLI_ARGUMENTS`; `result` is `null` |
| 3 | Internal, environment or I/O error: PowerShell below 7.4 (`DOCS_RUNTIME_UNSUPPORTED`), a read failure other than absence, unreadable or uncomposable runtime schemas, or any unexpected exception caught at the entry boundary (`DOCS_CLI_RUNTIME`). `findings` holds exactly one finding; `result` is `null`; one fixed line is also written to stderr |

- `-Json`: stdout receives exactly one document, the canonical JSON (sorted keys, compact, trailing
  LF) of `{command, exit_code, findings, ok, result}`, where `command` is the subcommand name (for
  example `validate-profile`), `ok` is `true` exactly when `exit_code` is 0, and `findings` is in
  `Get-DocsOrderedFinding` order. Identical inputs, arguments and clock value produce identical
  bytes. The envelope has no schema file; Pester and 900007 Jest tests pin it.
- Without `-Json`: `ConvertTo-DocsReportText` output on stdout.
- `-Help`: usage text listing the table rows; reads no input; exit 0. A missing `-Command` without
  `-Help` exits 2.

### Schema identity and reference conventions

- `$schema`: `https://json-schema.org/draft/2020-12/schema` in every docs schema.
- `$id`: `urn:drm-copilot:docs:1.0.0:<name>`, where `<name>` is the file stem without
  `.schema.json`.
- Artifact header, required in each artifact schema: `$schema` (const equal to the schema `$id`),
  `schema_version` (const `"1.0.0"`), `artifact_kind` (const equal to `<name>`), `id`
  (`urn:drm-copilot:docs:1.0.0:common#/$defs/identifier`), `extensions`
  (`urn:drm-copilot:docs:1.0.0:common#/$defs/extensions`).
- Shared references use the absolute docs common URN plus a JSON pointer, for example
  `{"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/element-kind"}`; schema-local references use
  `#/$defs/<name>`. No docs schema references `schemas/discovery/v2/`, which is not pushed down.
- `$defs` names are kebab-case; property names are snake_case; no nested `$id`.
- Every object is closed (`additionalProperties: false`) and lists every property in `required`
  unless this specification marks it optional. Inapplicable companion fields are `null`, not absent.
- Formats: the orchestrator probe shows `format: date-time` is an annotation only under
  `Test-Json`. Every timestamp constraint is therefore a regex `pattern`. Docs common `timestamp`
  keeps `format: date-time` as an annotation and adds the pattern
  `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]{1,9})?Z$`. A calendar date
  uses the pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`; calendar validity is not a schema rule and is
  checked in PowerShell by the feature that consumes the field (1021 for `last_reviewed`).

### Docs `common` `$defs` (`urn:drm-copilot:docs:1.0.0:common`)

Copied from discovery v2 common (pinned by a parity test, compared as canonical JSON): `text`,
`identifier`, `identifiers`, `relative-path`, `paths`, `path-or-glob`, `exclusions`, `revision`,
`sha256`, `timestamp`, `extensions`, `validation-outcome`, and any definition those reference
transitively. `timestamp` is the only deliberate divergence (the added pattern above) and is
excluded from the parity comparison by name. In the tables below these names mean the docs common
copies.

Docs-specific definitions:

| Definition | Shape |
|---|---|
| `element-kind` | `enum: ["cli-command", "cli-option", "http-route", "config-key", "public-symbol", "architecture-component"]` |
| `element-id` | string, pattern `^(?:cli-command\|cli-option\|http-route\|config-key\|public-symbol\|architecture-component)-[0-9a-f]{64}$` (also satisfies `identifier`) |
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
| `finding` | closed object: `code` (pattern `^[A-Z][A-Z0-9_]*$`), `severity` (`enum: ["error", "warning", "info"]`), `artifact_path` (relative-path or `null`), `pointer` (RFC 6901 pointer pattern), `related_ids` (identifiers), `related_paths` (paths), `message` (text), `next_action` (text). Key set equals the output of `New-DocsFinding`. |
| `diagnostic` | closed object: `id` (identifier), `code`, `severity` (`enum: ["information", "warning", "error"]`), `path` (relative-path or `null`), `message` (text), `analyzer_id` (identifier), `blocking` (boolean), `extensions`. |

The `diataxis-mode` values are shared with 1021 (`page-metadata.schema.json`) and 900006
(`diataxis_mode: reference`).

### Artifact schema: `docs-profile`

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

Semantic checks after schema validation are listed under `Test-DocsProfileSemantic`. Consumers:
900003 reads `surface_selection` and `artifact_paths.inventory_snapshot`; 1023 reads
`completion_gates.docs_complete`, `page_owners`, `documentation_roots` and the other
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
(`disposition`), `page_bindings` (array of `page-binding`), `rationale` (text or `null`), `owner`
(identifier or `null`), `target` (text or `null`), `updated_by` (`actor`), `extensions`.

Disposition companion rules (`allOf` of `if`/`then` keyed on `disposition`, within the structural
walk subset so each violation names its field):

| Disposition | `page_bindings` | `rationale` | `owner` | `target` |
|---|---|---|---|---|
| `documented` | `minItems 1` | `null` | `null` | `null` |
| `excluded` | `maxItems 0` | text | `null` | `null` |
| `deferred` | `maxItems 0` | text or `null` | identifier | text |

Completeness (every inventoried element has an entry) is a semantic rule owned by 1023, not a
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
(relative-path), `dimensions` (closed object whose required keys are exactly `exists`, `accurate`,
`example_present`, `owner_assigned`, `diataxis_mode`, each a `#/$defs/dimension-result`),
`extensions`. `$defs/dimension-result` (closed): `state` (parity-state), `rationale` (text or
`null`), `evidence_pin_ids` (identifiers); `fail` and `not-applicable` require `rationale` text.
An unknown dimension is rejected by `additionalProperties: false`.

### Artifact schema: `docs-evidence-pin` (collection form)

One document per repository holds every pin, sorted by `pin_id`.

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `pins` | array `uniqueItems` of `#/$defs/pin` |

`$defs/pin` (closed): `pin_id` (identifier), `element_id` (element-id), `element_kind`
(element-kind), `page_path` (relative-path), `symbol` (text; the pinned declaration),
`source_path` (relative-path), `source_sha256` (sha256; 1023 compares it as an opaque value with the
current snapshot element), `revision` (revision or `null`), `claim` (text or `null`), `pinned_at`
(timestamp), `pinned_by` (`actor`).

### Artifact schema: `docs-validation-receipt`

| Field | Shape |
|---|---|
| header | as above |
| `mode` | `enum: ["profile", "ledger", "matrix", "docs-complete"]` |
| `repository` | identifier |
| `revision` | revision (non-null; 900008 matches it against the head revision) |
| `inputs` | array `uniqueItems` of `artifact-pin` |
| `counts` | closed object: `elements_total`, `undocumented`, `stale_pages` (integers minimum 0), `by_disposition` (closed object whose required keys are exactly the dispositions, integer values minimum 0), `by_kind` (closed object whose required keys are exactly the element kinds, integer values minimum 0) |
| `validation_result` | validation-outcome |
| `findings` | array `uniqueItems` of docs `finding` |
| `issued_at` | timestamp |
| `writer` | closed `{tool: const "drm-copilot-docs", version: text}` |

Result binding copied from discovery `validation-receipt`: `pass` forbids any finding with
severity `error`; `fail` requires at least one. An unknown disposition or kind is rejected through
the closed `by_disposition` and `by_kind` objects.

Rejection coverage: each artifact schema carries an element-kind or disposition field (profile
`surface_selection.element_kinds`, snapshot `elements[].kind`, ledger `entries[].kind` and
`entries[].disposition`, matrix `rows[].kind`, pin `pins[].element_kind`, receipt
`counts.by_kind` and `counts.by_disposition`). In the acceptance criteria, "each artifact schema"
means the artifact schemas `docs-profile`, `surface-inventory-snapshot`, `docs-coverage-ledger`,
`docs-parity-matrix`, `docs-evidence-pin` and `docs-validation-receipt`; the definitions-only
`common` schema has no root object and no example and is verified through the artifact schemas
that reference it.

## Data & State

- Element identity is a pure function of kind, path and declaration.
- All ordering is deterministic: findings by `Get-DocsOrderedFinding`, elements by `element_id`,
  pins by `pin_id`, analyzer rows by `Id`, schema names in fixed order.
- Framework code, schemas and examples contain no consumer-specific names; all repository
  specificity is profile data.
- No module-scope cache: schemas are read and composed once per command invocation.
- Persistence: `init -Write` writes the profile (and, after 1021 and 900008, their template rows)
  through `Write-DocsFileText`, the only filesystem write in 1020. Ledger, matrix, pin and receipt
  writes belong to 1023.
- Runtime schema copy: `.claude/lib/docs/schemas/v1/` holds byte-identical copies of every file in
  `schemas/docs/v1/` (canonical location, naming contract). The bundle copy holds byte-identical
  copies of every file under `.claude/lib/docs/`.
- Migration or backfill: none.

## Constraints & Risks

- The epic naming contract is fixed; this feature may not change it. The runtime schema copy is an
  addition, not a relocation (OQ-1).
- Language rule (epic `## Owner Directive: Implementation Language (2026-10-30, refined)`): every
  artifact is PowerShell, JSON, YAML or Markdown; no Python or TypeScript is created or edited. Any
  artifact that cannot follow the rule is an owner question, not a decision. No such artifact was
  found (see `## Artifact Classification`).
- PowerShell 7 built-ins only (epic A8): `Test-Json` and `System.Text.Json`; `ConvertFrom-Json` and
  `ConvertTo-Json` are not used for artifacts; no new module dependency.
- CI-only behavior: the `windows-latest` runner's PowerShell version and bundled JsonSchema.Net
  determine `Test-Json` behavior; a local 7.6.9 run does not prove it. Tests assert codes, pointers
  and field-name containment only, and the runtime fails closed below 7.4.
- Batch budget: sixteen production PowerShell files (eight plus eight bundle copies) exceed the
  direct-mode cap, so execution runs on the large route in the item worktree that holds the
  orchestration checkpoint, never in an isolated executor worktree.
- File size: `Invoke-DocsCommand.ps1`, `DocsSchema.psm1` and `DocsProfile.psm1` are the largest
  candidates; a file reaching the 500-line guidance is split into a new `Docs<Area>.psm1` with its
  own Pester suite, push-down copy and core entry.
- Test isolation: dot-sourcing the entry script imports `Docs*` and `DiscoveryEncoding` modules into
  the session; every suite removes them in `AfterAll`.
- Shared append-only edit points: `Invoke-DocsCommand.ps1` dispatch table, `DocsAnalyzerRegistry.psm1`,
  `DocsSchema.psm1` schema table, `DocsProfileCommands.psm1` template table, Claude `core.json`, and
  `quality-tiers.yml`. Owner anchors keep insertion points apart; remaining conflicts are resolved
  in the later child's remediation loop.
- Neutrality: consumer identifiers are configured only as lowercase hex SHA-256 digests, never as
  text.

## Implementation Strategy

- Create the eight production files under `.claude/lib/docs/` listed in `### Module conventions`.
- Create `schemas/docs/v1/common.schema.json` and the six artifact schemas, and
  `examples/docs/v1/<name>.example.json` for each artifact schema.
- Create the runtime copies `.claude/lib/docs/schemas/v1/*.schema.json`.
- Create byte-identical bundle copies of every file under `.claude/lib/docs/` at
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`paths`):
  append every file under `.claude/lib/docs/`, PowerShell and data.
- Edit `quality-tiers.yml`: add `path: ".claude/lib/docs"`, `tier: T3` (OQ-4), with a rationale
  stating that it is a runtime library shipped in the `.claude` bundle. No change to
  `config/poshqc-coverage.json` (already lists `.claude/lib`) or `config/poshqc-scan.json`.
- Tests (Pester, `tests/scripts/claude-lib/docs/`): `DocsJson.Tests.ps1`, `DocsFinding.Tests.ps1`,
  `DocsSchema.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `DocsSurface.Tests.ps1`,
  `DocsAnalyzerRegistry.Tests.ps1`, `DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1`,
  `Invoke-DocsCommand.Tests.ps1`, `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`, one
  `Docs.TestSupport.psm1` (in-memory command context and schema-set builders), and a committed
  fixture analyzer module under `tests/scripts/claude-lib/docs/fixtures/` loaded through the
  `-ImportModule` seam.
- Neutrality test: `$script:ConsumerIdentifierSha256` holds lowercase hex SHA-256 digests of the
  lowercase identifier forms to ban, supplied by the orchestrator or owner. The first preparation
  recorded `bbddb9f7a8340215503f6089cb5364689432a9cfb261cd7683c4fe2f20760f6b` and
  `59f0db478528b4c446cfaf3d5b8a358dc500a6d97b29a215ee8c216a2f7174e2`; the executor confirms each
  value by an independent route before use. The pure helper `Find-DocsIdentifierDigest -FileText
  <IDictionary> -Digest <string[]>` lowercases text, enumerates maximal `[a-z0-9]+` runs and maximal
  `[a-z0-9]+(?:[-_.][a-z0-9]+)+` compounds, hashes each candidate with `Get-DocsSha256Hex`, and
  returns `(path, digest)` pairs. Scan scope: every file under `.claude/lib/docs/`, `schemas/docs/`
  and `examples/docs/`, read once into memory.
- Golden identity vectors: for each chosen `(kind, path, declaration)` the test asserts the exact
  canonical string and the hex digest recorded once from an independent hash of that string
  (evidence under `<FEATURE>/evidence/`).
- Dependency changes: none.
- Logging: none added; exit-3 diagnostics go to stderr.
- Rollout: additive; destination repositories receive the lib through the existing Claude
  push-down and opt in by running `init`.

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and extension commands; none here);
D = epic `### Artifact classes for this epic` (schema, configuration, data and test rows). "Avoid new
Python" applies to every row.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsJson.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsFinding.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsSchema.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsSurface.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfile.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | pushed-down helper/lib (entry) | PowerShell | R1 |
| `.claude/lib/docs/schemas/v1/*.schema.json` (runtime copies of `schemas/docs/v1/`) | schema/config/data (pushed down) | JSON | D; location is OQ-1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` (bundle copies of every file above) | pushed-down helper/lib and data (mirror) | PowerShell, JSON | R1, D |
| `schemas/docs/v1/common.schema.json` and the artifact schemas | schema/config/data | JSON | D |
| `examples/docs/v1/<name>.example.json` (one per artifact schema) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `quality-tiers.yml` (edit) | schema/config/data | YAML | D |
| `tests/scripts/claude-lib/docs/*.Tests.ps1`, `Docs.TestSupport.psm1`, `fixtures/*.psm1` | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/**` (spec, user story, plan, evidence) | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, Python file or TypeScript file is created or
edited. Every artifact follows the language rule; OQ-1 and OQ-2 concern location and reachability,
not language.

## Decisions Later Children Must Honor

- Register a subcommand by inserting rows directly under the child's own anchor in
  `Invoke-DocsCommand.ps1` (1021, 900003, 1023, 900006, 900008); never edit another anchor or row.
  Command modules are `Docs<Area>Commands.psm1` or the epic-named module and follow the command
  function contract.
- Analyzer rows go under the child's anchor in `DocsAnalyzerRegistry.psm1` (900003, 900004);
  analyzers follow the `Invoke-DocsAnalyzer<Name> -CapturedInput -Selection` contract and are pure.
- Use only literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` for sibling modules and
  data; list every new `.claude/lib/docs/` file (PowerShell and data) in Claude `core.json`, mirror
  it byte-identically, and keep `Docs.Manifest.Tests.ps1` green.
- New schemas (1021 `page-metadata.schema.json`) go to `schemas/docs/v1/` and the runtime copy under
  `.claude/lib/docs/schemas/v1/`, with a `Get-DocsSchemaPath` row and a `Get-DocsSchemaName` entry
  under the 1021 anchor; shared definitions are referenced through
  `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>`; no ref to discovery schemas; timestamps use a
  `pattern`, never `format` alone.
- Validate artifacts with `Test-DocsArtifactText`; never rely on `Test-Json` message text to name a
  field. Constraints whose failures must name a field stay within the structural walk subset.
- Parse JSON with `ConvertFrom-DocsJsonText`; never `ConvertFrom-Json` for artifacts.
- Build findings with `New-DocsFinding` and results with `New-DocsCommandResult`; exit codes 0/1/2/3
  and the `-Json` envelope apply to every subcommand; never print output or call `exit` inside a
  command module.
- No filesystem, clock or process access outside the command context; tests use in-memory contexts
  and create no temporary files.
- Consumer configuration and workflow templates ship as data under `.claude/lib/docs/templates/` and
  are delivered by `init` through one `Get-DocsInitTemplate` row under the child's anchor (1021,
  900008); no push-down root is added and no file goes under
  `extensions/drm-copilot/resources/templates/`.
- Element identifiers come from `Get-DocsElementId`; records are rebuilt with
  `ConvertFrom-DocsSurfaceElement`; pin and receipt identifiers use `Get-DocsStableId`; digests use
  `Get-DocsBytesSha256Hex` and are compared as opaque values (1023).
- Profile access goes through `ConvertFrom-DocsProfileText`; the keys 1023 relies on are
  `artifact_paths.{inventory_snapshot, coverage_ledger, parity_matrix, evidence_pins,
  validation_receipt}`, `completion_gates.docs_complete.{allow_deferred, max_stale_pages,
  required_parity_dimensions}`, `page_owners[{path_or_glob, owner}]` and `documentation_roots`.
- 1023's single-write-boundary test allowlists `Write-DocsFileText` in `Invoke-DocsCommand.ps1` with
  the reason "init create-only and explicit overwrite"; 1023 adds its own boundary module.
- 900007 invokes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name>
  -Json ...` with the workspace root as working directory and parses the envelope; it adds no logic.
- 900009 skills call `Invoke-DocsCommand.ps1` or the MCP tools; Codex reachability follows OQ-2.
- 900010 states PowerShell 7.4 as the destination prerequisite (OQ-3).

## Owner Questions

None of these is decided beyond its provisional default. Owner answers may change the affected
criteria through a specification revision.

1. **OQ-1 - Runtime schema location.** The naming contract fixes `schemas/docs/v1/`, which no
   push-down root publishes. Options: (a) keep canonical `schemas/docs/v1/` and ship a
   byte-identical runtime copy under `.claude/lib/docs/schemas/v1/` pinned by a Pester test;
   (b) make `.claude/lib/docs/schemas/v1/` the only canonical location (naming-contract change);
   (c) add `schemas` as a push-down root (TypeScript plus in-place edits of existing Python twins).
   Provisional default: (a).
2. **OQ-2 - Codex and `.agents` reachability.** The docs lib is published only in the Claude bundle.
   Codex skills mirrored by 900009 would need either the Claude push-down in the destination or a
   `.codex/lib/docs/` virtual directory (new `VIRTUAL_RESOURCE_DIRECTORIES` entry in TypeScript, the
   in-place edit of the existing Python twin, and Codex skill text naming `.codex/lib/docs/`).
   Provisional default: Claude bundle only in 1020; 900009 decides after the owner answers.
3. **OQ-3 - Destination PowerShell floor.** The epic states "PowerShell 7 only"; `Test-Json` Draft
   2020-12 support needs 7.4. Provisional default: require 7.4 and fail closed with
   `DOCS_RUNTIME_UNSUPPORTED` (exit 3) below it.
4. **OQ-4 - Tier of `.claude/lib/docs`.** T3 matches every existing `.claude/lib/*` entry; T2 would
   reflect the contract role but adds property-test density and mutation-trend obligations and
   requires changing `test_committed_quality_tiers_yml_assigns_spec_tiers`. Provisional default: T3.
5. **OQ-5 - `init -Write` scope.** Delivering the 900008 workflow and 1021 linter configuration
   through `init` means a pushed-down helper writes into a destination's `.github/workflows/` and
   repository-root dotfiles. Provisional default: allowed only with `-Write`, create-only unless
   `-Force`, dry run by default, every planned path listed before any write.

No owner question was added beyond OQ-1 to OQ-5.

## Numeric Derivation Reference

The acceptance criteria name the artifact schemas by name and assert no count. Counts used in the
narrative are supported by complete `## Numeric Derivation Evidence` records: the artifact schema
family in the earlier research and the production PowerShell file family (eight files) in the
addendum research.

## Acceptance Criteria

- [ ] Every example under `examples/docs/v1/` validates against its artifact schema: `Test-Json` returns `True` and `Test-DocsArtifactText` returns no finding for each example (`tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1`).
- [ ] For each artifact schema (`docs-profile`, `surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`, `docs-validation-receipt`), an in-memory copy of its example with one required field deleted, and a copy with an unknown element kind or disposition, each make `Test-Json` return `False` and make `Test-DocsArtifactText` return an `error` finding (`DOCS_SCHEMA_REQUIRED_MISSING`, `DOCS_SCHEMA_VALUE_NOT_ALLOWED` or `DOCS_SCHEMA_PROPERTY_UNKNOWN`) whose pointer locates the mutated field (`DocsSchemaContract.Tests.ps1`).
- [ ] `Invoke-DocsCommand.ps1 -Command validate-profile -Profile examples/docs/v1/docs-profile.example.json` exits 0 with no `error` finding (`tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` and `DocsProfileCommands.Tests.ps1`).
- [ ] `-Command validate-profile` exits 1 for an invalid profile, and the finding names the failing field: a profile without `audiences` yields `DOCS_SCHEMA_REQUIRED_MISSING` at `/audiences` with a message containing `audiences`; a missing required field inside a nested `$ref` target yields a finding whose pointer and message name that field; an unknown element kind yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/surface_selection/element_kinds/<n>`; the field naming comes from `Get-DocsSchemaStructuralFinding`, not from `Test-Json` message text (`DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1`).
- [ ] `-Command validate-profile` exits 1 with `DOCS_JSON_DUPLICATE_KEY` for a profile containing a repeated member, with `DOCS_PROFILE_AUDIENCE_UNKNOWN` for an undeclared audience reference, and with `DOCS_PROFILE_MISSING` for an absent profile (`DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1`).
- [ ] `-Command init` without `-Write` exits 0, writes nothing, and returns a starter profile that `ConvertFrom-DocsProfileText` accepts with no finding for several repository identifiers; with `-Write` it creates the profile; with `-Write` and an existing target it exits 1 with `DOCS_INIT_TARGET_EXISTS` and writes nothing; with `-Write -Force` it overwrites (`DocsProfileCommands.Tests.ps1`, using an in-memory context).
- [ ] Element identifiers are deterministic over a seeded set of inputs: for a seeded `[System.Random]` input set (seed printed on failure) the same kind, path and declaration yield the same identifier, enumerated boundary cases yield distinct identifiers, each golden vector matches its recorded canonical string and hex digest, and an unpaired surrogate or a non-relative path is rejected with `DOCS_IDENTITY_INPUT_INVALID` (`tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1`).
- [ ] `ConvertFrom-DocsSurfaceElement` throws `DOCS_ELEMENT_ID_MISMATCH` for a record whose `element_id` was altered, and `New-DocsSurfaceElement` rejects a `cli-option` without a `cli-command-` parent (`DocsSurface.Tests.ps1`).
- [ ] `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` holds consumer identifiers only as lowercase hex SHA-256 digests (no identifier text), finds no configured digest in any file under `.claude/lib/docs/`, `schemas/docs/` or `examples/docs/`, detects a synthetic identifier injected into an in-memory file map (positive control), and asserts the digest list is non-empty with every entry matching `^[0-9a-f]{64}$`.
- [ ] `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` passes: every file under `.claude/lib/docs/` (PowerShell and data, recursively) is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and is SHA-256 identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- [ ] The existing push-down contract tests `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (including `test_every_psscriptroot_occurrence_is_recognized`) pass on the feature branch without modification.
- [ ] The file set under `.claude/lib/docs/schemas/v1/` equals the file set under `schemas/docs/v1/` and each runtime copy is byte-identical to its canonical file (`DocsSchemaContract.Tests.ps1`).
- [ ] Each docs common definition copied from discovery v2 common equals the discovery definition as canonical JSON, except `timestamp`, which carries the timestamp `pattern`; no docs schema contains a `$ref` to a discovery URN or to a file (`DocsSchemaContract.Tests.ps1`).
- [ ] `Join-DocsSchemaText` rewrites docs common URN refs and refs inside copied definitions to `#/$defs/common.<name>`, leaves local refs unchanged, removes the root `$id`, returns `DOCS_SCHEMA_COMPOSITION_CONFLICT` for a target `$defs` key beginning `common.`, and returns `DOCS_SCHEMA_REF_UNRESOLVED` for an unknown common name and for a foreign URN, file or URI ref without retrieving it (`tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1`).
- [ ] `Test-DocsArtifactText` returns exactly one `DOCS_SCHEMA_INVALID` finding with pointer `''` when `Test-Json` returns `False` with no ErrorRecord and the structural walk finds nothing, and returns the walk findings when the walk reports an error (`DocsSchema.Tests.ps1`, using a schema constraint outside the walk subset and a stubbed `Test-Json` result where needed).
- [ ] Exit codes follow 0/1/2/3 for every 1020 subcommand: 0 for success and `-Help`; 1 for `error` findings; 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `null` for a missing `-Command`, an unknown command, an unknown option, a missing value, a repeated non-`multi` option and a non-relative path; 3 with exactly one finding (`DOCS_RUNTIME_UNSUPPORTED` through the `-PowerShellVersion` seam set below 7.4, or `DOCS_CLI_RUNTIME` for an injected exception) and one stderr line (`Invoke-DocsCommand.Tests.ps1`).
- [ ] With `-Json`, stdout is exactly one canonical JSON document whose keys are `command`, `exit_code`, `findings`, `ok` and `result`, `command` is the subcommand name, `ok` is `true` exactly when `exit_code` is 0, and two runs with identical inputs, arguments and clock produce identical bytes; without `-Json`, the last line is `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>` (`Invoke-DocsCommand.Tests.ps1`, `DocsFinding.Tests.ps1`).
- [ ] `Test-DocsCommandTable` returns no finding for the committed dispatch table; the table contains the `init` and `validate-profile` rows under the `# --- 1020: init, validate-profile ---` anchor followed by the anchors for 1021, 900003, 1023, 900006 and 900008 in that order; and `Test-DocsCommandTable` rejects a duplicate name, a reserved option name and a function outside `^Invoke-Docs[A-Za-z]+Command$` (`Invoke-DocsCommand.Tests.ps1`).
- [ ] The committed analyzer registry has no rows and carries the 900003 and 900004 anchors; `Test-DocsAnalyzerRegistration` returns no finding for it and returns `DOCS_ANALYZER_REGISTRATION_INVALID` for a duplicate `Id` and for a `Module` outside `.claude/lib/docs/`; `Select-DocsAnalyzerRegistration` reports `DOCS_ANALYZER_UNKNOWN` without invoking the `-ImportModule` seam; `Invoke-DocsAnalyzer` rejects fixture output whose kind is outside the registration (`tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1`).
- [ ] Every new file under `.claude/lib/docs/` passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, and no production file under `.claude/lib/docs/` exceeds 500 logical lines.
- [ ] `quality-tiers.yml` contains an entry with `path: ".claude/lib/docs"` and `tier: T3`; `python -m scripts.dev_tools.check_quality_tiers` exits 0 and `test_committed_quality_tiers_yml_matches_live_tree` and `test_committed_quality_tiers_yml_assigns_spec_tiers` pass unmodified.
- [ ] No Python or TypeScript file is added or modified: `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule.
- [ ] No discovery file changes: `git diff --name-only <merge-base>..HEAD` lists no path under `packages/discovery-runtime/`, `schemas/discovery/` or `.claude/lib/discovery-validation/`.
- [ ] No test creates a temporary file: no file under `tests/scripts/claude-lib/docs/` contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`, and every command test uses an in-memory command context.
- [ ] Pester line coverage is at least 85% for each production file under `.claude/lib/docs/`, read from the PoshQC coverage report produced by `Invoke-PoshQCTest`, with no production file excluded from measurement (no branch-coverage gate applies to Pester); the figures are recorded under `<FEATURE>/evidence/coverage/`.
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` on `windows-latest` and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to Pester suites or commands
- [ ] Behavior matches acceptance criteria on PowerShell 7.4 or later and on the CI `windows-latest` runner
- [ ] Edge cases covered by tests: empty file, invalid JSON, duplicate keys, excess depth, unknown analyzer identifier, duplicate audience identifiers, unknown audience reference, directory mode outside the policy, existing init target
- [ ] Docs suites pass in three seeded shuffled file-order runs in one process (each seed and order recorded) and in a fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Toolchain pass completed (format, lint with PSScriptAnalyzer, architecture and contract tests, Pester) in a single clean pass
- [ ] Forbidden-token scan with bracket-class patterns over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: JSON parsing, findings and envelope, schema composition and structural walk, profile loading and validation, surface identities, analyzer registry, entry script.
- [ ] Integration scenarios: every example validates against its composed schema; runtime schema copies and bundle copies match their sources.
- [ ] CLI examples: `Invoke-DocsCommand.ps1 -Command init`, `Invoke-DocsCommand.ps1 -Command validate-profile`.
