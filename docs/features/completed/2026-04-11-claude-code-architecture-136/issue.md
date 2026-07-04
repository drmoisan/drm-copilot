# claude-code-architecture (Issue #136)

- Date captured: 2026-04-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/claude-code-architecture/ (Issue #136)

- Issue: #136
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/136
- Last Updated: 2026-04-11
- Work Mode: full-feature

## Problem / Why

The repository's orchestration model is built around Copilot-specific primitives: auto-attached instruction files, declarative agent handoffs, reusable skill contracts, and extension-backed MCP tool surfaces. Claude Code can support the same overall workflows, but it uses a distinct four-layer native architecture:

1. `CLAUDE.md` and `.claude/rules/` for persistent standing instructions (not a monolithic single file)
2. `.claude/skills/` for user-invocable or automatically loaded reusable workflows (first-class primitive — not `.claude/commands/`)
3. `.claude/agents/` for named specialist personas with their own tool allowlists, models, hooks, memory, and MCP server scoping (first-class primitive — not ad hoc file reads at delegation time)
4. `.claude/settings.json` and `.claude/hooks/` for permissioned-enforced behavior and deterministic stop gates

Without a documented and implemented Claude-native architecture that uses all four layers, the current orchestration assets are not portable outside the Copilot runtime. Specifically, the repository cannot leverage Claude Code's per-subagent tool restrictions, subagent-scoped hooks, preloaded skills, or project-level permission enforcement — all of which are required to replicate the deterministic routing, guarded handoffs, and completion-gate behavior the Copilot orchestration model provides.

A command-only or `CLAUDE.md`-only approach (the original draft design) intentionally discards supported Claude features and is not a correct Claude-native architecture.

## Proposed Behavior

Add a first-class Claude Code architecture to the repository that maps the current Copilot orchestration model onto the four Claude-native layers, preserving existing workflow boundaries and specialist responsibilities with minimal duplication.

At a high level, the implementation should:

1. **Standing instructions layer**: Add a repo-root `CLAUDE.md` that carries forward tone policy, policy-compliance order, and top-level architectural context. Add `.claude/rules/*.md` files — optionally path-scoped — to carry the language-specific and directory-specific rules that currently live in `.github/instructions/*.instructions.md` files.

2. **Skills layer**: Implement direct-use workflows as project skills under `.claude/skills/<name>/SKILL.md`. Skills are the primary user-invocable entry point surface in Claude Code. The initial set must include at minimum: `orchestrate`, `commit-message`, `pr-author`, and `research-issue`. These replace `.claude/commands/` as the target surface for new work. The `orchestrate` skill must use `context: fork` and `agent: orchestrator` frontmatter to make delegation deterministic rather than prompt-driven.

3. **Subagents layer**: Register specialist personas as project subagents under `.claude/agents/`. Each subagent file must carry frontmatter that declares its specific `tools` allowlist (including permitted `Agent(...)` delegation targets), `model`, `skills` to preload, `hooks` for stop-gate enforcement, and `memory: project`. The initial set must include at minimum: `orchestrator`, `atomic-planner`, `atomic-executor`, `feature-review`, and `task-researcher`.

4. **Enforcement layer**: Define `.claude/settings.json` with an explicit `permissions` block that allowlists required `Bash(...)`, `Read`, `Edit(...)`, `Write(...)`, MCP, `Skill(...)`, and `Agent(...)` patterns, and includes `deny` rules for sensitive paths. Add `.claude/hooks/` entries for `SubagentStop` and `PreToolUse` to enforce completion signals and bash command validation without relying on prose instructions alone.

5. **Resumability**: Preserve the existing checkpoint-file pattern at `artifacts/orchestration/orchestrator-state.json`. The Claude orchestrator subagent must read this file before performing new work and write an updated checkpoint after each phase transition.

6. **Sync strategy**: Document and implement a strategy for keeping `.claude/agents/` content aligned with the canonical `.github/agents/*.agent.md` sources, and `.claude/skills/` aligned with `.github/skills/*/SKILL.md` sources, to prevent divergence over time.

7. **Architecture documentation**: Explicitly document supported equivalences, non-equivalences (particularly the absence of Copilot's declarative `handoffs:` metadata), and the Claude-native substitutes used in each case.

## Acceptance Criteria

### Layer 1 — Standing instructions

- [ ] A repo-root `CLAUDE.md` exists and includes: the repository tone policy, the policy-compliance reading order, references to the `.claude/rules/` directory for modular rule loading, and top-level architectural context for the Claude orchestration model
- [ ] At least one `.claude/rules/` file exists for each major language group represented in the repository (Python, PowerShell, C#, TypeScript), with `paths:` frontmatter scoping the rules to the relevant file extensions or directories, and content migrated from the corresponding `.github/instructions/*.instructions.md` files
- [ ] The `CLAUDE.md` does not embed long multi-step procedures; those are delegated to skills or subagents, consistent with the Claude Code documentation recommendation to move procedures out of `CLAUDE.md`

### Layer 2 — Skills

- [ ] A project skill exists at `.claude/skills/orchestrate/SKILL.md` with `context: fork`, `agent: orchestrator`, and `argument-hint: [objective]` frontmatter fields, and its body instructs the orchestrator to read policy, resume from checkpoint, delegate only through configured subagents, and not report completion until required artifacts and validation gates pass
- [ ] A project skill exists at `.claude/skills/commit-message/SKILL.md` that implements the commit-message workflow currently represented in `.github/agents/` or `.github/prompts/`, with frontmatter that restricts allowed tools to `Read`, `Bash(git log *)`, and `Bash(git diff *)`
- [ ] A project skill exists at `.claude/skills/pr-author/SKILL.md` that implements the PR authoring workflow, with frontmatter that restricts allowed tools to `Read` and `Bash(git log *)`
- [ ] A project skill exists at `.claude/skills/research-issue/SKILL.md` that implements the research task workflow, with frontmatter that restricts allowed tools to `Read`, `Grep`, `Glob`, and `WebFetch`
- [ ] No new user-invocable workflows are implemented under `.claude/commands/`; that directory is either absent or explicitly documented as a backward-compatibility surface only
- [ ] Each skill's frontmatter includes a `description` field that is accurate and specific enough for the Claude runtime to surface the skill at the correct invocation moment

### Layer 3 — Subagents

- [ ] A `orchestrator` subagent exists at `.claude/agents/orchestrator.md` with frontmatter declaring: `tools` restricted to permitted `Agent(...)` delegation targets (atomic-planner, atomic-executor, feature-review, task-researcher, and language-specific engineers), `Read`, `Grep`, `Glob`, `Bash`, and `mcp__drmCopilotExtension__.*` patterns; `model: sonnet`; `skills` listing at minimum `policy-compliance-order`, `feature-promotion-lifecycle`, `atomic-plan-contract`, and `acceptance-criteria-tracking`; `memory: project`; and a `Stop` hook that blocks termination unless a checkpoint update and required artifact paths are confirmed
- [ ] A `atomic-planner` subagent exists at `.claude/agents/atomic-planner.md` with frontmatter that constrains `tools` to `Read`, `Grep`, `Glob`, `Edit`, and `Write` on the `docs/` and `artifacts/` paths only, and with a `Stop` hook that blocks termination unless the output plan file path is confirmed
- [ ] A `atomic-executor` subagent exists at `.claude/agents/atomic-executor.md` with frontmatter that declares the language-specific toolchain commands it is permitted to run as explicit `Bash(...)` patterns rather than open shell access
- [ ] A `feature-review` subagent exists at `.claude/agents/feature-review.md` with frontmatter that restricts tools to `Read`, `Grep`, `Glob`, `Bash(git diff *)`, and `Write(/docs/features/active/**)`, and with a `Stop` hook that blocks termination unless the review artifact paths are confirmed
- [ ] A `task-researcher` subagent exists at `.claude/agents/task-researcher.md` with frontmatter that restricts tools to `Read`, `Grep`, `Glob`, `WebFetch`, and `Write(/artifacts/research/**)`, and with a `Stop` hook that blocks termination unless the research artifact path is confirmed
- [ ] No subagent's `tools` frontmatter field uses an open-ended pattern equivalent to "all tools"; every subagent has an explicit and deliberately scoped allowlist
- [ ] Each subagent's `description` field is accurate and specific enough that the Claude runtime passes the right task types to it without prompt-text disambiguation

### Layer 4 — Enforcement

- [ ] A `.claude/settings.json` file exists with a `permissions` block that includes explicit `allow` entries for `Bash(git *)`, `Bash(poetry run *)`, `Bash(pwsh *)`, `Read`, `Edit(/docs/**)`, `Write(/docs/**)`, `Write(/artifacts/**)`, `mcp__drmCopilotExtension__.*`, `Skill(orchestrate *)`, `Skill(commit-message *)`, `Skill(pr-author *)`, and `Skill(research-issue *)`, and explicit `deny` entries for sensitive paths including `.env` and any secrets directories
- [ ] The `.claude/settings.json` includes a `hooks.SubagentStop` entry with a `matcher` that targets at minimum `atomic-planner`, `atomic-executor`, `feature-review`, and `task-researcher`, and whose hook body blocks stopping when the subagent output is missing a required completion marker or artifact path
- [ ] The `.claude/settings.json` includes a `hooks.PreToolUse` entry for `Bash` that invokes a validation script (PowerShell or bash) from `.claude/hooks/`, and that script exists in the repository with at least basic dangerous-command detection
- [ ] The `settings.json` does not use `permissionMode: bypassPermissions` or any global shell-open pattern as the default; the default mode is `acceptEdits` or equivalent least-privilege starting point
- [ ] The enforcement layer documentation explicitly states which behaviors are enforced at runtime by hooks and settings versus which behaviors rely on prompt conventions, so that maintainers do not overstate the runtime guarantees

### Resumability and state

- [ ] The `orchestrator` subagent implementation includes explicit instructions to read `artifacts/orchestration/orchestrator-state.json` before performing any new orchestration work, and to write an updated checkpoint JSON after each phase transition (intake, planning, execution, review)
- [ ] The checkpoint schema documented in the subagent or in accompanying migration documentation matches the existing schema used by the Copilot orchestrator so that in-progress workflows are not orphaned during a Copilot-to-Claude transition

### Sync strategy and migration documentation

- [ ] The repository includes a documented sync strategy (in `docs/` or `CLAUDE.md`) that specifies the authoritative source for each asset category: whether `.claude/agents/` is generated from `.github/agents/*.agent.md`, maintained independently, or kept in sync through a named script or manual process
- [ ] The migration documentation explicitly lists each Copilot primitive and its Claude-native equivalent, with a third column for non-equivalences and documented fallback behavior for those gaps
- [ ] The documentation explicitly states that Copilot's declarative `handoffs:` metadata has no direct Claude equivalent, and identifies the combination of named subagents, skill `context: fork` + `agent:` routing, checkpoint files, and `SubagentStop` hooks as the Claude-native substitute
- [ ] The documentation explicitly states that `.claude/commands/` is a backward-compatible legacy surface and that `.claude/skills/` is the recommended surface for all new user-invocable workflows

### Validation

- [ ] An end-to-end walkthrough document or test scenario demonstrates a complete small-path orchestration run under Claude Code: invoking the `orchestrate` skill, the orchestrator subagent reading the checkpoint, delegating to `atomic-planner`, confirming the plan artifact, delegating to `atomic-executor`, and completing with a checkpoint write — with specific file paths and expected outputs cited at each step
- [ ] The walkthrough explicitly identifies at least two enforcement boundaries that are enforced by hooks or permissions rather than by prose, and confirms those gates block the expected disallowed operations

## Constraints & Risks

- Claude Code does not provide a direct equivalent for Copilot's declarative `handoffs:` metadata. The Claude-native substitute — named subagents plus skill `context: fork` delegation, checkpoint files, and `SubagentStop` hooks — approximates the behavior but relies on a different enforcement model. This must be documented explicitly and not presented as equivalent runtime enforcement.
- Custom subagents in Claude Code cannot themselves spawn further subagents from within a subagent invocation. Nested delegation must be coordinated by the main thread or routed through skills that fork a chosen agent. The `orchestrator` implementation must account for this constraint.
- The repository's `.github/agents/` files and `.github/skills/` files represent the canonical workflow content. Creating a second divergent set of Claude-native files without a defined sync strategy will increase maintenance cost and create drift risk. The sync strategy is a required deliverable, not an optional follow-up.
- Permission configuration is a usability and safety tradeoff. Overly narrow `Bash(...)` allowlists will interrupt orchestration mid-workflow. Overly broad patterns weaken the enforcement layer. The initial permission set in `settings.json` should be derived from an actual audit of the operations each subagent performs, not from guessing.
- Scope is limited to the four-layer architecture, skill and subagent definitions, settings and hooks, resumability, sync strategy, and validation guidance. It does not include rewriting every existing `.github/agents/` file, restructuring unrelated repository automation, or implementing agent teams (which are experimental, higher-cost, and not suited to this repository's sequential workflow model).
- Agent teams are explicitly out of scope. They are designed for collaborative parallel exploration, not for the repository's deterministic sequential pipeline (promotion → research → planning → execution → review).

## Test Conditions to Consider

- [ ] Validation that each `.claude/skills/` file can be invoked by name in a Claude Code session and produces the expected entry-point behavior (context fork, agent delegation, or direct workflow execution as applicable)
- [ ] Validation that each `.claude/agents/` subagent's `tools` frontmatter correctly restricts the tool surface: attempt an operation outside the declared allowlist and confirm it is blocked at the permission layer, not just by prose instruction
- [ ] Validation that the `SubagentStop` hooks in `settings.json` block premature termination when the required artifact path is absent from the subagent's output, and allow termination when the artifact path is present
- [ ] Validation that the `orchestrator` subagent reads `artifacts/orchestration/orchestrator-state.json` at the start of a session and correctly resumes from a partially populated checkpoint rather than restarting the workflow from scratch
- [ ] Validation that the `PreToolUse` bash-validation hook in `settings.json` invokes the hook script and blocks at least one representative dangerous-command pattern
- [ ] Documentation review confirming that every non-equivalence between Copilot and Claude is identified and that no section of the migration documentation claims runtime enforcement for behaviors that are enforced only by prompt conventions

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/claude-code-architecture/` folder from the template