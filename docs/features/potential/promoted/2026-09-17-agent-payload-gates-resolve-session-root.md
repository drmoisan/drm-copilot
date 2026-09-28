# agent-payload-gates-resolve-session-root (Issue #690)

- Date captured: 2026-09-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/agent-payload-gates-resolve-session-root/ (Issue #690)

- Issue: #690
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/690
- Last Updated: 2026-09-18
## Summary

Two PreToolUse gates that act on `Agent` delegation payloads still resolve their orchestrator
checkpoint against the invoking session's working directory instead of the call's target worktree:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — `$script:CheckpointPath` at
  line 27 is the session-root-relative `artifacts/orchestration/orchestrator-state.json`. It never
  calls `Resolve-WorktreeCallTarget`.
- `.claude/hooks/enforce-model-routing-receipt.ps1` — `-CheckpointPath` defaults to the same
  session-root-relative path (line 46).

This is the remaining half of epic #678's defect class. #669 delivered the resolution module, #671
fixed only the `git -C` staging exemption, and #687 wired the pr-author gate. These two were not
covered.

## Observed impact (2026-09-17/18)

Working issue #688 from a coordinating session whose root was a different worktree:

- `Agent(powershell-typed-engineer)` delegation was denied with `PREIMPLEMENTATION_GATE_BLOCKED`
  even though the delegation prompt named the feature folder and a valid, validator-passing
  checkpoint existed in the target worktree.
- Every `Edit` and `Write` against production paths in that worktree was denied for the same
  reason.

The work had to be done through the PowerShell tool instead, which the gate does not govern. So the
gate does not prevent the work; it only prevents doing it through the governed path, which is the
worst of both outcomes.

## Why this needs its own decision, not a copy of #687

#687 could require `pr-author` to pass `--head <branch>`, because a `gh pr create` command has a
natural place to name its target. `Agent` payloads have no equivalent: a prompt may legitimately
name no feature folder. Denying `NoTarget` for this payload class would block every such
delegation, which is a far larger blast radius than the PR-creation path.

The policy question to settle first: for an `Agent` payload that resolves `NoTarget`, is the
correct behaviour to allow against the session root (today's behaviour, which is the false-approval
risk), to deny (fail-closed, but breaks legitimate untargeted delegations), or to allow only when
the session root's checkpoint is the sole active checkpoint in the repository?

## Proposed Behavior

1. Decide the `NoTarget` policy for the Agent payload class, then apply it uniformly to both gates.
2. Where resolution yields `OtherWorktree`, both gates MUST read that worktree's checkpoint.
3. Where resolution yields `SessionRoot`, behaviour MUST be unchanged.
4. Preserve fail-closed behaviour for a malformed or unreadable checkpoint.

## Acceptance Criteria (early draft)

- [ ] A delegation whose prompt names a feature folder in another worktree is validated against
      that worktree's checkpoint.
- [ ] An `Edit`/`Write` to a path inside another worktree is validated against that worktree's
      checkpoint.
- [ ] The settled `NoTarget` policy is implemented identically in both gates.
- [ ] Pester coverage for the resolution matrix in both gates, with existing cases as regression
      guards.

## Constraints & Risks

- Both gates must stay fail-closed for malformed state.
- A too-strict `NoTarget` policy blocks legitimate untargeted delegations; a too-loose one
  reintroduces the false approval of defect 3.2.

## Next Step

- [x] Promote to GitHub issue
