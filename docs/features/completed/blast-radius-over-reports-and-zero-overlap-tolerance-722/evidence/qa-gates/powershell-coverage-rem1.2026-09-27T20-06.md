# Blast-Radius Directory Coverage, Convention, and Uniqueness (Remediation Cycle 1, P2-T3)

Timestamp: 2026-09-27T20-06
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadius.psm1 -CoverageOutputPath SCRATCH/rem-p2-directory.xml ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0

## Blast-radius directory with coverage (exit 0; verbatim summary)

```text
TotalCount=535
PassedCount=535
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=118 CoveredLines=118 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=107 LinePercent=100
```

No FAILED: line was printed.

## Convention suite (exit 0)

```text
TotalCount=6
PassedCount=6
FailedCount=0
```

## Test-name uniqueness suite (exit 0)

```text
TotalCount=5
PassedCount=5
FailedCount=0
```

## Baseline comparison

Main plan baseline values from FEATURE/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T18-09.md beside the new values:

| Measure | Main plan baseline | This cycle |
| --- | --- | --- |
| Blast-radius directory TotalCount | 534 | 535 (one net new It) |
| BlastRadiusScheduling.psm1 LinePercent | 100 (122/122) | 100 (118/118) |
| BlastRadius.psm1 LinePercent | 100 (107/107) | 100 (107/107) |
| Convention suite FailedCount | 0 | 0 |
| Uniqueness suite FailedCount | 0 | 0 |

The scheduling module's analyzed line count fell from 122 to 118 because the Get-ConflictRelationCommand helper was deleted and two guard lines were added.

Output Summary: PASS. Directory run TotalCount=535, FailedCount=0; LinePercent 100 for BlastRadiusScheduling.psm1 and 100 for BlastRadius.psm1 (both at least 85, no regression from the 100/100 baseline); convention 6/6 and uniqueness 5/5 with FailedCount=0.
