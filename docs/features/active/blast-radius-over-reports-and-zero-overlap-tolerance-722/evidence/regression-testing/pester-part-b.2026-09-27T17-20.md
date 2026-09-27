# Pester Part B Runs with Coverage, Re-run After P10-T13 (P10-T11)

Timestamp: 2026-09-27T17-20
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1,.claude/lib/blast-radius/BlastRadius.psm1,.claude/lib/blast-radius/BlastRadiusValidation.psm1 -CoverageOutputPath SCRATCH/pester-p10.xml
EXIT_CODE: 0
Output Summary: Re-run required by the P10-T13 re-run clause, because P10-T13 changed one primary file (the W3 test's heading literal in the write-intent Pester file, to remove a non-ASCII em dash that PSScriptAnalyzer reported as PSUseBOMForUnicodeEncodedFile). Both runs again printed FailedCount=0. The write-intent run printed TotalCount=28, PassedCount=28 with one passing line for every block B34 It name; the key-partition run printed TotalCount=6, PassedCount=6. Coverage values are identical to the first run: BlastRadiusWriteIntent.psm1 100%, BlastRadius.psm1 86.92%, BlastRadiusValidation.psm1 70.3% from the write-intent file alone. The first run is recorded in pester-part-b.2026-09-27T17-16.md and is kept.

## Run 1: write-intent file (ANSI codes and durations removed)

```text
   [+] drops glob-mention tokens (W1)
   [+] never drops the feature-folder glob (W1)
   [+] drops every token of a multi-word span (W2)
   [+] drops the tokens of a read task (W3)
   [+] lets a write verb override a read verb (W3)
   [+] drops tokens outside path_roots unless they are root surfaces (W4)
   [+] disables root anchoring when path_roots is empty (W4)
   [+] lets the spec contribute contracts only (W5)
   [+] drops placeholder-stem tokens (W6)
   [+] does not make a shared-surface read citation hard
   [+] matches current behavior when the flag is absent
   [+] matches current behavior when the flag is false
   [+] derives radii that pass V1 and V2 in write-intent mode
   [+] pins the same read-verb, write-verb, and placeholder-stem sets as the Python module
   [+] never adds a token under the write-intent rules
   [+] reproduces the expected radius for write-intent-glob-mention
   [+] reproduces the expected radius for write-intent-command-span
   [+] reproduces the expected radius for write-intent-read-task
   [+] reproduces the expected radius for write-intent-root-anchoring
   [+] reproduces the expected radius for write-intent-spec-contracts-only
   [+] reproduces the expected radius for write-intent-placeholder-stem
   [+] reproduces the expected radius for write-intent-shared-surface-read-citation
   [+] reproduces the expected radius for write-intent-flag-absent-matches-current
   [+] rejects the invalid shape flag-string
   [+] rejects the invalid shape flag-int
   [+] rejects the invalid shape path-roots-string
   [+] rejects the invalid shape path-roots-non-string-entry
   [+] keeps the feature-folder glob in write-intent normalization
TotalCount=28
PassedCount=28
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 AnalyzedLines=102 CoveredLines=102 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=93 LinePercent=86.92
COVERAGE file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 AnalyzedLines=101 CoveredLines=71 LinePercent=70.3
```

## Run 2: key-partition file

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 -CoveragePath (same three modules) -CoverageOutputPath SCRATCH/pester-p10.xml
EXIT_CODE of run 2: 0

```text
   [+] declares equal values for the runtime-describing keys in both copies
   [+] requires every separator-free self-hosted shared surface to reach the bundled copy
   [+] requires every top-level key in both copies to be classified and shared
   [+] requires a populated shared-surface list and module map in both copies
   [+] requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file
   [+] declares an empty bundled path_roots list
TotalCount=6
PassedCount=6
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 AnalyzedLines=102 CoveredLines=0 LinePercent=0
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=0 LinePercent=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 AnalyzedLines=101 CoveredLines=0 LinePercent=0
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
