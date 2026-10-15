# PowerShell Test and Coverage Baseline (P0-T17)

Timestamp: 2026-09-28T21-52
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 -CoveragePath scripts/orchestration/Invoke-CiGateParser.ps1 -CoverageOutputPath SCRATCH/ci-gate-baseline.xml
EXIT_CODE: 0
Output Summary:
- `TotalCount=15`, `PassedCount=15`, `FailedCount=0`
- `COVERAGE file=scripts/orchestration/Invoke-CiGateParser.ps1 AnalyzedLines=34 CoveredLines=32 LinePercent=94.12`
- Baseline PowerShell line coverage for the parser: 94.12%.
