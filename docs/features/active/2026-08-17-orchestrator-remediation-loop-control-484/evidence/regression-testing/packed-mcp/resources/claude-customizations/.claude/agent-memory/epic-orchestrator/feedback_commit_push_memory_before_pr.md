---
name: commit-and-push-agent-memory-before-pr
description: The repo-root .claude/agent-memory/ tree is gitignored; the only tracked location is the bundled mirror under extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/, and memory must be copied there and committed before a PR opens.
metadata:
  type: feedback
  scope: general
---

**The repo-root `.claude/agent-memory/` tree is gitignored** (`.gitignore:78`, pattern
`.claude/agent-memory`). Writing a memory file there — in the main checkout or in any agent
worktree — never puts it under version control, and `git status` will not show it. `git add` on
that path is a no-op without `-f`, and forcing it would violate repository policy.

The only tracked location is the bundled mirror:
`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/<agent-name>/`.
A memory only reaches `main`, and only becomes available to a future fresh checkout, when it is
copied into that mirror (including the mirror's own `MEMORY.md` index) and committed.

Therefore, for every run: capture memory into the runtime path `.claude/agent-memory/<agent>/` as
normal, and before the run's PR opens, mirror any new or changed files into the tracked bundle path
and commit them there. If the CI/remediation cycle produces additional memory after the PR opens,
mirror and commit those too before the PR merges.

**Why:** On 2026-07-21, cleanup of the worktree for the already-merged branch
`feature/legacy-discovery-documentation-371` turned up three untracked review-artifact files that
existed only in that worktree and would have been lost outright. On 2026-08-07, the child
orchestrator for epic feature #445 reported that it could not commit its memory at all because the
path is gitignored, and its worktree held four genuinely new memory files across the
`feature-review`, `orchestrator`, and `pr-author` scopes. Those had to be copied out by hand before
`git worktree remove` destroyed them. The earlier version of this memory asserted that
`.claude/agent-memory/` was committable; that was wrong and caused a child to be given an
impossible instruction.

**How to apply:**
- Never instruct a child agent to "commit and push `.claude/agent-memory/`". Instruct it to write
  memory to the runtime path and to **report** what it wrote, so the parent can mirror it.
- Before removing any child worktree, list `<worktree>/.claude/agent-memory/` and copy new files
  into the main checkout's runtime tree, merging the per-agent `MEMORY.md` index lines rather than
  overwriting them. `git status` will not warn you, because the files are ignored.
- **`git worktree remove` without `--force` is a safety net; let it work.** It refuses with
  "contains modified or untracked files" when a child left *tracked-path* content uncommitted. On
  2026-08-09 that refusal caught three review artifacts (`code-review`, `feature-audit`,
  `policy-audit` from a remediation-cycle exit reaudit) that the #440 child had written into its
  feature folder but never committed. Never reach for `--force` first. Run
  `git status --short` in the worktree, `git log --oneline origin/<integration>..HEAD` for unpushed
  commits, and `git merge-base --is-ancestor HEAD origin/<integration>` to confirm the branch is
  fully merged. Rescue anything found, `diff -q` the copies to prove they are byte-identical, commit
  them to the integration branch, and only then use `--force`.
- A fresh agent worktree starts from `origin/main` and therefore has an **empty** runtime memory
  tree. Child agents in worktrees effectively run without memory; do not assume a child knows
  anything recorded in a previous run's memory. Put load-bearing context in the delegation prompt.
- Before you open the final integration-to-`main` PR via `Agent(pr-author)`, mirror your own new
  `.claude/agent-memory/epic-orchestrator/` files into the tracked bundle path and commit them.
- See [[worktree-isolation-branches-from-main]] and [[no-sendmessage-tool-for-epic-orchestrator]]
  for the related worktree-isolation constraints.

**Why:** Epic runs schedule child features across isolated git worktrees, and those worktrees are removed once each child's branch merges. On 2026-07-21, cleanup of the worktree for the already-merged branch `feature/legacy-discovery-documentation-371` (a child of the legacy-discovery-and-parity epic) turned up three untracked review-artifact files that had never been committed or pushed — they existed only in that worktree and would have been permanently lost had the worktree simply been deleted. Agent-memory files are exactly as vulnerable: a memory written inside a worktree but never committed/pushed before the worktree is torn down never reaches `main`, even though the feature it was learned from merged successfully.

**How to apply:**
- Each child feature's own `Agent(orchestrator)` instance is responsible for committing and pushing its own `.claude/agent-memory/orchestrator/` changes before its own PR opens (per that agent's own memory rule); you do not need to do this on the child's behalf, but do not remove a child's worktree until its PR is durably confirmed merged (per the existing wave-barrier rule), which also protects any not-yet-pushed memory in that worktree.
- Before you open the final integration-to-`main` PR via `Agent(pr-author)`, stage, commit, and push any new or modified files under `.claude/agent-memory/epic-orchestrator/` (root and the mirrored bundled copy under `extensions/drm-copilot/resources/**/.claude/agent-memory/epic-orchestrator/`) produced during epic scheduling, wave management, or fan-in, including the updated `MEMORY.md` index.
- If a CI failure on the integration PR or a reaudit produces new learning worth recording as memory, write it, then commit and push it to the integration branch before the final integration PR merges.
- This does not change the memory content rules (still feedback/project/reference typed, still indexed in `MEMORY.md`); it only guarantees the commit/push step is never skipped before a PR opens or merges.
