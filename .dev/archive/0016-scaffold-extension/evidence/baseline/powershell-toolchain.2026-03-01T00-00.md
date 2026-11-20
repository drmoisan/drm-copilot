# Baseline PowerShell Toolchain Evidence

## Command 1
Timestamp: 2026-03-02T00:27:29Z
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
EXIT_CODE: 0
Output Summary: `Invoke-PoshQCFormat` completed with all files already formatted.

## Command 2
Timestamp: 2026-03-02T00:28:19Z
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
EXIT_CODE: 0
Output Summary: `Invoke-PoshQCAnalyze` passed with no findings.

## Command 3
Timestamp: 2026-03-02T00:28:33Z
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary: `Invoke-PoshQCTest` passed (217 passed, 0 failed, 7 skipped) and produced coverage output.
