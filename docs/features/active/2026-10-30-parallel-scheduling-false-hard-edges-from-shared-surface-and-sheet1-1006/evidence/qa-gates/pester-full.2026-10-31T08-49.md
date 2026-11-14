# PowerShell Pester Final Run (issue #1006)

Timestamp: 2026-10-31T08-49
Task: P8-T7
Command: sh SCRATCH/issue-1006-pester-full.sh final (PowerShell 7 imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts, fresh single process, coverage on)
EXIT_CODE: 0
Output Summary:
- Tests completed in 829s. JUnit (`artifacts/pester/pester-junit.xml`, copied to SCRATCH): tests 13541, failures 0, errors 0, skipped 10. P0-T7 named no failing test; the count rose from 13518 by the 23 rows of the new `BlastRadiusGenericContract.Tests.ps1`.
- Overall Pester command coverage: 92.75% over 34,081 analyzed commands in 256 files.
- Per-file line coverage from `artifacts/pester/powershell-coverage.xml` (JaCoCo LINE counters), each at or above 85 percent:
  - `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`: 100.00% (39/39)
  - `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`: 100.00% (80/80)
  - `.claude/lib/blast-radius/BlastRadiusNormalization.psm1`: 100.00% (52/52)
  - `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`: 100.00% (103/103)
  - `.claude/lib/blast-radius/BlastRadius.psm1`: 100.00% (108/108)
