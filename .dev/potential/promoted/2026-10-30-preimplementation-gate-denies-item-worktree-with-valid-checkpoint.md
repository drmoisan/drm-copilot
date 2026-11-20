# preimplementation-gate-denies-item-worktree-with-valid-checkpoint (Issue #1010)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-gate-denies-item-worktree-with-valid-checkpoint/ (Issue #1010)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1010
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1010
- Last Updated: 2026-10-30
## Summary

The preimplementation gate denies writes into an item worktree that has a complete, valid checkpoint, because it evaluates the session-root checkpoint instead of the target worktree's. One of four sibling bugs that share the target-worktree resolver fix described in the batch-budget bug (see the sibling issue for the full resolver specification).

## Environment

- OS/version: not recorded
- Python version: not applicable
- Command/flags used: Write, Edit, or `git commit` from a coordinating session, a non-isolated child, or that child's subagents, against a file inside an item worktree
- Data source or fixture: hooks `enforce-orchestration-preimplementation-gate.ps1` and its `-helpers`, `-targets`, `-modes`, and `-epic-scope` files

## Steps to Reproduce

1. Prepare an item worktree whose checkpoint has issue number, feature folder, route, `lifecycle_ready`, and checkpoint state.
2. From a coordinator-rooted session (or a non-isolated child, or its subagents), Write, Edit, or `git commit` against a file in that worktree.
3. Typical cases: committing an owner-decision record onto a prepared item branch before its child launches; pr-author writing `artifacts/pr_body_<N>.receipt.json` for an item from a coordinator-rooted subagent.

## Expected Behavior

- The checkpoint of the resolved target worktree is evaluated for file and git targets.
- `TARGET_WORKTREE_NOT_DERIVABLE` / `TARGET_WORKTREE_AMBIGUOUS` are denied only when no single worktree resolves.
- Delegation-prompt resolution for `Agent(...)` is unchanged.

## Actual Behavior

The gate denies `PREIMPLEMENTATION_GATE_BLOCKED` because it evaluates the session-root checkpoint, and the coordinator root keeps no per-item checkpoint by design.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

It blocks pr-author's receipt write (compounding the PR-authoring bug) and forces a human to open one session per item.

## Suspected Cause / Notes

Hooks derive the root from `Split-Path (Split-Path $PSScriptRoot)`, which is the coordinator checkout when Claude Code loads hooks from the session project directory. Use the shared `Resolve-HookTargetWorktree` resolver.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Write/Edit/commit into a worktree with a complete checkpoint → allow; the same into a worktree without one → deny; a target outside every worktree → current behavior; two candidate worktrees → ambiguous deny. Tests in every runtime carrying the hook (Claude, Codex, and the bundled push-down copies).
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity as in the sibling batch-budget issue (execution-environment brief copies, `orchestrator-state.md`, contract tests, pack manifest, dependency closure, no Python in hooks).

Out of scope: no relaxation of the preimplementation requirements; no change to worktree-isolation behavior or checkpoint schemas.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
