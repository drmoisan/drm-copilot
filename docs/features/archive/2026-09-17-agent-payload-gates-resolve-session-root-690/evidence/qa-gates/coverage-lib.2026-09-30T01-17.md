# Final Coverage CG-LIB (P12-T4)

Timestamp: 2026-09-30T01-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <CG-LIB final test list> -CoveragePath <group coverage files> -CoverageOutputPath SCRATCH/cov-lib-final.xml -ReportPath SCRATCH/cov-lib-final.txt
EXIT_CODE: 0
Output Summary:
- TotalCount=252
- PassedCount=252
- FailedCount=0
- COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 AnalyzedLines=106 CoveredLines=102 LinePercent=96.23
- COVERAGE file=.claude/lib/worktree-resolution/EpicScopeResolution.psm1 AnalyzedLines=112 CoveredLines=101 LinePercent=90.18
- COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 AnalyzedLines=146 CoveredLines=146 LinePercent=100
- FAILED: lines: none
- Threshold check: WRR 100 >= 85; WIR 96.23 >= BASEPCT 96.23; ESR 90.18 >= BASEPCT 89.42. PASS.
