# Coverage Baseline CG-MERGE (P0-T29)

Timestamp: 2026-09-29T23-11
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <enforce-epic-merge-gate.Tests.ps1, .Authorization, .AuthorizationFields, .TriggerScoping> -CoveragePath .claude/hooks/enforce-epic-merge-gate.ps1 -CoverageOutputPath SCRATCH/cov-merge-base.xml -ReportPath SCRATCH/cov-merge-base.txt
EXIT_CODE: 0
Output Summary:
- TotalCount=120
- PassedCount=120
- FailedCount=0
- FAILED: lines: none
- COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 AnalyzedLines=120 CoveredLines=116 LinePercent=96.67 (BASEPCT)
