# P6-T20 Isolation guard run (AC-47)

Timestamp: 2026-10-09T00-38
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=34
  PassedCount=34
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 34 tests in 132ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1'
Describing gate suites isolate the epic checkpoint read (structural guard)
 127ms (108ms|20ms)
 13ms (13ms|1ms)
 30ms (11ms|20ms)
 14ms (14ms|1ms)
 8ms (8ms|1ms)
 30ms (29ms|1ms)
 7ms (7ms|0ms)
 9ms (9ms|0ms)
 17ms (16ms|0ms)
 Context guard predicate discrimination
 10ms (8ms|2ms)
 5ms (4ms|0ms)
 9ms (8ms|0ms)
 4ms (4ms|0ms)
 7ms (7ms|1ms)
 5ms (5ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)

Describing the run-checkpoint mocks block the epic-state read (seam sufficiency)
 221ms (219ms|2ms)
 44ms (42ms|2ms)
 38ms (37ms|0ms)
 46ms (45ms|1ms)
 66ms (65ms|1ms)
 84ms (64ms|20ms)
 77ms (75ms|2ms)
 74ms (73ms|1ms)
 73ms (72ms|1ms)
 55ms (54ms|1ms)
 57ms (56ms|2ms)
 50ms (48ms|1ms)
Tests completed in 1.77s
Tests Passed: 34, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=34
PassedCount=34
FailedCount=0
```
