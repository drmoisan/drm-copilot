# Live Route Probe After Split (#769, P2-T3, P2-T4, P2-T5)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/route-probe.ps1 .claude/hooks/enforce-powershell-batch-budget.ps1 artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 0
Output Summary:
LARGE-PATH-ROUTE=True
SELECTED-ROUTE=large

Related checks:
- P2-T3: Write of .claude/hooks/enforce-powershell-batch-budget-route.ps1 succeeded without a hook denial; route-probe over CROUTE printed LARGE-PATH-ROUTE=True and SELECTED-ROUTE=large.
- P2-T4: git grep -c -F -e 'function Test-PowerShellBatchBudgetLargePathRoute' over CHOOK exited 1 with no output; git grep -c -F -e 'enforce-powershell-batch-budget-route.ps1' over CHOOK printed `.claude/hooks/enforce-powershell-batch-budget.ps1:1`.
