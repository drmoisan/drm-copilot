# Final File-Size Check (#769, P9-T10)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <8 P9-T1 files> <4 bundle copies>
EXIT_CODE: 0
Output Summary:
.claude/hooks/enforce-powershell-batch-budget.ps1 LineCount=486
.claude/hooks/enforce-powershell-batch-budget-route.ps1 LineCount=137
.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=461
tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 LineCount=490
tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 LineCount=353
tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 LineCount=371
tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 LineCount=382
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=336
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 LineCount=486
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1 LineCount=137
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=461
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=336
Every .ps1 value is at most 500. Both runsettings copies are 336 = P0-T10 value 335 plus 1.
