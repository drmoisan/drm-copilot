# P4-T2 and P4-T3 task note

Timestamp: 2026-11-09T16-27
Command: focused debug run of tests/scripts/claude-skills/epic-progress-report and tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 (Invoke-Pester from a SCRATCH sh launcher; debugging only, not a gate)
EXIT_CODE: 1
Output Summary: 417 passed, 1 failed before the entry-script bundle copy was refreshed (`mirrors every skill-folder file byte-identically in the bundle`, the entry script hash); the copy was then refreshed in the same P4-T3 commit. The P6-T2 parallel gate is the evidence for both tasks.

## Rendering choices fixed in P4-T2 (within E1, no design change)

- Sequential rate on the `**Velocity:**` line: a one-feature report prints that feature's own rate and source; otherwise the pooled median with source `pooled` when a feature qualifies, else the default rate with source `default`.
- A range with no SD source prints `range n/a (<reason>)`, using the reason from `Get-EpicProgressScheduleRange`.
- Item mode prints the chain alone in the `**Elapsed:**` parentheses (`(#<n>)`), with no cap text; the Full critical-path section states that the item has no dependency, cap, or tail.

## Cases added under CD-1 (no design, file-set, or task-list change)

- `Get-EpicProgressReport.Render.CriticalPath.Tests.ps1`: `prints a single feature with its own rate and source (AC-04)`, `prints no upper bound for the slow end and n/a with the reason when no SD exists (AC-05)`, `prints no graph message line for a valid graph (AC-07)`.
- `Get-EpicProgressReport.CriticalPath.Tests.ps1`: the AC-31 case also asserts that epic mode probes the routing-config path, as the positive control for `reads no routing config in item mode (E5)`.

## Handoff expectation closed

- The three cases the Phases 0-3 executor listed as failing until P4-T3 (`writes only the state file at -StatePath`, `prints the Full golden for a legacy four-sample state`, `uses the item state path by default`) were updated to version 3 in P4-T3 and pass in the focused run.
- `scripts/dev-tools/Get-EpicProgressReport.ps1` and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` have no diff against the merge base of `origin/main` and `HEAD`.
