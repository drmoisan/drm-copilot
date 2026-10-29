# Final: full coverage-enabled Pester run after the fix

Timestamp: 2026-10-28T23-15
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts (one fresh process over the full tests/scripts population, coverage population derived from config/poshqc-coverage.json; sh launcher under SCRATCH, PowerShell 7)
EXIT_CODE: 0
Output Summary:
- Counts read from artifacts/pester/pester-junit.xml: total 11816, passed 11806, failed 0, errors 0, skipped 10 (baseline: total 11812, passed 11802, skipped 10; the difference is the four new rows).
- Repo-wide line coverage read from artifacts/pester/powershell-coverage.xml (report LINE counter): 92.88% (18232 of 19630 lines); baseline 92.88% (18232 of 19630); not below baseline and at least 85%.
- Line coverage of scripts/ci/New-FileSizeBaseline.ps1 from the same file: 100.00% (32 of 32 lines); baseline 100.00% (32 of 32); at least 85%.
- This is a full tests/scripts run, not a subset run, so the canonical coverage file keeps the full population. It supersedes any earlier subset coverage run in the cycle.
- Counts and percentages come from the JUnit and coverage XML files, not from an MCP result.
