# Changed-Line Coverage (P6-T8), pass 1

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -CoverageReportPath SCRATCH/cov-final.txt -BaseRef 497cb504ad9a4e5435dc8946333ebc28baea50c4 -File .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1,.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1
EXIT_CODE: 0
Output Summary:
CHANGED-COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 ChangedLines=71 ChangedAnalyzed=28 ChangedCovered=27 ChangedPercent=96.43
CHANGED-COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 ChangedLines=314 ChangedAnalyzed=96 ChangedCovered=95 ChangedPercent=98.96
CHANGED-COVERAGE file=.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1 ChangedLines=346 ChangedAnalyzed=108 ChangedCovered=108 ChangedPercent=100

SIB and PORT are absent at the base ref, so every line counts as changed. The one changed HOOK line that is not covered is line 61 (the catch assignment for a failed sibling dot-source).

Result: PASS (three CHANGED-COVERAGE lines, each ChangedPercent at least 85).
