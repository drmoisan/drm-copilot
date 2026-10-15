# Regression tests/scripts/claude-hooks (P12-T13)

Timestamp: 2026-09-30T01-24
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks
EXIT_CODE: 0
Output Summary:
- TotalCount=2150
- PassedCount=2150
- FailedCount=0
- FAILED: lines: none (every FAILED line is trivially a member of the baseline failure set).
- TotalCount 2150 = BASE_HOOKS 2070 + 78 planned + 2 rows added by the Phase 12 coverage fix (evidence/other/p12-coverage-fix-deviation). The plan literal (BASE_HOOKS + 78 = 2148) is not met, because of that recorded deviation.
