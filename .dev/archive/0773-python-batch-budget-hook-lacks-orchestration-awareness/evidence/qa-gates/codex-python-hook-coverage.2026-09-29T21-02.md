# Final Coverage: Codex Python Hook (P11-T6)

Timestamp: 2026-09-29T21-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1,tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 -CoveragePath .codex/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-xpy-final.xml -ReportPath SCRATCH/cov-xpy-final.txt
EXIT_CODE: 0
Output Summary:
TotalCount=68
PassedCount=68
FailedCount=0
COVERAGE file=.codex/hooks/enforce-python-batch-budget.ps1 AnalyzedLines=99 CoveredLines=98 LinePercent=98.99
MISSED file=.codex/hooks/enforce-python-batch-budget.ps1 Lines=341
XPYHOOK LinePercent=98.99 (threshold 85; baseline XPY_BASE_PCT=96.55).
