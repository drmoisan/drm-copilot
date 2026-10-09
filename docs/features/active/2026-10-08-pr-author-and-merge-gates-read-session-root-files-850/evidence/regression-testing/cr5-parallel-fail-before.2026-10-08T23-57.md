# P2-T2 [expect-fail] CR-5 fail-before run (parallel WorktreeResolution suite)

Timestamp: 2026-10-08T23-57
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 1, 
  TotalCount=7
  PassedCount=6
  FailedCount=1
  FAILED: parallel worktree-removal gate run-target resolution.Y7 emits a single leading token when both run kinds are unresolved
  FAILED-FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1

Note: Expected outcome: FailedCount=1 with the single FAILED line ending in 'Y7 emits a single leading token when both run kinds are unresolved' (PREM still emits the token twice before B2).

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 7 tests in 158ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 517ms (492ms|25ms)
 77ms (75ms|2ms)
 61ms (61ms|1ms)
 49ms (49ms|1ms)
 36ms (35ms|1ms)
 18ms (17ms|1ms)
  [-] Y7 emits a single leading token when both run kinds are unresolved
 64ms (63ms|1ms)
   at ([regex]::Matches($reason, 'PARALLEL_WORKTREE_REMOVAL_BLOCKED:')).Count | Should -Be 1 -Because 'the gate token appears exactly once', tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:178
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:178
   Expected 1, because the gate token appears exactly once, but got 2.
Tests completed in 1.47s
Tests Passed: 6, 
Failed: 1, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=7
PassedCount=6
FailedCount=1
FAILED: parallel worktree-removal gate run-target resolution.Y7 emits a single leading token when both run kinds are unresolved
FAILED-FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
```
