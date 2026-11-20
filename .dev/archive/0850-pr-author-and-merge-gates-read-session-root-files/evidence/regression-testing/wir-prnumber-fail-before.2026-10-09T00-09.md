# P4-T2 [expect-fail] T-WIR-PR fail-before run

Timestamp: 2026-10-09T00-09
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 11, 
  TotalCount=11
  PassedCount=0
  FailedCount=11
  FAILED: Resolve-WorktreeItemTargetByPrNumber.resolves the worktree whose pr_gate records the pull request number
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.resolves the worktree whose standalone authorization records the pull request number
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.returns NoTarget when no checkpoint records the number
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.returns Ambiguous when several checkpoints record the number
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.reads only through the checkpoint-text seam
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.exports the item-by-PR resolver
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is string
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is zero
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is negative
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is fractional
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
  FAILED: Resolve-WorktreeItemTargetByPrNumber.skips an absent, empty, or unparseable checkpoint
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1

Note: Expected outcome: TotalCount=11 and FailedCount=11 (Resolve-WorktreeItemTargetByPrNumber does not exist before B5).

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 11 tests in 124ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1'
Describing Resolve-WorktreeItemTargetByPrNumber
  [-] resolves the worktree whose pr_gate records the pull request number
 151ms (129ms|22ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:55
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] resolves the worktree whose standalone authorization records the pull request number
 24ms (23ms|2ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:67
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] returns NoTarget when no checkpoint records the number
 22ms (22ms|0ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:79
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] returns Ambiguous when several checkpoints record the number
 21ms (20ms|0ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:94
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] reads only through the checkpoint-text seam
 53ms (53ms|1ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:112
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] exports the item-by-PR resolver
 51ms (51ms|0ms)
   at ($actual -join ',') | Should -BeExactly ($expected -join ','), tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:134
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:134
   Expected strings to be the same, but they were different.
   Expected length: 321
   Actual length:   284
   Strings differ at index 284.
   Expected: '...-WorktreeItemCheckpointText,Get-WorktreeItemLiveRoot,Resolve-WorktreeItemTarget,Resolve-WorktreeI...'
   But was:  '...-WorktreeItemCheckpointText,Get-WorktreeItemLiveRoot,Resolve-WorktreeItemTarget'
              ----------------------------------------------------------------------------------^
  [-] ignores a standalone pr_number that is string
 23ms (22ms|1ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:147
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] ignores a standalone pr_number that is zero
 22ms (22ms|1ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:147
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] ignores a standalone pr_number that is negative
 27ms (26ms|1ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:147
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] ignores a standalone pr_number that is fractional
 21ms (20ms|1ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:147
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
  [-] skips an absent, empty, or unparseable checkpoint
 25ms (24ms|1ms)
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1:161
   CommandNotFoundException: The term 'Resolve-WorktreeItemTargetByPrNumber' is not recognized as a name of a cmdlet, function, script file, or executable program.
   Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
Tests completed in 931ms
Tests Passed: 0, 
Failed: 11, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=11
PassedCount=0
FailedCount=11
FAILED: Resolve-WorktreeItemTargetByPrNumber.resolves the worktree whose pr_gate records the pull request number
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.resolves the worktree whose standalone authorization records the pull request number
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.returns NoTarget when no checkpoint records the number
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.returns Ambiguous when several checkpoints record the number
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.reads only through the checkpoint-text seam
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.exports the item-by-PR resolver
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is string
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is zero
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is negative
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.ignores a standalone pr_number that is fractional
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
FAILED: Resolve-WorktreeItemTargetByPrNumber.skips an absent, empty, or unparseable checkpoint
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1
```
