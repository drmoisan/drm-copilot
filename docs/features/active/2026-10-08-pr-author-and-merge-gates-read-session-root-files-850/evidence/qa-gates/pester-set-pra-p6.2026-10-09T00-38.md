# P6-T21 SET-PRA after Phase 6 (includes T-PRA-IAR), run 1

Timestamp: 2026-10-09T00-38
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1,tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=262
  PassedCount=262
  FailedCount=0

## Full output

```text
Pester v5.6.1

Starting discovery in 14 files.
Discovery found 262 tests in 760ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1'
Describing enforce-pr-author-skill.ps1
 Context tool input parsing
 211ms (140ms|71ms)
 19ms (17ms|2ms)
 14ms (13ms|1ms)
 Context gh pr create - inline body (Case A)
 122ms (121ms|1ms)
 53ms (52ms|1ms)
 Context gh pr edit - inline body (Case A)
 40ms (39ms|1ms)
 25ms (24ms|1ms)
 30ms (29ms|1ms)
 Context gh pr create - missing body (Case B)
 22ms (21ms|1ms)
 37ms (36ms|1ms)
 Context gh pr create/edit - missing context artifact (Case C)
 108ms (107ms|1ms)
 22ms (21ms|1ms)
 Context allowed commands
 108ms (107ms|1ms)
 68ms (67ms|0ms)
 41ms (40ms|1ms)
 40ms (39ms|1ms)
 30ms (29ms|1ms)
 43ms (42ms|1ms)
 41ms (40ms|1ms)
 44ms (43ms|1ms)
 40ms (39ms|1ms)
 Context receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)
 81ms (75ms|6ms)
 Context receipt - missing (PR_AUTHOR_RECEIPT_MISSING)
 95ms (93ms|2ms)
 Context receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)
 89ms (87ms|2ms)
 Context receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)
 93ms (91ms|2ms)
 Context receipt - stale (PR_AUTHOR_RECEIPT_STALE)
 79ms (77ms|2ms)
 Context receipt - all checks pass (allow)
 90ms (89ms|2ms)
 Context Get-PrAuthorBypassReason helper
 85ms (83ms|1ms)
 26ms (25ms|1ms)
 37ms (37ms|1ms)
 Context decision builders emit the PreToolUse schema
 14ms (12ms|1ms)
 8ms (7ms|1ms)
 Context Test-PrAuthorBypassRequired helper
 93ms (92ms|2ms)
 33ms (32ms|1ms)
 48ms (48ms|1ms)
 Context Get-PrContextArtifactExistence real Test-Path wrapper
 27ms (26ms|2ms)
 Context Get-PrBodyFileBytes real read seam
 9ms (8ms|1ms)
 217ms (216ms|1ms)
 Context Get-PrAuthorReceiptContent real read seam
 8ms (7ms|1ms)
 14ms (13ms|1ms)
 Context Get-PrContextSummaryLastWriteUtc real seam
 8ms (6ms|1ms)
 18ms (17ms|1ms)
 Context Invoke-PrAuthorSkillDecision without mock (real context lookup)
 35ms (33ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1'
Describing enforce-pr-author-skill.ps1 epic scope (issue #663)
 172ms (170ms|2ms)
 74ms (73ms|1ms)
 68ms (67ms|1ms)
 93ms (92ms|1ms)
 112ms (112ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1'
Describing enforce-pr-author-skill.ps1 (orchestrator-state preflight)
 Context orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)
 47ms (45ms|2ms)
 36ms (35ms|1ms)
 Context script entrypoint (end-to-end)
 775ms (774ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1'
Describing enforce-pr-author-skill.ps1 payload envelope
 Context entry-point exit code and emitted decision (AC-4, no child process)
 17ms (15ms|1ms)
 8ms (7ms|1ms)
 8ms (7ms|1ms)
 11ms (11ms|1ms)
 7ms (7ms|1ms)
 7ms (6ms|1ms)
 Context nested envelope reaches the existing decision logic (AC-7)
 17ms (16ms|1ms)
 11ms (11ms|1ms)
 8ms (7ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 target resolution
 Context the checkpoint is taken from the resolved target, not the session root
 425ms (423ms|1ms)
 357ms (357ms|1ms)
 Context an underivable target denies instead of answering from unrelated state
 24ms (23ms|1ms)
 340ms (339ms|0ms)
 22ms (22ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1'
Describing enforce-pr-author-skill trigger scoping (issue #545)
 Context over-match removal - a quoted mention is not an invocation
 17ms (16ms|1ms)
 Context under-match removal - a relocating spelling now classifies
 35ms (34ms|1ms)
 24ms (24ms|0ms)
 Context flag distinction - --body does not match --body-file
 30ms (29ms|1ms)
 Context wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test
 45ms (42ms|3ms)
 28ms (28ms|0ms)
 35ms (35ms|0ms)
 18ms (18ms|0ms)
 70ms (70ms|0ms)
 39ms (38ms|1ms)
 33ms (33ms|1ms)
 Context every PR_* reason code is still produced for its genuine triggering invocation
 39ms (38ms|1ms)
 35ms (35ms|0ms)
 46ms (46ms|0ms)
 44ms (43ms|1ms)
 55ms (54ms|1ms)
 50ms (50ms|0ms)
 50ms (50ms|1ms)
 Context R-2.c wrapper-led body flags
 30ms (29ms|1ms)
 38ms (38ms|1ms)
 28ms (27ms|1ms)
 20ms (19ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 worktree-resolution matrix
 558ms (557ms|1ms)
 345ms (345ms|0ms)
 20ms (19ms|0ms)
 315ms (315ms|0ms)
 319ms (318ms|0ms)
 312ms (311ms|0ms)
 365ms (364ms|0ms)
 19ms (19ms|0ms)
 258ms (258ms|0ms)
 235ms (234ms|0ms)
 198ms (198ms|0ms)
 218ms (218ms|0ms)
 221ms (221ms|0ms)
 12ms (12ms|0ms)
 277ms (276ms|0ms)
 183ms (182ms|1ms)
 195ms (194ms|0ms)
 289ms (289ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1'
Describing enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride
 Context epic_mode is false or absent (no-op/allow)
 11ms (10ms|1ms)
 10ms (9ms|0ms)
 7ms (7ms|0ms)
 Context epic_mode is true with the correct --base (allow)
 15ms (14ms|1ms)
 Context epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)
 18ms (18ms|1ms)
 Context epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)
 16ms (15ms|1ms)
 13ms (12ms|0ms)
 Context end-to-end via Invoke-PrAuthorSkillDecision (sixth check wired into the receipt path)
 59ms (59ms|1ms)
 48ms (48ms|0ms)
 Context issue #663 epic scope
 67ms (66ms|1ms)
 54ms (54ms|0ms)
 53ms (52ms|0ms)
 45ms (45ms|0ms)
 59ms (59ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1'
Describing Test-EpicBaseBranchOverride trigger scoping (issue #545)
 Context under-match removal - a relocating spelling now classifies
 13ms (13ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 5ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
 51ms (50ms|1ms)
 Context rejection conditions
 11ms (10ms|1ms)
 15ms (15ms|0ms)
 12ms (12ms|0ms)
 9ms (8ms|0ms)
 11ms (11ms|0ms)
 22ms (22ms|0ms)
 11ms (11ms|0ms)
 Context fail-closed conditions
 7ms (6ms|1ms)
 9ms (8ms|0ms)
 9ms (8ms|0ms)
 10ms (10ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 Context default invoker (portable path is the only path)
 130ms (129ms|1ms)
 29ms (28ms|0ms)
 16ms (16ms|0ms)
 15ms (15ms|0ms)
 13ms (13ms|0ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
 8ms (6ms|2ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 Context per-key extra statuses rejected on every non-owning key
 5ms (4ms|1ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 4ms (4ms|0ms)
 Context epic-merge-gate regression scenario
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1'
Describing gate suites isolate the epic checkpoint read (structural guard)
 45ms (44ms|1ms)
 16ms (16ms|0ms)
 9ms (8ms|0ms)
 13ms (13ms|0ms)
 7ms (6ms|0ms)
 19ms (19ms|0ms)
 6ms (6ms|0ms)
 7ms (7ms|0ms)
 8ms (8ms|0ms)
 Context guard predicate discrimination
 7ms (6ms|1ms)
 4ms (3ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)

Describing the run-checkpoint mocks block the epic-state read (seam sufficiency)
 47ms (46ms|2ms)
 18ms (17ms|0ms)
 36ms (35ms|0ms)
 15ms (15ms|0ms)
 24ms (24ms|0ms)
 16ms (15ms|0ms)
 23ms (22ms|0ms)
 21ms (21ms|0ms)
 19ms (18ms|0ms)
 18ms (17ms|0ms)
 15ms (15ms|0ms)
 34ms (33ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1'
Describing enforce-pr-author-skill issue #824 decisions
 Context commands that mention gh pr create without invoking it
 24ms (23ms|1ms)
 19ms (19ms|0ms)
 14ms (13ms|0ms)
 17ms (16ms|0ms)
 18ms (17ms|0ms)
 Context body-file normalization and receipt verification
 191ms (189ms|1ms)
 218ms (218ms|0ms)
 201ms (201ms|0ms)
 192ms (192ms|0ms)
 204ms (203ms|0ms)
 169ms (168ms|0ms)
 138ms (137ms|0ms)
 170ms (170ms|0ms)
 168ms (168ms|0ms)
 162ms (161ms|0ms)
 34ms (33ms|0ms)
 31ms (30ms|0ms)
 Context inline-body and no-body pull requests
 10ms (9ms|1ms)
 7ms (6ms|0ms)
 6ms (6ms|0ms)
 14ms (14ms|0ms)
 10ms (9ms|0ms)
 62ms (62ms|0ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1'
Describing Issue #824 regression: promotion gate (claude)
 26ms (25ms|1ms)

Describing Issue #824 regression: promotion gate (codex)
 48ms (48ms|1ms)

Describing Issue #824 regression: Claude epic worktree-removal gate
 21ms (20ms|1ms)
 12ms (11ms|0ms)

Describing Issue #824 regression: Claude parallel worktree-removal gate
 21ms (20ms|1ms)
 10ms (9ms|0ms)

Describing Issue #824 regression: Codex epic worktree-removal gate
 27ms (26ms|1ms)
 4ms (3ms|0ms)

Describing Issue #824 regression: preimplementation gate (claude)
 12ms (11ms|1ms)

Describing Issue #824 regression: preimplementation gate (codex)
 10ms (9ms|1ms)

Describing Issue #824 regression: Claude pr-author skill gate
 Context commands that mention gh pr create without invoking it (R-733-714, R-733-GREP)
 14ms (13ms|1ms)
 25ms (25ms|0ms)
 10ms (10ms|0ms)
 7ms (7ms|0ms)
 Context body-file spellings reach receipt verification (R-733-715)
 11ms (11ms|1ms)
 10ms (9ms|0ms)
 12ms (12ms|0ms)
 9ms (9ms|0ms)
 8ms (8ms|0ms)

Describing Issue #824 regression: pr-author command allowlist
 14ms (13ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 4ms (3ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1'
Describing enforce-pr-author-skill.ps1 item artifact root
 249ms (248ms|1ms)
 208ms (208ms|0ms)
 246ms (245ms|0ms)
 206ms (205ms|0ms)
 192ms (191ms|0ms)
 157ms (156ms|0ms)
 173ms (172ms|0ms)
 194ms (194ms|0ms)
 183ms (182ms|0ms)
 577ms (576ms|0ms)
 194ms (194ms|0ms)
 54ms (54ms|0ms)
 30ms (30ms|0ms)
 30ms (30ms|0ms)
 168ms (168ms|0ms)
Tests completed in 21.37s
Tests Passed: 262, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=262
PassedCount=262
FailedCount=0
```
