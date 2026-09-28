# Pester Part A, Re-run after P5-T14 Format (P5-T10 re-run)

Timestamp: 2026-09-27T16-35
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <file> -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath <xml under SCRATCH> (one run per file of P5-T2, P5-T3, P5-T4)
EXIT_CODE: 0
Output Summary: Re-run required by P5-T14 because the MCP format call changed the hash of tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 (whitespace alignment of one hashtable literal only). All three runs exited 0 and printed FailedCount=0. P5-T2 file: TotalCount=50, PassedCount=50, 50 passing It lines (one per B23 entry, unchanged from the original run), scheduling module COVERAGE AnalyzedLines=122 CoveredLines=122 LinePercent=100. P5-T3 file: 6/6 passed, LinePercent=90.98. P5-T4 file: 5/5 passed, LinePercent=0 (that file does not exercise the scheduling module). Results are identical to the original P5-T10 artifact pester-part-a.2026-09-27T15-52.md.

## Run 1: P5-T2 file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/pester-p5.xml
EXIT_CODE: 0

```text
TotalCount=50
PassedCount=50
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=122 LinePercent=100
```

## Run 2: P5-T3 file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/pester-p5-2.xml
EXIT_CODE: 0

```text
TotalCount=6
PassedCount=6
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=111 LinePercent=90.98
```

## Run 3: P5-T4 file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1 -CoverageOutputPath SCRATCH/pester-p5-3.xml
EXIT_CODE: 0

```text
TotalCount=5
PassedCount=5
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=0 LinePercent=0
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
