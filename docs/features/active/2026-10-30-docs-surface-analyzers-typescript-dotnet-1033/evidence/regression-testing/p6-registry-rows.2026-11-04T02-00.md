# Phase 6 registry rows and membership suite ([P6-T1])

Timestamp: 2026-11-04T02-00
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs` in one process; preceded in the same loop pass by `Invoke-PoshQCFormat` over `.claude/lib/docs,tests/scripts/claude-lib/docs` (59 files, every one reported `Already formatted`, no file changed) and a direct `Invoke-ScriptAnalyzer` run with the repository settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, one call per file with one retry, over the same two folders through SCRATCH/issue-1033-pssa-files.ps1 (59 files, 0 findings)); counts read from artifacts/pester/pester-junit.xml
EXIT_CODE: 4
Output Summary: `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1`: tests=12, failures=0, errors=0 (JUnit `testsuite` element). Whole folder `tests/scripts/claude-lib/docs`: tests=683, failures=4 (1020's `Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]), errors=0, skipped=0; exit 4 reflects those four failures.

## Edit made

Seven rows inserted into `.claude/lib/docs/DocsAnalyzerRegistry.psm1`, one per line, directly under the anchor line `# --- 1033: TypeScript and .NET analyzers ---` of the scanner table `$script:DocsAnalyzerRow` and before the table's closing parenthesis, in the 1020 row form `[pscustomobject]@{ Id; Version; AnalysisMethod; ElementKinds; Module; Function }` with `Version = '1.0.0'`, `AnalysisMethod = 'scanner'` and `Module = (Join-Path -Path $PSScriptRoot -ChildPath '<leaf>')`: `typescript-cli` (`cli-command`, `cli-option`; `DocsAnalyzerTypeScriptCli.psm1`; `Invoke-DocsAnalyzerTypeScriptCli`), `typescript-http` (`http-route`; `DocsAnalyzerTypeScriptHttp.psm1`; `Invoke-DocsAnalyzerTypeScriptHttp`), `typescript-exports` (`public-symbol`; `DocsAnalyzerTypeScriptExports.psm1`; `Invoke-DocsAnalyzerTypeScriptExports`), `dotnet-http` (`http-route`; `DocsAnalyzerDotnetHttp.psm1`; `Invoke-DocsAnalyzerDotnetHttp`), `dotnet-config` (`config-key`; `DocsAnalyzerDotnetConfig.psm1`; `Invoke-DocsAnalyzerDotnetConfig`), `dotnet-public-api` (`public-symbol`; `DocsAnalyzerDotnetApi.psm1`; `Invoke-DocsAnalyzerDotnetApi`), `extension-import` (`cli-command`, `cli-option`, `http-route`, `config-key`, `public-symbol`, `architecture-component`; `DocsAnalyzerExtensionImport.psm1`; `Invoke-DocsAnalyzerExtensionImport`). No other line of the module changed; no anchor comment changed; no row under the 1022 or 1031 anchor and none in `$script:DocsAnalyzerNativeRow` (`git diff` of the module shows seven added lines only).

## Existing-test search (tests/scripts/claude-lib/docs for `Get-DocsAnalyzerRegistration`, `Select-DocsAnalyzerRegistration`, `DocsAnalyzerRow`, `TypeScript and .NET analyzers`)

| Match | Disposition |
|---|---|
| `DocsAnalyzerRegistry.Tests.ps1` (`$script:DocsAnalyzerRow = @(` and the 1033 anchor in the anchor-order test; `variable:script:DocsAnalyzerRow` in the module-scope test; `Get-DocsAnalyzerRegistration` without `-ScannerRow`/`-NativeRow` once, in `reports no finding for the committed registry`; every other `Get-DocsAnalyzerRegistration` and `Select-DocsAnalyzerRegistration` call passes in-memory rows) | unchanged: [P0-T4] C6 records NONE (membership-only suite, 1020 v0.6); the committed-registry assertion is a finding count of `Test-DocsAnalyzerRegistration`, which the seven valid rows keep at 0; the suite passed 30/30 in this run |
| `DocsProfile.Tests.ps1` `DOCS_ANALYZER_UNKNOWN` case | unchanged: its unknown identifier is `unregistered-analyzer`, none of the seven |
| 1022 suites | none present on the branch (no `DocsAnalyzerPython*` or `DocsInventory*` suite under `T`) |
| `DocsAnalyzerExtensionImport.Tests.ps1` (this feature; `Get-DocsAnalyzerRegistration` in the registry-seam test) | unchanged: asserts `Test-DocsAnalyzerRegistration` reports no finding and the registry stays callable, which holds with the rows |

## Tests (`DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1`, 12, membership only)

The module text carries the 1033 anchor line between `$script:DocsAnalyzerRow = @(` and `$script:DocsAnalyzerNativeRow = @(`; no line matches `# --- 900[0-9]{3}:` while the positive control `# --- 900011: placeholder ---` does; for each of the seven identifiers `Get-DocsAnalyzerRegistration` contains exactly one row found by `Id` and `AnalysisMethod` `scanner` with `Version` `1.0.0`, the specified module leaf, function and element kinds; none of the seven equals `python-cli`, `python-http`, `python-public-api`, `config-files` or `python-architecture`; `Test-DocsAnalyzerRegistration` returns no finding; each of the seven `Id = '<id>'` tokens appears once in the module text, after the 1033 anchor and before the next anchor or the end of the scanner table. No row count and no exclusivity assertion over the committed tables.

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1` | 12 | 0 | 0 | 0 |
| `DocsAnalyzerRegistry.Tests.ps1` (1020, unmodified) | 30 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs` (whole folder) | 683 | 4 (`Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]) | 0 | 0 |
