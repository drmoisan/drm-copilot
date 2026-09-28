# Pester Part B Runs with Coverage (P10-T11)

Timestamp: 2026-09-27T17-16
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1,.claude/lib/blast-radius/BlastRadius.psm1,.claude/lib/blast-radius/BlastRadiusValidation.psm1 -CoverageOutputPath SCRATCH/pester-p10.xml
EXIT_CODE: 0
Output Summary: Both runs printed FailedCount=0. The write-intent run (P10-T2 file) printed TotalCount=28, PassedCount=28, with one passing line for every block B34 It name, including all eight 'reproduces the expected radius for <FixtureName>' cases and 'pins the same read-verb, write-verb, and placeholder-stem sets as the Python module'. The key-partition run (P10-T3 file) printed TotalCount=6, PassedCount=6, including 'declares an empty bundled path_roots list'. Coverage from the write-intent run alone: BlastRadiusWriteIntent.psm1 100% (102 of 102 analyzed lines), BlastRadius.psm1 86.92%, BlastRadiusValidation.psm1 70.3%; the key-partition file reads config files only and covers none of the three modules. These per-run values are informational; the whole-directory coverage gate is P16.

## Run 1: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 (ANSI codes removed)

```text
   [+] drops glob-mention tokens (W1) 97ms (74ms|23ms)
   [+] never drops the feature-folder glob (W1) 46ms (45ms|1ms)
   [+] drops every token of a multi-word span (W2) 5ms (5ms|1ms)
   [+] drops the tokens of a read task (W3) 37ms (36ms|1ms)
   [+] lets a write verb override a read verb (W3) 17ms (5ms|12ms)
   [+] drops tokens outside path_roots unless they are root surfaces (W4) 4ms (4ms|1ms)
   [+] disables root anchoring when path_roots is empty (W4) 11ms (11ms|1ms)
   [+] lets the spec contribute contracts only (W5) 12ms (12ms|1ms)
   [+] drops placeholder-stem tokens (W6) 4ms (3ms|1ms)
   [+] does not make a shared-surface read citation hard 86ms (84ms|1ms)
   [+] matches current behavior when the flag is absent 49ms (48ms|1ms)
   [+] matches current behavior when the flag is false 24ms (24ms|1ms)
   [+] derives radii that pass V1 and V2 in write-intent mode 163ms (163ms|0ms)
   [+] pins the same read-verb, write-verb, and placeholder-stem sets as the Python module 15ms (14ms|1ms)
   [+] never adds a token under the write-intent rules 527ms (526ms|1ms)
   [+] reproduces the expected radius for write-intent-glob-mention 23ms (20ms|2ms)
   [+] reproduces the expected radius for write-intent-command-span 9ms (9ms|1ms)
   [+] reproduces the expected radius for write-intent-read-task 11ms (10ms|1ms)
   [+] reproduces the expected radius for write-intent-root-anchoring 24ms (24ms|1ms)
   [+] reproduces the expected radius for write-intent-spec-contracts-only 13ms (12ms|1ms)
   [+] reproduces the expected radius for write-intent-placeholder-stem 11ms (11ms|1ms)
   [+] reproduces the expected radius for write-intent-shared-surface-read-citation 132ms (131ms|1ms)
   [+] reproduces the expected radius for write-intent-flag-absent-matches-current 46ms (46ms|1ms)
   [+] rejects the invalid shape flag-string 19ms (17ms|2ms)
   [+] rejects the invalid shape flag-int 4ms (3ms|2ms)
   [+] rejects the invalid shape path-roots-string 4ms (4ms|1ms)
   [+] rejects the invalid shape path-roots-non-string-entry 4ms (2ms|1ms)
   [+] keeps the feature-folder glob in write-intent normalization 13ms (12ms|1ms)
TotalCount=28
PassedCount=28
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 AnalyzedLines=102 CoveredLines=102 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=93 LinePercent=86.92
COVERAGE file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 AnalyzedLines=101 CoveredLines=71 LinePercent=70.3
```

## Run 2: tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 (ANSI codes removed)

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 -CoveragePath (same three modules) -CoverageOutputPath SCRATCH/pester-p10.xml
EXIT_CODE of run 2: 0

```text
   [+] declares equal values for the runtime-describing keys in both copies 48ms (28ms|20ms)
   [+] requires every separator-free self-hosted shared surface to reach the bundled copy 6ms (5ms|0ms)
   [+] requires every top-level key in both copies to be classified and shared 4ms (4ms|0ms)
   [+] requires a populated shared-surface list and module map in both copies 5ms (4ms|0ms)
   [+] requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file 6ms (5ms|0ms)
   [+] declares an empty bundled path_roots list 24ms (23ms|0ms)
TotalCount=6
PassedCount=6
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 AnalyzedLines=102 CoveredLines=0 LinePercent=0
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=0 LinePercent=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 AnalyzedLines=101 CoveredLines=0 LinePercent=0
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
