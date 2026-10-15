# PowerShell claude-lib Regression (P8-T4)

Timestamp: 2026-09-28T22-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib
EXIT_CODE: 0
Output Summary: `TotalCount=1710`, `PassedCount=1709`, `FailedCount=0` (1 skipped, as at baseline). TotalCount equals the P0-T18 baseline of 1693 plus 17 (15 moved-in parser tests and 2 manifest tests). No `FAILED:` lines, so the failure set equals the empty P0-T18 baseline set.
