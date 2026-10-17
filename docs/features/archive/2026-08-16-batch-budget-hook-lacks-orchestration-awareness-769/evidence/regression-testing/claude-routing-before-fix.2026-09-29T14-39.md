# Claude Routing Regression Tests Before Fix (#769, P1-T2) [expect-fail]

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
TotalCount=47
PassedCount=0
FailedCount=47
All 47 cases fail against the unfixed hook: 21 route-predicate rows and 4 selected-route cases (functions absent), 6 direct-mode, 5 large-path, 2 test-path, 4 override, and 5 seam cases (ReadCheckpoint and LargePathRoute parameters absent, old deny message, legacy TestCap mandatory parameter, CLAUDE_POWERSHELL_BUDGET present in the hook source).
Pre-change line count of the test file: 353 (at most 500).
