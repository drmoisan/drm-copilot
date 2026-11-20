# P0-T25 Coverage baseline CG-PRA

Timestamp: 2026-10-08T23-49
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1,tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 -CoveragePath .claude/hooks/enforce-pr-author-skill.ps1,.claude/hooks/enforce-pr-author-skill-helpers.ps1 -CoverageOutputPath SCRATCH/cov-pra-base.xml -ReportPath SCRATCH/cov-pra-base.txt
EXIT_CODE: 0
Output Summary:
  Failed: 1, 
  TotalCount=247
  PassedCount=246
  FailedCount=1
  FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
  COVERAGE file=.claude/hooks/enforce-pr-author-skill.ps1 AnalyzedLines=50 CoveredLines=46 LinePercent=92
  COVERAGE file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 AnalyzedLines=115 CoveredLines=112 LinePercent=97.39
  Rule EE: applied using the P0-T17 probe output (evidence/baseline/pester-set-pra.2026-10-08T23-39.md; condition holds). The FAILED line above is textually identical to EE-1 (A3 prints no FAILED-FILE line).
  Failure message: REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
  ENV-EPIC-FAILED: EE-1
  Baseline failure set (CG-PRA): empty
  Baseline container set (CG-PRA): empty
  BASEPCT PRA (.claude/hooks/enforce-pr-author-skill.ps1): 92
  BASEPCT PRAH (.claude/hooks/enforce-pr-author-skill-helpers.ps1): 97.39

## Full output

```text
Pester v5.6.1

Starting discovery in 13 files.
Discovery found 247 tests in 433ms.
Starting code coverage.
Code Coverage preparation finished after 203 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1'
Describing enforce-pr-author-skill.ps1
 Context tool input parsing
 117ms (96ms|21ms)
 14ms (12ms|2ms)
 10ms (10ms|1ms)
 Context gh pr create - inline body (Case A)
 134ms (133ms|1ms)
 31ms (30ms|1ms)
 Context gh pr edit - inline body (Case A)
 26ms (25ms|1ms)
 28ms (28ms|1ms)
 24ms (24ms|1ms)
 Context gh pr create - missing body (Case B)
 37ms (23ms|14ms)
 25ms (24ms|0ms)
 Context gh pr create/edit - missing context artifact (Case C)
 31ms (30ms|1ms)
 31ms (30ms|0ms)
 Context allowed commands
   [-] allows gh pr create --body-file artifacts/pr_body_12.md when context exists
 162ms (160ms|2ms)
    at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:154
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:154
    Expected strings to be the same, but they were different.
    Expected length: 5
    Actual length:   4
    Strings differ at index 0.
    Expected: 'allow'
    But was:  'deny'
               ^
 63ms (62ms|1ms)
 38ms (37ms|1ms)
 37ms (37ms|0ms)
 19ms (19ms|0ms)
 21ms (20ms|0ms)
 24ms (24ms|1ms)
 32ms (32ms|0ms)
 28ms (27ms|1ms)
 Context receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)
 51ms (50ms|1ms)
 Context receipt - missing (PR_AUTHOR_RECEIPT_MISSING)
 62ms (61ms|1ms)
 Context receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)
 57ms (56ms|1ms)
 Context receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)
 66ms (65ms|1ms)
 Context receipt - stale (PR_AUTHOR_RECEIPT_STALE)
 71ms (70ms|1ms)
 Context receipt - all checks pass (allow)
 94ms (93ms|1ms)
 Context Get-PrAuthorBypassReason helper
 77ms (76ms|1ms)
 36ms (35ms|1ms)
 45ms (44ms|1ms)
 Context decision builders emit the PreToolUse schema
 20ms (18ms|2ms)
 8ms (7ms|1ms)
 Context Test-PrAuthorBypassRequired helper
 73ms (72ms|2ms)
 42ms (41ms|1ms)
 41ms (41ms|1ms)
 Context Get-PrContextArtifactExistence real Test-Path wrapper
 13ms (11ms|1ms)
 Context Get-PrBodyFileBytes real read seam
 9ms (7ms|1ms)
 182ms (181ms|1ms)
 Context Get-PrAuthorReceiptContent real read seam
 8ms (6ms|2ms)
 11ms (10ms|1ms)
 Context Get-PrContextSummaryLastWriteUtc real seam
 7ms (6ms|1ms)
 13ms (12ms|1ms)
 Context Invoke-PrAuthorSkillDecision without mock (real context lookup)
 26ms (25ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1'
Describing enforce-pr-author-skill.ps1 epic scope (issue #663)
 195ms (192ms|2ms)
 68ms (68ms|1ms)
 75ms (74ms|1ms)
 84ms (84ms|0ms)
 105ms (105ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1'
Describing enforce-pr-author-skill.ps1 (orchestrator-state preflight)
 Context orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)
 51ms (49ms|2ms)
 36ms (35ms|1ms)
 Context script entrypoint (end-to-end)
 652ms (651ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1'
Describing enforce-pr-author-skill.ps1 payload envelope
 Context entry-point exit code and emitted decision (AC-4, no child process)
 18ms (16ms|2ms)
 9ms (8ms|1ms)
 7ms (6ms|0ms)
 21ms (14ms|8ms)
 6ms (6ms|0ms)
 7ms (6ms|1ms)
 Context nested envelope reaches the existing decision logic (AC-7)
 24ms (23ms|1ms)
 12ms (11ms|1ms)
 7ms (7ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 target resolution
 Context the checkpoint is taken from the resolved target, not the session root
 475ms (474ms|2ms)
 401ms (400ms|1ms)
 Context an underivable target denies instead of answering from unrelated state
 32ms (31ms|1ms)
 331ms (330ms|1ms)
 25ms (24ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1'
Describing enforce-pr-author-skill trigger scoping (issue #545)
 Context over-match removal - a quoted mention is not an invocation
 26ms (24ms|1ms)
 Context under-match removal - a relocating spelling now classifies
 39ms (38ms|1ms)
 32ms (32ms|1ms)
 Context flag distinction - --body does not match --body-file
 38ms (37ms|1ms)
 Context wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test
 46ms (45ms|1ms)
 39ms (38ms|1ms)
 35ms (34ms|0ms)
 23ms (22ms|1ms)
 59ms (59ms|0ms)
 42ms (41ms|0ms)
 34ms (33ms|0ms)
 Context every PR_* reason code is still produced for its genuine triggering invocation
 29ms (28ms|1ms)
 40ms (40ms|1ms)
 50ms (49ms|0ms)
 46ms (46ms|0ms)
 43ms (43ms|0ms)
 47ms (46ms|0ms)
 48ms (47ms|0ms)
 Context R-2.c wrapper-led body flags
 28ms (27ms|1ms)
 38ms (37ms|0ms)
 26ms (25ms|0ms)
 16ms (16ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 worktree-resolution matrix
 524ms (523ms|1ms)
 367ms (366ms|1ms)
 28ms (27ms|1ms)
 391ms (391ms|0ms)
 316ms (316ms|1ms)
 318ms (317ms|0ms)
 295ms (295ms|0ms)
 25ms (25ms|0ms)
 334ms (334ms|1ms)
 233ms (233ms|0ms)
 247ms (247ms|0ms)
 236ms (236ms|0ms)
 254ms (253ms|0ms)
 11ms (10ms|0ms)
 257ms (255ms|2ms)
 232ms (232ms|1ms)
 245ms (245ms|1ms)
 257ms (257ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1'
Describing enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride
 Context epic_mode is false or absent (no-op/allow)
 16ms (15ms|1ms)
 14ms (14ms|0ms)
 10ms (10ms|0ms)
 Context epic_mode is true with the correct --base (allow)
 24ms (23ms|1ms)
 Context epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)
 17ms (16ms|1ms)
 Context epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)
 20ms (19ms|1ms)
 14ms (13ms|0ms)
 Context end-to-end via Invoke-PrAuthorSkillDecision (sixth check wired into the receipt path)
 64ms (64ms|1ms)
 69ms (68ms|0ms)
 Context issue #663 epic scope
 84ms (83ms|1ms)
 84ms (84ms|1ms)
 64ms (64ms|0ms)
 59ms (59ms|0ms)
 72ms (71ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1'
Describing Test-EpicBaseBranchOverride trigger scoping (issue #545)
 Context under-match removal - a relocating spelling now classifies
 15ms (14ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 7ms (6ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
 43ms (42ms|1ms)
 Context rejection conditions
 23ms (21ms|1ms)
 15ms (14ms|0ms)
 13ms (12ms|0ms)
 14ms (13ms|0ms)
 17ms (17ms|0ms)
 11ms (11ms|0ms)
 12ms (12ms|0ms)
 Context fail-closed conditions
 19ms (19ms|1ms)
 12ms (12ms|0ms)
 10ms (10ms|0ms)
 10ms (9ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
 9ms (7ms|2ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 Context default invoker (portable path is the only path)
 138ms (137ms|1ms)
 24ms (24ms|0ms)
 15ms (15ms|0ms)
 14ms (13ms|0ms)
 12ms (12ms|0ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
 6ms (5ms|2ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 3ms (3ms|0ms)
 Context per-key extra statuses rejected on every non-owning key
 6ms (5ms|1ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (2ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 9ms (9ms|0ms)
 1ms (1ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 Context epic-merge-gate regression scenario
 4ms (4ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1'
Describing gate suites isolate the epic checkpoint read (structural guard)
 35ms (34ms|1ms)
 15ms (14ms|0ms)
 12ms (12ms|0ms)
 18ms (17ms|0ms)
 7ms (7ms|0ms)
 12ms (12ms|0ms)
 8ms (7ms|0ms)
 8ms (7ms|0ms)
 Context guard predicate discrimination
 8ms (7ms|1ms)
 3ms (3ms|0ms)
 6ms (6ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 3ms (2ms|0ms)
 4ms (4ms|0ms)
 3ms (3ms|0ms)
 5ms (5ms|0ms)
 3ms (3ms|0ms)
 3ms (3ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|0ms)

Describing the run-checkpoint mocks block the epic-state read (seam sufficiency)
 47ms (45ms|2ms)
 16ms (15ms|1ms)
 33ms (33ms|1ms)
 18ms (17ms|1ms)
 27ms (26ms|1ms)
 20ms (19ms|1ms)
 35ms (34ms|1ms)
 25ms (24ms|1ms)
 32ms (31ms|1ms)
 22ms (22ms|1ms)
 23ms (22ms|1ms)
 25ms (25ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1'
Describing enforce-pr-author-skill issue #824 decisions
 Context commands that mention gh pr create without invoking it
 29ms (28ms|1ms)
 22ms (21ms|0ms)
 18ms (17ms|0ms)
 16ms (15ms|0ms)
 22ms (22ms|0ms)
 Context body-file normalization and receipt verification
 257ms (255ms|2ms)
 221ms (221ms|1ms)
 192ms (192ms|0ms)
 212ms (212ms|0ms)
 183ms (183ms|0ms)
 176ms (176ms|0ms)
 189ms (189ms|1ms)
 188ms (187ms|0ms)
 375ms (375ms|1ms)
 388ms (386ms|1ms)
 55ms (54ms|1ms)
 26ms (25ms|1ms)
 Context inline-body and no-body pull requests
 24ms (23ms|1ms)
 13ms (13ms|1ms)
 10ms (10ms|1ms)
 19ms (19ms|1ms)
 15ms (14ms|0ms)
 81ms (81ms|0ms)
 Context body-file root seam
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1'
Describing Issue #824 regression: promotion gate (claude)
 26ms (25ms|1ms)

Describing Issue #824 regression: promotion gate (codex)
 71ms (70ms|1ms)

Describing Issue #824 regression: Claude epic worktree-removal gate
 44ms (42ms|1ms)
 12ms (12ms|0ms)

Describing Issue #824 regression: Claude parallel worktree-removal gate
 34ms (33ms|1ms)
 14ms (13ms|0ms)

Describing Issue #824 regression: Codex epic worktree-removal gate
 27ms (26ms|1ms)
 4ms (3ms|0ms)

Describing Issue #824 regression: preimplementation gate (claude)
 14ms (12ms|1ms)

Describing Issue #824 regression: preimplementation gate (codex)
 10ms (9ms|1ms)

Describing Issue #824 regression: Claude pr-author skill gate
 Context commands that mention gh pr create without invoking it (R-733-714, R-733-GREP)
 38ms (37ms|1ms)
 20ms (19ms|0ms)
 17ms (17ms|0ms)
 11ms (11ms|0ms)
 Context body-file spellings reach receipt verification (R-733-715)
 18ms (18ms|1ms)
 68ms (68ms|0ms)
 16ms (15ms|0ms)
 16ms (16ms|0ms)
 13ms (13ms|0ms)

Describing Issue #824 regression: pr-author command allowlist
 17ms (15ms|1ms)
 6ms (6ms|1ms)
 14ms (14ms|1ms)
 9ms (9ms|1ms)
Tests completed in 18.74s
Tests Passed: 246, 
Failed: 1, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 631 ms.
Covered 95.18% / 75%. 228 analyzed Commands in 2 Files.
Missed commands:

File                                Class Function                         Line Command
----                                ----- --------                         ---- -------
enforce-pr-author-skill-helpers.ps1       Test-PrAuthorReceiptVerification  247 return "PR_AUTHOR_RECEIPT_MISSING: ``$r…
enforce-pr-author-skill-helpers.ps1       Test-PrAuthorReceiptVerification  263 return "PR_AUTHOR_RECEIPT_HASH_MISMATCH…
enforce-pr-author-skill-helpers.ps1       Test-PrAuthorReceiptVerification  286 return "PR_AUTHOR_RECEIPT_STALE: ``$rec…
enforce-pr-author-skill.ps1                                                 309 $entryPointResult = @(Invoke-PrAuthorSk…
enforce-pr-author-skill.ps1                                                 309 Invoke-PrAuthorSkillEntryPoint
enforce-pr-author-skill.ps1                                                 310 if ($entryPointResult.Count -gt 1) {…
enforce-pr-author-skill.ps1                                                 311 $entryPointResult[0..($entryPointResult…
enforce-pr-author-skill.ps1                                                 311 $entryPointResult.Count - 2
enforce-pr-author-skill.ps1                                                 311 Write-Output
enforce-pr-author-skill.ps1                                                 314 ([int]$entryPointResult[-1])
enforce-pr-author-skill.ps1                                                 314 [int]$entryPointResult[-1]


TotalCount=247
PassedCount=246
FailedCount=1
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
COVERAGE file=.claude/hooks/enforce-pr-author-skill.ps1 AnalyzedLines=50 CoveredLines=46 LinePercent=92
HIT file=.claude/hooks/enforce-pr-author-skill.ps1 Lines=47,48,51,53,66,90,91,94,117,118,121,139,140,143,146,150,172,173,174,175,176,180,181,182,185,186,188,189,192,206,207,208,209,230,231,232,233,234,260,288,291,292,295,296,298,302
MISSED file=.claude/hooks/enforce-pr-author-skill.ps1 Lines=309,310,311,314
COVERAGE file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 AnalyzedLines=115 CoveredLines=112 LinePercent=97.39
HIT file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 Lines=34,35,41,42,46,48,49,71,110,112,113,114,117,118,137,160,161,162,164,165,166,168,169,171,172,173,175,228,229,230,233,234,235,238,239,240,245,251,252,253,254,256,257,261,262,266,268,270,272,274,275,279,280,285,289,290,291,295,296,297,300,337,338,340,341,347,348,349,356,357,358,359,360,361,362,363,364,372,373,376,378,379,383,385,386,391,392,399,400,401,406,407,408,409,411,412,413,414,415,419,420,421,422,423,424,426,428,433,434,435,436,440
MISSED file=.claude/hooks/enforce-pr-author-skill-helpers.ps1 Lines=247,263,286
```
