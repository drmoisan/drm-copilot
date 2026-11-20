# PowerShell Test Baseline

Timestamp: 2026-03-14T15-48
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary:
- PoshQC test execution completed successfully at the repository root.
- Tests Passed: 224, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0.
- PowerShell coverage headline values: Covered 42.98% / 0%.
- Coverage detail: 1,545 analyzed commands in 16 files.
- Coverage artifact written: `artifacts/pester/powershell-coverage.koverage.xml`.
