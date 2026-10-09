# PowerShell Coverage Baseline (P0-T25)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1,tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 -CoveragePath .claude/hooks/validate-orchestrator-output.ps1 -CoverageOutputPath SCRATCH/cov-hook-base.xml -ReportPath SCRATCH/cov-hook-base.txt
EXIT_CODE: 0
Output Summary:
TotalCount=57
PassedCount=57
FailedCount=0
COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AnalyzedLines=110 CoveredLines=104 LinePercent=94.55
MISSED file=.claude/hooks/validate-orchestrator-output.ps1 Lines=140,415,416,417,418,421

BASE_HOOK_PCT=94.55

Baseline for files that do not yet exist:
- .claude/hooks/validate-orchestrator-output-resolution.ps1 (SIB): NEW-FILE
- .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 (PORT): NEW-FILE

Result: PASS (numeric LinePercent recorded).
