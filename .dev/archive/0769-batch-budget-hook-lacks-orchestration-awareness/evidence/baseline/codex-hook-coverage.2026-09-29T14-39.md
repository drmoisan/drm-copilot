# Codex Hook Test and Coverage Baseline (#769, P0-T16)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 -CoveragePath .codex/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-codex-baseline.xml -ReportPath SCRATCH/cov-codex-baseline.txt
EXIT_CODE: 0
Output Summary:
TotalCount=48
PassedCount=48
FailedCount=0
COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=87 CoveredLines=84 LinePercent=96.55
MISSED file=.codex/hooks/enforce-powershell-batch-budget.ps1 Lines=247,248,249
CODEX_BASE_PCT: 96.55
