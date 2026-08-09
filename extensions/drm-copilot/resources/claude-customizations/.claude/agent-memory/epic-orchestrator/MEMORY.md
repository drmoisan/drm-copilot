# Epic Orchestrator Memory Index

- [Agent-memory is gitignored; mirror it to the bundle](feedback_commit_push_memory_before_pr.md) — repo-root .claude/agent-memory/ is ignored; only the extensions/ bundled mirror is tracked. Rescue worktree memory before removal.
- [Worktree isolation branches from main](feedback_worktree_isolation_branches_from_main.md) — child worktrees start at origin/main, so every epic child prompt must fetch and check out the integration branch first.
- [No SendMessage tool](feedback_no_sendmessage_tool.md) — a launched child cannot be corrected; delegation prompts must be complete, self-correcting, and fail-closed at launch.
- [Layer 1 PreToolUse gates may be inert](project_layer1_gates_may_be_inert.md) — a registered gate that denies when run directly did not block the real call; verify guardrails by observing a denial, not an allow.
