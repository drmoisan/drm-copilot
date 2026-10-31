# Baseline Pester over Existing TOUCHED-SUITES (issue #1009)

Timestamp: 2026-10-30T17-12
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-touched-existing.txt issue-1009-cov-hooks.txt (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders <18 existing TOUCHED-SUITES files>; counts read from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- JUnit: total=1419 passed=1419 failed=0 skipped=0
- Failing tests: none
- Line coverage (baseline, branch base):
  - `.claude/hooks/enforce-python-batch-budget.ps1`: 130/139 = 93.53%
  - `.claude/hooks/enforce-powershell-batch-budget.ps1`: 130/139 = 93.53%
  - `.codex/hooks/enforce-python-batch-budget.ps1`: 101/106 = 95.28%
  - `.codex/hooks/enforce-powershell-batch-budget.ps1`: 101/106 = 95.28%

Per-suite (passed/total):
- tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1: 20/20
- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1: 47/47
- tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1: 36/36
- tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1: 32/32
- tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1: 34/34
- tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1: 180/180
- tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1: 16/16
- tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1: 22/22
- tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1: 33/33
- tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1: 671/671
- tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1: 34/34
- tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1: 55/55
- tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1: 16/16
- tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1: 49/49
- tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1: 11/11
- tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1: 34/34
- tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1: 86/86
- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1: 43/43
