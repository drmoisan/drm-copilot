# Pass-After: CR-1 Keyed-Only Tie-Break (Claude, RW15)

Timestamp: 2026-10-08T20-29
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P1-T8.ps1 (same body as the fail-before run)
EXIT_CODE: 0
Output Summary: Passed=25 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0 (16 existing cases plus 9 CAT-R1 cases). Fail-before: regression-testing/fail-before-cr1-claude.2026-10-08T20-23.md (Passed=21, Failed=4).

```
Passed=25 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
