# Claude Code Architecture

This document describes the four-layer architecture used to map the existing GitHub Copilot orchestration model in this repository onto Claude Code primitives. It covers the equivalence mapping, non-equivalences, sync strategy, and an end-to-end validation walkthrough.

## 1. Copilot-to-Claude Equivalence Table

The following table maps each Copilot primitive to its Claude Code equivalent, covering instruction files, direct-use prompts, reusable skills, and handoff metadata.
The mapping for specialist agents is included alongside each category.

| Copilot Primitive | Claude Equivalent | Notes |
|---|---|---|
| `.github/copilot-instructions.md` | `CLAUDE.md` | Standing instructions, always loaded into context |
| `.github/instructions/*.instructions.md` | `.claude/rules/*.md` | Path-scoped via `paths:` YAML frontmatter; activated automatically when matching files are in scope |
| `.github/prompts/*.prompt.md` | `.claude/skills/<name>/SKILL.md` | User-invocable workflows; Claude skills use `argument-hint:` frontmatter for parameter discovery |
| `.github/agents/*.agent.md` | `.claude/agents/*.md` | Named specialist personas with `tools:`, `model:`, `hooks:`, and `memory:` boundaries declared in YAML frontmatter |
| `.github/skills/*/SKILL.md` | `.claude/skills/<name>/SKILL.md` (or preloaded via `skills:` frontmatter in subagents) | Reusable workflow contracts; shared by multiple agents via `skills:` lists |
| `handoffs:` metadata | Named subagents + `context: fork` + `agent:` + checkpoint files + `SubagentStop` hooks | No single direct equivalent; requires a combination of Claude primitives (see Section 2) |

## 2. Non-Equivalences

Several Copilot orchestration primitives have no direct Claude Code equivalent. This section documents each gap and the substitute approach used in this repository.

### `handoffs:` metadata has no direct Claude equivalent

In Copilot agent files, the `handoffs:` frontmatter key declares which specialist agents an orchestrator can delegate to. Claude Code has no single primitive that replicates this behavior. The Claude-native substitute is the combination of:

1. **Named subagents** (`.claude/agents/*.md`) declare specialist boundaries (tools, model, memory).
2. **Skill `context: fork`** with an **`agent:` routing** field in `.claude/skills/<name>/SKILL.md` directs user-invoked skills to run under a specific subagent persona.
3. **Checkpoint files** (e.g., `artifacts/orchestration/orchestrator-state.json`) persist phase-transition state between delegations.
4. **`SubagentStop` hooks** in `.claude/settings.json` enforce completion gates, blocking subagent termination when required artifact paths are absent from the output.

### Subagent nesting limitation

Custom subagents cannot spawn further subagents from within a subagent invocation. The orchestrator coordinates all delegation from the main thread. Delegation chains are flat: orchestrator delegates to exactly one subagent at a time, waits for completion, and then delegates to the next subagent based on checkpoint state.

### `.claude/commands/` is backward-compatibility only

The `.claude/commands/` directory is a backward-compatibility surface for Claude Code. The recommended surface for new user-invocable workflows is `.claude/skills/`, which supports richer frontmatter (`argument-hint:`, `context:`, `agent:`, `allowed-tools:`) and integrates with the subagent delegation model.

## 3. Sync Strategy

The `.github/` directory is the authoritative source for all orchestration assets. The `.claude/` directory contains derived files that adapt those assets for Claude Code consumption. No `.claude/` file replaces a `.github/` file; the `.github/` versions remain canonical.

### Authoritative source by asset category

| `.claude/` Asset | Authoritative Source | Relationship |
|---|---|---|
| `.claude/rules/*.md` | `.github/instructions/*.instructions.md` | Derived: summarized policy content with `paths:` frontmatter added |
| `.claude/skills/<name>/SKILL.md` | `.github/skills/*/SKILL.md` and `.github/prompts/*.prompt.md` | Derived: workflow body adapted with Claude-specific frontmatter (`context:`, `agent:`, `allowed-tools:`) |
| `.claude/agents/*.md` | `.github/agents/*.agent.md` | Maintained alongside: manual sync using diff to reconcile tool lists, model settings, and hook declarations |
| `CLAUDE.md` | `.github/copilot-instructions.md` + `.github/skills/policy-compliance-order/SKILL.md` | Derived: standing instructions composed from tone policy and compliance order |
| `.claude/settings.json` | No direct `.github/` equivalent | Authored directly: Claude Code-specific permissions, hooks, and default mode |

### Manual sync procedure

**For `.claude/rules/` files (derived from `.github/instructions/`):**

1. Run `diff` between the `.github/instructions/<lang>-code-change.instructions.md` file and the corresponding `.claude/rules/<lang>.md` file.
2. Identify any policy changes in the `.github/` source that are not reflected in the `.claude/` derivative.
3. Update the `.claude/rules/<lang>.md` file to incorporate the policy delta while preserving the `paths:` frontmatter and the summarized format.
4. Repeat for the `*-unit-test.instructions.md` source for each language.

**For `.claude/skills/` files (derived from `.github/skills/` and `.github/prompts/`):**

1. Run `diff` between the `.github/skills/<name>/SKILL.md` (or `.github/prompts/<name>.prompt.md`) and the corresponding `.claude/skills/<name>/SKILL.md`.
2. Update the Claude skill body to reflect any workflow changes while preserving Claude-specific frontmatter fields.

**For `.claude/agents/` files (maintained alongside `.github/agents/`):**

1. Run `diff` between `.github/agents/<name>.agent.md` and `.claude/agents/<name>.md`.
2. Reconcile differences in tool lists, model declarations, skill references, and hook declarations.
3. Validate that scoped `Bash(...)` patterns in `.claude/agents/` still match the toolchain commands used by the corresponding `.github/agents/` file.

**For `CLAUDE.md` (derived from `.github/copilot-instructions.md`):**

1. Review `.github/copilot-instructions.md` for tone or compliance changes.
2. Update `CLAUDE.md` to reflect any changes without duplicating full policy text (reference the source files instead).

## 4. Validation Walkthrough: Small-Path Orchestration Run

This section documents a complete small-path orchestration run under Claude Code, tracing the flow through each layer and identifying the enforcement boundaries that protect the process.

### Step-by-step sequence

**Step 1 — User invokes `/orchestrate`**

The user runs the `/orchestrate` skill (`.claude/skills/orchestrate/SKILL.md`). The skill frontmatter specifies `context: fork` and `agent: orchestrator`, which causes Claude Code to launch the orchestrator subagent (`.claude/agents/orchestrator.md`) in a forked context.

**Step 2 — Orchestrator reads checkpoint state**

The orchestrator reads `artifacts/orchestration/orchestrator-state.json` to determine the current phase, pending delegations, and any unfinished work from a previous session. If no checkpoint exists, the orchestrator initializes a new orchestration cycle.

**Step 3 — Orchestrator delegates to `atomic-planner`**

Based on the checkpoint state, the orchestrator delegates planning to the `atomic-planner` subagent (`.claude/agents/atomic-planner.md`). The planner's tool list is restricted to `Read`, `Grep`, `Glob`, and scoped write access to `docs/**` and `artifacts/**`. It cannot execute arbitrary Bash commands.

**Step 4 — `atomic-planner` writes plan**

The `atomic-planner` produces a phased plan file at `docs/features/active/<feature>/plan.md`. The plan follows the format defined in the `atomic-plan-contract` skill, with Phase 0 policy reads, implementation phases, and a final QA loop. The planner's `SubagentStop` hook (defined in `.claude/settings.json`) blocks termination unless the planner's output includes a plan file path.

**Step 5 — Orchestrator delegates to `atomic-executor`**

The orchestrator reads the plan path from the planner's output and delegates execution to the `atomic-executor` subagent (`.claude/agents/atomic-executor.md`). The executor has scoped `Bash(...)` patterns for each toolchain command (`poetry run black *`, `npx prettier *`, `pwsh *`, etc.) and MCP access via `mcp__drmCopilotExtension__.*`.

**Step 6 — Executor runs toolchain and writes evidence**

The executor works through the plan task-by-task, running the repository toolchain (format, lint, type-check, test) and writing evidence artifacts to the feature folder's `evidence/` directory. Each completed task is checked off in the plan file.

**Step 7 — Orchestrator writes updated checkpoint**

After the executor completes, the orchestrator updates `artifacts/orchestration/orchestrator-state.json` with the new phase state, completed delegations, and any remaining work. This checkpoint enables session resumption.

### Enforcement boundaries

Two enforcement boundaries protect this orchestration flow through hooks and permissions configured in `.claude/settings.json`:

1. **`PreToolUse` hook — dangerous Bash command blocking.** Before any `Bash` tool invocation, Claude Code executes `.claude/hooks/validate-bash.ps1`. This script checks the proposed command against a list of blocked patterns (`rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`, `git reset --hard`, `git push -f`). If any blocked pattern is detected, the hook exits with code 1 and the Bash command is rejected before execution. Safe commands proceed with exit code 0.

2. **`SubagentStop` hook — premature termination blocking.** When any of the four subagents (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`) attempts to stop, the `SubagentStop` hook inspects the subagent's output for required completion markers (`plan-path`, `research-path`, `review-artifact`, `PREFLIGHT`, or `evidence/`). If the required marker is absent, the hook exits with code 1 and blocks the subagent from stopping, forcing it to continue until the required artifact path is produced.
