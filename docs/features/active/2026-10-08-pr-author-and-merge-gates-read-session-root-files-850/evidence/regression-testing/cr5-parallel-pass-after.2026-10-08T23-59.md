# P2-T9 CR-5 pass-after run (parallel WorktreeResolution suite)

Timestamp: 2026-10-08T23-59
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=7
  PassedCount=7
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 7 tests in 166ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 533ms (508ms|25ms)
 52ms (50ms|2ms)
 66ms (65ms|1ms)
 46ms (46ms|1ms)
 34ms (34ms|1ms)
 17ms (16ms|1ms)
 42ms (42ms|1ms)
Tests completed in 1.47s
Tests Passed: 7, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=7
PassedCount=7
FailedCount=0
```
