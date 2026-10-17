# Phase 4 Line Counts (P4-T17)

Timestamp: 2026-09-29T20-03
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 .codex/hooks/enforce-batch-budget-route.ps1 .codex/hooks/enforce-powershell-batch-budget.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary:
.codex/hooks/enforce-batch-budget-route.ps1 LineCount=139 (at most 500)
.codex/hooks/enforce-powershell-batch-budget.ps1 LineCount=341 (expected 341)
tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 LineCount=382 (expected 382)
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 LineCount=497 (expected 497)
tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 LineCount=87 (at most 500)
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 LineCount=337 (RUNSET_0 plus 1)
