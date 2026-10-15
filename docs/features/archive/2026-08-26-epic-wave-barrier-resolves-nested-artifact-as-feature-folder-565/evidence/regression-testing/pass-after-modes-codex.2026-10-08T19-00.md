# Pass-After: Codex Preimplementation Gate Suites (W06 change, W27 cases)

Timestamp: 2026-10-08T19-00
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate*.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P5-T6.ps1
EXIT_CODE: 0
Output Summary: Passed=325 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Seven suites ran: the six existing Codex gate suites plus W27. No FAILED lines. Fail-before reference: regression-testing/fail-before-modes-codex.2026-10-08T18-14.md (11 failed).

```
Passed=325 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```

Suites executed (from the console output):

```
enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
```
