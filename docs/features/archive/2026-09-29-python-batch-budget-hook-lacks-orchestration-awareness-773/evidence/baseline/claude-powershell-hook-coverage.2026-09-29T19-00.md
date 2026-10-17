# Claude PowerShell Hook and Old Route Helper Coverage Baseline (P0-T17)

Timestamp: 2026-09-29T19-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1,tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-powershell-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-cps-base.xml -ReportPath SCRATCH/cov-cps-base.txt
EXIT_CODE: 0
Output Summary:
TotalCount=83
PassedCount=83
FailedCount=0
COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=132 CoveredLines=126 LinePercent=95.45
MISSED file=.claude/hooks/enforce-powershell-batch-budget.ps1 Lines=88,98,481,482,483,486
COVERAGE file=.claude/hooks/enforce-powershell-batch-budget-route.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12
MISSED file=.claude/hooks/enforce-powershell-batch-budget-route.ps1 Lines=134,135
CPS_BASE_PCT=95.45
ROUTE_BASE_PCT=94.12
