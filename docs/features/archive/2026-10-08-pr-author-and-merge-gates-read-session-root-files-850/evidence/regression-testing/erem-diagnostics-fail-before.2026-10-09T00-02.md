# P3-T2 [expect-fail] T-EREM-DX fail-before run

Timestamp: 2026-10-09T00-02
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 8, 
  TotalCount=8
  PassedCount=0
  FailedCount=8
  FAILED: epic worktree-removal gate deny diagnostics.emits a single leading token when both run kinds are unresolved
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.names each run kind's status and checkpoint path
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.names the matched record merge_status
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.states that no record matched
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.states that the checkpoint was absent or unparseable
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.diagnostics builder and read result.returns the checkpoint path it read on the read result
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.diagnostics builder and read result.returns a null path when the target is unresolved
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
  FAILED: epic worktree-removal gate deny diagnostics.diagnostics builder and read result.builds the clause without reading any file
  FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1

Note: Expected outcome: TotalCount=8 and FailedCount=8 (EREM and EREMR do not yet emit a single token, a diagnostics clause, or a Path property).

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 8 tests in 181ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1'
Describing epic worktree-removal gate deny diagnostics
  [-] emits a single leading token when both run kinds are unresolved
 539ms (506ms|33ms)
   at ([regex]::Matches($reason, 'EPIC_WORKTREE_REMOVAL_BLOCKED:')).Count | Should -Be 1 -Because 'the gate token appears exactly once', tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:78
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:78
   Expected 1, because the gate token appears exactly once, but got 2.
  [-] names each run kind's status and checkpoint path
 50ms (48ms|2ms)
   at $reason.Contains("epic run OtherWorktree (checkpoint '$($script:EpicPath)')") | Should -BeTrue -Because 'the clause names the epic status and checkpoint path', tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:93
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:93
   Expected $true, because the clause names the epic status and checkpoint path, but got $false.
  [-] names the matched record merge_status
 79ms (78ms|1ms)
   at $decision.hookSpecificOutput.permissionDecisionReason.Contains("merge_status 'pr_open'") | Should -BeTrue -Because 'the clause names the matched features[] record merge_status', tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:107
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:107
   Expected $true, because the clause names the matched features[] record merge_status, but got $false.
  [-] states that no record matched
 28ms (28ms|1ms)
   at $decision.hookSpecificOutput.permissionDecisionReason.Contains('no matching items[] record') | Should -BeTrue -Because 'the parallel checkpoint records no items[] entry for the target', tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:120
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:120
   Expected $true, because the parallel checkpoint records no items[] entry for the target, but got $false.
  [-] states that the checkpoint was absent or unparseable
 34ms (33ms|1ms)
   at $reason.Contains('checkpoint absent or unparseable') | Should -BeTrue -Because 'the epic checkpoint text does not parse', tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:135
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:135
   Expected $true, because the epic checkpoint text does not parse, but got $false.
 Context diagnostics builder and read result
   [-] returns the checkpoint path it read on the read result
 30ms (27ms|3ms)
    at $read.Path | Should -Be $script:EpicPath, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:150
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:150
    Expected '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json', but got $null.
   [-] returns a null path when the target is unresolved
 28ms (28ms|1ms)
    at @($read.PSObject.Properties.Name) | Should -Contain 'Path', tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:163
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:163
    Expected 'Path' to be found in collection @('Target', 'Checkpoint'), but it was not found.
   [-] builds the clause without reading any file
 29ms (28ms|1ms)
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:185
    CommandNotFoundException: The term 'Get-EpicWorktreeGateDenyDiagnostics' is not recognized as a name of a cmdlet, function, script file, or executable program.
    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
Tests completed in 1.6s
Tests Passed: 0, 
Failed: 8, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=8
PassedCount=0
FailedCount=8
FAILED: epic worktree-removal gate deny diagnostics.emits a single leading token when both run kinds are unresolved
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.names each run kind's status and checkpoint path
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.names the matched record merge_status
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.states that no record matched
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.states that the checkpoint was absent or unparseable
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.diagnostics builder and read result.returns the checkpoint path it read on the read result
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.diagnostics builder and read result.returns a null path when the target is unresolved
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
FAILED: epic worktree-removal gate deny diagnostics.diagnostics builder and read result.builds the clause without reading any file
FAILED-FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
```
