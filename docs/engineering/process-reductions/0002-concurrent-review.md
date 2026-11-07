# 0002: Concurrent review

## Summary

reduction: 0002
Date: 2026-11-07
Issue: #1097
Merge commit: pending (PR #1097)

Moves the feature review from before pull-request creation to beside CI. A new run records `review_mode: "concurrent"`, opens its pull request after the local test run passes, and runs the review and CI at the same time. The merge waits for both. The number in the `Merge commit:` line is the canonical issue number, which stands in until the pull request exists. The orchestrator replaces it with the real pull request number right after PR creation.

Renumbered from 0001, because PR #1102 took that number on `main` first. The reduction commit's subject carries the token `reduction: 0001` and cannot be rewritten without a forced push; the renumbering commit's subject carries `reduction: 0002`. Find the reduction by its commit subject, `feat(orchestrate): run the feature review beside CI`, or by `reduction: 0002`.

## Reason and Evidence

The reduction removes the wait of CI behind review, as research section 6 of `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` describes. The owner's condition is that merge stays impossible without a passing review and green CI, so the merge guard `enforce-epic-merge-gate-review.ps1` landed first, in its own commit, inert without the key. This entry records the relaxation that the guard makes safe. The time saved is unknown until stage timing has data.

## Files Changed

- `.claude/skills/orchestrate/SKILL.md`
- `.agents/skills/orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/rules/orchestrator-state.md`
- `.claude/agents/orchestrator.md`
- `.agents/skills/orchestrator-state/SKILL.md`
- `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`
- `scripts/dev_tools/validate_orchestrator_state.py`
- `.claude/lib/orchestrator-state/OrchestratorState.psm1`
- `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`
- `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`
- `extensions/drm-copilot/jest.config.cjs`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-state/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`, a byte-identical bundle copy
- `scripts/dev_tools/_orchestrator_state_concurrent_review.py`, new
- `tests/scripts/dev_tools/test_orchestrator_state_concurrent_review.py`, new
- `tests/fixtures/orchestrator_state_concurrent_review/` (twelve corpus files), new
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-concurrent-review.ts`, new
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-concurrent-review.test.ts`, new
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateConcurrentReview.Tests.ps1`, new
- `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1`, new
- `docs/engineering/process-reductions/README.md`, the index row of this entry

## Prior Text

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current
## Concurrent Review and CI (review_mode)

This section applies to a run whose checkpoint records `review_mode: "concurrent"` (issue #1097). The feature review and CI then run at the same time on an open pull request, and the merge waits for both. A run without that value is sequential and follows every other section of this skill unchanged.

1. **New-run default.** The first checkpoint write of a new run records `review_mode: "concurrent"` when the route opens a pull request and the target worktree holds the guard file `.claude/hooks/enforce-epic-merge-gate-review.ps1`. Without that file the run stays sequential, because a skill newer than its hooks would otherwise stop at readiness.
2. **Resume.** A run that resumes a checkpoint without the key stays sequential, and the key is never added on resume. A sequential run follows every other section unchanged.
3. **Sequence.** The local parallel test run passes; commit, with the steps of `## Pre-Feature-Review Commit` running here, before the pull request; open the pull request; a run with a ledger entry commits the entry's pull-request number next, before reading `head_sha`; run the `feature-review` delegation and CI together; join; merge.
4. **Recording.** Every `remediation_loop.review_outcomes[]` entry carries `head_sha`: the full lowercase head of the pushed branch, read before the review delegation.
5. **Join.** The merge proceeds only when all of these hold: the last `review_outcomes[]` entry has verdict `PASS` at a current head; `ci_gate.conclusion` is `success` at the live head; and a `CI full run` check with conclusion `success` exists at the reviewed head, or at an ancestor of it whose diff to the reviewed head lists only `feature-folder` paths. A reviewed head is current when it equals the live head, or when it is an ancestor of the live head and the diff between them lists only `feature-folder` paths; this is the rule of the merge guard. The `CI full run` check is required because a docs-only head reports success without the heavy suites.
6. **Moved conditions.** Conditions 1 and 2 of `## PR Creation Gate` apply at the join, not before the pull request. S9 steps 6 and 7, and DONE, run only after the join. A parallel child still never merges itself.
7. **Re-entry.** Any code push after a `PASS`, including a CI fix or a merge of `origin/main`, is a stale head and requires a new review and a new S9 pass. Commits inside `feature-folder`, such as review artifacts and stage-timing evidence, do not. Ledger back-fills lie outside `feature-folder`, so they land before the review starts.
8. **Portable handoff.** The destination projection is a closed key set and drops `review_mode`, so a concurrent run is not handed off between pull-request creation and the join.
9. **Validators and deny codes.** Readiness stops rejecting `step7_status: pending` only under the key, and `require_complete` then requires the last `PASS` entry with `head_sha`. The TypeScript rule reaches the MCP validator only after an extension release. Until then installed MCP accepts a checkpoint that the PowerShell stop hook and the Python CLI reject, so check a concurrent checkpoint with the repository-local Python validator CLI, in its `orchestrator-state` mode with `--require-complete`. The merge guard denies with `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, or `REVIEW_GATE_HEAD_UNRESOLVED`, each after the token `EPIC_MERGE_GATE_BLOCKED`. The merge is issued as its own Bash call, and any other form is denied with `REVIEW_GATE_HEAD_UNRESOLVED`.
10. **Step order.** `completed_steps` stays in canonical order, because `.claude/hooks/enforce-checkpoint-monotonic.ps1` denies a checkpoint Write that lists `S8_create_pr` before `S7_feature_review`. When the review completes, insert `S7_feature_review` before the existing `S8_create_pr` entry; do not append it. A later review adds no second entry. `step8_status` is `in_progress` at pull-request creation, because readiness rejects `pending`, and it stays `in_progress` until the join, because `.claude/hooks/enforce-completion-consistency.ps1` reads `completed` there as a completion claim and denies a checkpoint Write whose `ci_gate.conclusion` is not `success`. A `completed` value would therefore deny the `ci_gate` write of every re-entry.


````

````Prior
````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current
## Concurrent Review and CI (review_mode)

This section applies to a run whose checkpoint records `review_mode: "concurrent"` (issue #1097). The feature review and CI then run at the same time on an open pull request, and the merge waits for both. A run without that value is sequential and follows every other section of this skill unchanged.

1. **New-run default.** The first checkpoint write of a new run records `review_mode: "concurrent"` when the route opens a pull request and the target worktree holds the guard file `.codex/hooks/enforce-epic-merge-gate-review.ps1`. Without that file the run stays sequential, because a skill newer than its hooks would otherwise stop at readiness.
2. **Resume.** A run that resumes a checkpoint without the key stays sequential, and the key is never added on resume. A sequential run follows every other section unchanged.
3. **Sequence.** The local parallel test run passes; commit, with the steps of `## Pre-Review Commit` running here, before the pull request; open the pull request; a run with a ledger entry commits the entry's pull-request number next, before reading `head_sha`; run the `feature-reviewer` delegation and CI together; join; merge.
4. **Recording.** Every `remediation_loop.review_outcomes[]` entry carries `head_sha`: the full lowercase head of the pushed branch, read before the review delegation.
5. **Join.** The merge proceeds only when all of these hold: the last `review_outcomes[]` entry has verdict `PASS` at a current head; `ci_gate.conclusion` is `success` at the live head; and a `CI full run` check with conclusion `success` exists at the reviewed head, or at an ancestor of it whose diff to the reviewed head lists only `feature-folder` paths. A reviewed head is current when it equals the live head, or when it is an ancestor of the live head and the diff between them lists only `feature-folder` paths; this is the rule of the merge guard. The `CI full run` check is required because a docs-only head reports success without the heavy suites.
6. **Moved conditions.** Conditions 1 and 2 of `## PR Creation Gate` apply at the join, not before the pull request. The merge and DONE of `## CI Green Gate` run only after the join. A parallel child still never merges itself.
7. **Re-entry.** Any code push after a `PASS`, including a CI fix or a merge of `origin/main`, is a stale head and requires a new review and a new `## CI Green Gate` pass. Commits inside `feature-folder`, such as review artifacts and stage-timing evidence, do not. Ledger back-fills lie outside `feature-folder`, so they land before the review starts.
8. **Portable handoff.** The destination projection is a closed key set and drops `review_mode`, so a concurrent run is not handed off between pull-request creation and the join.
9. **Validators and deny codes.** Readiness stops rejecting `step7_status: pending` only under the key, and `require_complete` then requires the last `PASS` entry with `head_sha`. The TypeScript rule reaches the MCP validator only after an extension release. Until then installed MCP accepts a checkpoint that the PowerShell stop hook and the Python CLI reject, so check a concurrent checkpoint with the repository-local Python validator CLI, in its `orchestrator-state` mode with `--require-complete`. The merge guard denies with `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, or `REVIEW_GATE_HEAD_UNRESOLVED`, each after the token `EPIC_MERGE_GATE_BLOCKED`. The merge is issued as its own Bash call, and any other form is denied with `REVIEW_GATE_HEAD_UNRESOLVED`.
10. **Step order.** `completed_steps` stays in canonical order, because `.codex/hooks/enforce-checkpoint-monotonic.ps1` denies a checkpoint Write that lists `S8_create_pr` before `S7_feature_review`. When the review completes, insert `S7_feature_review` before the existing `S8_create_pr` entry; do not append it. A later review adds no second entry. `step8_status` is `in_progress` at pull-request creation, because readiness rejects `pending`, and it stays `in_progress` until the join, because `.codex/hooks/enforce-completion-consistency.ps1` reads `completed` there as a completion claim and denies a checkpoint Write whose `ci_gate.conclusion` is not `success`. A `completed` value would therefore deny the `ci_gate` write of every re-entry.


````

````Prior
````

### Revert Block: .claude/skills/parallel-orchestrate/SKILL.md

````Current
   **Concurrent review.** When the child checkpoint records `review_mode: "concurrent"`, do not
   record `merge_status: ci_green` and do not run `gh pr merge` until its last
   `review_outcomes[]` entry is `PASS` at a current head, as the join in
   `## Concurrent Review and CI (review_mode)` of `.claude/skills/orchestrate/SKILL.md` defines it;
   keep `merge_status: pr_open` and treat the item as not done. Issue #1097 amends
   `.claude/skills/orchestrate/SKILL.md` for every new run and adds no parallel-specific condition
   to the child's PR Creation Gate. The merge gate reads the child through the item target, so
   this step is the backstop when that target does not resolve.

````

````Prior
````

### Revert Block: .claude/rules/orchestrator-state.md

````Current
## Concurrent-Review Scope and Backward Compatibility

These rules apply only when a checkpoint contains the top-level key `review_mode` with the exact string `concurrent`, compared ordinally. An absent key, `null`, `sequential`, a case variant, a number, and every other value mean sequential, and a checkpoint without the key validates exactly as before: no `gh` call, no new denial, and no readiness relaxation. The key is tolerated and is not a member of `REQUIRED_STATE_KEYS`. `.claude/skills/orchestrate/SKILL.md` (`## Concurrent Review and CI (review_mode)`) defines the run sequence.

- **`head_sha`.** Each `remediation_loop.review_outcomes[]` entry of a concurrent run carries `head_sha`: the head the review ran against, a full lowercase object id of 40 or 64 characters. Plain validation does not read it.
- **Last-entry semantics.** Only the final `review_outcomes[]` element counts, so an earlier `PASS` never satisfies a rule.
- **Readiness.** Under the key, PR-creation readiness stops rejecting `step7_status` for the value `pending` only. `blocked`, and every other step, keep today's result. TypeScript has no readiness port.
- **Completion.** Under the key, `require_complete` appends exactly one of these strings after the existing completion checks, byte-identical in `scripts/dev_tools/_orchestrator_state_concurrent_review.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-concurrent-review.ts`, and `Get-OrchestratorStateCompletionConcurrentReviewError` in `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`, and pinned by the corpus `tests/fixtures/orchestrator_state_concurrent_review/`. The second is reported only when the first does not apply. Validators do no git work.
  - `Checkpoint completion validation failed: review_mode concurrent requires a last review_outcomes entry with verdict PASS.`
  - `Checkpoint completion validation failed: review_mode concurrent requires head_sha on the last review_outcomes entry.`
- **Merge guard.** `.claude/hooks/enforce-epic-merge-gate-review.ps1`, byte-identical at `.codex/hooks/`, runs before every allow branch of both merge gates. It denies with `REVIEW_GATE_NOT_PASSED`, `REVIEW_GATE_HEAD_STALE`, or `REVIEW_GATE_HEAD_UNRESOLVED`, each after the token `EPIC_MERGE_GATE_BLOCKED`. A later head is current only when the reviewed head is its ancestor and every path changed since then lies inside `feature-folder`, so a code change after the review, including a merge of `origin/main`, is stale. A merge must be one plain `gh pr merge` of one number as its own Bash call: under the key, text that could be a merge and cannot be bound to one pull request is denied with `REVIEW_GATE_HEAD_UNRESOLVED`, before any process and before the out-of-scope allow of both gates.
- **Validator route (D9).** The TypeScript rule reaches the MCP surface only after an extension release. Until then, installed MCP accepts a checkpoint that the PowerShell stop hook and the Python CLI reject, so a concurrent checkpoint is checked through the Python CLI.

Honest disclosure (D10): the guard is a policy-level control, not a security control. A writer in the same session can edit the checkpoint. A merge outside the Bash hook surface is not gated. A merge whose item target does not resolve (`NoTarget` or `Ambiguous`), or whose child checkpoint does not parse, sees no key, and the parallel skill step is then the only backstop. A push after the lookup can change the head unless the command passes `--match-head-commit`. The `CI full run` requirement of the join is skill-level, because a docs-only head passes `CI Required Gate`. The authorization path reads no CI result, so the required `CI Required Gate` context is the control there. A text scan cannot read every merge: a script file performing the merge cannot be read, and neither can encoded or run-time composed text, a `gh` alias or shell function from an earlier call, or an endpoint held in a variable. A merge through a tool other than Bash is not gated: the Claude PowerShell tool and `mcp__*` tools, because the gate is registered on the `Bash` matcher only, and the Codex `shell_command` tool, because the gate is registered under `^Bash$` and returns for any other tool name. An already-queued auto-merge fires with no command, and `gh pr merge <PR> --disable-auto` removes it. A direct push to the base branch is not a pull-request merge, and the gate does not read it. A number-less merge text sees only the session checkpoint, so a key in another worktree is not found. The extra checkpoint read of the shape rule is best-effort: a failed read sees no key and keeps the decision of a run without the key. Under the key the rule is fail-closed, so prose containing `pr merge` is denied in any command, including `git commit -m` and `grep`. This trade is accepted because only concurrent runs carry the key and a merge is issued in its own call.


````

````Prior
````

### Revert Block: .claude/agents/orchestrator.md

````Current
- `review_outcomes[]` — one entry per review, including `PASS`, appended in order. Each entry is an object with `verdict` (one of `PASS`, `REMEDIATION_REQUIRED`, `HALT_NON_REMEDIABLE`, `AWAITING_CI`) and `findings[]`, the review's blocking findings only, each an object with `remediability` (one of `autonomous`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`). An optional `inputs_path` names the `remediation-inputs` file. Under top-level `review_mode: "concurrent"`, each entry also carries `head_sha`, the head the review ran against; see `## Concurrent Review and CI (review_mode)` in `.claude/skills/orchestrate/SKILL.md`.

````

````Prior
- `review_outcomes[]` — one entry per review, including `PASS`, appended in order. Each entry is an object with `verdict` (one of `PASS`, `REMEDIATION_REQUIRED`, `HALT_NON_REMEDIABLE`, `AWAITING_CI`) and `findings[]`, the review's blocking findings only, each an object with `remediability` (one of `autonomous`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`). An optional `inputs_path` names the `remediation-inputs` file.

````

### Revert Block: scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py

````Current
    - Under `review_mode: "concurrent"`, a `pending` `step7_status` does not
      block, because the review runs beside CI after the PR opens.

````

````Prior
````

### Revert Block: scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py

````Current
        `gh pr create` of a branch has already succeeded. Under
        `review_mode: "concurrent"`, a pending `step7_status` is allowed.

````

````Prior
        `gh pr create` of a branch has already succeeded.

````

### Revert Block: scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py

````Current
        # Under `review_mode: concurrent` the review runs beside CI after the
        # PR opens, so a pending review is expected here; the merge guard holds
        # the merge until it passes. `blocked` and every other step still block.
        if (
            key == "step7_status"
            and value == "pending"
            and state.get("review_mode") == "concurrent"
        ):
            continue

````

````Prior
````

### Revert Block: scripts/dev_tools/validate_orchestrator_state.py

````Current
from scripts.dev_tools._orchestrator_state_concurrent_review import (
    validate_concurrent_review_completion,
)

````

````Prior
````

### Revert Block: scripts/dev_tools/validate_orchestrator_state.py

````Current
        errors.extend(validate_concurrent_review_completion(state_map))

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorState.psm1

````Current
        blocked_remediation_loop_limit, except a pending step 7 under review_mode concurrent;
        blocked_reason must be `none` or absent; and the

````

````Prior
        blocked_remediation_loop_limit; blocked_reason must be `none` or absent; and the

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorState.psm1

````Current
    $stateNames = @($State.PSObject.Properties | ForEach-Object { $_.Name })
    $reviewMode = if ($stateNames -ccontains 'review_mode') { (Get-OrchestratorStateField -State $State -Name 'review_mode').Value } else { $null }

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorState.psm1

````Current
        # Under review_mode concurrent the review runs beside CI and the merge guard holds the merge.
        if ($key -ceq 'step7_status' -and $field.Value -ceq 'pending' -and $reviewMode -is [string] -and $reviewMode -ceq 'concurrent') { continue }

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current
    Portable completion-gate checks C1, C2, C3, C4, C5, C7, and C8.

````

````Prior
    Portable completion-gate checks C1, C2, C3, C4, C5, and C7.

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current
      C8    last review outcome under review_mode concurrent (value-gated)

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current
function Get-OrchestratorStateCompletionConcurrentReviewError {
    <#
    .SYNOPSIS
        Return the review-record error under review_mode concurrent (row C8).
    .DESCRIPTION
        Mirrors validate_concurrent_review_completion. Only the exact string concurrent
        activates the check, and only the final review_outcomes element counts. The head
        error is reported only when the verdict error does not apply. The check does no
        git work: head currency stays with the merge guard.
    .PARAMETER State
        The parsed checkpoint object.
    .OUTPUTS
        System.String[] - zero or one error string.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $State
    )

    $mode = $null
    if ((Get-CheckpointObjectMemberName -Owner $State) -ccontains 'review_mode') { $mode = (Get-CheckpointObjectMember -Owner $State -Name 'review_mode').Value }
    if (-not (($mode -is [string]) -and ($mode -ceq 'concurrent'))) {
        return [string[]]@()
    }

    # A missing loop, a non-list value, an empty list, and a non-object last entry all
    # leave $last unset, so each reports the verdict error.
    $last = $null
    $loop = (Get-CheckpointObjectMember -Owner $State -Name 'remediation_loop').Value
    $outcomes = (Get-CheckpointObjectMember -Owner $loop -Name 'review_outcomes').Value
    if ((Test-CheckpointListValue -Value $outcomes) -and $outcomes.Count -gt 0) {
        $last = $outcomes[$outcomes.Count - 1]
    }
    $verdict = (Get-CheckpointObjectMember -Owner $last -Name 'verdict').Value
    if (-not (($verdict -is [string]) -and ($verdict -ceq 'PASS'))) {
        return [string[]]@('Checkpoint completion validation failed: review_mode concurrent requires a last review_outcomes entry with verdict PASS.')
    }

    $head = (Get-CheckpointObjectMember -Owner $last -Name 'head_sha').Value
    if (-not (($head -is [string]) -and ($head -cmatch '\A[0-9a-f]{40}([0-9a-f]{24})?\z'))) {
        return [string[]]@('Checkpoint completion validation failed: review_mode concurrent requires head_sha on the last review_outcomes entry.')
    }
    return [string[]]@()
}


````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1

````Current
    Get-OrchestratorStatePreparationTerminalError, `
    Get-OrchestratorStateCompletionConcurrentReviewError

````

````Prior
    Get-OrchestratorStatePreparationTerminalError

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1

````Current
      C8        the review record under review_mode concurrent

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1

````Current
    # blocked_reason, pr_gate, ci_gate, phase completeness, routing contract, the
    # preparation terminal contract, and the concurrent review record.

````

````Prior
    # blocked_reason, pr_gate, ci_gate, phase completeness, routing contract, and
    # the preparation terminal contract.

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1

````Current
    $errors.AddRange([string[]]@(Get-OrchestratorStateCompletionConcurrentReviewError -State $state))

````

````Prior
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts

````Current
import { validateConcurrentReviewCompletion } from "./orchestrator-state-concurrent-review";

````

````Prior
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts

````Current
 *       contract, the routing contract, and the concurrent review record.

````

````Prior
 *       contract, and the routing contract.

````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts

````Current
    errors.push(...validateConcurrentReviewCompletion(stateMap));

````

````Prior
````

### Revert Block: extensions/drm-copilot/jest.config.cjs

````Current
    // Issue #1097: the completion rule under review_mode concurrent.
    "./src/lib/validate/orchestrator-state-concurrent-review.ts": {
      lines: 85,
      branches: 75,
    },

````

````Prior
````

### Revert Block: .agents/skills/orchestrator-state/SKILL.md

````Current
## Concurrent-Review Key (review_mode)

The top-level checkpoint key `review_mode` selects the concurrent run sequence. Only the exact string `concurrent`, compared ordinally, activates it; an absent key, `null`, `sequential`, a case variant, a number, and every other value mean sequential. Under the key, each `remediation_loop.review_outcomes[]` entry carries `head_sha`, the full lowercase head the review ran against. `## Concurrent Review and CI (review_mode)` in `.agents/skills/orchestrate/SKILL.md` defines the run sequence.


````

````Prior
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, in the order of this entry. Then delete `scripts/dev_tools/_orchestrator_state_concurrent_review.py`, `tests/scripts/dev_tools/test_orchestrator_state_concurrent_review.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-concurrent-review.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-concurrent-review.test.ts`, the folder `tests/fixtures/orchestrator_state_concurrent_review/`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateConcurrentReview.Tests.ps1`, and `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1`. Leave the merge guard in place, because it is inert without the key.
2. Re-copy mirrors and bundles: copy each of these to its bundle path under `extensions/drm-copilot/resources/`: `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, `.claude/agents/orchestrator.md`, and the three modules `OrchestratorState.psm1`, `OrchestratorStateCompletionChecks.psm1`, and `OrchestratorStateCompletion.psm1` under `claude-customizations/`, and `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrator-state/SKILL.md` under `codex-and-agents-customizations/`.
3. Regenerate Codex variants: not applicable, because no base agent variant changed; still run the generator `--check`.
4. Restore pinned hashes: not applicable, because no pinned surface moved.
5. Restore contract-test literals: not applicable, because no contract-test pin changed.
6. Run the contract tests: run `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_ci_gate_all_checks_contracts.py`, `test_parallel_orchestrator_surface_contracts.py`, `test_orchestration_guardrail_contracts.py`, `test_claude_rules_frontmatter.py`, `checkpoint-hygiene-skill-contract.Tests.ps1`, and `StageTimingDocumentation.Tests.ps1`.

## Revert Signals

- A merge later found to have skipped a review.
- A rise in `REVIEW_GATE_HEAD_STALE` denials or in re-reviews per item.
- More remediation cycles after CI fixes.
- No measured saving in stage-timing reports.
