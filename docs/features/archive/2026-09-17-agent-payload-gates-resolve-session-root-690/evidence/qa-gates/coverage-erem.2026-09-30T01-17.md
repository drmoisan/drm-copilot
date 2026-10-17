# Final Coverage CG-EREM (P12-T9)

Timestamp: 2026-09-30T01-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <CG-EREM final test list> -CoveragePath <group coverage files> -CoverageOutputPath SCRATCH/cov-erem-final.xml -ReportPath SCRATCH/cov-erem-final.txt
EXIT_CODE: 0
Output Summary:
- TotalCount=143
- PassedCount=143
- FailedCount=0
- COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 AnalyzedLines=109 CoveredLines=104 LinePercent=95.41
- COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 AnalyzedLines=23 CoveredLines=22 LinePercent=95.65
- FAILED: lines: none
- Threshold check: EREM 95.41 >= BASEPCT 95.24; EREMR 95.65 >= 85. PASS.
