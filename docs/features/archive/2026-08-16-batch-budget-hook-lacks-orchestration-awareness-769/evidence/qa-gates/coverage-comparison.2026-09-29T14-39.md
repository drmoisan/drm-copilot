# Coverage Comparison (#769, P11-T4)

Timestamp: 2026-09-29T14-39
Command: comparison of baseline/claude-hook-coverage, baseline/codex-hook-coverage, qa-gates/claude-hook-coverage, qa-gates/codex-hook-coverage, and qa-gates/changed-line-coverage (all 2026-09-29T14-39)
EXIT_CODE: 0
Output Summary: every post-change and changed-code value is at least 85; Disposition PASS.

Language: PowerShell (Pester line coverage; no branch-coverage gate applies)

Baseline Coverage:
- .claude/hooks/enforce-powershell-batch-budget.ps1: 95.35 (CLAUDE_BASE_PCT, P0-T15)
- .codex/hooks/enforce-powershell-batch-budget.ps1: 96.55 (CODEX_BASE_PCT, P0-T16)
- .claude/hooks/enforce-powershell-batch-budget-route.ps1: not present at baseline (new file)

Post-Change Coverage:
- .claude/hooks/enforce-powershell-batch-budget.ps1: 95.45 (P9-T4)
- .claude/hooks/enforce-powershell-batch-budget-route.ps1: 94.12 (P9-T4)
- .codex/hooks/enforce-powershell-batch-budget.ps1: 97.73 (P9-T5)

New/Changed-code Coverage:
- .claude/hooks/enforce-powershell-batch-budget.ps1: 100 (P9-T6)
- .claude/hooks/enforce-powershell-batch-budget-route.ps1: 94.12 (P9-T6)
- .codex/hooks/enforce-powershell-batch-budget.ps1: 96.51 (P9-T6)

Disposition: PASS

Neither existing hook regressed (95.35 to 95.45; 96.55 to 97.73).
Python: no in-scope source file (qa-gates/python-scope, P10-T3). TypeScript: no file changed.
