# Claude Python Hook Coverage Baseline (P0-T15)

Timestamp: 2026-09-29T19-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 -CoveragePath .claude/hooks/enforce-python-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-cpy-base.xml -ReportPath SCRATCH/cov-cpy-base.txt
EXIT_CODE: 0
Output Summary:
TotalCount=35
PassedCount=35
FailedCount=0
COVERAGE file=.claude/hooks/enforce-python-batch-budget.ps1 AnalyzedLines=129 CoveredLines=123 LinePercent=95.35
MISSED file=.claude/hooks/enforce-python-batch-budget.ps1 Lines=76,86,449,450,451,454
CPY_BASE_PCT=95.35
