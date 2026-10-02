# Claude Hook Test and Coverage Baseline (#769, P0-T15)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 -CoveragePath .claude/hooks/enforce-powershell-batch-budget.ps1 -CoverageOutputPath SCRATCH/cov-claude-baseline.xml -ReportPath SCRATCH/cov-claude-baseline.txt
EXIT_CODE: 0
Output Summary:
TotalCount=36
PassedCount=36
FailedCount=0
COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1 AnalyzedLines=129 CoveredLines=123 LinePercent=95.35
MISSED file=.claude/hooks/enforce-powershell-batch-budget.ps1 Lines=79,89,452,453,454,457
CLAUDE_BASE_PCT: 95.35
