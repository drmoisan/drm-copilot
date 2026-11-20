# Cycle 3 PowerShell static gate (R2)

Timestamp: 2026-11-15T21-27
Command: SCRATCH static.ps1 (Invoke-Formatter drift check with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer with the same settings; Invoke-PoshQCLeakScan -Root) over the changed .ps1 files (classify hook copy, classify Cases, operands Cases)
EXIT_CODE: 0
Output Summary: format check: 0 files drift (exit 0, 0 findings); PSScriptAnalyzer: 0 findings (exit 0); leak scan: 859 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures (exit 0). Type check not applicable for PowerShell. The three other classify copies are byte-identical to the checked copy (same git blob hash).
