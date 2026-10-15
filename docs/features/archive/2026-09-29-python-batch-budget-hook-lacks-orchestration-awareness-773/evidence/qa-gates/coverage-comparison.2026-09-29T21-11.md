# Coverage Comparison (P13-T2)

Timestamp: 2026-09-29T21-11
Command: Derived from baseline artifacts P0-T15 through P0-T18 and final artifacts P11-T4 through P11-T9 (no new command run).
EXIT_CODE: 0
Output Summary: All post-change and changed-code PowerShell line-coverage values are at least 85. Disposition PASS.

Language: PowerShell (Pester line coverage via SCRATCH/pester-coverage.ps1 and SCRATCH/changed-line-coverage.ps1)

Baseline Coverage:
- CPYHOOK `.claude/hooks/enforce-python-batch-budget.ps1`: CPY_BASE_PCT=95.35
- XPYHOOK `.codex/hooks/enforce-python-batch-budget.ps1`: XPY_BASE_PCT=96.55
- CPSHOOK `.claude/hooks/enforce-powershell-batch-budget.ps1`: CPS_BASE_PCT=95.45
- XPSHOOK `.codex/hooks/enforce-powershell-batch-budget.ps1`: XPS_BASE_PCT=97.73
- CROUTE_OLD `.claude/hooks/enforce-powershell-batch-budget-route.ps1`: ROUTE_BASE_PCT=94.12

Post-Change Coverage:
- CPYHOOK: 95.45 (P11-T4)
- CPSHOOK: 95.45 (P11-T5)
- CROUTE `.claude/hooks/enforce-batch-budget-route.ps1`: 94.12 (P11-T5 and P11-T8)
- XPYHOOK: 98.99 (P11-T6)
- XPSHOOK: 98.99 (P11-T7)
- XROUTE `.codex/hooks/enforce-batch-budget-route.ps1`: 94.12 (P11-T7 and P11-T8)

New/Changed-code Coverage (P11-T9, lines changed against BASE_SHA 91805f15ddc5930759d877cf6147467096ad91fe):
- CPYHOOK: 100
- CPSHOOK: 100
- XPYHOOK: 98.11
- XPSHOOK: 100
- CROUTE: 94.12
- XROUTE: 94.12

Disposition: PASS

Notes:
- No post-change value is below its baseline: CPYHOOK 95.35 to 95.45, XPYHOOK 96.55 to 98.99, CPSHOOK 95.45 to 95.45, XPSHOOK 97.73 to 98.99, route helper 94.12 to 94.12 per copy.
- No Python or TypeScript source file changed (P10-T10: `git diff --name-only BASE_SHA -- "*.py"` and `git status --porcelain -- "*.py"` printed nothing; no TypeScript source was edited), so no Python or TypeScript coverage gate applies to this change.
- PowerShell has no branch-coverage gate (Pester does not measure branch coverage); only the 85 percent line threshold applies.
