# Fail-Before Run (unfixed hook) - issue 1114

Timestamp: 2026-11-07T19-37
Command: sh SCRATCH/issue-1114-pester.sh failbefore (PowerShell 7 in the item worktree: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <item worktree>; exit $r.ExitCode), run after [P2-T1] and before [P3-T1]; per-row results read from the per-shard JUnit files under artifacts/pester/parallel/ by SCRATCH/issue-1114-rows.ps1 and SCRATCH/issue-1114-figures.ps1 (shards mode)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Returned ExitCode: 1 (8 workers; shard 7 exit 4, all other shards exit 0). The run is not green, so counts come from the 8 per-shard JUnit files.
- Counts: 15942 tests; 15928 passed; 4 failed; 0 errors; 10 skipped.
- `1114: judges the audit named by the reviewer when another item's audit is newer`: FAILED on the stdout outcome assertion (`Expected $null or empty, because the named audit A carries a PASS coverage verdict for Python, but got '{"decision":"block",...}'`); the unfixed hook judged the newer audit of the other item (`2026-11-07-item-b-1115/policy-audit.2026-11-07T22-00.md`).
- `1114: blocks a report older than the newest item commit for the language in an item worktree`: FAILED on the stdout outcome assertion (`Expected a value, because a stale Python report in the item worktree must block, but got $null or empty.`); the unfixed hook accepted the stale report.
- `1114: blocks an absent coverage report for a changed language in an item worktree`: FAILED on the stdout outcome assertion (`Expected a value, because an absent Python report in the item worktree must block, but got $null or empty.`).
- `1114: with two active items and a stale report the review of the named item is blocked on freshness`: FAILED on the stdout outcome assertion (`Expected a value, because the named item has a stale Python report, but got $null or empty.`).
- No failure is a missing-command failure: the wrapper functions resolve because the suite dot-sources the [P1-T1] and [P1-T2] files.
- Every other failing test name in the [P0-T4] artifact: none to compare, because the [P0-T4] run had 0 failures and this run has no failure besides the four new rows.
- The [P1-T1] and [P1-T2] suites pass in this run: `validate-feature-review-coverage-freshness.Tests.ps1` 21 of 21, `feature-review-coverage-target.Tests.ps1` 34 of 34.
