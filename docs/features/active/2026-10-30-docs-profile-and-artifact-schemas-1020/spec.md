# docs-profile-and-artifact-schemas — Spec

- **Issue:** #1020
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 1020, wave 0, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft
- **Version:** 0.5 (preflight revision of the D3 and D5 amendment: binding 1031 preconditions and real issue numbers)
- **Requirements source:** `docs/features/epics/documentation-estate-tooling/epic.md` on branch `origin/epic/documentation-estate-tooling-integration`
- **Research (amendment design source):** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T22-35-docs-profile-amendment-d3-d5-addendum-research.md`
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

Version 0.4 amends version 0.3 for the owner decisions of 2026-10-30 recorded in the epic
`## Owner Decisions (2026-10-30, received through the coordinator)` and `### Amendment of 1020
required by D3 and D5`. Under D1 this amendment is a new planning cycle for 1020. The amendment
design source is the 2026-10-30T22-35 addendum research. Changes:

- D3: an `analysis_method` field (`native` or `scanner`) on snapshot elements, snapshot
  `analyzers[]` items and coverage-ledger entries, carried by `DocsSurface.psm1` and by registry
  rows keyed on (`Id`, `AnalysisMethod`). It is not part of the element identifier.
- D5: `source_sha256` is the declaration-lines digest (`#### Declaration-lines digest`), not a
  whole-file digest; `line_range` is required for every kind except `architecture-component`.
- D5: the `-Json` envelope gets its own schema, `schemas/docs/v1/docs-command-envelope.schema.json`,
  with a runtime copy, a bundle copy, a `core.json` line and an example. The earlier statement that
  the envelope has no schema file is withdrawn.
- D3: the analyzer registry carries a 1031 anchor. Stale placeholder numbers are corrected from
  git history as confirmed by the orchestrator: 900002 is 1021, 900003 is 1022, 900005 is 1023 and
  900006 is 1024.
- Epic 1024 generator decision: audience identifiers use one shared docs common pattern
  (`audience-id`), referenced by the profile schema and by the 1021 page-metadata schema.

Everything not named above is unchanged from version 0.3. Open points from the addendum are OQ-6
to OQ-9 under `## Owner Questions`.

Version 0.5 is the single preflight revision of this planning cycle. The requirements source is the
epic on the integration branch (`docs/features/epics/documentation-estate-tooling/epic.md` on
`origin/epic/documentation-estate-tooling-integration`), whose `### Native-analyzer contracts from
the preparation of 1031 (binding)` adds preconditions for 1031. Changes:

- Every remaining placeholder carries its real issue number from the epic manifest: 900004 is 1033,
  900007 is 1036, 900008 is 1034, 900009 is 1037, 900010 is 1038 and 900011 is 1031. No
  placeholder number remains in this file outside the two revision notes; the anchor guards reject
  any anchor line numbered in the `900000` range.
- The 1031 analyzer anchor heads its own provider table, `$script:DocsAnalyzerNativeRow`, because
  the registry rejects duplicate (`Id`, `AnalysisMethod`) pairs and 1031 must not edit the scanner
  table; `Get-DocsAnalyzerRegistration` concatenates the scanner table and the native table in that
  order.
- The command context gains the process member `InvokeProcess`.
- `New-DocsDiagnostic` gains `-Severity` (`error`, `warning` or `information`).
- The core pack manifest, its bundle mirror and `Docs.Manifest.Tests.ps1` cover every file under
  `.claude/lib/docs/` except the `.claude/lib/docs/python/` subtree, which only the python pack
  manifest lists (1031). 1020 creates no file under that subtree.

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
examples. Features 1021, 1022, 1033, 1031, 1023, 1024 and 1034 consume the modules
directly; 1036 consumes them through `Invoke-DocsCommand.ps1`. The contracts below are normative: a
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
  path and declaration; the analysis methods `native` and `scanner`; and the declaration-lines
  digest that each element records as `source_sha256`.
- The analyzer contract and an owner-anchored analyzer registry, empty in this feature, keyed on
  (`Id`, `AnalysisMethod`), with a scanner provider table that 1022 and 1033 extend and a separate
  native provider table that 1031 extends.
- Profile parsing, schema and semantic validation, and a starter profile.
- The entry script `Invoke-DocsCommand.ps1 -Command <subcommand> [arguments]` with an
  owner-anchored dispatch table and the subcommands `init` and `validate-profile`.
- Six artifact schemas, one definitions-only `common.schema.json` and one non-artifact
  `docs-command-envelope.schema.json` (the `-Json` envelope, D5) under `schemas/docs/v1/`; one
  example per artifact schema and one envelope example under `examples/docs/v1/`; and a
  byte-identical runtime copy of every schema under `.claude/lib/docs/schemas/v1/` (owner question
  OQ-1).
- Push-down registration: every file under `.claude/lib/docs/` except the
  `.claude/lib/docs/python/` subtree listed in the Claude core pack manifest and mirrored
  byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
  The `.claude/lib/docs/python/` subtree is reserved for the 1031 Python-native helper, which only
  the python pack manifest lists; 1020 creates no file there.
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
  `docs-validation-receipt`, `docs-command-envelope`, followed by the anchor comment
  `# --- 1021: page-metadata ---`.
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
  `### Artifact validation`. The parameter name stays `ArtifactKind`; it also accepts the one
  non-artifact kind `docs-command-envelope`, which validates a `-Json` envelope.
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

Owner decision D5 asks for `Test-Json` cross-file `$ref` to be tested first, with self-contained
schemas as the fallback. The probe above is that test; cross-file refs fail by default, so the
fallback applies. The fallback is the in-memory composed schema: each schema file keeps its docs
common URN refs, and `Join-DocsSchemaText` produces a self-contained schema in memory before
`Test-Json` runs. No schema file carries a physically inlined copy of a docs common definition.
Owner acceptance of this form is OQ-6.

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
- `Get-DocsAnalysisMethod` returns the analysis methods in contract order: `native`, `scanner`.
- `ConvertTo-DocsDeclarationText -Text <string> [-LineRange <int[]>]` and
  `Get-DocsDeclarationSha256 -Text <string> [-LineRange <int[]>]` per
  `#### Declaration-lines digest`.
- `Test-DocsRelativePath -Path` (POSIX relative path grammar, equal to docs common
  `relative-path`); `Test-DocsFullRevision -Revision` (40 or 64 lowercase hex).
- `Get-DocsStableId -Prefix <string> -Value <object>` returns `<prefix>-` plus the lowercase hex
  SHA-256 of `ConvertTo-DocsCanonicalJson -Value`. An `AUTHORIZATION_INPUT_INVALID: ...` error from
  `DiscoveryEncoding.psm1` is rethrown as `DOCS_IDENTITY_INPUT_INVALID: ...`.
- `Get-DocsElementId -Kind <string> -Path <string> -Declaration <string>` per
  `### Element identifiers`.
- `Test-DocsElementId -ElementId <string>` (docs common `element-id` pattern).
- `New-DocsSurfaceElement -Kind -Path -Declaration -Name -AnalyzerId -AnalysisMethod -SourceText
  [-ParentId] [-LineRange <int[]>] [-Property <IDictionary>] [-Extension <IDictionary>]` returns an
  ordered hashtable in the snapshot `element` shape with a computed `element_id` and a computed
  `source_sha256` (`Get-DocsDeclarationSha256 -Text $SourceText -LineRange $LineRange`).
  `-AnalysisMethod` is mandatory and must be a value of `Get-DocsAnalysisMethod`; `-SourceText` is
  the strict-UTF-8 text of the captured input for `Path`. `-LineRange` is mandatory for every kind
  except `architecture-component`, and requires `1 <= start <= end <= <line count>`. A caller
  cannot supply a digest. `cli-option` requires a parent identifier beginning `cli-command-`.
  An invalid argument throws `DOCS_IDENTITY_INPUT_INVALID` naming the argument, or
  `DOCS_DIGEST_RANGE_INVALID` for a range outside the text.
- `ConvertFrom-DocsSurfaceElement -Record <IDictionary>` requires `analysis_method` in the record,
  re-verifies `element_id` and throws `DOCS_ELEMENT_ID_MISMATCH` for a record whose identifier
  differs from the recomputed one.
- `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Severity <error|warning|information>]
  [-Blocking <bool>]` returns the docs `diagnostic` shape with `id` equal to `Get-DocsStableId
  -Prefix 'diagnostic' -Value @{ analyzer; code; path }`. Severity and blocking are coupled:
  `blocking` is `true` exactly when `severity` is `error`. With `-Severity`, `blocking` follows the
  severity (`information` and `warning` force `blocking` `false`), and an explicit `-Blocking` that
  disagrees with the severity throws `DOCS_IDENTITY_INPUT_INVALID` naming `Blocking`. Without
  `-Severity`, `-Blocking` (default `$true`) selects `error` when true and `warning` when false.
  A `-Severity` value outside `error`, `warning` and `information` throws
  `DOCS_IDENTITY_INPUT_INVALID` naming `Severity`. The values match the docs common `diagnostic`
  `severity` enum; `information` is the severity 1022 and 1031 use for non-blocking notices (1031
  precondition).

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
- `analysis_method`, `source_sha256`, `line_range`, `name` and `properties` do not participate in
  the identifier. A native and a scanner analysis of the same declaration therefore produce the
  same `element_id`, and ledger entries and evidence pins stay valid when the method changes.
- Declaration conventions per kind (binding on 1022, 1033 and 1031):

| Kind | Declaration | Example |
|---|---|---|
| `cli-command` | full command path | `tool docs inventory` |
| `cli-option` | command path, one space, long option | `tool docs inventory --analyzer` |
| `http-route` | upper-case method, one space, route template | `GET /items/{id}` |
| `config-key` | dotted key path | `tool.settings.timeout` |
| `public-symbol` | qualified name | `example_pkg.module.function` |
| `architecture-component` | package or module path | `example_pkg.analyzers` |

#### Declaration-lines digest (D5)

An element digest covers the declaration's source lines, not the whole file. The field names stay
`source_sha256` and `line_range` (`{start, end}`).

`ConvertTo-DocsDeclarationText -Text <string> [-LineRange <int[]>]` (pure) returns the canonical
declaration text:

1. Remove one leading U+FEFF if present.
2. Replace every CRLF with LF, then every remaining CR with LF.
3. If the text ends with LF, remove exactly one trailing LF. Split on LF into lines numbered from 1.
   The empty text has zero lines.
4. With `-LineRange @(start, end)`: require `1 <= start <= end <= <line count>`, otherwise throw
   `DOCS_DIGEST_RANGE_INVALID` naming the range. Select lines `start` through `end` inclusive.
   Without `-LineRange` (permitted only for `architecture-component`): select every line.
5. Return the selected lines, each followed by exactly one LF. No trimming, no tab or whitespace
   change and no Unicode normalization is applied. Zero selected lines give the empty string.

`Get-DocsDeclarationSha256 -Text <string> [-LineRange <int[]>]` (pure) returns
`Get-DocsSha256Hex -Text (ConvertTo-DocsDeclarationText -Text $Text -LineRange $LineRange)`: the
lowercase hex SHA-256 of the UTF-8 bytes, without BOM, of the canonical declaration text. The input
is the strict-UTF-8 `text` of `New-DocsCapturedInput`, so no unpaired surrogate reaches the
encoder.

Properties:

- Line numbers and the range are not hashed. Inserting or deleting lines above a declaration shifts
  its `line_range` and leaves `source_sha256` unchanged.
- CRLF and LF forms of the same file, a file with and without a final newline, and a file with and
  without a BOM produce the same digest.
- An edit to any line outside the range leaves the digest unchanged; an edit to any line inside the
  range changes it.
- Architecture-component exception: an `architecture-component` element (a package or module path)
  may have `line_range` `null`; its digest then covers every line of the normalized file, because
  the module is its own declaration. This is the only case in which the digest equals a whole-file
  digest. Owner acceptance is OQ-7.
- A native analyzer (1031) reproduces the digest from its own line numbers with the same five
  steps; `Invoke-DocsAnalyzer` recomputes it, so byte agreement between the scanner and a native
  analyzer is a checked property.
- Golden vector D1: source text `a = 1<CR><LF>def handler():<CR><LF>    return 1<CR><LF>b = 2` (no
  final newline), range `@(2, 3)`, canonical text `def handler():<LF>    return 1<LF>`; the hex
  digest is recorded once from an independent hash of the canonical text, with evidence under
  `<FEATURE>/evidence/other/`.

### `DocsAnalyzerRegistry.psm1`

- `Get-DocsAnalyzerRegistration [-ScannerRow <object[]>] [-NativeRow <object[]>]` (pure) returns
  the scanner provider rows followed by the native provider rows, in that fixed order. The two
  parameters default to the committed tables `$script:DocsAnalyzerRow` and
  `$script:DocsAnalyzerNativeRow`; tests pass in-memory rows to prove the order without mutating
  module state.
- `Test-DocsAnalyzerRegistration -Registration <object[]>` (pure) returns findings
  (`DOCS_ANALYZER_REGISTRATION_INVALID` with the pointer `/<row index>/<field>`, where the row index
  is the row's position in the given registration, which for the committed registry is the
  concatenation of the scanner table and the native table): duplicate
  (`Id`, `AnalysisMethod`) pair, `Id` outside the identifier grammar, `AnalysisMethod` outside
  `Get-DocsAnalysisMethod`, a `native` row whose `Id` has no `scanner` row (the scanner baseline is
  always available, D3), empty `ElementKinds` or a kind outside `Get-DocsElementKind`, `Module` not
  resolving inside `.claude/lib/docs/` or without a `DocsAnalyzer*.psm1` leaf, `Function` not
  matching `^Invoke-DocsAnalyzer[A-Za-z]+$`, blank `Version`. Uniqueness is on (`Id`,
  `AnalysisMethod`), not on `Id` alone, so a native analyzer registers under the same identifier as
  its scanner.
- `Select-DocsAnalyzerRegistration -Registration <object[]> -ElementKind <string[]> [-AnalyzerId
  <string[]>] [-NativeAvailable <string[]>]` (pure) validates the whole request before any import,
  reports each unknown identifier as `DOCS_ANALYZER_UNKNOWN`, and returns one row per selected `Id`,
  sorted by `Id` (invariant under input order): the `native` row when the `Id` is in
  `-NativeAvailable` and a `native` row exists, otherwise the `scanner` row. Detection of a language
  pack and interpreter is not part of this function; it belongs to the native analyzer's adapter
  (1031). This selection rule is provisional (OQ-9).
- `New-DocsCapturedInput -Path <string> -Bytes <byte[]> [-MaxBytes <int>]` (pure) returns
  `@{ path; sha256; size; text; diagnostic }`; strict UTF-8 decoding; an oversize or undecodable
  input carries a diagnostic and `text` `$null`.
- `Invoke-DocsAnalyzer -Registration <object> -CapturedInput <object[]> -Selection <object>
  [-ImportModule <scriptblock>]` imports the module through the seam (default `Import-Module -Name
  <path> -Force -ErrorAction Stop`), calls the analyzer function, validates the output (kinds within
  the registration, `analyzer_id` equal to `Id`, `analysis_method` equal to the row's
  `AnalysisMethod`, recomputed element identifiers, and `source_sha256` equal to
  `Get-DocsDeclarationSha256` over the captured input text of the element's `path` and its
  `line_range`) and returns `@{ Elements; Diagnostics }` sorted by identifier. Output that fails
  any check is rejected with a finding.
- Analyzer function contract (1022, 1033, 1031): `Invoke-DocsAnalyzer<Name> -CapturedInput
  <object[]> -Selection <object>` returns `@{ Elements = @(...); Diagnostics = @(...) }`; pure,
  deterministic, no I/O, inputs not mutated; an unclassifiable or oversize input yields a diagnostic
  rather than a partial result.
- Registry form (owner-anchored slots in two provider tables; 1020 commits no rows):

```powershell
$script:DocsAnalyzerRow = @(
    # --- 1022: Python and configuration analyzers ---
    # --- 1033: TypeScript and .NET analyzers ---
)

$script:DocsAnalyzerNativeRow = @(
    # --- 1031: Python-native analyzers ---
)
```

  The scanner table `$script:DocsAnalyzerRow` holds `scanner` rows (1022, 1033). The native table
  `$script:DocsAnalyzerNativeRow` is a separate provider table owned by 1031 and holds its `native`
  rows; 1031 edits only that table, so a native row that shares an `Id` with a 1022 scanner row
  never touches a line of the scanner table. Both tables are validated together by
  `Test-DocsAnalyzerRegistration` over the output of `Get-DocsAnalyzerRegistration`.
  Row form: `[pscustomobject]@{ Id = '<identifier>'; Version = '1.0.0'; AnalysisMethod =
  '<scanner|native>'; ElementKinds = @('<kind>'); Module = (Join-Path -Path $PSScriptRoot
  -ChildPath 'DocsAnalyzer<Name>.psm1'); Function = 'Invoke-DocsAnalyzer<Name>' }`, one row per
  line. Profiles select analyzer identifiers only; no profile names a module or a method.
  Anchor format is `# --- <issue number>: <scope> ---`; every anchor carries the real issue number
  from the epic manifest, and no anchor carries a placeholder number in the `900000` range.

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
  `# --- 1021: page-check configuration ---` and `# --- 1034: docs workflow ---`. 1020 commits the
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
  `overwrite`, UTF-8 without BOM, LF); `UtcNow`; `InvokeProcess` (`param($FilePath, $ArgumentList,
  $StdinText, $TimeoutSeconds)`, 1031 precondition). Relative paths are checked with
  `Test-DocsRelativePath` before any context call.
- Process member: the real `InvokeProcess` wraps the private function `Invoke-DocsProcess` of the
  same file, which starts `FilePath` through `System.Diagnostics.ProcessStartInfo` with
  `UseShellExecute` false, each `ArgumentList` item added as one argument (no shell and no command
  string), standard input, output and error redirected as UTF-8, and the working directory equal to
  `RepositoryRoot`. It writes `StdinText` to standard input and closes it, reads both output streams
  asynchronously, and waits at most `TimeoutSeconds`. It returns `@{ ExitCode; Stdout; Stderr;
  TimedOut }`: on exit, `ExitCode` is the process exit code and `TimedOut` is `$false`; on timeout
  the process tree is killed, `ExitCode` is `$null` and `TimedOut` is `$true`. A `TimeoutSeconds`
  that is not a positive number throws `DOCS_PROCESS_ARGUMENT_INVALID` before any process starts,
  and a start failure (for example an executable that does not exist) throws
  `DOCS_PROCESS_START_FAILED` naming `FilePath`. 1020 names no process target and no 1020 command
  calls the member. A caller in `.claude/lib/docs/` never invokes it as `& $Context.InvokeProcess`;
  it passes the member to a `[scriptblock]`-typed parameter declared in the calling file and invokes
  that parameter, which `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  accepts. If `Invoke-DocsCommand.ps1` approaches 500 lines, `Invoke-DocsProcess` moves to
  `.claude/lib/docs/DocsProcess.psm1` with its own Pester suite, bundle copy, core entry and
  classification row.

#### Dispatch table

`Get-DocsCommandTable` returns rows from literal source lines, one row per line, with one anchor
comment per owner:

```powershell
$script:DocsCommandRow = @(
    # --- 1020: init, validate-profile ---
    [pscustomobject]@{ Name = 'init'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsInitCommand'; Option = @{ RepositoryId = 'value'; Profile = 'value'; Write = 'switch'; Force = 'switch' } }
    [pscustomobject]@{ Name = 'validate-profile'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsValidateProfileCommand'; Option = @{ Profile = 'value' } }
    # --- 1021: check ---
    # --- 1022: inventory ---
    # --- 1023: coverage, update-ledger, validate ---
    # --- 1024: generate-reference ---
    # --- 1034: surface-delta ---
)
```

- Anchor numbers are the real issue numbers from the epic manifest (1021, 1022, 1023, 1024, 1034);
  no anchor carries a placeholder number in the `900000` range. 1031 adds no subcommand
  (`inventory` belongs to 1022), so the dispatch table has no 1031 anchor.

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
  LF) of `{command, exit_code, findings, ok, result}`, where `command` is the `-Command` value when
  it names a row of the dispatch table (for example `validate-profile`) and `null` otherwise
  (missing or unknown command, exit 2), `ok` is `true` exactly when `exit_code` is 0, and
  `findings` is in `Get-DocsOrderedFinding` order with its default limit. Identical inputs,
  arguments and clock value produce identical bytes.
- Envelope schema (D5): `schemas/docs/v1/docs-command-envelope.schema.json` pins the envelope (see
  `### Envelope schema: docs-command-envelope`). Every `-Json` output of every subcommand validates
  against it through `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` and `Test-Json`.
- Without `-Json`: `ConvertTo-DocsReportText` output on stdout.
- `-Help`: usage text listing the table rows; reads no input; exit 0. With `-Json`, `-Help` writes
  an envelope with `exit_code` 0, no findings and `result` `{"usage": [<line>, ...]}`. A missing
  `-Command` without `-Help` exits 2.

### Schema identity and reference conventions

- `$schema`: `https://json-schema.org/draft/2020-12/schema` in every docs schema.
- `$id`: `urn:drm-copilot:docs:1.0.0:<name>`, where `<name>` is the file stem without
  `.schema.json`.
- Artifact header, required in each artifact schema: `$schema` (const equal to the schema `$id`),
  `schema_version` (const `"1.0.0"`), `artifact_kind` (const equal to `<name>`), `id`
  (`urn:drm-copilot:docs:1.0.0:common#/$defs/identifier`), `extensions`
  (`urn:drm-copilot:docs:1.0.0:common#/$defs/extensions`).
- Exception: `docs-command-envelope` is not an artifact. Its key set is fixed to `command`,
  `exit_code`, `findings`, `ok` and `result`, so it carries no artifact header, and it is not a
  value of `docs-artifact-kind` (an envelope is never pinned).
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
| `analysis-method` | `enum: ["native", "scanner"]` (D3) |
| `audience-id` | string, pattern `^[a-z0-9][a-z0-9-]*$(?![\s\S])` |
| `audience-ids` | array, `uniqueItems`, items `audience-id` |
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

The `diataxis-mode` values are shared with 1021 (`page-metadata.schema.json`) and 1024
(`diataxis_mode: reference`).

`audience-id` implements the epic pattern `^[a-z0-9][a-z0-9-]*$` (epic `### Generator decisions
from the first preparation of 1024`) as the one shared definition for audience identifiers. The
`(?![\s\S])` suffix follows the convention of the copied discovery patterns: `Test-Json` uses .NET
regular expressions, in which `$` also matches before a final newline, so without the suffix a
value such as `"readers\n"` would pass. For every string that contains no newline, the stored
pattern accepts exactly the strings the epic pattern accepts. `audience-id` is distinct from
`identifier`: `docs.v2` passes only `identifier`, and `2nd-line` passes only `audience-id`. An
invalid audience identifier fails a `pattern`, which is outside the structural walk subset, so it
yields `DOCS_SCHEMA_INVALID` rather than a field-named finding.

### Artifact schema: `docs-profile`

| Field | Shape |
|---|---|
| header | as above |
| `repository` | closed object `{id: identifier}` |
| `audiences` | array `minItems 1`, `uniqueItems`, items closed `{id: audience-id, description: text}` |
| `documentation_roots` | array `minItems 1`, items closed `{id: identifier, path: relative-path, audience_ids: audience-ids}` |
| `surface_selection` | closed object: `element_kinds` (array `minItems 1`, `uniqueItems`, items `element-kind`), `source_roots` (paths, `minItems 1`), `exclusions` (exclusions), `analyzers` (identifiers; optional; absent means every registered analyzer whose kinds intersect `element_kinds`) |
| `page_owners` | array of closed `{path_or_glob: path-or-glob, owner: identifier}` |
| `diataxis_policy` | closed object: `modes` (array `minItems 1`, `uniqueItems`, items `diataxis-mode`), `required_front_matter` (array `uniqueItems`, items `front-matter-field`), `directory_modes` (array of closed `{path_or_glob: path-or-glob, mode: diataxis-mode}`) |
| `completion_gates` | closed object: `docs_complete` (closed `{required_dispositions_complete: const true, allow_deferred: boolean, max_stale_pages: integer minimum 0, required_parity_dimensions: array uniqueItems of parity-dimension}`), `integration_pr_gate` (closed `{enabled: boolean}`) |
| `artifact_paths` | closed object: `inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`, `validation_receipt`, each relative-path |

Semantic checks after schema validation are listed under `Test-DocsProfileSemantic`, which is
unchanged by the audience-id amendment. `New-DocsStarterProfile` and the example profile use
audience identifiers that match `audience-id` (for example `maintainers`). Consumers: 1022 reads
`surface_selection` and `artifact_paths.inventory_snapshot`; 1023 reads
`completion_gates.docs_complete`, `page_owners`, `documentation_roots` and the other
`artifact_paths`; 1024 reads `diataxis_policy` and `page_owners`; 1034 reads
`completion_gates.integration_pr_gate.enabled`.

### Artifact schema: `surface-inventory-snapshot`

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `revision` | revision or `null` (working copy) |
| `profile_sha256` | sha256 of the canonical profile bytes |
| `analyzers` | array `uniqueItems` of closed `{id: identifier, version: text, analysis_method: analysis-method}`, all required; uniqueness of `analyzers[].id` within one snapshot is a semantic rule owned by 1022, because `uniqueItems` compares whole objects |
| `inputs` | array `uniqueItems` of closed `{path: relative-path, sha256: sha256, size: integer minimum 0}` |
| `elements` | array `uniqueItems` of `#/$defs/element` |
| `diagnostics` | array of docs `diagnostic` |
| `captured_at` | timestamp |

`$defs/element` (closed): `element_id` (element-id), `kind` (element-kind), `path`
(relative-path), `declaration` (text), `name` (text), `parent_id` (element-id or `null`),
`analyzer_id` (identifier), `analysis_method` (analysis-method; required, not nullable),
`source_sha256` (sha256; schema `description` "SHA-256 of the declaration lines selected by
line_range (normalized per spec), not of the whole file"), `line_range` (closed
`{start: integer minimum 1, end: integer minimum 1}` or `null`), `properties` (array of closed
`{name: identifier, value: string | number | boolean | null}`; keys and shapes only, never
configuration values), `extensions`. Conditional rules: `kind: cli-option` requires `parent_id`
matching `^cli-command-`; every other kind allows `null` or any element-id. `if` `kind` is one of
the five kinds other than `architecture-component`, `then` `properties.line_range` has
`type: "object"`, so a `null` range on, for example, a `cli-command` yields
`DOCS_SCHEMA_TYPE_MISMATCH` at `/elements/<n>/line_range`. `start <= end` is not expressible in
JSON Schema and is enforced by `New-DocsSurfaceElement` and `ConvertTo-DocsDeclarationText`.

The snapshot example exercises both methods: some elements carry `analysis_method: "native"` and
others `"scanner"`, and `analyzers[]` lists one entry per method with neutral identifiers.

### Artifact schema: `docs-coverage-ledger`

| Field | Shape |
|---|---|
| header | as above |
| `repository` | identifier |
| `snapshot_ref` | `artifact-pin` with `artifact_kind` const `surface-inventory-snapshot` |
| `entries` | array `uniqueItems` of `#/$defs/entry` |

`$defs/entry` (closed): `element_id` (element-id), `kind` (element-kind), `analysis_method`
(analysis-method; required, not nullable), `disposition` (`disposition`), `page_bindings` (array of
`page-binding`), `rationale` (text or `null`), `owner` (identifier or `null`), `target` (text or
`null`), `updated_by` (`actor`), `extensions`. `analysis_method` records the method of the snapshot
element at the last ledger synchronization; 1023 keeps it current. The ledger example copies the
method of each entry's element. The scanner precision limit (D3) is recorded by 1023 as a
`deferred` entry with an owner and a target, which the companion rules below already require; no
further schema change is needed for it.

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
`source_path` (relative-path), `source_sha256` (sha256; the declaration-lines digest copied from
the snapshot element; 1023 compares it as an opaque value with the current snapshot element),
`revision` (revision or `null`), `claim` (text or `null`), `pinned_at`
(timestamp), `pinned_by` (`actor`).

### Artifact schema: `docs-validation-receipt`

| Field | Shape |
|---|---|
| header | as above |
| `mode` | `enum: ["profile", "ledger", "matrix", "docs-complete"]` |
| `repository` | identifier |
| `revision` | revision (non-null; 1034 matches it against the head revision) |
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
that reference it. The non-artifact `docs-command-envelope` schema is not one of the artifact
schemas; it has its own example and its own acceptance criterion.

### Envelope schema: `docs-command-envelope`

`schemas/docs/v1/docs-command-envelope.schema.json` (D5):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "urn:drm-copilot:docs:1.0.0:docs-command-envelope",
  "title": "Invoke-DocsCommand.ps1 -Json output envelope",
  "type": "object",
  "additionalProperties": false,
  "required": ["command", "exit_code", "findings", "ok", "result"],
  "properties": {
    "command": {"type": ["string", "null"], "pattern": "^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$(?![\\s\\S])"},
    "exit_code": {"type": "integer", "enum": [0, 1, 2, 3]},
    "findings": {"type": "array", "maxItems": 101, "items": {"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/finding"}},
    "ok": {"type": "boolean"},
    "result": {}
  },
  "allOf": [
    {"if": {"properties": {"exit_code": {"const": 0}}},
     "then": {"properties": {"ok": {"const": true}, "findings": {"items": {"properties": {"severity": {"enum": ["warning", "info"]}}}}}},
     "else": {"properties": {"ok": {"const": false}}}},
    {"if": {"properties": {"exit_code": {"const": 1}}},
     "then": {"properties": {"findings": {"minItems": 1}}}},
    {"if": {"properties": {"exit_code": {"enum": [2, 3]}}},
     "then": {"properties": {"findings": {"minItems": 1, "maxItems": 1}, "result": {"type": "null"}}}}
  ]
}
```

- `result` is open (`{}`): each subcommand owns its result shape, so later children do not edit
  this file. The exit 2 and exit 3 rows force `null`.
- Every constraint except `pattern` is inside the structural walk subset, so an envelope violation
  names its field. `maxItems: 101` is the `Get-DocsOrderedFinding` default limit of 100 plus the
  one `FINDINGS_LIMIT` finding; every command uses the default limit.
- The file keeps the docs common URN ref and is composed in memory by `Get-DocsComposedSchemaSet`
  like every other docs schema (`#### Schema composition`). It has a byte-identical runtime copy
  under `.claude/lib/docs/schemas/v1/`, a byte-identical bundle copy, and one `core.json` `paths`
  line `".claude/lib/docs/schemas/v1/docs-command-envelope.schema.json"`.
- Example: `examples/docs/v1/docs-command-envelope.example.json`, a `validate-profile` exit 1
  envelope with one `DOCS_PROFILE_AUDIENCE_UNKNOWN` finding and `result`
  `{"profile_path": ..., "repository_id": ...}`.

## Data & State

- Element identity is a pure function of kind, path and declaration; the analysis method does not
  affect it.
- `source_sha256` is a pure function of the captured input text and `line_range`
  (`Get-DocsDeclarationSha256`).
- The analysis method is recorded per snapshot element, per snapshot `analyzers[]` item and per
  ledger entry; diagnostics carry no method field, and a diagnostic's method is derived through its
  `analyzer_id` (OQ-8).
- All ordering is deterministic: findings by `Get-DocsOrderedFinding`, elements by `element_id`,
  pins by `pin_id`, analyzer rows by `Id`, schema names in fixed order.
- Framework code, schemas and examples contain no consumer-specific names; all repository
  specificity is profile data.
- No module-scope cache: schemas are read and composed once per command invocation.
- Persistence: `init -Write` writes the profile (and, after 1021 and 1034, their template rows)
  through `Write-DocsFileText`, the only filesystem write in 1020. Ledger, matrix, pin and receipt
  writes belong to 1023.
- Runtime schema copy: `.claude/lib/docs/schemas/v1/` holds byte-identical copies of every file in
  `schemas/docs/v1/` (canonical location, naming contract). The bundle copy holds byte-identical
  copies of every file under `.claude/lib/docs/` except the `.claude/lib/docs/python/` subtree,
  whose bundle placement and manifest listing belong to 1031 and the python pack.
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
  and field-name containment only, and the runtime fails closed below 7.4. The envelope schema
  relies on `if`/`then`/`else` with `const` and `enum`, the empty schema `{}` and a `type` array
  with `pattern`, and `audience-id` relies on the `(?![\s\S])` suffix; these are confirmed only by
  the CI result.
- Digest tests use in-memory strings with explicit CR characters, so the repository
  `.gitattributes` line-ending rule cannot affect them.
- Batch budget: sixteen production PowerShell files (eight plus eight bundle copies) exceed the
  direct-mode cap, so execution runs on the large route in the item worktree that holds the
  orchestration checkpoint, never in an isolated executor worktree.
- File size: `Invoke-DocsCommand.ps1`, `DocsSchema.psm1` and `DocsProfile.psm1` are the largest
  candidates; a file reaching the 500-line guidance is split into a new `Docs<Area>.psm1` with its
  own Pester suite, push-down copy and core entry. `DocsSurface.psm1` and
  `DocsAnalyzerRegistry.psm1` grow with this amendment; if `DocsSurface.psm1` approaches 500 lines,
  the digest functions move to `DocsDeclarationDigest.psm1` with the same obligations and a
  classification row. The process member adds `Invoke-DocsProcess` to `Invoke-DocsCommand.ps1`; if
  that file approaches 500 lines, the function moves to `DocsProcess.psm1` on the same terms.
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
- Create `schemas/docs/v1/common.schema.json`, the six artifact schemas and
  `schemas/docs/v1/docs-command-envelope.schema.json`, and `examples/docs/v1/<name>.example.json`
  for each artifact schema and for the envelope.
- Create the runtime copies `.claude/lib/docs/schemas/v1/*.schema.json`.
- Create byte-identical bundle copies of every file under `.claude/lib/docs/` at
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`paths`):
  append every file under `.claude/lib/docs/` except the `.claude/lib/docs/python/` subtree,
  PowerShell and data (1020 creates no file in that subtree).
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
  (evidence under `<FEATURE>/evidence/`). The declaration-lines digest golden vector D1 is recorded
  the same way, in the same evidence file.
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
| `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` (runtime copy, D5) | schema/config/data (pushed down) | JSON | D; location is OQ-1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` (bundle copies of every file above) | pushed-down helper/lib and data (mirror) | PowerShell, JSON | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` (bundle copy, D5) | schema/config/data (mirror) | JSON | D |
| `schemas/docs/v1/common.schema.json` and the artifact schemas | schema/config/data | JSON | D |
| `schemas/docs/v1/docs-command-envelope.schema.json` (canonical, non-artifact, D5) | schema/config/data | JSON | D |
| `examples/docs/v1/<name>.example.json` (one per artifact schema) | schema/config/data | JSON | D |
| `examples/docs/v1/docs-command-envelope.example.json` (D5) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `quality-tiers.yml` (edit) | schema/config/data | YAML | D |
| `tests/scripts/claude-lib/docs/*.Tests.ps1`, `Docs.TestSupport.psm1`, `fixtures/*.psm1` | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/**` (spec, user story, plan, evidence) | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, Python file or TypeScript file is created or
edited. Every artifact follows the language rule; OQ-1 and OQ-2 concern location and reachability,
not language. The D3 language exception (a language-native analyzer pushed down only with its
language's pack) applies to 1031, not to 1020: 1020 creates no Python file. If the conditional
split of `## Constraints & Risks` creates `.claude/lib/docs/DocsDeclarationDigest.psm1` or
`.claude/lib/docs/DocsProcess.psm1`, each is a pushed-down helper/lib in PowerShell under R1, with a
bundle copy and a `core.json` line.

## Decisions Later Children Must Honor

- Register a subcommand by inserting rows directly under the child's own anchor in
  `Invoke-DocsCommand.ps1` (1021, 1022, 1023, 1024, 1034); never edit another anchor or row.
  Command modules are `Docs<Area>Commands.psm1` or the epic-named module and follow the command
  function contract. 1031 has no dispatch anchor.
- Analyzer rows go under the child's anchor in `DocsAnalyzerRegistry.psm1`. The scanner provider
  table `$script:DocsAnalyzerRow` carries, in order, `# --- 1022: Python and configuration
  analyzers ---` and `# --- 1033: TypeScript and .NET analyzers ---`; the separate native provider
  table `$script:DocsAnalyzerNativeRow` carries `# --- 1031: Python-native analyzers ---`.
  `Get-DocsAnalyzerRegistration` returns the scanner table followed by the native table, and
  `Test-DocsAnalyzerRegistration` validates the rows of both. 1031 inserts its rows only into the
  native table. Analyzers follow the `Invoke-DocsAnalyzer<Name> -CapturedInput -Selection`
  contract and are pure.
- Registry keying (D3): every row carries `AnalysisMethod` (`scanner` or `native`); uniqueness is
  on (`Id`, `AnalysisMethod`) across both tables; a `native` row requires a `scanner` row with the
  same `Id`. 1022 and 1033 register `scanner` rows; 1031 registers `native` rows under the same
  identifiers as the 1022 Python analyzers. Selection takes the `native` row only for identifiers
  passed in `-NativeAvailable`; detection of the pack and interpreter belongs to the 1031 adapter
  (OQ-9).
- `analysis_method` (D3): every element an analyzer returns carries `analysis_method` equal to its
  registry row's `AnalysisMethod` (1022 and 1033: `scanner`; 1031: `native`); every snapshot
  `analyzers[]` item carries it; every ledger entry carries the method of its snapshot element and
  1023 keeps it current. It is not part of the element identifier and is not added to diagnostics.
  The scanner precision limit is recorded by 1023 as a `deferred` ledger entry with an owner and a
  target.
- Declaration-lines digest (D5): `source_sha256` is `Get-DocsDeclarationSha256` over the captured
  input text and `line_range`, built only through `New-DocsSurfaceElement -SourceText`; `line_range`
  is required for every kind except `architecture-component`; `Invoke-DocsAnalyzer` rejects any
  element whose digest differs from the recomputed one. A native analyzer (1031) reproduces the
  five normalization steps of `#### Declaration-lines digest` byte for byte. Evidence pins copy the
  element digest, and 1023 compares digests as opaque values.
- Use only literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` for sibling modules and
  data; list every new `.claude/lib/docs/` file except the files of the `.claude/lib/docs/python/`
  subtree (PowerShell and data) in Claude `core.json`, mirror it byte-identically, and keep
  `Docs.Manifest.Tests.ps1` green. The `.claude/lib/docs/python/` subtree is listed only in the
  python pack manifest (1031), and every assertion of `Docs.Manifest.Tests.ps1` excludes it.
- Diagnostics: build diagnostics with `New-DocsDiagnostic`; a non-blocking notice uses `-Severity
  information` (blocking `false`), and blocking is `true` exactly when severity is `error`.
- New schemas (1021 `page-metadata.schema.json`) go to `schemas/docs/v1/` and the runtime copy under
  `.claude/lib/docs/schemas/v1/`, with a `Get-DocsSchemaPath` row and a `Get-DocsSchemaName` entry
  under the 1021 anchor; shared definitions are referenced through
  `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>`; no ref to discovery schemas; timestamps use a
  `pattern`, never `format` alone.
- Audience identifiers (coordination with 1021): 1021 `page-metadata.schema.json` `audience` is
  `minItems 1` with items `urn:drm-copilot:docs:1.0.0:common#/$defs/audience-id` (or `audience-ids`
  plus `minItems 1`); it does not restate the pattern. The docs profile uses `audience-id` for
  `audiences[].id` and `audience-ids` for `documentation_roots[].audience_ids`, so profile audience
  identifiers and page-metadata `audience` values follow one pattern.
- Validate artifacts with `Test-DocsArtifactText`; never rely on `Test-Json` message text to name a
  field. Constraints whose failures must name a field stay within the structural walk subset.
- Parse JSON with `ConvertFrom-DocsJsonText`; never `ConvertFrom-Json` for artifacts.
- Build findings with `New-DocsFinding` and results with `New-DocsCommandResult`; exit codes 0/1/2/3
  and the `-Json` envelope apply to every subcommand; never print output or call `exit` inside a
  command module.
- Envelope schema (D5): every subcommand's `-Json` output validates against
  `schemas/docs/v1/docs-command-envelope.schema.json`; each child adds a Pester case that validates
  its subcommands' `-Json` output through `Test-DocsArtifactText -ArtifactKind
  'docs-command-envelope'`. `result` is owned by each subcommand and is not constrained by the
  envelope schema; children do not edit the envelope schema. Commands use the default finding
  limit.
- No filesystem, clock or process access outside the command context; tests use in-memory contexts
  and create no temporary files.
- Process access (1031 precondition): a child starts a process only through `Context.InvokeProcess`
  (`param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds)`, returning `@{ ExitCode; Stdout;
  Stderr; TimedOut }`). The calling file passes the member to a `[scriptblock]`-typed parameter
  declared in that file and invokes the parameter, never `& $Context.InvokeProcess`, so
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` accepts it.
  1020 commits no process target; a child whose file names an interpreter follows the epic's
  allowlist decision for that guard (owner question Q11) in its own change. Unit tests use the
  in-memory `InvokeProcess` fake of `Docs.TestSupport.psm1`, whose call log records each call.
- Consumer configuration and workflow templates ship as data under `.claude/lib/docs/templates/` and
  are delivered by `init` through one `Get-DocsInitTemplate` row under the child's anchor (1021,
  1034); no push-down root is added and no file goes under
  `extensions/drm-copilot/resources/templates/`.
- Element identifiers come from `Get-DocsElementId`; records are rebuilt with
  `ConvertFrom-DocsSurfaceElement`; pin and receipt identifiers use `Get-DocsStableId`; element
  digests use `Get-DocsDeclarationSha256`, other file digests use `Get-DocsBytesSha256Hex`, and all
  digests are compared as opaque values (1023).
- Profile access goes through `ConvertFrom-DocsProfileText`; the keys 1023 relies on are
  `artifact_paths.{inventory_snapshot, coverage_ledger, parity_matrix, evidence_pins,
  validation_receipt}`, `completion_gates.docs_complete.{allow_deferred, max_stale_pages,
  required_parity_dimensions}`, `page_owners[{path_or_glob, owner}]` and `documentation_roots`.
- 1023's single-write-boundary test allowlists `Write-DocsFileText` in `Invoke-DocsCommand.ps1` with
  the reason "init create-only and explicit overwrite"; 1023 adds its own boundary module.
- 1036 invokes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name>
  -Json ...` with the workspace root as working directory and parses the envelope, whose shape is
  fixed by `docs-command-envelope.schema.json`; it adds no logic.
- 1037 skills call `Invoke-DocsCommand.ps1` or the MCP tools; Codex reachability follows OQ-2.
- 1038 states PowerShell 7.4 as the destination prerequisite (OQ-3).

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
   Codex skills mirrored by 1037 would need either the Claude push-down in the destination or a
   `.codex/lib/docs/` virtual directory (new `VIRTUAL_RESOURCE_DIRECTORIES` entry in TypeScript, the
   in-place edit of the existing Python twin, and Codex skill text naming `.codex/lib/docs/`).
   Provisional default: Claude bundle only in 1020; 1037 decides after the owner answers.
3. **OQ-3 - Destination PowerShell floor.** The epic states "PowerShell 7 only"; `Test-Json` Draft
   2020-12 support needs 7.4. Provisional default: require 7.4 and fail closed with
   `DOCS_RUNTIME_UNSUPPORTED` (exit 3) below it.
4. **OQ-4 - Tier of `.claude/lib/docs`.** T3 matches every existing `.claude/lib/*` entry; T2 would
   reflect the contract role but adds property-test density and mutation-trend obligations and
   requires changing `test_committed_quality_tiers_yml_assigns_spec_tiers`. Provisional default: T3.
5. **OQ-5 - `init -Write` scope.** Delivering the 1034 workflow and 1021 linter configuration
   through `init` means a pushed-down helper writes into a destination's `.github/workflows/` and
   repository-root dotfiles. Provisional default: allowed only with `-Write`, create-only unless
   `-Force`, dry run by default, every planned path listed before any write.
6. **OQ-6 - D5 self-contained fallback form.** D5 names self-contained schemas as the fallback when
   cross-file `$ref` fails, which the probe confirmed. Options: (a) each schema file keeps the docs
   common URN ref and `Join-DocsSchemaText` composes a self-contained schema in memory before
   `Test-Json`; (b) each file physically inlines the shared definitions it uses (a second copy per
   file, each needing a parity test). Provisional default: (a).
7. **OQ-7 - Architecture-component digest exception.** An `architecture-component` element may have
   `line_range` `null`, and its digest then covers every line of the normalized file. This is the
   only case where the digest equals a whole-file digest. Provisional default: allow the exception.
8. **OQ-8 - Granularity of the recorded method.** D3 says the ledger records the analysis method
   "per finding". Provisional default: the method is recorded per ledger entry, per snapshot element
   and per snapshot `analyzers[]` item, matching the epic D3 text "per element"; the docs common
   `diagnostic` gains no method field, and a diagnostic's method is derived through its
   `analyzer_id`.
9. **OQ-9 - Registry key and native selection rule.** Provisional default: rows are unique on
   (`Id`, `AnalysisMethod`); a `native` row requires a `scanner` row with the same `Id`; selection
   returns the `native` row only for identifiers in `-NativeAvailable`, otherwise the `scanner` row.
   1022 and 1031 confirm or revise this rule in their own preparation through an epic-level
   update.

OQ-1 to OQ-5 come from the re-preparation; OQ-6 to OQ-9 come from the D3 and D5 amendment research
and are not decided beyond their provisional defaults.

## Numeric Derivation Reference

The acceptance criteria name the artifact schemas, anchors and test cases by name and assert no
count. Counts used in the narrative are supported by complete `## Numeric Derivation Evidence`
records: the artifact schema family in the earlier research, the production PowerShell file family
(eight files) in the PowerShell design addendum research, and, in the D3 and D5 amendment
research, the docs schema file family after the amendment (eight files, including `common` and
`docs-command-envelope`) and the `.claude/lib/docs/` file family after the amendment (sixteen files:
eight PowerShell files and eight runtime schema copies).

## Acceptance Criteria

- [ ] Every example under `examples/docs/v1/` validates against its schema, including the `docs-command-envelope` example against the envelope schema: `Test-Json` returns `True` and `Test-DocsArtifactText` returns no finding for each example (`tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1`).
- [ ] For each artifact schema (`docs-profile`, `surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`, `docs-validation-receipt`), an in-memory copy of its example with one required field deleted, and a copy with an unknown element kind or disposition, each make `Test-Json` return `False` and make `Test-DocsArtifactText` return an `error` finding (`DOCS_SCHEMA_REQUIRED_MISSING`, `DOCS_SCHEMA_VALUE_NOT_ALLOWED` or `DOCS_SCHEMA_PROPERTY_UNKNOWN`) whose pointer locates the mutated field (`DocsSchemaContract.Tests.ps1`).
- [ ] `Invoke-DocsCommand.ps1 -Command validate-profile -Profile examples/docs/v1/docs-profile.example.json` exits 0 with no `error` finding (`tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` and `DocsProfileCommands.Tests.ps1`).
- [ ] `-Command validate-profile` exits 1 for an invalid profile, and the finding names the failing field: a profile without `audiences` yields `DOCS_SCHEMA_REQUIRED_MISSING` at `/audiences` with a message containing `audiences`; a missing required field inside a nested `$ref` target yields a finding whose pointer and message name that field; an unknown element kind yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/surface_selection/element_kinds/<n>`; the field naming comes from `Get-DocsSchemaStructuralFinding`, not from `Test-Json` message text (`DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1`).
- [ ] `-Command validate-profile` exits 1 with `DOCS_JSON_DUPLICATE_KEY` for a profile containing a repeated member, with `DOCS_PROFILE_AUDIENCE_UNKNOWN` for an undeclared audience reference, and with `DOCS_PROFILE_MISSING` for an absent profile (`DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1`).
- [ ] `-Command init` without `-Write` exits 0, writes nothing, and returns a starter profile that `ConvertFrom-DocsProfileText` accepts with no finding for several repository identifiers; with `-Write` it creates the profile; with `-Write` and an existing target it exits 1 with `DOCS_INIT_TARGET_EXISTS` and writes nothing; with `-Write -Force` it overwrites (`DocsProfileCommands.Tests.ps1`, using an in-memory context).
- [ ] Element identifiers are deterministic over a seeded set of inputs: for a seeded `[System.Random]` input set (seed printed on failure) the same kind, path and declaration yield the same identifier, enumerated boundary cases yield distinct identifiers, each golden vector matches its recorded canonical string and hex digest, and an unpaired surrogate or a non-relative path is rejected with `DOCS_IDENTITY_INPUT_INVALID` (`tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1`).
- [ ] `ConvertFrom-DocsSurfaceElement` throws `DOCS_ELEMENT_ID_MISMATCH` for a record whose `element_id` was altered, and `New-DocsSurfaceElement` rejects a `cli-option` without a `cli-command-` parent (`DocsSurface.Tests.ps1`).
- [ ] `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` holds consumer identifiers only as lowercase hex SHA-256 digests (no identifier text), finds no configured digest in any file under `.claude/lib/docs/`, `schemas/docs/` or `examples/docs/`, detects a synthetic identifier injected into an in-memory file map (positive control), and asserts the digest list is non-empty with every entry matching `^[0-9a-f]{64}$`.
- [ ] `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` passes: every file under `.claude/lib/docs/` except `.claude/lib/docs/python/**` (PowerShell and data, recursively) is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and is SHA-256 identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`; the discovered set is non-empty; and the exclusion filter drops every in-memory path under `.claude/lib/docs/python/` and keeps every other in-memory path, including `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` and a path under `.claude/lib/docs/pythonic/`.
- [ ] The existing push-down contract tests `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (including `test_every_psscriptroot_occurrence_is_recognized`) pass on the feature branch without modification.
- [ ] The file set under `.claude/lib/docs/schemas/v1/` equals the file set under `schemas/docs/v1/` and each runtime copy is byte-identical to its canonical file (`DocsSchemaContract.Tests.ps1`).
- [ ] Each docs common definition copied from discovery v2 common equals the discovery definition as canonical JSON, except `timestamp`, which carries the timestamp `pattern`; no docs schema contains a `$ref` to a discovery URN or to a file (`DocsSchemaContract.Tests.ps1`).
- [ ] `Join-DocsSchemaText` rewrites docs common URN refs and refs inside copied definitions to `#/$defs/common.<name>`, leaves local refs unchanged, removes the root `$id`, returns `DOCS_SCHEMA_COMPOSITION_CONFLICT` for a target `$defs` key beginning `common.`, and returns `DOCS_SCHEMA_REF_UNRESOLVED` for an unknown common name and for a foreign URN, file or URI ref without retrieving it (`tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1`).
- [ ] `Test-DocsArtifactText` returns exactly one `DOCS_SCHEMA_INVALID` finding with pointer `''` when `Test-Json` returns `False` with no ErrorRecord and the structural walk finds nothing, and returns the walk findings when the walk reports an error (`DocsSchema.Tests.ps1`, using a schema constraint outside the walk subset and a stubbed `Test-Json` result where needed).
- [ ] Exit codes follow 0/1/2/3 for every 1020 subcommand: 0 for success and `-Help`; 1 for `error` findings; 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `null` for a missing `-Command`, an unknown command, an unknown option, a missing value, a repeated non-`multi` option and a non-relative path; 3 with exactly one finding (`DOCS_RUNTIME_UNSUPPORTED` through the `-PowerShellVersion` seam set below 7.4, or `DOCS_CLI_RUNTIME` for an injected exception) and one stderr line (`Invoke-DocsCommand.Tests.ps1`).
- [ ] With `-Json`, stdout is exactly one canonical JSON document whose keys are `command`, `exit_code`, `findings`, `ok` and `result`, `command` is the subcommand name when `-Command` names a dispatch-table row and `null` for a missing or unknown command, `ok` is `true` exactly when `exit_code` is 0, and two runs with identical inputs, arguments and clock produce identical bytes; without `-Json`, the last line is `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>` (`Invoke-DocsCommand.Tests.ps1`, `DocsFinding.Tests.ps1`).
- [ ] `Test-DocsCommandTable` returns no finding for the committed dispatch table; the table contains the `init` and `validate-profile` rows under the `# --- 1020: init, validate-profile ---` anchor followed by the anchors `# --- 1021: check ---`, `# --- 1022: inventory ---`, `# --- 1023: coverage, update-ledger, validate ---`, `# --- 1024: generate-reference ---` and `# --- 1034: surface-delta ---` in that order, with no anchor line carrying a placeholder number in the `900000` range; and `Test-DocsCommandTable` rejects a duplicate name, a reserved option name and a function outside `^Invoke-Docs[A-Za-z]+Command$` (`Invoke-DocsCommand.Tests.ps1`).
- [ ] The committed analyzer registry has no rows: the scanner provider table `$script:DocsAnalyzerRow` is empty and carries the anchors `# --- 1022: Python and configuration analyzers ---` and `# --- 1033: TypeScript and .NET analyzers ---` in that order, the separate native provider table `$script:DocsAnalyzerNativeRow` is empty, follows the scanner table in the module text and carries the anchor `# --- 1031: Python-native analyzers ---`, and no anchor line carries a placeholder number in the `900000` range; `Get-DocsAnalyzerRegistration` returns the scanner rows followed by the native rows; `Test-DocsAnalyzerRegistration` validates rows from both tables (a defective row in either table yields `DOCS_ANALYZER_REGISTRATION_INVALID` with a pointer to its position in the concatenated registration, and a `scanner` row in the scanner table with a `native` row of the same `Id` in the native table is accepted); `Test-DocsAnalyzerRegistration` returns no finding for the committed registry and returns `DOCS_ANALYZER_REGISTRATION_INVALID` for a duplicate (`Id`, `AnalysisMethod`) pair and for a `Module` outside `.claude/lib/docs/`; `Select-DocsAnalyzerRegistration` reports `DOCS_ANALYZER_UNKNOWN` without invoking the `-ImportModule` seam; `Invoke-DocsAnalyzer` rejects fixture output whose kind is outside the registration (`tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1`).
- [ ] Every new file under `.claude/lib/docs/` passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, and no production file under `.claude/lib/docs/` exceeds 500 logical lines.
- [ ] `quality-tiers.yml` contains an entry with `path: ".claude/lib/docs"` and `tier: T3`; `python -m scripts.dev_tools.check_quality_tiers` exits 0 and `test_committed_quality_tiers_yml_matches_live_tree` and `test_committed_quality_tiers_yml_assigns_spec_tiers` pass unmodified.
- [ ] No Python or TypeScript file is added or modified: `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule.
- [ ] No discovery file changes: `git diff --name-only <merge-base>..HEAD` lists no path under `packages/discovery-runtime/`, `schemas/discovery/` or `.claude/lib/discovery-validation/`.
- [ ] No test creates a temporary file: no file under `tests/scripts/claude-lib/docs/` contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`, and every command test uses an in-memory command context.
- [ ] Pester line coverage is at least 85% for each production file under `.claude/lib/docs/`, read from the PoshQC coverage report produced by `Invoke-PoshQCTest`, with no production file excluded from measurement (no branch-coverage gate applies to Pester); the figures are recorded under `<FEATURE>/evidence/coverage/`.
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` on `windows-latest` and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head.
- [ ] Analysis method (D3): docs common defines `analysis-method` as `enum: ["native", "scanner"]`; the snapshot `$defs/element`, the snapshot `analyzers[]` items and the ledger `$defs/entry` each require a non-null `analysis_method`, and for each of them an in-memory copy of the example with `analysis_method` deleted yields `DOCS_SCHEMA_REQUIRED_MISSING` and a copy with an unknown value yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED`, each with a pointer that locates the field (`DocsSchemaContract.Tests.ps1`); `New-DocsSurfaceElement` rejects an `-AnalysisMethod` outside `Get-DocsAnalysisMethod` with `DOCS_IDENTITY_INPUT_INVALID`, and two elements that differ only in `AnalysisMethod` have equal `element_id` and are both accepted by `ConvertFrom-DocsSurfaceElement` (`DocsSurface.Tests.ps1`); `Test-DocsAnalyzerRegistration` returns `DOCS_ANALYZER_REGISTRATION_INVALID` for an `AnalysisMethod` outside `Get-DocsAnalysisMethod` and for a `native` row without a `scanner` row of the same `Id`, and accepts a `scanner` row and a `native` row that share an `Id`; `Select-DocsAnalyzerRegistration` returns the `native` row for an `Id` in `-NativeAvailable` and the `scanner` row otherwise; `Invoke-DocsAnalyzer` rejects fixture output whose `analysis_method` differs from the row's `AnalysisMethod` (`DocsAnalyzerRegistry.Tests.ps1`).
- [ ] Declaration-lines digest (D5): a Pester test proves locality of `Get-DocsDeclarationSha256` for a six-line in-memory text and range `@(3, 4)`: changing line 1, changing line 6, inserting two lines above with the range shifted to `@(5, 6)`, converting line endings to CRLF, removing the final newline and adding a BOM each leave the digest unchanged, while changing one character in line 3, changing one character in line 4, and extending the range to `@(3, 5)` each change it; a seeded `[System.Random]` property test (seed printed on failure) shows that a mutation of a line outside the range never changes the digest and appending a character to a line inside the range always changes it; ranges `@(0, 1)`, `@(3, 2)` and an `end` beyond the line count throw `DOCS_DIGEST_RANGE_INVALID`; an `architecture-component` without a range digests every normalized line; golden vector D1 matches its recorded canonical text and hex digest (`DocsSurface.Tests.ps1`); a `null` `line_range` on a `cli-command` element yields `DOCS_SCHEMA_TYPE_MISMATCH` at `/elements/<n>/line_range` (`DocsSchemaContract.Tests.ps1`); and `Invoke-DocsAnalyzer` rejects fixture output whose `source_sha256` differs from the digest recomputed from the captured input and `line_range` (`DocsAnalyzerRegistry.Tests.ps1`).
- [ ] Envelope schema (D5): `schemas/docs/v1/docs-command-envelope.schema.json` exists with `$id` `urn:drm-copilot:docs:1.0.0:docs-command-envelope`, its runtime copy under `.claude/lib/docs/schemas/v1/` and its bundle copy are byte-identical to it, and `core.json` lists `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json`; a Pester test validates the `Invoke-DocsCommand.ps1 -Json` output of each planned `-Json` scenario (exit 0 `validate-profile`, exit 1 invalid profile, each exit 2 case, each exit 3 case, and `-Help -Json`) against the envelope schema, asserting that `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` returns no finding and that `Test-Json` with the composed envelope schema returns `True`, with `Test-Json` not mocked in that suite (`Invoke-DocsCommand.Tests.ps1`); and in-memory mutations of the envelope example are rejected: `ok` true with `exit_code` 1 yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/ok`, an extra key yields `DOCS_SCHEMA_PROPERTY_UNKNOWN`, `exit_code` 2 with two findings yields `DOCS_SCHEMA_ITEM_COUNT` at `/findings`, `exit_code` 0 with an `error` finding yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/findings/0/severity`, and a missing `result` yields `DOCS_SCHEMA_REQUIRED_MISSING` at `/result` (`DocsSchemaContract.Tests.ps1`).
- [ ] Audience identifiers: docs common defines `audience-id` with pattern `^[a-z0-9][a-z0-9-]*$(?![\s\S])` and `audience-ids`, and the profile schema references them for `audiences[].id` and `documentation_roots[].audience_ids` (`DocsSchemaContract.Tests.ps1`); profiles with audience identifiers `Readers`, `docs.v2`, `a_b`, `-x` and `readers` followed by a newline are each rejected by `ConvertFrom-DocsProfileText` (`Ok` false, at least one `error` finding), and profiles with `2nd-line` and `maintainers` are accepted (`DocsProfile.Tests.ps1`).
- [ ] Diagnostic severity (1031 precondition): `New-DocsDiagnostic -Severity error` returns `severity` `error` with `blocking` `true`; `-Severity warning` returns `warning` with `blocking` `false`; `-Severity information` returns `information` with `blocking` `false`, also when `-Blocking` is omitted; `-Severity information -Blocking $true` throws `DOCS_IDENTITY_INPUT_INVALID` naming `Blocking`; an unknown severity (for example `info`) throws `DOCS_IDENTITY_INPUT_INVALID` naming `Severity`; without `-Severity`, `-Blocking $true` gives `error` and `-Blocking $false` gives `warning`; every returned diagnostic has exactly the key set of the docs common `diagnostic` definition, and its `severity` is a value of that definition's `severity` enum (`DocsSurface.Tests.ps1`).
- [ ] Process member (1031 precondition): the context from `New-DocsCommandContext` exposes the `[scriptblock]` member `InvokeProcess`, and its member set equals that of the in-memory context of `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`; run against the current PowerShell executable (no Python), the real member returns the child's exit code, its standard output and its standard error separately, passes `StdinText` to the child's standard input, returns `TimedOut` `$true` and `ExitCode` `$null` for a child that outlives a one-second timeout, throws `DOCS_PROCESS_START_FAILED` for an executable that does not exist and `DOCS_PROCESS_ARGUMENT_INVALID` for a non-positive timeout; the in-memory fake records each call with its four arguments in its call log; and `enforcement-hooks-no-python-invocation.Tests.ps1` reports no finding for any `.claude/lib/docs/` file (`Invoke-DocsCommand.Tests.ps1`).

## Definition of Done

- [ ] Acceptance criteria documented and mapped to Pester suites or commands
- [ ] Behavior matches acceptance criteria on PowerShell 7.4 or later and on the CI `windows-latest` runner
- [ ] Edge cases covered by tests: empty file, invalid JSON, duplicate keys, excess depth, unknown analyzer identifier, duplicate audience identifiers, unknown audience reference, directory mode outside the policy, existing init target, digest range outside the text, empty source text, `architecture-component` without a range, `native` registry row without a `scanner` row, analyzer output with a mismatched method or digest, a defective row in the native provider table, each diagnostic severity with its blocking coupling, an unknown diagnostic severity, a severity that disagrees with an explicit `-Blocking`, a process that exits non-zero, writes to standard error, outlives its timeout or cannot start, and a non-positive process timeout
- [ ] Docs suites pass in three seeded shuffled file-order runs in one process (each seed and order recorded) and in a fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Toolchain pass completed (format, lint with PSScriptAnalyzer, architecture and contract tests, Pester) in a single clean pass
- [ ] Forbidden-token scan with bracket-class patterns over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: JSON parsing, findings and envelope, schema composition and structural walk, profile loading and validation, surface identities, declaration-lines digest, analyzer registry, entry script.
- [ ] Integration scenarios: every example validates against its composed schema; runtime schema copies and bundle copies match their sources.
- [ ] CLI examples: `Invoke-DocsCommand.ps1 -Command init`, `Invoke-DocsCommand.ps1 -Command validate-profile`.
