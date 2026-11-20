# Pre-Change Line Counts (#769, P0-T10)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .claude/hooks/enforce-powershell-batch-budget.ps1 .codex/hooks/enforce-powershell-batch-budget.ps1 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary:
.claude/hooks/enforce-powershell-batch-budget.ps1 LineCount=457
.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=256
tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 LineCount=495
tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 LineCount=346
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 LineCount=497
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=335

Acceptance: six LineCount lines; CHOOK 457, XHOOK 256, CTEST 495 as expected.
