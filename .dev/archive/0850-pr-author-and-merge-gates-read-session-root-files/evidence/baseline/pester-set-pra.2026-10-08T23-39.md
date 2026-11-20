# P0-T17 Pester baseline SET-PRA (plan revision 4, rule EE)

Timestamp: 2026-10-08T23-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1,tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1,tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1,tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 ; then sh SCRATCH/run-ps.sh SCRATCH/epic-checkpoint-probe.ps1 (A18, no arguments)
EXIT_CODE: 0
Output Summary:
  TotalCount=247
  PassedCount=246
  FailedCount=1
  FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
  A18: DECISION=deny
  A18: REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
  A18: DECISION-WITHOUT-CHECKPOINT=allow
  Probe condition (rule EE): HOLDS (DECISION=deny; REASON begins EPIC_BASE_BRANCH_MISMATCH:; DECISION-WITHOUT-CHECKPOINT=allow)
  ENV-EPIC-FAILED: EE-1
  BASE_PRA: 247
  Baseline failure set: empty
  Baseline container set: empty
  BASELINE-RED-IN-EDITED-SUITE: not triggered (the only failure is EE-1, exempt under rule EE)

## Rule EE application

The single `FAILED:` line and its `FAILED-FILE:` line are textually identical to EE-1:

```text
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
```

Failure message (A18 `REASON=` line, verbatim):

```text
REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
```

ENV-EPIC-FAILED: EE-1

The exempt line is not a member of the P0-T17 baseline failure set. Recorded counts are unchanged (TotalCount=247, PassedCount=246, FailedCount=1). No `FAILED-CONTAINER:` line was printed.

## A18 output (full)

```text
DECISION=deny
REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
DECISION-WITHOUT-CHECKPOINT=allow
```

## A2 output (full; ANSI codes and the worktree root removed)

```text
Pester v5.6.1

Starting discovery in 13 files.
Discovery found 247 tests in 428ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1'
Describing enforce-pr-author-skill.ps1
 Context tool input parsing
   [+] denies an empty payload as an envelope anomaly (fail closed) 152ms (132ms|20ms)
   [+] allows when JSON has no command field 14ms (12ms|2ms)
   [+] denies unparseable JSON instead of throwing (exit 1 is non-blocking) 10ms (9ms|0ms)
 Context gh pr create - inline body (Case A)
   [+] blocks gh pr create --body "inline string" 142ms (141ms|1ms)
   [+] blocks gh pr create --body='inline' (equals-sign form) 42ms (42ms|0ms)
 Context gh pr edit - inline body (Case A)
   [+] blocks gh pr edit --body "inline text" (no --body-file) 20ms (19ms|1ms)
   [+] blocks gh pr edit --body='inline' (equals-sign form, no --body-file) 19ms (19ms|0ms)
   [+] allows gh pr edit --title "x" (no body flag remains allowed) 23ms (23ms|0ms)
 Context gh pr create - missing body (Case B)
   [+] blocks gh pr create with no body flags 20ms (18ms|1ms)
   [+] blocks gh pr create --title foo with no body flags 33ms (33ms|0ms)
 Context gh pr create/edit - missing context artifact (Case C)
   [+] blocks gh pr create --body-file artifacts/pr_body_12.md when context is absent 26ms (25ms|1ms)
   [+] blocks gh pr edit --body-file artifacts/pr_body_12.md when context is absent 28ms (27ms|1ms)
 Context allowed commands
   [-] allows gh pr create --body-file artifacts/pr_body_12.md when context exists 150ms (148ms|2ms)
    at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:154
    at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:154
    Expected strings to be the same, but they were different.
    Expected length: 5
    Actual length:   4
    Strings differ at index 0.
    Expected: 'allow'
    But was:  'deny'
               ^
   [+] allows gh pr edit --body-file artifacts/pr_body_12.md when context exists 50ms (50ms|0ms)
   [+] allows gh pr edit --title "new title" (no body flag) 29ms (29ms|1ms)
   [+] allows gh pr edit --add-label bug (no body flag) 39ms (39ms|0ms)
   [+] allows gh pr view 13 19ms (18ms|0ms)
   [+] allows gh pr list 19ms (18ms|0ms)
   [+] allows gh pr merge 22ms (22ms|0ms)
   [+] allows gh pr checkout 13 19ms (18ms|0ms)
   [+] allows gh issue create (not guarded by this hook) 18ms (18ms|0ms)
 Context receipt - noncanonical body-file path (PR_BODY_PATH_NONCANONICAL)
   [+] blocks a --body-file artifacts/pr_body.md (no number) with PR_BODY_PATH_NONCANONICAL 41ms (40ms|1ms)
 Context receipt - missing (PR_AUTHOR_RECEIPT_MISSING)
   [+] blocks with PR_AUTHOR_RECEIPT_MISSING when the receipt read seam returns null 41ms (40ms|1ms)
 Context receipt - number mismatch (PR_AUTHOR_RECEIPT_NUMBER_MISMATCH)
   [+] blocks with PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when receipt.number does not match the path number 40ms (39ms|1ms)
 Context receipt - hash mismatch (PR_AUTHOR_RECEIPT_HASH_MISMATCH)
   [+] blocks with PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body SHA-256 does not match receipt.sha256 43ms (42ms|1ms)
 Context receipt - stale (PR_AUTHOR_RECEIPT_STALE)
   [+] blocks with PR_AUTHOR_RECEIPT_STALE when created_at is not strictly newer than the context last-write 59ms (57ms|1ms)
 Context receipt - all checks pass (allow)
   [+] allows when all six receipt checks pass 129ms (127ms|2ms)
 Context Get-PrAuthorBypassReason helper
   [+] returns null for allowed command 115ms (113ms|2ms)
   [+] returns PR_AUTHOR_SKILL_BLOCKED for inline --body 70ms (69ms|1ms)
   [+] returns PR_CONTEXT_MISSING when --body-file present but context absent 66ms (64ms|2ms)
 Context decision builders emit the PreToolUse schema
   [+] Get-PrAuthorSkillBlockDecision yields hookEventName=PreToolUse and permissionDecision=deny after serialize-then-parse 22ms (20ms|2ms)
   [+] Get-PrAuthorSkillAllowDecision yields permissionDecision=allow 12ms (11ms|1ms)
 Context Test-PrAuthorBypassRequired helper
   [+] returns false for an allowed command 104ms (101ms|3ms)
   [+] returns true for a blocked command (inline --body) 58ms (57ms|1ms)
   [+] returns true when context is missing for --body-file command 44ms (43ms|1ms)
 Context Get-PrContextArtifactExistence real Test-Path wrapper
   [+] returns a boolean result without throwing 21ms (19ms|2ms)
 Context Get-PrBodyFileBytes real read seam
   [+] returns $null when the body-file path does not exist 8ms (7ms|2ms)
   [+] returns the raw bytes when the path exists (points at the hook script itself) 174ms (173ms|1ms)
 Context Get-PrAuthorReceiptContent real read seam
   [+] returns $null when the receipt path does not exist 7ms (6ms|1ms)
   [+] returns the raw file text when the receipt path exists (points at the hook script itself) 11ms (10ms|1ms)
 Context Get-PrContextSummaryLastWriteUtc real seam
   [+] returns $null when the context summary path does not exist 12ms (11ms|1ms)
   [+] returns a UTC DateTime when the context path exists (points at the hook script itself) 14ms (13ms|1ms)
 Context Invoke-PrAuthorSkillDecision without mock (real context lookup)
   [+] blocks gh pr create with no body flags regardless of context artifact 20ms (19ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1'
Describing enforce-pr-author-skill.ps1 epic scope (issue #663)
  [+] epic scope allows gh pr create --head integration_branch --base main when every feature is merged or worktree_removed 157ms (155ms|2ms)
  [+] epic scope denies when a feature has a non-terminal merge_status and names the epic checkpoint and merge_status 55ms (55ms|1ms)
  [+] epic scope denies when features is empty and names the epic checkpoint and features 49ms (49ms|1ms)
  [+] without an epic checkpoint the call takes the unchanged per-feature path and is denied by its resolution 62ms (61ms|1ms)
  [+] a per-feature pull request whose --head differs from integration_branch gets the same decision and reason as with no epic checkpoint 78ms (77ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1'
Describing enforce-pr-author-skill.ps1 (orchestrator-state preflight)
 Context orchestrator-state preflight (ORCHESTRATOR_STATE_PREFLIGHT_FAILED)
   [+] blocks gh pr create --body-file when the checkpoint is missing 32ms (30ms|2ms)
   [+] blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails 29ms (28ms|0ms)
 Context script entrypoint (end-to-end)
   [+] blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE) 630ms (628ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1'
Describing enforce-pr-author-skill.ps1 payload envelope
 Context entry-point exit code and emitted decision (AC-4, no child process)
   [+] returns exit code 0 and emits a deny when every transport is empty 21ms (20ms|2ms)
   [+] returns exit code 0 and emits a deny for unparseable JSON 9ms (8ms|1ms)
   [+] returns exit code 0 and emits a deny for JSON with no tool_input key 8ms (7ms|1ms)
   [+] returns exit code 0 and emits a deny for the legacy flat root shape 8ms (7ms|1ms)
   [+] returns exit code 0 and emits a deny for a null tool_input 7ms (6ms|1ms)
   [+] returns exit code 0 and emits a deny for a non-object tool_input 7ms (7ms|1ms)
 Context nested envelope reaches the existing decision logic (AC-7)
   [+] denies a nested gh pr create carrying an inline --body 22ms (21ms|1ms)
   [+] allows a nested Bash command outside the gate scope 12ms (12ms|1ms)
   [+] allows a well-formed tool_input that carries no command property (scope filter) 9ms (9ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 target resolution
 Context the checkpoint is taken from the resolved target, not the session root
   [+] validates the sibling worktree checkpoint when --head names another worktree 406ms (405ms|2ms)
   [+] uses the absolute session-root checkpoint path when the target resolves to the session root 310ms (310ms|1ms)
 Context an underivable target denies instead of answering from unrelated state
   [+] denies with the no-target code when the call names no target 29ms (28ms|1ms)
   [+] denies with the ambiguity code when signals disagree 388ms (387ms|1ms)
   [+] never reports success on a sibling checkpoint: the false-approval case of defect 3.2 29ms (28ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1'
Describing enforce-pr-author-skill trigger scoping (issue #545)
 Context over-match removal - a quoted mention is not an invocation
   [+] allows a quoted --body-file mention inside a JSON receipt value 23ms (21ms|2ms)
 Context under-match removal - a relocating spelling now classifies
   [+] classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md 30ms (29ms|1ms)
   [+] classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md 31ms (31ms|1ms)
 Context flag distinction - --body does not match --body-file
   [+] does not match --body against a --body-file token 40ms (38ms|1ms)
 Context wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test
   [+] wrapper deny pin 1: classifies a gh pr create relocated through xargs 56ms (55ms|1ms)
   [+] wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument 35ms (34ms|1ms)
   [+] wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument 32ms (31ms|1ms)
   [+] wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper 31ms (31ms|1ms)
   [+] wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper 117ms (116ms|1ms)
   [+] wrapper deny pin 6: classifies a heredoc body piped into bash 84ms (83ms|1ms)
   [+] wrapper deny pin 7: classifies a live substitution inside a double-quoted span 64ms (64ms|1ms)
 Context every PR_* reason code is still produced for its genuine triggering invocation
   [+] PR_AUTHOR_SKILL_BLOCKED for gh pr create with no body flag 57ms (55ms|2ms)
   [+] PR_CONTEXT_MISSING for gh pr create --body-file when the context artifact is absent 64ms (63ms|1ms)
   [+] PR_BODY_PATH_NONCANONICAL for a --body-file path outside the canonical pattern 72ms (71ms|1ms)
   [+] PR_AUTHOR_RECEIPT_MISSING when the sibling receipt is absent 74ms (73ms|1ms)
   [+] PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when the receipt number does not equal the path number 70ms (69ms|1ms)
   [+] PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body hash does not equal the recorded hash 82ms (81ms|1ms)
   [+] PR_AUTHOR_RECEIPT_STALE when created_at is not newer than the context last-write 61ms (60ms|1ms)
 Context R-2.c wrapper-led body flags
   [+] R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument 37ms (36ms|1ms)
   [+] R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case 35ms (34ms|1ms)
   [+] R2c-N1 still routes a non-wrapper --body-file edit to the context check 25ms (25ms|1ms)
   [+] R2c-N2 still allows a quoted --body mention inside a JSON receipt value 18ms (17ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1'
Describing enforce-pr-author-skill.ps1 worktree-resolution matrix
  [+] pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root 515ms (514ms|1ms)
  [+] pr-author R1 allows when the branch locates the own ready checkpoint from the sibling session root 338ms (338ms|0ms)
  [+] pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present 25ms (24ms|0ms)
  [+] pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready 336ms (335ms|1ms)
  [+] pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target 276ms (276ms|1ms)
  [+] pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready 332ms (332ms|0ms)
  [+] pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present 311ms (310ms|0ms)
  [+] pr-author R5 denies with the no-target code when the command names no target 17ms (16ms|0ms)
  [+] pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready 255ms (254ms|0ms)
  [+] pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable 244ms (243ms|0ms)
  [+] pr-author R7 denies with the preflight reason when the resolved checkpoint is empty 226ms (226ms|0ms)
  [+] pr-author R8 denies with the no-target code when the branch is checked out in no live worktree 320ms (320ms|0ms)
  [+] pr-author R9 denies with the ambiguity code when the branch is checked out in two live worktrees 408ms (405ms|3ms)
  [+] pr-author R10 allows a command that is not a gated gh pr invocation when the target is unresolvable 15ms (15ms|0ms)
  [+] pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions 240ms (240ms|0ms)
  [+] pr-author denies an unresolved NoTarget target without reaching the orchestrator-state preflight 219ms (218ms|1ms)
  [+] pr-author denies an unresolved Ambiguous target without reaching the orchestrator-state preflight 211ms (211ms|0ms)
  [+] pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check 223ms (223ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1'
Describing enforce-pr-author-skill.ps1 - Test-EpicBaseBranchOverride
 Context epic_mode is false or absent (no-op/allow)
   [+] allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null) 12ms (11ms|1ms)
   [+] allows when the checkpoint has epic_mode: false 9ms (9ms|0ms)
   [+] allows a non-create command regardless of epic_mode (gh pr edit is out of scope) 8ms (7ms|0ms)
 Context epic_mode is true with the correct --base (allow)
   [+] allows when --base matches epic_context.integration_branch exactly 12ms (11ms|1ms)
 Context epic_mode is true with a missing --base (deny EPIC_BASE_BRANCH_MISMATCH)
   [+] denies when --base is absent from the command text 12ms (11ms|1ms)
 Context epic_mode is true with a mismatched --base (deny EPIC_BASE_BRANCH_MISMATCH)
   [+] denies when --base names a different branch than epic_context.integration_branch 13ms (12ms|1ms)
   [+] denies when epic_mode is true but epic_context.integration_branch is missing 8ms (8ms|0ms)
 Context end-to-end via Invoke-PrAuthorSkillDecision (sixth check wired into the receipt path)
   [+] denies EPIC_BASE_BRANCH_MISMATCH end-to-end when epic_mode is true and --base is missing 55ms (55ms|1ms)
   [+] allows end-to-end when epic_mode is true and --base matches 46ms (45ms|0ms)
 Context issue #663 epic scope
   [+] issue #663 epic scope allows --base main end-to-end 56ms (55ms|1ms)
   [+] issue #663 epic scope denies --base development with EPIC_BASE_BRANCH_MISMATCH 49ms (49ms|0ms)
   [+] issue #663 epic scope denies --base epic/sample-epic-integration with EPIC_BASE_BRANCH_MISMATCH 47ms (46ms|0ms)
   [+] issue #663 epic scope denies a missing --base with EPIC_BASE_BRANCH_MISMATCH 43ms (43ms|0ms)
   [+] issue #663 epic scope reads the epic checkpoint once per gh pr create call 44ms (44ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1'
Describing Test-EpicBaseBranchOverride trigger scoping (issue #545)
 Context under-match removal - a relocating spelling now classifies
   [+] classifies gh --repo drmoisan/drm-copilot pr create --base epic/x where it is skipped today 14ms (13ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
   [+] no longer reports EPIC_BASE_BRANCH_MISMATCH for a quoted mention of the gh pr create phrase 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1'
Describing Test-OrchestratorStatePrCreationReadiness
 Context PR-creation-ready checkpoint
   [+] returns ExitCode 0 and empty Output for a ready checkpoint 45ms (43ms|1ms)
 Context rejection conditions
   [+] returns ExitCode 1 for a missing required key 10ms (9ms|1ms)
   [+] returns ExitCode 1 when a readiness step is pending 9ms (9ms|0ms)
   [+] returns ExitCode 1 when a readiness step is blocked 13ms (13ms|0ms)
   [+] returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit 8ms (8ms|0ms)
   [+] returns ExitCode 1 when blocked_reason is set to a non-none value 9ms (8ms|0ms)
   [+] returns ExitCode 1 when local_execution_overrides is a non-empty list 8ms (8ms|0ms)
   [+] returns ExitCode 1 with a base error when blocked_reason is outside the allowed vocabulary 11ms (11ms|0ms)
 Context fail-closed conditions
   [+] returns ExitCode 1 when the checkpoint file is missing 8ms (7ms|1ms)
   [+] returns ExitCode 1 when the checkpoint file exists but is empty 7ms (7ms|0ms)
   [+] returns ExitCode 1 when the checkpoint root is not a JSON object 7ms (6ms|0ms)
   [+] returns ExitCode 1 when the checkpoint is not valid JSON 7ms (7ms|0ms)

Describing Invoke-OrchestratorStatePreflight
 Context Invoke-OrchestratorStatePreflight (direct seam tests)
   [+] reports HasErrors when the injected $Invoker returns a non-zero exit code 4ms (3ms|1ms)
   [+] reports no errors when the injected $Invoker returns exit 0 3ms (2ms|0ms)
   [+] reports HasErrors with empty ErrorText when the injected $Invoker returns a non-zero exit with no output 3ms (2ms|0ms)
   [+] defaults ExitCode/Output when the injected $Invoker result carries neither property 2ms (2ms|0ms)
 Context default invoker (portable path is the only path)
   [+] blocks a not-ready checkpoint with ORCHESTRATOR_STATE_PREFLIGHT_FAILED through the default path 111ms (110ms|1ms)
   [+] invokes the portable readiness function as the default, with no branch to bypass it 26ms (26ms|0ms)
   [+] names no python, python3, py, or poetry command anywhere in the default invoker 15ms (14ms|0ms)
   [+] allows the preflight to pass when both portable legs report a ready checkpoint 12ms (12ms|0ms)
   [+] fails the preflight for a checkpoint carrying a U-family violation 15ms (15ms|0ms)

Describing Get-OrchestratorStateBasePresenceError per-step-key status vocabulary
 Context per-key extra statuses accepted on their owning key
   [+] accepts step9_status value passed 7ms (5ms|2ms)
   [+] accepts step9_status value failed_remediation_required 1ms (1ms|0ms)
   [+] accepts step9_status value blocked_ci_loop_limit 1ms (1ms|0ms)
   [+] accepts step6_status value blocked_remediation_loop_limit 2ms (2ms|0ms)
 Context per-key extra statuses rejected on every non-owning key
   [+] rejects passed on step5_status 5ms (4ms|1ms)
   [+] rejects passed on step6_status 1ms (1ms|0ms)
   [+] rejects passed on step7_status 1ms (1ms|0ms)
   [+] rejects passed on step8_status 1ms (1ms|0ms)
   [+] rejects passed on step10_status 1ms (1ms|0ms)
   [+] rejects failed_remediation_required on step5_status 2ms (1ms|0ms)
   [+] rejects failed_remediation_required on step6_status 4ms (4ms|0ms)
   [+] rejects failed_remediation_required on step7_status 2ms (1ms|0ms)
   [+] rejects failed_remediation_required on step8_status 2ms (1ms|0ms)
   [+] rejects failed_remediation_required on step10_status 2ms (1ms|0ms)
   [+] rejects blocked_ci_loop_limit on step5_status 1ms (1ms|0ms)
   [+] rejects blocked_ci_loop_limit on step6_status 2ms (1ms|0ms)
   [+] rejects blocked_ci_loop_limit on step7_status 1ms (1ms|0ms)
   [+] rejects blocked_ci_loop_limit on step8_status 2ms (1ms|0ms)
   [+] rejects blocked_ci_loop_limit on step10_status 2ms (1ms|0ms)
   [+] rejects blocked_remediation_loop_limit on step5_status 1ms (1ms|0ms)
   [+] rejects blocked_remediation_loop_limit on step7_status 1ms (1ms|0ms)
   [+] rejects blocked_remediation_loop_limit on step8_status 2ms (1ms|0ms)
   [+] rejects blocked_remediation_loop_limit on step9_status 1ms (1ms|0ms)
   [+] rejects blocked_remediation_loop_limit on step10_status 1ms (1ms|0ms)
 Context epic-merge-gate regression scenario
   [+] passes base validation for an epic_mode checkpoint recording step9_status passed 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1'
Describing gate suites isolate the epic checkpoint read (structural guard)
  [+] tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 41ms (41ms|1ms)
  [+] tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 15ms (15ms|0ms)
  [+] tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 8ms (8ms|0ms)
  [+] tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 14ms (13ms|0ms)
  [+] tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 6ms (5ms|0ms)
  [+] tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 18ms (18ms|0ms)
  [+] tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 5ms (5ms|0ms)
  [+] tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 isolates the epic checkpoint read in its outermost BeforeAll 7ms (6ms|0ms)
 Context guard predicate discrimination
   [+] accepts the compliant positional form with zero findings 7ms (6ms|1ms)
   [+] accepts the compliant -CommandName and -MockWith form with zero findings 6ms (6ms|0ms)
   [+] rejects a Mock that targets another command with a finding containing "missing from outermost BeforeAll" 5ms (5ms|0ms)
   [+] rejects a Mock without -ModuleName with a finding containing "lacks -ModuleName" 3ms (3ms|0ms)
   [+] rejects a Mock body other than $null with a finding containing "not exactly" 3ms (3ms|0ms)
   [+] rejects a Mock declared only in a nested Context BeforeAll with a finding containing "missing from outermost BeforeAll" 3ms (2ms|0ms)
   [+] rejects an Import-Module with -Force with a finding containing "uses -Force" 4ms (3ms|0ms)
   [+] rejects an import and Mock placed before the hook dot-source with a finding containing "order violated" 3ms (3ms|0ms)
   [+] rejects a missing Get-WorktreeRunCheckpointText Mock with a finding containing "Mock of Get-WorktreeRunCheckpointText missing from outermost BeforeAll" 3ms (2ms|0ms)
   [+] rejects a Get-WorktreeRunCheckpointText Mock without -ModuleName with a finding containing "Mock lacks -ModuleName WorktreeRunResolution" 3ms (2ms|0ms)
   [+] rejects a missing WorktreeRunResolution import with a finding containing "Import-Module of WorktreeRunResolution.psm1 missing from outermost BeforeAll" 3ms (3ms|0ms)
   [+] rejects a WorktreeRunResolution import with -Force with a finding containing "Import-Module of WorktreeRunResolution.psm1 uses -Force" 3ms (2ms|0ms)
   [+] reports a listed suite path that does not exist and names the path 3ms (3ms|0ms)

Describing the run-checkpoint mocks block the epic-state read (seam sufficiency)
  [+] gate 1 control: the hostile payload is epic scope without the mocks 38ms (37ms|2ms)
  [+] gate 3 control: the hostile payload is epic scope without the mocks 14ms (13ms|0ms)
  [+] gate 4 control: the hostile payload is epic scope without the mocks 23ms (22ms|0ms)
  [+] gate 4 selector control: the hostile payload is epic scope without the mocks 15ms (15ms|0ms)
  [+] gate 1 treatment A: both $null mocks block the target lookup and the epic-state read 22ms (22ms|0ms)
  [+] gate 3 treatment A: both $null mocks block the target lookup and the epic-state read 16ms (15ms|0ms)
  [+] gate 4 treatment A: both $null mocks block the target lookup and the epic-state read 19ms (19ms|0ms)
  [+] gate 4 selector treatment A: both $null mocks block the target lookup and the epic-state read 20ms (19ms|0ms)
  [+] gate 1 treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read 24ms (23ms|0ms)
  [+] gate 3 treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read 15ms (15ms|0ms)
  [+] gate 4 treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read 18ms (18ms|0ms)
  [+] gate 4 selector treatment B: the Get-EpicScopeCheckpointText mock alone blocks the epic-state read 17ms (17ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1'
Describing enforce-pr-author-skill issue #824 decisions
 Context commands that mention gh pr create without invoking it
   [+] PA-01 allows R-733-714 18ms (17ms|1ms)
   [+] PA-02 allows the R-733-GREP G1 command 18ms (17ms|0ms)
   [+] PA-03 allows the R-733-GREP G2 command 15ms (14ms|0ms)
   [+] PA-04 allows the R-733-GREP G3 command 20ms (20ms|0ms)
   [+] PA-05 allows the fixture AC-18 Select-String command 14ms (14ms|0ms)
 Context body-file normalization and receipt verification
   [+] PA-06 reaches receipt verification for gh pr create --head bug/x-5 --body-file "artifacts/pr_body_5.md" 182ms (181ms|1ms)
   [+] PA-07 reaches receipt verification for gh pr create --head bug/x-5 --body-file=artifacts/pr_body_5.md 151ms (150ms|0ms)
   [+] PA-08 reaches receipt verification for gh pr create --head bug/x-5 --body-file /session/artifacts/pr_body_5.md 175ms (175ms|0ms)
   [+] PA-09 reaches receipt verification for gh pr create --head bug/x-5 --body-file ./artifacts/pr_body_5.md 157ms (156ms|0ms)
   [+] PA-10 reaches receipt verification for gh pr create --head bug/x-5 --body-file artifacts\pr_body_5.md 171ms (171ms|0ms)
   [+] PA-11 denies the non-canonical body file in gh pr create --head bug/x-5 --body-file docs/pr_body_5.md 157ms (157ms|0ms)
   [+] PA-12 denies the non-canonical body file in gh pr create --head bug/x-5 --body-file artifacts/pr_body_x.md 155ms (155ms|0ms)
   [+] PA-13 denies the non-canonical body file in gh pr create --head bug/x-5 --body-file /elsewhere/artifacts/pr_body_5.md 158ms (158ms|0ms)
   [+] PA-14 denies the non-canonical body file in echo --body-file artifacts/pr_body_5.md; gh pr create --head bug/x-5 --body-file notes/pr.md 229ms (229ms|0ms)
   [+] PA-15 denies the non-canonical body file in gh pr create --head bug/x-5 --body-file ../artifacts/pr_body_5.md 336ms (336ms|1ms)
   [+] PA-22 reads the body flags of an unmodeled-option create from its raw text 49ms (49ms|1ms)
   [+] PA-24 treats a create with no readable body-file value as non-canonical 31ms (31ms|1ms)
 Context inline-body and no-body pull requests
   [+] PA-16 denies gh pr create --head bug/x-5 with PR_AUTHOR_SKILL_BLOCKED 16ms (15ms|1ms)
   [+] PA-17 denies gh pr create --head bug/x-5 --body x with PR_AUTHOR_SKILL_BLOCKED 11ms (10ms|0ms)
   [+] PA-18 denies gh pr edit 5 --body x with PR_AUTHOR_SKILL_BLOCKED 8ms (7ms|0ms)
   [+] PA-19 denies bash -c "gh pr create --body x" with PR_AUTHOR_SKILL_BLOCKED 12ms (12ms|0ms)
   [+] PA-23 reads an inline body from the raw text of an unmodeled-option create 16ms (16ms|1ms)
   [+] PA-20 denies the G1 command when substring presence is reinstated 69ms (69ms|0ms)
 Context body-file root seam
   [+] PA-21 returns the current location as the body-file root 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1'
Describing Issue #824 regression: promotion gate (claude)
  [+] REG-01 allows R-824-MAIN, whose prose only contains the letters of gh issue new 31ms (31ms|1ms)

Describing Issue #824 regression: promotion gate (codex)
  [+] REG-01 allows R-824-MAIN, whose prose only contains the letters of gh issue new 60ms (59ms|1ms)

Describing Issue #824 regression: Claude epic worktree-removal gate
  [+] REG-02 allows R-824-ADD1, which removes a file and no worktree 22ms (21ms|1ms)
  [+] REG-03 allows R-742-1, git --version 9ms (9ms|0ms)

Describing Issue #824 regression: Claude parallel worktree-removal gate
  [+] REG-04 allows R-824-ADD1, which removes a file and no worktree 19ms (18ms|1ms)
  [+] REG-05 allows R-742-1, git --version 11ms (10ms|0ms)

Describing Issue #824 regression: Codex epic worktree-removal gate
  [+] REG-06 returns no decision for R-824-ADD1, which removes a file and no worktree 25ms (23ms|1ms)
  [+] REG-07 returns no decision for R-742-1, git --version 4ms (4ms|0ms)

Describing Issue #824 regression: preimplementation gate (claude)
  [+] REG-08 does not classify R-742-1, git --version, as an implementation command 12ms (11ms|1ms)

Describing Issue #824 regression: preimplementation gate (codex)
  [+] REG-08 does not classify R-742-1, git --version, as an implementation command 9ms (8ms|1ms)

Describing Issue #824 regression: Claude pr-author skill gate
 Context commands that mention gh pr create without invoking it (R-733-714, R-733-GREP)
   [+] REG-09 allows R-733-714, a commit whose heredoc body contains the letters of gh pr create 12ms (11ms|1ms)
   [+] REG-10 allows R-733-GREP G1, a Select-String search for a phrase 15ms (15ms|0ms)
   [+] REG-11 allows R-733-GREP G2, a grep inside a command substitution 22ms (21ms|0ms)
   [+] REG-12 allows R-733-GREP G3, a grep whose pattern is the literal gh pr create 6ms (6ms|0ms)
 Context body-file spellings reach receipt verification (R-733-715)
   [+] REG-13 accepts S1, a double-quoted body-file path 12ms (11ms|1ms)
   [+] REG-14 accepts S2, the --body-file=tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 form 10ms (10ms|0ms)
   [+] REG-15 accepts S3, an absolute path under the session root 13ms (12ms|0ms)
   [+] REG-16 accepts S4, a ./-prefixed relative path 10ms (10ms|0ms)
   [+] REG-17 accepts S5, a backslash-separated path 9ms (9ms|0ms)

Describing Issue #824 regression: pr-author command allowlist
  [+] REG-18 denies the R-733-712 chained receipt procedure 15ms (14ms|1ms)
  [+] REG-19 allows git log -1 --format=%H run alone 3ms (3ms|0ms)
  [+] REG-20 allows sha256sum artifacts/pr_body_5.md run alone 3ms (3ms|0ms)
  [+] REG-21 allows date -u +%Y-%m-%dT%H:%M:%SZ run alone 4ms (3ms|0ms)
Tests completed in 17.57s
Tests Passed: 246, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=247
PassedCount=246
FailedCount=1
FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
```
