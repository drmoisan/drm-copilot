# R1 Fail-Before: Historical-Runs Suite Alone (Remediation Cycle 1, P0-T12) [expect-fail]

Timestamp: 2026-09-27T19-40
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadius.psm1 -CoverageOutputPath SCRATCH/rem-p0-historical.xml
EXIT_CODE: 0
ExpectedExitCode: 0

(A3 exits 0 whatever the test outcome; the fail signal is FailedCount.)

## Output (verbatim summary lines)

```text
TotalCount=9
PassedCount=9
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=112 LinePercent=91.8
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=67 LinePercent=62.62
```

The literal "is not available; import the facade module" occurs 0 times in the run output (grep -c -F).

## Branch rule

R1-REPRODUCED-IN-ISOLATION: no

FailedCount is 0, so the branch condition is not met. The R1 fail-before evidence is the CI-FAILED set recorded by P0-T10 in FEATURE/evidence/remediation-baseline/ci-run-36356018317.2026-09-27T19-36.md.

CI-FAILED lines that P0-T10 assigns to tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 (6):

```text
CI-FAILED: Blast-radius historical runs.matches detection at tolerance 0 for epic-655-followups 59ms (58ms|1ms)
CI-FAILED: Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for epic-655-followups 1.61s (1.61s|1ms)
CI-FAILED: Blast-radius historical runs.matches detection at tolerance 0 for backlog-2026-09-26 61ms (60ms|1ms)
CI-FAILED: Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for backlog-2026-09-26 2.61s (2.6s|1ms)
CI-FAILED: Blast-radius historical runs.matches detection at tolerance 0 for followups-2026-09-27 45ms (45ms|0ms)
CI-FAILED: Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for followups-2026-09-27 3.85s (3.85s|0ms)
```

Output Summary: PASS (expect-fail task, "no" branch). Exit 0; TotalCount=9, PassedCount=9, FailedCount=0; COVERAGE BlastRadiusScheduling.psm1 LinePercent=91.8, BlastRadius.psm1 LinePercent=62.62. R1 is not reproduced in isolation; the R1 fail-before evidence is the 6 historical-runs CI-FAILED lines of P0-T10, quoted above.
