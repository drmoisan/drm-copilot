# Codex Routing Regression Tests Before Fix (#769, P4-T2) [expect-fail]

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
TotalCount=49
PassedCount=0
FailedCount=49
All 49 cases fail against the unfixed Codex hook (route functions, ReadCheckpoint, LargePathRoute, and Invoke-PowerShellBatchBudgetCodexEntryPoint absent; mandatory TestCap; old deny message).
Test file line count (P4-T1): 382 (at most 500). The Write succeeded without a hook denial.
