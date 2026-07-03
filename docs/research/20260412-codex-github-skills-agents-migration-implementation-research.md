<!-- markdownlint-disable-file -->

# Task Research Notes: codex-github-skills-agents-migration

## Research Executed

### File Analysis

- `c:\Users\DanMoisan\repos\drm-copilot\.github`
  - The migration source is large and still structurally authoritative today: `rg --files .github` returned 109 files, and a repo-local line count across those files reported 13,668 lines spanning agents, instructions, prompts, skills, workflows, and the `.github/codex` utility files.
- `c:\Users\DanMoisan\repos\drm-copilot\AGENTS.md`
  - The current always-on Codex instruction file is generated from `.github/copilot-instructions.md` plus `.github/instructions/*.instructions.md`, so the current Codex runtime still depends on GitHub-ecosystem source files for repository policy.
- `c:\Users\DanMoisan\repos\drm-copilot\.agents\README.md`
  - The repo already defines the intended Codex runtime split: `.agents/skills/<skill>/SKILL.md` for reusable skills, `.codex/agents/*.toml` for subagents, and `.codex/prompts/*.md` for prompt launchers. That is the strongest internal evidence for where the final native source of truth should live.
- `c:\Users\DanMoisan\repos\drm-copilot\.agents\skills\README.md`
  - The Codex skill taxonomy already groups foundation, integration, language-routing, workflow, and specialist-support skills. This is a usable target architecture, not a greenfield design.
- `c:\Users\DanMoisan\repos\drm-copilot\.agents\skills\policy-compliance-order\SKILL.md`
  - The skill still instructs agents to read `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md`, so one of the most central Codex-native skills still points back into the GitHub ecosystem.
- `c:\Users\DanMoisan\repos\drm-copilot\.agents\skills\repo-automation-adapter\SKILL.md`
  - This is already a good Codex-native pattern: host-specific automation is centralized in one shared skill, semantic MCP tools on server `drmCopilotExtension` are the canonical dependency, and the skill explicitly forbids duplicating raw VS Code command IDs across workflows.
- `c:\Users\DanMoisan\repos\drm-copilot\.agents\skills\repo-automation-adapter\agents\openai.yaml`
  - The repo already uses a Codex-native MCP dependency declaration beside the owning skill. The final migration should keep this pattern and expand it only where a skill truly owns an external MCP dependency.
- `c:\Users\DanMoisan\repos\drm-copilot\.codex\agents\orchestrator.toml`
  - The orchestrator is already authored as a native Codex agent with repo-local skill references and strict delegation receipts. It no longer reads `.github` directly.
- `c:\Users\DanMoisan\repos\drm-copilot\.codex\agents\atomic-planner.toml`
  - The planner is already native and preserves the strict planner -> executor preflight loop as a Codex subagent contract, including validator requirements and in-place plan revision.
- `c:\Users\DanMoisan\repos\drm-copilot\.codex\agents\feature-reviewer.toml`
  - The feature reviewer is already native and preserves remediation-triggered automatic planning handoffs without referring back to `.github`.
- `c:\Users\DanMoisan\repos\drm-copilot\.codex\agents\task-researcher.toml`
  - This and many other agents remain migration wrappers. The file explicitly says it is a Codex migration wrapper, names `.github/agents/task-researcher.agent.md` as the canonical migration source, and requires reading that source file first.
- `c:\Users\DanMoisan\repos\drm-copilot\.codex\agents`
  - A repo-local count found 42 Codex agent files. Of those, 15 are native contracts and 27 are wrappers that still require `.github/agents/*.agent.md` at runtime.
- `c:\Users\DanMoisan\repos\drm-copilot\.codex\prompts`
  - Only four prompt launchers currently exist: `feature-review-remediate.md`, `generate-commit-message-repo.md`, `generate-pr.md`, and `orchestrate-work.md`. The `.github/prompts` source tree contains 24 files, so most GitHub prompt entry points have not yet been re-expressed natively.
- `c:\Users\DanMoisan\repos\drm-copilot\scripts\dev-tools\sync-agents-from-instructions.ps1`
  - The AGENTS generator hard-codes `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md` as its discovery and rendering source, then writes a generated `AGENTS.md`. This script is a primary implementation target because it is the mechanism that keeps Codex always-on instructions coupled to `.github`.
- `c:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools\agentic_sync.py`
  - The cross-repo synchronization tool only syncs `.github/agents`, `.github/instructions`, `.github/prompts`, and `.github/skills`. It does not synchronize `.agents`, `.codex`, or any future project-level Codex plugin/config layer.
- `c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_codex_full_migration_inventory.py`
  - Current tests intentionally allow two Codex agent shapes: native contracts and strict wrappers. For non-bespoke agents, the tests explicitly require wrapper fragments such as `Canonical migration source:` and `.github/agents/` references. These tests must change if the final runtime is to stop reading GitHub ecosystem files.
- `c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_codex_agent_wrapper_contracts.py`
  - The wrapper-contract tests currently preserve strict handoff behavior in native agents. They are useful and should survive, but their assertions should move from wrapper provenance to native contract wording.
- `c:\Users\DanMoisan\repos\drm-copilot\tests\scripts\dev_tools\test_codex_handoff_contract_parity.py`
  - The parity tests already validate important Codex-native workflow guarantees across skills and agents: strict planner preflight, executor preflight return signals, and automatic remediation handoff. These are the correct guards to keep after migration.
- `c:\Users\DanMoisan\repos\drm-copilot\README.md`
  - The README already documents the `drmCopilotExtension` MCP surface for Codex but still describes `.github/skills/` as the skill-definition location and still documents `syncAgentsFromInstructions` as a `.github/instructions` aggregator.
- `c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\README.md`
  - The extension README and related templates still describe `.github/instructions/*.instructions.md` as the canonical AGENTS source. The extension command surface therefore still publishes GitHub-ecosystem assumptions into downstream workspaces.
- `c:\Users\DanMoisan\repos\drm-copilot\extensions\drm-copilot\resources\templates\policy_audit\AGENTS.md`
  - The policy-audit template AGENTS file tells Codex to follow `.github/instructions/*.instructions.md`. This is another direct runtime dependency that must be removed if a downstream workspace is expected to be functional without the GitHub ecosystem.
- `c:\Users\DanMoisan\repos\drm-copilot\artifacts\research\20260412-claude-code-github-skills-agents-migration-research.md`
  - The Claude migration research is a strong example of the required evidence quality and of full-tree mapping, but the runtime conclusions are not directly reusable because Codex supports different native primitives, especially AGENTS.md, project skills, subagents, MCP config, and plugins.

### Code Search Results

- `rg -n "\.github/|Canonical migration source:|Read the canonical source" .agents .codex AGENTS.md`
  - The active Codex runtime still contains many GitHub-ecosystem dependencies: `AGENTS.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/skill-canonical-location-audit/SKILL.md`, and 27 `.codex/agents/*.toml` wrapper agents all reference `.github` directly.
- `rg -n "You are the Codex migration wrapper for the legacy GitHub Copilot agent" .codex/agents`
  - 27 wrapper agents were found. The remaining 15 `.codex/agents/*.toml` files are native contracts. The migration is therefore materially incomplete rather than merely undocumented.
- `rg -n "\.github/instructions|syncAgentsFromInstructions|AGENTS.md" scripts extensions tests`
  - The `.github` dependency is systemic, not isolated to agent wrappers. It is encoded in the AGENTS generator, the extension command, the extension README, feature templates, policy-audit templates, and multiple test suites.
- `rg --files .github` plus repo-local counting
  - The migration source is 109 files / 13,668 lines. This is small enough to normalize into native surfaces through scripted generation and parity tests, and large enough that maintaining two hand-authored ecosystems would create drift.
- `.github/skills` directory comparison against `.agents/skills`
  - Only one GitHub skill name lacks a same-name Codex-native counterpart (`feature-review-workflow`), but several Codex-native skills now have different names or consolidated roles (`feature-review`, `atomic-planner`, `atomic-executor`, `commit-message-conventions`, `orchestrator-workflow`, `pr-authoring`, `repo-automation-adapter`).
- `.codex/prompts` versus `.github/prompts`
  - GitHub has 24 prompt files while Codex has 4. Prompt entrypoint migration is therefore only partially complete and is an explicit design choice that still needs rationalization.
- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`
  - The current inventory test codifies wrapper acceptance by requiring `.github/agents/` fragments for most Codex agents. This confirms that runtime `.github` reads are still part of the tested design, not accidental leftovers.

### External Research

- #githubRepo:"openai/codex AGENTS.md"
  - The official `openai/codex` repository publishes repo-local `AGENTS.md` guidance directly in the repo. This supports making `AGENTS.md` itself the runtime truth for persistent instructions instead of treating it only as a generated view over `.github`.
- #fetch:https://developers.openai.com/codex/guides/agents-md
  - Official Codex docs state that Codex reads `AGENTS.md` files from the current working directory upward, later and deeper files override earlier ones, nested files are preferred over top-level files, and the combined AGENTS context has a size limit. This makes `AGENTS.md` the correct surface for persistent policy but a poor place for long workflow bodies.
- #fetch:https://developers.openai.com/codex/skills
  - Official docs define project-local skills as the authoring surface for reusable workflow guidance. They explicitly recommend starting with local skills for repo workflows and using plugins later when sharing across teams or bundling integrations. This aligns with the repo’s existing `.agents/skills` direction.
- #fetch:https://developers.openai.com/codex/subagents
  - Official docs define subagents as first-class specialist workers and state that subagents only run when the user explicitly asks. The docs also document agent nesting controls through `agents.max_depth` and concurrency via `agents.max_threads`. Current repo workflows that require planner -> executor or reviewer -> planner nested handoffs therefore need an explicit Codex config, not an implicit assumption.
- #fetch:https://developers.openai.com/codex/mcp
  - Official Codex docs define MCP server configuration in `~/.codex/config.toml` and in project `.codex/config.toml` for trusted repositories. This is the correct native place to declare the `drmCopilotExtension` server and any future optional GitHub-related MCP bindings for this repo.
- #fetch:https://developers.openai.com/codex/plugins/build
  - Official plugin docs define plugins as installable packages with `.codex-plugin/plugin.json` plus optional `.mcp.json`, `.app.json`, and skills. The docs explicitly recommend local skills first and plugins later when packaging stable, shareable workflows. That makes plugins an optional distribution layer, not the primary runtime truth for this migration.
- #fetch:https://developers.openai.com/codex/rules
  - Official rules docs describe `.rules` files as a way to gate commands that escape the sandbox or to inject command-specific instruction text. That is narrower than the repo’s full workflow contracts; rules are useful for shell guardrails but should not carry the main orchestration or template logic.
- #fetch:https://developers.openai.com/codex/hooks
  - As of April 12, 2026, the official hooks page marks hooks as experimental and temporarily disabled on Windows. Because the user environment is Windows and this repo already targets Windows-hosted PowerShell workflows, hooks should not be a required enforcement mechanism for the migration.

### Project Conventions

- Standards referenced: `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `.agents/README.md`, `.agents/skills/README.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/repo-automation-adapter/SKILL.md`, `.codex/agents/*.toml`, `.codex/prompts/*.md`, and the Codex migration regression tests under `tests/scripts/dev_tools/`.
- Instructions followed: research-only work restricted to `artifacts/research/`; evidence-backed findings only; no code/config edits outside the research artifact; official Codex guidance treated as the primary external source.

## Key Discoveries

### Project Structure

The repository already has the outline of a correct Codex-native architecture, but it is still in a transitional dual-runtime state.

The current layers are:

1. Persistent instructions
   - Runtime surface today: `AGENTS.md`
   - Actual authored source today: `.github/copilot-instructions.md` plus `.github/instructions/*.instructions.md`
   - Problem: Codex reads `AGENTS.md`, but the repo still requires `.github` to build and reason about it.

2. Reusable workflow and policy packets
   - Runtime surface today: `.agents/skills/*/SKILL.md`
   - Strength: this is already the right place for reusable workflow contracts.
   - Problem: several skills still point back to `.github`, especially baseline policy and migration-audit skills.

3. Specialist workers
   - Runtime surface today: `.codex/agents/*.toml`
   - Strength: orchestration-chain agents are already authored natively and preserve strict handoff rules.
   - Problem: most non-chain agents are still wrappers that must read `.github/agents/*.agent.md` first.

4. Lightweight launchers
   - Runtime surface today: `.codex/prompts/*.md`
   - Strength: the repo already uses thin launchers for orchestrate / commit-message / PR authoring.
   - Problem: this is only partially migrated, and `.codex/prompts` is a repo convention rather than the primary Codex concept documented by OpenAI. The stable reusable workflow logic belongs in `.agents/skills`, not in prompt files.

5. External tool and automation bindings
   - Runtime surface today: `repo-automation-adapter` plus `agents/openai.yaml`
   - Strength: this is already the correct abstraction boundary for `drmCopilotExtension` MCP usage.
   - Problem: the repo does not yet have a project `.codex/config.toml`, so MCP server availability, nesting depth, and any future optional plugin/app configuration are not expressed in Codex’s native config surface.

6. Distribution
   - Runtime/distribution surface today: extension-side bundled `.codex` / `.agents` publisher and push-down tooling
   - Strength: the repo already knows how to publish Codex assets into another workspace.
   - Problem: the published assets still include wrapper agents and GitHub-ecosystem assumptions.

The most important structural conclusion is this:

- The final Codex-native runtime should make `AGENTS.md`, `.agents/skills`, `.codex/agents`, and project `.codex/config.toml` the runtime truth.
- `.github` can remain only as optional compatibility export material or repository CI/config material, not as a runtime dependency.

### Implementation Patterns

The best Codex-native pattern for this repository is a **native-source-of-truth architecture with compatibility export, not wrapper indirection**.

The native roles should be:

1. `AGENTS.md`
   - Purpose: persistent repository policy, tone, baseline workflow constraints, path-specific instructions through nested AGENTS files when needed.
   - Keep concise because official docs impose a combined size limit across loaded AGENTS files.
   - Do not place long multi-step workflow bodies here.

2. `.agents/skills/*/SKILL.md`
   - Purpose: reusable workflow bodies, template rules, artifact contracts, handoff contracts, and shared policy packets.
   - This should be the canonical authored source for most material currently in `.github/skills` and most reusable workflow content currently duplicated in `.github/prompts`.
   - This layer already exists and should become the canonical source of truth.

3. `.codex/agents/*.toml`
   - Purpose: bounded workers and orchestrators with concise native developer instructions that reference repo-local skills instead of wrappering `.github`.
   - Keep thin. If a rule is reusable across agents, it belongs in a skill.
   - Replace wrapper agents with native contracts in place; do not keep the wrapper text and simply rename the source path.

4. `.codex/config.toml`
   - Purpose: Codex-native project configuration.
   - Required here because the repo needs:
     - `mcp_servers.drmCopilotExtension`
     - explicit `agents.max_depth` for nested handoff chains
     - optional `agents.max_threads`
     - optional `project_doc_fallback_filenames` only if additional persistent instruction files are introduced deliberately
   - This file is currently missing and is a real functionality gap for native Codex execution.

5. `repo-automation-adapter` + `agents/openai.yaml`
   - Purpose: the only place where repo-local workflow skills depend on MCP semantics.
   - Keep this centralization. Do not duplicate `drmCopilotExtension` bindings across skills or agent files.

6. Optional plugin packaging
   - Purpose: stable cross-repo installation and bundled integration metadata.
   - Not required for correctness inside this repo.
   - Good as a final packaging/distribution step once the repo’s runtime truth is fully native.

7. Rules and hooks
   - Purpose: optional guardrails.
   - Do not make them required for the core migration.
   - Official hooks are currently a poor fit for this repo because the docs say they are temporarily disabled on Windows as of April 12, 2026.

The concrete migration implication is that the current repo should preserve its strict handoff, template, and validation processes in skills and native agent contracts, then backstop them with tests and validators rather than with runtime wrapper indirection.

### Complete Examples

```toml
# Proposed native Codex project config and contract flow.

# .codex/config.toml
[agents]
max_depth = 2
max_threads = 6

[mcp_servers.drmCopilotExtension]
command = "python"
args = ["-m", "scripts.dev_tools.run_mcp_server"]

# Pseudocode for the native-source-of-truth update flow:
#
# 1. Read native authored policy sources.
# 2. Render AGENTS.md from native policy inputs, not from .github/instructions.
# 3. Keep reusable workflow contracts in .agents/skills.
# 4. Update each .codex/agents/*.toml file so it references only native skills.
# 5. Fail validation if any runtime file under AGENTS.md / .agents / .codex still
#    contains .github/agents, .github/instructions, or wrapper-provenance wording.
# 6. Refresh extension bundle assets from the native Codex surfaces.
# 7. Optionally emit compatibility exports or a plugin package after native
#    validation passes.
```

### API and Schema Documentation

The recommended native file roles are:

- `AGENTS.md`
  - Canonical always-on instruction surface for Codex.
  - Generated from native policy source files if the repo still wants modular authorship, but the generator must no longer depend on `.github/instructions`.

- `.agents/skills/<skill-name>/SKILL.md`
  - Canonical reusable workflow / shared rule surface.
  - Use for:
    - atomic plan contracts
    - feature review workflow
    - policy audit template usage
    - PR context rules
    - remediation handoff rules
    - language routing rules
    - commit/PR authoring contracts

- `.agents/skills/<skill-name>/agents/openai.yaml`
  - Canonical per-skill MCP dependency declaration when a skill owns an MCP dependency.
  - Use only for the owning adapter skill to avoid duplication.

- `.codex/agents/<agent-name>.toml`
  - Canonical bounded worker definition.
  - Use for orchestrator, planners, executors, reviewers, researchers, document writers, and typed engineers.
  - Native agents should reference repo-local skills directly and should not read `.github/agents/*.agent.md`.

- `.codex/prompts/*.md`
  - Optional thin launchers only.
  - Keep only when a one-shot launch surface materially improves usability.
  - They should forward into native agents or native skills and should not hold canonical workflow rules.

- `.codex/config.toml`
  - Canonical Codex project configuration surface.
  - Required because nested subagent contracts in this repo need explicit depth configuration and MCP server definition.

- Optional plugin package
  - `plugins/<name>/.codex-plugin/plugin.json`
  - optional `.mcp.json`
  - optional `.app.json`
  - optional skills
  - Use only when this repo wants a shareable installable package beyond the repo-local runtime.

Proposed migration state model:

1. `legacy-runtime-bound`
   - Runtime files still read `.github`.
2. `native-authored`
   - Native sources exist for policies, skills, agents, and config.
3. `native-validated`
   - No runtime `.github` references remain under `AGENTS.md`, `.agents`, `.codex`, or the bundled Codex payload.
4. `compat-exported`
   - Optional compatibility outputs are generated for GitHub-side consumers, but Codex runtime no longer requires them.
5. `packaged`
   - Optional plugin or push-down package is published from the native Codex surfaces.

State transitions should be fail-closed:

- do not advance from `native-authored` to `native-validated` until inventory tests confirm zero runtime `.github` dependencies,
- do not advance to `compat-exported` or `packaged` until the extension bundle and native tests both pass,
- do not mark the migration complete while wrapper-agent tests still require `.github/agents/` fragments.

### Configuration Examples

```toml
# Minimal recommended project config shape for this repository.

[agents]
max_depth = 2
max_threads = 6

[mcp_servers.drmCopilotExtension]
command = "python"
args = ["-m", "scripts.dev_tools.run_mcp_server"]

# Optional only if the repo introduces an additional persistent instruction file
# alongside AGENTS.md and wants Codex to read it automatically.
project_doc_fallback_filenames = ["AGENTS.md"]
```

### Technical Requirements

1. Make Codex-native files the runtime source of truth.
   - Update `scripts/dev-tools/sync-agents-from-instructions.ps1` so it reads native instruction sources instead of `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md`.
   - Regenerate `AGENTS.md` from that native source.

2. Remove runtime `.github` dependencies from skills.
   - Update `.agents/skills/policy-compliance-order/SKILL.md` to point to `AGENTS.md` and any native instruction-source directory.
   - Update `.agents/skills/skill-canonical-location-audit/SKILL.md` to audit `.agents/skills/**/SKILL.md`, not `.github/skills/**/SKILL.md`.
   - Update `.agents/skills/make-skill-template/SKILL.md` so it is explicitly about Codex-native skills, not GitHub Copilot skills.

3. Replace wrapper agents with native agents.
   - Rewrite the 27 wrapper agents under `.codex/agents/` so they no longer require `Canonical migration source` and no longer read `.github/agents/*.agent.md`.
   - Preserve current sequencing, handoff, and validation rules by moving shared logic into skills where appropriate.

4. Rationalize prompt launchers.
   - Keep `.codex/prompts/*.md` only as thin entrypoint shims where they materially help.
   - Migrate reusable workflow logic from `.github/prompts/*.prompt.md` into `.agents/skills`, not into large prompt files.

5. Add a real Codex project config.
   - Create `.codex/config.toml`.
   - Declare the `drmCopilotExtension` MCP server there.
   - Set `agents.max_depth` high enough to support the existing planner -> executor and reviewer -> planner handoff chains. With the current workflow design, `2` is the minimum defensible setting.

6. Keep MCP/tooling ownership centralized.
   - Continue using `repo-automation-adapter` as the only skill that owns the repo automation MCP dependency declaration via `agents/openai.yaml`.
   - Do not duplicate MCP dependency metadata in every workflow skill or agent.

7. Update distribution and bundle tooling.
   - Update `scripts/dev_tools/agentic_sync.py` to synchronize native Codex surfaces and any native instruction-source directory, not just `.github`.
   - Update the extension’s bundled `.codex` / `.agents` payload and any documentation or templates that still tell downstream repos to depend on `.github/instructions`.

8. Invert the current migration tests.
   - Replace tests that currently require wrapper provenance with tests that fail when runtime `.github` references remain in `AGENTS.md`, `.agents`, `.codex`, or the bundled Codex payload.
   - Keep the existing strict handoff and validator parity tests, because those already protect the behavior that matters.

9. Treat plugins as optional packaging, not as primary runtime architecture.
   - If cross-repo installation is a goal after native migration, add a plugin package only after the repo-local runtime is fully native.
   - Do not force the repo to depend on plugin packaging for basic operation.

10. Do not rely on hooks for required enforcement on Windows.
   - Preserve strict handoffs, template usage, and workflow processes in native skills, native agent contracts, validators, and tests.
   - Consider rules or hooks only as optional future guardrails once official Windows support is viable.

**Mandatory unachievable objective callout**:
- **The repo cannot satisfy the objective "nothing in the final Codex system should require reading anything from the GitHub ecosystem" while keeping the current wrapper-agent and AGENTS-generation design intact. Today, `AGENTS.md`, the AGENTS sync script, multiple skills, 27 Codex agents, the extension README/templates, and several tests all explicitly depend on `.github`. Those contracts must be rewritten, not merely renamed.**
- **The repo should not make Windows hooks a required part of the migration. As of April 12, 2026, the official Codex hooks documentation marks hooks as experimental and temporarily disabled on Windows, which is the user’s current environment.**

## Recommended Approach

Adopt a **Codex-native source-of-truth migration**:

1. Make `AGENTS.md`, `.agents/skills`, `.codex/agents`, and a new project `.codex/config.toml` the canonical runtime surfaces.
2. Move persistent policy authorship to native instruction sources that render `AGENTS.md`, instead of generating `AGENTS.md` from `.github/instructions`.
3. Convert every remaining wrapper agent into a native Codex agent that references repo-local skills directly.
4. Keep strict handoff, template, and validation contracts in shared skills plus native agent instructions, then enforce them with validators and regression tests.
5. Keep `repo-automation-adapter` as the only MCP-owning adapter skill and declare `drmCopilotExtension` in project `.codex/config.toml`.
6. Keep `.codex/prompts` only as thin launchers where useful; do not make them the canonical workflow body.
7. Treat plugin packaging as a later optional distribution layer once the repo-local runtime is fully native and self-contained.

Why this is the best fit:

- It directly satisfies the user’s key objective: the final Codex runtime no longer needs `.github` files to function.
- It aligns with current official Codex concepts: `AGENTS.md` for persistent instructions, skills for reusable workflows, subagents for bounded workers, and config for MCP/nesting behavior.
- It preserves the repo’s strict handoff and validation design with minimal behavioral disruption because the important contracts are already captured in native skills and in the native orchestration-chain agents.
- It avoids an unnecessary rearchitecture into plugins or hook-dependent enforcement before the repo’s own native runtime is complete.

Rejected alternatives (brief, non-exhaustive):

- **Keep `.github` as canonical and retain wrapper agents**: rejected because it fails the stated objective of a self-sufficient Codex runtime and keeps drift and dual-maintenance risk high.
- **Plugin-first migration**: rejected as the primary approach because plugins are a packaging layer, not the best place to establish the repo’s canonical runtime truth.
- **Prompt-first migration**: rejected because official Codex guidance and the repo’s own current skill architecture both point to skills as the reusable workflow surface; prompt files are appropriate only as thin launchers.

## Implementation Guidance

- **Objectives**: remove all runtime `.github` dependencies from Codex surfaces; preserve strict handoffs, validation loops, and template usage; add native Codex configuration for MCP and nesting; keep downstream installation possible without the GitHub ecosystem.
- **Key Tasks**: retarget AGENTS generation to native sources; rewrite wrapper agents as native contracts; update baseline skills that still reference `.github`; add `.codex/config.toml`; update extension docs/templates and bundle resources; invert inventory tests so they fail on runtime `.github` references; optionally add a plugin package only after native migration is complete.
- **Dependencies**: `AGENTS.md`; `.agents/skills/**`; `.codex/agents/**`; `.codex/prompts/**`; `scripts/dev-tools/sync-agents-from-instructions.ps1`; `scripts/dev_tools/agentic_sync.py`; `extensions/drm-copilot/**`; `tests/scripts/dev_tools/**`; the `drmCopilotExtension` MCP server; official Codex docs for AGENTS, skills, subagents, MCP, plugins, rules, and hooks.
- **Success Criteria**: `AGENTS.md`, `.agents`, `.codex`, and the bundled Codex payload contain no required runtime references to `.github`; all previously wrappered agents are native; `.codex/config.toml` exists and explicitly defines MCP plus agent nesting; strict handoff/template/validator parity tests still pass; extension and publisher docs no longer tell downstream workspaces to depend on `.github/instructions`; a downstream repo can receive the Codex payload and operate without any GitHub-ecosystem runtime files.
