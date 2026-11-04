# TARGET RD1 Structure and MOCKED Scan (P2-T1)

Timestamp: 2026-11-04T01-20
Command: pwsh -NoProfile -File SCRATCH/issue-1066-rd1-scan.ps1 -Path tests/scripts/dev-tools/run-actionlint.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Parse errors: 0.
- Top-level statements: 2 (`Set-StrictMode -Version Latest`, `Describe "run-actionlint.ps1"`); outside the Describe only the Set-StrictMode statement remains.
- Statements directly in the Describe: BeforeAll 1, AfterAll 1, BeforeEach 1, AfterEach 1.
- Capture statements found: 2 (`$script:describeHadImportScriptFunction`, `$script:describeHadArchiveModule`); TestHelpers.ps1 dot-source statements: 1 (path built with `[System.IO.Path]::GetFullPath` and `[System.IO.Path]::Combine` from `$PSScriptRoot`).
- Commands called (AST CommandAst names) and MOCKED hits:
  - AfterAll: Get-Module, Remove-Module; MOCKED hits: none (function removal uses `$ExecutionContext.SessionState.InvokeProvider.Item`).
  - Capture statements: Get-Module; MOCKED hits: none.
  - Dot-source expression: no command; MOCKED hits: none.
- MOCKED hits total: 0. MOCKED = Split-Path, Resolve-Path, Join-Path, Get-Command, Write-Information, New-Item, Invoke-WebRequest, Expand-Archive, Remove-Item, Test-Path, Write-Output, Write-Error, Invoke-ActionlintExe.
- TARGET physical lines after RD1: 554. No It block and no Context mock changed.
