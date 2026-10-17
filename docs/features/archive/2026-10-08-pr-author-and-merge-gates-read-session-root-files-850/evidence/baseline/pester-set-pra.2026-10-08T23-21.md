# P0-T17 Pester baseline SET-PRA

Timestamp: 2026-10-08T23-21
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1,tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 1, 
  TotalCount=247
  PassedCount=246
  FailedCount=1
  FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1

## Full output

```text
Pester v5.6.1

Starting discovery in 13 files.
Discovery found 247 tests in 718ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1'
Describing enforce-pr-author-skill.ps1
 Context tool input parsing
 211ms (185ms|26ms)
 19ms (17ms|2ms)
 15ms (14ms|1ms)
 Context gh pr create - inline body (Case A)
 196ms (195ms|1ms)
 63ms (62ms|1ms)
 Context gh pr edit - inline body (Case A)
 32ms (30ms|1ms)
 29ms (28ms|1ms)
 33ms (32ms|1ms)
 Context gh pr create - missing body (Case B)
 26ms (25ms|1ms)
 57ms (57ms|1ms)
 Context gh pr create/edit - missing context artifact (Case C)
 66ms (64ms|2ms)
 66ms (64ms|2ms)
 Context allowed commands
   [-] allows gh pr create --body-file artifacts/pr_body_12.md when context exists
 391ms (387ms|4ms)
    at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:154
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:154
    Expected strings to be the same, but they were different.
    Expected length: 5
    Actual length:   4
    Strings differ at index 0.
    Expected: 'allow'
    But was:  'deny'
               ^
 151ms (150ms|1ms)
 84ms (83ms|1ms)
 99ms (98ms|2ms)
 52ms (51ms|1ms)
 45ms (44ms|1ms)
 53ms (52ms|1ms)
 64ms (63ms|1ms)
 46ms (45ms|1ms)
 Context receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)
 80ms (78ms|2ms)
 Context receipt - missing (PR_AUTHOR_RECEIPT_MISSING)
 86ms (84ms|2ms)
 Context receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)
 61ms (59ms|1ms)
 Context receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)
 68ms (66ms|2ms)
 Context receipt - stale (PR_AUTHOR_RECEIPT_STALE)
 78ms (76ms|1ms)
 Context receipt - all checks pass (allow)
 117ms (115ms|2ms)
 Context Get-PrAuthorBypassReason helper
 104ms (102ms|2ms)
 38ms (37ms|1ms)
 44ms (43ms|1ms)
 Context decision builders emit the PreToolUse schema
 17ms (15ms|2ms)
 13ms (12ms|1ms)
 Context Test-PrAuthorBypassRequired helper
 67ms (66ms|1ms)
 40ms (39ms|1ms)
 38ms (37ms|1ms)
 Context Get-PrContextArtifactExistence real Test-Path wrapper
 28ms (26ms|2ms)
 Context Get-PrBodyFileBytes real read seam
 12ms (10ms|2ms)
 300ms (298ms|2ms)
 Context Get-PrAuthorReceiptContent real read seam
 14ms (11ms|3ms)
 28ms (27ms|1ms)
 Context Get-PrContextSummaryLastWriteUtc real seam
 12ms (10ms|2ms)
 26ms (25ms|1ms)
 Context Invoke-PrAuthorSkillDecision without mock (real context lookup)
 48ms (46ms|2ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1'
Describing enforce-pr-author-skill.ps1 epic scope (issue #663)
 242ms (239ms|2ms)
 95ms (95ms|1ms)
 86ms (85ms|1ms)
 115ms (114ms|1ms)
 167ms (167ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1'
Describing enforce-pr-author-skill.ps1 (orchestrator-state preflight)
 Context orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)
 56ms (54ms|2ms)
 52ms (51ms|1ms)
 Context script entrypoint (end-to-end)
 1.08s (1.08s|2ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1'
Describing enforce-pr-author-skill.ps1 payload envelope
 Context entry-point exit code and emitted decision (AC-4, no child process)
 20ms (18ms|2ms)
 9ms (8ms|1ms)
 9ms (8ms|1ms)
 7ms (7ms|1ms)
 7ms (7ms|1ms)
 8ms (7ms|1ms)
 Context nested envelope reaches the existing decision logic (AC-7)
 25ms (24ms|1ms)
 17ms (16ms|1ms)
 9ms (8ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 target resolution
 Context the checkpoint is taken from the resolved target, not the session root
 469ms (467ms|2ms)
 341ms (340ms|1ms)
 Context an underivable target denies instead of answering from unrelated state
 23ms (22ms|1ms)
 309ms (308ms|0ms)
 22ms (21ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1'
Describing enforce-pr-author-skill trigger scoping (issue #545)
 Context over-match removal - a quoted mention is not an invocation
 23ms (21ms|1ms)
 Context under-match removal - a relocating spelling now classifies
 30ms (29ms|1ms)
 28ms (27ms|1ms)
 Context flag distinction - --body does not match --body-file
 34ms (33ms|1ms)
 Context wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test
 46ms (45ms|1ms)
 28ms (28ms|1ms)
 27ms (26ms|1ms)
 27ms (26ms|1ms)
 71ms (71ms|1ms)
 51ms (50ms|1ms)
 35ms (34ms|1ms)
 Context every PR_* reason code is still produced for its genuine triggering invocation
 33ms (32ms|1ms)
 30ms (30ms|1ms)
 42ms (41ms|0ms)
 46ms (37ms|9ms)
 41ms (40ms|0ms)
 43ms (42ms|1ms)
 42ms (42ms|0ms)
 Context R-2.c wrapper-led body flags
 23ms (23ms|1ms)
 32ms (32ms|0ms)
 22ms (22ms|0ms)
 16ms (15ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 worktree-resolution matrix
 1.12s (1.12s|1ms)
 491ms (491ms|1ms)
 31ms (31ms|0ms)
 419ms (418ms|1ms)
 293ms (292ms|0ms)
 323ms (322ms|0ms)
 481ms (480ms|1ms)
 33ms (33ms|1ms)
 418ms (417ms|1ms)
 352ms (349ms|3ms)
 250ms (250ms|0ms)
 224ms (223ms|0ms)
 189ms (189ms|0ms)
 11ms (11ms|0ms)
 227ms (227ms|0ms)
 211ms (211ms|0ms)
 204ms (204ms|0ms)
 384ms (384ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1'
Describing enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride
 Context epic_mode is false or absent (no-op/allow)
 19ms (18ms|1ms)
 17ms (16ms|1ms)
 12ms (11ms|1ms)
 Context epic_mode is true with the correct --base (allow)
 27ms (26ms|1ms)
 Context epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)
 19ms (18ms|1ms)
 Context epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)
 21ms (20ms|1ms)
 16ms (15ms|1ms)
 Context end-to-end via Invoke-PrAuthorSkillDecision (sixth check wired into the receipt path)
 75ms (73ms|1ms)
 77ms (77ms|0ms)
 Context issue #663 epic scope
 83ms (82ms|1ms)
 63ms (63ms|0ms)
 75ms (74ms|0ms)
 59ms (59ms|0ms)
 52ms (52ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1'
Describing Test-EpicBaseBranchOverride trigger scoping (issue #545)
 Context under-match removal - a relocating spelling now classifies
 16ms (15ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 7ms (6ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
 51ms (50ms|1ms)
 Context rejection conditions
 12ms (11ms|1ms)
 19ms (19ms|0ms)
 13ms (12ms|0ms)
 15ms (14ms|0ms)
 15ms (14ms|1ms)
 19ms (18ms|1ms)
 12ms (11ms|1ms)
 Context fail-closed conditions
 9ms (9ms|1ms)
 9ms (9ms|0ms)
 9ms (9ms|1ms)
 22ms (21ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
 5ms (4ms|2ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 Context default invoker (portable path is the only path)
 132ms (131ms|1ms)
 33ms (33ms|0ms)
 18ms (17ms|1ms)
 27ms (26ms|1ms)
 15ms (14ms|0ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
 9ms (6ms|2ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 3ms (3ms|0ms)
 Context per-key extra statuses rejected on every non-owning key
 6ms (5ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 6ms (6ms|0ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 6ms (5ms|0ms)
 3ms (2ms|1ms)
 Context epic-merge-gate regression scenario
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1'
Describing gate suites isolate the epic checkpoint read (structural guard)
 47ms (46ms|1ms)
 17ms (17ms|0ms)
 9ms (8ms|0ms)
 15ms (15ms|0ms)
 10ms (9ms|1ms)
 25ms (24ms|1ms)
 9ms (8ms|1ms)
 12ms (12ms|1ms)
 Context guard predicate discrimination
 12ms (11ms|1ms)
 6ms (5ms|1ms)
 9ms (8ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 7ms (6ms|1ms)
 7ms (7ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 13ms (12ms|1ms)
 7ms (6ms|1ms)
 6ms (5ms|1ms)
 4ms (4ms|1ms)

Describing the run-checkpoint mocks block the epic-state read (seam sufficiency)
 75ms (73ms|2ms)
 42ms (41ms|1ms)
 45ms (44ms|1ms)
 37ms (37ms|1ms)
 41ms (40ms|1ms)
 36ms (36ms|1ms)
 36ms (36ms|1ms)
 34ms (34ms|1ms)
 37ms (36ms|1ms)
 31ms (30ms|1ms)
 36ms (35ms|1ms)
 32ms (31ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1'
Describing enforce-pr-author-skill issue #824 decisions
 Context commands that mention gh pr create without invoking it
 22ms (21ms|1ms)
 24ms (23ms|1ms)
 19ms (18ms|1ms)
 15ms (15ms|0ms)
 14ms (13ms|0ms)
 Context body-file normalization and receipt verification
 166ms (165ms|1ms)
 199ms (198ms|0ms)
 310ms (309ms|0ms)
 165ms (164ms|0ms)
 224ms (223ms|1ms)
 182ms (181ms|0ms)
 217ms (217ms|0ms)
 168ms (168ms|0ms)
 168ms (168ms|0ms)
 185ms (185ms|0ms)
 53ms (53ms|0ms)
 31ms (30ms|1ms)
 Context inline-body and no-body pull requests
 21ms (18ms|2ms)
 14ms (13ms|1ms)
 18ms (17ms|1ms)
 29ms (28ms|1ms)
 18ms (18ms|1ms)
 128ms (127ms|1ms)
 Context body-file root seam
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1'
Describing Issue #824 regression: promotion gate (claude)
 36ms (35ms|1ms)

Describing Issue #824 regression: promotion gate (codex)
 66ms (65ms|1ms)

Describing Issue #824 regression: Claude epic worktree-removal gate
 43ms (42ms|1ms)
 9ms (9ms|1ms)

Describing Issue #824 regression: Claude parallel worktree-removal gate
 19ms (18ms|1ms)
 10ms (10ms|0ms)

Describing Issue #824 regression: Codex epic worktree-removal gate
 23ms (22ms|1ms)
 5ms (4ms|0ms)

Describing Issue #824 regression: preimplementation gate (claude)
 26ms (25ms|1ms)

Describing Issue #824 regression: preimplementation gate (codex)
 11ms (10ms|1ms)

Describing Issue #824 regression: Claude pr-author skill gate
 Context commands that mention gh pr create without invoking it (R-733-714, R-733-GREP)
 30ms (29ms|1ms)
 15ms (14ms|0ms)
 13ms (12ms|0ms)
 7ms (7ms|0ms)
 Context body-file spellings reach receipt verification (R-733-715)
 13ms (13ms|1ms)
 16ms (16ms|0ms)
 11ms (11ms|0ms)
 13ms (12ms|0ms)
 12ms (11ms|0ms)

Describing Issue #824 regression: pr-author command allowlist
 22ms (21ms|1ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 4ms (4ms|0ms)
Tests completed in 22.49s
Tests Passed: 246, 
Failed: 1, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=247
PassedCount=246
FailedCount=1
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
```
