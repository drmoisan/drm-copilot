# cleanup-merged-worktrees (Issue #396)

- Date captured: 2026-07-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-merged-worktrees/ (Issue #396)

- Issue: #396
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/396
- Last Updated: 2026-07-22
- Work Mode: full-feature

## Problem / Why

Orchestration (epic and regular feature work) routinely creates git worktrees and branches for parallel, isolated execution. Once a branch's work has merged into `main`, the worktree and branch are frequently left behind. There is no deterministic, repository-native mechanism to detect which worktrees/branches are safe to remove (fully merged) versus which still carry unmerged or unique work (e.g., stranded agent-memory commits appended to a worktree branch after its feature content already merged).

## Proposed Behavior

A new Claude Code skill, backed by a deterministic bash script, that:

1. Enumerates git worktrees and local branches and classifies each branch as merged-into-main or not, using ancestry checks (`git merge-base --is-ancestor`), not text heuristics.
2. Never targets the currently checked-out worktree/branch.
3. For a merged branch/worktree with no commits beyond what is already reachable from `main`, marks it for deletion (worktree removal via `git worktree remove`, then branch deletion via `git branch -d`).
4. For a merged branch with residual commits appended after the merge point, inspects each residual commit's content: if the same content already exists on `main` (even under a different commit SHA, e.g. re-applied via a different merge), it is safe to drop. If the residual commit is a documentation/agent-memory artifact whose content is NOT yet on `main`, the commit is flagged for cherry-pick rather than silent deletion.
5. Consolidates all flagged cherry-pick-worthy documentation/memory commits, across however many stranded branches carry them, onto a single new branch off `main` named `documentationandmemories`.
6. Hands the consolidated branch to the `pr-author` workflow to open a PR merging it into `main`.
7. Only after the consolidation PR merges (or when there was nothing to consolidate) deletes the worktrees and branches identified in steps 3-4, since any unique content has already been preserved.
8. Runs detection deterministically (bash script, no LLM judgment for the ancestry/content-diff mechanics); LLM judgment is reserved for editorial questions (e.g., is this stranded content really "documentation") the script cannot resolve on its own.

## Acceptance Criteria (early draft)

- [ ] Bash script deterministically lists worktrees/branches merged into `main` with no residual commits, and is safe to auto-delete.
- [ ] Bash script deterministically lists merged branches with residual commits, distinguishing content-already-on-main (safe to drop) from unique documentation content (needs cherry-pick).
- [ ] Script never selects the current worktree/branch for deletion.
- [ ] Skill documents the cherry-pick-to-`documentationandmemories`-then-PR-then-delete workflow end to end.
- [ ] Unit tests cover: merged/no-worktree branch, merged/with-worktree branch, unmerged branch (excluded), merged branch with residual commit whose content already exists on main, merged branch with residual unique documentation commit, and current-branch exclusion.

## Constraints & Risks

- Destructive by nature (deletes worktrees and branches); must never run against unmerged work or the active worktree.
- Must not assume a specific number of stranded branches; must aggregate an arbitrary number into one `documentationandmemories` branch.
- PR creation must go through the `pr-author` handoff per repository policy, not direct `gh pr create`.
- Follows the repository's existing bash tooling conventions under `scripts/bash/`.

## Test Conditions to Consider

- [ ] Unit coverage: branch classification (merged/unmerged, with/without worktree, with/without residual commits)
- [ ] Integration scenarios: end-to-end run against a scratch git repo fixture with fabricated worktrees/branches (no temp files in unit tests; use a disposable git repo built in a test-only helper, not `/tmp` reliance)
- [ ] CLI/API examples: dry-run output vs. apply mode

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/cleanup-merged-worktrees/` folder from the template

