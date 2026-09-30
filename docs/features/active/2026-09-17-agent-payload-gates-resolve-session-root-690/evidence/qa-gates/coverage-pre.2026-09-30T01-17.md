# Final Coverage CG-PRE (P12-T5)

Timestamp: 2026-09-30T01-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <CG-PRE final test list> -CoveragePath <group coverage files> -CoverageOutputPath SCRATCH/cov-pre-final.xml -ReportPath SCRATCH/cov-pre-final.txt
EXIT_CODE: 0
Output Summary:
- TotalCount=420
- PassedCount=420
- FailedCount=0
- COVERAGE file=.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 AnalyzedLines=153 CoveredLines=148 LinePercent=96.73
- COVERAGE file=.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 AnalyzedLines=67 CoveredLines=67 LinePercent=100
- FAILED: lines: none
- Threshold check: PRE 96.73 >= BASEPCT 93.42; PRES 100 >= BASEPCT 100. PASS.
