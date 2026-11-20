# Final Coverage: Claude PowerShell Hook and Claude Route Helper (P11-T5)

Timestamp: 2026-09-29T21-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1,tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-cps-final.xml -ReportPath SCRATCH/cov-cps-final.txt
EXIT_CODE: 0
Output Summary:
TotalCount=83
PassedCount=83
FailedCount=0
COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=132 CoveredLines=126 LinePercent=95.45
MISSED file=.claude/hooks/enforce-powershell-batch-budget.ps1 Lines=88,98,481,482,483,486
COVERAGE file=.claude/hooks/enforce-batch-budget-route.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12
MISSED file=.claude/hooks/enforce-batch-budget-route.ps1 Lines=136,137
CPSHOOK LinePercent=95.45 and CROUTE LinePercent=94.12 (each at least 85).
