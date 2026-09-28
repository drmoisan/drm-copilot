# R1 Pass-After: Three Suites Alone, Each in a Fresh Process (Remediation Cycle 1, P2-T2)

Timestamp: 2026-09-27T20-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath <suite> -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadius.psm1 -CoverageOutputPath <SCRATCH/rem-p2-scheduling.xml | SCRATCH/rem-p2-historical.xml | SCRATCH/rem-p2-writeintent.xml>   (three separate runs)
EXIT_CODE: 0

## Run 1: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 (exit 0)

```text
TotalCount=51
PassedCount=51
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=118 CoveredLines=118 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=42 LinePercent=39.25
   [+] fails fast naming -Relation when the relation is omitted 6ms (5ms|1ms)
   [+] invokes the supplied relation rather than resolving a command 9ms (9ms|0ms)
```

## Run 2: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 (exit 0)

```text
TotalCount=9
PassedCount=9
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=118 CoveredLines=109 LinePercent=92.37
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=67 LinePercent=62.62
```

## Run 3: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 (exit 0)

```text
TotalCount=28
PassedCount=28
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=118 CoveredLines=107 LinePercent=90.68
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=93 LinePercent=86.92
```

No FAILED: line was printed by any of the three runs. The per-suite coverage values are single-suite figures for information; the directory-level coverage gate is P2-T3.

## Checks

- All three runs exit 0 with FailedCount=0 and no FAILED line: yes.
- Scheduling run TotalCount=51 (50 before, minus the removed Get-Command mock It, plus the two new Its) with "[+]" lines for both new Its: yes.
- Historical run TotalCount=9: yes.
- Write-intent run TotalCount=28, equal to WI_TOTAL recorded by P0-T15: yes.

Output Summary: PASS. Scheduling 51/51, historical-runs 9/9, write-intent 28/28 (WI_TOTAL=28), each in a fresh process; both new scheduling Its pass.
