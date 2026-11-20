# PowerShell QA Gate Evidence

## Run 1 — Targeted verification

Timestamp: 2026-02-22T01:30:00-05:00
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary:
- Discovery found 218 tests
- Tests Passed: 211, Failed: 0, Skipped: 7
- Coverage artifacts emitted under `artifacts/pester/`
GateStatus: PASS

## Run 2 — Final full toolchain loop (single uninterrupted clean pass)

Timestamp: 2026-02-22T01:58:00-05:00
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
EXIT_CODE: 0
Output Summary:
- All scanned PowerShell files already formatted

Timestamp: 2026-02-22T01:58:20-05:00
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
EXIT_CODE: 0
Output Summary:
- PSScriptAnalyzer passed with no findings

Timestamp: 2026-02-22T01:58:45-05:00
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary:
- Discovery found 218 tests
- Tests Passed: 211, Failed: 0, Skipped: 7

GateStatus: PASS
