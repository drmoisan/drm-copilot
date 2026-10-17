# Coverage Baseline CG-PRE (P0-T26)

Timestamp: 2026-09-29T23-11
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <8 EXIST-PRE suites> -CoveragePath .claude/hooks/enforce-orchestration-preimplementation-gate.ps1,.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 -CoverageOutputPath SCRATCH/cov-pre-base.xml -ReportPath SCRATCH/cov-pre-base.txt
EXIT_CODE: 0
Output Summary:
- TotalCount=393
- PassedCount=393
- FailedCount=0
- FAILED: lines: none
- COVERAGE file=.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 AnalyzedLines=152 CoveredLines=142 LinePercent=93.42 (BASEPCT)
- COVERAGE file=.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 AnalyzedLines=27 CoveredLines=27 LinePercent=100 (BASEPCT)
