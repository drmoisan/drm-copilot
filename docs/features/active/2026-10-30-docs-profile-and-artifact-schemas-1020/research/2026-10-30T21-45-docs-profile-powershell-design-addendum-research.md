# docs-profile-and-artifact-schemas (Issue #1020) - PowerShell Design Addendum

- Feature: child 1020 of epic #1019 (documentation-estate-tooling), wave 0, band C3
- Branch: `feature/docs-profile-and-artifact-schemas-1020`
- Mode: re-preparation research for the refined language rule; no source, configuration or test
  file was changed.
- Relationship to earlier research: `research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md`
  (the "earlier research") was written for the withdrawn Python package design. This addendum
  supersedes every section of it that names `packages/docs-runtime`, `drm_copilot_docs`,
  `dev.docs.*`, Poetry, pytest, `jsonschema`/`referencing`, the wheel builder, or the
  `tests/docs_runtime/` layout. The language-independent sections it keeps are listed in section 1.
- Filename note: the delegation named `...-docs-profile-powershell-design-addendum.md`. The
  SubagentStop hook `.claude/hooks/validate-task-researcher-output.ps1` (`Test-IsValidResearchFileName`)
  accepts only names ending in `-research.md` (or `research-addendum.<timestamp>.md`), so this file
  carries the suffix `-research.md` in the same folder. The earlier research made the same
  adjustment.
- Sources read: `docs/features/epics/documentation-estate-tooling/epic.md` (whole file), the earlier
  research, the 1023 folder (`spec.md`, `plan.2026-10-30T16-51.md`, research file), the 1021 research
  and spec, `.claude/skills/execution-environment/SKILL.md`, `.claude/rules/powershell.md`, and every
  repository file cited below.
- Q1 empirical input: the `Test-Json` behavior recorded in section 2 is the orchestrator probe,
  2026-10-30 (PowerShell 7.6.9, bundled JsonSchema.Net 7.0.0). The task-researcher tool set cannot
  run PowerShell; nothing in section 2 was re-measured here.
- Requirement origin: one consumer repository (epic `## Goal`). No identifier of that repository
  appears in this file.

## 0. Decisions in One Line Each

1. Q1: `DocsSchema.psm1` composes each schema in memory (copies docs-common `$defs` into the target,
   rewrites docs-common URN refs to local `#/$defs/common.<name>` refs, strips the root `$id`) and
   calls `Test-Json -Json -Schema` with the composed text; no `-FetchExternalReference`, no global
   schema registry, no per-file copies of shared definitions.
2. Docs schemas do not reference `schemas/discovery/v2/common.schema.json`; the definitions they
   need are copied into `schemas/docs/v1/common.schema.json`, and a Pester parity test pins the
   copied set to the discovery definitions.
3. Runtime schemas are read from `.claude/lib/docs/schemas/v1/` (a byte-identical copy of
   `schemas/docs/v1/`), located with literal `Join-Path -Path $PSScriptRoot -ChildPath '...'`
   joins; the canonical location stays `schemas/docs/v1/` (owner question OQ-1).
4. Eight production PowerShell files under `.claude/lib/docs/` (seven `Docs<Area>.psm1` modules plus
   `Invoke-DocsCommand.ps1`), adding two refinement modules `DocsJson.psm1` and `DocsFinding.psm1`
   to the epic file list.
5. Pure functions take in-memory strings and hashtables; all filesystem and clock access goes
   through one command-context object built only by `Invoke-DocsCommand.ps1`.
6. The dispatch table and the analyzer registry use owner-anchored slots: 1020 commits one anchor
   comment per later owner, and each child inserts its rows under its own anchor only.
7. Exit codes 0/1/2/3 and the `-Json` envelope `{command, exit_code, findings, ok, result}` are
   rendered as canonical JSON (sorted keys, compact, trailing LF) by `DocsFinding.psm1`.
8. Element identifiers are `<kind>-<sha256 hex>` over the canonical JSON of
   `{"declaration","kind","path"}` plus LF, computed with the existing
   `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` (`ConvertTo-DiscoveryCanonicalJson`).
9. JSON is parsed with `System.Text.Json` into ordinal hashtables (not `ConvertFrom-Json`), with
   duplicate-key detection.
10. The profile is JSON at `docs/documentation-estate/docs-profile.json`; YAML is rejected under A8.
11. Consumer configuration and the 900008 workflow template are delivered by
    `Invoke-DocsCommand.ps1 -Command init`, which copies template data shipped under
    `.claude/lib/docs/templates/` (dry run by default, create-only with `-Write`, overwrite only with
    `-Force`); no push-down root is added.
12. Push-down registration: append every `.claude/lib/docs/` file (PowerShell and data) to
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, mirror
    byte-identically, and add `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`.
13. The Codex tree is not changed by 1020 (owner question OQ-2 for 900009).
14. `quality-tiers.yml` gains `.claude/lib/docs` at tier T3 (owner question OQ-4); no change to
    `config/poshqc-coverage.json` or `config/poshqc-scan.json` is needed.
15. Destination PowerShell floor is 7.4 (owner question OQ-3).
16. The JSON envelope gets no schema file; Pester and 900007 Jest tests pin it.

## 1. Reuse of the Earlier Research

Kept, with the substitution rule below:

- `### 4.2 Docs common $defs` (all rows).
- `### 4.3 The six artifact schemas (field level)` (all field tables, `$defs/element`,
  `$defs/entry`, `$defs/row`, `$defs/dimension-result`, `$defs/pin`, companion rules, receipt
  counts and the AC-coverage paragraph). The profile dataclass paragraph is replaced by section 3.2
  (`DocsProfile.psm1`).
- `### 4.1 Schema identity and reference form (recommended)`: `$schema` dialect 2020-12, `$id`
  `urn:drm-copilot:docs:1.0.0:<name>`, the artifact header, closed objects, kebab-case `$defs`,
  snake_case properties, no nested `$id`, and the seventh file `common.schema.json`.
- `### 4.4 Surface element model and analyzer contract`: the identity rule, input constraints,
  per-kind `declaration` conventions, and the element/diagnostic shapes. The Python Protocol,
  dataclass and `importlib` details are replaced by section 3.
- `## 3. Behavior Semantics`: edge cases (empty file, invalid JSON, duplicate keys, unknown analyzer
  identifier, duplicate audience identifiers, unknown audience reference, directory mode outside the
  policy). The YAML edge case is dropped (section 4).
- `## Numeric Derivation Evidence` for the six artifact schemas, element kinds, dispositions,
  parity dimensions and front-matter fields.

Substitution rule: every reference written in the earlier research as "discovery `<name>`" or
`urn:drm-copilot:discovery:2.0.0:common#/$defs/<name>` becomes the docs-common definition
`urn:drm-copilot:docs:1.0.0:common#/$defs/<name>` (section 2.3). The artifact header `id` and
`extensions` therefore reference docs common.

Superseded and not reused: `### 1.3`, `### 1.4`, `### 1.5`, `### 2.1`, `### 2.2`, `### 2.3`,
`### 4.5`, `## 5`, `## 6`, `## Pre-Mortem`, `## 7` and `## 8` of the earlier research.

One further change to `### 4.1`: formats. `Test-Json` is not assumed to assert `format`
(Items to Confirm), so the docs-common `timestamp` keeps `format: date-time` and adds the pattern
`^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]{1,9})?Z$`. This is the only
deliberate divergence from the copied discovery definitions and is excluded from the parity test by
name.

## 2. Q1 Resolution: Schema References Under Test-Json

### 2.1 Facts

- Orchestrator probe, 2026-10-30 (PowerShell 7.6.9, JsonSchema.Net 7.0.0): a cross-file `$ref`
  (URN `urn:...:common#/$defs/x` or relative `common.schema.json#/$defs/x`, through `-Schema` or
  `-SchemaFile`) throws "The JSON schema contains a reference that could not be resolved. External
  schema references are not supported by default, use the 'FetchExternalReference' parameter to
  enable it." `-SchemaFile <main> -FetchExternalReference` resolved a relative-file ref.
  Registering the common schema through `[Json.Schema.SchemaRegistry]::Global.Register(...)` made a
  URN ref resolve. Inline `#/$defs/...` refs work. Draft-07 and 2020-12 both validate. A failing
  validation emits ErrorRecords with FullyQualifiedErrorId
  `InvalidJsonAgainstSchemaDetailed,Microsoft.PowerShell.Commands.TestJsonCommand` whose message
  ends with the instance pointer, for example `Required properties ["kind"] are not present at ''`
  and `Value should match one of the values specified by the enum at '/kind'`.
- Repository precedent: `.claude/lib/discovery-validation/DiscoveryValidation.psm1`
  (`Get-DiscoveryRuntimeVersionError`, `$script:MinimumPowerShellVersion = [version]'7.4'`) records
  that `Test-Json` Draft 2020-12 support arrived in PowerShell 7.4 (issue #475) and fails closed
  below that floor through an injectable `-PowerShellVersion` seam.
- `schemas/discovery/v2/` is not pushed down: the Claude push-down roots are `.claude` and `config`
  (`ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, the same
  tuple in `scripts/dev_tools/push_down_claude_customizations.py` and `PUBLISHED_ROOT_FOLDERS` in
  `scripts/dev_tools/skill_bundle_contract.py`), and no `*.schema.json` exists in the bundle other
  than `extensions/drm-copilot/resources/config/orchestration-handoff.schema.json`. A consumer
  repository therefore has no discovery common schema to reference.

### 2.2 Options compared

| Option | Works on any PowerShell 7.4+ `Test-Json` | Global state | Other cost |
|---|---|---|---|
| A. In-memory composition (selected) | Yes; relies only on inline `#/$defs` refs, which the probe confirmed | None | One pure function; refs in source files stay in the URN form of the earlier research |
| B. `-SchemaFile` with `-FetchExternalReference` | Unknown: parameter availability on 7.4/7.5 is unverified | None, but performs reference retrieval | URN refs cannot be fetched, so refs must change to relative files; tests must validate from on-disk files; a ref with an `http` base would trigger network retrieval |
| C. `SchemaRegistry.Global.Register` | Depends on the bundled JsonSchema.Net API, which changes between PowerShell releases | Process-global, mutable; re-registration behavior unverified | Violates `.claude/rules/powershell.md` "Avoid global state"; leaks between Pester suites in one process |
| D. Self-contained schema files (shared definitions copied into each of the six) | Yes | None | Six copies of shared vocabulary drift; needs a generator or a six-way parity test; larger files |

Decision: option A. Rationale: it is the only option that needs neither an unverified parameter nor
process-global state, it keeps one copy of the shared vocabulary (`common.schema.json` stays the
seventh schema, definitions only, `$id` `urn:drm-copilot:docs:1.0.0:common`), and it is a pure
function over strings, so tests run without files.

### 2.3 Composition contract (`Join-DocsSchemaText`)

Input: the target schema text and the docs-common schema text. Output: `@{ Text; Findings }`.

1. Parse both with `ConvertFrom-DocsJsonText` (section 3.9).
2. Copy every docs-common `$defs/<name>` into the target `$defs` as `common.<name>`. A target that
   already defines a `$defs` key beginning with `common.` yields `DOCS_SCHEMA_COMPOSITION_CONFLICT`.
3. Rewrite every string-valued `$ref` keyword:
   - `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>` becomes `#/$defs/common.<name>`; a `<name>`
     absent from docs common yields `DOCS_SCHEMA_REF_UNRESOLVED`;
   - inside the copied definitions, `#/$defs/<name>` becomes `#/$defs/common.<name>`;
   - a target-local ref beginning with `#` is unchanged;
   - any other ref (another URN, a file name, any URI scheme) yields `DOCS_SCHEMA_REF_UNRESOLVED`
     and is never fetched (fail closed).
   Only keys named `$ref` whose value is a string are rewritten; a `properties` member named
   `$schema` or `$ref` maps to an object and is not a keyword.
4. Remove the root `$id` from the composed text so that no `Test-Json` call can register a
   document in a JsonSchema.Net registry (see Items to Confirm). The root `$schema` keyword is kept
   for dialect selection.
5. Serialize with `ConvertTo-DocsJsonText` (deterministic key order).

Validation (`Test-DocsArtifactText`): `Test-Json -Json <instance text> -Schema <composed text>
-ErrorAction SilentlyContinue -ErrorVariable <var>`; each ErrorRecord becomes one finding through
`ConvertFrom-DocsSchemaErrorRecord`: code `DOCS_SCHEMA_INVALID`, severity `error`, `pointer` taken
from the final ` at '<pointer>'` of the message when present (otherwise empty), and `message` equal
to the record's exception message, which names the field (for a missing property, the property
name; for an enum failure, the pointer). Tests assert that the message contains the field name and
that the pointer is extracted; they do not assert the full JsonSchema.Net wording, which varies by
PowerShell release.

## 3. Module Design for `.claude/lib/docs/`

### 3.1 Files and import graph

All modules follow the conventions pinned by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`:
the help block contains the sentence token `imports its siblings with -ErrorAction Stop`,
`Set-StrictMode -Version Latest` is followed immediately by `$ErrorActionPreference = 'Stop'`, and
every column-0 `Import-Module` carries `-ErrorAction Stop`. Every `$PSScriptRoot` use is the literal
F2 form `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` (precedent
`.claude/lib/parallel-drift/ParallelDrift.psm1`, `'../blast-radius/BlastRadius.psm1'`), because
`test_every_psscriptroot_occurrence_is_recognized` and the closure test in
`tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (forms in
`tests/scripts/dev_tools/pack_manifest_dependency_scan.py`) accept only recognized literal forms and
require every target to be listed in core.

| File | Role | Imports (literal F2) |
|---|---|---|
| `DocsJson.psm1` (refinement) | System.Text.Json parsing, deterministic serialization, canonical JSON and SHA-256 | `../discovery-validation/DiscoveryEncoding.psm1` |
| `DocsFinding.psm1` (refinement) | Finding model, ordering, bound, command result, envelope and text rendering | `DocsJson.psm1` |
| `DocsSchema.psm1` | Schema table, schema reading, composition (Q1), artifact validation, version floor | `DocsJson.psm1`, `DocsFinding.psm1` |
| `DocsSurface.psm1` | Element kinds, path and revision grammar, stable and element identifiers, element and diagnostic records | `DocsJson.psm1`, `DocsFinding.psm1` |
| `DocsAnalyzerRegistry.psm1` | Analyzer contract, registration table, selection, captured inputs, invocation | `DocsSurface.psm1`, `DocsFinding.psm1` |
| `DocsProfile.psm1` | Profile parse, schema and semantic validation, starter profile | `DocsJson.psm1`, `DocsSchema.psm1`, `DocsFinding.psm1`, `DocsAnalyzerRegistry.psm1` |
| `DocsProfileCommands.psm1` | `init` and `validate-profile` command functions, init template table | `DocsProfile.psm1`, `DocsSchema.psm1`, `DocsFinding.psm1`, `DocsJson.psm1` |
| `Invoke-DocsCommand.ps1` | Entry script: parameters, dispatch table, argument parsing, real command context, output and exit | `DocsFinding.psm1`, `DocsJson.psm1`; command modules imported lazily from the selected row |

`DiscoveryEncoding.psm1` is already in the Claude `core.json` and the Codex virtual directory, so the
cross-area import is closed under core.

### 3.2 Exported functions and signatures

Parameter names are PascalCase; every function is an advanced function with `[CmdletBinding()]`.
"Pure" means no filesystem, clock, process, environment or module-scope mutable state.

`DocsJson.psm1` (pure):

- `ConvertFrom-DocsJsonText -Text <string> [-ArtifactPath <string>] [-MaxDepth <int> = 64]` returns
  `@{ Value; Findings }`. Objects become hashtables with the ordinal comparer, integers `Int64`,
  other numbers `Double`, strings unchanged (no DateTime coercion). A repeated property name yields
  `DOCS_JSON_DUPLICATE_KEY` at its pointer; malformed text yields `DOCS_JSON_INVALID`; excess depth
  yields `DOCS_JSON_TOO_DEEP`. Precedent: `ConvertFrom-ParallelDriftJsonElement` in
  `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`, whose help records why
  `ConvertFrom-Json` is unsuitable (timestamp-shaped strings become DateTime; integer and boolean
  distinctions are lost).
- `ConvertTo-DocsJsonText -Value <object> [-Indented]` returns text with ordinal key order at every
  depth, `UnsafeRelaxedJsonEscaping`, LF line endings (CRLF from `Utf8JsonWriter` on .NET 8 is
  normalized) and one trailing LF. Used for files a person reads (profile, artifacts).
- `ConvertTo-DocsCanonicalJson -Value <object>` delegates to `ConvertTo-DiscoveryCanonicalJson`
  (compact, sorted, safe integers only, trailing LF).
- `Get-DocsSha256Hex -Text <string>` and `Get-DocsBytesSha256Hex -Bytes <byte[]>` delegate to
  `Get-DiscoverySha256Hex` and `Get-DiscoveryBytesSha256Hex`.

`DocsFinding.psm1` (pure):

- `New-DocsFinding -Code <string> -Severity <error|warning|info> -Message <string> -NextAction
  <string> [-ArtifactPath <string>] [-Pointer <string> = ''] [-RelatedId <string[]>] [-RelatedPath
  <string[]>]` returns an ordered hashtable with exactly the eight keys of the docs-common `finding`
  definition. It enforces the code grammar `^[A-Z][A-Z0-9_]*$`, the RFC 6901 pointer grammar, the
  identifier grammar for related IDs and the relative-path grammar for paths, and sorts and
  de-duplicates both related lists (mirroring `Finding.__post_init__` in
  `packages/discovery-runtime/src/drm_copilot_discovery/findings.py`, a design reference only).
- `Get-DocsChildPointer -Pointer <string> -Part <object>` (escapes `~` and `/`).
- `Get-DocsOrderedFinding -Finding <object[]> [-Limit <int> = 100]` returns the findings sorted by
  the `finding_key` order (artifact path or empty, pointer, code, related IDs, related paths,
  severity, message, next action; ordinal comparison), de-duplicated and bounded, with one
  `FINDINGS_LIMIT` error marker when truncated (mirroring `FindingCollector`).
- `Test-DocsFindingHasError -Finding <object[]>`.
- `New-DocsCommandResult -Command <string> -ExitCode <0|1|2|3> -Finding <object[]> [-Result
  <object>] [-Line <string[]>]` returns `[pscustomobject]` with `Command`, `ExitCode`, `Findings`
  (ordered), `Result`, `Line` (command-specific text lines).
- `ConvertTo-DocsEnvelopeText -CommandResult <object>` returns the canonical JSON of
  `{command, exit_code, findings, ok, result}` with `ok` true exactly when `exit_code` is 0.
- `ConvertTo-DocsReportText -CommandResult <object>` returns one line per finding
  (`<severity> <code> <artifact_path><pointer>: <message>`, path omitted when null), the
  command-specific lines, and the summary line `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`
  (the text format in the 1023 `spec.md` `### Text format`).

`DocsSchema.psm1`:

- `Get-DocsSchemaName` (pure) returns the schema names in fixed order: `common`, `docs-profile`,
  `surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`,
  `docs-validation-receipt`; an anchor comment marks where 1021 appends `page-metadata`.
- `Get-DocsSchemaPath` returns an ordered map name to path built at module scope from one literal F2
  join per file, for example
  `Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-profile.schema.json'`.
- `Read-DocsSchemaSet [-SchemaPath <IDictionary>] [-ReadText <scriptblock>]` (I/O; the module's only
  read) returns name to text.
- `Join-DocsSchemaText -SchemaText <string> -CommonSchemaText <string>` (pure; section 2.3).
- `Get-DocsComposedSchemaSet -SchemaSet <IDictionary>` (pure) composes every artifact schema once per
  invocation; no module-scope cache.
- `Test-DocsArtifactText -ArtifactKind <string> -JsonText <string> -ComposedSchemaSet <IDictionary>
  [-ArtifactPath <string>]` (pure apart from the built-in `Test-Json`) returns findings: JSON parse
  findings first (duplicate keys, malformed text), then schema findings.
- `ConvertFrom-DocsSchemaErrorRecord -ErrorRecord <ErrorRecord> [-ArtifactPath <string>]` (pure).
- `Get-DocsRuntimeVersionError [-PowerShellVersion <version> = $PSVersionTable.PSVersion]` (pure)
  returns the fail-closed message below 7.4, otherwise `$null` (precedent
  `Get-DiscoveryRuntimeVersionError`).

`DocsSurface.psm1` (pure):

- `Get-DocsElementKind` returns the six kinds in contract order; `Test-DocsElementKind -Kind`.
- `Test-DocsRelativePath -Path` (port of `validate_finding_path`); `Test-DocsFullRevision -Revision`
  (40 or 64 lowercase hex).
- `Get-DocsStableId -Prefix <string> -Value <object>` returns `<prefix>-` plus the SHA-256 of the
  canonical JSON of `Value` (port of `stable_id` in
  `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py`).
- `Get-DocsElementId -Kind <string> -Path <string> -Declaration <string>` (section 3.8).
- `Test-DocsElementId -ElementId <string>`.
- `New-DocsSurfaceElement -Kind -Path -Declaration -Name -AnalyzerId -SourceSha256 [-ParentId]
  [-LineRange <int[]>] [-Property <IDictionary>] [-Extension <IDictionary>]` returns an ordered
  hashtable in the snapshot `element` shape with a recomputed `element_id`; `cli-option` requires a
  `cli-command-` parent.
- `ConvertFrom-DocsSurfaceElement -Record <IDictionary>` (the inverse 1023 needs; the earlier
  1023 research `### 1.1` recorded its absence as a gap) re-verifies `element_id` and throws
  `DOCS_ELEMENT_ID_MISMATCH` on a tampered record.
- `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Blocking <bool> = $true]` returns the docs
  `diagnostic` shape with `id` = `Get-DocsStableId -Prefix 'diagnostic' -Value @{ analyzer; code;
  path }` and severity `error` when blocking, else `warning` (port of `diagnostic` in the same
  Python module).

`DocsAnalyzerRegistry.psm1`:

- `Get-DocsAnalyzerRegistration` (pure) returns the committed registration rows (section 3.6).
- `Test-DocsAnalyzerRegistration -Registration <object[]>` (pure) returns findings: unique `Id`,
  identifier grammar, non-empty `ElementKinds` within `Get-DocsElementKind`, `Module` resolving
  inside `.claude/lib/docs/` with a `DocsAnalyzer*.psm1` leaf, `Function` matching
  `^Invoke-DocsAnalyzer[A-Za-z]+$`, non-blank `Version`.
- `Select-DocsAnalyzerRegistration -Registration <object[]> -ElementKind <string[]> [-AnalyzerId
  <string[]>]` (pure) validates the whole request before any import, returns rows sorted by `Id`,
  and reports an unknown identifier as `DOCS_ANALYZER_UNKNOWN`.
- `New-DocsCapturedInput -Path <string> -Bytes <byte[]> [-MaxBytes <int>]` (pure) returns
  `@{ path; sha256; size; text; diagnostic }`; strict UTF-8 decoding; an oversize or undecodable
  input carries a diagnostic and `text` `$null`.
- `Invoke-DocsAnalyzer -Registration <object> -CapturedInput <object[]> -Selection <object>
  [-ImportModule <scriptblock>]` imports the module through the seam (default
  `Import-Module -Name <path> -Force -ErrorAction Stop`), calls the analyzer function, and validates
  its output (kinds within the registration, `analyzer_id` equal to `Id`, recomputed element IDs);
  output is `@{ Elements; Diagnostics }` sorted by identifier.
- Analyzer function contract (for 900003/900004): `Invoke-DocsAnalyzer<Name> -CapturedInput
  <object[]> -Selection <object>` returns `@{ Elements = @(...); Diagnostics = @(...) }`; pure,
  deterministic, no I/O, inputs not mutated, unclassifiable or oversize input produces a diagnostic.

`DocsProfile.psm1`:

- `Get-DocsDefaultProfilePath` returns `docs/documentation-estate/docs-profile.json`.
- `ConvertFrom-DocsProfileText -Text <string> -ArtifactPath <string> -ComposedSchemaSet
  <IDictionary> [-AnalyzerId <string[]>]` (pure) returns `@{ Profile; Findings; Ok }`: parse, then
  schema, then semantics. `Profile` is the parsed ordinal hashtable with the snake_case JSON keys
  (`artifact_paths`, `completion_gates`, `page_owners`, `documentation_roots`, and so on), `$null`
  when parse or schema validation fails.
- `Test-DocsProfileSemantic -Profile <IDictionary> -AnalyzerId <string[]>` (pure): unique audience
  and root identifiers, audience references resolve, directory modes within
  `diataxis_policy.modes`, analyzer identifiers registered.
- `New-DocsStarterProfile [-RepositoryId <string> = 'repository']` (pure) returns a profile that
  passes `ConvertFrom-DocsProfileText`.

`DocsProfileCommands.psm1`:

- `Invoke-DocsInitCommand -Argument <IDictionary> -Context <object>` (options `RepositoryId`,
  `Profile`, `Write`, `Force`).
- `Invoke-DocsValidateProfileCommand -Argument <IDictionary> -Context <object>` (option `Profile`).
- `Get-DocsInitTemplate` (pure) returns the template table (section 5).

`Invoke-DocsCommand.ps1`:

- Parameters: `-Command <string>`, `-Json` (switch), `-Help` (switch), `-RepositoryRoot <string>`,
  and `[Parameter(ValueFromRemainingArguments = $true)] [string[]] $CommandArgument`;
  `[CmdletBinding(PositionalBinding = $false)]`; no Mandatory parameter, so a missing `-Command`
  exits 2 instead of prompting (precedent `Invoke-ParallelDriftDetection.ps1`).
- Functions: `Get-DocsCommandTable`, `ConvertFrom-DocsCommandArgument -CommandArgument <string[]>
  -OptionSpec <IDictionary>`, `New-DocsCommandContext -RepositoryRoot <string>`,
  `Write-DocsFileText` (wrapper seam for the only write primitive), and
  `Invoke-DocsCommandCli -Command -Json -Help -RepositoryRoot -CommandArgument [-Context]` returning
  `@{ ExitCode; Stdout; Stderr }`.
- Guard: `if ($MyInvocation.InvocationName -ne '.') { ... exit $outcome.ExitCode }`, so Pester
  dot-sources the script to load its functions without running it.

### 3.3 Pure versus I/O and the command context

- Every command function receives `-Context`, a `[pscustomobject]` with `RepositoryRoot`,
  `ReadText` (`param($RelativePath)`; throws an item-not-found error for an absent file), `ReadBytes`,
  `TestFile`, `ListFile` (`param($RelativeRoot)`; sorted relative POSIX paths), `WriteText`
  (`param($RelativePath, $Text, $Mode)` with `Mode` `create` or `overwrite`; UTF-8 without BOM, LF),
  and `UtcNow`.
- Only `New-DocsCommandContext` in `Invoke-DocsCommand.ps1` builds the real context; tests build a
  context whose scriptblocks read and write an in-memory hashtable of path to text. No test creates
  a temporary file.
- Relative paths are checked with `Test-DocsRelativePath` before any context call; a non-relative
  path is a usage error (exit 2).
- Repository root: `-RepositoryRoot` if given, else the current location. It is not derived from
  `$PSScriptRoot`: the lib sits three levels below the root, and no recognized non-dependency form
  in `pack_manifest_dependency_scan.py` covers a three-level parent chain. 900007 starts the script
  with the workspace root as working directory.
- Write primitive scope: `Write-DocsFileText` (used by `WriteText`) is the only filesystem write in
  1020. 1023's single-write-boundary test must allowlist it with the reason "init create-only and
  explicit overwrite"; 1023 adds its own boundary in `DocsLedgerMutation.psm1`.

### 3.4 Runtime location of schemas

- `DocsSchema.psm1` reads from `.claude/lib/docs/schemas/v1/`, resolved from `$PSScriptRoot` with one
  literal F2 join per schema file. The same code path runs in this repository and in a consumer.
- Each join target must be listed in core (closure test), which makes the closure test a guard that
  every runtime schema ships.
- Canonical schemas stay at `schemas/docs/v1/` (naming contract); `.claude/lib/docs/schemas/v1/` is
  a byte-identical runtime copy pinned by a Pester test (section 12), and the bundle copy under
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/` is pinned
  by the existing Python parity test and `Docs.Manifest.Tests.ps1`.
- Rejected: adding `schemas` to the push-down roots (three root tuples to edit, changes the
  enumeration-order contract, and would publish discovery schemas or need new filtering); reading
  `schemas/docs/v1/` from the consumer root (absent in a consumer). Moving the canonical location
  is a naming-contract change and is raised as OQ-1.

### 3.5 Dispatch table (owner-anchored slots)

`Get-DocsCommandTable` returns an array built from literal rows. Form:

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

- Each child inserts its rows directly under its own anchor and never edits another anchor or row.
  Because unchanged anchor lines separate the insertion points, parallel wave-1 branches merge
  without textual conflict in the common case; any conflict that remains is resolved in the child's
  remediation loop (epic `### Cross-feature conflict surface`).
- One row per line; `Module` uses the literal F2 join so the closure scanner sees every command
  module; the module is imported only when its row is selected.
- `Option` maps a PascalCase option name to `value`, `multi` (repeatable) or `switch`. The names
  `Command`, `Json`, `Help` and `RepositoryRoot` are reserved. `Test-DocsCommandTable` (pure, in the
  entry script) rejects duplicate names, reserved option names and a `Function` outside
  `^Invoke-Docs[A-Za-z]+Command$`; a Pester test runs it over the committed table.
- Command function contract: `Invoke-Docs<Area>Command -Argument <IDictionary> -Context <object>`
  returns the object from `New-DocsCommandResult`. Usage errors are detected by
  `ConvertFrom-DocsCommandArgument` before the command function runs.

### 3.6 Analyzer registry (owner-anchored slots)

`DocsAnalyzerRegistry.psm1` holds:

```powershell
$script:DocsAnalyzerRow = @(
    # --- 900003: Python and configuration analyzers ---
    # --- 900004: TypeScript and .NET analyzers ---
)
```

Row form: `[pscustomobject]@{ Id = '<identifier>'; Version = '1.0.0'; ElementKinds = @('<kind>', ...);
Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzer<Name>.psm1'); Function =
'Invoke-DocsAnalyzer<Name>' }`. Profiles select identifiers only; no profile names a module. 1020
commits an empty registry; `Test-DocsAnalyzerRegistration` over the committed rows yields no
findings.

### 3.7 Exit codes and envelope

| Code | Meaning in every subcommand |
|---|---|
| 0 | Success or help; no `error` finding |
| 1 | Findings: at least one `error` finding, or a command-specific failure condition (for example an absent profile, `DOCS_PROFILE_MISSING`) |
| 2 | Usage or input error detected before any read: missing or unknown `-Command`, unknown option, missing value, repeated non-`multi` option, value outside the option grammar, non-relative path; `findings` holds exactly one `DOCS_CLI_ARGUMENTS`; `result` is null |
| 3 | Internal, environment or I/O error: PowerShell below 7.4 (`DOCS_RUNTIME_UNSUPPORTED`), a read failure other than absence, unreadable runtime schemas, or any unexpected exception caught at the entry boundary (`DOCS_CLI_RUNTIME`); `findings` holds exactly one finding (1023 may use `DOCS_MUTATION_FAILED`); `result` is null |

- `-Json`: stdout receives exactly one document, `ConvertTo-DocsEnvelopeText` output. `command` is
  the subcommand name (`validate-profile`, not a console-script name). Identical inputs, arguments
  and clock value give identical bytes.
- Without `-Json`: `ConvertTo-DocsReportText` output on stdout. On exit 3 one fixed line is also
  written to stderr.
- `-Help` (or no `-Command`): usage text listing the table rows; reads no input; exit 0 for `-Help`,
  exit 2 for a missing `-Command`.
- `validate-profile` result: `{profile_path, repository_id}` on exit 0 or 1 with a parsed profile,
  `null` otherwise. `init` result: `{profile, planned_writes[{path, action}]}` with `action`
  `create`, `overwrite` or `exists`.

### 3.8 Deterministic element identifiers

- Rule (mirrors the discovery findings identity, `stable_id` in
  `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py` and `canonical_json`
  in `packages/discovery-runtime/src/drm_copilot_discovery/models.py`, cited as design references
  only): `element_id = <kind> + "-" + lowercase hex SHA-256 of UTF-8 bytes of
  canonical_json({"declaration": D, "kind": K, "path": P}) + "\n"`.
- PowerShell computation: `Get-DocsStableId -Prefix $Kind -Value ([ordered]@{ kind = $Kind; path =
  $Path; declaration = $Declaration })`, which calls `ConvertTo-DiscoveryCanonicalJson` (ordinal key
  order, escapes only `"`, `\` and C0 controls, non-ASCII literal, trailing LF) and
  `Get-DiscoverySha256Hex`. `DiscoveryEncoding.psm1` documents byte agreement with the Python
  runtime and the TypeScript gateway.
- Input validation before hashing: `Kind` in the six kinds; `Path` passes `Test-DocsRelativePath`;
  `Declaration` non-blank, no leading or trailing whitespace, no C0 controls, and no unpaired UTF-16
  surrogate (Python raises on encoding one, while `[System.Text.Encoding]::UTF8` would silently
  substitute U+FFFD; the check uses a throwing `UTF8Encoding`). No Unicode normalization.
- `DiscoveryEncoding.psm1` throws `AUTHORIZATION_INPUT_INVALID: ...` for non-JSON values;
  `Get-DocsStableId` catches it and rethrows as `DOCS_IDENTITY_INPUT_INVALID: ...`.

### 3.9 JSON reading and writing rules

- Reading: UTF-8, a leading BOM stripped by the context reader, `ConvertFrom-DocsJsonText` for every
  document. `Test-Json` receives the original text (after BOM removal), never a re-serialized value.
- Writing: `ConvertTo-DocsJsonText -Indented` for files; `ConvertTo-DocsCanonicalJson` for digests,
  identifiers and the envelope.

## 4. Profile File Format and Path

- Decision: JSON only. The profile path a consumer uses is `docs/documentation-estate/docs-profile.json`
  (the default already assumed in the 1023 `spec.md` common options table); `-Profile <relative
  path>` overrides it.
- YAML rejected: PowerShell 7 has no built-in YAML parser, and epic assumption A8 forbids a new
  third-party module. The earlier research's YAML edge case and `format` argument are dropped.
- Parsing uses System.Text.Json, not `ConvertFrom-Json`, for the reasons in section 3.2
  (`DocsJson.psm1`); this keeps "PowerShell 7 built-ins only" (A8).

## 5. Consumer Configuration and Workflow Template Delivery

Evidence:

- The Claude push-down publishes only `.claude` and `config` (`ROOT_FOLDERS`, three copies cited in
  section 2.1); the Copilot push-down publishes `.github/agents`, `.github/hooks`,
  `.github/instructions`, `.github/prompts` and `.github/skills` (`COPILOT_ROOT_FOLDERS` in
  `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts`). No root reaches
  `.github/workflows/` or a repository-root dotfile.
- Every published file is a plain overwrite except the two decorated `config/` paths
  (`DESTINATION_WRITE_DECORATORS` and `MERGED_RELATIVE_PATHS` in `claude-customizations.ts`), so a
  consumer-owned file delivered by push-down (profile, vocabulary, workflow) would be overwritten on
  every push.
- `extensions/drm-copilot/resources/templates/` is not a push-down root (epic
  `### Decisions carried from the first preparation of 1020 and 1021`).

Decision: `Invoke-DocsCommand.ps1 -Command init` delivers consumer configuration.

- Template data ships under `.claude/lib/docs/templates/` (pushed down with the lib, listed in core,
  mirrored byte-identically). `Get-DocsInitTemplate` returns an owner-anchored table of rows
  `[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/<file>');
  Destination = '<consumer-relative path>' }`, with anchors `# --- 1021: page-check configuration ---`
  and `# --- 900008: docs workflow ---`. 1020 commits the mechanism with no template rows; the
  profile is generated by `New-DocsStarterProfile`, not copied.
- Behavior: without `-Write`, `init` reads nothing but the destination existence checks, writes
  nothing, and returns the starter profile and the planned writes (exit 0). With `-Write`, every
  destination is checked first; if any exists and `-Force` is absent, the command exits 1 with one
  `DOCS_INIT_TARGET_EXISTS` finding per existing path and writes nothing; otherwise it writes each
  file (`create`, or `overwrite` under `-Force`).
- 1021 and 900008 follow this: their files are template data under `.claude/lib/docs/templates/`,
  added to core and the bundle, with one `Get-DocsInitTemplate` row each.
- Owner question OQ-5 records that `init -Write` writes into `.github/workflows/` of the consumer.

## 6. Push-Down Mirror Mechanism and Parity Tests

- Mirror: every file under `.claude/lib/docs/` (PowerShell, `schemas/v1/*.schema.json`, later
  `templates/*`) has a byte-identical copy under
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`. Precedent:
  `.claude/lib/mermaid/` and its bundle copy, listed in core.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  (`paths`), which already lists `.claude/lib/mermaid/*.psm1` and
  `.claude/lib/discovery-validation/DiscoveryEncoding.psm1`. With an explicit pack selection, only
  manifest-listed paths are published (`computePublishedPaths` in
  `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts`), so data files must be
  listed as well as modules.
- Existing contract tests (execution-environment `## Contract Tests That Pin Mirrored Files`) that
  see the new files:
  - `test_push_down_claude_resource_contracts.py`
    (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`): every distributable file
    under `.claude/` (filter `filter_distributable_claude_paths` in
    `tests/scripts/dev_tools/claude_payload_scope_test_support.py`) must exist in the bundle with
    equal text, including the schema copies.
  - `test_push_down_pack_manifest_dependency_closure.py`: every literal `$PSScriptRoot` target of a
    manifested PowerShell file (modules, command rows, schema and template data) must be in core;
    `test_every_psscriptroot_occurrence_is_recognized` rejects a non-literal `$PSScriptRoot` use.
  - `test_push_down_claude_pack_manifest_completeness.py` enumerates bundled agents, hooks and
    skills only (`enumerate_bundled_claude_relative_paths`), so it does not check lib files; the
    per-area Pester manifest test below is the required guard.
  - Not affected: the Codex completeness test, the Codex generator check, rules frontmatter,
    `test_push_down_issue_824_follow_ups.py` (rules and skills), hook guard tests.
- New Pester guard `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`, modeled on
  `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Manifest.Tests.ps1`, but discovering
  every file under `.claude/lib/docs/` recursively (not only `.ps1`/`.psm1`): each is listed exactly
  once in core, has a bundle counterpart, and is SHA-256 identical to it.
- Schemas tree: `schemas/` is not and cannot become a push-down root without the root-tuple edits
  in section 3.4; runtime copies therefore sit under `.claude/lib/docs/schemas/v1/` (OQ-1).

## 7. Codex Customization Tree

- The Codex/agents push-down publishes `.codex`, `.agents` and virtual destinations
  (`ROOT_FOLDERS`, `VIRTUAL_RESOURCE_PAIRS`, `VIRTUAL_RESOURCE_DIRECTORIES` and
  `VIRTUAL_ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`,
  mirrored in `scripts/dev_tools/push_down_codex_and_agents_customizations.py`). Libraries are
  carried as virtual resources stored once under `extensions/drm-copilot/resources/lib/<area>/`:
  `.codex/lib/codex-routing/` (three pairs) and `.codex/lib/discovery-validation/` (one directory
  pair). There is no `.codex/lib/` in the repository tree.
- 1020 adds no Codex hook, skill or agent that calls the docs lib, so no Codex mirror is needed for
  1020's acceptance criteria.
- 900009 mirrors skills to `.agents/skills/`. A Codex-only consumer would lack
  `.claude/lib/docs/Invoke-DocsCommand.ps1`. Publishing `.codex/lib/docs/` needs a new
  `VIRTUAL_RESOURCE_DIRECTORIES` entry (TypeScript, extension command, permitted) plus the matching
  in-place edit of the existing Python twin and a different path in Codex skill text. This is raised
  as OQ-2 rather than decided.

## 8. Quality Tiers and PoshQC Configuration

- `quality-tiers.yml` covers `.claude/lib`: rule R4 in `scripts/dev_tools/quality_tiers_contract.py`
  discovers every `.claude/lib/<name>` folder holding any file at any depth, so
  `.claude/lib/docs/schemas/v1/` does not create a second project. Without an entry,
  `check_quality_tiers` reports `QT008` in `quality-checks7 / Code Quality & Tests (<version>)`.
- Schema: `version: 1`, `projects[]` with `path`, `tier`, `rationale` (`ENTRY_KEYS`).
- Entry to add: `path: ".claude/lib/docs"`, `tier: T3`, `rationale: "Runtime library shipped in the
  `.claude` bundle; documentation profile, schemas and command entry"`. T3 matches every existing
  `.claude/lib/*` entry and leaves
  `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
  (`test_committed_quality_tiers_yml_assigns_spec_tiers`, which permits only
  `packages/discovery-runtime` at T1/T2) unchanged; `test_committed_quality_tiers_yml_matches_live_tree`
  passes once the folder exists. T2 is OQ-4.
- `config/poshqc-coverage.json` already lists `.claude/lib` in `roots`, and `config/poshqc-scan.json`
  already scans `tests/scripts`; no edit is needed. New suites are assigned to
  `poshqc / PowerShell QC shard 1`, `shard 2` or `shard 3` (windows-latest) automatically, measured
  with coverage, merged by `poshqc / PowerShell QC` (required context), and statically checked by
  `poshqc / PowerShell QC static`. `poshqc / PowerShell hook suites (Linux)` runs only
  `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, so docs suites run on Windows only.

## 9. Neutrality Test Design

- File: `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1`.
- Digest list: a test-module constant `$script:ConsumerIdentifierSha256` holding lowercase hex SHA-256
  digests of the lowercase identifier forms to ban. Text forms are never written. The values are
  supplied by the orchestrator or owner (Items to Confirm).
- Scan scope (read-only `Get-Content -Raw` over committed files, held in memory): every file under
  `.claude/lib/docs/` (modules, entry script, schema copies, templates) and `schemas/docs/`; also
  `examples/docs/` (beyond the AC minimum). The bundle copy is byte-identical and need not be
  scanned twice.
- Pure helper in the test module: `Find-DocsIdentifierDigest -FileText <IDictionary> -Digest
  <string[]>` lowercases each text, enumerates candidate tokens from two tokenizations (maximal
  `[a-z0-9]+` runs and maximal `[a-z0-9]+(?:[-_.][a-z0-9]+)+` compounds), hashes each candidate
  with `Get-DocsSha256Hex`, and returns `(path, digest)` pairs.
- Tests: one parametrized `It` per scanned file asserting no match; a positive control that injects
  a synthetic identifier into an in-memory map with its digest computed in the test and asserts it
  is found; a guard that the digest list is non-empty and every entry matches `^[0-9a-f]{64}$`.

## 10. Artifact Classification Table

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and extension commands); D = epic
`### Artifact classes for this epic` (data rows and test rows); "Avoid new Python" applies to all.

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
| `.claude/lib/docs/schemas/v1/*.schema.json` (seven runtime copies) | schema/config/data (pushed down) | JSON | D; location is OQ-1 |
| bundle copies of the fifteen files above under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` | pushed-down helper/lib and data (mirror) | PowerShell, JSON | R1, D |
| `schemas/docs/v1/common.schema.json` and the six artifact schemas | schema/config/data | JSON | D |
| `examples/docs/v1/<name>.example.json` (six) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `quality-tiers.yml` (edit) | schema/config/data | YAML | D |
| `tests/scripts/claude-lib/docs/*.Tests.ps1` and one `*.TestSupport.psm1` fixture | test | PowerShell (Pester) | D |

No MCP tool, extension command, hook, skill, agent, Python file or TypeScript file is created or
edited. No artifact is outside the rule; the two placement questions (OQ-1, OQ-2) concern location,
not language.

## 11. Batch Budget

- Production PowerShell files: eight under `.claude/lib/docs/` plus eight bundle copies = sixteen
  (bundle copies count, per execution-environment `## Batch Budget`). JSON and YAML files are not
  counted by `.claude/hooks/enforce-powershell-batch-budget.ps1` or the Python twin; test files never
  count.
- Sixteen exceeds the direct-mode cap of three. Execution runs in the item worktree whose
  `artifacts/orchestration/orchestrator-state.json` selects the `preparation` or `large` route and is
  not terminal (`Test-BatchBudgetLargePathRoute` in `.claude/hooks/enforce-batch-budget-route.ps1`),
  never in an isolated executor worktree (no checkpoint there, because `artifacts/` is gitignored).
- Bundle copies written by a copy step through Bash are not seen by the hook (matcher `Write|Edit`);
  the plan still treats them as production files for review and parity.

## 12. Testing Implications

Pester suites under `tests/scripts/claude-lib/docs/`:

| Suite | Covers |
|---|---|
| `DocsJson.Tests.ps1` | ordinal objects, Int64/Double, no DateTime coercion, duplicate keys, malformed text, depth bound, LF normalization, canonical delegation |
| `DocsFinding.Tests.ps1` | grammar checks, ordering, de-duplication, bound and `FINDINGS_LIMIT`, envelope keys and `ok`, text format and summary line |
| `DocsSchema.Tests.ps1` | composition (ref rewrite, conflict, unresolved and foreign refs fail closed, `$id` removal), error-record mapping, version floor seam |
| `DocsSchemaContract.Tests.ps1` | every example validates; per artifact schema, a deleted required field and an unknown kind or disposition each fail; runtime copies equal `schemas/docs/v1/` bytes; copied docs-common definitions equal the discovery v2 definitions (canonical JSON), except `timestamp` by name; schema text stays within the 500-line guidance |
| `DocsSurface.Tests.ps1` | kind and path grammar, identity determinism over a seeded `[System.Random]` input set (seed printed on failure), injectivity over enumerated boundary cases, golden vectors (canonical string literal and hex), surrogate rejection, element inverse and tamper detection, diagnostic identity |
| `DocsAnalyzerRegistry.Tests.ps1` | registration validation, selection before import, captured input bounds and decoding, invocation through a committed fixture module with output validation, empty committed registry yields no findings |
| `DocsProfile.Tests.ps1` | parse, schema and semantic findings with pointers, starter profile validity for several repository identifiers |
| `DocsProfileCommands.Tests.ps1` | `init` dry run, `-Write` create, existing target refusal, `-Force`; `validate-profile` exit 0, exit 1 naming the field, absent profile |
| `Invoke-DocsCommand.Tests.ps1` | dot-sourced functions: table validation, argument parsing (exit 2 cases), exit 0/1/2/3 mapping, `-Json` byte determinism, help; `Write-DocsFileText` mocked; real `ReadText` exercised against a committed example file |
| `Docs.Manifest.Tests.ps1` | core membership and bundle byte identity for every `.claude/lib/docs/` file |
| `DocsNeutrality.Tests.ps1` | section 9 |

- Golden identity vectors: the test asserts the exact canonical string for each vector and the hex
  digest recorded once from an independent hash of that string (for example `sha256sum` over the
  literal bytes in a `sh` script under `SCRATCH`, recorded in evidence). The values are listed in
  Items to Confirm because they cannot be computed by this researcher.
- Coverage: Pester line coverage >= 85% per file for `.claude/lib/docs/`, read from
  `artifacts/pester/powershell-coverage.xml` written by `Invoke-PoshQCTest`
  (`scripts/powershell/PoshQC/PoshQC.psd1`); no branch gate for Pester; no production file excluded.
  The entry script's top-level guarded block is the expected residual.
- Isolation: a seeded shuffled file-order run of the docs suites in one process with at least three
  seeds (each seed and order recorded), plus a fresh single-process run over `tests/scripts`, both
  under `<FEATURE>/evidence/regression-testing/`. Suites remove the `Docs*` modules in `AfterAll`;
  dot-sourcing the entry script imports modules into the test session, so `AfterAll` must remove
  them as well.
- CI jobs: `poshqc / PowerShell QC static`, `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3`,
  aggregator `poshqc / PowerShell QC`; Python contract tests and the tier check run in
  `quality-checks7 / Code Quality & Tests (3.10)` through `(3.13)`.

## 13. Contracts 1023 Assumes That 1020 Must Provide

The 1023 folder in this worktree (`spec.md`, `plan.2026-10-30T16-51.md`, research) still describes
the withdrawn Python design; its re-preparation is not visible here (Items to Confirm). Its plan also
cites epic headings that no longer exist (`### Decisions recorded during preparation of 1020 (binding
on later children)`, `### 900005 - docs-coverage-ledger-and-receipt (wave 1, C4)`). The
language-independent contracts it relies on map to 1020 as follows:

| 1023 assumption (Python name) | 1020 PowerShell provision |
|---|---|
| `element_identifier`, `SurfaceElement`, `element_to_json`, missing inverse | `Get-DocsElementId`, `New-DocsSurfaceElement`, `ConvertFrom-DocsSurfaceElement` |
| `stable_id(prefix, row(...))` for pin and receipt identifiers | `Get-DocsStableId -Prefix -Value` |
| `canonical_json`, SHA-256 of raw bytes | `ConvertTo-DocsCanonicalJson`, `Get-DocsBytesSha256Hex` |
| `parse_document` with duplicate-key detection | `ConvertFrom-DocsJsonText` |
| `validate_artifact(value, artifact_kind, artifact_path, resources)` | `Test-DocsArtifactText -ArtifactKind -JsonText -ComposedSchemaSet -ArtifactPath`; tests pass composed sets built from committed schema text |
| `Finding`, `FindingCollector` (limit 100, `FINDINGS_LIMIT`), `child_pointer`, `validate_finding_path`, `is_full_revision` | `New-DocsFinding`, `Get-DocsOrderedFinding`, `Get-DocsChildPointer`, `Test-DocsRelativePath`, `Test-DocsFullRevision` |
| `parse_profile`, `ArtifactPaths`, `CompletionGates`, `DocsCompleteGate`, `PageOwner` | `ConvertFrom-DocsProfileText`; keys `artifact_paths.{inventory_snapshot, coverage_ledger, parity_matrix, evidence_pins, validation_receipt}`, `completion_gates.docs_complete.{allow_deferred, max_stale_pages, required_parity_dimensions}`, `page_owners[{path_or_glob, owner}]`, `documentation_roots` |
| Ports `read_bytes`, `list_pages`, `store`, `clock` | Context members `ReadBytes`, `ReadText`, `ListFile`, `WriteText`, `UtcNow`; 1023 adds its own write boundary module |
| Exit codes 0/1/2/3, envelope `{command, ok, exit_code, findings, result}`, text format, `DOCS_CLI_ARGUMENTS`, `DOCS_CLI_RUNTIME` | Section 3.7, rendered by `DocsFinding.psm1`; `command` is the subcommand name; `--format json` becomes `-Json` |
| Receipt `writer.tool` const `drm-copilot-docs` | Unchanged in `docs-validation-receipt.schema.json` |
| Default profile path `docs/documentation-estate/docs-profile.json` | `Get-DocsDefaultProfilePath` |
| Dispatch rows for `coverage`, `update-ledger`, `validate` | Anchor `# --- 1023: coverage, update-ledger, validate ---` |

## 14. Decisions Later Children Must Honor

- Add command modules as `Docs<Area>Commands.psm1` or the epic-named module, and register by
  inserting rows under the child's own anchor in `Invoke-DocsCommand.ps1` only (1021, 900003, 1023,
  900006, 900008).
- Analyzer rows go under the child's anchor in `DocsAnalyzerRegistry.psm1` (900003, 900004);
  analyzers follow the `Invoke-DocsAnalyzer<Name> -CapturedInput -Selection` contract and are pure.
- Use only literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` for sibling modules and
  data; list every new `.claude/lib/docs/` file (PowerShell and data) in Claude `core.json`, mirror
  it byte-identically, and keep `Docs.Manifest.Tests.ps1` green (every child).
- New schemas (1021 `page-metadata.schema.json`) go to `schemas/docs/v1/` and the runtime copy under
  `.claude/lib/docs/schemas/v1/`, with a `Get-DocsSchemaPath` row; shared definitions are referenced
  through `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>`; no ref to discovery schemas.
- Parse JSON with `ConvertFrom-DocsJsonText`; never `ConvertFrom-Json` for artifacts.
- Build findings with `New-DocsFinding` and results with `New-DocsCommandResult`; never print output
  or call `exit` inside a command module.
- No filesystem, clock or process access outside the command context; tests use in-memory contexts
  and create no temporary files.
- Consumer configuration and workflow templates ship as data under `.claude/lib/docs/templates/` and
  are delivered by `init` through one `Get-DocsInitTemplate` row (1021, 900008); no push-down root
  and no file under `extensions/drm-copilot/resources/templates/`.
- 900007 invokes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name>
  -Json ...` with the workspace root as working directory and parses the envelope; it adds no logic.
- 1023's write-boundary allowlist includes `Write-DocsFileText` in `Invoke-DocsCommand.ps1` (init).
- 900009 skills call `Invoke-DocsCommand.ps1` or the MCP tools; Codex reachability follows OQ-2.
- 900010 states PowerShell 7.4 as the destination prerequisite (OQ-3).

## Numeric Derivation Evidence

The count below supports the batch-budget statement in section 11; it is not a `spec.md`
acceptance-criterion count.

- Complete Family: DocsJson.psm1, DocsFinding.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfile.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1
- Exhaustive Search Scope: entire worktree, every production PowerShell file this addendum proposes under `.claude/lib/docs/`, compared against the epic 1020 file list
- Inclusion Rules: `.ps1` and `.psm1` files created under `.claude/lib/docs/` by 1020
- Exclusion Rules: test files, data files (`.json`, `.yml`), bundle copies (counted separately as an equal second set), files owned by later children
- Primary Search Strategy or Query Expression: enumerate the rows of the section 3.1 file table (DocsJson.psm1, DocsFinding.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfile.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1)
- Primary Member Set: DocsJson.psm1, DocsFinding.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfile.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: take the epic `### 1020 - docs-profile-and-artifact-schemas` Files (create) list (DocsProfile.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1) and add the refinements stated in section 0 decision 4 (DocsJson.psm1, DocsFinding.psm1), then compare with the PowerShell rows of the section 10 classification table
- Cross-check Member Set: DocsProfile.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1, DocsJson.psm1, DocsFinding.psm1
- Cross-check Count: 8
- Member-set Comparison: the normalized primary and cross-check member sets are equal; with eight byte-identical bundle copies the production PowerShell total is sixteen

## Pre-Mortem

- Review checklists: a reviewer can flag a `$PSScriptRoot` use outside the literal forms, a command module that prints or exits, a production file excluded from coverage, or a schema that does not reject an unknown kind or disposition; the plan must carry the closure and recognized-form tests, the command-result contract test, per-file coverage evidence, and one rejection test per artifact schema in `DocsSchemaContract.Tests.ps1`.
- Coverage: the entry script and the real context factory could fall below 85% line coverage; the plan must keep the script thin, dot-source it in tests, wrap the write primitive in `Write-DocsFileText` and mock it, exercise `ReadText` against a committed example, and read per-file figures from `artifacts/pester/powershell-coverage.xml` (no branch gate for Pester).
- Mirror parity: every `.claude/lib/docs/` file, including the seven schema copies, must be listed in Claude `core.json` and byte-identical in the bundle, and the runtime schema copies must equal `schemas/docs/v1/`; the plan must run `test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py`, `Docs.Manifest.Tests.ps1` and the schema copy test; no execution-environment brief fact changes (no CI job, required context, tool route or batch-budget rule), so no brief-update task is needed.
- File size: `Invoke-DocsCommand.ps1`, `DocsSchema.psm1` and `DocsProfile.psm1` are the largest candidates and the convention test enforces the 800-line hard limit on modules; the plan must split at the 500-line guidance into a new `Docs<Area>.psm1` with its own test file and record logical line counts.
- Test isolation: dot-sourcing the entry script imports `Docs*` and `DiscoveryEncoding` modules into the session, and lazy command imports can leak between suites; the plan must remove the modules in `AfterAll`, keep no module-scope cache, use in-memory contexts, and record three seeded shuffled file-order runs plus a fresh single-process run over `tests/scripts`.
- CI-only behavior: the windows-latest runner's PowerShell version and its bundled JsonSchema.Net determine `Test-Json` 2020-12 support, error-message shape and pattern handling, which a local 7.6.9 run does not prove; the plan must confirm the runner version, assert only field-name containment and pointer extraction, and fail closed below 7.4; tests must not read gitignored `artifacts/` state and must use forward-slash relative paths with `Join-Path`.
- Evidence: artifacts outside `<FEATURE>/evidence/<kind>/`, with plan-time stamps, host paths, or the two forbidden consumer tokens fail review; the plan must write write-time UTC stamps, record `SCRATCH` for scratch paths, and run the forbidden-token scan with bracket-class patterns over every changed file.

## Rejected Alternatives (summary)

- `Test-Json -FetchExternalReference`, the JsonSchema.Net global registry, and per-file
  self-contained schemas (section 2.2).
- Referencing discovery v2 common at runtime (not pushed down; section 2.1).
- A `schemas` push-down root, and reading schemas from the consumer root (section 3.4).
- YAML profiles (A8; section 4).
- Delivering consumer configuration by a push-down tree (overwrites consumer-owned files; no root
  reaches `.github/workflows/`; section 5).
- Glob-discovered command or analyzer modules (non-literal `$PSScriptRoot` use fails the recognized-form
  test and hides the dispatch set) and a plain append-at-end table (adjacent-line conflicts between
  parallel wave-1 children).
- `ConvertFrom-Json` for artifacts (DateTime coercion and lost integer/boolean distinctions).

## Owner Questions Raised

1. **OQ-1 - Runtime schema location.** The naming contract fixes `schemas/docs/v1/`, which no
   push-down root publishes. Options: (a) keep canonical `schemas/docs/v1/` and ship a
   byte-identical runtime copy under `.claude/lib/docs/schemas/v1/` pinned by a Pester test;
   (b) make `.claude/lib/docs/schemas/v1/` the only canonical location (naming-contract change);
   (c) add `schemas` as a push-down root (TypeScript plus two in-place Python edits). Provisional
   default: (a).
2. **OQ-2 - Codex and `.agents` reachability.** The docs lib is published only in the Claude bundle.
   Codex skills mirrored by 900009 would need either the Claude push-down in the consumer or a
   `.codex/lib/docs/` virtual directory (new `VIRTUAL_RESOURCE_DIRECTORIES` entry in TypeScript, the
   in-place edit of the existing Python twin, and Codex skill text naming `.codex/lib/docs/`).
   Provisional default: Claude bundle only in 1020; 900009 decides after the owner answers.
3. **OQ-3 - Destination PowerShell floor.** The epic states "PowerShell 7 only"; `Test-Json`
   Draft 2020-12 support needs 7.4 (precedent `DiscoveryValidation.psm1`). Provisional default:
   require 7.4 and fail closed with `DOCS_RUNTIME_UNSUPPORTED` (exit 3) below it.
4. **OQ-4 - Tier of `.claude/lib/docs`.** T3 matches every existing `.claude/lib/*` entry; T2 would
   reflect the contract role but adds property-test density and mutation-trend obligations and
   requires changing `test_committed_quality_tiers_yml_assigns_spec_tiers`, which permits only the
   approved discovery package at T1/T2. Provisional default: T3.
5. **OQ-5 - `init -Write` scope.** Delivering the 900008 workflow and 1021 linter configuration
   through `init` means a pushed-down helper writes into a consumer's `.github/workflows/` and
   repository-root dotfiles. Provisional default: allowed only with `-Write`, create-only unless
   `-Force`, dry run by default, every planned path listed before any write.

## Items for the Orchestrator to Confirm

- Whether `Test-Json -FetchExternalReference` exists on PowerShell 7.4 and 7.5 (recorded for
  completeness; the selected design does not use it).
- The PowerShell version preinstalled on the `windows-latest` runner used by the `poshqc` shard jobs
  (`.github/workflows/_poshqc.yml` uses `shell: pwsh` with no version pin), and, on that version:
  Draft 2020-12 validation; inline `#/$defs/<name>` refs where `<name>` contains `.`; one ErrorRecord
  per failure with a message ending in ` at '<pointer>'`; handling of the copied patterns
  (`(?![\s\S])`, `\x00-\x1f`, ` `); whether `format: date-time` is asserted or annotation-only;
  and whether repeated `Test-Json` calls with a schema carrying the same `$id` but different content
  raise a registry error (the design strips `$id`, so this only confirms the reason).
- Whether `-Name value` tokens reach a `ValueFromRemainingArguments` parameter of an advanced script
  when invoked in-process with `&` as well as with `pwsh -File` (the parallel-drift precedent shows
  the `-File` case).
- The SHA-256 digest list for the neutrality test (lowercase identifier forms supplied by the owner
  or orchestrator, never as text).
- The golden identity vectors: for each chosen `(kind, path, declaration)`, the hex SHA-256 of the
  canonical string plus LF, computed by an independent route (for example `sha256sum` in a `sh`
  script, or the existing discovery `stable_id`).
- Whether 1023 has been re-prepared under the refined rule on another branch; in this worktree its
  `spec.md`, plan and research still describe `packages/docs-runtime` and cite epic headings that
  were renamed.
- Owner answers to OQ-1 through OQ-5.
- The delegated filename was adjusted to end in `-research.md` (see the header); confirm that later
  references use the adjusted path.
