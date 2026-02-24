# Baseline Evidence — PowerShell (Remediation)

- Timestamp: 2026-02-23T20-34
- Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
- EXIT_CODE: 1
- Output Summary: PSScriptAnalyzer reported 10 `PSUseConsistentIndentation` findings in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` (lines 257–267).

- Timestamp: 2026-02-23T20-34
- Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
- EXIT_CODE: 1
- Output Summary: Pester run found 1 failing test for insiders command preference in `new-potential-entry.Tests.ps1`; remaining tests passed or skipped.
