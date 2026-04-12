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

The provided migration research in `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md` is sufficient to complete this spec. It adds the missing file-by-file mapping, clarifies the correct orchestration runtime model, and identifies the enforcement boundaries that are repository-enforceable versus managed-settings-only.


## Behavior

Add a first-class Claude Code architecture to the repository that maps the current Copilot orchestration model onto the four Claude-native layers, preserving existing workflow boundaries and specialist responsibilities with minimal duplication.

At a high level, the implementation should:

1. **Standing instructions layer**: Add a repo-root `CLAUDE.md` that carries forward tone policy, policy-compliance order, and top-level architectural context. Add `.claude/rules/*.md` files — optionally path-scoped — to carry the language-specific and directory-specific rules that currently live in `.github/instructions/*.instructions.md` files.

2. **Skills layer**: Implement direct-use workflows as project skills under `.claude/skills/<name>/SKILL.md`. Skills are the primary user-invocable entry point surface in Claude Code. The initial set must include at minimum: `orchestrate`, `commit-message`, `pr-author`, and `research-issue`. These replace `.claude/commands/` as the target surface for new work. The `orchestrate` skill must frame work for the already-active main-thread orchestrator rather than forking an `orchestrator` worker that would need to spawn downstream subagents.

3. **Subagents layer**: Register bounded specialist personas as project subagents under `.claude/agents/`. Each subagent file must carry frontmatter that declares its specific `tools` allowlist, `model`, `skills` to preload, `hooks` for stop-gate enforcement, and `memory: project`. The initial repository-canonical set must include at minimum: `atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, and the repository's language engineer agents. The `orchestrator` remains important, but it must run as the main session agent instead of as a nested worker subagent.

4. **Enforcement layer**: Define `.claude/settings.json` with an explicit `permissions` block that allowlists required `Bash(...)`, `Read`, `Edit(...)`, `Write(...)`, MCP, `Skill(...)`, and `Agent(...)` patterns, and includes `deny` rules for sensitive paths. Add `.claude/hooks/` entries for `SubagentStop` and `PreToolUse` to enforce completion signals and bash command validation without relying on prose instructions alone.

5. **Resumability**: Preserve the existing checkpoint-file pattern at `artifacts/orchestration/orchestrator-state.json`. The main-thread Claude orchestrator must read this file before performing new work and write an updated checkpoint after each phase transition.

6. **Sync strategy**: Document and implement a strategy for keeping `.claude/agents/` content aligned with the canonical `.github/agents/*.agent.md` sources, and `.claude/skills/` aligned with `.github/skills/*/SKILL.md` sources, to prevent divergence over time.

7. **Architecture documentation**: Explicitly document supported equivalences, non-equivalences (particularly the absence of Copilot's declarative `handoffs:` metadata and the inability of Claude subagents to spawn subagents), and the Claude-native substitutes used in each case.

More specifically, the runtime behavior must follow this deterministic pattern:

1. The repository opens in Claude Code with `.claude/settings.json` setting `agent: "orchestrator"`, so the main session itself has access to `Agent(...)` delegation.
2. User entry points such as `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, `/review-feature`, `/review-staged`, `/review-epic`, and `/update-status` are implemented as Claude skills rather than `.claude/commands/*` files.
3. The main-thread orchestrator launches bounded workers directly (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, and language engineers) instead of relying on nested worker-to-worker fan-out.
4. Canonical reusable guidance remains authored under `.github/skills/*/SKILL.md` and is mirrored into `.claude/skills/*/SKILL.md` so it can be preloaded into workers through `skills:` frontmatter rather than duplicated into agent bodies.
5. Only repository-canonical, bounded workers are committed under `.claude/agents/`. Generic beast, mentor, and framework-persona agents are kept out of project scope so Claude's routing remains deterministic.
6. The permissions and hooks layer enforces the architecture through deny-first rules, bash validation, worker stop-gates, and config-change auditing.

### Canonical `.github/skills` migration map

| `.github` source | Claude-native role | Target |
|---|---|---|
| `.github/skills/README.md` | Documentation-only taxonomy; not a runtime asset | Reference from `docs/engineering/claude-code-architecture.md` only |
| `.github/skills/acceptance-criteria-tracking/SKILL.md` | Reusable project skill, preloaded into executors/reviewers/status-sync workers | `.claude/skills/acceptance-criteria-tracking/SKILL.md` |
| `.github/skills/atomic-plan-contract/SKILL.md` | Reusable planner/executor/orchestrator contract | `.claude/skills/atomic-plan-contract/SKILL.md` |
| `.github/skills/csharp-change-budget-router/SKILL.md` | Reusable C# orchestration routing skill | `.claude/skills/csharp-change-budget-router/SKILL.md` |
| `.github/skills/csharp-orchestration-state-machine/SKILL.md` | Reusable C# checkpoint-state skill | `.claude/skills/csharp-orchestration-state-machine/SKILL.md` |
| `.github/skills/evidence-and-timestamp-conventions/SKILL.md` | Reusable evidence-location skill | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` |
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | Reusable promotion workflow skill | `.claude/skills/feature-promotion-lifecycle/SKILL.md` |
| `.github/skills/feature-review-workflow/SKILL.md` | Reusable feature-review workflow skill | `.claude/skills/feature-review-workflow/SKILL.md` |
| `.github/skills/make-skill-template/SKILL.md` | Optional manual maintenance skill only | `.claude/skills/make-skill-template/SKILL.md` |
| `.github/skills/policy-audit-template-usage/SKILL.md` | Reusable policy-audit artifact skill | `.claude/skills/policy-audit-template-usage/SKILL.md` |
| `.github/skills/policy-compliance-order/SKILL.md` | Reusable baseline policy-order skill, also summarized in standing instructions | `.claude/skills/policy-compliance-order/SKILL.md` plus `CLAUDE.md` / `.claude/rules/*` summaries |
| `.github/skills/powershell-change-budget-router/SKILL.md` | Reusable PowerShell orchestration routing skill | `.claude/skills/powershell-change-budget-router/SKILL.md` |
| `.github/skills/powershell-orchestration-state-machine/SKILL.md` | Reusable PowerShell checkpoint-state skill | `.claude/skills/powershell-orchestration-state-machine/SKILL.md` |
| `.github/skills/pr-base-branch-merge-base/SKILL.md` | Reusable PR base-branch resolution skill | `.claude/skills/pr-base-branch-merge-base/SKILL.md` |
| `.github/skills/pr-context-artifacts/SKILL.md` | Reusable PR-context artifact skill | `.claude/skills/pr-context-artifacts/SKILL.md` |
| `.github/skills/remediation-handoff-atomic-planner/SKILL.md` | Reusable remediation-routing skill; main thread executes the actual planner call | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` |
| `.github/skills/skill-canonical-location-audit/SKILL.md` | Optional manual maintenance skill only | `.claude/skills/skill-canonical-location-audit/SKILL.md` |

### Canonical `.github/agents` migration map

| `.github` source | Claude-native treatment | Target / disposition |
|---|---|---|
| `.github/agents/orchestrator.agent.md` | Main-thread-only repository orchestrator, not a nested worker | `.claude/agents/orchestrator.md` plus `.claude/skills/orchestrate/SKILL.md`; set `.claude/settings.json` `agent: "orchestrator"` |
| `.github/agents/python-orchestrator.agent.md` | Fold unique routing logic into skills or keep only as an explicitly selected main-thread mode | `.claude/skills/python-orchestrator-routing/SKILL.md` or optional `.claude/agents/python-orchestrator.md` |
| `.github/agents/powershell-orchestrator.agent.md` | Fold unique routing logic into skills or keep only as an explicitly selected main-thread mode | `.claude/skills/powershell-orchestrator-routing/SKILL.md` or optional `.claude/agents/powershell-orchestrator.md` |
| `.github/agents/csharp-orchestrator.agent.md` | Fold unique routing logic into skills or keep only as an explicitly selected main-thread mode | `.claude/skills/csharp-orchestrator-routing/SKILL.md` or optional `.claude/agents/csharp-orchestrator.md` |
| `.github/agents/atomic_planning.agent.md` | Project worker subagent | `.claude/agents/atomic-planner.md` |
| `.github/agents/atomic_executor.agent.md` | Project worker subagent | `.claude/agents/atomic-executor.md` |
| `.github/agents/python-atomic-planning.agent.md` | Optional Python-specialized planner worker or merge into generic planner + skills | Optional `.claude/agents/python-atomic-planner.md` |
| `.github/agents/python-atomic-executor.agent.md` | Project worker subagent | `.claude/agents/python-atomic-executor.md` |
| `.github/agents/powershell-atomic-planning.agent.md` | Optional PowerShell-specialized planner worker or merge into generic planner + skills | Optional `.claude/agents/powershell-atomic-planner.md` |
| `.github/agents/powershell-atomic-executor.agent.md` | Project worker subagent | `.claude/agents/powershell-atomic-executor.md` |
| `.github/agents/csharp-atomic-planning.agent.md` | Optional C#-specialized planner worker or merge into generic planner + skills | Optional `.claude/agents/csharp-atomic-planner.md` |
| `.github/agents/csharp-atomic-executor.agent.md` | Project worker subagent | `.claude/agents/csharp-atomic-executor.md` |
| `.github/agents/python-typed-engineer.agent.md` | Project worker subagent | `.claude/agents/python-typed-engineer.md` |
| `.github/agents/python-execution-only-typed.agent.md` | Merge into `python-typed-engineer`; do not create a second project worker | No separate project file |
| `.github/agents/powershell-typed-engineer.agent.md` | Project worker subagent | `.claude/agents/powershell-typed-engineer.md` |
| `.github/agents/csharp-typed-engineer.agent.md` | Project worker subagent | `.claude/agents/csharp-typed-engineer.md` |
| `.github/agents/typescript-engineer.agent.md` | Project worker subagent | `.claude/agents/typescript-engineer.md` |
| `.github/agents/feature-review.agent.md` | Project worker subagent plus optional wrapper skill | `.claude/agents/feature-review.md`, optional `.claude/skills/review-feature/SKILL.md` |
| `.github/agents/task-researcher.agent.md` | Project worker subagent plus wrapper skill | `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md` |
| `.github/agents/pr-author.agent.md` | Manual wrapper skill, optional focused subagent | `.claude/skills/pr-author/SKILL.md`, optional `.claude/agents/pr-author.md` |
| `.github/agents/commit-steward.agent.md` | Manual wrapper skill, optional focused subagent | `.claude/skills/commit-message/SKILL.md`, optional `.claude/agents/commit-steward.md` |
| `.github/agents/prd-feature.agent.md` | Project worker subagent plus wrapper skill; main thread handles any research sequencing | `.claude/agents/prd-feature.md`, `.claude/skills/fill-feature-docs/SKILL.md` |
| `.github/agents/prd.agent.md` | Optional manual skill or personal agent only; not project-default automation | Optional `.claude/skills/prd-creator/SKILL.md` or `~/.claude/agents/prd-creator.md` |
| `.github/agents/staged-review.agent.md` | Project worker subagent plus wrapper skill | `.claude/agents/staged-review.md`, `.claude/skills/review-staged/SKILL.md` |
| `.github/agents/epic-review.agent.md` | Project worker subagent plus wrapper skill | `.claude/agents/epic-review.md`, `.claude/skills/review-epic/SKILL.md` |
| `.github/agents/status_updater.agent.md` | Project worker subagent plus wrapper skill | `.claude/agents/status-updater.md`, `.claude/skills/update-status/SKILL.md` |
| `.github/agents/commentary-remediation.agent.md` | Optional maintenance-only project worker or manual skill | Optional `.claude/agents/comment-remediator.md` and/or `.claude/skills/remediate-comments/SKILL.md` |
| `.github/agents/pytest-unit-test-coding.agent.md` | Optional specialized worker or merge into Python engineer workflow | Optional `.claude/agents/pytest-unit-test-coding.md` |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | Optional specialized worker or merge into PowerShell engineer workflow | Optional `.claude/agents/powershell-di-unit-test-engineer.md` |
| `.github/agents/tdd-red.agent.md`, `.github/agents/tdd-green.agent.md`, `.github/agents/tdd-refactor.agent.md` | Optional personal/library or future project workers only if TDD becomes canonical | Optional user-level or future project files |
| `.github/agents/mentor.agent.md`, `.github/agents/api-architect.agent.md`, `.github/agents/hlbpa.agent.md`, `.github/agents/expert-nextjs-developer.agent.md`, `.github/agents/expert-react-frontend-engineer.agent.md`, `.github/agents/5.1-Beast-adjusted.agent.md`, `.github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md`, `.github/agents/gpt-5-beast-mode.agent.md`, `.github/agents/voidbeast-gpt41enhanced.agent.md` | Personal or library personas only; keep out of repository-scoped automatic routing | User-level only or retire |

### Direct-use `.github/prompts` migration map

| `.github/prompts` source | Claude-native target |
|---|---|
| `orchestrate-work.prompt.md` | `.claude/skills/orchestrate/SKILL.md` |
| `orchestrate-python-work.prompt.md` | `.claude/skills/orchestrate-python/SKILL.md` or fold into orchestrator routing skills |
| `orchestrate-powershell-work.prompt.md` | `.claude/skills/orchestrate-powershell/SKILL.md` or fold into orchestrator routing skills |
| `orchestrate-csharp-work.prompt.md` | `.claude/skills/orchestrate-csharp/SKILL.md` or fold into orchestrator routing skills |
| `generate-pr.prompt.md` | `.claude/skills/pr-author/SKILL.md` |
| `generate-commit-message-repo.prompt.md` | `.claude/skills/commit-message/SKILL.md` |
| `generate-atomic-plan.prompt.md` | Supporting reference content inside the planner skill directory |
| `research-issue.prompt.md` | `.claude/skills/research-issue/SKILL.md` |
| `review-feature.prompt.md` | `.claude/skills/review-feature/SKILL.md` |
| `review-staged.prompt.md` | `.claude/skills/review-staged/SKILL.md` |
| `review-epic.prompt.md` | `.claude/skills/review-epic/SKILL.md` |
| `update_status.prompt.md` | `.claude/skills/update-status/SKILL.md` |
| `fillout-prd-feature.prompt.md` | `.claude/skills/fill-feature-docs/SKILL.md` |
| Remaining `breakdown-*`, `export-chat`, `code-exemplars-*`, `javascript-typescript-jest`, `add-educational-comments`, and `remediate-comments` prompts | Optional manual skills retained only if still actively used |


## Inputs / Outputs

**Inputs:**
- The canonical `.github/instructions/*.instructions.md` files (standing policy sources).
- The canonical `.github/agents/*.agent.md` files (specialist persona definitions).
- The canonical `.github/skills/*/SKILL.md` files (reusable workflow contracts).
- The canonical `.github/prompts/*.prompt.md` files (direct-use entry points).
- The existing `artifacts/orchestration/orchestrator-state.json` checkpoint schema.

**Outputs:**
- `CLAUDE.md` (repo root) — repository tone policy, compliance reading order, and architectural context.
- `.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/csharp.md` — path-scoped language policy files.
- `.claude/skills/orchestrate/SKILL.md` — orchestration entry point skill.
- `.claude/skills/commit-message/SKILL.md` — commit message generation skill.
- `.claude/skills/pr-author/SKILL.md` — PR authoring skill.
- `.claude/skills/research-issue/SKILL.md` — research task skill.
- `.claude/agents/orchestrator.md` — orchestrator subagent.
- `.claude/agents/atomic-planner.md` — atomic planner subagent.
- `.claude/agents/atomic-executor.md` — atomic executor subagent.
- `.claude/agents/feature-review.md` — feature review subagent.
- `.claude/agents/task-researcher.md` — task researcher subagent.
- `.claude/agents/prd-feature.md` — feature-doc completion subagent.
- `.claude/agents/python-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/agents/typescript-engineer.md` — repository-canonical implementation workers.
- `.claude/settings.json` — shared permissions and hook configuration.
- `.claude/hooks/validate-bash.ps1` — PreToolUse bash validation hook script.
- `docs/engineering/claude-code-architecture.md` — sync strategy and Copilot/Claude equivalences documentation.

**Config keys and defaults:**
- No environment variables or feature flags are introduced. All configuration lives in `.claude/settings.json` and the supporting files.

**Versioning / backward-compatibility constraints:**
- Existing `.github/` files are the canonical source and must not be modified. `.claude/` files mirror or reference content from `.github/` as specified by the sync strategy.
- The `.claude/commands/` directory must not be used for new user-invocable workflows. If it exists, it is documented as a backward-compatibility surface only.
- The migration must preserve the distinction between repository-canonical project workers and personal/library personas. Repository-canonical workers live under `.claude/agents/`; generic or experimental personas stay user-scoped or are retired.

## API / CLI Surface

**Skill invocations (primary user-invocable surface in Claude Code):**

```
/orchestrate <objective>
  → runs in the current main Claude session, which is already using the `orchestrator` agent via `.claude/settings.json`;
    the orchestrator reads the checkpoint and executes the full orchestration lifecycle
    (promotion → research → planning → execution → review) by launching bounded worker subagents from the main thread.

/commit-message
  → reads staged git changes and the commit-message conventions skill;
    writes a conventional commit message following the repository's canonical format.

/pr-author
  → reads pr_context.summary.txt and pr_context.appendix.txt;
    writes a GitHub-ready PR body with strict verification and auto-close rules.

/research-issue <feature-folder>
  → reads the issue.md in the specified feature folder;
    writes structured research output to artifacts/research/<timestamp>-<short-name>-research.md.

/review-feature <feature-folder>
  → invokes the feature review workflow skill, which launches the `feature-review` worker and produces
    the required audit artifacts under the active feature folder.

/review-staged
  → invokes the staged review workflow skill, which launches the `staged-review` worker and produces
    the required review artifacts from staged diffs.

/review-epic <epic-folder>
  → invokes the epic review workflow skill, which launches the `epic-review` worker and produces
    epic audit artifacts.

/update-status <epic-folder>
  → invokes the status synchronization workflow skill, which launches the `status-updater` worker and
    reconciles plan and issue status based on evidence.
```

**Subagent delegation (internal, not user-facing):**
- The main-thread `orchestrator` agent delegates to: `atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, and the repository's language engineers.
- Worker subagents that need follow-on actions do not themselves spawn more subagents; instead they return artifact paths or remediation-required signals to the main-thread orchestrator, which then launches the next worker.
- All delegation uses named `Agent(...)` patterns declared in the orchestrator's allowed tool surface and reinforced through `permissions.allow` / `permissions.deny` entries.

**Contracts and validation rules:**
- Skills must declare `description` and, where needed, `disable-model-invocation`, `user-invocable`, `argument-hint`, `allowed-tools`, `context`, `agent`, `hooks`, and `paths` in frontmatter.
- Subagents must declare `name`, `description`, `tools` (and `disallowedTools` where needed), `model`, `skills`, `memory`, `hooks`, and any required `permissionMode` in frontmatter.
- Settings must declare a `permissions` block with explicit `allow` and `deny` arrays.
- Hook scripts must exit with a non-zero code to block an operation and zero to allow it.
- `SubagentStop` hooks must reject worker completion when required artifact paths, checkpoint updates, or completion summaries are missing from the output.
- `ConfigChange` hooks may audit or block changes to `CLAUDE.md`, `.claude/settings.json`, and `.claude/rules/**` during runtime so the architecture remains stable while the migration is in progress.

## Data & State

**Data flow:**
- User invokes a skill → the current main session is already running as the `orchestrator` agent → the orchestrator reads policy from `CLAUDE.md` and `.claude/rules/` → the orchestrator reads `artifacts/orchestration/orchestrator-state.json` → the orchestrator launches bounded worker subagents as needed → each worker returns artifact paths and completion status → the orchestrator writes an updated checkpoint after each phase.

**Storage and persistence:**
- `artifacts/orchestration/orchestrator-state.json` is the persistent checkpoint for orchestration state. Its schema is unchanged from the existing Copilot orchestrator contract.
- All other outputs (plans, review artifacts, research files) follow the existing `docs/features/active/<feature>/` and `artifacts/` directory conventions.
- `.claude/settings.json` is the shared project configuration file, checked into the repository.
- `.github/skills/*/SKILL.md` and `.github/agents/*.agent.md` remain the authored source of reusable contracts and worker intent. The `.claude/` files are runtime mirrors or Claude-native wrappers around those canonical assets.

**Invariants:**
- The main-thread orchestrator must read the checkpoint before doing new work.
- The main-thread orchestrator must write an updated checkpoint after each phase transition.
- No `.claude/` file may replace a `.github/` file; both directories coexist.
- No repository workflow may depend on a nested Claude subagent spawning additional subagents.
- Only repository-canonical workers may be committed under `.claude/agents/`; generic or personal agents remain user-scoped or are removed from the repository runtime.

**Migration / backfill:**
- No migration of existing data is required. The `.claude/` directory is new and additive.
- Existing `.github/prompts/*.prompt.md` files are not deleted as part of the initial migration, but their user-facing equivalents move to `.claude/skills/*/SKILL.md`.

## Constraints & Risks

- Claude Code does not provide a direct equivalent for Copilot's declarative `handoffs:` metadata. The Claude-native substitute — named subagents plus skill `context: fork` delegation, checkpoint files, and `SubagentStop` hooks — approximates the behavior but relies on a different enforcement model. This must be documented explicitly and not presented as equivalent runtime enforcement.
- Custom subagents in Claude Code cannot themselves spawn further subagents from within a subagent invocation. Nested delegation must therefore be coordinated by the main thread. The `orchestrator` implementation cannot rely on `context: fork` to create an `orchestrator` worker that then performs downstream delegation.
- The repository's `.github/agents/` files and `.github/skills/` files represent the canonical workflow content. Creating a second divergent set of Claude-native files without a defined sync strategy will increase maintenance cost and create drift risk. The sync strategy is a required deliverable, not an optional follow-up.
- Permission configuration is a usability and safety tradeoff. Overly narrow `Bash(...)` allowlists will interrupt orchestration mid-workflow. Overly broad patterns weaken the enforcement layer. The initial permission set in `settings.json` should be derived from an actual audit of the operations each subagent performs, not from guessing.
- Project-scoped settings and hooks can enforce a strong default runtime, but they cannot make every user override impossible. Hard non-overrideable guarantees such as forcing the default agent, disallowing local permission edits, or requiring managed hooks depend on managed settings outside the repository.
- Migrating generic beast, mentor, or framework personas into project scope would weaken routing determinism by giving Claude additional irrelevant worker options. Those personas must remain user-scoped or be retired.
- Scope is limited to the four-layer architecture, skill and subagent definitions, settings and hooks, resumability, sync strategy, and validation guidance. It does not include rewriting every existing `.github/agents/` file, restructuring unrelated repository automation, or implementing agent teams (which are experimental, higher-cost, and not suited to this repository's sequential workflow model).
- Agent teams are explicitly out of scope. They are designed for collaborative parallel exploration, not for the repository's deterministic sequential pipeline (promotion → research → planning → execution → review).

## Implementation Strategy

**Implementation scope:**
All changes are additive new files in `.claude/` and `docs/engineering/`. No existing source, test, or configuration files are deleted or structurally modified. The `.github/` directory remains the canonical source of truth.

**New files to create:**

| File | Purpose |
|---|---|
| `CLAUDE.md` | Repo-root standing instructions: tone policy, compliance reading order, arch context |
| `.claude/rules/python.md` | Python policy rules, scoped via `paths: ["**/*.py"]` |
| `.claude/rules/powershell.md` | PowerShell policy rules, scoped via `paths: ["**/*.ps1", "**/*.psm1", "**/*.psd1"]` |
| `.claude/rules/typescript.md` | TypeScript policy rules, scoped via `paths: ["**/*.ts"]` |
| `.claude/rules/csharp.md` | C# policy rules, scoped via `paths: ["**/*.cs", "**/*.csproj"]` |
| `.claude/skills/orchestrate/SKILL.md` | Orchestration entry point; manual skill that frames work for the already-active main-thread orchestrator |
| `.claude/skills/commit-message/SKILL.md` | Commit message generation; `allowed-tools: [Read, Bash(git log *), Bash(git diff *)]` |
| `.claude/skills/pr-author/SKILL.md` | PR body authoring; `allowed-tools: [Read, Bash(git log *)]` |
| `.claude/skills/research-issue/SKILL.md` | Issue research; `allowed-tools: [Read, Grep, Glob, WebFetch]` |
| `.claude/skills/review-feature/SKILL.md`, `.claude/skills/review-staged/SKILL.md`, `.claude/skills/review-epic/SKILL.md`, `.claude/skills/update-status/SKILL.md` | Wrapper skills for review and status-sync workflows |
| `.claude/skills/fill-feature-docs/SKILL.md` | Wrapper skill for feature-doc completion from issue and research context |
| `.claude/agents/orchestrator.md` | Main-thread orchestrator agent with full worker delegation allowlist, `model: sonnet`, `memory: project` |
| `.claude/agents/atomic-planner.md` | Planning subagent restricted to `docs/` and `artifacts/` write paths |
| `.claude/agents/atomic-executor.md` | Execution subagent with explicit language toolchain `Bash(...)` patterns |
| `.claude/agents/feature-review.md` | Review subagent restricted to read + `Write(/docs/features/active/**)` |
| `.claude/agents/task-researcher.md` | Research subagent restricted to read + `Write(/artifacts/research/**)` |
| `.claude/agents/prd-feature.md` | Feature-doc completion worker with template-preserving write scope |
| `.claude/agents/python-typed-engineer.md` | Python implementation worker |
| `.claude/agents/powershell-typed-engineer.md` | PowerShell implementation worker |
| `.claude/agents/csharp-typed-engineer.md` | C# implementation worker |
| `.claude/agents/typescript-engineer.md` | TypeScript implementation worker |
| `.claude/settings.json` | Shared permissions and hook entries (allow/deny arrays + SubagentStop + PreToolUse) |
| `.claude/hooks/validate-bash.ps1` | PowerShell hook script invoked by `PreToolUse` for dangerous-command detection |
| `.claude/hooks/audit-config-change.ps1` | Optional config-change audit or block hook for Claude configuration edits |
| `docs/engineering/claude-code-architecture.md` | Sync strategy and Copilot/Claude equivalences documentation |

**Dependency changes:** None. No new packages are required.

**Logging/telemetry:** None introduced by this feature.

**Rollout plan:** No staged deploy or feature flags are needed. All files are checked into the repository on the feature branch and become available to Claude Code sessions opened in that repo immediately after merge. The runtime rollout order should be: standing instructions and rules first, reusable skills second, worker subagents third, settings and hooks fourth, and validation walkthrough last.

### Deterministic runtime wiring

1. Create `CLAUDE.md` and `.claude/rules/*` from the canonical `.github/instructions/*` policies.
2. Mirror canonical `.github/skills/*/SKILL.md` files into `.claude/skills/*/SKILL.md`, adding only Claude-native frontmatter and support-file references.
3. Create repository-canonical worker agents under `.claude/agents/*` and preload the relevant mirrored skills through `skills:` frontmatter.
4. Keep `.github/prompts/*` as source material during migration, but expose the user-facing workflow surface through project skills, not `.claude/commands/*`.
5. Configure `.claude/settings.json` with `agent: "orchestrator"`, deny-first permissions, worker-specific `Agent(...)` allow rules, and hook registrations for `PreToolUse`, `SubagentStop`, and optional `ConfigChange`.
6. Validate that the main-thread orchestrator can launch each allowed worker and that disallowed workers or tools are blocked by the enforcement layer.

### Enforcement model

The repository-enforceable controls are:

- `CLAUDE.md` and `.claude/rules/*` for always-on guidance
- `.claude/settings.json` `permissions.allow` / `permissions.deny` for deny-first runtime control
- `PreToolUse` hooks for dangerous command validation
- `SubagentStop` hooks for artifact-output and completion-gate enforcement
- `ConfigChange` hooks for detecting or blocking unauthorized edits to Claude configuration files

The migration documentation must also state clearly that the following stronger guarantees require managed settings outside the repository:

- forcing the default session agent so CLI overrides are impossible
- preventing user or local permission-rule edits entirely
- restricting hooks to managed-only hooks
- locking plugin marketplaces or MCP server availability

## Definition of Done

- [ ] The repository contains a working Claude-native architecture spanning `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/`, with each layer implemented for its intended feature role rather than documented only
- [ ] The main-thread orchestration flow is implemented so the repository can run end-to-end feature workflows in Claude Code without relying on a forked `orchestrator` worker to perform nested subagent delegation
- [ ] The repository includes the canonical user-facing workflow skills required by this feature (`orchestrate`, `commit-message`, `pr-author`, `research-issue`, and any required review/status skills), and each one routes to the expected Claude-native runtime surface
- [ ] The repository includes the bounded repository-canonical worker agents required by this feature (planner, executor, research, review, feature-doc, and language-engineer workers), with project-scoped routing limited to those workers rather than to generic personal personas
- [ ] The `.claude/settings.json` permissions and `.claude/hooks/*` enforcement layer are implemented and demonstrably block at least the documented disallowed tool/path/command cases while allowing the intended workflow operations
- [ ] The checkpoint-based resumability flow works with `artifacts/orchestration/orchestrator-state.json`, and an interrupted orchestration run resumes from recorded state instead of restarting from scratch
- [ ] The sync strategy is implemented and documented so a maintainer can determine how `.claude/` runtime files stay aligned with canonical `.github/` sources and can update them without guessing ownership or mirror rules
- [ ] The Copilot-to-Claude equivalence documentation is complete, including file-by-file migration maps for canonical `.github/skills`, `.github/agents`, and direct-use `.github/prompts`, plus explicit documentation of non-equivalences and fallback behavior
- [ ] Validation evidence exists for the required feature behaviors: skill invocation, worker routing, permission enforcement, hook enforcement, checkpoint resume behavior, and exclusion of repository-disallowed generic agents from project-scoped automatic routing
- [ ] Documentation for using and maintaining the new Claude runtime is updated in the expected repository locations (`docs/engineering/claude-code-architecture.md`, feature docs, and any referenced entry-point guidance)

## Seeded Test Conditions (from potential)
- [ ] Validation that each `.claude/skills/` file can be invoked by name in a Claude Code session and produces the expected entry-point behavior (context fork, agent delegation, or direct workflow execution as applicable)
- [ ] Validation that each `.claude/agents/` subagent's `tools` frontmatter correctly restricts the tool surface: attempt an operation outside the declared allowlist and confirm it is blocked at the permission layer, not just by prose instruction
- [ ] Validation that the `SubagentStop` hooks in `settings.json` block premature termination when the required artifact path is absent from the subagent's output, and allow termination when the artifact path is present
- [ ] Validation that the main-thread `orchestrator` agent reads `artifacts/orchestration/orchestrator-state.json` at the start of a session and correctly resumes from a partially populated checkpoint rather than restarting the workflow from scratch
- [ ] Validation that the `PreToolUse` bash-validation hook in `settings.json` invokes the hook script and blocks at least one representative dangerous-command pattern
- [ ] Validation that the main-thread `orchestrator` can launch each allowed worker agent directly and that repository-disallowed generic or personal agents are not available through the project-scoped automatic routing path
- [ ] Documentation review confirming that every non-equivalence between Copilot and Claude is identified and that no section of the migration documentation claims runtime enforcement for behaviors that are enforced only by prompt conventions
