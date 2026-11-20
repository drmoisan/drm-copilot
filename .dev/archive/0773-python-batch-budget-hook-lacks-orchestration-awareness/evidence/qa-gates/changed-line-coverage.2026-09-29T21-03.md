# Changed-Line Coverage Against BASE_SHA (P11-T9)

Timestamp: 2026-09-29T21-03
Command: sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -CoverageReportPath SCRATCH/<report> -BaseRef 91805f15ddc5930759d877cf6147467096ad91fe -File <file>, for (cov-cpy-final.txt, .claude/hooks/enforce-python-batch-budget.ps1), (cov-cps-final.txt, .claude/hooks/enforce-powershell-batch-budget.ps1), (cov-xpy-final.txt, .codex/hooks/enforce-python-batch-budget.ps1), (cov-xps-final.txt, .codex/hooks/enforce-powershell-batch-budget.ps1), (cov-route-final.txt, .claude/hooks/enforce-batch-budget-route.ps1,.codex/hooks/enforce-batch-budget-route.ps1)
EXIT_CODE: 0
Output Summary:
CHANGED-COVERAGE file=.claude/hooks/enforce-python-batch-budget.ps1 ChangedLines=99 ChangedAnalyzed=33 ChangedCovered=33 ChangedPercent=100
CHANGED-COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1 ChangedLines=3 ChangedAnalyzed=3 ChangedCovered=3 ChangedPercent=100
CHANGED-COVERAGE file=.codex/hooks/enforce-python-batch-budget.ps1 ChangedLines=169 ChangedAnalyzed=53 ChangedCovered=52 ChangedPercent=98.11
CHANGED-COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1 ChangedLines=4 ChangedAnalyzed=3 ChangedCovered=3 ChangedPercent=100
CHANGED-COVERAGE file=.claude/hooks/enforce-batch-budget-route.ps1 ChangedLines=139 ChangedAnalyzed=34 ChangedCovered=32 ChangedPercent=94.12
CHANGED-COVERAGE file=.codex/hooks/enforce-batch-budget-route.ps1 ChangedLines=139 ChangedAnalyzed=34 ChangedCovered=32 ChangedPercent=94.12
Six lines, none MISSING, each ChangedPercent at least 85. The two route helpers are new at BASE_SHA, so every line counts as changed.
