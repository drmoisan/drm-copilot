# AC-12 Helper Check (P10-T8)

Timestamp: 2026-09-29T20-52
Command: git grep -c -F -e '<function literal>' -- .claude/hooks/enforce-batch-budget-route.ps1 .codex/hooks/enforce-batch-budget-route.ps1 for `function ConvertFrom-BatchBudgetCheckpoint`, `function Get-BatchBudgetSelectedRoute`, `function Test-BatchBudgetLargePathRoute`; git grep -c -F -e 'enforce-batch-budget-route.ps1' -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1 .codex/hooks/enforce-powershell-batch-budget.ps1 .codex/hooks/enforce-python-batch-budget.ps1; sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 .claude/hooks/enforce-batch-budget-route.ps1 .codex/hooks/enforce-batch-budget-route.ps1
EXIT_CODE: 0
Output Summary:
- Each function search printed two path:1 lines (CROUTE and XROUTE).
- Dot-source search printed four path:1 lines (CPSHOOK, CPYHOOK, XPSHOOK, XPYHOOK).
- PAIR-SUMMARY pairs=1 unequal=0
