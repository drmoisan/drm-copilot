<!-- markdownlint-disable-file -->

# Task Research Notes: claude-code-github-skills-agents-migration

## Research Executed

### File Analysis

- `c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-04-11-claude-code-architecture-136\research.md`
  - The existing feature research correctly identifies Claude-native skills, subagents, settings, and hooks as the four runtime layers, but its recommended `/orchestrate` pattern still assumes a forked `orchestrator` subagent can delegate to other subagents. Current Claude documentation says subagents cannot spawn subagents, so that recommendation must be corrected.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\README.md`
  - `.github/skills` is already the repository’s canonical reusable-guidance layer. This maps directly to Claude project skills and should remain the single authored source for reusable workflow contracts.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\acceptance-criteria-tracking\SKILL.md`
  - Defines authoritative AC source resolution and check-off timing; this belongs in a Claude skill that is preloaded into execution, review, and status-sync agents.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\atomic-plan-contract\SKILL.md`
  - Defines plan schema, preflight loop, baseline evidence, and QA loop requirements; this must remain a reusable skill rather than being duplicated inside planner or executor prompts.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\feature-promotion-lifecycle\SKILL.md`
  - Encodes the promotion variable model and extension-first lifecycle. This is reusable orchestration knowledge and should stay as a Claude skill, preloaded into any orchestrator-style runtime.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\feature-review-workflow\SKILL.md`
  - Encodes the review artifact workflow and required shared skills. This belongs in a Claude skill and should be preloaded into review agents.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\policy-compliance-order\SKILL.md`
  - Provides the baseline policy order and hard constraints. In Claude, this should exist both as a reusable skill and as summarized standing instructions in `CLAUDE.md`/`.claude/rules/`.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\skills\evidence-and-timestamp-conventions\SKILL.md`
  - Defines canonical evidence directories and timestamp naming. This is reusable reference content and should stay as a Claude skill, not a hook script.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\orchestrator.agent.md`
  - The Copilot orchestrator assumes nested handoffs to planner, executor, reviewers, research, and feature-doc agents. In Claude, that orchestration can only be deterministic if the orchestrator runs in the main thread; a forked subagent cannot fan out to other subagents.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\python-orchestrator.agent.md`
  - Language-specific orchestrators are structurally similar to the top-level orchestrator and have the same nested-delegation incompatibility when modeled as Claude subagents.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\powershell-orchestrator.agent.md`
  - PowerShell orchestration also depends on downstream delegation, so it cannot remain a nested worker subagent in Claude. Its language-specific routing content should be extracted into skills consumed by the main-thread orchestrator.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\csharp-orchestrator.agent.md`
  - C# orchestration uses the same nested handoff pattern and must be treated the same way as Python and PowerShell orchestration.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\feature-review.agent.md`
  - This agent is a viable Claude project subagent because it is a bounded review worker. Its automatic remediation handoff must be driven by the main thread, not from inside the subagent.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\task-researcher.agent.md`
  - This agent is already constrained to `artifacts/research/` and maps cleanly to a Claude project subagent.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\atomic_planning.agent.md`
  - Planning-only behavior maps cleanly to a Claude subagent. The preflight loop must use main-thread chaining or a main-thread agent session so it can invoke the execution validator.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\atomic_executor.agent.md`
  - Execution-only behavior maps cleanly to a Claude subagent and is the natural target for deterministic artifact and toolchain stop-gates.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\pr-author.agent.md`
  - This is a direct-use authoring worker. It fits Claude best as a manual skill, optionally backed by a focused subagent.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\commit-steward.agent.md`
  - This is a direct-use authoring worker. It fits Claude best as a manual skill, optionally backed by a focused subagent.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\prd-feature.agent.md`
  - This fills feature docs and has an internal research handoff. In Claude, the doc-filling worker can remain a subagent, but the research handoff must move back to the main-thread orchestrator.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\epic-review.agent.md`
  - This is a bounded review workflow that can be a Claude subagent, but any remediation-planning fan-out must be controlled by the main thread.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\staged-review.agent.md`
  - This is a bounded review workflow that can be a Claude subagent, but its remediation planning must be orchestrated by the main thread.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\agents\status_updater.agent.md`
  - This is a bounded status-sync worker. It can be a Claude subagent, with optional remediation planning chained by the main thread if needed.
- `c:\Users\DanMoisan\repos\drm-copilot\.github\prompts\*.prompt.md`
  - The prompt inventory shows that many current direct-use entry points are really workflow launchers (`orchestrate-*`, `generate-pr`, `generate-atomic-plan`, `research-issue`, `review-*`, `update_status`). In Claude, these should be project skills, not `.claude/commands/` files.
- `c:\Users\DanMoisan\repos\drm-copilot\.github`
  - The top-level structure is `copilot-instructions.md`, `instructions/`, `skills/`, `agents/`, `prompts/`, `workflows/`, and `codex/`. In Claude-native terms this becomes standing instructions + rules, skills, subagents, settings/hooks, and documentation about sync and equivalence.

### Code Search Results

- `^(description|model|tools|handoffs):`
  - A metadata sweep across `.github/agents/*.agent.md` found 41 project agent definitions. The files fall into three categories: deterministic repository workflow agents with explicit handoffs, bounded single-purpose workers that can map directly to Claude subagents, and generic/personal personas that are not repository-canonical and should not be committed as project subagents.
- `.github/prompts/*.prompt.md`
  - The prompt inventory contains 23 direct-use prompt files. Most correspond to user-invocable workflows that should be turned into `.claude/skills/<name>/SKILL.md` rather than legacy `.claude/commands/*.md` files.
- `.github/skills/**/SKILL.md`
  - The skills inventory is already organized as canonical reusable contracts. Each file is a candidate for a same-name Claude project skill, with only Claude-specific frontmatter and supporting-file references added.
- `subagents cannot spawn other subagents|Agent\(agent_type\)`
  - Claude’s runtime limitation means any Copilot agent that performs downstream handoffs cannot remain a nested Claude subagent if deterministic delegation is required. Those handoffs must be moved to a main-thread orchestrator pattern.

### External Research

- #githubRepo:"anthropics/claude-code settings hooks examples"
  - Referenced through the prior verified research artifact in `docs/features/active/2026-04-11-claude-code-architecture-136/research.md`. The official examples establish settings and hooks as the native enforcement surface for permission checks, stop-gates, and managed policy.
- #fetch:https://code.claude.com/docs/en/skills
  - Skills are the first-class replacement for custom commands. They support `description`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `context`, `agent`, `hooks`, `paths`, supporting files, and argument substitution. The docs explicitly state that custom commands have been merged into skills.
- #fetch:https://code.claude.com/docs/en/sub-agents
  - Claude custom subagents are first-class project files under `.claude/agents/`. They support `tools`, `disallowedTools`, `model`, `permissionMode`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`, and `color`. The critical limitation is explicit: subagents cannot spawn other subagents.
- #fetch:https://code.claude.com/docs/en/settings
  - `.claude/settings.json` is the project-shared configuration file for permissions, hooks, environment, default `agent`, and related policy. Project settings are shareable through git, but command-line flags and local settings can still override non-managed defaults.
- #fetch:https://code.claude.com/docs/en/permissions
  - Permission rules are deny-first and additive across scopes. `permissions.deny` at the project level cannot be overridden by allow rules at other scopes. Rules can target `Skill(...)`, `Agent(...)`, `Bash(...)`, `Read(...)`, `Edit(...)`, `Write(...)`, `WebFetch(...)`, and MCP tool names. Hooks complement permissions but do not replace deny-first evaluation.
- #fetch:https://code.claude.com/docs/en/hooks
  - Hooks are the deterministic runtime enforcement layer. `PreToolUse` can block or rewrite tool input, `SubagentStop` can prevent a worker from stopping until required outputs exist, and `ConfigChange` can audit or block configuration changes. Hooks can be defined in settings or scoped to skills/agents. `Stop` hooks declared in subagent frontmatter become `SubagentStop` at runtime.
- #fetch:https://code.claude.com/docs/en/memory
  - `CLAUDE.md` and `.claude/rules/` are context, not hard enforcement. They should hold always-on guidance, while procedures and workflows should be moved into skills. Claude recommends keeping `CLAUDE.md` concise and using imports or rules for modularity.
- #fetch:https://code.claude.com/docs/en/commands
  - The commands reference explicitly says to add your own commands through skills. This confirms that `.claude/commands/` is a backward-compatibility surface, not the correct target for new repository workflows.

### Project Conventions

- Standards referenced: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, language-specific instruction files from `.github/instructions/`, `.github/skills/policy-compliance-order/SKILL.md`, and `.github/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Instructions followed: research-only work restricted to `artifacts/research/`; evidence-based findings only; no source or configuration edits outside the scratch research area; all Claude-runtime claims grounded in current official documentation plus repository-source inspection.

## Key Discoveries

### Project Structure

The repository’s `.github` area already separates concerns in a way that maps directly to Claude Code, but only if the migration keeps the layers distinct:

1. `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md` are standing policy.
2. `.github/skills/*/SKILL.md` are reusable workflow or reference contracts.
3. `.github/agents/*.agent.md` are persona/workflow contracts.
4. `.github/prompts/*.prompt.md` are direct-use workflow entry points.

The correct Claude-native expression is:

1. `CLAUDE.md` + `.claude/rules/**/*.md` for standing policy.
2. `.claude/skills/<name>/SKILL.md` for reusable reference content and user-invocable workflows.
3. `.claude/agents/<name>.md` for bounded worker personas that do not need nested delegation.
4. `.claude/settings.json` + `.claude/hooks/*` for deterministic enforcement, permission allow/deny rules, and stop-gates.

The migration must not flatten skills into agent bodies or commands into `CLAUDE.md`. That would recreate the same duplication the repository has already spent effort removing from the Copilot side.

The migration also needs one structural correction that is not captured in the draft spec: a Claude subagent cannot spawn downstream subagents. That means Copilot-style orchestrators with nested `handoffs:` cannot be implemented as forked worker agents if they still need to delegate planner/executor/reviewer/research workers. The orchestrator must either:

- run as the **main session agent** via `.claude/settings.json` `agent: "orchestrator"` or `claude --agent orchestrator`, or
- run as a **main-thread inline skill** whose instructions cause the main thread to spawn the downstream agents.

For this repository, the cleaner deterministic option is to make the project’s default main-thread agent the orchestrator and use manual skills such as `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue` as user-facing entry points.

### Implementation Patterns

#### Recommended runtime pattern

1. **Main-thread orchestrator**
   - Set `.claude/settings.json` `agent` to `orchestrator` so the main session itself owns `Agent(...)` delegation.
   - Keep `/orchestrate` as a manual skill that frames the objective, checkpoint behavior, and required artifact expectations for the already-active orchestrator.

2. **Reusable contracts remain skills**
   - Mirror each canonical `.github/skills/<name>/SKILL.md` to `.claude/skills/<name>/SKILL.md`.
   - Preload the necessary ones into project subagents through the `skills:` frontmatter field.

3. **Only bounded workers become Claude project subagents**
   - Good fit: planner, executor, feature review, task research, language engineers, and narrow document writers.
   - Poor fit: any nested orchestrator that still expects to call planner/executor/review from inside itself.

4. **Prompt files become wrapper skills**
   - `.github/prompts/*.prompt.md` should generally become manual project skills with Claude-native frontmatter, not `.claude/commands/*` files.

5. **Deterministic enforcement is deny-first plus hooks**
   - Project `permissions.deny` blocks disallowed tools, agents, skills, risky Bash patterns, and sensitive paths.
   - `PreToolUse` validates Bash and sensitive edits.
   - `SubagentStop` enforces artifact-output contracts.
   - `ConfigChange` protects `.claude/settings.json`, `CLAUDE.md`, and `.claude/rules/**` from discretionary edits outside dedicated migration workflows.

#### `.github/skills` → Claude mapping (file-by-file)

| `.github` source file | Current role | Claude-native treatment | Claude target file(s) | Handoff / invocation model | Deterministic enforcement notes |
|---|---|---|---|---|---|
| `.github/skills/README.md` | Human-facing taxonomy for canonical skills | Keep as documentation only; do not load at runtime | `docs/engineering/claude-code-architecture.md` should cite it; no `.claude` runtime file needed | N/A | Prevent duplication by documenting `.github/skills` as authored source and `.claude/skills` as runtime mirror |
| `.github/skills/acceptance-criteria-tracking/SKILL.md` | AC source resolution and check-off contract | Mirror as project skill | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | Preload into executor, review, and status-sync subagents | `SubagentStop` should require AC status output when those workers are expected to check off criteria |
| `.github/skills/atomic-plan-contract/SKILL.md` | Canonical plan schema and QA loop | Mirror as project skill | `.claude/skills/atomic-plan-contract/SKILL.md` | Preload into planner, executor, and orchestrator runtime | `SubagentStop` should block planner/executor completion when required plan artifacts or QA summaries are absent |
| `.github/skills/csharp-change-budget-router/SKILL.md` | C# routing and budget rules | Mirror as project skill | `.claude/skills/csharp-change-budget-router/SKILL.md` | Preload into main orchestrator and any optional C#-only main-thread agent | Use project deny rules to keep non-C# agents from editing C# paths unless explicitly allowed |
| `.github/skills/csharp-orchestration-state-machine/SKILL.md` | C# checkpoint schema | Mirror as project skill | `.claude/skills/csharp-orchestration-state-machine/SKILL.md` | Preload into main orchestrator and optional C# orchestration mode | `PreToolUse` or `SubagentStop` can require checkpoint file writes before stop |
| `.github/skills/evidence-and-timestamp-conventions/SKILL.md` | Canonical evidence locations and timestamp rules | Mirror as project skill | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Preload into reviewers, executors, and status-sync workers | Hooks should validate required artifact paths against these conventions |
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | Promotion variable model and folder lifecycle | Mirror as project skill | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | Preload into main orchestrator | `PreToolUse` should restrict promotion-related Bash/PowerShell commands to the documented tool surface |
| `.github/skills/feature-review-workflow/SKILL.md` | Canonical PR-style review workflow | Mirror as project skill | `.claude/skills/feature-review-workflow/SKILL.md` | Preload into `feature-review`, `staged-review`, and `epic-review` workers | `SubagentStop` should check for required review artifact files |
| `.github/skills/make-skill-template/SKILL.md` | Meta-skill for creating skills | Mirror as optional manual project skill | `.claude/skills/make-skill-template/SKILL.md` | Manual-only skill; `disable-model-invocation: true` | Restrict with `permissions.ask` or `permissions.deny` for skill-authoring writes unless explicitly invoked |
| `.github/skills/policy-audit-template-usage/SKILL.md` | Policy-audit artifact rules | Mirror as project skill | `.claude/skills/policy-audit-template-usage/SKILL.md` | Preload into review workers | `SubagentStop` should require template-derived audit artifact names and validator success |
| `.github/skills/policy-compliance-order/SKILL.md` | Baseline policy order | Mirror as project skill and summarize in standing instructions | `.claude/skills/policy-compliance-order/SKILL.md`, plus `CLAUDE.md` and `.claude/rules/*` summaries | Preload into every repository-controlled subagent | Use `ConfigChange` auditing and `permissions.deny` on policy files to prevent discretionary policy edits |
| `.github/skills/powershell-change-budget-router/SKILL.md` | PowerShell routing and budget rules | Mirror as project skill | `.claude/skills/powershell-change-budget-router/SKILL.md` | Preload into main orchestrator and optional PowerShell-only main-thread mode | Pair with `permissions.deny` on disallowed PowerShell mutation scopes |
| `.github/skills/powershell-orchestration-state-machine/SKILL.md` | PowerShell checkpoint schema | Mirror as project skill | `.claude/skills/powershell-orchestration-state-machine/SKILL.md` | Preload into main orchestrator and optional PowerShell orchestration mode | Enforce checkpoint persistence through hooks before stop |
| `.github/skills/pr-base-branch-merge-base/SKILL.md` | Base-branch resolution contract | Mirror as project skill | `.claude/skills/pr-base-branch-merge-base/SKILL.md` | Preload into review and PR-authoring workers | Review stop-gates should reject undocumented default-branch fallbacks |
| `.github/skills/pr-context-artifacts/SKILL.md` | PR-context artifact locations and refresh rules | Mirror as project skill | `.claude/skills/pr-context-artifacts/SKILL.md` | Preload into review and PR-authoring workers | Hooks can require canonical PR-context file references before allowing review completion |
| `.github/skills/remediation-handoff-atomic-planner/SKILL.md` | Remediation trigger and plan handoff rules | Mirror as project skill | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | Preload into review/status workers; main thread handles actual planner invocation | Prevent nested delegation by keeping planning chain in main-thread workflow skills |
| `.github/skills/skill-canonical-location-audit/SKILL.md` | Audit duplicate canonical locations | Mirror as optional manual project skill | `.claude/skills/skill-canonical-location-audit/SKILL.md` | Manual-only skill used during maintenance | Use this during sync reviews, not as a default loaded skill |

#### `.github/agents` → Claude mapping (file-by-file)

Legend used below:

- **Project subagent**: commit under `.claude/agents/<name>.md`.
- **Wrapper skill**: create a manual skill under `.claude/skills/<name>/SKILL.md`; optional subagent only if isolation adds value.
- **Main-thread only**: do not use as a nested Claude subagent; either make it the default session agent or inline its logic into a main-thread skill.
- **Personal/library only**: do not commit as a project Claude subagent; if retained, keep under `~/.claude/agents/` or archive.

| `.github` source file | Current Copilot role | Claude-native treatment | Claude target file(s) | Handoff management in Claude | Enforcement / anti-drift notes |
|---|---|---|---|---|---|
| `.github/agents/orchestrator.agent.md` | Global workflow coordinator with nested handoffs | **Main-thread only**; this cannot be a forked worker if it must spawn planner/executor/reviewer agents | `.claude/agents/orchestrator.md` plus `.claude/skills/orchestrate/SKILL.md`; set `.claude/settings.json` `agent: "orchestrator"` | Main thread launches `Agent(atomic-planner, atomic-executor, feature-review, task-researcher, ...)` sequentially; `/orchestrate` stays inline/manual | Project settings can make orchestrator the default session agent, but only managed settings can make that non-overridable |
| `.github/agents/python-orchestrator.agent.md` | Python-specific nested orchestrator | **Do not commit as nested subagent**; extract unique Python routing logic into skills or optionally keep as an explicit main-thread agent for Python-only sessions | Preferred: `.claude/skills/python-orchestrator-routing/SKILL.md` or fold into orchestrator skillset; optional `.claude/agents/python-orchestrator.md` only for explicit `--agent` use | Main thread uses the Python budget/router skills, then directly spawns Python planner/executor/engineer workers | Do not let the project orchestrator delegate to a `python-orchestrator` subagent expecting further fan-out |
| `.github/agents/powershell-orchestrator.agent.md` | PowerShell-specific nested orchestrator | Same as Python orchestration: routing skill or optional main-thread-only agent, not nested worker | Preferred: `.claude/skills/powershell-orchestrator-routing/SKILL.md`; optional `.claude/agents/powershell-orchestrator.md` for explicit sessions | Main thread uses PowerShell routing skills and directly spawns PowerShell planner/executor/engineer workers | Prevent accidental nesting by denying `Agent(powershell-orchestrator)` in main orchestrator config unless explicitly using that session mode |
| `.github/agents/csharp-orchestrator.agent.md` | C#-specific nested orchestrator | Same as Python/PowerShell orchestration: routing skill or optional main-thread-only agent, not nested worker | Preferred: `.claude/skills/csharp-orchestrator-routing/SKILL.md`; optional `.claude/agents/csharp-orchestrator.md` for explicit sessions | Main thread uses C# routing skills and directly spawns C# planner/executor/engineer workers | Same nested-delegation restriction applies |
| `.github/agents/atomic_planning.agent.md` | Generic planner | Project subagent | `.claude/agents/atomic-planner.md` | Main thread invokes directly; subagent may preload `atomic-plan-contract` but should not spawn more subagents | `SubagentStop` should require `PREFLIGHT: ALL CLEAR` or plan path output when applicable |
| `.github/agents/atomic_executor.agent.md` | Generic executor | Project subagent | `.claude/agents/atomic-executor.md` | Main thread invokes directly for validation/execution | `SubagentStop` should require updated plan state, QA summary, and AC summary |
| `.github/agents/python-atomic-planning.agent.md` | Python planning chain wrapper | Project subagent if Python planning specialization is retained; otherwise fold into generic planner plus skills | `.claude/agents/python-atomic-planner.md` or omit in favor of generic planner + preloaded Python skills | Main thread invokes directly; no nested planner fan-out from inside it | Keep naming normalized to lowercase hyphens |
| `.github/agents/python-atomic-executor.agent.md` | Python executor specialization | Project subagent | `.claude/agents/python-atomic-executor.md` | Main thread invokes directly for Python execution | `SubagentStop` should require Black/Ruff/Pyright/Pytest evidence fields |
| `.github/agents/powershell-atomic-planning.agent.md` | PowerShell planning chain wrapper | Project subagent if PowerShell specialization is retained; otherwise fold into generic planner + PowerShell skills | `.claude/agents/powershell-atomic-planner.md` or omit in favor of generic planner + preloaded PowerShell skills | Main thread invokes directly | Use hyphenated file/name normalization |
| `.github/agents/powershell-atomic-executor.agent.md` | PowerShell executor specialization | Project subagent | `.claude/agents/powershell-atomic-executor.md` | Main thread invokes directly | `SubagentStop` should require format/analyze/test evidence |
| `.github/agents/csharp-atomic-planning.agent.md` | C# planning chain wrapper | Project subagent if retained; otherwise fold into generic planner + C# skills | `.claude/agents/csharp-atomic-planner.md` or omit in favor of generic planner + preloaded C# skills | Main thread invokes directly | Same naming normalization applies |
| `.github/agents/csharp-atomic-executor.agent.md` | C# executor specialization | Project subagent | `.claude/agents/csharp-atomic-executor.md` | Main thread invokes directly | `SubagentStop` should require C# formatter/build/test evidence |
| `.github/agents/python-typed-engineer.agent.md` | Python implementation worker | Project subagent | `.claude/agents/python-typed-engineer.md` | Main thread invokes directly from orchestrator flow | Restrict tools to Python-relevant mutation commands and repo file scopes |
| `.github/agents/python-execution-only-typed.agent.md` | Python implementation duplicate/specialized variant | Merge into `python-typed-engineer` rather than carrying two near-identical project agents | No separate project file; document as merged into `.claude/agents/python-typed-engineer.md` | N/A | Keep one authoritative Python implementation worker to reduce routing ambiguity |
| `.github/agents/powershell-typed-engineer.agent.md` | PowerShell implementation worker | Project subagent | `.claude/agents/powershell-typed-engineer.md` | Main thread invokes directly | Restrict tools and paths to PowerShell scopes |
| `.github/agents/csharp-typed-engineer.agent.md` | C# implementation worker | Project subagent | `.claude/agents/csharp-typed-engineer.md` | Main thread invokes directly | Restrict tools and paths to C# scopes |
| `.github/agents/typescript-engineer.agent.md` | TypeScript implementation worker | Project subagent | `.claude/agents/typescript-engineer.md` | Main thread invokes directly or via manual skill | Restrict tools to TS/Jest workflows and relevant repo paths |
| `.github/agents/feature-review.agent.md` | Feature review worker | Project subagent + wrapper skill | `.claude/agents/feature-review.md`, optional `.claude/skills/review-feature/SKILL.md` | Main thread invokes review worker; if remediation is required, main thread calls planner next | `SubagentStop` should require policy/code/feature audit artifact paths |
| `.github/agents/task-researcher.agent.md` | Research-only worker | Project subagent + wrapper skill | `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md` | `/research-issue` may fork `task-researcher`; main thread handles any downstream actions after research returns | Constrain write access to `artifacts/research/**` and deny other edits |
| `.github/agents/pr-author.agent.md` | PR body authoring worker | Prefer wrapper skill; optional focused subagent if isolation is desired | `.claude/skills/pr-author/SKILL.md`, optional `.claude/agents/pr-author.md` | Manual skill; if subagent exists, `/pr-author` may fork it because no nested fan-out is required | `disable-model-invocation: true` recommended to keep PR writing user-triggered |
| `.github/agents/commit-steward.agent.md` | Commit message authoring worker | Prefer wrapper skill; optional focused subagent if isolation is desired | `.claude/skills/commit-message/SKILL.md`, optional `.claude/agents/commit-steward.md` | Manual skill; no nested handoffs required | Keep this user-invocable only; do not let Claude auto-run commit authoring |
| `.github/agents/prd-feature.agent.md` | Feature-doc filling worker with optional research handoff | Project subagent + wrapper skill, but remove nested research handoff from worker itself | `.claude/agents/prd-feature.md`, `.claude/skills/fill-feature-docs/SKILL.md` | Main thread or orchestrator runs research first, then invokes `prd-feature` worker | Preserve template fidelity via stop-gates that require output paths only |
| `.github/agents/prd.agent.md` | General PRD generator that asks clarifying questions | Not repository-deterministic; keep as optional manual skill or personal agent, not project default | Optional `.claude/skills/prd-creator/SKILL.md` or `~/.claude/agents/prd-creator.md` | Manual only | This conflicts with the repo’s no-questions deterministic automation style; do not preload into project orchestration |
| `.github/agents/staged-review.agent.md` | Staged-diff reviewer | Project subagent + wrapper skill | `.claude/agents/staged-review.md`, `.claude/skills/review-staged/SKILL.md` | Main thread invokes worker, then planner if remediation is required | `SubagentStop` should require staged review artifact paths |
| `.github/agents/epic-review.agent.md` | Epic-root reviewer | Project subagent + wrapper skill | `.claude/agents/epic-review.md`, `.claude/skills/review-epic/SKILL.md` | Main thread invokes worker, then planner if remediation is required | `SubagentStop` should require epic-audit, feature-delivery-inventory, and policy-audit paths |
| `.github/agents/status_updater.agent.md` | Status synchronization worker | Project subagent + wrapper skill | `.claude/agents/status-updater.md`, `.claude/skills/update-status/SKILL.md` | Main thread invokes worker; if blockers remain, main thread can invoke planner | Restrict edits to docs/features and plan/checklist files |
| `.github/agents/commentary-remediation.agent.md` | Python comment/docstring remediation worker | Optional project subagent or maintenance-only skill | Optional `.claude/agents/comment-remediator.md` and/or `.claude/skills/remediate-comments/SKILL.md` | Manual only | Keep out of default routing to avoid accidental bulk comment rewrites |
| `.github/agents/pytest-unit-test-coding.agent.md` | Python test-focused worker | Optional project subagent or merge into Python engineer workflow | Optional `.claude/agents/pytest-unit-test-coding.md` | Main thread invokes directly only when a test-specialist worker is explicitly desired | Could also be replaced by `python-typed-engineer` plus a testing skill |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | PowerShell test-focused worker | Optional project subagent or merge into PowerShell engineer workflow | Optional `.claude/agents/powershell-di-unit-test-engineer.md` | Main thread invokes directly only when explicit test-specialist behavior is desired | Normalize filename and `name` field to lowercase hyphens |
| `.github/agents/tdd-red.agent.md` | TDD red-phase worker | Optional personal/library agent or optional project subagent only if TDD workflow becomes canonical | Optional `~/.claude/agents/tdd-red.md` or project equivalent | Main thread invokes directly; no nested handoffs | Not currently part of required repository orchestration |
| `.github/agents/tdd-green.agent.md` | TDD green-phase worker | Same as `tdd-red` | Optional `~/.claude/agents/tdd-green.md` or project equivalent | Main thread invokes directly | Not currently part of required repository orchestration |
| `.github/agents/tdd-refactor.agent.md` | TDD refactor-phase worker | Same as `tdd-red` | Optional `~/.claude/agents/tdd-refactor.md` or project equivalent | Main thread invokes directly | Not currently part of required repository orchestration |
| `.github/agents/mentor.agent.md` | Generic mentoring persona | Personal/library only; do not commit as project subagent | `~/.claude/agents/mentor.md` if retained | User-invoked only | Project-scoped auto-delegation would make routing less deterministic |
| `.github/agents/api-architect.agent.md` | Generic architecture persona | Personal/library only | `~/.claude/agents/api-architect.md` if retained | User-invoked only | Not repository-canonical |
| `.github/agents/expert-nextjs-developer.agent.md` | Generic Next.js persona | Personal/library only unless the repo later adds a dedicated Next.js runtime | `~/.claude/agents/expert-nextjs-developer.md` if retained | User-invoked only | Not repository-canonical today |
| `.github/agents/expert-react-frontend-engineer.agent.md` | Generic React persona | Personal/library only unless the repo later adds a dedicated React runtime | `~/.claude/agents/expert-react-frontend-engineer.md` if retained | User-invoked only | Not repository-canonical today |
| `.github/agents/hlbpa.agent.md` | Generic high-level architecture reviewer | Personal/library only | `~/.claude/agents/hlbpa.md` if retained | User-invoked only | Not repository-canonical |
| `.github/agents/5.1-Beast-adjusted.agent.md` | Generic broad “beast mode” persona | Personal/library only or retire | `~/.claude/agents/5-1-beast-adjusted.md` if retained | User-invoked only | Keeping this project-scoped would undermine deterministic routing |
| `.github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md` | Generic broad “thinking beast” persona | Personal/library only or retire | `~/.claude/agents/5-1-thinking-beast-mode-adjusted.md` if retained | User-invoked only | Same reason as above |
| `.github/agents/gpt-5-beast-mode.agent.md` | Generic broad GPT persona | Personal/library only or retire | `~/.claude/agents/gpt-5-beast-mode.md` if retained | User-invoked only | Same reason as above |
| `.github/agents/voidbeast-gpt41enhanced.agent.md` | Generic advanced autonomous persona | Personal/library only or retire | `~/.claude/agents/voidbeast-gpt41enhanced.md` if retained | User-invoked only | Same reason as above |

#### How handoffs should be managed in the Claude ecosystem

1. **Main-thread orchestration for all fan-out**
   - Any workflow that needs to call multiple downstream workers must run in the main thread.
   - This is why `orchestrator` should be the default session agent, not a forked worker.

2. **Direct-use workflows become manual skills**
   - `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, `/review-feature`, `/review-staged`, `/review-epic`, and `/update-status` should all be project skills.
   - For bounded single-worker tasks, a skill may use `context: fork` and `agent: <worker>`. Example: `/research-issue` can fork `task-researcher` safely because `task-researcher` does not need to spawn more workers.

3. **Nested Copilot `handoffs:` become explicit main-thread sequences**
   - Example: `feature-review.agent.md` currently delegates remediation plan creation. In Claude, the main thread should:
     1. invoke `feature-review`,
     2. inspect its output or required artifact presence,
     3. invoke `atomic-planner` if remediation is needed,
     4. verify the remediation plan path exists.

4. **Shared skills replace duplicated prompt sections**
   - Instead of copying `feature-review-workflow`, `policy-compliance-order`, `atomic-plan-contract`, and similar content into every worker, preload those skills via subagent frontmatter `skills:`.

5. **Use `Agent(<allowed-subagent>)` restrictions for deterministic fan-out**
   - The main-thread orchestrator should allow only the known repository workers.
   - Workers that should never be reachable from project automation should not be in project scope at all; if they must exist, add `permissions.deny` entries for them.

#### How the ecosystem enforces the architecture and prevents deviations

**Repository-enforceable controls (project scope):**

1. `CLAUDE.md` + `.claude/rules/**/*.md`
   - Always-on guidance for policy order, architecture boundaries, and sync expectations.
   - This is advisory context, not hard enforcement.

2. `.claude/settings.json` `permissions`
   - Deny-first tool, skill, and agent rules.
   - Examples:
     - deny generic/personal agents from project automation,
     - deny edits to `.github/instructions/**`, `.claude/settings.json`, `.claude/rules/**`, and `CLAUDE.md` except in dedicated migration workflows,
     - deny dangerous Bash patterns such as `git push --force*`, `rm -rf *`, or broad network tools unless explicitly allowed.

3. `.claude/hooks/*`
   - `PreToolUse`: validate Bash/PowerShell commands and block unauthorized edits or path escapes.
   - `SubagentStop`: require artifact paths, plan paths, AC summaries, or review files before a worker can stop.
   - `ConfigChange`: audit or block unauthorized edits to Claude configuration files during a session.
   - `InstructionsLoaded`: optional observability for which standing-instruction files actually loaded.

4. Scope isolation
   - Only commit repository-canonical workers under `.claude/agents/`.
   - Keep personal or experimental personas in `~/.claude/agents/` or retire them.
   - This prevents Claude from auto-considering irrelevant agents for repository work.

**What requires managed settings for hard enforcement beyond the repository:**

- Forcing the default session agent so CLI `--agent` cannot override it.
- Preventing all user/local permission-rule changes through `allowManagedPermissionRulesOnly`.
- Restricting hook origins to managed hooks only through `allowManagedHooksOnly`.
- Locking marketplace/plugin sources and MCP server availability.

In other words, project settings give a strong deterministic baseline, but only managed settings can make every part of that baseline non-optional for all users and launch modes.

### Complete Examples

```markdown
<!-- Recommended Claude-native orchestration shape: main-thread orchestrator, manual wrapper skill, bounded worker subagents -->

# .claude/skills/orchestrate/SKILL.md
---
name: orchestrate
description: Run the repository orchestration workflow for a feature or bug objective. Use when starting or resuming promotion, research, planning, execution, or review in this repository.
disable-model-invocation: true
argument-hint: [objective]
allowed-tools:
  - Agent(atomic-planner)
  - Agent(atomic-executor)
  - Agent(feature-review)
  - Agent(task-researcher)
  - Agent(python-typed-engineer)
  - Agent(powershell-typed-engineer)
  - Agent(csharp-typed-engineer)
  - Agent(typescript-engineer)
  - Read
  - Grep
  - Glob
  - Bash(git *)
---

Treat the current main session as the repository orchestrator.

Objective:
$ARGUMENTS

Required behavior:
- Read and honor `CLAUDE.md` and all matching `.claude/rules/` files.
- Read `artifacts/orchestration/orchestrator-state.json` before new work.
- Delegate specialist work only through the allowed repository subagents.
- Keep all nested delegation in the main thread; do not fork a subagent that must itself spawn other subagents.
- Do not report completion until the required artifacts exist and stop-gates pass.


# .claude/agents/orchestrator.md
---
name: orchestrator
description: Deterministic repository orchestrator. Use proactively for end-to-end feature and bug workflows.
tools:
  - Agent(atomic-planner)
  - Agent(atomic-executor)
  - Agent(feature-review)
  - Agent(task-researcher)
  - Agent(prd-feature)
  - Agent(python-typed-engineer)
  - Agent(powershell-typed-engineer)
  - Agent(csharp-typed-engineer)
  - Agent(typescript-engineer)
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - Bash(git *)
  - Bash(pwsh *)
  - mcp__drmCopilotExtension__*
model: sonnet
skills:
  - policy-compliance-order
  - feature-promotion-lifecycle
  - atomic-plan-contract
  - acceptance-criteria-tracking
  - pr-context-artifacts
  - pr-base-branch-merge-base
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Evaluate whether the orchestrator may stop.
            Block stopping unless the response references the current checkpoint path,
            the selected workflow path, and the required artifact paths for the selected route.
memory: project
---

You are the repository orchestrator.

Keep orchestration state in `artifacts/orchestration/orchestrator-state.json`.
Delegate worker tasks from the main thread only.
If a worker returns remediation-required output, launch the next required worker yourself rather than expecting nested worker fan-out.
```

### API and Schema Documentation

#### Native Claude file naming and placement rules

- Standing instructions:
  - `CLAUDE.md`
  - `.claude/rules/<topic>.md`
- Reusable skills:
  - `.claude/skills/<skill-name>/SKILL.md`
  - optional support files under the same skill directory (`reference.md`, `examples.md`, `scripts/*`)
- Project subagents:
  - `.claude/agents/<agent-name>.md`
  - `name` must use lowercase letters and hyphens only
- Enforcement:
  - `.claude/settings.json`
  - `.claude/hooks/<purpose>.ps1`

#### Handoff conversion rules

| Copilot construct | Claude-native equivalent | Notes |
|---|---|---|
| `handoffs:` inside an orchestrator that must fan out further | Main-thread `Agent(...)` calls from the default session agent or inline manual skill | Required because Claude subagents cannot spawn subagents |
| Direct-use `.github/prompts/*.prompt.md` | Manual project skills under `.claude/skills/*/SKILL.md` | Prefer skills over `.claude/commands/` |
| Shared `.github/skills/*/SKILL.md` guidance | Same-name Claude project skill, usually preloaded into worker agents | Do not flatten into agent bodies |
| Policy instructions in `.github/instructions/*.instructions.md` | `CLAUDE.md` + path-scoped `.claude/rules/**/*.md` | Advisory context only |
| Runtime enforcement via Copilot tool contracts | `permissions` + `hooks` in `.claude/settings.json` | Deny-first, then hook validation, then worker stop-gates |

#### `.github/prompts` family treatment

The prompt inventory should be mapped as follows so the skill/agent migration is complete in practice:

- `.github/prompts/orchestrate-work.prompt.md` → `.claude/skills/orchestrate/SKILL.md`
- `.github/prompts/orchestrate-python-work.prompt.md` → `.claude/skills/orchestrate-python/SKILL.md` or fold into orchestrator routing skillset
- `.github/prompts/orchestrate-powershell-work.prompt.md` → `.claude/skills/orchestrate-powershell/SKILL.md` or fold into orchestrator routing skillset
- `.github/prompts/orchestrate-csharp-work.prompt.md` → `.claude/skills/orchestrate-csharp/SKILL.md` or fold into orchestrator routing skillset
- `.github/prompts/generate-pr.prompt.md` → `.claude/skills/pr-author/SKILL.md`
- `.github/prompts/generate-commit-message-repo.prompt.md` → `.claude/skills/commit-message/SKILL.md`
- `.github/prompts/generate-atomic-plan.prompt.md` → support/reference file inside the planner skill directory, not a separate command surface
- `.github/prompts/research-issue.prompt.md` → `.claude/skills/research-issue/SKILL.md`
- `.github/prompts/review-feature.prompt.md` → `.claude/skills/review-feature/SKILL.md`
- `.github/prompts/review-staged.prompt.md` → `.claude/skills/review-staged/SKILL.md`
- `.github/prompts/review-epic.prompt.md` → `.claude/skills/review-epic/SKILL.md`
- `.github/prompts/update_status.prompt.md` → `.claude/skills/update-status/SKILL.md`
- `.github/prompts/fillout-prd-feature.prompt.md` → `.claude/skills/fill-feature-docs/SKILL.md`
- Remaining `breakdown-*`, `export-chat`, `code-exemplars-*`, `javascript-typescript-jest`, `add-educational-comments`, and `remediate-comments` prompts → optional manual skills; keep only if still actively used.

### Configuration Examples

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "agent": "orchestrator",
  "permissions": {
    "allow": [
      "Agent(atomic-planner)",
      "Agent(atomic-executor)",
      "Agent(feature-review)",
      "Agent(task-researcher)",
      "Agent(prd-feature)",
      "Agent(python-typed-engineer)",
      "Agent(powershell-typed-engineer)",
      "Agent(csharp-typed-engineer)",
      "Agent(typescript-engineer)",
      "Skill(orchestrate)",
      "Skill(commit-message)",
      "Skill(pr-author)",
      "Skill(research-issue)",
      "Read",
      "Grep",
      "Glob",
      "Bash(git *)"
    ],
    "deny": [
      "Agent(5.1-Beast-adjusted)",
      "Agent(5.1-Thinking-Beast-Mode-adjusted)",
      "Agent(gpt-5-beast-mode)",
      "Agent(voidbeast-gpt41enhanced)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Edit(/.github/instructions/**)",
      "Edit(/CLAUDE.md)",
      "Edit(/.claude/settings.json)",
      "Edit(/.claude/rules/**)",
      "Bash(git push --force*)",
      "Bash(rm -rf *)"
    ],
    "defaultMode": "acceptEdits"
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-bash.ps1"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "atomic-executor|feature-review|task-researcher",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Block stop unless the agent output contains the required artifact path(s) and completion evidence for $ARGUMENTS."
          }
        ]
      }
    ],
    "ConfigChange": [
      {
        "matcher": "project_settings|skills",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/audit-config-change.ps1"
          }
        ]
      }
    ]
  }
}
```

### Technical Requirements

1. **Correct the orchestration model before implementation begins**
   - Remove the assumption that `/orchestrate` should use `context: fork` with an `orchestrator` worker that then delegates to other subagents.
   - Replace it with a main-thread orchestrator model.

2. **Keep `.github` as canonical authored content**
   - `.github/skills/*/SKILL.md` remains the authored source of reusable workflow contracts.
   - `.github/agents/*.agent.md` remains the authored source for persona/workflow intent, but not every file becomes a committed Claude project subagent.

3. **Create the standing-instructions layer**
   - Create `CLAUDE.md` at the repo root.
   - Mirror the applicable `.github/instructions/*.instructions.md` files into `.claude/rules/*.md` with path scoping where appropriate.
   - Import or summarize `AGENTS.md` where that reduces duplication, but keep Claude-specific corrections explicit.

4. **Mirror repository skills to `.claude/skills/`**
   - Create one same-name skill directory per canonical `.github/skills/*/SKILL.md` file, except `.github/skills/README.md` which remains documentation only.
   - Add Claude frontmatter such as `disable-model-invocation`, `user-invocable`, `paths`, `allowed-tools`, and `hooks` only where needed.

5. **Convert prompt entry points into project skills**
   - Each current workflow prompt under `.github/prompts/*.prompt.md` should become a project skill.
   - Treat `.claude/commands/` as legacy compatibility only; do not target it for new migration work.

6. **Create only the repository-canonical project subagents**
   - Commit the bounded workers listed above under `.claude/agents/`.
   - Normalize names to lowercase hyphenated identifiers.
   - Drop or relocate generic/personal personas to `~/.claude/agents/` or archive them.

7. **Move nested handoff logic back to the main thread**
   - For any current Copilot agent that has `handoffs:` and would be invoked as a Claude subagent, remove nested delegation from the worker itself.
   - Put sequencing logic into the main-thread orchestrator skill/agent workflow instead.

8. **Implement settings and hook enforcement**
   - Add `.claude/settings.json` with deny-first rules for agents, skills, file paths, and risky commands.
   - Add `.claude/hooks/validate-bash.ps1` for `PreToolUse` command validation.
   - Add a `SubagentStop` strategy that checks for required artifact paths and completion summaries.
   - Add `ConfigChange` auditing or blocking for unauthorized configuration changes.

9. **Document sync and non-equivalence explicitly**
   - `docs/engineering/claude-code-architecture.md` must explain:
     - which `.github` files map to which `.claude` files,
     - which Copilot constructs are equivalent in Claude,
     - which are not equivalent, especially nested `handoffs:`,
     - how to update mirrors without drift.

10. **Validate the migrated runtime intentionally**
    - Verify that manual skills appear by name and route correctly.
    - Verify that a worker blocked by permissions or hooks fails because of the enforcement layer, not just prompt text.
    - Verify that the main-thread orchestrator can spawn each allowed worker and cannot spawn disallowed ones.

**Mandatory unachievable objective callout**:
- **A forked Claude subagent cannot be the repository orchestrator if it must delegate to other subagents. Claude’s current runtime explicitly prohibits subagents from spawning subagents, so the draft design that makes `/orchestrate` fork an `orchestrator` worker and then expects nested planner/executor/reviewer delegation is not achievable as written.**
- **A command-only migration targeting only `CLAUDE.md` and `.claude/commands/` is not a correct Claude-native architecture. Claude skills, project subagents, settings, and hooks are first-class primitives and are required for this repository’s reusable workflows, worker isolation, and deterministic enforcement.**
- **Repository-scoped files alone cannot fully prevent every user override. Project settings can enforce deny rules and hooks strongly, but absolute prevention of command-line or local configuration overrides requires managed settings outside the repository.**

## Recommended Approach

Adopt a **main-thread orchestrator + project skills + bounded worker subagents + deny-first settings/hooks** model.

The concrete recommendation is:

1. Set `.claude/settings.json` `agent` to `orchestrator` so the session itself can fan out to downstream workers.
2. Keep user entry points as manual project skills:
   - `/orchestrate`
   - `/commit-message`
   - `/pr-author`
   - `/research-issue`
   - optional `/review-feature`, `/review-staged`, `/review-epic`, `/update-status`
3. Commit only repository-canonical workers under `.claude/agents/`:
   - `atomic-planner`
   - `atomic-executor`
   - `feature-review`
   - `task-researcher`
   - `prd-feature`
   - `python-typed-engineer`
   - `powershell-typed-engineer`
   - `csharp-typed-engineer`
   - `typescript-engineer`
   - optional specialized planners/executors/reviewers if they add real value beyond preloaded skills
4. Mirror canonical `.github/skills/*/SKILL.md` into `.claude/skills/*/SKILL.md` and preload them into the relevant workers.
5. Keep generic beast/mentor/framework personas out of project scope so Claude’s routing remains deterministic.
6. Enforce the architecture with project `permissions.deny`, `PreToolUse`, `SubagentStop`, and `ConfigChange` hooks.

Brief rejected alternatives:

- **Forked orchestrator subagent**: rejected because a Claude subagent cannot spawn further subagents.
- **Command-only port**: rejected because it discards Claude-native skills, subagents, and enforcement.
- **Project-committed generic personas**: rejected because they are not repository-canonical and would weaken deterministic routing.

## Implementation Guidance

- **Objectives**: correct the orchestration model to main-thread delegation; mirror canonical `.github/skills` into Claude skills; map each `.github/agents` file to either a project subagent, wrapper skill, or personal/library-only disposition; express prompt entry points as Claude skills; enforce policy and artifact contracts through settings and hooks; document sync and non-equivalence explicitly.
- **Key Tasks**: rewrite the architecture spec to remove forked-orchestrator guidance; create the `.claude/rules`, `.claude/skills`, `.claude/agents`, `.claude/settings.json`, and `.claude/hooks/*` layers according to the mapping tables; convert `.github/prompts` into project skills; keep non-canonical personas out of project scope; add validation guidance and sync documentation.
- **Dependencies**: current `.github` canonical files; official Claude docs for skills, subagents, settings, permissions, hooks, memory, and commands; existing repository artifact conventions under `artifacts/` and `docs/features/`; optional managed-settings support if stronger-than-project enforcement is required later.
- **Success Criteria**: the migrated design no longer assumes nested worker fan-out from Claude subagents; every `.github/skills` file has an explicit Claude treatment; every `.github/agents` file has an explicit Claude disposition and target filename; direct-use workflow prompts are mapped to skills; deterministic handoffs are described as main-thread `Agent(...)` sequences; enforcement strategy clearly distinguishes advisory instructions from deny-first rules and hooks; the sync strategy documents `.github` as canonical and `.claude` as runtime mirror.