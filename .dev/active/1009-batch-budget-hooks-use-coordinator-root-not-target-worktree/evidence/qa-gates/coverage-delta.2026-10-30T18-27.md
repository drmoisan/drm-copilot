# Coverage Delta (issue #1009)

Timestamp: 2026-10-30T18-27
Command: SCRATCH/issue-1009-report.ps1 -CovTargetsFile SCRATCH/issue-1009-cov-hooks.txt over artifacts/pester/powershell-coverage.xml from the final [P9-T5] run, compared with `evidence/baseline/pester-baseline.2026-10-30T17-12.md`
EXIT_CODE: 0
Output Summary: both new files are at or above the 85% line threshold, and every canonical hook is at or above its baseline. PowerShell has no branch-coverage gate.

| File | Baseline (P0-T6) | Post-change (P9-T5) | Gate | Result |
|---|---|---|---|---|
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | new | 151/152 = 99.34% | >= 85% | PASS |
| `.codex/hooks/hook-target-worktree.ps1` | new | 148/149 = 99.33% | >= 85% | PASS |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 130/139 = 93.53% | 143/152 = 94.08% | >= baseline | PASS |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 130/139 = 93.53% | 143/152 = 94.08% | >= baseline | PASS |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 101/106 = 95.28% | 114/119 = 95.80% | >= baseline | PASS |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 101/106 = 95.28% | 114/119 = 95.80% | >= baseline | PASS |

Changed hook lines: in each hook the denominator and the covered count both rose by 13 lines, and the missed count is unchanged (9 per Claude hook, 5 per Codex hook), so no added line is uncovered. The single uncovered line in the module and in the twin is the host-bound default WorktreeListInvoker body, which the AST rows assert without executing it.
