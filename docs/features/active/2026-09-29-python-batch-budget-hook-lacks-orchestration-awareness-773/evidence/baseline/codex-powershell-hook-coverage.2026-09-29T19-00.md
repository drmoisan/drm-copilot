# Codex PowerShell Hook Coverage Baseline (P0-T18)

Timestamp: 2026-09-29T19-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-xps-base.xml -ReportPath SCRATCH/cov-xps-base.txt
EXIT_CODE: 0
Output Summary:
TotalCount=90
PassedCount=90
FailedCount=0
COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=132 CoveredLines=129 LinePercent=97.73
MISSED file=.codex/hooks/enforce-powershell-batch-budget.ps1 Lines=171,172,458
XPS_BASE_PCT=97.73
