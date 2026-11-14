# Upstream Contracts - Issue 1034

Timestamp: 2026-11-04T14-57
Command: Read of .claude/lib/docs/Invoke-DocsCommand.ps1, DocsProfileCommands.psm1, DocsReceipt.psm1, DocsJson.psm1, DocsSurface.psm1, .claude/lib/discovery-validation/DiscoveryEncoding.psm1 and tests/scripts/claude-lib/docs/Docs.TestSupport.psm1; grep -E '^function <name>' over .claude/lib/docs/*.psm1 *.ps1 for each 1020 function; grep of Get-DocsCommandTable, Get-DocsInitTemplate and planned_writes over tests/scripts/claude-lib/docs/
EXIT_CODE: 0
Output Summary: PASS. Both 1034 anchors match the expected text; every 1020 function this plan calls exists; the DocsJson.psm1 and DocsSurface.psm1 import closure is column-0 Import-Module of sibling PowerShell modules only (no runtime import); receipt artifact_kind is docs-validation-receipt. No further suite enumerates the complete subcommand or init planned-write set (none).

## Anchors

- `Get-DocsCommandTable` in `Invoke-DocsCommand.ps1`: `# --- 1034: surface-delta ---` (matches expected), last line of the table literal, after `# --- 1024: generate-reference ---`.
- `Get-DocsInitTemplate` in `DocsProfileCommands.psm1`: `# --- 1034: docs workflow ---` (matches expected), after the five 1021 page-check rows.

## Dispatch Row Options

- `check` (1021): `Profile` = value, `Path` = multi.
- `inventory` (1022): `Profile` = value, `Analyzer` = multi, `Revision` = value, `Write` = switch.
- `validate` (1023): `Profile` = value, `Mode` = value (mode values `profile`, `ledger`, `matrix`, `docs-complete`), `Revision` = value, `WriteReceipt` = switch.

## Receipt Fields (DocsReceipt.psm1)

- `artifact_kind` = `docs-validation-receipt` (matches expected); `mode`; `revision`; `validation_result` in `pass` or `fail`; persisted at profile `artifact_paths.validation_receipt` (default `<estate>/docs-validation-receipt.json`, `DocsProfile.psm1`).

## Defining Module of Each 1020 Function Called

| Function | Module |
|---|---|
| New-DocsCommandResult, New-DocsFinding, Get-DocsOrderedFinding | DocsFinding.psm1 |
| ConvertFrom-DocsJsonText, ConvertTo-DocsCanonicalJson, Get-DocsBytesSha256Hex | DocsJson.psm1 |
| Test-DocsRelativePath, Test-DocsFullRevision | DocsSurface.psm1 |
| ConvertFrom-DocsProfileText, Get-DocsDefaultProfilePath | DocsProfile.psm1 |
| Get-DocsComposedSchemaSet, Test-DocsArtifactText | DocsSchema.psm1 |
| Get-DocsInitTemplate, Invoke-DocsInitCommand | DocsProfileCommands.psm1 |
| Get-DocsCommandTable, Test-DocsCommandTable, New-DocsCommandContext, Invoke-DocsProcess, ConvertTo-DocsProcessRequest, ConvertTo-DocsProcessResult, Invoke-DocsCommandCli | Invoke-DocsCommand.ps1 |

## New-DocsTestContext Parameters

`File` (IDictionary, AllowNull), `UtcNow` (datetime, default 2026-01-01T00:00:00Z), `ProcessResult` (IDictionary, AllowNull), `RepositoryRoot` (string, default `in-memory-repository`). Returns `@{ Context; Files; WriteLog; ProcessCallLog }`; context members `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`, `InvokeProcess`.

## Import Closure

- `DocsJson.psm1`: `Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../discovery-validation/DiscoveryEncoding.psm1') -ErrorAction Stop` (column 0).
- `DocsSurface.psm1`: column-0 imports of `DocsJson.psm1` and `DocsFinding.psm1`.
- `DiscoveryEncoding.psm1`: no import statement.
- No runtime (Python or other interpreter) import in the closure.

## Further Enumerating Assertions in tests/scripts/claude-lib/docs/

- Complete subcommand set: none. `DocsLedgerCommands.Tests.ps1`, `DocsInventory.Tests.ps1`, `DocsPageCheck.Tests.ps1` and `Invoke-DocsCommand.Tests.ps1` assert membership of named rows and `Test-DocsCommandTable` emptiness only.
- Complete init planned-write set: none. `DocsProfileCommands.Tests.ps1` uses a membership loop; `DocsPageTemplates.Tests.ps1` uses `Should -Contain` (dispositions already named in the plan).
