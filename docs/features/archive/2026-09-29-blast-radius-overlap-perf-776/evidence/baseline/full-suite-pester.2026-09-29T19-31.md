# Baseline Full Pester Suite (P0-T12)

Timestamp: 2026-09-29T19-31
Command: date -u +%Y-%m-%dT%H:%M:%SZ; mcp__drm-copilot__run_poshqc_test (workspace_root REPO, no scan_folders); sh SCRATCH/run-ps.sh SCRATCH/junit-summary.ps1 -Path artifacts/pester/pester-junit.xml; sh SCRATCH/run-ps.sh SCRATCH/coverage-xml.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -BaseRef 43c9e95eaa39b3d896a9da5501cd57953033c2bc .claude/lib/blast-radius/BlastRadiusGlob.psm1 .claude/lib/blast-radius/BlastRadiusConflict.psm1
EXIT_CODE: 0
START: 2026-09-29T23:18:03Z
Output Summary:
- MCP-TEST result text (fixed template, not used for counts): {"ok":true,"tool":"run_poshqc_test","summary":"Ran bundled PoshQC test against 'REPO'."}
- JUNIT-LAST-WRITE-UTC=2026-09-29T23:31:24Z (later than START)
- COVERAGE-LAST-WRITE-UTC=2026-09-29T23:29:56Z (later than START)
- JUNIT-TESTCASES=5676
- JUNIT-FAILED=0
- JUNIT-SKIPPED=10
- JUNIT-FAILED-CASE lines: none. The baseline failure set is empty.
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusGlob.psm1 AnalyzedLines=70 CoveredLines=70 LinePercent=100
- COVERAGE file=.claude/lib/blast-radius/BlastRadiusConflict.psm1 AnalyzedLines=43 CoveredLines=42 LinePercent=97.67
- CHANGED lines for both modules: ChangedLines=0 AnalyzedChangedLines=0 ChangedLinePercent=NA (expected at baseline; no edits since BASE_SHA).
- junit-summary.ps1 exit 0; coverage-xml.ps1 exit 0.
- Result: PASS. P2-T7 expects JUNIT-TESTCASES = 5676 + 33 = 5709.

JUNIT-BLAST-SUITE lines (verbatim):

```
JUNIT-BLAST-SUITE file=BlastRadius.Conflict.Tests.ps1 tests=32 failures=0 errors=0 time=1.211
JUNIT-BLAST-SUITE file=BlastRadius.HistoricalRuns.Tests.ps1 tests=9 failures=0 errors=0 time=426.233
JUNIT-BLAST-SUITE file=BlastRadius.KeyPartition.Tests.ps1 tests=6 failures=0 errors=0 time=0.089
JUNIT-BLAST-SUITE file=BlastRadius.Manifest.Tests.ps1 tests=4 failures=0 errors=0 time=0.062
JUNIT-BLAST-SUITE file=BlastRadius.Parity.Tests.ps1 tests=80 failures=0 errors=0 time=24.375
JUNIT-BLAST-SUITE file=BlastRadius.Regression452.Tests.ps1 tests=26 failures=0 errors=0 time=1.461
JUNIT-BLAST-SUITE file=BlastRadius.Tests.ps1 tests=47 failures=0 errors=0 time=1.052
JUNIT-BLAST-SUITE file=BlastRadius.TruthTable.Tests.ps1 tests=23 failures=0 errors=0 time=0.828
JUNIT-BLAST-SUITE file=BlastRadius.Validation.Tests.ps1 tests=31 failures=0 errors=0 time=1.445
JUNIT-BLAST-SUITE file=BlastRadiusConfig.Tests.ps1 tests=49 failures=0 errors=0 time=0.484
JUNIT-BLAST-SUITE file=BlastRadiusConflict.Tests.ps1 tests=13 failures=0 errors=0 time=0.962
JUNIT-BLAST-SUITE file=BlastRadiusExtraction.Path.Tests.ps1 tests=61 failures=0 errors=0 time=0.297
JUNIT-BLAST-SUITE file=BlastRadiusExtraction.Tests.ps1 tests=21 failures=0 errors=0 time=0.133
JUNIT-BLAST-SUITE file=BlastRadiusGlob.Tests.ps1 tests=49 failures=0 errors=0 time=0.270
JUNIT-BLAST-SUITE file=BlastRadiusNormalization.Tests.ps1 tests=15 failures=0 errors=0 time=0.787
JUNIT-BLAST-SUITE file=BlastRadiusScheduling.Tests.ps1 tests=51 failures=0 errors=0 time=2.441
JUNIT-BLAST-SUITE file=BlastRadiusTokenShape.Tests.ps1 tests=16 failures=0 errors=0 time=0.187
JUNIT-BLAST-SUITE file=BlastRadiusWriteIntent.Tests.ps1 tests=28 failures=0 errors=0 time=2.178
```
