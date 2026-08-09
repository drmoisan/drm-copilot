# Epic Orchestrator Memory Index

- [Agent-memory is gitignored; mirror it to the bundle](feedback_commit_push_memory_before_pr.md) — repo-root .claude/agent-memory/ is ignored; only the extensions/ bundled mirror is tracked. Rescue worktree memory before removal.
- [Worktree isolation branches from main](feedback_worktree_isolation_branches_from_main.md) — child worktrees start at origin/main, so every epic child prompt must fetch and check out the integration branch first.
- [No SendMessage tool](feedback_no_sendmessage_tool.md) — a launched child cannot be corrected; delegation prompts must be complete, self-correcting, and fail-closed at launch.
- [Layer 1 PreToolUse enforcement is inconsistent](project_layer1_gates_may_be_inert.md) — the pr-author gate denied decisively; the worktree-removal gate did not block a call it denies in isolation.
- [The epic integration PR cannot pass the pr-author gate](project_epic_integration_pr_gate_gap.md) — the gate reads orchestrator-state.json and its epic-mode check forces the wrong base; escalate, do not fabricate.
