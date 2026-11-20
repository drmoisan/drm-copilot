# R1 Fail-Before: Scheduling Suite Alone (Remediation Cycle 1, P0-T11) [expect-fail]

Timestamp: 2026-09-27T19-37
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 -CoveragePath .claude/lib/blast-radius/BlastRadiusScheduling.psm1,.claude/lib/blast-radius/BlastRadius.psm1 -CoverageOutputPath SCRATCH/rem-p0-scheduling.xml
EXIT_CODE: 0
ExpectedExitCode: 0

(A3 exits 0 whatever the test outcome; the fail signal is FailedCount.)

## Output (verbatim summary lines)

```text
TotalCount=50
PassedCount=50
FailedCount=0
COVERAGE file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 AnalyzedLines=122 CoveredLines=122 LinePercent=100
COVERAGE file=.claude/lib/blast-radius/BlastRadius.psm1 AnalyzedLines=107 CoveredLines=42 LinePercent=39.25
```

The literal "is not available; import the facade module" occurs 0 times in the run output (grep -c -F).

## Branch rule

R1-REPRODUCED-IN-ISOLATION: no

FailedCount is 0, so the branch condition (FailedCount greater than 0 and the literal present) is not met. In a fresh process the suite imports the facade and the scheduling module in an order under which Get-Command in the scheduling module scope resolves Test-BlastRadiusConflict, so the defect does not surface when this file runs alone. The R1 fail-before evidence is the CI-FAILED set recorded by P0-T10 in FEATURE/evidence/remediation-baseline/ci-run-36356018317.2026-09-27T19-36.md (CI run 36356018317 at f5d06476, one process for the whole tree with coverage).

CI-FAILED lines that P0-T10 assigns to tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 (26):

```text
CI-FAILED: BlastRadiusScheduling.Edge rule terms.keeps a shared-surface overlap hard at every tolerance 51ms (50ms|1ms)
CI-FAILED: BlastRadiusScheduling.Edge rule terms.treats a contract dependency as hard 49ms (48ms|0ms)
CI-FAILED: BlastRadiusScheduling.Edge rule terms.applies the integer inequality strictly at its boundary 47ms (46ms|0ms)
CI-FAILED: BlastRadiusScheduling.Edge rule terms.records the first canonical reason kind 53ms (52ms|1ms)
CI-FAILED: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-452-shared-surface-hard 49ms (49ms|0ms)
CI-FAILED: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-452-directory-prefix-weighted 54ms (53ms|1ms)
CI-FAILED: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-452-negative-controls 53ms (52ms|1ms)
CI-FAILED: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-soft-pair-tolerated 53ms (52ms|1ms)
CI-FAILED: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-absent-key-strict 54ms (54ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-contract 60ms (60ms|0ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-directory-vs-file 45ms (44ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-directory-vs-glob 45ms (44ms|0ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-empty-vs-empty 47ms (46ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-empty-vs-nonempty 60ms (59ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-glob-concrete 52ms (51ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-glob-undecidable 46ms (46ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-mergeable-csproj-no-edge 47ms (47ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-mergeable-glob-still-contends 51ms (50ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-module-overlap 57ms (57ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-multi-reason 55ms (54ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-none-disjoint 62ms (61ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-path-overlap 50ms (49ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-shared-surface 47ms (47ms|1ms)
CI-FAILED: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-sibling-prefix-disjoint 45ms (44ms|0ms)
CI-FAILED: BlastRadiusScheduling.Ordering and symmetry.sorts edges and tolerated overlaps by pair 47ms (47ms|0ms)
CI-FAILED: BlastRadiusScheduling.Ordering and symmetry.decides (b, a) the same as (a, b) 46ms (46ms|0ms)
```

Output Summary: PASS (expect-fail task, "no" branch). Exit 0; TotalCount=50, PassedCount=50, FailedCount=0; COVERAGE BlastRadiusScheduling.psm1 LinePercent=100, BlastRadius.psm1 LinePercent=39.25. R1 is not reproduced in isolation; the R1 fail-before evidence is the 26 scheduling CI-FAILED lines of P0-T10, quoted above.
