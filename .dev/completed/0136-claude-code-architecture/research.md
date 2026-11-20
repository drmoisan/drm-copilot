<!-- markdownlint-disable-file -->

# Task Research Notes: claude-code-architecture

## Research Executed

### File Analysis

- `c:\Users\DanMoisan\repos\drm-copilot\docs\features\potential\2026-04-11-claude-code-architecture.md`
  - The draft feature frames Claude support primarily around `CLAUDE.md` plus `.claude/commands/`, but it does not account for Claude Code's first-class project skills, custom subagents, `.claude/rules/`, hooks, or native skill/subagent permission controls.
- `c:\Users\DanMoisan\repos\drm-copilot\docs\features\research\claude-ecosystem.md`
  - The earlier research correctly identified `CLAUDE.md`, permissions, and checkpoint reuse, but it is now incomplete in two important ways: it treats `.claude/commands/` as the primary user-extensibility surface and states that Claude has no direct skill primitive.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\orchestrator.agent.md`
  - The Copilot orchestrator relies on declarative `handoffs:`, specialist agent routing, reusable skills, and a checkpoint file at `artifacts/orchestration/orchestrator-state.json`; those concerns need native Claude equivalents rather than a flat command-only port.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\feature-promotion-lifecycle\SKILL.md`
  - The repository already treats reusable workflow rules as canonical skill content, not inline agent duplication. That matches Claude Code's skill model more closely than the current draft suggests.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\policy-compliance-order\SKILL.md`
  - The repo expects a deterministic policy reading order and hard constraints. In Claude Code, those belong in `CLAUDE.md` and `.claude/rules/`, not in ad hoc slash commands.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\evidence-and-timestamp-conventions\SKILL.md`
  - Canonical artifact naming and evidence location rules already exist as reusable skill content and should remain reusable in Claude through skills or rule files rather than being flattened into one monolithic `CLAUDE.md`.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\README.md`
  - The repository's own skill taxonomy mirrors Claude's current design intent: reusable guidance belongs in skills and should be referenced rather than duplicated.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\prompts\research-issue.prompt.md`
  - Direct-use prompts in the Copilot ecosystem behave more like Claude skills than like Claude subagents; they are user-invocable workflows that inject structured instructions on demand.

### Code Search Results

- `handoffs:|tools: \[|Shared skills|Use these reusable skills`
  - Found repeated across `.github/agents/*.agent.md`, confirming that the Copilot ecosystem separates orchestration, specialist personas, and reusable skills instead of embedding everything into one prompt.
- `agent: '|description: '`
  - Found across `.github/prompts/*.prompt.md`, showing that prompt files are direct-use entry points mapped to specific agents; this is closer to Claude skills with `context: fork` plus `agent:` than to raw `.claude/commands/` files.
- `Canonical|When to Use This Skill|Reusable`
  - Found across `.github/skills/**/SKILL.md`, confirming that reusable conventions, contracts, and workflows are already organized as skills.
- `Claude Code|CLAUDE.md|.claude/commands|.claude/skills|.claude/agents`
  - Existing repository references are limited to research notes and the draft potential issue; there is no actual `.claude/` implementation yet.

### External Research

- #githubRepo:"anthropics/claude-code settings hooks examples"
  - Official GitHub-hosted examples under `examples/settings` and `examples/hooks` show that managed settings, hook validation, and policy enforcement are expected parts of Claude Code deployments; the examples explicitly position settings and hooks as enforcement mechanisms rather than relying on prompt text alone.
- #githubRepo:"anthropics/claude-code mdm managed settings"
  - Official MDM examples document managed deployment on Windows and macOS and reinforce that organization-wide policy belongs in managed settings, with `/status` used to verify active sources.
- #fetch:https://code.claude.com/docs/en/memory
  - `CLAUDE.md` provides persistent instructions, not hard enforcement. Nested `CLAUDE.md` and `.claude/rules/` files support scoped loading, `@` imports, and AGENTS.md import bridging. Claude explicitly recommends moving multi-step procedures out of `CLAUDE.md` into skills.
- #fetch:https://code.claude.com/docs/en/skills
  - Skills are a first-class Claude Code primitive. Custom commands have been merged into skills; `.claude/commands/*.md` still works, but new work is recommended under `.claude/skills/<name>/SKILL.md`. Skills support frontmatter, supporting files, arguments, optional `context: fork`, `agent:`, `allowed-tools`, hooks, path scoping, and invocation controls.
- #fetch:https://code.claude.com/docs/en/sub-agents
  - Custom subagents are also first-class. Project subagents live in `.claude/agents/`, have their own prompt body plus frontmatter for tools, disallowed tools, model, permission mode, hooks, memory, MCP servers, skills, isolation, and background behavior. This directly contradicts the earlier draft assumption that Claude lacks native specialist-agent registration.
- #fetch:https://code.claude.com/docs/en/settings
  - Settings define shared project policy in `.claude/settings.json`, including permissions, hooks, enabled plugins, and the default session agent. The settings docs also state that skills are part of the configuration system and that subagents are discovered by scope.
- #fetch:https://code.claude.com/docs/en/permissions
  - Permission rules can target `Skill(...)`, `Agent(...)`, Bash patterns, Read/Edit paths, and MCP tool names. Claude explicitly recommends hooks when behavior must be enforced more deterministically than prompt instructions allow.
- #fetch:https://code.claude.com/docs/en/hooks
  - Hooks are the native runtime enforcement layer. `PreToolUse`, `PermissionRequest`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, and `Stop` can block, rewrite, or continue execution. Hooks can be defined in settings, skills, or subagent frontmatter and can target Bash, file edits, agents, and MCP tools.
- #fetch:https://code.claude.com/docs/en/commands
  - Built-in commands are CLI features, but custom user workflows should now be implemented as skills. The commands reference explicitly says: "To add your own commands, see skills."
- #fetch:https://code.claude.com/docs/en/agent-teams
  - Agent teams are experimental, higher-cost, and designed for collaborative multi-session work. The docs position subagents as the preferred mechanism for focused delegated tasks whose results only need to return to a lead coordinator.

### Project Conventions

- Standards referenced: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `policy-compliance-order`, and `evidence-and-timestamp-conventions`.
- Instructions followed: research-only work restricted to `artifacts/research/`; evidence-based findings only; no source or config modifications outside the scratch research area.

## Key Discoveries

### Project Structure

The repository's current Copilot taxonomy has four distinct roles:

1. Repository-wide and language-specific standing policy lives in `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md`.
2. Direct-use entry points live in `.github/prompts/*.prompt.md`.
3. Specialist personas and orchestrators live in `.github/agents/*.agent.md`.
4. Reusable workflows and contracts live in `.github/skills/*/SKILL.md`.

That split maps poorly to a command-only Claude design because Claude Code already has four matching native constructs:

1. `CLAUDE.md` and `.claude/rules/` for standing instructions.
2. `.claude/skills/` for user-invocable or automatically loaded workflows.
3. `.claude/agents/` for named specialist personas with their own tool/model/hook boundaries.
4. `.claude/settings.json` plus hooks for permission policy and deterministic enforcement.

The repo does not currently contain any `.claude/` implementation. This means the draft feature is still free to choose a Claude-native taxonomy instead of preserving an outdated approximation.

### Implementation Patterns

The strongest Claude-native pattern for this repository is:

- Put always-on repository policy in `CLAUDE.md` plus `.claude/rules/`.
- Put reusable direct-use workflows in `.claude/skills/`, not `.claude/commands/`, because custom commands are now subsumed by skills.
- Put specialist personas in `.claude/agents/` so they get native frontmatter fields for tool allowlists, models, hooks, memory, skills, MCP servers, and worktree isolation.
- Use skills with `context: fork` and `agent:` to turn those subagents into deterministic user entry points.
- Use `.claude/settings.json` permissions plus hooks to enforce what prompt text alone cannot reliably guarantee.

For the Copilot-to-Claude mapping in this repository, the closest correspondence is therefore:

- Copilot instruction files -> `CLAUDE.md` + `.claude/rules/`
- Copilot prompts -> Claude skills
- Copilot specialist agents -> Claude custom subagents
- Copilot reusable skills -> Claude skills, optionally preloaded into subagents via the `skills` frontmatter field
- Copilot handoff metadata -> Claude subagent delegation plus hook-based stop gates and settings-based permission controls

The earlier research note's proposed runtime pattern—keeping specialists as arbitrary files outside `.claude/agents/` and reading them manually at delegation time—is technically possible, but it gives up native Claude features that are directly relevant to this repo: per-subagent tool restrictions, per-subagent models, scoped hooks, scoped MCP servers, and persistent subagent memory.

### Complete Examples

```markdown
<!-- Recommended Claude-native entry point: a skill that invokes a named orchestrator subagent -->

# .claude/skills/orchestrate/SKILL.md
---
name: orchestrate
description: Route a repository request through the deterministic orchestration workflow. Use for feature, bug, research, planning, execution, and audit handoffs in this repository.
disable-model-invocation: true
context: fork
agent: orchestrator
argument-hint: [objective]
allowed-tools:
  - Bash(git *)
  - Read
  - Grep
  - Glob
---

Execute the repository orchestration workflow for:

$ARGUMENTS

Required behavior:
- Read repository policy from CLAUDE.md and matching rules.
- Persist and resume state from `artifacts/orchestration/orchestrator-state.json`.
- Delegate specialist work only through the configured subagents.
- Do not report completion until required artifacts and validation gates pass.


# .claude/agents/orchestrator.md
---
name: orchestrator
description: Deterministic repository orchestrator. Use proactively for end-to-end feature and bug workflows.
tools:
  - Agent(atomic-planner,atomic-executor,feature-review,task-researcher,prd-feature,python-typed-engineer,powershell-typed-engineer,typescript-engineer)
  - Read
  - Grep
  - Glob
  - Bash
  - mcp__drmCopilotExtension__.*
model: sonnet
skills:
  - policy-compliance-order
  - feature-promotion-lifecycle
  - atomic-plan-contract
  - acceptance-criteria-tracking
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Evaluate whether the orchestrator may stop.
            Block stopping unless the last message confirms checkpoint update,
            required artifacts, and either a completed small-path or large-path review.
            Context: $ARGUMENTS
memory: project
---

You are the repository orchestrator.

Enforce deterministic variable handling, checkpoint writes, and specialist-only delegation.
Resume from `artifacts/orchestration/orchestrator-state.json` before doing new work.
```

### API and Schema Documentation

Claude-native roles and their authoritative capabilities are now clearer than the draft issue states:

- `CLAUDE.md`
  - Role: persistent standing instructions and architecture/policy context.
  - Best for: tone, coding standards, workflow invariants, imports of existing `AGENTS.md`, and high-level guidance.
  - Not for: long procedures, side-effecting workflows, or hard enforcement.

- `.claude/rules/*.md`
  - Role: modular instruction files, optionally path-scoped with `paths:`.
  - Best for: language-specific or directory-specific rules that currently live in many `.github/instructions/*.instructions.md` files.

- `.claude/skills/<name>/SKILL.md`
  - Role: first-class reusable workflows or reference packets.
  - Best for: commit-message generation, PR authoring, research kickoff, planning kickoffs, template-driven document creation, and any repetitive workflow that should load on demand.
  - Key frontmatter fields: `name`, `description`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `context`, `agent`, `hooks`, `paths`, `model`, `effort`, `shell`.
  - Important lifecycle rule: the description is always part of the available-skill context unless `disable-model-invocation: true`; full skill content loads when invoked.

- `.claude/agents/*.md`
  - Role: first-class custom specialist personas.
  - Best for: atomic planner, atomic executor, feature reviewer, task researcher, PRD/spec writer, and the orchestrator itself.
  - Key frontmatter fields: `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`, `maxTurns`, `initialPrompt`.
  - Important limitation: subagents cannot spawn other subagents from within a subagent invocation; nested delegation must be coordinated by the main thread or via skills that fork a chosen agent.

- `.claude/settings.json`
  - Role: team-shared enforced configuration.
  - Best for: `permissions`, shared `hooks`, `enabledPlugins`, project `agent`, and MCP/plugin settings.
  - Important enforcement rule: deny-first precedence, and hooks can still block even when allow rules exist.

- `.claude/commands/*.md`
  - Role: backward-compatible legacy custom-command location.
  - Best for: compatibility only.
  - Current official guidance: new user workflows should be implemented as skills because commands have been merged into the skill mechanism and skills support supporting files, invocation control, and forked-agent execution.

### Configuration Examples

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "agent": "orchestrator",
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(poetry run *)",
      "Bash(pwsh *)",
      "Read",
      "Edit(/docs/**)",
      "Write(/docs/**)",
      "mcp__drmCopilotExtension__.*",
      "Skill(orchestrate *)",
      "Skill(commit-message *)",
      "Skill(pr-author *)",
      "Skill(research-issue *)"
    ],
    "deny": [
      "Agent(Explore)",
      "Read(./.env)",
      "Read(./secrets/**)",
      "Bash(curl *)"
    ],
    "defaultMode": "acceptEdits"
  },
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "atomic-planner|atomic-executor|feature-review|task-researcher",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Block stopping if the subagent output is missing the required completion marker or artifact path. Context: $ARGUMENTS"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "shell": "powershell",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-bash-command.ps1"
          }
        ]
      }
    ]
  }
}
```

### Technical Requirements

- Replace the draft "`CLAUDE.md` + `.claude/commands/` only" model with a four-layer Claude taxonomy:
  - standing instructions,
  - reusable skills,
  - specialist subagents,
  - enforced settings/hooks.
- Revise acceptance criteria so that:
  - project skills are the primary user-invocable workflow surface,
  - custom subagents are the primary specialist persona surface,
  - `.claude/commands/` is optional legacy compatibility, not the main design target.
- Keep deterministic handoffs by combining:
  - named subagent types,
  - skill `context: fork` + `agent:` routing,
  - shared checkpoint files,
  - `SubagentStop`/`Stop` hooks,
  - permissions that restrict which skills and agents can run.
- Preserve the repository's canonical workflow content by either:
  - generating `.claude/skills` and `.claude/agents` from existing `.github` sources, or
  - manually migrating canonical content once, then maintaining Claude-native files as the runtime truth.
- Use `.claude/rules/` instead of overloading the root `CLAUDE.md` with all language-specific detail.

**Mandatory unachievable objective callout**:
- **The draft objective that "everything should be in `CLAUDE.md` files or in `.claude/commands/` files" is not achievable as a correct Claude-native architecture because Claude Code has first-class skills and first-class custom subagents that are the intended runtime surfaces for reusable workflows and specialist personas. A command-only design would intentionally discard supported features needed by this repository, including per-subagent tool restrictions, subagent-specific hooks, preloaded skills, memory, MCP scoping, and skill-based fork execution.**
- **A one-to-one recreation of Copilot's runtime-enforced `handoffs:` metadata is also not achievable. Claude can approximate deterministic handoffs through named subagents, permissions, hooks, and checkpoint files, but the enforcement model is different and must be documented as such.**

## Recommended Approach

Adopt a Claude-native runtime architecture rather than a command-only compatibility shim.

For this repository, the best implementation pattern is:

1. Use a repo-root `CLAUDE.md` plus `.claude/rules/` to carry standing policy, language rules, and architecture context.
2. Implement direct-use workflows as project skills in `.claude/skills/`.
   - `orchestrate`
   - `commit-message`
   - `pr-author`
   - `research-issue`
   - any document/template-filling workflows now represented as `.github/prompts/*.prompt.md`
3. Implement specialist personas as project subagents in `.claude/agents/`.
   - `orchestrator`
   - `atomic-planner`
   - `atomic-executor`
   - `feature-review`
   - `task-researcher`
   - language-specific engineers
4. Invoke those specialists through skills that use `context: fork` and `agent:` where deterministic entry points are required.
5. Enforce handoff and completion behavior through `.claude/settings.json` permissions and hooks rather than relying on prose alone.
6. Continue to use the repository's checkpoint-file pattern (`artifacts/orchestration/orchestrator-state.json`) for resumability.

Applied to `docs/features/research/claude-ecosystem.md`, the concrete corrections are:

- Replace the row mapping `.github/skills/*/SKILL.md` to "inline in `CLAUDE.md` or referenced from commands" with "`.claude/skills/<name>/SKILL.md` (first-class runtime primitive)".
- Replace the guidance that user-invocable entry points belong primarily in `.claude/commands/` with "project skills are the primary entry points; `.claude/commands/` remains optional compatibility".
- Replace the guidance that specialist agent definitions should remain outside the runtime and be read manually at delegation time with "register specialist project subagents under `.claude/agents/`; if minimizing duplication matters, generate them from `.github/agents/*.agent.md` or otherwise keep a sync process".
- Add `.claude/rules/` as the analog for the current layered instruction-file ecosystem.
- Add hooks and permissions as the explicit deterministic enforcement layer for completion signals, guarded commands, and skill/agent availability.

Recommended file layout for this repository:

- `CLAUDE.md`
- `.claude/rules/*.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/commit-message/SKILL.md`
- `.claude/skills/pr-author/SKILL.md`
- `.claude/skills/research-issue/SKILL.md`
- `.claude/agents/orchestrator.md`
- `.claude/agents/atomic-planner.md`
- `.claude/agents/atomic-executor.md`
- `.claude/agents/feature-review.md`
- `.claude/agents/task-researcher.md`
- `.claude/settings.json`
- `.claude/hooks/*`

Rejected alternatives (brief, non-exhaustive):

- Command-only port using `.claude/commands/` plus `CLAUDE.md` and manual file reads.
  - Rejected because it ignores Claude's native skills/subagents model and weakens runtime control over personas, tools, hooks, and memory.
- Keep `.github/agents/*.agent.md` as the sole runtime specialist format and never register project subagents.
  - Rejected because Claude-native subagents provide capabilities the repository needs and the manual-read pattern is a downgrade, not a migration.
- Agent-team-first orchestration.
  - Rejected because agent teams are experimental, more expensive, and better suited to collaborative parallel exploration than to the repository's mostly sequential promotion -> research -> planning -> execution -> review pipeline.

## Implementation Guidance

- **Objectives**: correct the draft Claude architecture so it uses the actual Claude-native primitives; preserve deterministic orchestration semantics; minimize maintenance drift between Copilot and Claude assets.
- **Key Tasks**: add `CLAUDE.md`; add `.claude/rules/`; convert direct-use prompts into skills; convert specialist agents into `.claude/agents/`; add `.claude/settings.json` permissions and hooks; document the sync strategy between existing `.github` assets and Claude-native files.
- **Dependencies**: current `.github/agents/*.agent.md`, `.github/prompts/*.prompt.md`, `.github/skills/*/SKILL.md`, `artifacts/orchestration/orchestrator-state.json`, Claude Code project settings/hook support, and the `drmCopilotExtension` MCP surface already referenced by the repo.
- **Success Criteria**: the final architecture explicitly distinguishes instructions vs skills vs subagents vs enforcement; user-invocable workflows are implemented as skills rather than command-only files; specialist personas are implemented as Claude project subagents; permissions and hooks cover deterministic handoffs; the issue draft is updated to remove the claim that everything should live only in `CLAUDE.md` or `.claude/commands/`.