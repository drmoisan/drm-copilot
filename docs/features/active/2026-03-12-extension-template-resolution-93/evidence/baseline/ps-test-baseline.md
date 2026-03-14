# PowerShell Test Baseline

Timestamp: 2026-03-13T00-40
Task: P0-T14
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 2

## Output Summary:

Tests Passed: 220, Failed: 2, Skipped: 7, Inconclusive: 0, NotRun: 0
Tests completed in 13.07s

### Coverage Headline:

Covered 43.5% / 0%. 1,524 analyzed Commands in 16 Files.

### Notes:

- 2 tests failing at baseline (pre-implementation). This is the pre-change state.
- EXIT_CODE 2 indicates test failures exist before the fix is applied.
