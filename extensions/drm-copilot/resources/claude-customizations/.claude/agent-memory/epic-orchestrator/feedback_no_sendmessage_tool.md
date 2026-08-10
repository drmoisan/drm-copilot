---
name: no-sendmessage-tool-for-epic-orchestrator
description: The epic-orchestrator tool allowlist has no SendMessage tool, so a launched child cannot be course-corrected; delegation prompts must be complete and self-correcting at launch.
metadata:
  type: feedback
  scope: general
---

`epic-orchestrator`'s tool allowlist is `Agent(orchestrator)`, `Agent(pr-author)`, `Read`, `Grep`,
`Glob`, scoped `Write`/`Edit`, `Bash(git *)`, `Bash(gh *)`, and two MCP tools. There is **no
`SendMessage` tool**. Once a child `Agent(orchestrator)` is launched with
`run_in_background: true`, it cannot be messaged, corrected, or stopped. The only remedies are to
wait for its completion notification and relaunch, or to let it halt on its own guard rails.

Attempting to work around this by calling `Agent` with the prompt text `SendMessage` does not
message anything — it spawns an additional, unisolated `orchestrator` in the main checkout with an
incoherent objective.

**Why:** On 2026-08-07, wave 0 of the `parallel-orchestration` epic was launched with prompts that
told each child to branch from its current worktree HEAD, before it was discovered that the Agent
tool bases worktrees on `origin/main` (see
[[worktree-isolation-branches-from-main]]). The attempt to course-correct the two running children
spawned a third orchestrator in the main repository checkout. It halted safely and made no
repository changes only because the `orchestrator` agent refuses to reconstruct a missing brief,
but the main checkout was exposed to an unisolated agent for the duration.

**How to apply:**
- Treat every child delegation prompt as one-shot and final. Verify the base commit, the plan path,
  the feature folder, and the PR base branch in the prompt text before the `Agent` call, not after.
- Include self-correcting first steps in the prompt (explicit `git fetch` / `git checkout -B`)
  rather than relying on assumptions about inherited state.
- Include an explicit "stop and report rather than regenerating" guard so a child that finds its
  preconditions unmet fails cleanly and cheaply instead of doing wrong work that must be discarded.
- If a launched child is already wrong, do not attempt to reach it. Wait for its notification,
  then relaunch with a corrected prompt.
