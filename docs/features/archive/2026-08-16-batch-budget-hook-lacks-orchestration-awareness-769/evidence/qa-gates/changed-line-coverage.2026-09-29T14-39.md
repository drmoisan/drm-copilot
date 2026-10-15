# Changed-Line Coverage (#769, P9-T6)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -CoverageReportPath SCRATCH/cov-claude-final.txt -BaseRef b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e -File .claude/hooks/enforce-powershell-batch-budget.ps1,.claude/hooks/enforce-powershell-batch-budget-route.ps1; sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -CoverageReportPath SCRATCH/cov-codex-final.txt -BaseRef b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e -File .codex/hooks/enforce-powershell-batch-budget.ps1
EXIT_CODE: 0
Output Summary:
CHANGED-COVERAGE file=.claude/hooks/enforce-powershell-batch-budget.ps1 ChangedLines=95 ChangedAnalyzed=33 ChangedCovered=33 ChangedPercent=100
CHANGED-COVERAGE file=.claude/hooks/enforce-powershell-batch-budget-route.ps1 ChangedLines=137 ChangedAnalyzed=34 ChangedCovered=32 ChangedPercent=94.12
CHANGED-COVERAGE file=.codex/hooks/enforce-powershell-batch-budget.ps1 ChangedLines=285 ChangedAnalyzed=86 ChangedCovered=83 ChangedPercent=96.51
Three lines, none MISSING, each ChangedPercent at least 85. CROUTE is new at BASE_SHA, so all its lines count as changed.
