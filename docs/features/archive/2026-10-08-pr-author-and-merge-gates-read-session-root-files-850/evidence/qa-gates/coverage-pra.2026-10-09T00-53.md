# P8-T4 Coverage CG-PRA final

Timestamp: 2026-10-09T00-53
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1,tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 -CoveragePath .claude/hooks/enforce-pr-author-skill.ps1,.claude/hooks/enforce-pr-author-skill-helpers.ps1,.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 -CoverageOutputPath SCRATCH/cov-pra-final.xml -ReportPath SCRATCH/cov-pra-final.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=262
  PassedCount=262
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-pr-author-skill.ps1 AnalyzedLines=49 CoveredLines=45 LinePercent=91.84
  COVERAGE file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 AnalyzedLines=111 CoveredLines=108 LinePercent=97.3
  COVERAGE file=.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 AnalyzedLines=58 CoveredLines=56 LinePercent=96.55

## Full output

```text
Pester v5.6.1

Starting discovery in 14 files.
Discovery found 262 tests in 464ms.
Starting code coverage.
Code Coverage preparation finished after 227 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1'
Describing enforce-pr-author-skill.ps1
 Context tool input parsing
 114ms (93ms|21ms)
 35ms (33ms|2ms)
 10ms (9ms|0ms)
 Context gh pr create - inline body (Case A)
 97ms (96ms|1ms)
 23ms (22ms|1ms)
 Context gh pr edit - inline body (Case A)
 42ms (40ms|1ms)
 25ms (24ms|1ms)
 32ms (32ms|1ms)
 Context gh pr create - missing body (Case B)
 25ms (24ms|1ms)
 23ms (22ms|1ms)
 Context gh pr create/edit - missing context artifact (Case C)
 103ms (102ms|1ms)
 38ms (37ms|1ms)
 Context allowed commands
 139ms (138ms|1ms)
 73ms (72ms|1ms)
 39ms (38ms|1ms)
 35ms (34ms|1ms)
 26ms (25ms|1ms)
 25ms (24ms|1ms)
 32ms (31ms|1ms)
 26ms (25ms|1ms)
 26ms (25ms|1ms)
 Context receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)
 49ms (48ms|1ms)
 Context receipt - missing (PR_AUTHOR_RECEIPT_MISSING)
 58ms (56ms|1ms)
 Context receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)
 55ms (54ms|1ms)
 Context receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)
 63ms (62ms|1ms)
 Context receipt - stale (PR_AUTHOR_RECEIPT_STALE)
 65ms (64ms|2ms)
 Context receipt - all checks pass (allow)
 75ms (74ms|1ms)
 Context Get-PrAuthorBypassReason helper
 74ms (73ms|1ms)
 31ms (30ms|1ms)
 39ms (39ms|1ms)
 Context decision builders emit the PreToolUse schema
 13ms (12ms|1ms)
 7ms (6ms|1ms)
 Context Test-PrAuthorBypassRequired helper
 95ms (94ms|1ms)
 37ms (36ms|1ms)
 42ms (42ms|1ms)
 Context Get-PrContextArtifactExistence real Test-Path wrapper
 14ms (13ms|1ms)
 Context Get-PrBodyFileBytes real read seam
 9ms (7ms|1ms)
 179ms (178ms|1ms)
 Context Get-PrAuthorReceiptContent real read seam
 7ms (6ms|1ms)
 10ms (10ms|1ms)
 Context Get-PrContextSummaryLastWriteUtc real seam
 6ms (5ms|1ms)
 13ms (12ms|1ms)
 Context Invoke-PrAuthorSkillDecision without mock (real context lookup)
 30ms (29ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1'
Describing enforce-pr-author-skill.ps1 epic scope (issue #663)
 176ms (173ms|2ms)
 71ms (71ms|1ms)
 70ms (69ms|1ms)
 86ms (85ms|1ms)
 106ms (105ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1'
Describing enforce-pr-author-skill.ps1 (orchestrator-state preflight)
 Context orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)
 50ms (49ms|1ms)
 45ms (44ms|1ms)
 Context script entrypoint (end-to-end)
 656ms (654ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1'
Describing enforce-pr-author-skill.ps1 payload envelope
 Context entry-point exit code and emitted decision (AC-4, no child process)
 30ms (18ms|12ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 7ms (6ms|1ms)
 7ms (7ms|1ms)
 7ms (6ms|1ms)
 Context nested envelope reaches the existing decision logic (AC-7)
 28ms (26ms|1ms)
 14ms (14ms|1ms)
 7ms (7ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 target resolution
 Context the checkpoint is taken from the resolved target, not the session root
 443ms (441ms|2ms)
 355ms (354ms|1ms)
 Context an underivable target denies instead of answering from unrelated state
 37ms (35ms|2ms)
 418ms (418ms|1ms)
 33ms (32ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1'
Describing enforce-pr-author-skill trigger scoping (issue #545)
 Context over-match removal - a quoted mention is not an invocation
 30ms (28ms|2ms)
 Context under-match removal - a relocating spelling now classifies
 50ms (49ms|1ms)
 39ms (38ms|1ms)
 Context flag distinction - --body does not match --body-file
 52ms (50ms|1ms)
 Context wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test
 56ms (54ms|1ms)
 54ms (53ms|1ms)
 48ms (47ms|1ms)
 38ms (37ms|1ms)
 84ms (83ms|1ms)
 51ms (50ms|1ms)
 45ms (45ms|1ms)
 Context every PR_* reason code is still produced for its genuine triggering invocation
 56ms (54ms|1ms)
 57ms (56ms|1ms)
 65ms (64ms|1ms)
 76ms (75ms|1ms)
 72ms (71ms|1ms)
 56ms (56ms|1ms)
 59ms (59ms|1ms)
 Context R-2.c wrapper-led body flags
 28ms (27ms|1ms)
 44ms (43ms|1ms)
 31ms (30ms|1ms)
 15ms (14ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 worktree-resolution matrix
 595ms (594ms|1ms)
 397ms (397ms|1ms)
 26ms (26ms|0ms)
 338ms (338ms|1ms)
 264ms (264ms|1ms)
 252ms (252ms|0ms)
 328ms (328ms|0ms)
 27ms (27ms|1ms)
 299ms (298ms|1ms)
 257ms (256ms|1ms)
 280ms (279ms|1ms)
 238ms (237ms|0ms)
 225ms (225ms|0ms)
 11ms (10ms|0ms)
 257ms (257ms|0ms)
 218ms (218ms|1ms)
 210ms (209ms|0ms)
 280ms (280ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1'
Describing enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride
 Context epic_mode is false or absent (no-op/allow)
 14ms (13ms|1ms)
 12ms (12ms|0ms)
 8ms (8ms|0ms)
 Context epic_mode is true with the correct --base (allow)
 22ms (21ms|1ms)
 Context epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)
 16ms (15ms|1ms)
 Context epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)
 22ms (21ms|1ms)
 13ms (12ms|0ms)
 Context end-to-end via Invoke-PrAuthorSkillDecision (sixth check wired into the receipt path)
 63ms (62ms|1ms)
 62ms (62ms|0ms)
 Context issue #663 epic scope
 73ms (72ms|1ms)
 65ms (64ms|0ms)
 67ms (67ms|1ms)
 61ms (61ms|0ms)
 73ms (73ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1'
Describing Test-EpicBaseBranchOverride trigger scoping (issue #545)
 Context under-match removal - a relocating spelling now classifies
 21ms (19ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 7ms (6ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
 42ms (41ms|1ms)
 Context rejection conditions
 15ms (14ms|1ms)
 9ms (9ms|0ms)
 9ms (9ms|0ms)
 12ms (11ms|0ms)
 10ms (9ms|0ms)
 10ms (9ms|0ms)
 19ms (18ms|0ms)
 Context fail-closed conditions
 9ms (8ms|1ms)
 10ms (10ms|0ms)
 9ms (9ms|0ms)
 11ms (11ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
 4ms (3ms|1ms)
 3ms (2ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 Context default invoker (portable path is the only path)
 130ms (129ms|1ms)
 25ms (24ms|0ms)
 15ms (15ms|0ms)
 14ms (14ms|0ms)
 12ms (12ms|0ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
 6ms (4ms|2ms)
 4ms (4ms|0ms)
 1ms (1ms|0ms)
 3ms (2ms|0ms)
 Context per-key extra statuses rejected on every non-owning key
 5ms (4ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 Context epic-merge-gate regression scenario
 8ms (7ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1'
Describing gate suites isolate the epic checkpoint read (structural guard)
 34ms (33ms|1ms)
 22ms (21ms|0ms)
 14ms (13ms|0ms)
 21ms (20ms|0ms)
 9ms (9ms|0ms)
 13ms (13ms|1ms)
 6ms (6ms|0ms)
 10ms (10ms|0ms)
 12ms (11ms|0ms)
 Context guard predicate discrimination
 8ms (7ms|1ms)
 4ms (3ms|0ms)
 6ms (6ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|1ms)
 3ms (3ms|0ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 4ms (3ms|0ms)
 3ms (2ms|0ms)

Describing the run-checkpoint mocks block the epic-state read (seam sufficiency)
 47ms (46ms|2ms)
 17ms (17ms|0ms)
 29ms (28ms|0ms)
 16ms (15ms|0ms)
 25ms (25ms|0ms)
 16ms (15ms|0ms)
 26ms (25ms|1ms)
 29ms (29ms|0ms)
 22ms (22ms|1ms)
 19ms (18ms|1ms)
 17ms (17ms|0ms)
 24ms (23ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1'
Describing enforce-pr-author-skill issue #824 decisions
 Context commands that mention gh pr create without invoking it
 24ms (23ms|1ms)
 20ms (20ms|0ms)
 18ms (18ms|0ms)
 17ms (17ms|1ms)
 20ms (20ms|0ms)
 Context body-file normalization and receipt verification
 183ms (182ms|1ms)
 168ms (167ms|0ms)
 185ms (185ms|0ms)
 164ms (163ms|0ms)
 184ms (183ms|0ms)
 194ms (194ms|0ms)
 162ms (162ms|0ms)
 225ms (225ms|0ms)
 229ms (229ms|1ms)
 176ms (176ms|0ms)
 48ms (48ms|0ms)
 19ms (19ms|0ms)
 Context inline-body and no-body pull requests
 15ms (14ms|1ms)
 14ms (14ms|0ms)
 9ms (9ms|0ms)
 15ms (15ms|0ms)
 16ms (15ms|0ms)
 84ms (84ms|0ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1'
Describing Issue #824 regression: promotion gate (claude)
 35ms (34ms|1ms)

Describing Issue #824 regression: promotion gate (codex)
 63ms (61ms|1ms)

Describing Issue #824 regression: Claude epic worktree-removal gate
 24ms (23ms|1ms)
 25ms (25ms|0ms)

Describing Issue #824 regression: Claude parallel worktree-removal gate
 27ms (26ms|1ms)
 18ms (17ms|0ms)

Describing Issue #824 regression: Codex epic worktree-removal gate
 21ms (20ms|1ms)
 3ms (3ms|0ms)

Describing Issue #824 regression: preimplementation gate (claude)
 12ms (11ms|1ms)

Describing Issue #824 regression: preimplementation gate (codex)
 22ms (21ms|1ms)

Describing Issue #824 regression: Claude pr-author skill gate
 Context commands that mention gh pr create without invoking it (R-733-714, R-733-GREP)
 38ms (37ms|1ms)
 15ms (15ms|0ms)
 18ms (17ms|0ms)
 14ms (13ms|0ms)
 Context body-file spellings reach receipt verification (R-733-715)
 16ms (15ms|1ms)
 14ms (13ms|0ms)
 17ms (16ms|0ms)
 11ms (10ms|0ms)
 12ms (12ms|0ms)

Describing Issue #824 regression: pr-author command allowlist
 13ms (12ms|1ms)
 4ms (4ms|0ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1'
Describing enforce-pr-author-skill.ps1 item artifact root
 341ms (341ms|1ms)
 214ms (213ms|0ms)
 250ms (250ms|0ms)
 231ms (231ms|0ms)
 223ms (223ms|0ms)
 204ms (204ms|0ms)
 211ms (210ms|0ms)
 234ms (234ms|0ms)
 231ms (231ms|0ms)
 721ms (721ms|0ms)
 241ms (241ms|0ms)
 79ms (79ms|0ms)
 37ms (37ms|0ms)
 37ms (37ms|0ms)
 193ms (193ms|0ms)
Tests completed in 21.86s
Tests Passed: 262, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 484 ms.
Covered 95.68% / 75%. 301 analyzed Commands in 3 Files.
Missed commands:

File                                      Class Function                         Line Command
----                                      ----- --------                         ---- -------
enforce-pr-author-skill-helpers.ps1             Test-PrAuthorReceiptVerification  244 return "PR_AUTHOR_RECEIPT_MISSING…
enforce-pr-author-skill-helpers.ps1             Test-PrAuthorReceiptVerification  260 return "PR_AUTHOR_RECEIPT_HASH_MI…
enforce-pr-author-skill-helpers.ps1             Test-PrAuthorReceiptVerification  283 return "PR_AUTHOR_RECEIPT_STALE: …
enforce-pr-author-skill.artifact-root.ps1       Test-PrAuthorBodyPathEqual         49 return $false
enforce-pr-author-skill.artifact-root.ps1       Get-PrAuthorEpicArtifactRoot       82 return $null
enforce-pr-author-skill.ps1                                                       321 $entryPointResult = @(Invoke-PrAu…
enforce-pr-author-skill.ps1                                                       321 Invoke-PrAuthorSkillEntryPoint
enforce-pr-author-skill.ps1                                                       322 if ($entryPointResult.Count -gt 1…
enforce-pr-author-skill.ps1                                                       323 $entryPointResult[0..($entryPoint…
enforce-pr-author-skill.ps1                                                       323 $entryPointResult.Count - 2
enforce-pr-author-skill.ps1                                                       323 Write-Output
enforce-pr-author-skill.ps1                                                       326 ([int]$entryPointResult[-1])
enforce-pr-author-skill.ps1                                                       326 [int]$entryPointResult[-1]


TotalCount=262
PassedCount=262
FailedCount=0
COVERAGE file=.claude/hooks/enforce-pr-author-skill.ps1 AnalyzedLines=49 CoveredLines=45 LinePercent=91.84
HIT file=.claude/hooks/enforce-pr-author-skill.ps1 Lines=53,54,57,59,77,102,103,106,130,131,134,157,158,161,164,168,190,191,192,193,194,198,199,200,203,205,206,209,223,224,225,226,247,248,249,250,251,272,300,303,304,307,308,310,314
MISSED file=.claude/hooks/enforce-pr-author-skill.ps1 Lines=321,322,323,326
COVERAGE file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 AnalyzedLines=111 CoveredLines=108 LinePercent=97.3
HIT file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 Lines=36,37,43,44,48,50,51,53,75,116,118,119,120,123,124,150,151,152,154,155,156,158,159,160,162,224,225,226,229,230,231,232,235,236,237,242,248,249,250,251,253,254,258,259,263,265,267,269,271,272,276,277,282,286,287,288,292,293,294,297,329,330,332,333,339,340,341,348,349,350,351,352,353,354,355,356,364,365,368,370,371,375,377,378,386,387,388,392,393,394,401,402,403,404,405,407,409,410,411,412,413,414,416,418,423,424,425,428
MISSED file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 Lines=244,260,283
COVERAGE file=.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 AnalyzedLines=58 CoveredLines=56 LinePercent=96.55
HIT file=.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 Lines=46,47,48,51,52,55,57,75,76,77,78,80,81,84,109,110,111,112,113,114,115,118,120,121,122,123,124,125,126,130,131,132,133,134,135,136,137,138,173,174,175,176,179,180,181,182,183,184,185,188,191,192,193,194,195,199
MISSED file=.claude/hooks/enforce-pr-author-skill.artifact-root.ps1 Lines=49,82
```
