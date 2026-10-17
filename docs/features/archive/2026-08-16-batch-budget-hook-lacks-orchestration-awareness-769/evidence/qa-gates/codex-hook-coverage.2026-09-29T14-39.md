# Final Codex Hook Test and Coverage (#769, P9-T5)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-codex-final.xml -ReportPath SCRATCH/cov-codex-final.txt
EXIT_CODE: 0
Output Summary:
TotalCount=90
PassedCount=90
FailedCount=0
COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=132 CoveredLines=129 LinePercent=97.73
MISSED file=.codex/hooks/enforce-powershell-batch-budget.ps1 Lines=171,172,458
LinePercent is at least 85.
