# Final File-Size Limit Check (P11-T13)

Timestamp: 2026-09-29T21-07
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <15 Appendix H files> <six bundle hook and helper copies> extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary:
.claude/hooks/enforce-batch-budget-route.ps1 LineCount=139
.codex/hooks/enforce-batch-budget-route.ps1 LineCount=139
.claude/hooks/enforce-powershell-batch-budget.ps1 LineCount=486
.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=341
.claude/hooks/enforce-python-batch-budget.ps1 LineCount=489
.codex/hooks/enforce-python-batch-budget.ps1 LineCount=344
tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 LineCount=481
tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 LineCount=368
tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 LineCount=389
tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 LineCount=87
tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 LineCount=275
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 LineCount=497
tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 LineCount=353
tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 LineCount=382
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=337
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 LineCount=489
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 LineCount=486
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-batch-budget-route.ps1 LineCount=139
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1 LineCount=344
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=341
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-batch-budget-route.ps1 LineCount=139
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=337
Every .ps1 file is at most 500 lines (AC-26). RUNSET and RUNSET_B each equal RUNSET_0 (336) plus 1.
