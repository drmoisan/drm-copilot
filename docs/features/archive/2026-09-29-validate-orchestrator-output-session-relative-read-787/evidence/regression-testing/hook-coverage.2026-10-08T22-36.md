# HOOK and SIB Coverage (P3-T13)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <SET-HOOK list> -CoveragePath .claude/hooks/validate-orchestrator-output.ps1,.claude/hooks/validate-orchestrator-output-resolution.ps1 -CoverageOutputPath SCRATCH/cov-hook-p3.xml -ReportPath SCRATCH/cov-hook-p3.txt
EXIT_CODE: 0
Output Summary:
TotalCount=93
PassedCount=93
FailedCount=0
COVERAGE file=.claude/hooks/validate-orchestrator-output.ps1 AnalyzedLines=130 CoveredLines=123 LinePercent=94.62
MISSED file=.claude/hooks/validate-orchestrator-output.ps1 Lines=61,176,476,477,478,479,482
COVERAGE file=.claude/hooks/validate-orchestrator-output-resolution.ps1 AnalyzedLines=96 CoveredLines=95 LinePercent=98.96
MISSED file=.claude/hooks/validate-orchestrator-output-resolution.ps1 Lines=89

Missed-line notes (each line read back with `sed -n` after the run): HOOK 476-482 is the script entry point, which the dot-source guard skips under test (also missed at baseline, as lines 415-421). HOOK 61 is the catch-block assignment for a failed sibling dot-source (`$script:OrchestratorOutputResolverImportFailure = 'validate-orchestrator-output-resolution.ps1'`). HOOK 176 is the existing blank-`runbook_path` return inside Test-HumanInteractionShape (baseline line 140, also missed at baseline). SIB 89 is the empty `-CheckpointPath` return of the shape check (`'the -CheckpointPath value is empty'`); no row passes an empty value.

Rows added under P3-T13: none (both LinePercent values are at least 85). The P3-T11 expected total stays at 93.

Result: PASS.
