# Remediation Full Pester Suite (P2-T8)

Timestamp: 2026-09-29T20-41
Command: date -u +%Y-%m-%dT%H:%M:%SZ; mcp__drm-copilot__run_poshqc_test (workspace_root REPO, no scan_folders); sh SCRATCH/run-ps.sh SCRATCH/junit-summary.ps1 -Path artifacts/pester/pester-junit.xml; sh SCRATCH/run-ps.sh SCRATCH/coverage-xml.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -BaseRef 43c9e95eaa39b3d896a9da5501cd57953033c2bc .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1
EXIT_CODE: 0
Output Summary:
- START=2026-09-30T00:33:45Z. MCP result: {"ok":true,"tool":"run_poshqc_test","summary":"Ran bundled PoshQC test against 'REPO'."} (fixed template; no counts read from it).
- A11 exit 0; A12 exit 0.
- JUNIT-LAST-WRITE-UTC=2026-09-30T00:40:47Z and COVERAGE-LAST-WRITE-UTC=2026-09-30T00:39:29Z, both later than START.
- JUNIT-TESTCASES=5726 (expected 5676 + 33 + 17 = 5726).
- JUNIT-FAILED=0; JUNIT-SKIPPED=10. No JUNIT-FAILED-CASE line was printed, so no PRE-EXISTING-STATE-DEPENDENT exception was needed.
- PRE-EXISTING-STATE-DEPENDENT: none.
- Every JUNIT-BLAST-SUITE line shows failures=0 errors=0 (22 suites), including the four new files: BlastRadiusGlob.RegexCache.Tests.ps1 tests=12, BlastRadiusConflict.PathOverlap.Tests.ps1 tests=21, BlastRadiusConflict.OverlappingPairs.Tests.ps1 tests=10, BlastRadiusScheduling.PairCost.Tests.ps1 tests=7. BlastRadius.HistoricalRuns.Tests.ps1 tests=9 time=58.298.
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 AnalyzedLines=77 CoveredLines=77 LinePercent=100
- CHANGED file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 ChangedLines=51 AnalyzedChangedLines=25 CoveredChangedLines=25 ChangedLinePercent=100
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusConflict.psm1 AnalyzedLines=97 CoveredLines=95 LinePercent=97.94
- CHANGED file=.claude/lib/blast-radius/BlastRadiusConflict.psm1 ChangedLines=193 AnalyzedChangedLines=63 CoveredChangedLines=62 ChangedLinePercent=98.41
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=116 CoveredLines=116 LinePercent=100
- CHANGED file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 ChangedLines=5 AnalyzedChangedLines=2 CoveredChangedLines=2 ChangedLinePercent=100
- Result: PASS.

Full A11 blast-suite lines:

```
JUNIT-BLAST-SUITE file=BlastRadius.Conflict.Tests.ps1 tests=32 failures=0 errors=0 time=1.103
JUNIT-BLAST-SUITE file=BlastRadius.HistoricalRuns.Tests.ps1 tests=9 failures=0 errors=0 time=58.298
JUNIT-BLAST-SUITE file=BlastRadius.KeyPartition.Tests.ps1 tests=6 failures=0 errors=0 time=0.108
JUNIT-BLAST-SUITE file=BlastRadius.Manifest.Tests.ps1 tests=4 failures=0 errors=0 time=0.085
JUNIT-BLAST-SUITE file=BlastRadius.Parity.Tests.ps1 tests=80 failures=0 errors=0 time=3.799
JUNIT-BLAST-SUITE file=BlastRadius.Regression452.Tests.ps1 tests=26 failures=0 errors=0 time=1.151
JUNIT-BLAST-SUITE file=BlastRadius.Tests.ps1 tests=47 failures=0 errors=0 time=1.397
JUNIT-BLAST-SUITE file=BlastRadius.TruthTable.Tests.ps1 tests=23 failures=0 errors=0 time=1.422
JUNIT-BLAST-SUITE file=BlastRadius.Validation.Tests.ps1 tests=31 failures=0 errors=0 time=1.943
JUNIT-BLAST-SUITE file=BlastRadiusConfig.Tests.ps1 tests=49 failures=0 errors=0 time=0.409
JUNIT-BLAST-SUITE file=BlastRadiusConflict.OverlappingPairs.Tests.ps1 tests=10 failures=0 errors=0 time=0.907
JUNIT-BLAST-SUITE file=BlastRadiusConflict.PathOverlap.Tests.ps1 tests=21 failures=0 errors=0 time=0.817
JUNIT-BLAST-SUITE file=BlastRadiusConflict.Tests.ps1 tests=13 failures=0 errors=0 time=0.730
JUNIT-BLAST-SUITE file=BlastRadiusExtraction.Path.Tests.ps1 tests=61 failures=0 errors=0 time=0.294
JUNIT-BLAST-SUITE file=BlastRadiusExtraction.Tests.ps1 tests=21 failures=0 errors=0 time=0.127
JUNIT-BLAST-SUITE file=BlastRadiusGlob.RegexCache.Tests.ps1 tests=12 failures=0 errors=0 time=0.099
JUNIT-BLAST-SUITE file=BlastRadiusGlob.Tests.ps1 tests=49 failures=0 errors=0 time=0.266
JUNIT-BLAST-SUITE file=BlastRadiusNormalization.Tests.ps1 tests=15 failures=0 errors=0 time=0.747
JUNIT-BLAST-SUITE file=BlastRadiusScheduling.PairCost.Tests.ps1 tests=7 failures=0 errors=0 time=0.301
JUNIT-BLAST-SUITE file=BlastRadiusScheduling.Tests.ps1 tests=51 failures=0 errors=0 time=2.227
JUNIT-BLAST-SUITE file=BlastRadiusTokenShape.Tests.ps1 tests=16 failures=0 errors=0 time=0.138
JUNIT-BLAST-SUITE file=BlastRadiusWriteIntent.Tests.ps1 tests=28 failures=0 errors=0 time=1.851
```
