# Final full Pester suite with coverage — issue #598

Timestamp: 2026-08-30T02-22
Task: [P10-T3]

Command:
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

The run is unscoped: no `-ScanFolders` argument was supplied, so it covers the full
`Run.Path` of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. This matches the form
`[P0-T16]` used to produce the comparands, and it is the run whose
`artifacts/pester/powershell-coverage.xml` `[P10-T4]` and `[P10-T5]` read.

The self-hosted PoshQC module is used rather than `mcp__drm-copilot__run_poshqc_test` for the reason
recorded in `[P0-T7]`: the MCP runner resolves its runsettings from the installed VS Code extension
rather than from the repository settings file.

EXIT_CODE: 0

The exit code was taken from the child `pwsh` process. `$LASTEXITCODE` is not a usable source here,
because `Invoke-PoshQCTest` is an in-process cmdlet and leaves that variable unset.

Output Summary:

Discovery found 3890 tests in 161 files. Tests completed in 124.53s. The replayed summary line,
verbatim:

```
Tests Passed: 3881, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

`Invoke-PoshQCTest` splits that summary across several `Write-Information` records
(`scripts/powershell/PoshQC/PoshQC.Testing.psm1:423` builds it from the format string
`Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}`). The line above is
the concatenation of those records, in order.

FinalPassed: 3881
FinalFailed: 0
FinalSkipped: 9
FinalInconclusive: 0
FinalNotRun: 0

The Pester console coverage headline for this run was
`Covered 94.25% / 0%. 10,742 analyzed Commands in 88 Files.` That figure is Pester's
**command**-coverage percentage, not the line-coverage percentage this plan gates on. The
line-coverage figure is derived by `[P10-T4]` from the report-level `counter type="LINE"` element of
`artifacts/pester/powershell-coverage.xml`. The two are different metrics over different
denominators and must not be compared with each other. The `[P0-T16]` baseline run printed the
corresponding command-coverage headline `Covered 94.24% / 0%. 10,722 analyzed Commands in 88 Files.`

## Comparands used

Both comparands are read from `evidence/baseline/pester-suite-postmerge.2026-08-29T23-10.md`,
written by `[P0-T16]`:

- `PostMergeBaselinePassed: 3873` (line 30 of that artifact)
- `PostMergeBaselineSkipped: 9` (line 32 of that artifact)

The pre-merge figures recorded by `[P0-T7]` (`Tests Passed: 3842, Failed: 0, Skipped: 9`) are
superseded and are not the comparands. The merge added Pester suites inside the runsettings
`Run.Path`, so a ceiling taken from the pre-merge tree would not describe the tree this run was made
against.

The final passed count of 3881 exceeds the post-merge baseline of 3873 by exactly 8, which is the
6 `It` blocks of `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` from `[P8-T1]` plus
the 2 `It` blocks added to
`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` by `[P8-T2]`.

## Acceptance evaluation

- `EXIT_CODE:` is `0`.
- The summary line shows `Failed: 0`.
- The skipped count is `9`, which is not greater than `PostMergeBaselineSkipped: 9`. No test was
  newly skipped by this change.

All three acceptance conditions hold. No Pester failure reached this task, so the
sequencing-constraint-7 repair branch does not fire, no repair artifact is required, and no batch
identifier needs to be recorded as having missed a failure.
