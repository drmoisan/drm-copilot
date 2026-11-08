# 1020 Precondition Verification ([P0-T1])

Timestamp: 2026-11-03T21-42
Command: git merge-base --is-ancestor origin/epic/documentation-estate-tooling-integration HEAD; file presence checks (test -f), byte comparisons (cmp) between LIB and BUNDLE copies, grep for `^function <Name>` over LIB, grep -c for the 1023 anchor, and reads of the schema files, DocsFinding.psm1, Invoke-DocsCommand.ps1, Docs.TestSupport.psm1 and Invoke-DocsCommand.Tests.ps1 (read-only; nothing written to the tree)
EXIT_CODE: 0
Output Summary: every row PRESENT; the envelope `command` constraint admits `coverage`, `update-ledger` and `validate`; the run continues. The merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD` equals `HEAD` (the branch was cut from the integration head that carries the merged 1020 surface, PR #1063).

Terms: `LIB` = `.claude/lib/docs`; `BUNDLE` = `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs`; `TESTS` = `tests/scripts/claude-lib/docs`.

## Checks

| Check | Result |
|---|---|
| `git merge-base --is-ancestor origin/epic/documentation-estate-tooling-integration HEAD` exits 0 | PRESENT (exit 0) |
| `LIB/DocsJson.psm1` | PRESENT |
| `LIB/DocsFinding.psm1` | PRESENT |
| `LIB/DocsSchema.psm1` | PRESENT |
| `LIB/DocsSurface.psm1` | PRESENT |
| `LIB/DocsAnalyzerRegistry.psm1` | PRESENT |
| `LIB/DocsProfile.psm1` | PRESENT |
| `LIB/DocsProfileCommands.psm1` | PRESENT |
| `LIB/Invoke-DocsCommand.ps1` | PRESENT |
| `BUNDLE/DocsJson.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/DocsFinding.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/DocsSchema.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/DocsSurface.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/DocsAnalyzerRegistry.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/DocsProfile.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/DocsProfileCommands.psm1` (byte-identical to LIB) | PRESENT |
| `BUNDLE/Invoke-DocsCommand.ps1` (byte-identical to LIB) | PRESENT |
| `schemas/docs/v1/common.schema.json` | PRESENT |
| `schemas/docs/v1/docs-profile.schema.json` | PRESENT |
| `schemas/docs/v1/surface-inventory-snapshot.schema.json` | PRESENT |
| `schemas/docs/v1/docs-coverage-ledger.schema.json` | PRESENT |
| `schemas/docs/v1/docs-parity-matrix.schema.json` | PRESENT |
| `schemas/docs/v1/docs-evidence-pin.schema.json` | PRESENT |
| `schemas/docs/v1/docs-validation-receipt.schema.json` | PRESENT |
| `schemas/docs/v1/docs-command-envelope.schema.json` | PRESENT |
| `LIB/schemas/v1/` holds the same eight files | PRESENT |
| Snapshot `$defs/element` lists `analysis_method` in `required` | PRESENT |
| Ledger `$defs/entry` lists `analysis_method` in `required` | PRESENT |
| Snapshot `analyzers[]` items (`$defs/analyzer`) carry `analysis_method` (required) | PRESENT |
| Docs common defines `analysis-method` (`enum: ["native", "scanner"]`) | PRESENT |
| Docs common defines `extensions` (patternProperties key `^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$`, value `json-value`) | PRESENT |
| `Get-DocsSchemaName` includes `docs-command-envelope` | PRESENT (after `docs-validation-receipt`, before the 1021 anchor) |
| `ConvertFrom-DocsJsonText` | PRESENT (DocsJson.psm1) |
| `ConvertTo-DocsJsonText` | PRESENT (DocsJson.psm1) |
| `ConvertTo-DocsCanonicalJson` | PRESENT (DocsJson.psm1) |
| `Get-DocsSha256Hex` | PRESENT (DocsJson.psm1) |
| `Get-DocsBytesSha256Hex` | PRESENT (DocsJson.psm1) |
| `New-DocsFinding` | PRESENT (DocsFinding.psm1) |
| `Get-DocsChildPointer` | PRESENT (DocsFinding.psm1) |
| `Get-DocsOrderedFinding` | PRESENT (DocsFinding.psm1) |
| `Test-DocsFindingHasError` | PRESENT (DocsFinding.psm1) |
| `New-DocsCommandResult` | PRESENT (DocsFinding.psm1) |
| `Read-DocsSchemaSet` | PRESENT (DocsSchema.psm1) |
| `Get-DocsComposedSchemaSet` | PRESENT (DocsSchema.psm1) |
| `Test-DocsArtifactText` (artifact kinds plus `docs-command-envelope`) | PRESENT (DocsSchema.psm1; the composed set holds every non-common schema name, including the envelope) |
| `Get-DocsElementKind` | PRESENT (DocsSurface.psm1) |
| `Get-DocsAnalysisMethod` | PRESENT (DocsSurface.psm1) |
| `Test-DocsRelativePath` | PRESENT (DocsSurface.psm1) |
| `Test-DocsFullRevision` | PRESENT (DocsSurface.psm1) |
| `Get-DocsStableId` | PRESENT (DocsSurface.psm1) |
| `Get-DocsElementId` | PRESENT (DocsSurface.psm1) |
| `Test-DocsElementId` | PRESENT (DocsSurface.psm1) |
| `ConvertFrom-DocsSurfaceElement` | PRESENT (DocsSurface.psm1) |
| `Get-DocsDefaultProfilePath` | PRESENT (DocsProfile.psm1) |
| `ConvertFrom-DocsProfileText` | PRESENT (DocsProfile.psm1) |
| `Get-DocsCommandTable` | PRESENT (Invoke-DocsCommand.ps1) |
| `Test-DocsCommandTable` | PRESENT (Invoke-DocsCommand.ps1) |
| `ConvertFrom-DocsCommandArgument` | PRESENT (Invoke-DocsCommand.ps1) |
| `New-DocsCommandContext` | PRESENT (Invoke-DocsCommand.ps1) |
| `Write-DocsFileText` | PRESENT (Invoke-DocsCommand.ps1) |
| `Invoke-DocsCommandCli` | PRESENT (Invoke-DocsCommand.ps1) |
| `ConvertTo-DocsEnvelopeText` | PRESENT (DocsFinding.psm1) |
| `ConvertTo-DocsReportText` | PRESENT (DocsFinding.psm1) |
| `New-DocsDiagnostic` | PRESENT (DocsSurface.psm1) |
| Anchor `# --- 1023: coverage, update-ledger, validate ---` occurs once in `LIB/Invoke-DocsCommand.ps1` with no row beneath it | PRESENT (count 1; the next line is the 1024 anchor) |
| Anchor occurs once in `BUNDLE/Invoke-DocsCommand.ps1` with no row beneath it | PRESENT (count 1; the next line is the 1024 anchor) |
| `TESTS/Docs.TestSupport.psm1` | PRESENT |
| `TESTS/Invoke-DocsCommand.Tests.ps1` | PRESENT |
| `TESTS/Docs.Manifest.Tests.ps1` | PRESENT |
| `TESTS/DocsNeutrality.Tests.ps1` | PRESENT |
| Envelope schema `command` constraint admits `coverage`, `update-ledger`, `validate` | PRESENT (`type: ["string", "null"]`, pattern `^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$(?![\s\S])`; all three names match) |

No row is MISSING or RENAMED.

## Facts recorded for later tasks

- Exports of `TESTS/Docs.TestSupport.psm1`: `Get-DocsTestRepositoryRoot`, `Get-DocsTestSchemaText` (ordered map of schema name to text read from `LIB/schemas/v1/*.schema.json`), `Get-DocsTestExampleText` (ordered map of example name to text from `examples/docs/v1/*.example.json`), and `New-DocsTestContext` (returns `@{ Context; Files; WriteLog; ProcessCallLog }`; parameters `-File <IDictionary>` path-to-text, `-UtcNow <datetime>` defaulting to 2026-01-01T00:00:00 Kind Utc, `-ProcessResult`, `-RepositoryRoot`; `ReadText`/`ReadBytes` of an absent path throw `ItemNotFoundException`; `WriteText` with mode `create` on an existing path throws, otherwise records `{ RelativePath; Text; Mode }` in `WriteLog` and stores the text so a later read returns it; `ListFile` returns the ordinal-sorted keys under `<root>/`).
- How 1020 command functions obtain the composed schema set: `DocsProfileCommands.psm1` defines the private (non-exported) helper `Get-DocsCommandSchemaSet`, which returns `(Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet)).Schemas` and throws `DOCS_SCHEMA_COMPOSITION_FAILED: <code> <message>` when the composition reports a finding. `Read-DocsSchemaSet` with no arguments reads the runtime copies through `Get-DocsSchemaPath` (literal `$PSScriptRoot` joins). Because the helper is private, 1023 defines its own equivalent in `DocsLedgerCommands.psm1`. Tests compose the set with `Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)` and use `.Schemas`.
- `Write-DocsFileText` mode `create` on an existing file (R3): it fails. Mode `create` maps to `[System.IO.FileMode]::CreateNew`, which throws `System.IO.IOException` when the file exists; mode `overwrite` maps to `FileMode.Create`. The function supports ShouldProcess. The in-memory `WriteText` of `Docs.TestSupport.psm1` throws on `create` of an existing path as well.
- `ConvertFrom-DocsCommandArgument` value for repeated `multi` tokens: every occurrence is appended, in argument order, to a `[string[]]` stored under the option's spec spelling (for example `-Page a -Page b` gives `@('a', 'b')`; a single occurrence gives a one-element `[string[]]`). The parser does not reject a repeated value for a `multi` option (a repeated non-multi option is a usage error), so the "repeated `-Page` value" rule of 1023 belongs to `Test-DocsUpdateLedgerArgument`. Option names match case-insensitively; a `switch` stores `$true`.
- `FINDINGS_LIMIT`: severity `error`; `Get-DocsOrderedFinding -Limit` defaults to 100 (`ValidateRange(1, 10000)`); when more than `Limit` distinct findings remain, the first `Limit` are kept and one `FINDINGS_LIMIT` error finding is appended (message `Findings were truncated to <Limit> of <total>.`). `New-DocsCommandResult` orders findings with the default limit (100); the envelope schema sets `maxItems: 101` on `findings`.
- `Invoke-DocsCommand.Tests.ps1` assertions: no row-count assertion and no exact row-set assertion on `Get-DocsCommandTable`. It asserts `Test-DocsCommandTable` returns no finding for the committed table; anchor order from the script text (1020, 1021, 1022, 1023, 1024, 1034), no `# --- 900NNN:` and no `# --- 1031:` anchor, `Name = 'init'` after the 1020 anchor and `Name = 'validate-profile'` before the 1021 anchor; help text only through `-Match 'validate-profile'` and `usage` count greater than 1. Disposition for [P4-T2]: Unchanged (the 1023 rows under the 1023 anchor violate none of these).
- Envelope schema `command` constraint: `{"type": ["string", "null"], "pattern": "^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$(?![\\s\\S])"}`; `exit_code` enum 0-3; exit 0 requires `ok` true and only `warning`/`info` findings; exit 1 requires at least one finding; exit 2 and 3 require exactly one finding and `result` null; `result` is otherwise unconstrained.
- Other facts used by Phases 1-2: `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Severity] [-Blocking]` returns an ordered record whose `extensions` member is an empty `[ordered]@{}` (a caller sets the `docs.precision-limit` key afterwards); its `id` is `Get-DocsStableId -Prefix 'diagnostic' -Value [ordered]@{ analyzer; code; path }`. `ConvertFrom-DocsSurfaceElement` throws `DOCS_IDENTITY_INPUT_INVALID` for a missing identity field or an unknown `analysis_method` and `DOCS_ELEMENT_ID_MISMATCH` for a tampered id. `New-DocsFinding` sorts and de-duplicates `-RelatedId` and `-RelatedPath` ordinally and rejects a related id outside the identifier grammar. `Test-DocsArtifactText` throws `DOCS_SCHEMA_UNKNOWN_KIND` for a kind outside the composed set. The structural walk (`DocsSchemaWalk.psm1`) covers `patternProperties`, so a non-empty `extensions` object validates. `ConvertFrom-DocsJsonText` returns ordinal `[hashtable]` objects (`.Contains`), `Int64` integers and `object[]` arrays. Docs common `docs-artifact-kind` enumerates the six artifact kinds only (the envelope is not pinnable).
