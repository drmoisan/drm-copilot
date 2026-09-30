# Pre-Change Line Counts (P0-T10)

Timestamp: 2026-09-29T18-56
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/hooks/enforce-python-batch-budget.ps1 .codex/hooks/enforce-python-batch-budget.ps1 .claude/hooks/enforce-powershell-batch-budget.ps1 .codex/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-powershell-batch-budget-route.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 .agents/skills/invoke-powershell-engineer/SKILL.md
EXIT_CODE: 0
Output Summary:
.claude/hooks/enforce-python-batch-budget.ps1 LineCount=454
.codex/hooks/enforce-python-batch-budget.ps1 LineCount=254
.claude/hooks/enforce-powershell-batch-budget.ps1 LineCount=486
.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=461
.claude/hooks/enforce-powershell-batch-budget-route.ps1 LineCount=137
tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 LineCount=485
tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 LineCount=371
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 LineCount=497
tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 LineCount=353
tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 LineCount=382
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=336
.agents/skills/invoke-powershell-engineer/SKILL.md LineCount=65

All eleven expected values match. RUNSET_0=336.
