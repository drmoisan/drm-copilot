---
name: layer1-pretooluse-gates-may-be-inert
description: A registered PreToolUse gate that denies correctly when run directly did not actually block the matching Bash call, so Layer 1 enforcement cannot be assumed; verify guardrails by observing a real denial.
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

The same doubt extends to the sibling gates that share the design — `enforce-epic-merge-gate.ps1`
and `enforce-epic-wave-barrier.ps1`. Across the whole epic the wave barrier was only ever observed
to *allow*; it was never observed to actually deny, so there is no positive evidence any of these
Layer 1 gates enforce in this runtime.

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
