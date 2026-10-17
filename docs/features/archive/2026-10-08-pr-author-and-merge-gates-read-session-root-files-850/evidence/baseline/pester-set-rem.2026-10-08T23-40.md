# P0-T19 Pester baseline SET-REM

Timestamp: 2026-10-08T23-40
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=223
  PassedCount=223
  FailedCount=0
  BASE_REM: 223
  A18 (copied verbatim from evidence/baseline/pester-set-pra.2026-10-08T23-39.md; not re-run):
  DECISION=deny
  REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
  DECISION-WITHOUT-CHECKPOINT=allow
  Rule EE: applied; SET-REM contains no EE-ROWS suite, so nothing is exempt (no ENV-EPIC-FAILED line).
  Baseline failure set: empty
  Baseline container set: empty
  BASELINE-RED-IN-EDITED-SUITE: not triggered

## Full output

```text
Pester v5.6.1

Starting discovery in 9 files.
Discovery found 223 tests in 441ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1
 Context commands outside scope
 68ms (49ms|20ms)
 35ms (34ms|1ms)
 82ms (81ms|0ms)
 11ms (11ms|0ms)
 Context allow on merge_status merged
 89ms (88ms|1ms)
 Context allow on merge_status worktree_removed
 15ms (14ms|1ms)
 Context deny on unreadable checkpoint
 53ms (52ms|1ms)
 23ms (23ms|0ms)
 Context deny on no matching record
 35ms (34ms|1ms)
 Context deny on other merge_status
 25ms (23ms|2ms)
 Context path normalization
 18ms (17ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the epic gate
 6ms (5ms|1ms)
 6ms (4ms|3ms)
 Context Find-EpicWorktreeFeatureRecord helper
 9ms (8ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Test-EpicWorktreeRemovalAllowed helper
 5ms (4ms|1ms)
 2ms (2ms|0ms)
 Context real Test-Path read seam
 54ms (53ms|1ms)
 34ms (34ms|0ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 21ms (20ms|1ms)
 10ms (9ms|0ms)
 9ms (9ms|0ms)
 10ms (9ms|0ms)
 9ms (8ms|0ms)
 36ms (36ms|0ms)
 22ms (21ms|0ms)
 Context parallel branch allow (AC-1, AC-2, AC-3)
 32ms (30ms|1ms)
 24ms (23ms|1ms)
 22ms (21ms|1ms)
 Context parallel branch fail-closed deny (AC-4)
 29ms (28ms|1ms)
 35ms (34ms|1ms)
 38ms (37ms|1ms)
 59ms (59ms|1ms)
 38ms (37ms|1ms)
 62ms (61ms|1ms)
 52ms (50ms|2ms)
 47ms (46ms|1ms)
 Context branch precedence and check ordering (AC-5, AC-7)
 44ms (42ms|2ms)
 60ms (59ms|1ms)
 Context Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)
 6ms (4ms|2ms)
 6ms (4ms|1ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 Context real Test-Path parallel read seam (AC-9)
 18ms (16ms|2ms)
 33ms (32ms|1ms)

Describing enforce-epic-worktree-removal-gate.ps1 manifest branch
 96ms (94ms|2ms)
 49ms (48ms|1ms)
 68ms (67ms|1ms)
 29ms (28ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-worktree-removal-gate trigger scoping (issue #545)
 Context under-match removal - a relocating spelling is now in scope
 40ms (37ms|4ms)
 Context operand resolution - the --force flag never becomes the path
 8ms (7ms|1ms)
 8ms (8ms|1ms)
 Context over-match removal and scope narrowing
 26ms (24ms|2ms)
 15ms (15ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing epic worktree-removal gate run-target resolution
 113ms (112ms|1ms)
 72ms (71ms|1ms)
 42ms (41ms|1ms)
 45ms (44ms|1ms)
 34ms (33ms|1ms)
 9ms (8ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1
 Context commands outside scope are allowed unconditionally
 12ms (10ms|2ms)
 8ms (7ms|1ms)
 10ms (10ms|1ms)
 13ms (12ms|1ms)
 11ms (10ms|1ms)
 9ms (8ms|1ms)
 Context allow when the matched item merge_status is terminal
 49ms (48ms|1ms)
 24ms (23ms|1ms)
 27ms (27ms|1ms)
 Context deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status
 31ms (30ms|1ms)
 27ms (27ms|1ms)
 27ms (26ms|1ms)
 31ms (31ms|1ms)
 36ms (35ms|1ms)
 37ms (36ms|1ms)
 39ms (38ms|1ms)
 Context deny fail-closed on an unusable checkpoint or an unmatched path
 44ms (42ms|2ms)
 37ms (36ms|1ms)
 37ms (36ms|1ms)
 37ms (36ms|1ms)
 Context read seam binding (the mocked seam value determines the decision)
 55ms (54ms|2ms)
 35ms (34ms|1ms)
 19ms (18ms|1ms)
 Context path normalization
 34ms (32ms|2ms)
 25ms (25ms|1ms)
 24ms (23ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the parallel gate
 12ms (11ms|2ms)
 9ms (9ms|1ms)
 Context Find-ParallelWorktreeItemRecord helper
 6ms (5ms|1ms)
 9ms (8ms|1ms)
 6ms (6ms|1ms)
 7ms (7ms|1ms)
 8ms (8ms|1ms)
 Context Test-ParallelWorktreeRemovalAllowed helper
 7ms (6ms|2ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 Context real Test-Path read seam
 17ms (15ms|1ms)
 26ms (25ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 22ms (20ms|1ms)
 10ms (10ms|1ms)
 11ms (10ms|1ms)
 10ms (10ms|1ms)
 9ms (9ms|1ms)
 27ms (27ms|1ms)
 28ms (27ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest branch
 32ms (30ms|1ms)
 24ms (23ms|1ms)
 29ms (28ms|1ms)
 14ms (13ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1 epic authorization
 Context epic authorization branch (issue #688)
 31ms (29ms|2ms)
 26ms (25ms|1ms)
 26ms (25ms|1ms)
 29ms (28ms|1ms)
 26ms (25ms|1ms)
 22ms (22ms|1ms)
 23ms (22ms|1ms)
 26ms (25ms|1ms)
 26ms (25ms|1ms)
 26ms (25ms|1ms)
 36ms (35ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate trigger scoping (issue #545)
 Context operand resolution - the --force flag never becomes the path
 8ms (6ms|2ms)
 Context under-match removal - a relocating spelling is now in scope
 23ms (22ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 21ms (20ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 44ms (43ms|1ms)
 45ms (44ms|1ms)
 38ms (37ms|1ms)
 36ms (36ms|1ms)
 30ms (29ms|1ms)
 8ms (8ms|1ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 39ms (38ms|1ms)
 38ms (37ms|1ms)
 43ms (42ms|1ms)
 41ms (40ms|1ms)
 47ms (46ms|1ms)
 57ms (56ms|1ms)
 47ms (46ms|1ms)
 52ms (51ms|1ms)
 44ms (43ms|1ms)
 50ms (48ms|1ms)
 52ms (51ms|1ms)
 43ms (42ms|1ms)
 43ms (41ms|1ms)
 43ms (42ms|1ms)
 41ms (40ms|1ms)
 51ms (49ms|1ms)
 43ms (42ms|1ms)
 45ms (44ms|1ms)
 45ms (44ms|1ms)
 45ms (44ms|1ms)
 39ms (37ms|1ms)
 33ms (32ms|1ms)
 43ms (42ms|1ms)
 50ms (48ms|2ms)
 40ms (39ms|1ms)
 34ms (33ms|1ms)
 37ms (36ms|1ms)
 28ms (27ms|1ms)
 42ms (41ms|1ms)
 29ms (29ms|1ms)
 33ms (32ms|1ms)
 28ms (27ms|1ms)
 33ms (32ms|1ms)
 29ms (28ms|1ms)
 37ms (37ms|1ms)
 64ms (63ms|1ms)
 65ms (64ms|2ms)
 39ms (38ms|1ms)
 40ms (39ms|1ms)
 63ms (62ms|1ms)
 68ms (67ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 35ms (33ms|2ms)
 29ms (28ms|1ms)
 32ms (32ms|1ms)
 24ms (23ms|1ms)
 20ms (19ms|1ms)
 21ms (20ms|1ms)
 22ms (21ms|1ms)
 19ms (19ms|1ms)
 26ms (25ms|1ms)
 18ms (18ms|1ms)
 20ms (19ms|1ms)
 23ms (22ms|1ms)
 27ms (26ms|1ms)
 26ms (25ms|1ms)
 26ms (25ms|1ms)
 19ms (18ms|1ms)
 21ms (21ms|1ms)
 22ms (21ms|1ms)
 24ms (23ms|1ms)
 20ms (19ms|1ms)
 22ms (22ms|1ms)
 22ms (22ms|1ms)
 20ms (19ms|1ms)
 27ms (26ms|1ms)
 24ms (23ms|1ms)
 19ms (18ms|1ms)
 30ms (29ms|1ms)
 21ms (21ms|1ms)
 20ms (20ms|1ms)
 23ms (22ms|1ms)
 24ms (23ms|1ms)
 19ms (18ms|1ms)
 29ms (28ms|1ms)
 18ms (18ms|1ms)
 22ms (21ms|1ms)
 28ms (27ms|1ms)
 20ms (20ms|1ms)
 22ms (21ms|1ms)
 25ms (24ms|1ms)
 38ms (37ms|1ms)
 42ms (41ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 26ms (25ms|1ms)
 Context AT-2 - the issue #591 operand mis-parse
 22ms (21ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 38ms (38ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 29ms (28ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 11ms (10ms|1ms)
 Context AT-6 - the wrapper deny pin
 78ms (77ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 7ms (6ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 9ms (8ms|1ms)
 5ms (5ms|1ms)
 5ms (4ms|1ms)
 10ms (9ms|1ms)
Tests completed in 9.73s
Tests Passed: 223, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=223
PassedCount=223
FailedCount=0
```
