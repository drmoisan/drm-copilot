# Coverage Delta (issue #1009)

Timestamp: 2026-10-30T18-00
Command: SCRATCH/issue-1009-report.ps1 -CovTargetsFile SCRATCH/issue-1009-cov-hooks.txt, reading artifacts/pester/powershell-coverage.xml from the [P9-T5] TOUCHED-SUITES run, compared with `evidence/baseline/pester-baseline.2026-10-30T17-12.md`
EXIT_CODE: 0
Output Summary: every new file is at or above the 85% line threshold and every canonical hook is at or above its baseline. PowerShell has no branch-coverage gate.

| File | Baseline (P0-T6) | Post-change (P9-T5) | Gate | Result |
|---|---|---|---|---|
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | new | 151/152 = 99.34% | >= 85% | PASS |
| `.codex/hooks/hook-target-worktree.ps1` | new | 148/149 = 99.33% | >= 85% | PASS |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 130/139 = 93.53% | 143/152 = 94.08% | >= baseline | PASS |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 130/139 = 93.53% | 143/152 = 94.08% | >= baseline | PASS |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 101/106 = 95.28% | 114/119 = 95.80% | >= baseline | PASS |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 101/106 = 95.28% | 114/119 = 95.80% | >= baseline | PASS |

New and changed hook lines: in each hook the denominator and the covered count both rose by 13 lines, and the missed count is unchanged (9 per Claude hook, 5 per Codex hook), so no added line is uncovered. The single uncovered line in each of the module and the twin is the host-bound default WorktreeListInvoker body, which the AST rows assert instead of executing.
