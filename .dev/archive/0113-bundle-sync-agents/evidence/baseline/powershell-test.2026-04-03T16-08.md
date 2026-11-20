Timestamp: 2026-04-03T16-08
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCTest completed successfully.
- Pester results: 226 passed, 0 failed, 7 skipped.
- Numeric coverage extracted from `artifacts/pester/powershell-coverage.koverage.xml`: 47.52% overall command coverage.
- Koverage uncovered/new-code headline reported by the tool output: 0%.
