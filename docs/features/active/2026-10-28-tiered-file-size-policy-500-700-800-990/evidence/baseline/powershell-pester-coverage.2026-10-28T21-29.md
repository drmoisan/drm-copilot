# PowerShell Pester and Coverage Baseline

Timestamp: 2026-10-28T21-29
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts (coverage population derived from config/poshqc-coverage.json; sh launcher under SCRATCH, PowerShell 7.6, Pester 5.9)
EXIT_CODE: 0
Output Summary:
- Counts read from `artifacts/pester/pester-junit.xml`: total 11448, passed 11438, failed 0, errors 0, skipped 10.
- Overall PowerShell line coverage read from `artifacts/pester/powershell-coverage.xml` (report LINE counter): 92.71% (17787 of 19185 lines).
- Pre-existing failing tests: none.
- Run duration about 723 s. Counts and the percentage come from the JUnit and coverage XML files, not from a PoshQC MCP result. A copy of both files is kept under SCRATCH for the [P7-T4] comparison.
- Note: the run was started before any implementation file existed; the new files created during the run (under `.claude/lib/file-size-policy/`) were outside the coverage population fixed at run start.
