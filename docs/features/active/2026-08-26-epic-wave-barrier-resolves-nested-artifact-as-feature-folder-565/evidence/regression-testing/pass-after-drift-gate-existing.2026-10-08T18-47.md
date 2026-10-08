# Pass-After: Existing Parallel Drift Gate Suites

Timestamp: 2026-10-08T18-47
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P4-T9.ps1
EXIT_CODE: 0
Output Summary: Passed=80 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The rewritten P1-T4 case ("reports two distinct folders as Ambiguous") now passes; it failed in regression-testing/fail-before-drift-gate-existing.2026-10-08T18-12.md.

```
Passed=80 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
