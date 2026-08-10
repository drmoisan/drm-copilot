---
name: epic-orchestrator-memory-index
description: Index of epic-orchestrator agent memories.
metadata:
  type: index
  scope: repo
---

# Epic Orchestrator Memory Index

- [Agent-memory is gitignored; mirror it to the bundle](feedback_commit_push_memory_before_pr.md) — repo-root .claude/agent-memory/ is ignored; only the extensions/ bundled mirror is tracked. Rescue worktree memory before removal.
- [Worktree isolation branches from main](feedback_worktree_isolation_branches_from_main.md) — child worktrees start at origin/main, so every epic child prompt must fetch and check out the integration branch first.
- [No SendMessage tool](feedback_no_sendmessage_tool.md) — a launched child cannot be corrected; delegation prompts must be complete, self-correcting, and fail-closed at launch.
