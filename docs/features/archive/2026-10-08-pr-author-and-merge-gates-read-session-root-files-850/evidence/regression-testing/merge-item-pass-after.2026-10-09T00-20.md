# P5-T12 T-MRG-IR pass-after run

Timestamp: 2026-10-09T00-20
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 2, 
  TotalCount=19
  PassedCount=17
  FailedCount=2
  FAILED: epic merge gate item-worktree resolution.denies an unresolvable item target with the no-target code
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.observes module-scoped WorktreeItemResolution mocks
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 19 tests in 112ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1'
Describing epic merge gate item-worktree resolution
 347ms (328ms|19ms)
 90ms (89ms|1ms)
  [-] denies an unresolvable item target with the no-target code
 40ms (39ms|1ms)
   at Test-WorktreeItemCheckpointRecordsPr, .claude\lib\worktree-resolution\WorktreeItemResolution.psm1:413
   at Resolve-WorktreeItemTargetByPrNumber, .claude\lib\worktree-resolution\WorktreeItemResolution.psm1:460
   at Resolve-EpicMergeGateItemTarget, .claude\hooks\enforce-epic-merge-gate-resolution.ps1:183
   at Invoke-EpicMergeGateDecision, .claude\hooks\enforce-epic-merge-gate.ps1:369
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:121
   RuntimeException: The property 'Name' cannot be found on this object. Verify that the property exists.
 28ms (27ms|0ms)
  [-] observes module-scoped WorktreeItemResolution mocks
 28ms (27ms|0ms)
   at Test-WorktreeItemCheckpointRecordsPr, .claude\lib\worktree-resolution\WorktreeItemResolution.psm1:413
   at Resolve-WorktreeItemTargetByPrNumber, .claude\lib\worktree-resolution\WorktreeItemResolution.psm1:460
   at Resolve-EpicMergeGateItemTarget, .claude\hooks\enforce-epic-merge-gate-resolution.ps1:183
   at Invoke-EpicMergeGateDecision, .claude\hooks\enforce-epic-merge-gate.ps1:369
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:150
   RuntimeException: The property 'Name' cannot be found on this object. Verify that the property exists.
 33ms (32ms|0ms)
 41ms (40ms|0ms)
 30ms (29ms|0ms)
 27ms (27ms|0ms)
 6ms (6ms|0ms)
 Context child checkpoint pull request binding
 5ms (2ms|3ms)
 3ms (3ms|0ms)
 7ms (5ms|2ms)
 9ms (9ms|1ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
Tests completed in 1.31s
Tests Passed: 17, 
Failed: 2, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=19
PassedCount=17
FailedCount=2
FAILED: epic merge gate item-worktree resolution.denies an unresolvable item target with the no-target code
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.observes module-scoped WorktreeItemResolution mocks
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
```
