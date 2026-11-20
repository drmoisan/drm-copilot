# docs-profile-and-artifact-schemas (Issue #1020) - Amendment Addendum for Owner Decisions D3 and D5

- Feature: child 1020 of epic #1019 (documentation-estate-tooling), wave 0, band C3
- Branch: `feature/docs-profile-and-artifact-schemas-1020`
- Mode: preparation, requirements amendment (new planning cycle under owner decision D1). No
  source, configuration or test file was changed.
- Relationship to earlier research: this addendum amends
  `research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md` (the "design
  addendum") for five items only. Everything in the current `spec.md` and
  `plan.2026-10-30T16-08.md` that is not named below stays as written.
- Sources read: the feature `issue.md`, `spec.md`, `user-story.md`, `plan.2026-10-30T16-08.md`,
  both earlier research files; epic `docs/features/epics/documentation-estate-tooling/epic.md`
  (front matter, `## Owner Decisions (2026-10-30, received through the coordinator)`,
  `### Amendment of 1020 required by D3 and D5`, `### PowerShell contracts from the re-preparation
  of 1020`, `### Command contract decisions from the first preparation of 1023`, `### Analyzer
  decisions from the first preparation of 1022`, `### Generator decisions from the first preparation
  of 1024`, `### 900011 - docs-surface-analyzer-python-native (wave 2, C3)`, `## Planned Waves`);
  the 1021 `spec.md`; `.claude/skills/execution-environment/SKILL.md`; and the repository files
  cited below.
- Requirement origin: one consumer repository (epic `## Goal`). No identifier of that repository
  appears in this file.
- Tool limits: the task-researcher tool set has no Bash, PowerShell, `git` or `gh`. Facts that need
  them are listed under `## Items for the Orchestrator to Confirm`.

## 0. Decisions in One Line Each

1. (a) Docs common gains `analysis-method` (`enum: ["native", "scanner"]`). `analysis_method` is
   required and non-null on snapshot `$defs/element`, on snapshot `analyzers[]` items and on
   ledger `$defs/entry`. It is not part of the element identifier.
2. (b) `source_sha256` keeps its name and is redefined as the declaration-lines digest: SHA-256 of
   the UTF-8 bytes of the selected lines after BOM removal and LF normalization, each selected line
   terminated by one LF. `line_range` becomes required non-null for every kind except
   `architecture-component`. `DocsSurface.psm1` computes it with two new pure functions, and
   `New-DocsSurfaceElement` takes the source text instead of a caller-supplied digest.
3. (c) A new non-artifact schema `schemas/docs/v1/docs-command-envelope.schema.json` pins the `-Json`
   envelope. It references docs common `finding` and is composed in memory like every other docs
   schema. It has a runtime copy, a bundle copy, a `core.json` line and one example. No existing
   repository test enumerates docs schema files; only counts inside the 1020 plan change.
4. (d) The analyzer registry carries three anchors in this order: `# --- 1022: Python and
   configuration analyzers ---`, `# --- 900004: TypeScript and .NET analyzers ---`, and
   `# --- 900011: Python-native analyzers ---`. The current spec text `900003` is a stale
   placeholder for 1022, and the dispatch-table anchors `900003` and `900006` are stale placeholders
   for 1022 and 1024.
5. (e) Docs common gains `audience-id` (pattern `^[a-z0-9][a-z0-9-]*$(?![\s\S])`) and
   `audience-ids`. The profile uses them. The page-metadata schema is owned by 1021 and references
   `urn:drm-copilot:docs:1.0.0:common#/$defs/audience-id`. 1020 adds a binding bullet for 1021 to
   `## Decisions Later Children Must Honor`.
6. Plan impact: eleven existing tasks change and one task is added, for 44 tasks and an estimated
   325 lines. The 40-task guideline was already exceeded (43) and justified, and the 400-line limit
   holds.

## 1. (a) `analysis_method` on Elements and Ledger Entries

### 1.1 Schema placement

Docs common `$defs` (`schemas/docs/v1/common.schema.json`), new row in the spec table
`### Docs \`common\` \`$defs\``:

| Definition | Shape |
|---|---|
| `analysis-method` | `enum: ["native", "scanner"]` |

`surface-inventory-snapshot.schema.json`:

- `$defs/element` gains `analysis_method`: `{"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/analysis-method"}`. It is listed in `required` and is not nullable.
- `analyzers[]` items change from `{id, version}` to closed `{id, version, analysis_method}`, all
  required. A snapshot then records which method produced each analyzer's output, and a diagnostic's
  method can be derived through its `analyzer_id`. The docs common `diagnostic` shape is not
  changed. Uniqueness of `analyzers[].id` within one snapshot is a semantic rule for 1022, because
  `uniqueItems` compares whole objects.

`docs-coverage-ledger.schema.json`:

- `$defs/entry` gains `analysis_method` (same `$ref`, required, not nullable). It records the
  method of the snapshot element at the last ledger synchronization; 1023 owns keeping it current
  (`sync-refs`). The scanner precision limit is recorded by 1023 as a `deferred` entry with an
  owner and a target; the existing companion rules already require both, so 1020 needs no further
  schema change for D3.

Both fields use `enum`, so a wrong value yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED` and a missing value
yields `DOCS_SCHEMA_REQUIRED_MISSING` from the structural walk with a field-naming pointer
(`$ref`, `required` and `enum` are all inside the walk subset of spec `#### Structural walk`).

Interpretation recorded for confirmation: the owner wording "per finding" is read as per ledger
entry and per snapshot element, which matches the epic D3 text "per element".

### 1.2 Examples

- `examples/docs/v1/surface-inventory-snapshot.example.json`: V1 and V2 (CLI) carry
  `analysis_method: "native"`, V3 and V4 carry `"scanner"`, so both enum values are exercised.
  `analyzers[]` lists one entry per method with neutral identifiers.
- `examples/docs/v1/docs-coverage-ledger.example.json`: each entry copies the method of its element.

### 1.3 Element identifier

Spec `#### Element identifiers` hashes only `{"declaration", "kind", "path"}`. `analysis_method`
is therefore excluded, and a native and a scanner run of the same declaration produce the same
`element_id`. This matches the epic 900011 statement that ledger pins stay valid when the method
changes. Add one sentence to that spec section ("`analysis_method`, `source_sha256`, `line_range`,
`name` and `properties` do not participate in the identifier"). Add one `DocsSurface.Tests.ps1`
case: two elements that differ only in `AnalysisMethod` have equal `element_id`, and
`ConvertFrom-DocsSurfaceElement` accepts both.

### 1.4 PowerShell functions that carry the field

| Function | Change |
|---|---|
| `DocsSurface.psm1` `Get-DocsAnalysisMethod` (new, pure) | Returns `native`, `scanner` in that order (mirrors `Get-DocsElementKind`). |
| `DocsSurface.psm1` `New-DocsSurfaceElement` | New mandatory `-AnalysisMethod <string>`, validated against `Get-DocsAnalysisMethod` (throws `DOCS_IDENTITY_INPUT_INVALID` naming the argument, consistent with the other argument checks). |
| `DocsSurface.psm1` `ConvertFrom-DocsSurfaceElement` | Requires `analysis_method` in the record; unchanged identifier re-verification. |
| `DocsAnalyzerRegistry.psm1` row form | New field `AnalysisMethod = 'scanner'` or `'native'`, one row per line as before. |
| `Test-DocsAnalyzerRegistration` | `AnalysisMethod` outside `Get-DocsAnalysisMethod` is `DOCS_ANALYZER_REGISTRATION_INVALID`; the uniqueness key becomes (`Id`, `AnalysisMethod`) instead of `Id`; a `native` row whose `Id` has no `scanner` row is `DOCS_ANALYZER_REGISTRATION_INVALID` (scanner baseline always available, D3). |
| `Select-DocsAnalyzerRegistration` | New optional `-NativeAvailable <string[]>` (identifiers whose native analyzer the caller has detected as available). Returns one row per selected `Id`: the `native` row when the `Id` is in `-NativeAvailable` and a native row exists, otherwise the `scanner` row. Stays pure; detection of the pack and interpreter stays in 900011's adapter. |
| `Invoke-DocsAnalyzer` | Output validation adds: each element's `analysis_method` equals the row's `AnalysisMethod`; and each element's `source_sha256` equals the digest recomputed from the captured input text of the element's `path` and its `line_range` (section 2), else the output is rejected with a finding. This makes D5 byte agreement between the PowerShell scanner and the Python-native analyzer a checked property, not a convention. |

Without the (`Id`, `AnalysisMethod`) key, the 900011 rows (same identifiers as 1022, per the epic
900011 scope split) would be rejected as duplicate identifiers. The selection rule is a proposal
that 1022 and 900011 confirm in their own preparation (Items to Confirm).

## 2. (b) Declaration-Lines Digest

### 2.1 Definition (normative text for spec `### DocsSurface.psm1`)

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
   change and no Unicode normalization are applied. Zero selected lines give the empty string.

`Get-DocsDeclarationSha256 -Text <string> [-LineRange <int[]>]` (pure) returns
`Get-DocsSha256Hex -Text (ConvertTo-DocsDeclarationText ...)`: the lowercase hex SHA-256 of the
UTF-8 bytes without BOM. The input text is the strict-UTF-8 `text` of `New-DocsCapturedInput`, so
no unpaired surrogate reaches the non-throwing `UTF8.GetBytes` inside `Get-DiscoverySha256Hex`.

Properties of this definition:

- Line numbers are not hashed. Inserting or deleting lines above a declaration shifts its
  `line_range` but leaves `source_sha256` unchanged, so a page is not marked stale by an unrelated
  edit.
- CRLF and LF checkouts of the same file, a file with and without a final newline, and a file with
  and without a BOM produce the same digest. This also removes any dependence on the `.gitattributes`
  rule `* text=auto eol=lf`.
- A Python-native analyzer (900011) reproduces the digest from `ast` line numbers (`lineno`,
  `end_lineno`) with the same five steps; `Invoke-DocsAnalyzer` recomputes it (section 1.4).

### 2.2 Schema fields

- Keep `source_sha256` (element and docs-evidence-pin) and `line_range` (`{start, end}`). The name
  is kept because the 1023 `spec.md` already uses `source_sha256` seven times and compares it as an
  opaque value; a rename would add churn to 1023 and 1024 for no behavior change. Add a schema
  `description` to the element `source_sha256`: "SHA-256 of the declaration lines selected by
  line_range (normalized per spec), not of the whole file".
- `line_range` stays `{start: integer minimum 1, end: integer minimum 1}` or `null`, with a new
  conditional inside the walk subset: `if` `kind` `enum` of the five kinds other than
  `architecture-component`, `then` `properties.line_range` `type: "object"`. A `null` range on a
  `cli-command` then yields `DOCS_SCHEMA_TYPE_MISMATCH` at `/elements/<n>/line_range`.
  `start <= end` is not expressible in JSON Schema and is enforced by `New-DocsSurfaceElement` and
  `ConvertTo-DocsDeclarationText`.
- `architecture-component` (a package or module path) may have `line_range: null`, and then the
  digest covers every line of the normalized file. The module is its own declaration. This is the
  only case where the digest equals a whole-file digest; it is listed for owner confirmation.

### 2.3 Element construction

`New-DocsSurfaceElement` replaces `-SourceSha256 <string>` with `-SourceText <string>` and computes
`source_sha256` through `Get-DocsDeclarationSha256` with `-LineRange`. `-LineRange` becomes
mandatory for every kind except `architecture-component`. Analyzers therefore cannot supply a
whole-file digest by mistake. This changes a 1020-internal signature that no merged code calls yet.

### 2.4 Tests (`DocsSurface.Tests.ps1`)

- Locality, example-based: a six-line in-memory text and range `@(3, 4)`. Each of the following
  leaves the digest unchanged: changing line 1, changing line 6, inserting two lines above with the
  range shifted to `@(5, 6)`, converting all line endings to CRLF, removing the final newline, and
  adding a BOM. Changing one character in line 3, or in line 4, changes the digest. Extending the
  range to `@(3, 5)` changes the digest.
- Locality, property-based: a seeded `[System.Random]` (seed printed in the failure message)
  generates line arrays and ranges. A mutation of a random line outside the range never changes the
  digest, and appending a character to a random line inside the range always changes it.
- Bounds: `@(0, 1)`, `@(3, 2)` and an `end` beyond the line count throw `DOCS_DIGEST_RANGE_INVALID`.
  Zero-line text without a range returns the digest of the empty string.
- Golden vector D1, computed independently in [P1-T1] by piping the literal canonical declaration
  text through `sha256sum` in a `sh` script under `SCRATCH`. Source text
  `a = 1<CR><LF>def handler():<CR><LF>    return 1<CR><LF>b = 2` (no final newline), range
  `@(2, 3)`, canonical text `def handler():<LF>    return 1<LF>`. The test asserts both the
  canonical string and the recorded hex.

## 3. (c) Envelope Schema `docs-command-envelope.schema.json`

### 3.1 Shape

The envelope is not an artifact. Spec AC S17 fixes its keys to exactly `command`, `exit_code`,
`findings`, `ok` and `result`, so it carries no artifact header (`$schema`, `schema_version`,
`artifact_kind`, `id`, `extensions`). Spec `### Schema identity and reference conventions` gains
that exception. It is not added to the `docs-artifact-kind` enum, because an envelope is never
pinned.

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

- `result` is open (`{}`). Each subcommand owns its result shape, which keeps later children from
  editing this file. The exit 2 and exit 3 rows of spec `#### Exit codes and the -Json envelope`
  force `null`.
- Every constraint except `pattern` is inside the structural-walk subset, so envelope violations
  name their field. `maxItems: 101` equals the `Get-DocsOrderedFinding` default limit of 100 plus
  the one `FINDINGS_LIMIT` finding. The spec must state that commands use the default limit.
- Spec gaps the amendment closes: `command` is the `-Command` value when it names a row of the
  dispatch table, otherwise `null` (missing or unknown command, exit 2). `-Help -Json` writes an
  envelope with exit 0, no findings and `result` `{"usage": [<line>, ...]}`.
- Name and order: `Get-DocsSchemaName` lists `docs-command-envelope` after
  `docs-validation-receipt` and before the `# --- 1021: page-metadata ---` anchor.
  `Get-DocsSchemaPath` gains `Join-Path -Path $PSScriptRoot -ChildPath
  'schemas/v1/docs-command-envelope.schema.json'`. `Get-DocsComposedSchemaSet` composes it with the
  others, and `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` validates an envelope.
  The parameter name stays `ArtifactKind`, and the spec notes that it also accepts this one
  non-artifact kind.
- Example: `examples/docs/v1/docs-command-envelope.example.json`, a `validate-profile` exit 1
  envelope with one `DOCS_PROFILE_AUDIENCE_UNKNOWN` finding and `result`
  `{"profile_path": ..., "repository_id": ...}`.

### 3.2 Cross-file `$ref` versus self-contained (D5)

D5 asks for `Test-Json` cross-file `$ref` to be tested first, with self-contained schemas as the
fallback. The orchestrator probe recorded in spec `#### Schema composition` shows that cross-file
refs fail by default, so the fallback applies. The fallback is implemented as it is for the other
seven files: the file keeps the docs-common URN ref, and `Join-DocsSchemaText` produces a
self-contained composed schema in memory before `Test-Json` runs. A physically inlined `finding`
definition was rejected because it would be a second copy that needs its own parity test (design
addendum section 2.2, option D). The orchestrator should confirm that the owner accepts the
in-memory composed form as the "self-contained" fallback.

### 3.3 Locations and registration

| Path | Change |
|---|---|
| `schemas/docs/v1/docs-command-envelope.schema.json` | create (canonical) |
| `examples/docs/v1/docs-command-envelope.example.json` | create |
| `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` | create, byte-identical runtime copy (OQ-1) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` | create, byte-identical bundle copy |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | one more `paths` line, `".claude/lib/docs/schemas/v1/docs-command-envelope.schema.json"` |

Manifest form, verified: `core.json` `paths` lists each file as one repository-relative string per
line, including data files, for example `".claude/lib/discovery-validation/DiscoveryAuthority.psd1"`.
No wildcard is used.

### 3.4 Pester validation of `-Json` output

In `Invoke-DocsCommand.Tests.ps1` ([P4-T4]):

- In `BeforeAll`, build the composed set once per suite with `Read-DocsSchemaSet`, using the
  committed runtime schemas read through `Docs.TestSupport.psm1`, and `Get-DocsComposedSchemaSet`.
  `Test-Json` is not mocked in this suite.
- For each `-Json` scenario already planned (exit 0 `validate-profile`, exit 1 invalid profile,
  every exit 2 case, both exit 3 cases, and `-Help -Json`), assert that `Test-DocsArtifactText
  -ArtifactKind 'docs-command-envelope' -JsonText $outcome.Stdout` returns no finding and that
  `Test-Json -Json $outcome.Stdout -Schema <composed text>` returns `$true`.
- Negative cases in `DocsSchemaContract.Tests.ps1` ([P3-T4]), each an in-memory mutation of the
  envelope example: `ok` true with `exit_code` 1 gives `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/ok`; an
  extra key gives `DOCS_SCHEMA_PROPERTY_UNKNOWN`; `exit_code` 2 with two findings gives
  `DOCS_SCHEMA_ITEM_COUNT` at `/findings`; `exit_code` 0 with an `error` finding gives
  `DOCS_SCHEMA_VALUE_NOT_ALLOWED` at `/findings/0/severity`; a missing `result` gives
  `DOCS_SCHEMA_REQUIRED_MISSING` at `/result`.

### 3.5 Tests that enumerate schema files

Repository tests, verified by reading:

| Test | Enumerates | Disposition |
|---|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) | every distributable `.claude` file; `filter_distributable_claude_paths` in `claude_payload_scope_test_support.py` excludes only `.claude/agent-memory`, `.claude/state`, `.claude/worktrees` and `.claude/settings.local.json` | Unchanged. It picks up the new runtime copy and requires the bundle copy. |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` with `pack_manifest_dependency_scan.py` (`_NAMED_FORM`) | literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` targets of manifested PowerShell | Unchanged. The new `Get-DocsSchemaPath` join requires the `core.json` line. |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | bundled agents, hooks and skills only (design addendum section 6) | Unchanged; not affected. |
| `tests/scripts/dev_tools/test_push_down_claude_config_carriage.py` (`REPO_ONLY_NAMES`) and `test_push_down_codex_and_agents_customizations.py` | `config/orchestration-handoff.schema.json` only | Unchanged; the `config` tree is not touched. |
| Pester suites under `tests/scripts/claude-lib/` and `tests/scripts/claude-hooks/` that name `schemas/` | discovery and blast-radius schemas only | Unchanged; none names `schemas/docs`. |

No repository test enumerates `schemas/docs/v1/` today, because the directory does not exist. The
counts that change are inside the 1020 plan and its planned suites:

| Planned item | Current text | Amended text |
|---|---|---|
| [P3-T1] runtime copies | "the seven files", "exactly seven new files" | eight |
| [P5-T1] bundle mirror | "fifteen files (eight PowerShell files, seven runtime schemas)", "exactly fifteen" | sixteen (eight and eight) |
| [P5-T2] `core.json` | "fifteen `.claude/lib/docs/` paths" | sixteen |
| `DocsSchema.Tests.ps1` ([P3-T3]) `Get-DocsSchemaName` order | seven names then the 1021 anchor | eight names then the 1021 anchor |
| `DocsSchemaContract.Tests.ps1` ([P3-T4]) | examples parametrized over six artifact schemas | example validation over seven examples (six artifact schemas plus the envelope); the rejection-per-schema cases (S2) stay over the six artifact schemas by name |
| `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1` | recursive discovery, one `It` per file | Unchanged; the new file is discovered. |
| Pre-Mortem `Mirror parity` bullet | "the seven runtime schema copies" | eight |

## 4. (d) 900011 Anchor in `DocsAnalyzerRegistry.psm1`

Recommended committed form:

```powershell
$script:DocsAnalyzerRow = @(
    # --- 1022: Python and configuration analyzers ---
    # --- 900004: TypeScript and .NET analyzers ---
    # --- 900011: Python-native analyzers ---
)
```

- Format: `# --- <issue number>: <scope> ---`, as in the existing anchors. 900011 is appended last,
  so no existing anchor line moves.
- Stale placeholder: the spec, plan and design addendum use `900003` for the Python and
  configuration analyzers. The epic front matter and `## Scope` have no `900003`; that scope is
  issue 1022 (`2026-10-30-docs-surface-analyzers-python-config-1022`). In the same way, the
  dispatch-table anchors `# --- 900003: inventory ---` and `# --- 900006: generate-reference ---`
  refer to 1022 (owner of `inventory`, epic naming contract) and 1024 (owner of
  `generate-reference`). The amendment corrects all three to `1022` and `1024`, including spec
  `## Decisions Later Children Must Honor` and ACs S18 and S19.
- Placeholders 900004 and 900011 are not yet promoted (epic front matter comment). Add a spec rule:
  a child whose placeholder number changes on promotion edits only its own anchor comment, in the
  same change that inserts its rows.
- Tests that count anchors: only the planned `DocsAnalyzerRegistry.Tests.ps1` ([P4-T1], "zero rows
  and both anchors in order") and `Invoke-DocsCommand.Tests.ps1` ([P4-T4], dispatch anchor order).
  [P4-T1] changes to three anchors in the order above. [P4-T4] changes the expected anchor texts
  for 1022 and 1024. No repository test reads these files today.
- 900011 adds no subcommand (`inventory` is owned by 1022), so the dispatch table gets no 900011
  anchor.

## 5. (e) Audience Identifier Pattern

- Today the profile uses docs common `identifier` (copied from discovery v2:
  `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])`) for `audiences[].id` and
  `documentation_roots[].audience_ids`. The stale 1021 `spec.md` `### Properties` gives
  `audience` items the pattern `^[a-z0-9][a-z0-9-]*$`. Neither pattern contains the other: `docs.v2`
  passes only the first, and `2nd-line` only the second. The epic 1024 decision fixes the second
  pattern for both schemas.
- Docs common gains:

| Definition | Shape |
|---|---|
| `audience-id` | string, pattern `^[a-z0-9][a-z0-9-]*$(?![\s\S])` |
| `audience-ids` | array, `uniqueItems`, items `audience-id` |

- The `(?![\s\S])` suffix follows the convention of every copied discovery pattern. The suffix is
  needed because `Test-Json` uses .NET regular expressions, where `$` also matches before a final
  newline; without it, the value `"readers\n"` would pass. For any string without a newline, the
  pattern accepts exactly the strings the epic pattern accepts.
- Profile schema: `audiences[].id` refers to `audience-id`, and `documentation_roots[].audience_ids`
  refers to `audience-ids`. `Test-DocsProfileSemantic` is unchanged. `New-DocsStarterProfile` and the
  example profile use audience ids that match (for example `maintainers`).
- Ownership: the page-metadata contract (`schemas/docs/v1/page-metadata.schema.json`) belongs to
  1021 (spec `## Decisions Later Children Must Honor`, `Get-DocsSchemaName` 1021 anchor). 1020
  defines the one shared `$defs` entry, and 1021 references it. Add a decision bullet: "1021
  `page-metadata.schema.json` `audience` is `minItems 1` with items
  `urn:drm-copilot:docs:1.0.0:common#/$defs/audience-id` (or `audience-ids` plus `minItems 1`); it
  does not restate the pattern." The 1021 spec still describes a self-contained Python-era schema;
  its re-preparation adopts the reference.
- Pattern failures are outside the walk subset, so an invalid audience id yields
  `DOCS_SCHEMA_INVALID` (spec `#### Artifact validation`, third case), not a field-named finding.
  This is allowed by the spec rule for constraints outside the subset. Test in [P4-T2]: profiles
  with audience ids `Readers`, `docs.v2`, `a_b` and `-x` are each rejected (`Ok` false, at least
  one `error` finding), and `2nd-line` and `maintainers` are accepted.

## 6. Plan Task Impact

Existing tasks touched (ID and title as in the plan):

| Task | Change |
|---|---|
| [P1-T1] golden identity vectors | Add digest golden vector D1 (section 2.4) to the same `sh` script and evidence file. |
| [P1-T2] `common.schema.json` | Add `analysis-method`, `audience-id` and `audience-ids`. |
| [P1-T3] profile and snapshot schemas and examples | Profile uses `audience-id` and `audience-ids`. Element gains `analysis_method`, the `line_range` conditional and the `source_sha256` description. `analyzers[]` gains `analysis_method`. Examples updated. |
| [P1-T4] ledger and matrix schemas and examples | Ledger `$defs/entry` gains `analysis_method`; example updated. |
| [P2-T3] `DocsSurface.psm1` | Add `Get-DocsAnalysisMethod`, `ConvertTo-DocsDeclarationText` and `Get-DocsDeclarationSha256`. Change `New-DocsSurfaceElement` (`-AnalysisMethod`, `-SourceText`, conditional `-LineRange`). Add the tests of sections 1.3 and 2.4. |
| [P3-T1] runtime copies | Seven to eight files. |
| [P3-T3] `DocsSchema.psm1` | Envelope name and path rows; name-order test. |
| [P3-T4] `DocsSchemaContract.Tests.ps1` | Envelope example validation and negative cases (section 3.4). Snapshot and ledger cases for a missing and an unknown `analysis_method`. A `null` `line_range` on a `cli-command` gives `DOCS_SCHEMA_TYPE_MISMATCH`. |
| [P4-T1] `DocsAnalyzerRegistry.psm1` | Three anchors (section 4); the `AnalysisMethod` row field, key and native-requires-scanner rule; `-NativeAvailable` selection; output validation of `analysis_method` and recomputed `source_sha256`, with a fixture case for each rejection. |
| [P4-T2] `DocsProfile.psm1` | Audience-id accept and reject cases (section 5); starter profile audience id. |
| [P4-T4] `Invoke-DocsCommand.ps1` | Dispatch anchors `1022` and `1024`; `command` null rule; `-Help -Json` envelope; envelope schema validation of every `-Json` scenario (section 3.4). |
| [P5-T1], [P5-T2] mirror and `core.json` | Fifteen to sixteen files and paths. |

Task to add:

- [P1-T6] Create `schemas/docs/v1/docs-command-envelope.schema.json` (section 3.1) and
  `examples/docs/v1/docs-command-envelope.example.json`. Acceptance is proven in [P3-T4] and
  [P4-T4]. Folding this into [P1-T5] would keep 43 tasks but would give that task three schemas and
  two kinds of contract; a separate task is recommended.

Non-task sections touched: `## Artifact Classification` (four rows: canonical schema, example,
runtime copy and bundle copy), `## Acceptance Criteria Traceability` (rows for the new spec ACs
below, and S18 and S19 text), `## Pre-Mortem` `Mirror parity` (eight copies), and
`## Size Justification` (44 tasks).

New or changed spec ACs for the spec writer:

- New: snapshot elements, snapshot `analyzers[]` and ledger entries require `analysis_method` in
  {`native`, `scanner`}; a missing or unknown value is rejected with a field-naming finding; the
  element identifier does not depend on it (`DocsSchemaContract.Tests.ps1`,
  `DocsSurface.Tests.ps1`).
- New: `Get-DocsDeclarationSha256` is unchanged by edits outside the line range, by line shifts,
  CRLF, BOM and final-newline differences, and changes for any edit inside the range; the D1 golden
  vector matches; `Invoke-DocsAnalyzer` rejects an element whose `source_sha256` differs from the
  recomputed digest (`DocsSurface.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`).
- New: every `-Json` output validates against `docs-command-envelope.schema.json` through
  `Test-DocsArtifactText` and `Test-Json`; the envelope example validates; the five mutations of
  section 3.4 are rejected (`Invoke-DocsCommand.Tests.ps1`, `DocsSchemaContract.Tests.ps1`).
- New: profile audience ids follow `audience-id` (section 5 cases) (`DocsProfile.Tests.ps1`).
- Changed S1 and U1 wording: "every example under `examples/docs/v1/` validates against its
  schema" (the envelope example included); S2 keeps its explicit list of six artifact schemas.
- Changed S18 and S19: anchor numbers 1022 and 1024; registry anchors 1022, 900004 and 900011 in
  that order.
- Spec prose to replace: `#### Exit codes and the -Json envelope` "The envelope has no schema file;
  Pester and 900007 Jest tests pin it", and `## Behavior` "Six artifact schemas plus one
  definitions-only `common.schema.json`" (add the envelope schema). The epic
  `### PowerShell contracts from the re-preparation of 1020` bullet "the envelope has no schema
  file" also contradicts D5 and needs an epic-level edit by the orchestrator.

Size: 43 + 1 = 44 tasks, against the 40-task guideline already exceeded and justified at 43. Lines:
312 now. The additions are about one line per touched task for counts, four classification rows,
four traceability rows, one new task of about three lines and size-justification text, an estimated
325 lines in total, under 400. The main size risk is task text length in [P2-T3], [P3-T4] and
[P4-T1]; keep the added test lists to one sentence each and refer to this addendum's sections.

## Numeric Derivation Evidence

### Docs schema files after the amendment (8)

- Complete Family: every `*.schema.json` file under `schemas/docs/v1/` that 1020 creates after the amendment
- Exhaustive Search Scope: spec `### DocsSchema.psm1` `Get-DocsSchemaName` list, spec `## Behavior`, the plan `## Artifact Classification` rows under `schemas/docs/v1/`, and section 3 of this addendum; 1021's `page-metadata` is excluded as a later child's file
- Inclusion Rules: canonical schema files created by 1020, including definitions-only `common` and the non-artifact envelope
- Exclusion Rules: runtime and bundle copies (separate families), examples, `page-metadata` (1021)
- Primary Search Strategy or Query Expression: spec `Get-DocsSchemaName` order list plus section 3.1 of this addendum
- Primary Member Set: common, docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt, docs-command-envelope
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: plan `## Artifact Classification` rows whose path begins `schemas/docs/v1/` (seven rows) plus the row added in section 6
- Cross-check Member Set: common, docs-profile, surface-inventory-snapshot, docs-coverage-ledger, docs-parity-matrix, docs-evidence-pin, docs-validation-receipt, docs-command-envelope
- Cross-check Count: 8
- Member-set Comparison: the normalized sets are equal

### Files under `.claude/lib/docs/` after the amendment (16)

- Complete Family: every file 1020 creates under `.claude/lib/docs/` (PowerShell and runtime schema data)
- Exhaustive Search Scope: spec `### Module conventions` import-graph table, spec `## Implementation Strategy`, plan [P5-T1] and the plan classification rows beginning `.claude/lib/docs/`
- Inclusion Rules: PowerShell production files and runtime schema copies created by 1020
- Exclusion Rules: bundle copies (an equal second family), tests, files of later children, templates (none in 1020)
- Primary Search Strategy or Query Expression: the eight import-graph rows plus the eight schema names of the family above, each prefixed `schemas/v1/`
- Primary Member Set: DocsJson.psm1, DocsFinding.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfile.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1, schemas/v1/common.schema.json, schemas/v1/docs-profile.schema.json, schemas/v1/surface-inventory-snapshot.schema.json, schemas/v1/docs-coverage-ledger.schema.json, schemas/v1/docs-parity-matrix.schema.json, schemas/v1/docs-evidence-pin.schema.json, schemas/v1/docs-validation-receipt.schema.json, schemas/v1/docs-command-envelope.schema.json
- Primary Count: 16
- Cross-check Search Strategy or Query Expression: plan classification rows whose path begins `.claude/lib/docs/` (fifteen rows: eight PowerShell, seven schema copies) plus the runtime-copy row added in section 3.3
- Cross-check Member Set: DocsJson.psm1, DocsFinding.psm1, DocsSchema.psm1, DocsSurface.psm1, DocsAnalyzerRegistry.psm1, DocsProfile.psm1, DocsProfileCommands.psm1, Invoke-DocsCommand.ps1, schemas/v1/common.schema.json, schemas/v1/docs-profile.schema.json, schemas/v1/surface-inventory-snapshot.schema.json, schemas/v1/docs-coverage-ledger.schema.json, schemas/v1/docs-parity-matrix.schema.json, schemas/v1/docs-evidence-pin.schema.json, schemas/v1/docs-validation-receipt.schema.json, schemas/v1/docs-command-envelope.schema.json
- Cross-check Count: 16
- Member-set Comparison: the normalized sets are equal; the production PowerShell count stays eight plus eight bundle copies, so the batch-budget statement is unchanged

## Pre-Mortem

- Review checklists: a reviewer can flag a schema constraint whose failure does not name its field, a registry that accepts a native row without a scanner baseline, or a digest computed over the whole file. The plan must keep the envelope and `analysis_method` constraints inside the walk subset, carry the native-requires-scanner rule and the recomputed-digest check in [P4-T1], and assert digest locality in [P2-T3].
- Coverage: the new pure functions (`ConvertTo-DocsDeclarationText`, `Get-DocsDeclarationSha256`, `Get-DocsAnalysisMethod`) and the new registry branches add lines to `DocsSurface.psm1` and `DocsAnalyzerRegistry.psm1`. The plan must give each branch (range error, empty text, architecture-component without range, native selection, scanner fallback, digest mismatch) a test so that per-file line coverage stays at or above 85% in [P6-T3].
- Mirror parity: the eighth schema needs a runtime copy, a bundle copy and a `core.json` line. A missed copy fails `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `Docs.Manifest.Tests.ps1`, and a missed `core.json` line fails the dependency-closure test through the new `Get-DocsSchemaPath` join. The plan must change the counts in [P3-T1], [P5-T1] and [P5-T2] to eight and sixteen. No execution-environment brief fact changes, so no brief-update task is needed.
- File size: `DocsSurface.psm1` and `DocsAnalyzerRegistry.psm1` grow. The plan must record their logical line counts in [P6-T10] and move the digest functions into `DocsDeclarationDigest.psm1` (own suite, bundle copy, `core.json` line and classification row) if `DocsSurface.psm1` approaches 500 lines.
- Test isolation: the envelope validation in `Invoke-DocsCommand.Tests.ps1` imports `DocsSchema.psm1` into a suite that dot-sources the entry script, and `DocsSchema.Tests.ps1` mocks `Test-Json`. The plan must remove the modules in `AfterAll`, never mock `Test-Json` in the entry-script suite, build the composed set in `BeforeAll` without module-scope caching, and keep the seeded shuffled runs of [P6-T5].
- CI-only behavior: `if`/`then`/`else` with `const`, the empty `result` schema and `type: ["string", "null"]` with `pattern` are evaluated by the runner's bundled JsonSchema.Net, which a local run does not prove. The `.gitattributes` LF rule cannot affect the digest tests, because their inputs are in-memory strings with explicit CR characters. The plan must assert only codes, pointers and `Test-Json` booleans, and read the CI result in [P6-T12].
- Evidence: the D1 golden vector must be recorded with write-time UTC stamps under `<FEATURE>/evidence/other/`, with `SCRATCH` and never a host path. The restricted-token scan of [P6-T11] covers the new schema, example and copies.

## Rejected Alternatives (summary)

- Renaming `source_sha256` to `declaration_sha256`: no behavior gain, and it adds churn to 1023 and 1024.
- Hashing line numbers or the range into the digest: a line shift would mark pages stale.
- Adding `analysis_method` to the element identifier: a method change would break ledger pins.
- Adding `analysis_method` to the docs common `diagnostic`: the method is derivable from `analyzers[]`, and the shared shape would change.
- A physically self-contained envelope schema with an inlined `finding`: a second copy of the definition (section 3.2).
- Giving the envelope the artifact header: it would change the key set fixed by AC S17.
- Separate analyzer identifiers for native analyzers (for example `python-cli-native`): profiles would have to name methods, against the epic statement that `inventory` runs the native analyzer for the same four identifiers.

## Items for the Orchestrator to Confirm

1. Anchor renumbering: that `900003` in the spec and plan means 1022 and `900006` means 1024 (the
   epic has neither placeholder; inferred from the epic `## Scope` and naming contract).
2. Owner acceptance that in-memory composition satisfies the D5 "self-contained schemas" fallback
   (section 3.2).
3. Owner acceptance of the `architecture-component` exception (null `line_range`, digest over the
   whole normalized file; section 2.2).
4. The interpretation "per finding" = per ledger entry and per snapshot element, with no method
   field on diagnostics (section 1.1).
5. The registry key (`Id`, `AnalysisMethod`) and the `-NativeAvailable` selection rule, coordinated
   with the 1022 and 900011 preparations (section 1.4).
6. On the `windows-latest` runner's PowerShell: `Test-Json` behavior for `if`/`then`/`else` with
   `const` and `enum`, the empty schema `{}`, `type` arrays with `pattern`, and whether `$` in a
   pattern matches before a trailing newline (the reason for the `(?![\s\S])` suffix in section 5).
7. Epic-level edit: the `### PowerShell contracts from the re-preparation of 1020` bullet "the
   envelope has no schema file", and the 1023 "Open: whether the element digest ..." bullet, are
   settled by D5 and should be updated.
8. Repository state was read from this worktree without `git`; the branch head, and whether `main`
   gained any test that enumerates `schemas/docs/`, need a `git` check.
