# [P0-T4] Pester coverage baseline

Timestamp: 2026-11-07T01-33
Command: branch-current Invoke-PoshQCTest with coverage over tests/scripts/claude-lib/docs (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -Paths tests/scripts/claude-lib/docs`); counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: tests 2136, failures 0, errors 0, skipped 0, suites 102. LIB/Invoke-DocsCommand.ps1 line 87.82 (137/156).

## Line coverage (artifacts/pester/powershell-coverage.xml)

| File | Line % (covered/lines) |
|---|---|
| `LIB/Invoke-DocsCommand.ps1` | 87.82 (137/156) |
| `LIB/DocsAnalyzerPythonNative.psm1` | 100.00 (93/93) |
| `LIB/DocsPythonNativeProtocol.psm1` | 100.00 (132/132) |
| `LIB/DocsAnalyzerRegistry.psm1` | 100.00 (135/135) |
| `LIB/DocsInventory.psm1` | 100.00 (121/121) |

Overall line coverage in this scope is 27.17 (9232/33979); the run covers only the docs suites. The missed lines of `LIB/Invoke-DocsCommand.ps1` are the bodies of `Invoke-DocsProcess` and of the guarded write in `Write-DocsFileText`.
