# Single-Ecosystem Skills (Issue #1025)

Each record proposes `shared` or `native` (spec `### Survey Records`); single-ecosystem records carry no difference table.

### architecture-boundaries

- Presence: claude=absent | codex=`.agents/skills/architecture-boundaries/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### atomic-executor

- Presence: claude=absent | codex=`.agents/skills/atomic-executor/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex skill form of a role that Claude Code defines as an agent; parity is tracked through the agent entries.

### atomic-planner

- Presence: claude=absent | codex=`.agents/skills/atomic-planner/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex skill form of a role that Claude Code defines as an agent; parity is tracked through the agent entries.

### bash-command-shape

- Presence: claude=absent | codex=`.agents/skills/bash-command-shape/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### benchmark-baselines

- Presence: claude=absent | codex=`.agents/skills/benchmark-baselines/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### ci-workflows

- Presence: claude=absent | codex=`.agents/skills/ci-workflows/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### cleanup-merged-worktrees

- Presence: claude=`.claude/skills/cleanup-merged-worktrees/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: Removing merged worktrees and branches is a repository procedure that does not depend on the tool that runs it.

### codex-model-routing

- Presence: claude=absent | codex=`.agents/skills/codex-model-routing/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Selects Codex deployments and reasoning effort, which is specific to Codex.

### commit-message-conventions

- Presence: claude=absent | codex=`.agents/skills/commit-message-conventions/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of repository conventions that Claude Code carries in its commit-message skill and rules.

### csharp

- Presence: claude=absent | codex=`.agents/skills/csharp/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### epic-progress-report

- Presence: claude=`.claude/skills/epic-progress-report/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: Reporting epic progress from checkpoints and issue state is tool-neutral.

### feature-review

- Presence: claude=absent | codex=`.agents/skills/feature-review/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex skill form of a role that Claude Code defines as an agent; parity is tracked through the agent entries.

### general-code-change

- Presence: claude=absent | codex=`.agents/skills/general-code-change/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### general-unit-test

- Presence: claude=absent | codex=`.agents/skills/general-unit-test/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### identify-session-id

- Presence: claude=`.claude/skills/identify-session-id/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Reads the Claude Code session identifier, a mechanism the other tools do not expose in the same form.

### mermaid-diagram

- Presence: claude=`.claude/skills/mermaid-diagram/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: Authoring Mermaid diagrams is independent of the agent tool.

### orchestrator-state

- Presence: claude=absent | codex=`.agents/skills/orchestrator-state/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### orchestrator-workflow

- Presence: claude=absent | codex=`.agents/skills/orchestrator-workflow/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex skill form of a role that Claude Code defines as an agent; parity is tracked through the agent entries.

### parallel-add

- Presence: claude=`.claude/skills/parallel-add/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: The parallel-run workflow governs repository state and checkpoints, which any orchestrating tool can follow.

### parallel-close

- Presence: claude=`.claude/skills/parallel-close/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: The parallel-run workflow governs repository state and checkpoints, which any orchestrating tool can follow.

### parallel-orchestrate

- Presence: claude=`.claude/skills/parallel-orchestrate/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: The parallel-run workflow governs repository state and checkpoints, which any orchestrating tool can follow.

### parallel-plan

- Presence: claude=`.claude/skills/parallel-plan/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: The parallel-run workflow governs repository state and checkpoints, which any orchestrating tool can follow.

### parallel-remove

- Presence: claude=`.claude/skills/parallel-remove/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: The parallel-run workflow governs repository state and checkpoints, which any orchestrating tool can follow.

### parallel-run

- Presence: claude=`.claude/skills/parallel-run/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: shared
- Rationale: The parallel-run workflow governs repository state and checkpoints, which any orchestrating tool can follow.

### powershell

- Presence: claude=absent | codex=`.agents/skills/powershell/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### pr-authoring

- Presence: claude=absent | codex=`.agents/skills/pr-authoring/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex companion of the shared pr-author skill holding Codex-specific authoring mechanics.

### python

- Presence: claude=absent | codex=`.agents/skills/python/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### python-suppressions

- Presence: claude=absent | codex=`.agents/skills/python-suppressions/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### quality-tiers

- Presence: claude=absent | codex=`.agents/skills/quality-tiers/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### quota-throttling

- Presence: claude=`.claude/skills/quota-throttling/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Throttles work against Claude account usage windows, which are specific to that tool.

### repo-automation-adapter

- Presence: claude=absent | codex=`.agents/skills/repo-automation-adapter/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Adapts Codex to the repository automation MCP surface, which is specific to Codex.

### self-explanatory-code-commenting

- Presence: claude=absent | codex=`.agents/skills/self-explanatory-code-commenting/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of repository commenting guidance that the other tools carry in rules or instructions.

### show-my-agent-tree

- Presence: claude=`.claude/skills/show-my-agent-tree/SKILL.md` | codex=absent | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Inspects the Claude Code subagent tree, a mechanism specific to that tool.

### tonality

- Presence: claude=absent | codex=`.agents/skills/tonality/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### translate-claude-to-codex

- Presence: claude=absent | codex=`.agents/skills/translate-claude-to-codex/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Translates Claude Code customizations into Codex form, a direction specific to Codex.

### typescript

- Presence: claude=absent | codex=`.agents/skills/typescript/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

### typescript-suppressions

- Presence: claude=absent | codex=`.agents/skills/typescript-suppressions/SKILL.md` | copilot=absent
- Identity: single-ecosystem
- Proposed disposition: native
- Rationale: Codex expression of a repository rule that Claude Code carries as a path-scoped rule; parity is tracked through the rule entries.

