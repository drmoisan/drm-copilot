# Final Coverage: Codex PowerShell Hook and Codex Route Helper (P11-T7)

Timestamp: 2026-09-29T21-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1,.codex/hooks/enforce-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-xps-final.xml -ReportPath SCRATCH/cov-xps-final.txt
EXIT_CODE: 0
Output Summary:
TotalCount=83
PassedCount=83
FailedCount=0
COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=99 CoveredLines=98 LinePercent=98.99
MISSED file=.codex/hooks/enforce-powershell-batch-budget.ps1 Lines=338
COVERAGE file=.codex/hooks/enforce-batch-budget-route.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12
MISSED file=.codex/hooks/enforce-batch-budget-route.ps1 Lines=136,137
XPSHOOK LinePercent=98.99 and XROUTE LinePercent=94.12 (each at least 85).
