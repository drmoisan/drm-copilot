# P1-T10 SET-LIB after Phase 1

Timestamp: 2026-10-08T23-55
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=255
  PassedCount=255
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 10 files.
Discovery found 255 tests in 364ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 59ms (41ms|18ms)
 9ms (7ms|2ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 16ms (16ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 7ms (6ms|1ms)
 7ms (5ms|1ms)
 3ms (2ms|1ms)
 5ms (4ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 237ms (236ms|2ms)
 92ms (90ms|2ms)
 41ms (40ms|1ms)
 60ms (59ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 41ms (40ms|1ms)
 25ms (24ms|1ms)
 58ms (57ms|1ms)
 28ms (27ms|1ms)
 25ms (25ms|1ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 27ms (26ms|1ms)
 30ms (29ms|1ms)
 20ms (20ms|0ms)
 25ms (24ms|1ms)
 26ms (25ms|1ms)
 23ms (22ms|1ms)
 22ms (22ms|0ms)
 31ms (30ms|1ms)
 28ms (27ms|1ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 32ms (30ms|2ms)
 43ms (43ms|1ms)
 30ms (29ms|1ms)

Describing EpicScopeResolution read seams
 30ms (29ms|2ms)
 24ms (24ms|1ms)
 21ms (21ms|1ms)
 14ms (13ms|1ms)
 23ms (23ms|1ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 29ms (27ms|2ms)
 32ms (32ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 4ms (3ms|1ms)
 19ms (18ms|1ms)
 3ms (3ms|1ms)

Describing WorktreeItemResolution issue signals
 26ms (24ms|2ms)
 3ms (2ms|1ms)
 6ms (5ms|0ms)
 8ms (7ms|1ms)

Describing WorktreeItemResolution checkpoint reader
 19ms (17ms|2ms)
 27ms (27ms|1ms)

Describing WorktreeItemResolution liveness seam
 50ms (48ms|1ms)
 17ms (17ms|1ms)

Describing WorktreeItemResolution target resolution
 15ms (13ms|1ms)
 37ms (36ms|1ms)
 12ms (11ms|1ms)
 29ms (28ms|1ms)
 18ms (17ms|1ms)
 11ms (11ms|0ms)
 13ms (12ms|0ms)
 14ms (13ms|0ms)
 11ms (11ms|1ms)
 13ms (13ms|1ms)
 10ms (9ms|0ms)
 9ms (9ms|0ms)
 11ms (11ms|1ms)
 11ms (10ms|1ms)
 8ms (7ms|0ms)
 30ms (30ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 9ms (7ms|2ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 5ms (5ms|1ms)
 13ms (12ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 10ms (9ms|1ms)

Describing WorktreeResolution bundle mirror byte identity
 11ms (9ms|2ms)
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (2ms|1ms)
 4ms (4ms|1ms)
 2ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 12ms (10ms|1ms)
 6ms (5ms|1ms)
 27ms (27ms|1ms)

Describing WorktreeResolution
 Context path normalisation
 8ms (4ms|4ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 14ms (13ms|1ms)
 3ms (2ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 6ms (4ms|2ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|1ms)
 Context root marker
 10ms (9ms|1ms)
 11ms (10ms|1ms)
 12ms (11ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|0ms)
 Context upward ascent
 10ms (9ms|1ms)
 23ms (18ms|4ms)
 11ms (10ms|1ms)
 11ms (10ms|1ms)
 14ms (14ms|1ms)
 4ms (4ms|1ms)
 Context worktree enumeration
 37ms (35ms|1ms)
 16ms (16ms|1ms)
 21ms (20ms|1ms)
 8ms (7ms|1ms)
 10ms (10ms|1ms)
 6ms (5ms|1ms)
 16ms (15ms|1ms)
 8ms (7ms|1ms)
 16ms (16ms|1ms)
 13ms (12ms|1ms)
 20ms (18ms|2ms)
 24ms (23ms|1ms)
 17ms (15ms|2ms)
 13ms (12ms|1ms)
 Context repo-relative normalisation
 27ms (26ms|1ms)
 6ms (5ms|0ms)
 6ms (5ms|1ms)
 18ms (17ms|1ms)
 4ms (3ms|1ms)
 8ms (8ms|1ms)
 Context reason code
 4ms (3ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 38ms (37ms|1ms)
 16ms (15ms|1ms)
 15ms (14ms|1ms)
 14ms (13ms|1ms)
 18ms (18ms|1ms)
 12ms (12ms|1ms)
 18ms (17ms|1ms)
 9ms (8ms|0ms)
 10ms (9ms|0ms)
 9ms (9ms|0ms)
 18ms (17ms|1ms)
 14ms (13ms|1ms)
 11ms (11ms|1ms)
 14ms (14ms|1ms)

Describing Resolve-WorktreeOperandTarget
 18ms (17ms|1ms)
 10ms (10ms|1ms)
 16ms (15ms|1ms)
 10ms (9ms|1ms)
 13ms (12ms|1ms)

Describing Run resolver result contract
 25ms (23ms|2ms)
 28ms (27ms|1ms)
 68ms (67ms|1ms)
 21ms (20ms|1ms)
 35ms (35ms|1ms)

Describing Run resolver purity (parse-tree scan)
 50ms (48ms|2ms)
 31ms (30ms|1ms)
 41ms (41ms|1ms)

Describing Resolver module exports
 7ms (5ms|2ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 9ms (7ms|1ms)
 4ms (4ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (4ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 7ms (6ms|1ms)

Describing Get-WorktreeRunCheckpointText
 6ms (4ms|2ms)
 4ms (3ms|1ms)
 6ms (6ms|1ms)
 50ms (49ms|1ms)

Describing Get-WorktreeRunCheckpointPath
 4ms (3ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|1ms)
 12ms (12ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 15ms (14ms|1ms)
 25ms (18ms|7ms)
 18ms (17ms|1ms)
 12ms (12ms|1ms)
 13ms (13ms|1ms)
 16ms (15ms|1ms)
 20ms (20ms|1ms)
 17ms (16ms|1ms)
 14ms (13ms|1ms)
 13ms (12ms|1ms)
 9ms (9ms|1ms)
 27ms (26ms|1ms)
 13ms (12ms|1ms)
 9ms (8ms|1ms)
 11ms (10ms|1ms)

Describing Resolve-WorktreeParallelTarget
 14ms (13ms|1ms)
 16ms (15ms|1ms)
 17ms (17ms|1ms)
 16ms (15ms|1ms)
 11ms (11ms|1ms)
 10ms (9ms|1ms)
 13ms (13ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 9ms (7ms|2ms)
 5ms (5ms|1ms)
 9ms (8ms|1ms)
 7ms (6ms|1ms)
 5ms (5ms|1ms)
 9ms (9ms|0ms)
 13ms (12ms|1ms)
 35ms (35ms|1ms)
 13ms (13ms|1ms)
 Context signal extraction
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 Context required matrix
 37ms (36ms|1ms)
 24ms (23ms|1ms)
 18ms (17ms|1ms)
 29ms (29ms|1ms)
 24ms (24ms|1ms)
 12ms (12ms|1ms)
 29ms (28ms|1ms)
 17ms (17ms|1ms)
 23ms (22ms|1ms)
 21ms (21ms|1ms)
 22ms (22ms|1ms)
 14ms (13ms|1ms)
 Context ambiguity, no target, and Ruling B
 27ms (25ms|2ms)
 18ms (18ms|1ms)
 12ms (12ms|1ms)
 18ms (17ms|1ms)
 17ms (15ms|2ms)
 23ms (22ms|1ms)
 8ms (7ms|1ms)
 19ms (19ms|1ms)
 32ms (32ms|1ms)
 19ms (19ms|1ms)
 28ms (27ms|1ms)
 5ms (5ms|0ms)
 52ms (52ms|0ms)
 Context path composition
 6ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 5ms (5ms|1ms)
Tests completed in 5.73s
Tests Passed: 255, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=255
PassedCount=255
FailedCount=0
```
