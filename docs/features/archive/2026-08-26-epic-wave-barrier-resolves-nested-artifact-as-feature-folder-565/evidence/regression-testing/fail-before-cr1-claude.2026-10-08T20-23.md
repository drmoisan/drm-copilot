# Fail-Before: CR-1 Keyed-Only Tie-Break (Claude, RW15)

Timestamp: 2026-10-08T20-23
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P1-T8.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: [expect-fail] Passed=21 Failed=4 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. Exactly four FAILED: lines, for M10p, M10e, M12a, M12b. M10p/M10e fail because the gate allows (the bare #302 selects the non-terminal sibling); M12a/M12b fail with ParameterBindingException because -KeyedOnly does not exist yet. M11p, M11e, M12c, M8h, M8m pass before the fix, as the plan expects.

```
Passed=21 Failed=4 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
FAILED: enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: only the keyed issue number breaks a tie.M10p: denies a parallel delegation as target-ambiguous when only a bare #302 sibling reference is cited
FAILED: enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: only the keyed issue number breaks a tie.M10e: denies an epic delegation as target-ambiguous when only a bare #302 sibling reference is cited
FAILED: enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M12a: returns no keyed issue number when only a bare hash form is present
FAILED: enforce-orchestration-preimplementation-gate-modes.ps1 target folder (Claude, issue #565).issue #565 CR-1: keyed-only issue source and the D3 hash fallback.M12b: returns the keyed issue number and ignores a bare hash form
```
