# B3 Scoped Pester ([P3-T8])

Timestamp: 2026-09-25T19-29
Command: sh <SCRATCHPAD>/i663/run.sh p3-verify  (resolves tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1 with Get-ChildItem to repository-relative paths, then runs R-SCOPED over them)
EXIT_CODE: 0
Output Summary: The glob resolved to 9 files (the eight pre-existing pr-author suites plus the new EpicScope suite). PassedCount 121, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. All five G1 names and all five expanded `issue #663 epic scope` names are on PASSED lines.

Supplementary (not a plan gate): a scoped non-writing format check (`Files checked: 199; would format: 0`) and a scoped PSScriptAnalyzer run with the repository settings (no findings) over .claude/hooks, .claude/lib/worktree-resolution, .codex/hooks, tests/scripts/claude-hooks, tests/scripts/codex-hooks, and tests/scripts/claude-lib/worktree-resolution.

## Resolved Path List

```
tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
```

## Runner Output

```
Glob tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1 resolved to 9 files.
Resolved Run.Path:
  tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
  tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1

Starting discovery in 9 files.
Discovery found 121 tests in 304ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1
 1.28s (849ms|302ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
 132ms (88ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1
 335ms (269ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
 667ms (612ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1
 187ms (132ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1
 237ms (184ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1
 1.08s (894ms|151ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1
 532ms (430ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1
 876ms (816ms|47ms)
Tests completed in 5.35s
Tests Passed: 121, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 121
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null)
PASSED: allows when the checkpoint has epic_mode: false
PASSED: allows a non-create command regardless of epic_mode (gh pr edit is out of scope)
PASSED: allows when --base matches epic_context.integration_branch exactly
PASSED: denies when --base is absent from the command text
PASSED: denies when --base names a different branch than epic_context.integration_branch
PASSED: denies when epic_mode is true but epic_context.integration_branch is missing
PASSED: denies EPIC_BASE_BRANCH_MISMATCH end-to-end when epic_mode is true and --base is missing
PASSED: allows end-to-end when epic_mode is true and --base matches
PASSED: issue #663 epic scope allows --base main end-to-end
PASSED: issue #663 epic scope denies --base development with EPIC_BASE_BRANCH_MISMATCH
PASSED: issue #663 epic scope denies --base epic/sample-epic-integration with EPIC_BASE_BRANCH_MISMATCH
PASSED: issue #663 epic scope denies a missing --base with EPIC_BASE_BRANCH_MISMATCH
PASSED: issue #663 epic scope reads the epic checkpoint once per gh pr create call
PASSED: classifies gh --repo drmoisan/drm-copilot pr create --base epic/x where it is skipped today
PASSED: no longer reports EPIC_BASE_BRANCH_MISMATCH for a quoted mention of the gh pr create phrase
PASSED: epic scope allows gh pr create --head integration_branch --base main when every feature is merged or worktree_removed
PASSED: epic scope denies when a feature has a non-terminal merge_status and names the epic checkpoint and merge_status
PASSED: epic scope denies when features is empty and names the epic checkpoint and features
PASSED: without an epic checkpoint the call takes the unchanged per-feature path and is denied by its resolution
PASSED: a per-feature pull request whose --head differs from integration_branch gets the same decision and reason as with no epic checkpoint
PASSED: blocks gh pr create --body-file when the checkpoint is missing
PASSED: blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails
PASSED: blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits a deny for unparseable JSON
PASSED: returns exit code 0 and emits a deny for JSON with no tool_input key
PASSED: returns exit code 0 and emits a deny for the legacy flat root shape
PASSED: returns exit code 0 and emits a deny for a null tool_input
PASSED: returns exit code 0 and emits a deny for a non-object tool_input
PASSED: denies a nested gh pr create carrying an inline --body
PASSED: allows a nested Bash command outside the gate scope
PASSED: allows a well-formed tool_input that carries no command property (scope filter)
PASSED: validates the sibling worktree checkpoint when --head names another worktree
PASSED: uses the absolute session-root checkpoint path when the target resolves to the session root
PASSED: denies with the no-target code when the call names no target
PASSED: denies with the ambiguity code when signals disagree
PASSED: never reports success on a sibling checkpoint: the false-approval case of defect 3.2
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows when JSON has no command field
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: blocks gh pr create --body "inline string"
PASSED: blocks gh pr create --body='inline' (equals-sign form)
PASSED: blocks gh pr edit --body "inline text" (no --body-file)
PASSED: blocks gh pr edit --body='inline' (equals-sign form, no --body-file)
PASSED: allows gh pr edit --title "x" (no body flag remains allowed)
PASSED: blocks gh pr create with no body flags
PASSED: blocks gh pr create --title foo with no body flags
PASSED: blocks gh pr create --body-file artifacts/pr_body_12.md when context is absent
PASSED: blocks gh pr edit --body-file artifacts/pr_body_12.md when context is absent
PASSED: allows gh pr create --body-file artifacts/pr_body_12.md when context exists
PASSED: allows gh pr edit --body-file artifacts/pr_body_12.md when context exists
PASSED: allows gh pr edit --title "new title" (no body flag)
PASSED: allows gh pr edit --add-label bug (no body flag)
PASSED: allows gh pr view 13
PASSED: allows gh pr list
PASSED: allows gh pr merge
PASSED: allows gh pr checkout 13
PASSED: allows gh issue create (not guarded by this hook)
PASSED: blocks a --body-file artifacts/pr_body.md (no number) with PR_BODY_PATH_NONCANONICAL
PASSED: blocks with PR_AUTHOR_RECEIPT_MISSING when the receipt read seam returns null
PASSED: blocks with PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when receipt.number does not match the path number
PASSED: blocks with PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body SHA-256 does not match receipt.sha256
PASSED: blocks with PR_AUTHOR_RECEIPT_STALE when created_at is not strictly newer than the context last-write
PASSED: allows when all six receipt checks pass
PASSED: returns null for allowed command
PASSED: returns PR_AUTHOR_SKILL_BLOCKED for inline --body
PASSED: returns PR_CONTEXT_MISSING when --body-file present but context absent
PASSED: Get-PrAuthorSkillBlockDecision yields hookEventName=PreToolUse and permissionDecision=deny after serialize-then-parse
PASSED: Get-PrAuthorSkillAllowDecision yields permissionDecision=allow
PASSED: returns false for an allowed command
PASSED: returns true for a blocked command (inline --body)
PASSED: returns true when context is missing for --body-file command
PASSED: returns a boolean result without throwing
PASSED: returns $null when the body-file path does not exist
PASSED: returns the raw bytes when the path exists (points at the hook script itself)
PASSED: returns $null when the receipt path does not exist
PASSED: returns the raw file text when the receipt path exists (points at the hook script itself)
PASSED: returns $null when the context summary path does not exist
PASSED: returns a UTC DateTime when the context path exists (points at the hook script itself)
PASSED: blocks gh pr create with no body flags regardless of context artifact
PASSED: allows a quoted --body-file mention inside a JSON receipt value
PASSED: classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md
PASSED: classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md
PASSED: does not match --body against a --body-file token
PASSED: wrapper deny pin 1: classifies a gh pr create relocated through xargs
PASSED: wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument
PASSED: wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument
PASSED: wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper
PASSED: wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper
PASSED: wrapper deny pin 6: classifies a heredoc body piped into bash
PASSED: wrapper deny pin 7: classifies a live substitution inside a double-quoted span
PASSED: PR_AUTHOR_SKILL_BLOCKED for gh pr create with no body flag
PASSED: PR_CONTEXT_MISSING for gh pr create --body-file when the context artifact is absent
PASSED: PR_BODY_PATH_NONCANONICAL for a --body-file path outside the canonical pattern
PASSED: PR_AUTHOR_RECEIPT_MISSING when the sibling receipt is absent
PASSED: PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when the receipt number does not equal the path number
PASSED: PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body hash does not equal the recorded hash
PASSED: PR_AUTHOR_RECEIPT_STALE when created_at is not newer than the context last-write
PASSED: R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument
PASSED: R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case
PASSED: R2c-N1 still routes a non-wrapper --body-file edit to the context check
PASSED: R2c-N2 still allows a quoted --body mention inside a JSON receipt value
PASSED: pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root
PASSED: pr-author R1 allows when the branch locates the own ready checkpoint from the sibling session root
PASSED: pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present
PASSED: pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready
PASSED: pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target
PASSED: pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready
PASSED: pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present
PASSED: pr-author R5 denies with the no-target code when the command names no target
PASSED: pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready
PASSED: pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable
PASSED: pr-author R7 denies with the preflight reason when the resolved checkpoint is empty
PASSED: pr-author R8 denies with the no-target code when the branch is checked out in no live worktree
PASSED: pr-author R9 denies with the ambiguity code when the branch is checked out in two live worktrees
PASSED: pr-author R10 allows a command that is not a gated gh pr invocation when the target is unresolvable
PASSED: pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions
PASSED: pr-author denies an unresolved NoTarget target without reaching the orchestrator-state preflight
PASSED: pr-author denies an unresolved Ambiguous target without reaching the orchestrator-state preflight
PASSED: pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check
RSCOPED_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```
