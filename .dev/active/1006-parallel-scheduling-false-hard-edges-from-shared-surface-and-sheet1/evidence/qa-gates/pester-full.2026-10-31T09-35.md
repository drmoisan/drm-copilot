# PowerShell Full Pester Run (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-35
Command: sh SCRATCH/issue-1006-pester-full.sh rc1 (PowerShell 7 imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts, fresh single process, coverage on); totals read by SCRATCH/issue-1006-pester-report.ps1 from the JUnit and JaCoCo copies
EXIT_CODE: 0
Output Summary: Tests completed in 796.65s. JUnit (artifacts/pester/pester-junit.xml, copied to SCRATCH): tests 13541, failures 0, errors 0, skipped 10. Overall Pester command coverage 92.75% over 34,081 commands in 256 files. Each of the five changed blast-radius modules is at 100% line coverage.

## Per-file line coverage (`artifacts/pester/powershell-coverage.xml`, JaCoCo LINE counters)

| Module | Line coverage |
|---|---|
| `.claude/lib/blast-radius/BlastRadius.psm1` | 100.00% (108/108) |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 100.00% (80/80) |
| `.claude/lib/blast-radius/BlastRadiusNormalization.psm1` | 100.00% (52/52) |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | 100.00% (39/39) |
| `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` | 100.00% (103/103) |

Each is at least 85 percent. The test count is the same as the prior final run (13541), because this cycle changed no test count.
