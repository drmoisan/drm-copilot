# 2026-04-11-claude-code-architecture — Spec

- **Issue:** #136
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-11T19-55
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository's orchestration model is built around Copilot-specific primitives: auto-attached instruction files, declarative agent handoffs, reusable skill contracts, and extension-backed MCP tool surfaces. Claude Code can support the same overall workflows, but it uses a distinct four-layer native architecture:

1. `CLAUDE.md` and `.claude/rules/` for persistent standing instructions (not a monolithic single file)
2. `.claude/skills/` for user-invocable or automatically loaded reusable workflows (first-class primitive — not `.claude/commands/`)
3. `.claude/agents/` for named specialist personas with their own tool allowlists, models, hooks, memory, and MCP server scoping (first-class primitive — not ad hoc file reads at delegation time)
4. `.claude/settings.json` and `.claude/hooks/` for permissioned-enforced behavior and deterministic stop gates

Without a documented and implemented Claude-native architecture that uses all four layers, the current orchestration assets are not portable outside the Copilot runtime. Specifically, the repository cannot leverage Claude Code's per-subagent tool restrictions, subagent-scoped hooks, preloaded skills, or project-level permission enforcement — all of which are required to replicate the deterministic routing, guarded handoffs, and completion-gate behavior the Copilot orchestration model provides.

A command-only or `CLAUDE.md`-only approach (the original draft design) intentionally discards supported Claude features and is not a correct Claude-native architecture.


## Behavior

Add a first-class Claude Code architecture to the repository that maps the current Copilot orchestration model onto the four Claude-native layers, preserving existing workflow boundaries and specialist responsibilities with minimal duplication.

At a high level, the implementation should:

1. **Standing instructions layer**: Add a repo-root `CLAUDE.md` that carries forward tone policy, policy-compliance order, and top-level architectural context. Add `.claude/rules/*.md` files — optionally path-scoped — to carry the language-specific and directory-specific rules that currently live in `.github/instructions/*.instructions.md` files.

2. **Skills layer**: Implement direct-use workflows as project skills under `.claude/skills/<name>/SKILL.md`. Skills are the primary user-invocable entry point surface in Claude Code. The initial set must include at minimum: `orchestrate`, `commit-message`, `pr-author`, and `research-issue`. These replace `.claude/commands/` as the target surface for new work. The `orchestrate` skill must use `context: fork` and `agent: orchestrator` frontmatter to make delegation deterministic rather than prompt-driven.

3. **Subagents layer**: Register specialist personas as project subagents under `.claude/agents/`. Each subagent file must carry frontmatter that declares its specific `tools` allowlist (including permitted `Agent(...)` delegation targets), `model`, `skills` to preload, `hooks` for stop-gate enforcement, and `memory: project`. The initial set must include at minimum: `orchestrator`, `atomic-planner`, `atomic-executor`, `feature-review`, and `task-researcher`.

4. **Enforcement layer**: Define `.claude/settings.json` with an explicit `permissions` block that allowlists required `Bash(...)`, `Read`, `Edit(...)`, `Write(...)`, MCP, `Skill(...)`, and `Agent(...)` patterns, and includes `deny` rules for sensitive paths. Add `.claude/hooks/` entries for `SubagentStop` and `PreToolUse` to enforce completion signals and bash command validation without relying on prose instructions alone.

5. **Resumability**: Preserve the existing checkpoint-file pattern at `artifacts/orchestration/orchestrator-state.json`. The Claude orchestrator subagent must read this file before performing new work and write an updated checkpoint after each phase transition.

6. **Sync strategy**: Document and implement a strategy for keeping `.claude/agents/` content aligned with the canonical `.github/agents/*.agent.md` sources, and `.claude/skills/` aligned with `.github/skills/*/SKILL.md` sources, to prevent divergence over time.

7. **Architecture documentation**: Explicitly document supported equivalences, non-equivalences (particularly the absence of Copilot's declarative `handoffs:` metadata), and the Claude-native substitutes used in each case.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Claude Code does not provide a direct equivalent for Copilot's declarative `handoffs:` metadata. The Claude-native substitute — named subagents plus skill `context: fork` delegation, checkpoint files, and `SubagentStop` hooks — approximates the behavior but relies on a different enforcement model. This must be documented explicitly and not presented as equivalent runtime enforcement.
- Custom subagents in Claude Code cannot themselves spawn further subagents from within a subagent invocation. Nested delegation must be coordinated by the main thread or routed through skills that fork a chosen agent. The `orchestrator` implementation must account for this constraint.
- The repository's `.github/agents/` files and `.github/skills/` files represent the canonical workflow content. Creating a second divergent set of Claude-native files without a defined sync strategy will increase maintenance cost and create drift risk. The sync strategy is a required deliverable, not an optional follow-up.
- Permission configuration is a usability and safety tradeoff. Overly narrow `Bash(...)` allowlists will interrupt orchestration mid-workflow. Overly broad patterns weaken the enforcement layer. The initial permission set in `settings.json` should be derived from an actual audit of the operations each subagent performs, not from guessing.
- Scope is limited to the four-layer architecture, skill and subagent definitions, settings and hooks, resumability, sync strategy, and validation guidance. It does not include rewriting every existing `.github/agents/` file, restructuring unrelated repository automation, or implementing agent teams (which are experimental, higher-cost, and not suited to this repository's sequential workflow model).
- Agent teams are explicitly out of scope. They are designed for collaborative parallel exploration, not for the repository's deterministic sequential pipeline (promotion → research → planning → execution → review).


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Validation that each `.claude/skills/` file can be invoked by name in a Claude Code session and produces the expected entry-point behavior (context fork, agent delegation, or direct workflow execution as applicable)
- [ ] Validation that each `.claude/agents/` subagent's `tools` frontmatter correctly restricts the tool surface: attempt an operation outside the declared allowlist and confirm it is blocked at the permission layer, not just by prose instruction
- [ ] Validation that the `SubagentStop` hooks in `settings.json` block premature termination when the required artifact path is absent from the subagent's output, and allow termination when the artifact path is present
- [ ] Validation that the `orchestrator` subagent reads `artifacts/orchestration/orchestrator-state.json` at the start of a session and correctly resumes from a partially populated checkpoint rather than restarting the workflow from scratch
- [ ] Validation that the `PreToolUse` bash-validation hook in `settings.json` invokes the hook script and blocks at least one representative dangerous-command pattern
- [ ] Documentation review confirming that every non-equivalence between Copilot and Claude is identified and that no section of the migration documentation claims runtime enforcement for behaviors that are enforced only by prompt conventions
