# P1-T9 CR-4 pass-after run (Record suite)

Timestamp: 2026-10-08T23-55
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=29
  PassedCount=29
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 29 tests in 169ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 280ms (259ms|21ms)
 16ms (14ms|2ms)
 18ms (18ms|1ms)
 28ms (28ms|1ms)
 12ms (12ms|1ms)
 13ms (13ms|0ms)
 20ms (19ms|0ms)
 72ms (72ms|0ms)
 10ms (9ms|0ms)
 12ms (11ms|0ms)
 13ms (12ms|1ms)
 13ms (12ms|1ms)
 13ms (13ms|1ms)
 10ms (9ms|0ms)

Describing Resolve-WorktreeOperandTarget
 20ms (18ms|1ms)
 9ms (9ms|0ms)
 19ms (19ms|1ms)
 7ms (6ms|0ms)
 30ms (29ms|0ms)

Describing Run resolver result contract
 44ms (43ms|1ms)
 21ms (21ms|1ms)
 19ms (18ms|1ms)
 14ms (13ms|1ms)
 44ms (43ms|0ms)

Describing Run resolver purity (parse-tree scan)
 32ms (31ms|1ms)
 32ms (32ms|1ms)
 34ms (33ms|1ms)

Describing Resolver module exports
 6ms (5ms|1ms)
 4ms (3ms|0ms)
Tests completed in 1.45s
Tests Passed: 29, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=29
PassedCount=29
FailedCount=0
```
