# Claude Code Architecture

This document describes the four-layer architecture used to map the existing GitHub Copilot orchestration model in this repository onto Claude Code primitives. It covers the equivalence mapping, non-equivalences, sync strategy, and an end-to-end validation walkthrough.

The migration research source for this architecture is `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md`.
That migration research file is sufficient for the repository's Claude Code architecture mapping and runtime migration decisions covered by this document.

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

The runtime model uses a main-thread orchestrator because Claude subagents cannot spawn subagents. The `/orchestrate` entrypoint remains user-invocable, but the main session coordinates delegation to worker agents instead of routing orchestration through a nested orchestrator worker.

### Main-thread worker inventory

The committed orchestrator allowlist delegates to the following repository-canonical workers from the main thread:

- `atomic-planner`
- `atomic-executor`
- `feature-review`
- `task-researcher`
- `prd-feature`
- `staged-review`
- `epic-review`
- `status-updater`
- `python-typed-engineer`
- `powershell-typed-engineer`
- `csharp-typed-engineer`
- `typescript-engineer`

### Authoritative source by asset category

| `.claude/` Asset | Authoritative Source | Relationship |
|---|---|---|
| `.claude/rules/*.md` | `.github/instructions/*.instructions.md` | Derived: summarized policy content with `paths:` frontmatter added |
| `.claude/skills/<name>/SKILL.md` | `.github/skills/*/SKILL.md` and `.github/prompts/*.prompt.md` | Derived: workflow body adapted with Claude-specific frontmatter (`context:`, `agent:`, `allowed-tools:`) |
| `.claude/agents/*.md` | `.github/agents/*.agent.md` | Maintained alongside: manual sync using diff to reconcile tool lists, model settings, and hook declarations |
| `CLAUDE.md` | `.github/copilot-instructions.md` + `.github/skills/policy-compliance-order/SKILL.md` | Derived: standing instructions composed from tone policy and compliance order |
| `.claude/settings.json` | No direct `.github/` equivalent | Authored directly: Claude Code-specific permissions, hooks, and default mode |

### Canonical `.github/skills` migration map

| Canonical source | Claude runtime target | Notes |
|---|---|---|
| `.github/skills/README.md` | No Claude runtime mirror | Documentation-only; no separate Claude skills README is required |
| `.github/skills/acceptance-criteria-tracking/SKILL.md` | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | Runtime mirror used by executor, review, and status workers |
| `.github/skills/atomic-plan-contract/SKILL.md` | `.claude/skills/atomic-plan-contract/SKILL.md` | Runtime mirror used by orchestrator, planner, and executor |
| `.github/skills/csharp-change-budget-router/SKILL.md` | `.claude/skills/csharp-change-budget-router/SKILL.md` | Runtime mirror for C# routing and budget rules |
| `.github/skills/csharp-orchestration-state-machine/SKILL.md` | `.claude/skills/csharp-orchestration-state-machine/SKILL.md` | Runtime mirror for C# checkpoint state handling |
| `.github/skills/evidence-and-timestamp-conventions/SKILL.md` | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Runtime mirror for deterministic evidence artifact naming |
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | Runtime mirror for feature-promotion workflow rules |
| `.github/skills/feature-review-workflow/SKILL.md` | `.claude/skills/feature-review-workflow/SKILL.md` | Runtime mirror for feature, staged, and epic review workflow rules |
| `.github/skills/make-skill-template/SKILL.md` | `.claude/skills/make-skill-template/SKILL.md` | Maintenance-only runtime mirror for manual skill-authoring workflows |
| `.github/skills/policy-audit-template-usage/SKILL.md` | `.claude/skills/policy-audit-template-usage/SKILL.md` | Maintenance-only runtime mirror for policy-audit template usage |
| `.github/skills/policy-compliance-order/SKILL.md` | `.claude/skills/policy-compliance-order/SKILL.md` | Runtime mirror for mandatory policy-read ordering |
| `.github/skills/powershell-change-budget-router/SKILL.md` | `.claude/skills/powershell-change-budget-router/SKILL.md` | Runtime mirror for PowerShell routing and budget rules |
| `.github/skills/powershell-orchestration-state-machine/SKILL.md` | `.claude/skills/powershell-orchestration-state-machine/SKILL.md` | Runtime mirror for PowerShell checkpoint state handling |
| `.github/skills/pr-base-branch-merge-base/SKILL.md` | `.claude/skills/pr-base-branch-merge-base/SKILL.md` | Runtime mirror for PR base-branch resolution rules |
| `.github/skills/pr-context-artifacts/SKILL.md` | `.claude/skills/pr-context-artifacts/SKILL.md` | Runtime mirror for PR-context artifact conventions |
| `.github/skills/remediation-handoff-atomic-planner/SKILL.md` | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | Runtime mirror for remediation-to-planner handoff rules |
| `.github/skills/skill-canonical-location-audit/SKILL.md` | `.claude/skills/skill-canonical-location-audit/SKILL.md` | Maintenance-only runtime mirror for canonical-location audits |

### Canonical `.github/agents` migration map

The repository-canonical bounded workers are the Claude project agents committed under `.claude/agents/`. The excluded personal personas `mentor`, `api-architect`, `hlbpa`, `5.1-Beast-adjusted`, `5.1-Thinking-Beast-Mode-adjusted`, `gpt-5-beast-mode`, and `voidbeast-gpt41enhanced` remain out of project-scoped routing and are not part of automatic repository delegation.

| Canonical source | Claude runtime target | Notes |
|---|---|---|
| `.github/agents/5.1-Beast-adjusted.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |
| `.github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |
| `.github/agents/api-architect.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |
| `.github/agents/atomic_executor.agent.md` | `.claude/agents/atomic-executor.md` | Bounded executor worker invoked directly by the main thread |
| `.github/agents/atomic_planning.agent.md` | `.claude/agents/atomic-planner.md` | Bounded planner worker invoked directly by the main thread |
| `.github/agents/commentary-remediation.agent.md` | No default project-scoped runtime target | Optional maintenance-only remediation worker, not part of default routing |
| `.github/agents/commit-steward.agent.md` | `.claude/skills/commit-message/SKILL.md` | Direct-use skill surface preferred over a committed project worker |
| `.github/agents/csharp-atomic-executor.agent.md` | `.claude/agents/csharp-typed-engineer.md` | Folded into the committed C# implementation worker |
| `.github/agents/csharp-atomic-planning.agent.md` | No committed project-scoped runtime target | Planning specialization omitted in favor of the generic planner plus mirrored skills |
| `.github/agents/csharp-orchestrator.agent.md` | No committed project-scoped runtime target | Main-thread orchestration remains centralized; no nested C# orchestrator worker |
| `.github/agents/csharp-typed-engineer.agent.md` | `.claude/agents/csharp-typed-engineer.md` | Project-scoped C# implementation worker |
| `.github/agents/epic-review.agent.md` | `.claude/agents/epic-review.md` | Project-scoped epic review worker with wrapper skill support |
| `.github/agents/expert-nextjs-developer.agent.md` | No project-scoped runtime target | Personal or library-only framework persona |
| `.github/agents/expert-react-frontend-engineer.agent.md` | No project-scoped runtime target | Personal or library-only framework persona |
| `.github/agents/feature-review.agent.md` | `.claude/agents/feature-review.md` | Project-scoped feature review worker |
| `.github/agents/gpt-5-beast-mode.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |
| `.github/agents/hlbpa.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |
| `.github/agents/mentor.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |
| `.github/agents/orchestrator.agent.md` | `.claude/agents/orchestrator.md` plus `.claude/skills/orchestrate/SKILL.md` | Main-thread orchestrator guidance only; no nested orchestrator worker launch |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | No committed project-scoped runtime target | Optional PowerShell test specialist, not part of default project routing |
| `.github/agents/powershell-atomic-executor.agent.md` | `.claude/agents/powershell-typed-engineer.md` | Folded into the committed PowerShell implementation worker |
| `.github/agents/powershell-atomic-planning.agent.md` | No committed project-scoped runtime target | Planning specialization omitted in favor of the generic planner plus mirrored skills |
| `.github/agents/powershell-orchestrator.agent.md` | No committed project-scoped runtime target | Main-thread orchestration remains centralized; no nested PowerShell orchestrator worker |
| `.github/agents/powershell-typed-engineer.agent.md` | `.claude/agents/powershell-typed-engineer.md` | Project-scoped PowerShell implementation worker |
| `.github/agents/pr-author.agent.md` | `.claude/skills/pr-author/SKILL.md` | Direct-use skill surface preferred over a committed project worker |
| `.github/agents/prd-feature.agent.md` | `.claude/agents/prd-feature.md` plus `.claude/skills/fill-feature-docs/SKILL.md` | Project-scoped feature-doc worker with direct-use wrapper |
| `.github/agents/prd.agent.md` | No project-scoped runtime target | General PRD generator is not part of deterministic repository routing |
| `.github/agents/pytest-unit-test-coding.agent.md` | No committed project-scoped runtime target | Optional Python test specialist, not part of default project routing |
| `.github/agents/python-atomic-executor.agent.md` | `.claude/agents/python-typed-engineer.md` | Folded into the committed Python implementation worker |
| `.github/agents/python-atomic-planning.agent.md` | No committed project-scoped runtime target | Planning specialization omitted in favor of the generic planner plus mirrored skills |
| `.github/agents/python-execution-only-typed.agent.md` | `.claude/agents/python-typed-engineer.md` | Merged into the single committed Python implementation worker |
| `.github/agents/python-orchestrator.agent.md` | No committed project-scoped runtime target | Main-thread orchestration remains centralized; no nested Python orchestrator worker |
| `.github/agents/python-typed-engineer.agent.md` | `.claude/agents/python-typed-engineer.md` | Project-scoped Python implementation worker |
| `.github/agents/staged-review.agent.md` | `.claude/agents/staged-review.md` | Project-scoped staged review worker with wrapper skill support |
| `.github/agents/status_updater.agent.md` | `.claude/agents/status-updater.md` plus `.claude/skills/update-status/SKILL.md` | Project-scoped status synchronization worker |
| `.github/agents/task-researcher.agent.md` | `.claude/agents/task-researcher.md` plus `.claude/skills/research-issue/SKILL.md` | Project-scoped research worker with direct-use wrapper |
| `.github/agents/tdd-green.agent.md` | No project-scoped runtime target | Optional personal or library-only TDD helper |
| `.github/agents/tdd-red.agent.md` | No project-scoped runtime target | Optional personal or library-only TDD helper |
| `.github/agents/tdd-refactor.agent.md` | No project-scoped runtime target | Optional personal or library-only TDD helper |
| `.github/agents/typescript-engineer.agent.md` | `.claude/agents/typescript-engineer.md` | Project-scoped TypeScript implementation worker |
| `.github/agents/voidbeast-gpt41enhanced.agent.md` | No project-scoped runtime target | Personal or library-only persona; excluded from project routing |

### Direct-use `.github/prompts` migration map

| Canonical source | Claude runtime target | Notes |
|---|---|---|
| `.github/prompts/add-educational-comments.prompt.md` | No committed project-scoped runtime target | Optional maintenance workflow; not part of the committed direct-use Claude surface |
| `.github/prompts/breakdown-bug-prd.prompt.md` | No committed project-scoped runtime target | Optional planning support prompt; not part of the committed direct-use Claude surface |
| `.github/prompts/breakdown-epic-arch.prompt.md` | No committed project-scoped runtime target | Optional planning support prompt; not part of the committed direct-use Claude surface |
| `.github/prompts/breakdown-epic-pm.prompt.md` | No committed project-scoped runtime target | Optional planning support prompt; not part of the committed direct-use Claude surface |
| `.github/prompts/breakdown-feature-implementation.prompt.md` | No committed project-scoped runtime target | Optional planning support prompt; not part of the committed direct-use Claude surface |
| `.github/prompts/breakdown-feature-prd.prompt.md` | No committed project-scoped runtime target | Optional planning support prompt; not part of the committed direct-use Claude surface |
| `.github/prompts/code-exemplars-blueprint-generator.prompt.md` | No committed project-scoped runtime target | Optional maintenance workflow; not part of the committed direct-use Claude surface |
| `.github/prompts/export-chat.prompt.md` | No committed project-scoped runtime target | Optional maintenance workflow; not part of the committed direct-use Claude surface |
| `.github/prompts/fillout-prd-feature.prompt.md` | `.claude/skills/fill-feature-docs/SKILL.md` | Direct-use feature-document completion skill |
| `.github/prompts/generate-atomic-plan.prompt.md` | No separate direct-use runtime target | Planner reference content is folded into the planner skill and agent workflow |
| `.github/prompts/generate-commit-message-repo.prompt.md` | `.claude/skills/commit-message/SKILL.md` | Direct-use commit-message skill |
| `.github/prompts/generate-pr.prompt.md` | `.claude/skills/pr-author/SKILL.md` | Direct-use PR body generation skill |
| `.github/prompts/javascript-typescript-jest.prompt.md` | No committed project-scoped runtime target | Optional language-specific workflow; not part of the committed direct-use Claude surface |
| `.github/prompts/orchestrate-csharp-work.prompt.md` | No separate direct-use runtime target | Main-thread orchestrator guidance remains centralized rather than split into per-language direct-use skills |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | No separate direct-use runtime target | Main-thread orchestrator guidance remains centralized rather than split into per-language direct-use skills |
| `.github/prompts/orchestrate-python-work.prompt.md` | No separate direct-use runtime target | Main-thread orchestrator guidance remains centralized rather than split into per-language direct-use skills |
| `.github/prompts/orchestrate-work.prompt.md` | `.claude/skills/orchestrate/SKILL.md` | Direct-use orchestration entrypoint |
| `.github/prompts/remediate-comments.prompt.md` | No committed project-scoped runtime target | Optional maintenance workflow; not part of the committed direct-use Claude surface |
| `.github/prompts/research-issue.prompt.md` | `.claude/skills/research-issue/SKILL.md` | Direct-use research artifact skill |
| `.github/prompts/review-epic.prompt.md` | `.claude/skills/review-epic/SKILL.md` | Direct-use wrapper for the epic review worker |
| `.github/prompts/review-feature.prompt.md` | `.claude/skills/review-feature/SKILL.md` | Direct-use wrapper for the feature review worker |
| `.github/prompts/review-staged.prompt.md` | `.claude/skills/review-staged/SKILL.md` | Direct-use wrapper for the staged review worker |
| `.github/prompts/update_status.prompt.md` | `.claude/skills/update-status/SKILL.md` | Direct-use wrapper for the status synchronization worker |

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

The user runs the `/orchestrate` skill (`.claude/skills/orchestrate/SKILL.md`). The skill is a direct-use entrypoint that keeps orchestration in the main session. It does not use `context: fork` or `agent: orchestrator`; instead, it loads the orchestrator workflow guidance and proceeds as the main-thread orchestrator.

**Step 2 — Orchestrator reads checkpoint state**

The orchestrator reads `artifacts/orchestration/orchestrator-state.json` to determine the current phase, pending delegations, and any unfinished work from a previous session. If no checkpoint exists, the orchestrator initializes a new orchestration cycle.

**Step 3 — Orchestrator delegates to `atomic-planner`**

Based on the checkpoint state, the orchestrator delegates planning to the `atomic-planner` subagent (`.claude/agents/atomic-planner.md`). The planner's tool list is restricted to `Read`, `Grep`, `Glob`, and scoped write access to `docs/**` and `artifacts/**`. It cannot execute arbitrary Bash commands.

**Step 4 — `atomic-planner` writes plan**

The `atomic-planner` produces a phased plan file at `docs/features/active/<feature>/plan.md`. The plan follows the format defined in the `atomic-plan-contract` skill, with Phase 0 policy reads, implementation phases, and a final QA loop. The planner's `SubagentStop` hook (defined in `.claude/settings.json`) blocks termination unless the planner's output includes a plan file path.

**Step 5 — Orchestrator delegates to `atomic-executor`**

The orchestrator reads the plan path from the planner's output and delegates execution to the `atomic-executor` subagent (`.claude/agents/atomic-executor.md`). The executor has scoped `Bash(...)` patterns for each toolchain command (`poetry run black *`, `npx prettier *`, `pwsh *`, etc.) and PowerShell MCP access via `mcp__drmCopilotExtension__run_poshqc_format`, `mcp__drmCopilotExtension__run_poshqc_analyze`, `mcp__drmCopilotExtension__run_poshqc_test`, and `mcp__drmCopilotExtension__run_poshqc_analyze_autofix`.

**Step 6 — Executor runs toolchain and writes evidence**

The executor works through the plan task-by-task, running the repository toolchain (format, lint, type-check, test) and writing evidence artifacts to the feature folder's `evidence/` directory. Each completed task is checked off in the plan file.

**Step 7 — Orchestrator writes updated checkpoint**

After the executor completes, the orchestrator updates `artifacts/orchestration/orchestrator-state.json` with the new phase state, completed delegations, and any remaining work. This checkpoint enables session resumption.

### Enforcement boundaries

Two enforcement boundaries protect this orchestration flow through hooks and permissions configured in `.claude/settings.json`:

1. **`PreToolUse` hook — dangerous Bash command blocking.** Before any `Bash` tool invocation, Claude Code executes `.claude/hooks/validate-bash.ps1`. This script checks the proposed command against a list of blocked patterns (`rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`, `git reset --hard`, `git push -f`). If any blocked pattern is detected, the hook exits with code 1 and the Bash command is rejected before execution. Safe commands proceed with exit code 0.

2. **`SubagentStop` hook — premature termination blocking.** When any of the bounded worker agents covered by the configured matcher (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, `staged-review`, `epic-review`, `status-updater`) attempts to stop, the `SubagentStop` hook inspects the subagent's output for required completion markers (`plan-path`, `research-path`, `review-artifact`, `PREFLIGHT`, or `evidence/`). If the required marker is absent, the hook exits with code 1 and blocks the subagent from stopping, forcing it to continue until the required artifact path is produced.

3. **`config-change handling` boundary — configuration edit control.** The migration research defines config-change handling as the boundary for auditing or blocking edits to Claude configuration files. In the implemented repository runtime, this boundary is documented but not currently wired as a live `ConfigChange` hook entry in `.claude/settings.json`.

## 5. Repository-Enforceable Controls

The repository can enforce the following controls directly through committed files:

- `CLAUDE.md` and `.claude/rules/*.md` define standing guidance and path-scoped policy summaries.
- `.claude/settings.json` enforces project-scoped `permissions.allow` and `permissions.deny` entries.
- `PreToolUse` enforces dangerous-command validation before Bash execution.
- `SubagentStop` enforces worker completion markers before bounded workers stop.
- `config-change handling` is represented as a documented repository boundary for configuration edits, even though the live runtime hook is not yet wired in the committed settings file.

## 6. Managed-Settings-Only Controls

The following controls require managed settings outside the repository if they must be non-overrideable for every user and launch mode:

- Forcing the default orchestrator agent in a way local users cannot override.
- Preventing local edits to project settings, hooks, or skills through out-of-repo policy.
- Requiring managed hook configuration for `PreToolUse`, `SubagentStop`, or `config-change handling` across all sessions.
- Enforcing organization-level restrictions on personal or library-only personas that remain outside project scope.
