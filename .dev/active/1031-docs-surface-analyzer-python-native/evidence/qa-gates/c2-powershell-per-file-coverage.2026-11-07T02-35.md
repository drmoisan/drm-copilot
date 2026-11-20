# [P3-T8] PowerShell per-file coverage and changed lines

Timestamp: 2026-11-07T02-35
Command: `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pscov.ps1` and `sh SCRATCH/issue-1031-pwsh.sh issue-1031-c2-changed.ps1 -Start CYCLE_START`, both reading artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: each of the five files is at or above 85; LIB/Invoke-DocsCommand.ps1 rose from 87.82 to 87.97; no changed line is missed.

## Line coverage (artifacts/pester/powershell-coverage.xml, written by [P3-T7])

| File | [P0-T4] | Post-change |
|---|---|---|
| `LIB/Invoke-DocsCommand.ps1` | 87.82 (137/156) | 87.97 (139/158) |
| `LIB/DocsAnalyzerPythonNative.psm1` | 100.00 (93/93) | 100.00 (93/93) |
| `LIB/DocsPythonNativeProtocol.psm1` | 100.00 (132/132) | 100.00 (132/132) |
| `LIB/DocsAnalyzerRegistry.psm1` | 100.00 (135/135) | 100.00 (135/135) |
| `LIB/DocsInventory.psm1` | 100.00 (121/121) | 100.00 (121/121) |

Overall line coverage: 95.26 (32371/33981). Every file is at or above 85, and `LIB/Invoke-DocsCommand.ps1` is not below the [P0-T4] figure.

## Changed-line intersection

- Lines changed against `CYCLE_START` that coverage instruments and that executed: 350, 380, 386.
- Missed lines: 214, 216 to 230, 253 to 255 (the bodies of `Invoke-DocsProcess` and the guarded write of `Write-DocsFileText`; `Invoke-DocsProcess` is unexecuted by design).
- Intersection of missed lines with changed lines: empty (S9, U9).
