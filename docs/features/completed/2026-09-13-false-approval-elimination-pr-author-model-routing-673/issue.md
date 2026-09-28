# false-approval-elimination-pr-author-model-routing (Issue #673)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/false-approval-elimination-pr-author-model-routing/ (Issue #673)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #673
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/673
- Last Updated: 2026-09-14
- Work Mode: full-bug

## Summary

The PR-creation readiness gate (`.claude/hooks/enforce-pr-author-skill.ps1` and siblings) and the
model-routing-receipt deterrent (`.claude/hooks/enforce-model-routing-receipt.ps1`) resolve the
orchestrator checkpoint from a fixed relative path, `artifacts/orchestration/orchestrator-state.json`,
against the invoking session's current working directory. In a parallel or epic topology the session
root holds a different item's checkpoint, so both gates validate one item's action against a sibling
item's state and return allow. This is a false approval: the reported green carries no information
about the item actually being gated.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (defect is platform-independent; hooks are PowerShell)
- Python version: not applicable — both hooks are PowerShell and must remain Python-free
- Command/flags used: `gh pr create ...` intercepted by `enforce-pr-author-skill.ps1`; `Agent(...)`
  delegation intercepted by `enforce-model-routing-receipt.ps1`
- Data source or fixture: two orchestrator-state checkpoints present simultaneously — one at the
  session root belonging to a sibling item, one in the item worktree belonging to the gated item

## Steps to Reproduce

1. Create a session root containing `artifacts/orchestration/orchestrator-state.json` that belongs to
   item A and is in a PR-creation-ready state.
2. Create a separate item worktree for item B whose own checkpoint is absent, or present and not ready.
3. From the session root, issue a gated action that pertains to item B (`gh pr create` for B's branch
   for defect 3.2; an `Agent(...)` delegation for B for defect 3.4).
4. Observe the gate's decision.

## Expected Behavior

Each gate resolves the checkpoint belonging to the item the call pertains to. When that checkpoint
cannot be identified, the gate denies with a distinct, greppable reason code naming the ambiguity.
A sibling item's checkpoint is never used as the basis for an allow.

## Actual Behavior

Both gates read the checkpoint that happens to occupy the session root and evaluate against it. In
run `bugs-2026-09-11`, `gh pr create` was allowed for a child working on the runsettings fix because
the readiness gate passed against issue 838's checkpoint. The child reported the outcome as "a false
green with respect to this task's own state, not evidence that this task's own lifecycle was
validated." `enforce-model-routing-receipt.ps1` was separately observed mid-run reading
`route_id: small`, `next_step: pr_creation` while gating a delegation belonging to an unrelated
parallel item.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: not available. A false approval produces no denial record, so there is no error text to
  attach. The condition must be reconstructed and observed directly rather than read from a log.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

A gate that silently validates one item's action against a different item's state is more damaging
than a gate that denies incorrectly: a false denial stalls a run visibly, whereas a false approval
lets the run proceed on an unverified basis with no record that anything was skipped.

## Suspected Cause / Notes

- `.claude/hooks/enforce-pr-author-skill.ps1:49` sets
  `$script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.json'`.
- `.claude/hooks/enforce-model-routing-receipt.ps1:46` defaults `$CheckpointPath` to the same
  relative literal.
- Neither path is resolved against the call's target worktree, and neither hook has any
  parallel-mode or epic-mode resolution step.
- `.codex/hooks/enforce-codex-model-routing.ps1` is a differently named analogue of the second hook;
  whether it carries the same defect is an open research question.
- Defects 3.2 and 3.4 of the `worktree-scoped-state-resolution` epic were reported by the run's
  orchestrator and its children, not reproduced by direct test. Independent reproduction is required
  before any fix.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: table-driven Pester over the cross product of cwd (session root vs item
      worktree), path form (relative vs absolute), and target (own item, sibling item, absent)
- [x] Integration scenario to retest: sibling-checkpoint-only case must deny with the ambiguity
      reason code; own-checkpoint-present cases must behave exactly as they do now
- [x] Manual verification notes: consume the target-worktree resolution contract delivered by epic
      feature F1 rather than re-implementing resolution locally; mirror every `.claude/**` edit into
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
