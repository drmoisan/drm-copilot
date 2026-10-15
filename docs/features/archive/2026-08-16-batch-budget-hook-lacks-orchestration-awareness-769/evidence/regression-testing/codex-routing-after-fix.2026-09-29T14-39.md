# Codex Routing Regression Tests After Fix (#769, P5-T5)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary:
TotalCount=49
PassedCount=49
FailedCount=0
Fail-before evidence: regression-testing/codex-routing-before-fix.2026-09-29T14-39.md (49 of 49 failed).
P5-T1 checks: the XHOOK Write succeeded without a hook denial (4th distinct production PowerShell path written through Write or Edit); git grep -c for POWERSHELL_LARGE_PATH_REQUIRED printed `.codex/hooks/enforce-powershell-batch-budget.ps1:2`; git grep -c for `[Console]::In.ReadToEnd()` printed `.codex/hooks/enforce-powershell-batch-budget.ps1:1`.
P5-T2 checks: git grep -c for ExtraSeams printed `...codex-batch-budget-hooks.Tests.ps1:9`; git grep -c for `the Python batch-budget hook cap contract` printed `...codex-batch-budget-hooks.Tests.ps1:1`.
