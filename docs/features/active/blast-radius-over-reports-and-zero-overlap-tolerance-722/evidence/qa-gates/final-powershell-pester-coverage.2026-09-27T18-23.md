# Final PowerShell Tests and Coverage (P16-T4)

Timestamp: 2026-09-27T18-23
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1,.claude/lib/blast-radius/BlastRadius.psm1,.claude/lib/blast-radius/BlastRadiusValidation.psm1 -CoverageOutputPath SCRATCH/pester-final.xml ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: PASS. Blast-radius Pester suite: TotalCount=534, PassedCount=534, FailedCount=0, no FAILED line, zero "[-]" result lines (the P0-T32 baseline failure set is empty, so there is no failure to compare). Every It in the three files carrying the B23, B24, and B34 blocks passed: BlastRadiusScheduling.Tests.ps1 50 passed / 0 failed, BlastRadius.HistoricalRuns.Tests.ps1 9 / 0, BlastRadiusWriteIntent.Tests.ps1 28 / 0. LinePercent per B41 module: BlastRadiusScheduling.psm1 100 (122/122), BlastRadiusWriteIntent.psm1 100 (102/102), BlastRadius.psm1 100 (107/107), BlastRadiusValidation.psm1 97.03 (98/101); all >= 85. Convention test (B46): TotalCount=6, PassedCount=6, FailedCount=0. Uniqueness guard (B47): TotalCount=5, PassedCount=5, FailedCount=0. All three runs exited 0.

## Blast-radius suite with coverage (verbatim summary)

```text
Tests Passed: 534, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 98.98% / 75%. 688 analyzed Commands in 4 Files.
TotalCount=534
PassedCount=534
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=122 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 AnalyzedLines=102 CoveredLines=102 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=107 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 AnalyzedLines=101 CoveredLines=98 LinePercent=97.03
```

The comma-joined -CoveragePath value was split by script A3 into the four modules, as the four
COVERAGE lines show.

## Per-file result lines (ANSI removed; "[+]" passed, "[-]" failed)

| Test file | Passed | Failed | Carries |
| --- | --- | --- | --- |
| BlastRadius.Conflict.Tests.ps1 | 32 | 0 | |
| BlastRadius.HistoricalRuns.Tests.ps1 | 9 | 0 | B24 |
| BlastRadius.KeyPartition.Tests.ps1 | 6 | 0 | |
| BlastRadius.Manifest.Tests.ps1 | 4 | 0 | |
| BlastRadius.Parity.Tests.ps1 | 80 | 0 | |
| BlastRadius.Tests.ps1 | 47 | 0 | |
| BlastRadius.TruthTable.Tests.ps1 | 23 | 0 | |
| BlastRadius.Validation.Tests.ps1 | 31 | 0 | |
| BlastRadiusConfig.Tests.ps1 | 49 | 0 | |
| BlastRadiusConflict.Tests.ps1 | 13 | 0 | |
| BlastRadiusExtraction.Path.Tests.ps1 | 61 | 0 | |
| BlastRadiusExtraction.Tests.ps1 | 21 | 0 | |
| BlastRadiusGlob.Tests.ps1 | 49 | 0 | |
| BlastRadiusNormalization.Tests.ps1 | 15 | 0 | |
| BlastRadiusScheduling.Tests.ps1 | 50 | 0 | B23 |
| BlastRadiusTokenShape.Tests.ps1 | 16 | 0 | |
| BlastRadiusWriteIntent.Tests.ps1 | 28 | 0 | B34 |
| Total | 534 | 0 | |

## Convention test run (block B46)

```text
[+] discovers the claude library modules on disk
[+] sets the fail-fast error preference at module scope in every discovered module
[+] guards every load-time sibling import with an explicit stop preference
[+] states the fail-fast convention in the module help block
[+] leaves the caller error preference unchanged after import
[+] keeps every claude library module within the five hundred line limit
Tests Passed: 6, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=6
PassedCount=6
FailedCount=0
```

## Test-name uniqueness guard run (block B47)

```text
[+] detects two sibling It names that differ only by letter case
[+] detects a literal -ForEach whose rows differ only by data-value case
[+] reports no collision when a literal -ForEach disambiguates rows with a distinct data key
[+] skips a non-literal -ForEach argument without raising a collision
[+] reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1
Tests Passed: 5, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=5
PassedCount=5
FailedCount=0
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
