# PowerShell QA Gates

## Command 1
Timestamp: 2026-03-02T00:55:30Z
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
EXIT_CODE: 0
Output Summary: PoshQC formatter passed; all scanned files (including extension bundled PowerShell script) already formatted.

## Command 2
Timestamp: 2026-03-02T00:56:10Z
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
EXIT_CODE: 0
Output Summary: PSScriptAnalyzer passed with no findings.

## Command 3
Timestamp: 2026-03-02T00:56:24Z
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary: Pester passed (217 passed, 0 failed, 7 skipped); coverage artifacts written.
