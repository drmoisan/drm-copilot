# Final Coverage CG-MERGE (P12-T8)

Timestamp: 2026-09-30T01-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <CG-MERGE final test list> -CoveragePath <group coverage files> -CoverageOutputPath SCRATCH/cov-merge-final.xml -ReportPath SCRATCH/cov-merge-final.txt
EXIT_CODE: 0
Output Summary:
- TotalCount=130
- PassedCount=130
- FailedCount=0
- COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 AnalyzedLines=125 CoveredLines=121 LinePercent=96.8
- COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 AnalyzedLines=36 CoveredLines=32 LinePercent=88.89
- FAILED: lines: none
- Threshold check: MRG 96.8 >= BASEPCT 96.67; MRGR 88.89 >= 85. PASS.
