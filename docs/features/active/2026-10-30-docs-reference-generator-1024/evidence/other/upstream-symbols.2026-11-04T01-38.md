# Upstream Symbol Confirmation (issue 1024)

Timestamp: 2026-11-04T01-38
Task: [P0-T3]
Command: grep of function, Export-ModuleMember and param blocks in .claude/lib/docs/*.psm1, .claude/lib/docs/Invoke-DocsCommand.ps1, tests/scripts/claude-lib/docs/Docs.TestSupport.psm1 and schemas/docs/v1/*.schema.json on the branch (HEAD equals the integration branch tip); Read of each signature
EXIT_CODE: 0
Output Summary: Every symbol of spec `### Upstream symbols consumed` is present except the conditional `Get-DocsPageComposedSchemaSet`, which is absent because 1020 composes page-metadata (GATE-B does not hold). No design-changing difference; no BLOCKED record.

## 1020 symbols

| Symbol | State | Module | Signature (confirmed) |
|---|---|---|---|
| `ConvertFrom-DocsJsonText` | present | `DocsJson.psm1` | `-Text <string> [-ArtifactPath <string>] [-MaxDepth <int>]` returns `@{ Value; Findings }` |
| `ConvertTo-DocsJsonText` | present | `DocsJson.psm1` | `-Value <object> [-Indented]`, sorted keys, one trailing LF |
| `ConvertTo-DocsCanonicalJson` | present | `DocsJson.psm1` | `-Value <object>`, compact, sorted keys, trailing LF |
| `Get-DocsSha256Hex` | present | `DocsJson.psm1` | `-Text <string>` |
| `Get-DocsBytesSha256Hex` | present | `DocsJson.psm1` | `-Bytes <byte[]>` |
| `New-DocsFinding` | present | `DocsFinding.psm1` | `-Code -Severity (error, warning, info) -Message -NextAction [-ArtifactPath] [-Pointer] [-RelatedId] [-RelatedPath]` |
| `Get-DocsOrderedFinding` | present | `DocsFinding.psm1` | `-Finding <object[]> [-Limit <int> = 100]` |
| `Test-DocsFindingHasError` | present | `DocsFinding.psm1` | `-Finding <object[]>` |
| `New-DocsCommandResult` | present | `DocsFinding.psm1` | `-Command -ExitCode (0..3) -Finding [-Result] [-Line]` |
| `ConvertTo-DocsEnvelopeText` | present | `DocsFinding.psm1` | `-CommandResult` |
| `ConvertTo-DocsReportText` | present | `DocsFinding.psm1` | `-CommandResult` |
| `Read-DocsSchemaSet` | present | `DocsSchema.psm1` | `[-SchemaPath <IDictionary>] [-ReadText <scriptblock>]` |
| `Get-DocsComposedSchemaSet` | present | `DocsSchema.psm1` | `-SchemaSet <IDictionary>` returns `@{ Schemas; Findings }` |
| `Join-DocsSchemaText` | present | `DocsSchema.psm1` | `-SchemaText -CommonSchemaText` |
| `Test-DocsArtifactText` | present | `DocsSchema.psm1` | `-ArtifactKind -JsonText -ComposedSchemaSet [-ArtifactPath]`; `docs-command-envelope` and `surface-inventory-snapshot` are composed kinds (in `Get-DocsSchemaName`) |
| `Get-DocsElementKind` | present | `DocsSurface.psm1` | no parameters; six kinds |
| `Test-DocsRelativePath` | present | `DocsSurface.psm1` | `-Path <string>` |
| `Get-DocsElementId` | present | `DocsSurface.psm1` | `-Kind -Path -Declaration` |
| `Test-DocsElementId` | present | `DocsSurface.psm1` | `-ElementId <string>` |
| `ConvertFrom-DocsSurfaceElement` | present | `DocsSurface.psm1` | `-Record <IDictionary>`; throws `DOCS_IDENTITY_INPUT_INVALID` or `DOCS_ELEMENT_ID_MISMATCH` |
| `New-DocsSurfaceElement` | present | `DocsSurface.psm1` | `-Kind -Path -Declaration -Name -AnalyzerId -AnalysisMethod -SourceText [-ParentId] [-LineRange] [-Property] [-Extension]` |
| `ConvertFrom-DocsProfileText` | present | `DocsProfile.psm1` | `-Text -ArtifactPath -ComposedSchemaSet [-AnalyzerId]` returns `@{ Profile; Findings; Ok }` |
| `Get-DocsDefaultProfilePath` | present | `DocsProfile.psm1` | returns `docs/documentation-estate/docs-profile.json` |
| `Get-DocsCommandTable` | present | `Invoke-DocsCommand.ps1` | no parameters |
| `Test-DocsCommandTable` | present | `Invoke-DocsCommand.ps1` | `-Table <object[]>` |
| `ConvertFrom-DocsCommandArgument` | present | `Invoke-DocsCommand.ps1` | `-CommandArgument <string[]> -OptionSpec <IDictionary>` |
| `New-DocsCommandContext` | present | `Invoke-DocsCommand.ps1` | `-RepositoryRoot <string>`; members `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`, `InvokeProcess` |
| `Write-DocsFileText` | present | `Invoke-DocsCommand.ps1` | `-FullPath -Text -Mode (create, overwrite)` |
| `Invoke-DocsCommandCli` | present | `Invoke-DocsCommand.ps1` | `[-Command] [-Json] [-Help] [-RepositoryRoot] [-CommandArgument] [-Context] [-CommandFunction] [-PowerShellVersion]` returns `@{ ExitCode; Stdout; Stderr }` |
| Anchor `# --- 1024: generate-reference ---` | present exactly once | `Invoke-DocsCommand.ps1` (`Get-DocsCommandTable`) | no row under it yet |
| Anchor beginning `# --- 900` | absent (0 lines) | `Invoke-DocsCommand.ps1` | as required |
| `schemas/docs/v1/docs-command-envelope.schema.json` | present | schema | `$id` `urn:drm-copilot:docs:1.0.0:docs-command-envelope` |
| `analysis_method`, `source_sha256` (declaration-lines digest) on snapshot elements | present | `surface-inventory-snapshot.schema.json` | both required element properties |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` | present | test support | exports `Get-DocsTestRepositoryRoot`, `Get-DocsTestSchemaText`, `Get-DocsTestExampleText`, `New-DocsTestContext` |
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | present | test | manifest parity |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | present | test | neutrality suite (`Describe 'Docs framework files'`) |

## 1021 symbols

| Symbol | State | Module | Signature (confirmed) |
|---|---|---|---|
| `ConvertFrom-DocsPageFrontMatter` | present | `DocsPageFrontMatter.psm1` | `-Text <string> -PagePath <string>` returns `@{ Present; Terminated; Value; FieldLine; BodyStartLine; Findings }` |
| `Test-DocsPageFrontMatter` | present | `DocsPageFrontMatter.psm1` | `-FrontMatter <IDictionary> -PagePath <string> -ComposedSchemaSet <IDictionary> -RequiredField <string[]> -AudienceId <string[]> [-FieldLine <IDictionary>]` |
| `Get-DocsPageComposedSchemaSet` | absent (not exported, not defined anywhere under `.claude` or `tests`) | `DocsPageFrontMatter.psm1` | conditional symbol; its absence is consistent with GATE-B not holding |
| `Get-DocsPageFenceLine` | present | `DocsPageMarkdown.psm1` | `-Line <string>` returns `$null` or `[ordered]@{ FenceCharacter; FenceLength; Info }` |
| `Test-DocsPageFenceClose` | present | `DocsPageMarkdown.psm1` | `-Fence <IDictionary> -OpenFence <IDictionary>` returns `[bool]` |
| `Get-DocsPageLineModel` | present | `DocsPageMarkdown.psm1` | `-Line <string[]> [-FirstLineNumber <int>]` |
| `Get-DocsPageCheckFinding` | present | `DocsPageCheck.psm1` | `-PageText -Profile -ProfilePath -ComposedSchemaSet -ExistingPath [-SelectedPath] [-LinkMap]` returns `@{ Findings; Result }` |
| `check` dispatch row | present | `Invoke-DocsCommand.ps1` | options `Profile` (value) and `Path` (multi) only |
| `DOCS_PAGE_MODE_INSTRUCTION_HEADING` | present | `DocsPageDiataxis.psm1` | instructional heading rule |
| `DOCS_PAGE_ORPHAN` | present | `DocsPageOrphans.psm1` | orphan rule |
| Entry pages | present | `DocsPageOrphans.psm1` `Get-DocsPageEntryPage` | `<root>/README.md`, else `<root>/index.md` |
| `schemas/docs/v1/page-metadata.schema.json` | present | schema | `$id` `urn:drm-copilot:docs:1.0.0:page-metadata`; runtime copy `.claude/lib/docs/schemas/v1/page-metadata.schema.json` has the same SHA-256 |

## Recorded decisions

- GATE-B: does not hold. `page-metadata` is listed in `Get-DocsSchemaName` under `# --- 1021: page-metadata ---` and in `Get-DocsSchemaPath`, so `Get-DocsComposedSchemaSet` composes it, and `Get-DocsPageComposedSchemaSet` does not exist. COMPOSED-SET is the `Schemas` map of `Get-DocsComposedSchemaSet` without further transformation.
- C2 (pending item, now observed): `WriteText` mode `create` on an existing target throws (real context: `Write-DocsFileText` opens `FileMode.CreateNew`; in-memory `New-DocsTestContext` throws). The real `Write-DocsFileText` creates parent directories (`CreateDirectory`). `ReadBytes` is a context member. `ReadText` decodes strictly (`ConvertFrom-DocsUtf8Bytes` uses a throwing UTF-8 decoder) and throws `ItemNotFoundException` for an absent path.
- C8 (pending item, now observed): resolved; `page-metadata` is registered in `Get-DocsSchemaName` and `Get-DocsSchemaPath`, and the runtime copy is byte-identical to the canonical schema.
- Schema paths read by `Read-DocsSchemaSet` (for [P1-T1]): one path per name of `Get-DocsSchemaName`, each `.claude/lib/docs/schemas/v1/<name>.schema.json` (names `common`, `docs-profile`, `surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`, `docs-validation-receipt`, `docs-command-envelope`, `page-metadata`). `Get-DocsSchemaPath` returns these joined to `$PSScriptRoot` (absolute); a context-based read passes the repository-relative form through `-SchemaPath` and `-ReadText`.
- OQ-2: `Test-DocsPathCovered` does not exist in `DocsSurface.psm1` (nor elsewhere under `.claude/lib`), so [P3-T1] creates `Test-DocsReferencePathCovered` in `DocsReferencePlan.psm1`.
- Test-support placement: `Docs.TestSupport.psm1` exposes no generator hook, so [P1-T1] creates `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1`.
- Open item (c): `Test-DocsPageFrontMatter -RequiredField` is declared `[Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]]`, so an empty array binds. No BLOCKED record.
- Runtime probe (PowerShell 7.6, helper script under SCRATCH): `Get-DocsComposedSchemaSet` over `Read-DocsSchemaSet` returned zero composition findings and composed kinds including `page-metadata` and `docs-command-envelope`; `Test-DocsPageFrontMatter -RequiredField @() -AudienceId @()` over `{ owner }` bound and returned zero findings; `ConvertFrom-DocsPageFrontMatter` parsed `<key>: <JSON value>` lines with zero findings.
- Open item (a) and (b) are kept as recorded in the plan; no observation changes them.
