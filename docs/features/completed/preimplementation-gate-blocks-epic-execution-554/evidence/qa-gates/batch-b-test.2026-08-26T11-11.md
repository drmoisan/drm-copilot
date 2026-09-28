# Batch B — Test Stage Over Both New Mode-Resolution Suites (issue #554)

Timestamp: 2026-08-26T11-11

Command:

```powershell
$paths = @(
    'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1'
)
$c = New-PesterConfiguration
$c.Run.Path = $paths
$c.Run.PassThru = $true
$c.Output.Verbosity = 'None'
$r = Invoke-Pester -Configuration $c
exit $r.FailedCount
```

EXIT_CODE: 0

Output Summary:

| Suite | Passed | Failed | Skipped |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **83** | **0** | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | **43** | **0** | 0 |
| **Combined** | **126** | **0** | **0** |

Each suite records a failed count of the integer 0 and a passed count greater than 0. The counts are
read from the Pester result object, not from a bare `Invoke-Pester` exit code, because `Run.Exit`
defaults to `$false` and a bare invocation exits 0 even with a failing case. The exit code above is
propagated from `$r.FailedCount`.

## The `[expect-fail]` Case Now Passes

The Claude suite's count rose from 64 passed and 1 failed at P2-T17 to 83 passed and 0 failed here.
Two things changed it:

1. **Matrix case 6b flipped from failing to passing.** It was the `[expect-fail]` case at P1-T2, and
   the structural classifier applied at P3-T2 is what changes its outcome from allow to deny. That
   is the one allow-to-deny behaviour change this fix introduces, and it is now asserted green.
2. **Eighteen decision-level cases were added** at P3-T12 through P3-T17: matrix cases 1 through 4
   and 5, the epic target-unresolvable case, the two decision-D8 merge-status cases, matrix cases 6a
   and 7, matrix case 8 as two separate `It` blocks, three parallel decision-level cases, and three
   deny-by-default cases.

64 + 1 + 18 = 83.

## Toolchain State

Neither suite file changed during the run: the SHA-256 of each was identical before and after
(`UNCHANGED_BY_RUN=True` for both). No stage failed and no stage changed a file, so the Batch B
toolchain is not restarted at P3-T21.
