# Phase 5 WIR corrective re-Write: SET-LIB re-run (micro-action; confirms the Phase 4 result still holds)

Timestamp: 2026-10-09T00-22
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
Discovery found 266 tests in 340ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 67ms (47ms|20ms)
 10ms (8ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 16ms (3ms|13ms)
 4ms (4ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 7ms (5ms|1ms)
 5ms (4ms|1ms)
 2ms (2ms|1ms)
 4ms (4ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 219ms (218ms|1ms)
 51ms (49ms|2ms)
 39ms (39ms|0ms)
 49ms (48ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 35ms (34ms|1ms)
 20ms (20ms|1ms)
 52ms (51ms|1ms)
 22ms (22ms|1ms)
 24ms (23ms|1ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 24ms (23ms|1ms)
 23ms (22ms|1ms)
 17ms (16ms|0ms)
 20ms (19ms|0ms)
 16ms (16ms|0ms)
 17ms (17ms|0ms)
 18ms (18ms|0ms)
 17ms (16ms|0ms)
 17ms (17ms|0ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 19ms (18ms|1ms)
 26ms (25ms|0ms)
 21ms (21ms|0ms)

Describing EpicScopeResolution read seams
 21ms (20ms|1ms)
 18ms (18ms|0ms)
 11ms (10ms|0ms)
 12ms (11ms|0ms)
 17ms (16ms|0ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 23ms (22ms|1ms)
 36ms (36ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1'
Describing Resolve-WorktreeItemTargetByPrNumber
 79ms (78ms|1ms)
 56ms (55ms|1ms)
 28ms (27ms|1ms)
 33ms (32ms|2ms)
 66ms (65ms|1ms)
 16ms (15ms|1ms)
 30ms (29ms|1ms)
 18ms (17ms|1ms)
 19ms (18ms|1ms)
 21ms (20ms|1ms)
 27ms (26ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 5ms (3ms|2ms)
 24ms (23ms|1ms)
 5ms (4ms|1ms)

Describing WorktreeItemResolution issue signals
 21ms (19ms|2ms)
 5ms (4ms|1ms)
 9ms (9ms|1ms)
 8ms (8ms|1ms)

Describing WorktreeItemResolution checkpoint reader
 14ms (13ms|2ms)
 21ms (20ms|1ms)

Describing WorktreeItemResolution liveness seam
 40ms (39ms|1ms)
 14ms (14ms|1ms)

Describing WorktreeItemResolution target resolution
 19ms (18ms|1ms)
 21ms (20ms|0ms)
 10ms (9ms|0ms)
 14ms (14ms|0ms)
 17ms (16ms|1ms)
 14ms (13ms|1ms)
 13ms (12ms|0ms)
 22ms (21ms|1ms)
 14ms (13ms|1ms)
 19ms (18ms|1ms)
 17ms (16ms|1ms)
 12ms (11ms|1ms)
 20ms (20ms|1ms)
 13ms (12ms|1ms)
 12ms (12ms|1ms)
 44ms (43ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 12ms (9ms|3ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 10ms (9ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 8ms (8ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 13ms (12ms|1ms)

Describing WorktreeResolution bundle mirror byte identity
 14ms (12ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 15ms (13ms|2ms)
 8ms (7ms|1ms)
 50ms (49ms|1ms)

Describing WorktreeResolution
 Context path normalisation
 15ms (6ms|9ms)
 4ms (2ms|2ms)
 5ms (4ms|2ms)
 4ms (3ms|1ms)
 7ms (5ms|2ms)
 4ms (2ms|1ms)
 8ms (6ms|1ms)
 10ms (7ms|3ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (2ms|2ms)
 Context root marker
 16ms (14ms|2ms)
 20ms (19ms|1ms)
 20ms (19ms|1ms)
 14ms (13ms|2ms)
 12ms (11ms|1ms)
 13ms (9ms|5ms)
 Context upward ascent
 23ms (18ms|5ms)
 30ms (29ms|1ms)
 23ms (22ms|1ms)
 19ms (18ms|1ms)
 24ms (23ms|1ms)
 8ms (6ms|1ms)
 Context worktree enumeration
 51ms (49ms|2ms)
 25ms (24ms|1ms)
 47ms (46ms|1ms)
 10ms (9ms|1ms)
 13ms (12ms|1ms)
 7ms (6ms|1ms)
 12ms (11ms|1ms)
 10ms (9ms|1ms)
 23ms (23ms|1ms)
 17ms (16ms|1ms)
 25ms (23ms|2ms)
 18ms (17ms|1ms)
 23ms (21ms|2ms)
 33ms (32ms|1ms)
 Context repo-relative normalisation
 36ms (34ms|2ms)
 8ms (7ms|1ms)
 7ms (7ms|1ms)
 18ms (17ms|1ms)
 6ms (5ms|1ms)
 12ms (11ms|1ms)
 Context reason code
 6ms (4ms|2ms)
 16ms (16ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 51ms (50ms|1ms)
 16ms (16ms|1ms)
 23ms (23ms|1ms)
 21ms (20ms|1ms)
 14ms (13ms|1ms)
 13ms (12ms|1ms)
 24ms (23ms|1ms)
 14ms (13ms|1ms)
 16ms (15ms|1ms)
 17ms (16ms|1ms)
 21ms (20ms|1ms)
 25ms (24ms|1ms)
 27ms (26ms|1ms)
 39ms (29ms|10ms)

Describing Resolve-WorktreeOperandTarget
 36ms (33ms|3ms)
 19ms (18ms|1ms)
 24ms (23ms|1ms)
 15ms (14ms|1ms)
 22ms (21ms|1ms)

Describing Run resolver result contract
 70ms (47ms|23ms)
 48ms (45ms|2ms)
 52ms (51ms|1ms)
 34ms (33ms|1ms)
 50ms (48ms|1ms)

Describing Run resolver purity (parse-tree scan)
 47ms (45ms|2ms)
 32ms (31ms|1ms)
 52ms (51ms|1ms)

Describing Resolver module exports
 7ms (5ms|2ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 9ms (8ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 7ms (6ms|1ms)

Describing Get-WorktreeRunCheckpointText
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 5ms (4ms|0ms)
 52ms (51ms|1ms)

Describing Get-WorktreeRunCheckpointPath
 4ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|0ms)
 14ms (14ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 14ms (12ms|1ms)
 18ms (17ms|1ms)
 24ms (24ms|1ms)
 11ms (11ms|1ms)
 17ms (17ms|1ms)
 17ms (16ms|1ms)
 22ms (21ms|1ms)
 34ms (33ms|1ms)
 18ms (18ms|1ms)
 16ms (16ms|1ms)
 12ms (12ms|1ms)
 10ms (10ms|1ms)
 9ms (9ms|1ms)
 15ms (14ms|1ms)
 12ms (12ms|1ms)

Describing Resolve-WorktreeParallelTarget
 15ms (13ms|1ms)
 14ms (14ms|1ms)
 16ms (15ms|0ms)
 14ms (13ms|1ms)
 16ms (15ms|1ms)
 9ms (9ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 9ms (7ms|1ms)
 4ms (4ms|1ms)
 6ms (5ms|1ms)
 6ms (6ms|1ms)
 5ms (4ms|1ms)
 10ms (10ms|0ms)
 11ms (10ms|0ms)
 23ms (23ms|0ms)
 13ms (12ms|1ms)
 Context signal extraction
 9ms (8ms|1ms)
 4ms (4ms|1ms)
 2ms (1ms|1ms)
 4ms (4ms|1ms)
 1ms (1ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 Context required matrix
 36ms (35ms|1ms)
 26ms (25ms|1ms)
 22ms (21ms|1ms)
 17ms (17ms|1ms)
 19ms (18ms|1ms)
 15ms (14ms|1ms)
 22ms (21ms|1ms)
 26ms (25ms|1ms)
 17ms (16ms|1ms)
 12ms (12ms|1ms)
 21ms (20ms|1ms)
 12ms (11ms|1ms)
 Context ambiguity, no target, and Ruling B
 26ms (24ms|2ms)
 18ms (17ms|1ms)
 12ms (11ms|1ms)
 21ms (21ms|1ms)
 24ms (23ms|1ms)
 29ms (28ms|1ms)
 13ms (12ms|1ms)
 14ms (13ms|1ms)
 38ms (38ms|1ms)
 23ms (22ms|1ms)
 39ms (38ms|1ms)
 7ms (6ms|1ms)
 43ms (43ms|1ms)
 Context path composition
 9ms (8ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 6ms (5ms|1ms)
Tests completed in 6.84s
Tests Passed: 266, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=266
PassedCount=266
FailedCount=0
```
