# P4-T10 SET-LIB after Phase 4

Timestamp: 2026-10-09T00-12
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=266
  PassedCount=266
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 11 files.
Discovery found 266 tests in 338ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 62ms (43ms|19ms)
 8ms (6ms|2ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 17ms (3ms|14ms)
 4ms (3ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 5ms (4ms|1ms)
 3ms (3ms|0ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 206ms (205ms|1ms)
 49ms (48ms|1ms)
 36ms (35ms|0ms)
 45ms (45ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 32ms (31ms|1ms)
 19ms (19ms|0ms)
 41ms (41ms|0ms)
 20ms (20ms|0ms)
 19ms (19ms|0ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 19ms (18ms|1ms)
 23ms (22ms|0ms)
 16ms (16ms|0ms)
 22ms (21ms|0ms)
 16ms (15ms|0ms)
 17ms (17ms|0ms)
 20ms (19ms|0ms)
 19ms (18ms|1ms)
 23ms (23ms|0ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 23ms (21ms|2ms)
 29ms (28ms|1ms)
 26ms (25ms|1ms)

Describing EpicScopeResolution read seams
 22ms (21ms|1ms)
 18ms (18ms|0ms)
 11ms (10ms|0ms)
 10ms (10ms|0ms)
 16ms (16ms|0ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 23ms (22ms|1ms)
 27ms (27ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1'
Describing Resolve-WorktreeItemTargetByPrNumber
 40ms (39ms|1ms)
 18ms (17ms|0ms)
 12ms (12ms|0ms)
 14ms (13ms|0ms)
 41ms (41ms|0ms)
 8ms (8ms|0ms)
 10ms (10ms|0ms)
 8ms (8ms|0ms)
 8ms (8ms|0ms)
 10ms (9ms|1ms)
 14ms (14ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 3ms (2ms|1ms)
 14ms (13ms|0ms)
 3ms (2ms|0ms)

Describing WorktreeItemResolution issue signals
 12ms (11ms|1ms)
 2ms (2ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)

Describing WorktreeItemResolution checkpoint reader
 14ms (10ms|4ms)
 19ms (18ms|0ms)

Describing WorktreeItemResolution liveness seam
 37ms (35ms|2ms)
 19ms (19ms|0ms)

Describing WorktreeItemResolution target resolution
 43ms (41ms|2ms)
 41ms (40ms|1ms)
 29ms (28ms|1ms)
 29ms (28ms|1ms)
 35ms (34ms|1ms)
 31ms (25ms|6ms)
 29ms (28ms|1ms)
 27ms (27ms|1ms)
 15ms (14ms|1ms)
 28ms (26ms|1ms)
 36ms (35ms|1ms)
 18ms (17ms|1ms)
 28ms (27ms|1ms)
 24ms (22ms|1ms)
 16ms (15ms|1ms)
 57ms (56ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 16ms (13ms|3ms)
 8ms (7ms|1ms)
 8ms (7ms|1ms)
 9ms (7ms|1ms)
 9ms (8ms|1ms)
 9ms (8ms|1ms)
 14ms (12ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 8ms (7ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 20ms (19ms|1ms)

Describing WorktreeResolution bundle mirror byte identity
 16ms (14ms|2ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 21ms (19ms|2ms)
 6ms (6ms|1ms)
 45ms (44ms|1ms)

Describing WorktreeResolution
 Context path normalisation
 10ms (4ms|5ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 8ms (6ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 Context root marker
 14ms (12ms|2ms)
 16ms (16ms|1ms)
 14ms (12ms|1ms)
 7ms (7ms|1ms)
 6ms (6ms|1ms)
 8ms (7ms|1ms)
 Context upward ascent
 17ms (14ms|2ms)
 21ms (21ms|1ms)
 13ms (13ms|1ms)
 14ms (13ms|1ms)
 21ms (20ms|1ms)
 5ms (4ms|1ms)
 Context worktree enumeration
 52ms (50ms|2ms)
 27ms (26ms|1ms)
 58ms (56ms|1ms)
 16ms (15ms|1ms)
 13ms (13ms|1ms)
 6ms (5ms|1ms)
 12ms (11ms|1ms)
 10ms (9ms|1ms)
 20ms (19ms|1ms)
 13ms (12ms|1ms)
 18ms (17ms|2ms)
 12ms (11ms|1ms)
 14ms (13ms|2ms)
 23ms (22ms|1ms)
 Context repo-relative normalisation
 23ms (22ms|1ms)
 6ms (5ms|0ms)
 5ms (4ms|1ms)
 12ms (12ms|1ms)
 3ms (2ms|1ms)
 7ms (7ms|1ms)
 Context reason code
 4ms (3ms|1ms)
 10ms (9ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 35ms (34ms|1ms)
 13ms (12ms|0ms)
 14ms (13ms|0ms)
 14ms (13ms|0ms)
 11ms (11ms|0ms)
 11ms (10ms|0ms)
 16ms (15ms|0ms)
 9ms (9ms|0ms)
 10ms (9ms|1ms)
 10ms (10ms|0ms)
 12ms (11ms|0ms)
 10ms (10ms|0ms)
 13ms (13ms|0ms)
 41ms (41ms|0ms)

Describing Resolve-WorktreeOperandTarget
 15ms (14ms|1ms)
 7ms (7ms|0ms)
 9ms (8ms|0ms)
 7ms (7ms|1ms)
 22ms (11ms|11ms)

Describing Run resolver result contract
 25ms (24ms|1ms)
 21ms (21ms|1ms)
 25ms (25ms|1ms)
 18ms (17ms|1ms)
 29ms (29ms|0ms)

Describing Run resolver purity (parse-tree scan)
 35ms (34ms|1ms)
 25ms (24ms|1ms)
 42ms (42ms|1ms)

Describing Resolver module exports
 5ms (4ms|1ms)
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 7ms (6ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|1ms)
 5ms (5ms|1ms)

Describing Get-WorktreeRunCheckpointText
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 5ms (4ms|1ms)
 52ms (52ms|1ms)

Describing Get-WorktreeRunCheckpointPath
 4ms (3ms|2ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 13ms (13ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 17ms (16ms|1ms)
 17ms (17ms|1ms)
 17ms (17ms|1ms)
 13ms (13ms|1ms)
 13ms (13ms|0ms)
 11ms (11ms|0ms)
 17ms (17ms|0ms)
 18ms (17ms|0ms)
 17ms (16ms|1ms)
 12ms (11ms|1ms)
 11ms (10ms|1ms)
 9ms (9ms|1ms)
 14ms (14ms|1ms)
 27ms (26ms|1ms)
 10ms (10ms|1ms)

Describing Resolve-WorktreeParallelTarget
 12ms (11ms|1ms)
 16ms (15ms|1ms)
 14ms (13ms|1ms)
 16ms (15ms|1ms)
 12ms (11ms|1ms)
 9ms (8ms|1ms)
 11ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 11ms (9ms|2ms)
 5ms (5ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 11ms (10ms|1ms)
 13ms (12ms|1ms)
 25ms (24ms|1ms)
 12ms (11ms|1ms)
 Context signal extraction
 13ms (11ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 4ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|1ms)
 Context required matrix
 28ms (27ms|1ms)
 19ms (18ms|1ms)
 14ms (14ms|1ms)
 16ms (16ms|1ms)
 16ms (15ms|1ms)
 10ms (10ms|1ms)
 14ms (14ms|1ms)
 14ms (13ms|1ms)
 17ms (16ms|1ms)
 15ms (14ms|1ms)
 17ms (16ms|1ms)
 13ms (12ms|1ms)
 Context ambiguity, no target, and Ruling B
 19ms (17ms|2ms)
 18ms (17ms|1ms)
 11ms (11ms|1ms)
 14ms (14ms|1ms)
 15ms (14ms|1ms)
 21ms (20ms|1ms)
 7ms (7ms|0ms)
 9ms (8ms|1ms)
 29ms (29ms|1ms)
 24ms (23ms|1ms)
 25ms (25ms|1ms)
 4ms (4ms|0ms)
 32ms (31ms|0ms)
 Context path composition
 7ms (6ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|1ms)
 4ms (3ms|0ms)
Tests completed in 5.84s
Tests Passed: 266, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=266
PassedCount=266
FailedCount=0
```
