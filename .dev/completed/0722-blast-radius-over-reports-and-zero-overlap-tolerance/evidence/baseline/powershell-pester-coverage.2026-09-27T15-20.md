# PowerShell Test and Coverage Baseline (P0-T32)

Timestamp: 2026-09-27T15-20
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadius.psm1,.claude/lib/blast-radius/BlastRadiusValidation.psm1 -CoverageOutputPath SCRATCH/pester-baseline.xml ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: Blast-radius Pester suite: TotalCount=438, PassedCount=438, FailedCount=0; baseline FAILED set empty. LinePercent: BlastRadius.psm1 100 (97/97 lines); BlastRadiusValidation.psm1 97 (97/100 lines). Convention test (block B46): TotalCount=6, PassedCount=6, FailedCount=0. Uniqueness guard (block B47): TotalCount=5, PassedCount=5, FailedCount=0. Stop condition not reached.

## Blast-radius suite with coverage (verbatim summary)

```text
Tests Passed: 438, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 98.34% / 75%. 302 analyzed Commands in 2 Files.
TotalCount=438
PassedCount=438
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=97 CoveredLines=97 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 AnalyzedLines=100 CoveredLines=97 LinePercent=97
```

| Metric | Value |
| --- | --- |
| TotalCount | 438 |
| PassedCount | 438 |
| FailedCount | 0 |
| FAILED lines (baseline failure set) | none |
| BlastRadius.psm1 LinePercent | 100 |
| BlastRadiusValidation.psm1 LinePercent | 97 |

The comma-joined -CoveragePath value was split by script A3 into the two modules, as the two COVERAGE
lines show.

## Convention test run (block B46; recorded separately)

```text
[+] keeps every claude library module within the five hundred line limit
Tests Passed: 6, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=6
PassedCount=6
FailedCount=0
```

## Test-name uniqueness guard run (block B47)

```text
[+] reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1
Tests Passed: 5, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=5
PassedCount=5
FailedCount=0
```

The B47 run printed FailedCount=0, and the convention run printed FailedCount=0, so the stop condition
was not reached.
