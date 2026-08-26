# Batch A — Test Stage Over the New Mode-Resolution Suite (issue #554)

Timestamp: 2026-08-26T10-48

Command:

```powershell
$r = Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 -PassThru
exit $r.FailedCount
```

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:

| Metric | Value |
| --- | --- |
| Passed | **64** |
| **Failed** | **1** |
| Skipped | **0** |
| Inconclusive | 0 |
| NotRun | 0 |
| Total discovered | 65 |
| Wall time | 876 ms |

Failing case, in full:

```text
enforce-orchestration-preimplementation-gate.ps1 mode resolution
  > Fault-1 wording independence, direction (b): the new allow-to-deny change
    > denies an orchestrator delegation phrased with "atomic execution" and no mode
      markers against an unready single-feature checkpoint
```

That is the `[expect-fail]` matrix case 6b added at P1-T2, and it is the **only** failing case in the
run. Its assertion failure is unchanged from the P1-T3 fail-before artifact: the pre-fix classifier
returns `allow` where the case asserts `deny`. The structural classifier that changes its outcome is
not applied until P3-T2, so its failure here is the expected outcome for this task and does not
restart the Batch A toolchain.

All 64 other cases passed. They comprise the predicate-level cases added at P2-T12, P2-T13, and
P2-T14: mode resolution for all four mode names, preparation-first precedence, the both-markers
requirement, the empty and null prompt defaults, the canonical checkpoint-path map for all four modes
and for an out-of-table name, the declared-path cross-check in its absent, matching, and mismatching
forms on both the epic and the parallel side, target-folder and issue-number resolution, all seven
epic conjuncts failing individually plus the null checkpoint, the fully ready epic case, the absent
`merge_status` case, both terminal-merged deny members, both epic failure-status allow members, the
issue-number fallback resolution, all six parallel conjuncts failing individually plus the null
checkpoint, the fully ready parallel case, both parallel terminal-merged deny members, both parallel
blocked-status allow members, and the five-member implementation-agent allow-list.

## Note on the Exit Code

`Invoke-Pester` defaults `Run.Exit` to `$false`, so a bare invocation of the command exactly as the
plan states it exits **0** even with a failing case. Measured directly:

```text
WRAPPER_EXIT_CODE=1            # $r = Invoke-Pester ... -PassThru ; exit $r.FailedCount
BARE_INVOKE_PESTER_EXIT_CODE=0 # Invoke-Pester ... with no exit propagation
```

The exit code recorded above is therefore taken from the wrapper that propagates the run's own
`FailedCount`, not from the bare invocation. Reading pass/fail from the bare process exit code would
have reported this run as clean while a case was failing.

## Toolchain State

The test stage changed no file: the suite's SHA-256 was identical before and after the run
(`SUITE_UNCHANGED_BY_RUN=True`). No other case failed, so the Batch A toolchain is not restarted at
P2-T16.
