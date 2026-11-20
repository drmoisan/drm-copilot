# Baseline: full coverage-enabled Pester run on the unchanged tree

Timestamp: 2026-10-28T22-58
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts (one fresh process, coverage population derived from config/poshqc-coverage.json; sh launcher under SCRATCH, PowerShell 7)
EXIT_CODE: 0
Output Summary:
- Counts read from artifacts/pester/pester-junit.xml: total 11812, passed 11802, failed 0, errors 0, skipped 10.
- Repo-wide line coverage read from artifacts/pester/powershell-coverage.xml (report LINE counter): 92.88% (18232 of 19630 lines).
- Line coverage of scripts/ci/New-FileSizeBaseline.ps1 from the same file: 100.00% (32 of 32 lines).
- Counts and percentages come from the JUnit and coverage XML files, not from an MCP result.
