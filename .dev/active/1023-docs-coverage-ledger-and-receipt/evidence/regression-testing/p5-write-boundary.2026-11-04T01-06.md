# Suite Evidence: write-boundary proof ([P5-T1])

Timestamp: 2026-11-04T01-06
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders tests/scripts/claude-lib/docs, coverage enabled; counts from artifacts/pester/pester-junit.xml by SCRATCH/issue-1023-pester-summary.ps1)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary: DocsWriteBoundary.Tests.ps1 tests=6 failures=0 errors=0. The run exit 4 is the four Docs.Manifest.Tests.ps1 cases that fail until the new LIB files are mirrored and manifested in Phase 6; no 1023 suite fails (JUnit root: tests=610 failures=4 errors=0).

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` | 6 | 0 | 0 | 0 |

Tests: `reads every library file once` (every `.ps1` and `.psm1` under `.claude/lib/docs`, 19 files, read into memory in `BeforeAll`), `finds no filesystem write primitive outside Write-DocsFileText` (the command primitives `Set-Content`, `Add-Content`, `Out-File`, `New-Item`, `Copy-Item`, `Move-Item`, `Remove-Item`, `Tee-Object`, `Export-Csv`, `Export-Clixml`; write members of `System.IO.File`, `System.IO.FileStream`, `System.IO.StreamWriter` and `System.IO.Directory`; file redirection; the allowlist entry `Invoke-DocsCommand.ps1/Write-DocsFileText` with the reason `init create-only and explicit overwrite`), `invokes a WriteText scriptblock only inside Invoke-DocsArtifactWrite`, `accesses the WriteText member only in DocsLedgerCommands.psm1 among 1023 modules` (in `Invoke-DocsUpdateLedgerCommand` and `Invoke-DocsValidateCommand`, which pass the member on and never invoke it), `references Invoke-DocsArtifactWrite only from DocsLedgerCommands.psm1`, `reports a write call in an in-memory source string` (positive control over four primitive kinds, a read-only function, the invocation, the member access and the reference; a non-parsing source throws).

## Files

- Created `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` (201 lines) with the pure AST helpers `Find-DocsWritePrimitive -SourceText -Path` (records `{Path, Line, Kind, Name, Function}`), `Find-DocsVariableInvocation`, `Find-DocsMemberAccess` and `Find-DocsCommandReference` over `[System.Management.Automation.Language.Parser]::ParseInput`. The helpers emit their records to the pipeline (no comma return) so collection over many files flattens them.

Toolchain on this file: Invoke-Formatter check-only (0 differing), PSScriptAnalyzer with the repository settings per file under timeout (0 findings), parser (0 errors).
