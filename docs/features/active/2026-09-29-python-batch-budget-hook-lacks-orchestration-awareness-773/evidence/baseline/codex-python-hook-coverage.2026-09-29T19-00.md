# Codex Python Hook Coverage Baseline (P0-T16)

Timestamp: 2026-09-29T19-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 -CoveragePath .codex/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-xpy-base.xml -ReportPath SCRATCH/cov-xpy-base.txt
EXIT_CODE: 0
Output Summary:
TotalCount=41
PassedCount=41
FailedCount=0
COVERAGE file=.codex/hooks/enforce-python-batch-budget.ps1 AnalyzedLines=87 CoveredLines=84 LinePercent=96.55
MISSED file=.codex/hooks/enforce-python-batch-budget.ps1 Lines=245,246,247
XPY_BASE_PCT=96.55
