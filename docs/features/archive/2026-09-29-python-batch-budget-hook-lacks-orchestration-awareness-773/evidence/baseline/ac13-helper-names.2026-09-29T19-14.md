# AC-13 Helper-Name Sweep Non-Vacuity Baseline (P0-T27)

Timestamp: 2026-09-29T19-14
Command: git grep -n -F -e 'PowerShellBatchBudgetCheckpoint' -e 'PowerShellBatchBudgetSelectedRoute' -e 'PowerShellBatchBudgetLargePathRoute' -- .claude/hooks .codex/hooks tests/scripts extensions/drm-copilot/resources
EXIT_CODE: 0
Output Summary:
36 match lines. Files named (match count):
- .claude/hooks/enforce-powershell-batch-budget-route.ps1 (6)
- .claude/hooks/enforce-powershell-batch-budget.ps1 (2; lines 395, 396)
- .codex/hooks/enforce-powershell-batch-budget.ps1 (8)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1 (6)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 (2)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 (8)
- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 (2; lines 125, 136)
- tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 (2; lines 136, 147)
Every required file (CPSHOOK, CROUTE_OLD, XPSHOOK, CPSRTEST, XPSRTEST, and the CB and XB copies) is named.
