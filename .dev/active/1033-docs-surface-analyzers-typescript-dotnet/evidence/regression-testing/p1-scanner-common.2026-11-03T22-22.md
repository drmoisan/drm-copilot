# Phase 1 scanner common suite ([P1-T1], [P1-T2])

Timestamp: 2026-11-03T22-22
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs` in one process; preceded by `Invoke-PoshQCFormat` over `.claude/lib/docs,tests/scripts/claude-lib/docs` (0 files formatted) and a direct `Invoke-ScriptAnalyzer` run with the repository settings (0 findings)); counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml
EXIT_CODE: 4
Output Summary: `DocsScannerCommon.Tests.ps1`: tests=26, failures=0, errors=0 (JUnit `testsuite` element for the suite). Whole folder `tests/scripts/claude-lib/docs`: tests=412, failures=4, errors=0, skipped=0; the four failures are all in 1020's `Docs.Manifest.Tests.ps1` (`Docs core.json manifest membership`: core.json listing and bundled counterpart of the new `DocsScannerCommon.psm1`), which the plan satisfies in [P6-T5] (bundle copy) and [P6-T6] (core.json entry) and re-runs in [P6-T7]; exit 4 reflects those four failures. Line coverage of `.claude/lib/docs/DocsScannerCommon.psm1` in this run: 97.77% (175 of 179 lines). Logical line count of the module: 498 (at most 500). Seed: not applicable (C2 row of [P0-T4]: 1020 exports `ConvertTo-DocsDeclarationText` and `Get-DocsDeclarationSha256`, so no fallback digest function and no seeded digest property test were created in this task; the digest properties are proven over 1020's functions by [P6-T4]).

## Files created

- `.claude/lib/docs/DocsScannerCommon.psm1` (498 logical lines): `Select-DocsScannerInput`, `Get-DocsScannerModulePath`, `Get-DocsScannerMatchingClose`, `Get-DocsScannerCallArgument`, `Get-DocsScannerLiteral`, `Join-DocsRouteTemplate`, `New-DocsScannerDiagnosticSet`, `Add-DocsScannerDiagnostic`, `ConvertTo-DocsScannerDiagnostic`, `New-DocsScannerPrecisionLimitDiagnostic`, `Get-DocsScannerPrecisionLimit`, plus two refinement helpers shared by every analyzer: `Get-DocsScannerInputDiagnosticCode` (maps a captured input with `text` `$null` to `INPUT_OVER_BOUND` or `INPUT_UNDECODABLE`) and `ConvertTo-DocsScannerElementList` (first-site-by-line de-duplication with `DUPLICATE_DECLARATION`, sorted by `element_id`). Neither `Get-DocsScannerDeclarationText` nor `Get-DocsDeclarationSha256` is created (C2).
- `tests/scripts/claude-lib/docs/Docs.ScannerTestSupport.psm1`: `New-DocsTestCapturedInput -Path -Text [-LineEnding LF|CRLF] [-Bom]`, `New-DocsTestOversizeInput -Path` (1048577 bytes), `New-DocsTestUndecodableInput -Path`, `New-DocsTestFinding`, `New-DocsTestExtensionManifest`, `ConvertTo-DocsTestOutputText`, `Get-DocsTestShuffled -Item -Seed`; no file read or written, no TestDrive, no module-scope cache.
- `tests/scripts/claude-lib/docs/DocsScannerCommon.Tests.ps1`: one `Context` per function (26 tests), including the precision-limit table assertions (five keys, ordering, registered identifiers and kinds, `typescript-cli` rows carry `cli-command`, no `EXTENSION_FINDING_SKIPPED` row), the marker builder assertions (severity `warning`, `blocking` `$false`, marker whose only key is `element_kind`, pre-existing `extensions` key kept with `New-DocsDiagnostic` mocked in the module scope, throws for `$null` and empty `-Path` and for `-ElementKind` `not-a-kind`), and the routing assertions of `ConvertTo-DocsScannerDiagnostic` (`CLI_DYNAMIC_REGISTRATION` under `typescript-cli` gives `cli-command`; `DUPLICATE_DECLARATION`, `INPUT_OVER_BOUND`, and `HTTP_DYNAMIC_ROUTE` under `typescript-exports` carry no marker).

Codes follow the [P0-T4] C7 adopted spelling (`^[A-Z][A-Z0-9_]*$`).

## Counts

| Scope | tests | failures | errors | skipped |
|---|---|---|---|---|
| `DocsScannerCommon.Tests.ps1` | 26 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs` (whole folder) | 412 | 4 (`Docs.Manifest.Tests.ps1`, expected until [P6-T5] and [P6-T6]) | 0 | 0 |
