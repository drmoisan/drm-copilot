# Pester Final Run with Coverage (Unit and Integration)

Timestamp: 2026-10-28T22-14
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -ScanFolders tests/scripts (one fresh process; coverage population derived from config/poshqc-coverage.json; sh launcher under SCRATCH, PowerShell 7.6, Pester 5.9)
EXIT_CODE: 0
Output Summary:
- Counts read from `artifacts/pester/pester-junit.xml`: total 11812, passed 11802, failed 0, errors 0, skipped 10 (baseline: total 11448, passed 11438, skipped 10; the difference is the 364 new and added rows).
- Overall PowerShell line coverage read from `artifacts/pester/powershell-coverage.xml` (report LINE counter): 92.88% (18232 of 19630 lines); baseline 92.71%.
- Duration: tests completed in 704 s.
- Not-applicable stages: type checking (PowerShell has no type checker in this repository's toolchain) and architecture-boundary tests (no PowerShell architecture-boundary tool is configured); both are recorded as N/A.
- Counts and the percentage come from the JUnit and coverage XML files, not from a PoshQC MCP result.
