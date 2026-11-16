# Gold Standard: epic-plan

## Objective

Scope and prepare a multi-feature epic end-to-end before execution for the epic-planner agent - epic-worthiness gate, decomposition, dependency-wave design, complexity assessment, preparation-mode child orchestrator delegations, integration-branch fan-in, and the epic-orchestrator kickoff prompt artifact. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Before proceeding, `epic-planner` must read `AGENTS.md`, the applicable language policies under `.agents/skills/`, `config/orchestration-routing.json`, and any existing `artifacts/orchestration/epic-planner-state.json` checkpoint.
- **OB-2** Epic-Worthiness Gate: It decomposes into at least two independently mergeable child features, each with its own issue, active feature folder, and eventual PR.
- **OB-3** Decomposition and Wave Design: Define `docs/features/epics/<epic-slug>/` and author `epic.md` using the manifest schema in `epic-orchestrate`.
- **OB-4** Preparation Worktree Records: Each completed preparation child is recorded in `planner_worktrees` keyed by branch, and its `path`, when recorded, is repository-relative to the main checkout; an absolute path is never recorded.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Epic-Worthiness Gate, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Decomposition and Wave Design, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Preparation Worktree Records, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
