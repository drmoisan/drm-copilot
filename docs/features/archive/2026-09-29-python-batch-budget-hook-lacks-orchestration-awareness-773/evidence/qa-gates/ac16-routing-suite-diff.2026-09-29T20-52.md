# AC-16 Routing Suite Diff Check (P10-T9)

Timestamp: 2026-09-29T20-52
Command: git diff --numstat 91805f15ddc5930759d877cf6147467096ad91fe -- tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1; git diff -U0 91805f15ddc5930759d877cf6147467096ad91fe -- <same two>; git status --porcelain -- <same two>
EXIT_CODE: 0
Output Summary:
- numstat: `2 2 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` and `2 2 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (exactly two lines).
- -U0 content lines (per file, identical pairs):
  - `-            Test-PowerShellBatchBudgetLargePathRoute -CheckpointText $Text | Should -Be $Expected` / `+            Test-BatchBudgetLargePathRoute -CheckpointText $Text | Should -Be $Expected`
  - `-            Get-PowerShellBatchBudgetSelectedRoute -CheckpointText $Text | Should -Be $Expected` / `+            Get-BatchBudgetSelectedRoute -CheckpointText $Text | Should -Be $Expected`
  Every `-` line contains `PowerShellBatchBudget`, and its paired `+` line differs only in `PowerShellBatchBudget` reading `BatchBudget`.
- git status --porcelain: no output.
