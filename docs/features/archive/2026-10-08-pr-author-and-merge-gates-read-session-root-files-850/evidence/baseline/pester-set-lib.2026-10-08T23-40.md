# P0-T20 Pester baseline SET-LIB

Timestamp: 2026-10-08T23-40
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/worktree-resolution
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=254
  PassedCount=254
  FailedCount=0
  BASE_LIB: 254
  A18 (copied verbatim from evidence/baseline/pester-set-pra.2026-10-08T23-39.md; not re-run):
  DECISION=deny
  REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
  DECISION-WITHOUT-CHECKPOINT=allow
  Rule EE: applied; SET-LIB contains no EE-ROWS suite, so nothing is exempt (no ENV-EPIC-FAILED line).
  Baseline failure set: empty
  Baseline container set: empty
  BASELINE-RED-IN-EDITED-SUITE: not triggered

## Full output

```text
Pester v5.6.1

Starting discovery in 10 files.
Discovery found 254 tests in 361ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 64ms (44ms|19ms)
 10ms (8ms|2ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 17ms (16ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 7ms (5ms|2ms)
 7ms (5ms|1ms)
 3ms (2ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 234ms (233ms|2ms)
 85ms (83ms|2ms)
 34ms (33ms|1ms)
 61ms (60ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 48ms (47ms|1ms)
 31ms (30ms|1ms)
 70ms (69ms|1ms)
 34ms (33ms|1ms)
 32ms (32ms|1ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 36ms (34ms|2ms)
 33ms (33ms|1ms)
 24ms (23ms|1ms)
 24ms (23ms|1ms)
 29ms (28ms|1ms)
 28ms (28ms|1ms)
 38ms (37ms|1ms)
 29ms (28ms|1ms)
 25ms (24ms|1ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 32ms (30ms|2ms)
 41ms (40ms|1ms)
 28ms (28ms|1ms)

Describing EpicScopeResolution read seams
 27ms (25ms|2ms)
 25ms (24ms|1ms)
 22ms (21ms|1ms)
 18ms (17ms|1ms)
 24ms (24ms|1ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 33ms (32ms|2ms)
 51ms (50ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 6ms (4ms|2ms)
 26ms (25ms|1ms)
 5ms (4ms|1ms)

Describing WorktreeItemResolution issue signals
 38ms (35ms|2ms)
 5ms (4ms|1ms)
 12ms (11ms|1ms)
 12ms (11ms|1ms)

Describing WorktreeItemResolution checkpoint reader
 27ms (24ms|2ms)
 65ms (64ms|1ms)

Describing WorktreeItemResolution liveness seam
 105ms (102ms|3ms)
 31ms (29ms|2ms)

Describing WorktreeItemResolution target resolution
 44ms (40ms|4ms)
 64ms (63ms|1ms)
 26ms (25ms|1ms)
 58ms (56ms|1ms)
 38ms (37ms|1ms)
 21ms (20ms|1ms)
 26ms (25ms|1ms)
 27ms (26ms|1ms)
 19ms (18ms|1ms)
 22ms (21ms|1ms)
 17ms (16ms|1ms)
 13ms (12ms|1ms)
 22ms (22ms|1ms)
 23ms (22ms|1ms)
 15ms (14ms|1ms)
 51ms (50ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 13ms (10ms|3ms)
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 7ms (6ms|1ms)
 6ms (5ms|1ms)
 5ms (4ms|1ms)
 14ms (13ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 19ms (18ms|1ms)

Describing WorktreeResolution bundle mirror byte identity
 16ms (14ms|2ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 7ms (6ms|1ms)
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 15ms (14ms|1ms)
 6ms (6ms|1ms)
 29ms (29ms|1ms)

Describing WorktreeResolution
 Context path normalisation
 9ms (5ms|5ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 14ms (1ms|13ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 6ms (5ms|2ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|1ms)
 Context root marker
 10ms (8ms|1ms)
 11ms (11ms|1ms)
 12ms (11ms|1ms)
 5ms (4ms|1ms)
 6ms (6ms|1ms)
 6ms (5ms|1ms)
 Context upward ascent
 14ms (13ms|1ms)
 18ms (14ms|4ms)
 10ms (9ms|1ms)
 11ms (10ms|1ms)
 16ms (15ms|1ms)
 4ms (4ms|1ms)
 Context worktree enumeration
 64ms (63ms|1ms)
 20ms (19ms|1ms)
 31ms (30ms|1ms)
 15ms (14ms|1ms)
 16ms (14ms|1ms)
 9ms (8ms|1ms)
 18ms (17ms|1ms)
 9ms (9ms|1ms)
 20ms (19ms|1ms)
 15ms (15ms|1ms)
 24ms (22ms|2ms)
 28ms (27ms|1ms)
 19ms (17ms|2ms)
 19ms (18ms|1ms)
 Context repo-relative normalisation
 26ms (25ms|1ms)
 7ms (6ms|1ms)
 8ms (7ms|1ms)
 19ms (18ms|1ms)
 4ms (3ms|1ms)
 8ms (7ms|1ms)
 Context reason code
 5ms (3ms|1ms)
 14ms (13ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 38ms (37ms|1ms)
 16ms (16ms|0ms)
 14ms (13ms|1ms)
 18ms (18ms|1ms)
 20ms (19ms|1ms)
 15ms (14ms|1ms)
 14ms (13ms|1ms)
 9ms (8ms|0ms)
 9ms (8ms|1ms)
 11ms (10ms|1ms)
 15ms (14ms|0ms)
 13ms (13ms|1ms)
 11ms (11ms|1ms)

Describing Resolve-WorktreeOperandTarget
 18ms (17ms|1ms)
 8ms (7ms|1ms)
 10ms (10ms|1ms)
 8ms (8ms|1ms)
 18ms (17ms|0ms)

Describing Run resolver result contract
 26ms (25ms|1ms)
 25ms (24ms|1ms)
 32ms (31ms|1ms)
 41ms (31ms|10ms)
 31ms (30ms|0ms)

Describing Run resolver purity (parse-tree scan)
 45ms (43ms|1ms)
 24ms (23ms|1ms)
 36ms (36ms|1ms)

Describing Resolver module exports
 6ms (5ms|1ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 9ms (7ms|2ms)
 5ms (4ms|1ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|1ms)
 4ms (3ms|0ms)
 7ms (6ms|1ms)

Describing Get-WorktreeRunCheckpointText
 6ms (4ms|2ms)
 4ms (3ms|1ms)
 6ms (6ms|1ms)
 75ms (74ms|1ms)

Describing Get-WorktreeRunCheckpointPath
 6ms (4ms|2ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 25ms (23ms|2ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 26ms (24ms|2ms)
 28ms (28ms|1ms)
 27ms (26ms|1ms)
 21ms (20ms|1ms)
 25ms (25ms|1ms)
 26ms (25ms|1ms)
 35ms (34ms|1ms)
 25ms (25ms|1ms)
 24ms (23ms|1ms)
 20ms (19ms|1ms)
 15ms (14ms|1ms)
 17ms (16ms|1ms)
 32ms (31ms|1ms)
 16ms (15ms|1ms)
 15ms (14ms|1ms)

Describing Resolve-WorktreeParallelTarget
 19ms (17ms|2ms)
 23ms (22ms|1ms)
 25ms (24ms|1ms)
 26ms (21ms|4ms)
 16ms (15ms|1ms)
 17ms (16ms|1ms)
 16ms (16ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 19ms (17ms|2ms)
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 12ms (11ms|1ms)
 15ms (15ms|1ms)
 30ms (29ms|1ms)
 22ms (21ms|1ms)
 Context signal extraction
 6ms (5ms|2ms)
 6ms (5ms|1ms)
 2ms (2ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 5ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|1ms)
 Context required matrix
 41ms (39ms|2ms)
 26ms (25ms|1ms)
 21ms (21ms|1ms)
 30ms (30ms|1ms)
 24ms (23ms|1ms)
 13ms (12ms|1ms)
 28ms (28ms|1ms)
 16ms (15ms|1ms)
 21ms (20ms|1ms)
 13ms (12ms|1ms)
 22ms (21ms|1ms)
 15ms (14ms|1ms)
 Context ambiguity, no target, and Ruling B
 27ms (25ms|2ms)
 24ms (24ms|1ms)
 16ms (16ms|1ms)
 33ms (32ms|1ms)
 34ms (33ms|1ms)
 38ms (38ms|1ms)
 10ms (9ms|1ms)
 12ms (11ms|1ms)
 46ms (45ms|1ms)
 33ms (32ms|1ms)
 42ms (41ms|1ms)
 9ms (8ms|1ms)
 59ms (59ms|1ms)
 Context path composition
 6ms (5ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|1ms)
 2ms (1ms|1ms)
 5ms (4ms|1ms)
Tests completed in 6.84s
Tests Passed: 254, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=254
PassedCount=254
FailedCount=0
```
