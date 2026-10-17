# P2-T10 SET-REM after Phase 2

Timestamp: 2026-10-08T23-59
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=224
  PassedCount=224
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 9 files.
Discovery found 224 tests in 717ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1
 Context commands outside scope
 105ms (77ms|28ms)
 52ms (50ms|1ms)
 119ms (118ms|1ms)
 16ms (15ms|1ms)
 Context allow on merge_status merged
 116ms (115ms|1ms)
 Context allow on merge_status worktree_removed
 19ms (18ms|1ms)
 Context deny on unreadable checkpoint
 68ms (67ms|1ms)
 36ms (35ms|1ms)
 Context deny on no matching record
 46ms (45ms|1ms)
 Context deny on other merge_status
 35ms (34ms|2ms)
 Context path normalization
 20ms (19ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the epic gate
 8ms (6ms|1ms)
 12ms (11ms|1ms)
 Context Find-EpicWorktreeFeatureRecord helper
 12ms (11ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 Context Test-EpicWorktreeRemovalAllowed helper
 6ms (5ms|1ms)
 4ms (3ms|1ms)
 Context real Test-Path read seam
 75ms (73ms|2ms)
 51ms (50ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 34ms (32ms|2ms)
 20ms (19ms|1ms)
 21ms (20ms|1ms)
 19ms (18ms|1ms)
 21ms (20ms|1ms)
 72ms (71ms|1ms)
 59ms (58ms|1ms)
 Context parallel branch allow (AC-1, AC-2, AC-3)
 79ms (65ms|13ms)
 62ms (61ms|2ms)
 55ms (52ms|3ms)
 Context parallel branch fail-closed deny (AC-4)
 62ms (58ms|4ms)
 56ms (55ms|1ms)
 52ms (51ms|1ms)
 60ms (59ms|1ms)
 48ms (47ms|1ms)
 50ms (48ms|2ms)
 53ms (52ms|1ms)
 42ms (41ms|1ms)
 Context branch precedence and check ordering (AC-5, AC-7)
 42ms (40ms|2ms)
 64ms (63ms|2ms)
 Context Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)
 38ms (4ms|34ms)
 21ms (4ms|17ms)
 7ms (6ms|2ms)
 6ms (5ms|1ms)
 Context real Test-Path parallel read seam (AC-9)
 23ms (21ms|2ms)
 35ms (33ms|1ms)

Describing enforce-epic-worktree-removal-gate.ps1 manifest branch
 105ms (103ms|2ms)
 40ms (39ms|1ms)
 67ms (66ms|1ms)
 29ms (29ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-worktree-removal-gate trigger scoping (issue #545)
 Context under-match removal - a relocating spelling is now in scope
 56ms (42ms|14ms)
 Context operand resolution - the --force flag never becomes the path
 10ms (9ms|1ms)
 8ms (8ms|1ms)
 Context over-match removal and scope narrowing
 19ms (18ms|1ms)
 17ms (16ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing epic worktree-removal gate run-target resolution
 98ms (96ms|1ms)
 40ms (40ms|0ms)
 38ms (38ms|1ms)
 50ms (49ms|1ms)
 35ms (35ms|1ms)
 13ms (12ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1
 Context commands outside scope are allowed unconditionally
 13ms (11ms|2ms)
 9ms (8ms|1ms)
 11ms (10ms|1ms)
 10ms (9ms|1ms)
 10ms (9ms|1ms)
 8ms (8ms|1ms)
 Context allow when the matched item merge_status is terminal
 60ms (59ms|1ms)
 30ms (29ms|1ms)
 29ms (29ms|1ms)
 Context deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status
 31ms (29ms|1ms)
 27ms (26ms|1ms)
 26ms (25ms|1ms)
 27ms (26ms|1ms)
 26ms (25ms|1ms)
 25ms (24ms|1ms)
 24ms (23ms|1ms)
 Context deny fail-closed on an unusable checkpoint or an unmatched path
 32ms (31ms|1ms)
 24ms (23ms|1ms)
 25ms (24ms|1ms)
 27ms (26ms|1ms)
 Context read seam binding (the mocked seam value determines the decision)
 46ms (45ms|1ms)
 30ms (30ms|1ms)
 16ms (15ms|1ms)
 Context path normalization
 35ms (34ms|1ms)
 26ms (26ms|1ms)
 26ms (26ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the parallel gate
 11ms (9ms|1ms)
 12ms (11ms|1ms)
 Context Find-ParallelWorktreeItemRecord helper
 7ms (6ms|2ms)
 11ms (10ms|1ms)
 6ms (5ms|1ms)
 8ms (7ms|1ms)
 11ms (10ms|1ms)
 Context Test-ParallelWorktreeRemovalAllowed helper
 9ms (7ms|1ms)
 7ms (7ms|1ms)
 10ms (9ms|1ms)
 Context real Test-Path read seam
 18ms (17ms|1ms)
 26ms (25ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 24ms (23ms|1ms)
 15ms (14ms|1ms)
 15ms (14ms|1ms)
 11ms (10ms|1ms)
 11ms (10ms|1ms)
 32ms (31ms|1ms)
 33ms (33ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest branch
 47ms (45ms|2ms)
 38ms (37ms|1ms)
 34ms (34ms|1ms)
 17ms (16ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1 epic authorization
 Context epic authorization branch (issue #688)
 45ms (43ms|2ms)
 28ms (27ms|1ms)
 25ms (25ms|1ms)
 29ms (29ms|1ms)
 26ms (26ms|1ms)
 25ms (24ms|1ms)
 27ms (27ms|1ms)
 33ms (32ms|1ms)
 27ms (26ms|1ms)
 28ms (27ms|1ms)
 33ms (33ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate trigger scoping (issue #545)
 Context operand resolution - the --force flag never becomes the path
 14ms (11ms|3ms)
 Context under-match removal - a relocating spelling is now in scope
 41ms (39ms|2ms)
 Context over-match removal - a quoted mention is not an invocation
 32ms (30ms|2ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 73ms (72ms|2ms)
 70ms (69ms|1ms)
 52ms (51ms|1ms)
 56ms (55ms|1ms)
 54ms (53ms|1ms)
 12ms (11ms|1ms)
 56ms (55ms|1ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 49ms (48ms|2ms)
 42ms (41ms|1ms)
 35ms (34ms|1ms)
 38ms (37ms|1ms)
 40ms (37ms|3ms)
 36ms (36ms|1ms)
 46ms (45ms|1ms)
 37ms (36ms|1ms)
 31ms (30ms|1ms)
 33ms (32ms|1ms)
 36ms (36ms|1ms)
 34ms (33ms|1ms)
 36ms (35ms|1ms)
 34ms (33ms|1ms)
 36ms (35ms|1ms)
 33ms (32ms|1ms)
 38ms (37ms|1ms)
 46ms (45ms|1ms)
 38ms (37ms|1ms)
 40ms (39ms|1ms)
 35ms (34ms|1ms)
 36ms (35ms|1ms)
 32ms (32ms|1ms)
 30ms (29ms|1ms)
 33ms (32ms|1ms)
 27ms (27ms|1ms)
 25ms (24ms|1ms)
 26ms (25ms|1ms)
 24ms (23ms|1ms)
 26ms (25ms|1ms)
 26ms (26ms|1ms)
 22ms (22ms|1ms)
 33ms (33ms|1ms)
 22ms (21ms|1ms)
 29ms (28ms|1ms)
 24ms (24ms|1ms)
 31ms (30ms|1ms)
 32ms (31ms|1ms)
 33ms (32ms|1ms)
 57ms (57ms|1ms)
 58ms (57ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 27ms (26ms|1ms)
 25ms (25ms|1ms)
 22ms (22ms|1ms)
 22ms (21ms|1ms)
 29ms (28ms|1ms)
 22ms (22ms|1ms)
 25ms (24ms|1ms)
 28ms (27ms|1ms)
 18ms (18ms|1ms)
 28ms (27ms|1ms)
 33ms (32ms|1ms)
 34ms (33ms|1ms)
 30ms (29ms|1ms)
 32ms (32ms|1ms)
 33ms (32ms|1ms)
 29ms (28ms|1ms)
 25ms (24ms|1ms)
 24ms (24ms|1ms)
 29ms (28ms|1ms)
 36ms (34ms|1ms)
 34ms (33ms|1ms)
 29ms (28ms|1ms)
 38ms (37ms|1ms)
 33ms (32ms|1ms)
 32ms (31ms|1ms)
 34ms (33ms|1ms)
 27ms (26ms|1ms)
 22ms (21ms|1ms)
 28ms (28ms|1ms)
 29ms (28ms|1ms)
 23ms (23ms|1ms)
 27ms (26ms|1ms)
 27ms (27ms|1ms)
 22ms (21ms|1ms)
 25ms (24ms|1ms)
 21ms (21ms|1ms)
 28ms (27ms|1ms)
 29ms (28ms|1ms)
 29ms (28ms|1ms)
 43ms (42ms|1ms)
 71ms (70ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 52ms (50ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 30ms (28ms|2ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 49ms (48ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 36ms (35ms|2ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 21ms (19ms|2ms)
 Context AT-6 - the wrapper deny pin
 83ms (82ms|2ms)
 Context AT-7 - the cross-runtime operand divergence
 9ms (8ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 11ms (9ms|1ms)
 8ms (7ms|1ms)
 6ms (6ms|1ms)
 13ms (12ms|1ms)
Tests completed in 11.75s
Tests Passed: 224, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=224
PassedCount=224
FailedCount=0
```
