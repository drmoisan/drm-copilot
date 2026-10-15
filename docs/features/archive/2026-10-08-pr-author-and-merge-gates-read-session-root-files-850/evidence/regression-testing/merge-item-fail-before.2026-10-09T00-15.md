# P5-T2 [expect-fail] T-MRG-IR fail-before run

Timestamp: 2026-10-09T00-15
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 14, 
  TotalCount=19
  PassedCount=5
  FailedCount=14
  FAILED: epic merge gate item-worktree resolution.authorizes a standalone merge from the item worktree checkpoint
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.does not authorize from a session-root copy of another worktree's checkpoint
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.denies an unresolvable item target with the no-target code
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.denies an ambiguous item target with the ambiguity code
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.observes module-scoped WorktreeItemResolution mocks
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.does not resolve an item target for a bare merge command
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.denies a merge when no checkpoint records the pull request number
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.denies a merge whose pull request number differs from pr_gate
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.re-checks the binding on the checkpoint the gate reads
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a null checkpoint
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a standalone pr_number that is string
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a standalone pr_number that is zero
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a standalone pr_number that is fractional
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
  FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false when neither field records the number
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1

Note: Expected outcome: FAILED lines include the ten rows P5-T2 names (MRG and MRGR do not yet resolve an item target or bind the number to a standalone record).

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 19 tests in 181ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1'
Describing epic merge gate item-worktree resolution
  [-] authorizes a standalone merge from the item worktree checkpoint
 373ms (348ms|25ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:90
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:90
   Expected strings to be the same, but they were different.
   Expected length: 5
   Actual length:   4
   Strings differ at index 0.
   Expected: 'allow'
   But was:  'deny'
              ^
  [-] does not authorize from a session-root copy of another worktree's checkpoint
 91ms (90ms|1ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny', tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:111
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:111
   Expected strings to be the same, but they were different.
   Expected length: 4
   Actual length:   5
   Strings differ at index 0.
   Expected: 'deny'
   But was:  'allow'
              ^
  [-] denies an unresolvable item target with the no-target code
 41ms (41ms|0ms)
   at $reason.Contains('pull request 812 is recorded in pr_gate.pr_number') | Should -BeTrue -Because 'the item detail names the number', tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:128
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:128
   Expected $true, because the item detail names the number, but got $false.
  [-] denies an ambiguous item target with the ambiguity code
 20ms (19ms|0ms)
   
   CommandNotFoundException: Could not find Command Resolve-EpicMergeGateItemTarget
  [-] observes module-scoped WorktreeItemResolution mocks
 48ms (47ms|0ms)
   at Should -Invoke Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 1 -Exactly, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:153
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:153
   Expected Get-WorktreeItemCheckpointText in module WorktreeItemResolution to be called 1 times exactly, but was called 0 times
  [-] does not resolve an item target for a bare merge command
 18ms (17ms|1ms)
   
   CommandNotFoundException: Could not find Command Resolve-EpicMergeGateItemTarget
  [-] denies a merge when no checkpoint records the pull request number
 32ms (32ms|1ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny', tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:179
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:179
   Expected strings to be the same, but they were different.
   Expected length: 4
   Actual length:   5
   Strings differ at index 0.
   Expected: 'deny'
   But was:  'allow'
              ^
  [-] denies a merge whose pull request number differs from pr_gate
 21ms (20ms|1ms)
   
   CommandNotFoundException: Could not find Command Resolve-EpicMergeGateItemTarget
  [-] re-checks the binding on the checkpoint the gate reads
 19ms (19ms|1ms)
   
   CommandNotFoundException: Could not find Command Resolve-EpicMergeGateItemTarget
 6ms (5ms|1ms)
 Context child checkpoint pull request binding
 5ms (2ms|2ms)
   [-] returns false for a null checkpoint
 4ms (4ms|0ms)
    at $result | Should -BeFalse, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:243
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:243
    Expected $false, but got $true.
 11ms (8ms|2ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
   [-] returns false for a standalone pr_number that is string
 4ms (4ms|1ms)
    at $result | Should -BeFalse -Because "a standalone pr_number that is $Name is not a positive JSON integer", tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:283
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:283
    Expected $false, because a standalone pr_number that is string is not a positive JSON integer, but got $true.
   [-] returns false for a standalone pr_number that is zero
 2ms (1ms|0ms)
    at $result | Should -BeFalse -Because "a standalone pr_number that is $Name is not a positive JSON integer", tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:283
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:283
    Expected $false, because a standalone pr_number that is zero is not a positive JSON integer, but got $true.
   [-] returns false for a standalone pr_number that is fractional
 3ms (2ms|1ms)
    at $result | Should -BeFalse -Because "a standalone pr_number that is $Name is not a positive JSON integer", tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:283
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:283
    Expected $false, because a standalone pr_number that is fractional is not a positive JSON integer, but got $true.
   [-] returns false when neither field records the number
 3ms (3ms|0ms)
    at $result | Should -BeFalse, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:294
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1:294
    Expected $false, but got $true.
Tests completed in 1.57s
Tests Passed: 5, 
Failed: 14, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=19
PassedCount=5
FailedCount=14
FAILED: epic merge gate item-worktree resolution.authorizes a standalone merge from the item worktree checkpoint
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.does not authorize from a session-root copy of another worktree's checkpoint
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.denies an unresolvable item target with the no-target code
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.denies an ambiguous item target with the ambiguity code
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.observes module-scoped WorktreeItemResolution mocks
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.does not resolve an item target for a bare merge command
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.denies a merge when no checkpoint records the pull request number
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.denies a merge whose pull request number differs from pr_gate
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.re-checks the binding on the checkpoint the gate reads
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a null checkpoint
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a standalone pr_number that is string
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a standalone pr_number that is zero
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false for a standalone pr_number that is fractional
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FAILED: epic merge gate item-worktree resolution.child checkpoint pull request binding.returns false when neither field records the number
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
```
