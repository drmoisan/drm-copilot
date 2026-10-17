# P3-T12 SET-REM after Phase 3 (includes T-EREM-DX)

Timestamp: 2026-10-09T00-06
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=232
  PassedCount=232
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 10 files.
Discovery found 232 tests in 399ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1
 Context commands outside scope
 76ms (54ms|22ms)
 20ms (9ms|11ms)
 63ms (63ms|0ms)
 12ms (11ms|1ms)
 Context allow on merge_status merged
 84ms (83ms|1ms)
 Context allow on merge_status worktree_removed
 16ms (15ms|1ms)
 Context deny on unreadable checkpoint
 52ms (51ms|1ms)
 23ms (22ms|0ms)
 Context deny on no matching record
 33ms (32ms|1ms)
 Context deny on other merge_status
 23ms (22ms|1ms)
 Context path normalization
 16ms (16ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the epic gate
 5ms (5ms|1ms)
 4ms (3ms|0ms)
 Context Find-EpicWorktreeFeatureRecord helper
 9ms (8ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Test-EpicWorktreeRemovalAllowed helper
 4ms (4ms|1ms)
 2ms (2ms|0ms)
 Context real Test-Path read seam
 50ms (49ms|1ms)
 33ms (32ms|0ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 21ms (20ms|1ms)
 8ms (8ms|0ms)
 8ms (8ms|0ms)
 8ms (7ms|0ms)
 7ms (7ms|0ms)
 33ms (33ms|0ms)
 21ms (21ms|0ms)
 Context parallel branch allow (AC-1, AC-2, AC-3)
 28ms (27ms|1ms)
 18ms (18ms|0ms)
 17ms (16ms|0ms)
 Context parallel branch fail-closed deny (AC-4)
 22ms (21ms|1ms)
 16ms (15ms|0ms)
 29ms (28ms|0ms)
 27ms (26ms|1ms)
 23ms (23ms|1ms)
 22ms (21ms|1ms)
 17ms (17ms|0ms)
 17ms (17ms|0ms)
 Context branch precedence and check ordering (AC-5, AC-7)
 19ms (18ms|1ms)
 31ms (31ms|0ms)
 Context Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 Context real Test-Path parallel read seam (AC-9)
 9ms (8ms|1ms)
 15ms (15ms|0ms)

Describing enforce-epic-worktree-removal-gate.ps1 manifest branch
 62ms (61ms|1ms)
 24ms (23ms|0ms)
 40ms (40ms|0ms)
 15ms (15ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-worktree-removal-gate trigger scoping (issue #545)
 Context under-match removal - a relocating spelling is now in scope
 27ms (25ms|2ms)
 Context operand resolution - the --force flag never becomes the path
 6ms (5ms|1ms)
 5ms (5ms|0ms)
 Context over-match removal and scope narrowing
 13ms (13ms|1ms)
 13ms (12ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing epic worktree-removal gate run-target resolution
 90ms (89ms|1ms)
 29ms (29ms|0ms)
 38ms (38ms|0ms)
 31ms (30ms|0ms)
 24ms (24ms|0ms)
 7ms (7ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1
 Context commands outside scope are allowed unconditionally
 8ms (7ms|1ms)
 6ms (5ms|0ms)
 7ms (7ms|0ms)
 8ms (8ms|0ms)
 10ms (10ms|1ms)
 6ms (6ms|0ms)
 Context allow when the matched item merge_status is terminal
 34ms (33ms|1ms)
 19ms (19ms|1ms)
 20ms (19ms|1ms)
 Context deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status
 24ms (24ms|1ms)
 19ms (19ms|0ms)
 17ms (17ms|0ms)
 30ms (30ms|0ms)
 21ms (21ms|0ms)
 20ms (20ms|0ms)
 22ms (21ms|1ms)
 Context deny fail-closed on an unusable checkpoint or an unmatched path
 24ms (20ms|4ms)
 21ms (21ms|1ms)
 22ms (21ms|1ms)
 33ms (33ms|0ms)
 Context read seam binding (the mocked seam value determines the decision)
 39ms (37ms|2ms)
 35ms (34ms|1ms)
 24ms (23ms|1ms)
 Context path normalization
 47ms (42ms|5ms)
 34ms (33ms|1ms)
 31ms (30ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the parallel gate
 19ms (15ms|4ms)
 22ms (21ms|1ms)
 Context Find-ParallelWorktreeItemRecord helper
 9ms (7ms|1ms)
 8ms (8ms|1ms)
 8ms (7ms|1ms)
 9ms (8ms|1ms)
 12ms (11ms|1ms)
 Context Test-ParallelWorktreeRemovalAllowed helper
 9ms (7ms|2ms)
 9ms (8ms|1ms)
 11ms (10ms|1ms)
 Context real Test-Path read seam
 23ms (21ms|2ms)
 39ms (38ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 20ms (19ms|1ms)
 13ms (13ms|1ms)
 11ms (10ms|1ms)
 9ms (9ms|1ms)
 12ms (11ms|1ms)
 28ms (28ms|1ms)
 25ms (24ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest branch
 47ms (45ms|2ms)
 46ms (45ms|1ms)
 53ms (52ms|1ms)
 29ms (28ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1 epic authorization
 Context epic authorization branch (issue #688)
 47ms (44ms|3ms)
 36ms (36ms|1ms)
 36ms (35ms|1ms)
 64ms (63ms|1ms)
 26ms (26ms|1ms)
 24ms (23ms|1ms)
 29ms (28ms|1ms)
 26ms (25ms|1ms)
 27ms (26ms|1ms)
 38ms (37ms|1ms)
 30ms (30ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate trigger scoping (issue #545)
 Context operand resolution - the --force flag never becomes the path
 9ms (7ms|2ms)
 Context under-match removal - a relocating spelling is now in scope
 35ms (34ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 12ms (10ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 64ms (62ms|2ms)
 41ms (41ms|1ms)
 40ms (40ms|1ms)
 36ms (35ms|1ms)
 32ms (31ms|1ms)
 8ms (8ms|1ms)
 34ms (33ms|0ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 43ms (42ms|2ms)
 27ms (27ms|1ms)
 23ms (22ms|1ms)
 25ms (25ms|1ms)
 23ms (22ms|1ms)
 27ms (27ms|1ms)
 31ms (31ms|1ms)
 31ms (30ms|1ms)
 30ms (29ms|1ms)
 23ms (22ms|1ms)
 24ms (24ms|1ms)
 27ms (26ms|1ms)
 26ms (25ms|1ms)
 32ms (32ms|1ms)
 40ms (39ms|1ms)
 41ms (40ms|1ms)
 54ms (53ms|1ms)
 55ms (53ms|1ms)
 62ms (60ms|1ms)
 62ms (60ms|1ms)
 50ms (49ms|1ms)
 51ms (50ms|1ms)
 46ms (45ms|1ms)
 45ms (44ms|1ms)
 50ms (49ms|1ms)
 44ms (43ms|1ms)
 30ms (29ms|1ms)
 30ms (29ms|1ms)
 27ms (26ms|1ms)
 30ms (29ms|1ms)
 27ms (26ms|1ms)
 28ms (28ms|1ms)
 36ms (35ms|1ms)
 30ms (29ms|1ms)
 31ms (30ms|1ms)
 30ms (29ms|1ms)
 29ms (29ms|1ms)
 28ms (28ms|1ms)
 22ms (21ms|1ms)
 43ms (42ms|1ms)
 44ms (44ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 31ms (30ms|2ms)
 20ms (19ms|1ms)
 25ms (24ms|1ms)
 23ms (23ms|1ms)
 24ms (23ms|1ms)
 19ms (19ms|1ms)
 23ms (22ms|1ms)
 22ms (21ms|1ms)
 28ms (28ms|1ms)
 37ms (36ms|1ms)
 31ms (30ms|1ms)
 32ms (31ms|1ms)
 38ms (37ms|1ms)
 35ms (34ms|1ms)
 31ms (31ms|1ms)
 36ms (35ms|1ms)
 33ms (32ms|1ms)
 32ms (31ms|1ms)
 32ms (31ms|1ms)
 23ms (23ms|1ms)
 23ms (22ms|1ms)
 27ms (26ms|1ms)
 27ms (26ms|1ms)
 22ms (22ms|1ms)
 30ms (29ms|1ms)
 34ms (33ms|1ms)
 45ms (44ms|1ms)
 38ms (37ms|1ms)
 31ms (30ms|1ms)
 32ms (31ms|1ms)
 33ms (32ms|1ms)
 26ms (25ms|1ms)
 27ms (27ms|1ms)
 31ms (30ms|1ms)
 24ms (24ms|1ms)
 22ms (22ms|1ms)
 26ms (25ms|1ms)
 23ms (22ms|1ms)
 23ms (22ms|1ms)
 47ms (46ms|1ms)
 39ms (38ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 33ms (31ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 19ms (18ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 39ms (38ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 27ms (26ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 11ms (10ms|1ms)
 Context AT-6 - the wrapper deny pin
 71ms (70ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 7ms (6ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 8ms (7ms|1ms)
 13ms (5ms|8ms)
 5ms (5ms|1ms)
 10ms (9ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1'
Describing epic worktree-removal gate deny diagnostics
 56ms (55ms|1ms)
 38ms (38ms|1ms)
 30ms (29ms|1ms)
 36ms (35ms|1ms)
 35ms (35ms|1ms)
 Context diagnostics builder and read result
 21ms (20ms|1ms)
 26ms (25ms|1ms)
 16ms (15ms|1ms)
Tests completed in 9.47s
Tests Passed: 232, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=232
PassedCount=232
FailedCount=0
```
