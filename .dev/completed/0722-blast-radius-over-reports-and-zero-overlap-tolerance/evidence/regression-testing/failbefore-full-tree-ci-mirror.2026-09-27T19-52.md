# Full-Tree Fail-Before, As CI Runs It (Remediation Cycle 1, P0-T14) [expect-fail]

Timestamp: 2026-09-27T19-52
Command: sh SCRATCH/run-ps.sh SCRATCH/poshqc-ci-mirror.ps1 -Root "."   (Bash tool, run_in_background; output redirected to SCRATCH/rem-p0-ci-mirror.txt)
EXIT_CODE: 1
ExpectedExitCode: 1

## Summary lines (verbatim; ANSI colour codes removed from the "Tests Passed:" line)

```text
PESTER-VERSION 5.6.1
PESTER-FAILED-TOTAL=35
Tests Passed: 5514, Failed: 35, Skipped: 9, Inconclusive: 0, NotRun: 0
JUNIT-SUMMARY CaseCount=5558 FailedCount=35
```

## JUNIT-FAILED lines (verbatim, 35)

```text
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 :: Blast-radius historical runs.matches detection at tolerance 0 for epic-655-followups
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 :: Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for epic-655-followups
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 :: Blast-radius historical runs.matches detection at tolerance 0 for backlog-2026-09-26
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 :: Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for backlog-2026-09-26
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 :: Blast-radius historical runs.matches detection at tolerance 0 for followups-2026-09-27
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 :: Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for followups-2026-09-27
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Edge rule terms.keeps a shared-surface overlap hard at every tolerance
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Edge rule terms.treats a contract dependency as hard
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Edge rule terms.applies the integer inequality strictly at its boundary
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Edge rule terms.records the first canonical reason kind
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-452-shared-surface-hard
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-452-directory-prefix-weighted
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-452-negative-controls
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-soft-pair-tolerated
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Scheduling fixtures.reproduces the expected decisions for scheduling-absent-key-strict
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-contract
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-directory-vs-file
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-directory-vs-glob
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-empty-vs-empty
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-empty-vs-nonempty
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-glob-concrete
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-glob-undecidable
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-mergeable-csproj-no-edge
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-mergeable-glob-still-contends
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-module-overlap
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-multi-reason
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-none-disjoint
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-path-overlap
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-shared-surface
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Strict identity.matches detection at tolerance 0 for conflict-sibling-prefix-disjoint
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Ordering and symmetry.sorts edges and tolerated overlaps by pair
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 :: BlastRadiusScheduling.Ordering and symmetry.decides (b, a) the same as (a, b)
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 :: BlastRadiusWriteIntent.Flag behavior and selector.does not make a shared-surface read citation hard
JUNIT-FAILED: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 :: BlastRadiusWriteIntent.Committed fixtures and readers.reproduces the expected radius for write-intent-shared-surface-read-citation
JUNIT-FAILED: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 :: enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree
```

## Derived values

- JUNIT-FAILED lines whose text contains "BlastRadiusScheduling" or "HistoricalRuns" or "historical runs": 32 (26 scheduling, 6 historical-runs).
- The literal "is not available; import the facade module" occurs 34 times in the run output, once per R1 failure.
- PRE_CASES = 5558.
- PRE_EXTRA = PESTER-FAILED-TOTAL (35) minus JUNIT-SUMMARY FailedCount (35) = 0.
- The pre-fix failure set that P2-T5 consults is the 35 JUNIT-FAILED lines above. It has the same 35 test names as the CI_FAILED set of P0-T10, so the local one-process run reproduces the CI failure in full (R1 and R2).

## Checks

- Exit 1: yes.
- PESTER-VERSION reads 5.6.1: yes.
- JUNIT-SUMMARY CaseCount at least 5000 (5558) and FailedCount at least 1 (35): yes.
- One JUNIT-FAILED line contains "reports no Python invocation beyond the allowlist across the guarded tree": yes.

Output Summary: PASS (expect-fail task). Exit 1; PESTER-VERSION 5.6.1; PESTER-FAILED-TOTAL=35; "Tests Passed: 5514, Failed: 35"; JUNIT-SUMMARY CaseCount=5558 FailedCount=35; 32 scheduling/historical-runs lines, 2 write-intent lines, and the guard line. PRE_CASES=5558, PRE_EXTRA=0.
