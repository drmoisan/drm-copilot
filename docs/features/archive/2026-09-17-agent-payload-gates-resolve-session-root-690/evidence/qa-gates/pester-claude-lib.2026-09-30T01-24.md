# Regression tests/scripts/claude-lib (P12-T14)

Timestamp: 2026-09-30T01-24
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib
EXIT_CODE: 0
Output Summary:
- TotalCount=1783
- PassedCount=1782
- FailedCount=0
- FAILED: lines: none (every FAILED line is trivially a member of the baseline failure set).
- TotalCount 1783 = BASE_CLIB 1710 + 72 planned + 1 row added by the Phase 12 coverage fix; 1 skipped test, as in the baseline (1709 passed, 1 skipped). The plan literal (BASE_CLIB + 72 = 1782) is not met, because of that recorded deviation.
