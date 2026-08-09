---
name: layer1-pretooluse-gates-may-be-inert
description: PreToolUse enforcement is inconsistent — the pr-author gate denied decisively while the worktree-removal gate did not block a call it correctly denies in isolation; never assume a gate is protecting you.
metadata:
  type: project
---

`enforce-epic-worktree-removal-gate.ps1` is registered as a `PreToolUse` Bash hook in
`.claude/settings.json` and is correct in isolation, yet it did not block a `git worktree remove`
that it should have denied.

**Why:** On 2026-08-09, during the `parallel-orchestration` epic, `git worktree remove` for the
issue-446 child worktree succeeded while the epic checkpoint still recorded
`worktree_path: null` and `merge_status: "worktree_created"` for that feature — precisely the state
the gate exists to refuse. Running the hook directly with the exact `CLAUDE_TOOL_INPUT` payload
returned `permissionDecision: deny` with `EPIC_WORKTREE_REMOVAL_BLOCKED` in all three forms tested:
the bare command, the compound `cp ... && echo ...; git worktree remove ...` form actually used, and
the specific 446 path. So the hook logic is sound and the registration is present; the decision just
did not take effect. The cause was not diagnosed, because diagnosing it mid-epic was not worth
stalling eight merged features.

**Do not generalize this into "Layer 1 hooks do not fire."** That would be wrong. Later in the same
run, `enforce-pr-author-skill.ps1` fired decisively and *denied* `gh pr create` for the epic
integration PR, with a `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` reason. So PreToolUse enforcement is
live in this runtime for at least that hook. The accurate statement is narrower and stranger: some
registered gates enforce and at least one did not, and the difference is not yet explained.

`enforce-epic-wave-barrier.ps1` sits in the unknown column: across the whole epic it was only ever
observed to *allow*, never to deny, so its enforcement was never positively demonstrated either way.

**How to apply:**
- Do not treat a Layer 1 `PreToolUse` gate as the thing that keeps an epic safe. Treat it as a
  deterrent that may or may not fire, and keep the operator-side discipline that does not depend on
  it: before removing any child worktree, durably confirm the merge with
  `gh pr view --json state,mergedAt,mergeCommit`, confirm a clean tree, confirm
  `git merge-base --is-ancestor HEAD origin/<integration>`, and rescue worktree content first.
- Update the checkpoint record (`worktree_path`, `merge_status`) *before* attempting removal anyway.
  It costs nothing, and it is what makes the gate able to help when it does fire.
- If you want to know whether a gate is live, construct a case it must refuse and observe the
  refusal. An allow proves nothing about enforcement.
- Report this to the human rather than quietly relying on Layer 2. Two of the epic's own deliverables
  (`enforce-parallel-worktree-removal-gate.ps1` and the parallel cohort barrier) are near-verbatim
  clones of this design, so if the epic original is inert the clones inherit it. That belongs in the
  integration-PR review, not in an agent's private notes.
- See [[commit-and-push-agent-memory-before-pr]] for the pre-removal sweep this pairs with.
