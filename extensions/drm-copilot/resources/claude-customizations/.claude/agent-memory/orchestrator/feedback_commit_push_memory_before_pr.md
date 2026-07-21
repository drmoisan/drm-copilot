---
name: commit-and-push-agent-memory-before-pr
description: Repo-tracked agent-memory files under .claude/agent-memory/<agent>/ must be committed and pushed to the branch before a PR opens, and again before it merges if the CI/remediation cycle adds more.
metadata:
  type: feedback
---

Repo-committed agent-memory files under `.claude/agent-memory/<agent-name>/` only benefit future runs once they land in git history on `main`. Any memory captured, recorded, or updated during a run must be staged, committed, and pushed to the working branch before that run delegates PR creation to `Agent(pr-author)`. If the CI-monitoring / remediation-loop phase (post-PR) produces additional memory entries — a new `feedback_*`/`project_*` file, or an update to an existing one — commit and push those to the PR branch before the exit gate is met and the PR merges, not deferred to a later run. Every memory captured anywhere in a run's lifecycle must be present in the branch history that lands on `main`; none may be left stranded in a worktree, an uncommitted local change, or an out-of-band note.

**Why:** Feature runs typically execute inside an isolated git worktree, and worktrees are removed once their branch's PR merges. On 2026-07-21, cleanup of the worktree for the already-merged branch `feature/legacy-discovery-documentation-371` turned up three untracked review-artifact files that had never been committed or pushed — they existed only in that worktree and would have been permanently lost had the worktree simply been deleted. Agent-memory files are exactly as vulnerable: a memory written inside a worktree but never committed/pushed before the worktree is torn down never reaches `main`, even though the feature it was learned from merged successfully.

**How to apply:**
- Before the `## PR Creation Delegation` step (delegating to `Agent(pr-author)`), stage, commit, and push any new or modified files under `.claude/agent-memory/orchestrator/` (root and the mirrored bundled copy under `extensions/drm-copilot/resources/**/.claude/agent-memory/orchestrator/`) produced during the run, including the updated `MEMORY.md` index.
- During the remediation loop / CI-monitoring phase, if a CI failure or reaudit produces new learning worth recording as memory, write it, then commit and push it to the same PR branch before the exit gate is satisfied and the PR merges.
- This does not change the memory content rules (still feedback/project/reference typed, still indexed in `MEMORY.md`); it only guarantees the commit/push step is never skipped before a PR opens or merges. Related: [[bundle-sync-after-runtime-edit]].
