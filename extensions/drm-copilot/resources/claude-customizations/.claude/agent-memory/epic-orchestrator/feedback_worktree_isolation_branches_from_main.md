---
name: worktree-isolation-branches-from-main
description: Agent(isolation "worktree") branches the child worktree from origin/main, not from the invoking worktree's HEAD, so every epic child prompt must begin with an explicit fetch-and-checkout of the integration branch.
metadata:
  type: feedback
  scope: general
---

`Agent(..., isolation: "worktree")` creates the child worktree from `origin/main`, **not** from the
HEAD or branch of the worktree that issued the delegation. An epic child therefore does not
inherit the integration branch's contents even when the invoking checkout is sitting on
`epic/<slug>-integration` at the same commit as its remote.

Every epic child delegation prompt must therefore open with an explicit, unconditional
re-basing step as the child's first action, before any artifact-presence check:

```
git fetch origin epic/<epic-slug>-integration
git checkout -B <feature-branch> FETCH_HEAD
```

This both places the prepared feature folders, specs, research, and approved atomic plans into the
child's worktree and creates the child's feature branch off the correct base in one step. Do not
instruct a child to "create your feature branch from the current worktree HEAD" — that silently
bases the child on `main`.

**Why:** On 2026-08-07, wave 0 of the `parallel-orchestration` epic was launched from a checkout
that was itself on `epic/parallel-orchestration-integration` at commit `8703d777`. Both child
worktrees were created at `51b9e91e`, which was `origin/main`. The integration tip was a
descendant of `origin/main`, so the children were missing every prepared child feature folder and
approved plan that `epic-plan` had committed. The `epic-orchestrate` skill requires child
worktrees to branch from `origin/<integration_branch>`; the Agent tool does not do this on its own,
and nothing in the tool result signals the base commit, so the defect is invisible unless
`git worktree list --porcelain` is checked against the integration tip immediately after launch.

**How to apply:**
- Put the fetch-and-checkout block in the delegation prompt itself. It is the only reliable
  mechanism, because there is no way to correct a child after launch (see
  [[no-sendmessage-tool-for-epic-orchestrator]]).
- Immediately after launching a wave, run `git worktree list --porcelain` from the main checkout
  and confirm each child worktree's HEAD is at or descended from the integration branch tip.
  Record the observed worktree paths into the checkpoint's `features[].worktree_path` at the same
  time, since the launch-binding invariants need them.
- The same correction applies to any child instruction that assumes inherited working-tree state,
  not just the branch base.
