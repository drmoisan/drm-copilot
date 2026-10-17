# PowerShell Test with Coverage (P8-T3)

Timestamp: 2026-09-28T22-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/ci-gate -CoveragePath .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -CoverageOutputPath SCRATCH/ci-gate-final.xml
EXIT_CODE: 0
Output Summary:
- `TotalCount=17`, `PassedCount=17`, `FailedCount=0` (15 parser tests + 2 manifest tests).
- `COVERAGE file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12`
- Post-change parser line coverage is 94.12%. It meets the 85% threshold and equals the P0-T17 baseline of 94.12%, so there is no regression. The parser's executable content is unchanged apart from the `.EXAMPLE` help-comment path.
