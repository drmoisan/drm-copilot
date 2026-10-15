# Final Coverage: Both Route Helper Copies Through the Parity Suite (P11-T8)

Timestamp: 2026-09-29T21-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 -CoveragePath .claude/hooks/enforce-batch-budget-route.ps1,.codex/hooks/enforce-batch-budget-route.ps1 -CoverageOutputPath SCRATCH/cov-route-final.xml -ReportPath SCRATCH/cov-route-final.txt
EXIT_CODE: 0
Output Summary:
TotalCount=55
PassedCount=55
FailedCount=0
COVERAGE file=.claude/hooks/enforce-batch-budget-route.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12
MISSED file=.claude/hooks/enforce-batch-budget-route.ps1 Lines=136,137
COVERAGE file=.codex/hooks/enforce-batch-budget-route.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12
MISSED file=.codex/hooks/enforce-batch-budget-route.ps1 Lines=136,137
CROUTE and XROUTE LinePercent=94.12 each (at least 85). Lines 136-137 are the defensive catch block of Test-BatchBudgetLargePathRoute, unchanged from the baseline helper (baseline ROUTE_BASE_PCT=94.12 with the same two lines missed).
