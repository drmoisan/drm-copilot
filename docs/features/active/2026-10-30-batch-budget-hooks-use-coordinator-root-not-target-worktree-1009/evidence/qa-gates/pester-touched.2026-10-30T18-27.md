# Pester over TOUCHED-SUITES with Coverage, Final Pass (issue #1009)

Timestamp: 2026-10-30T18-27
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-touched.txt issue-1009-cov-hooks.txt (Invoke-PoshQCTest -ScanFolders <the 23 TOUCHED-SUITES files>; counts from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: JUnit total=1653 passed=1653 failed=0 skipped=0.

Dependency-failure rows passed: `B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookTargetWorktree.psm1 when that direct edge fails`; the same for `.claude/hooks/enforce-powershell-batch-budget.ps1`; `B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming hook-target-worktree.ps1 when that direct edge fails`; the same for `.codex/hooks/enforce-powershell-batch-budget.ps1`.

AC-26 suites passed with no edit (none appears in `git diff --name-only origin/main...HEAD` or `git status --porcelain`): enforce-python-batch-budget.Tests.ps1 34/34; enforce-powershell-batch-budget.Tests.ps1 36/36; enforce-python-batch-budget-routing.Tests.ps1 32/32; enforce-powershell-batch-budget-routing.Tests.ps1 47/47; enforce-batch-budget.RouteImportFailure.Tests.ps1 20/20; codex-batch-budget-hooks.Tests.ps1 34/34; codex-python-batch-budget-routing.Tests.ps1 34/34; codex-powershell-batch-budget-routing.Tests.ps1 49/49; codex-batch-budget.RouteImportFailure.Tests.ps1 16/16; codex-batch-budget-route-parity.Tests.ps1 55/55; PreToolUseSchema.Contract.Tests.ps1 16/16.

Other suites: HookTargetWorktree.Tests.ps1 83/83; hook-target-worktree.Tests.ps1 83/83; enforce-python-batch-budget.TargetWorktree.Tests.ps1 20/20; enforce-powershell-batch-budget.TargetWorktree.Tests.ps1 21/21; codex-batch-budget.TargetWorktree.Tests.ps1 20/20; WorktreeResolution.Manifest.Tests.ps1 25/25; legacy-codex-hook-contracts.Tests.ps1 43/43; hook-dependency-failure.Claude.Tests.ps1 182/182; hook-dependency-failure.Codex.Tests.ps1 88/88; hook-dependency-guard-completeness.Tests.ps1 671/671; enforcement-hooks-no-python-invocation.Tests.ps1 33/33; codex-pretooluse-integration.Tests.ps1 11/11.

Line coverage: HookTargetWorktree.psm1 151/152 = 99.34%; hook-target-worktree.ps1 148/149 = 99.33%; Claude Python and PowerShell hooks 143/152 = 94.08% each; Codex Python and PowerShell hooks 114/119 = 95.80% each.

CI: these suites run in the `poshqc / PowerShell QC` shards; those under tests/scripts/claude-hooks and tests/scripts/codex-hooks also run in `poshqc / PowerShell hook suites (Linux)` (pending CI).
