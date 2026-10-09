# P1-T2 [expect-fail] CR-4 fail-before run (Record suite)

Timestamp: 2026-10-08T23-52
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 1, 
  TotalCount=29
  PassedCount=28
  FailedCount=1
  FAILED: Resolve-WorktreeRunTargetByRecord.B14 compares UNC paths case-insensitively
  FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1

Note: Expected outcome: FailedCount=1 with the single FAILED line ending in 'B14 compares UNC paths case-insensitively' (WRR still compares UNC paths case-sensitively before B1).

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 29 tests in 135ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 226ms (208ms|18ms)
 13ms (11ms|1ms)
 14ms (13ms|0ms)
 22ms (22ms|0ms)
 10ms (10ms|0ms)
 11ms (11ms|0ms)
 17ms (16ms|0ms)
 63ms (63ms|0ms)
 9ms (8ms|0ms)
 9ms (9ms|0ms)
 11ms (11ms|0ms)
 11ms (11ms|0ms)
 13ms (13ms|0ms)
  [-] B14 compares UNC paths case-insensitively
 32ms (31ms|1ms)
   at $target.Status | Should -Be 'OtherWorktree', tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1:260
   at <ScriptBlock>, tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1:260
   Expected strings to be the same, but they were different.
   Expected length: 13
   Actual length:   8
   Strings differ at index 0.
   Expected: 'OtherWorktree'
   But was:  'NoTarget'
              ^

Describing Resolve-WorktreeOperandTarget
 18ms (16ms|1ms)
 17ms (16ms|0ms)
 9ms (8ms|0ms)
 6ms (5ms|1ms)
 28ms (28ms|1ms)

Describing Run resolver result contract
 34ms (32ms|2ms)
 18ms (18ms|1ms)
 14ms (14ms|0ms)
 25ms (24ms|0ms)
 25ms (24ms|0ms)

Describing Run resolver purity (parse-tree scan)
 25ms (24ms|1ms)
 24ms (23ms|0ms)
 29ms (28ms|0ms)

Describing Resolver module exports
 5ms (4ms|1ms)
 2ms (2ms|0ms)
Tests completed in 1.23s
Tests Passed: 28, 
Failed: 1, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=29
PassedCount=28
FailedCount=1
FAILED: Resolve-WorktreeRunTargetByRecord.B14 compares UNC paths case-insensitively
FAILED-FILE: tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
```
