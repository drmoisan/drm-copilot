# P5-T12 T-MRG-IR pass-after run (after the WIR corrective re-Write)

Timestamp: 2026-10-09T00-22
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=19
  PassedCount=19
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 19 tests in 170ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1'
Describing epic merge gate item-worktree resolution
 401ms (381ms|21ms)
 96ms (95ms|1ms)
 46ms (45ms|1ms)
 36ms (36ms|1ms)
 41ms (40ms|1ms)
 42ms (42ms|1ms)
 55ms (55ms|1ms)
 40ms (40ms|1ms)
 38ms (37ms|1ms)
 6ms (6ms|1ms)
 Context child checkpoint pull request binding
 6ms (3ms|3ms)
 5ms (4ms|1ms)
 10ms (7ms|2ms)
 11ms (10ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|1ms)
 3ms (3ms|1ms)
Tests completed in 1.64s
Tests Passed: 19, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=19
PassedCount=19
FailedCount=0
```
