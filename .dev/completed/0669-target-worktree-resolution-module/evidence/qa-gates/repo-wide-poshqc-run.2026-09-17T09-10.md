# Repo-Wide Self-Hosted PoshQC Test Run (R1, cycle 1)

- Timestamp: 2026-09-17T13:59:41Z
- Command: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path`
- EXIT_CODE: 2

## Output Summary

`EXIT_CODE:` records the numeric value observed from the child `pwsh` process: `2`. The child process
did not print the replayed summary block (`PoshQC.Testing.psm1:454-456`), consistent with the observed
gap recorded in agent memory (`Invoke-PoshQCTest` does not print that block when `-not
$config.Run.PassThru` never fires on a `PesterConfiguration` object). Pester's own summary line did
print before the process exited, verbatim:

```
Tests Passed: 4642, Failed: 2, Skipped: 9, Inconclusive: 0, NotRun: 0
```

Immediately preceding that line:

```
Covered 94.81% / 0%. 13,266 analyzed Commands in 103 Files.
```

A `WARNING` was printed at the start of the run: `Scan configuration 'config/poshqc-scan.json' folder
'tests/powershell' does not exist under root <worktree root>; skipping.` This reflects the scan-config
resolution described in `[P1-T1]`'s task text (`Get-PoshQCScanConfigFolder` / `Resolve-PoshQCScanFolder`),
which resolved the three-entry `scanFolders` set (`scripts`, `tests/powershell`, `tests/scripts`) and
found only two of the three folders present on disk (`tests/powershell` does not exist in this
worktree); this narrowing was performed by `Invoke-PoshQCTest` itself, not by any `-ScanFolders` argument
supplied by this task, and none was supplied.

Post-run `LastWriteTime` values, checked in a fresh `pwsh` invocation after the run's child process
exited:

- `artifacts/pester/powershell-coverage.xml`: `2026-09-17T09:58:21.8238684-04:00`
- `artifacts/pester/pester-junit.xml`: `2026-09-17T09:59:11.7666053-04:00`

Both values are later than the corresponding `[P0-T3]` baseline values
(`2026-09-17T08:42:00.4537585-04:00` and `2026-09-17T08:42:16.2944756-04:00` respectively), confirming
both canonical run-output files were freshly written by this repo-wide run. The nonzero `EXIT_CODE: 2`
is not itself a failure of this task per the Run-Exit Termination Handling section of the plan; the
`LastWriteTime` comparison above is the acceptance-relevant observation and it holds.
