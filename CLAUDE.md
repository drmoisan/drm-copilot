---
description: Standing instructions for Claude Code sessions in this repository.
---
@AGENTS.md

# CLAUDE.md

The import above loads `AGENTS.md`, the hand-authored standing guidance shared with every agent: tone, the Codex rule skills, the toolchain loop, the file-size pointer, the harness sources, and Codex epic routing. The sections below are Claude-only.

## Policy Compliance Reading Order

Before performing any code or test changes, read the following policy rules in this order:

1. `.claude/rules/tonality.md` — repository tone and communication policy
2. `.claude/rules/general-code-change.md` — baseline code change rules
3. `.claude/rules/general-unit-test.md` — baseline unit test rules
4. Language-specific rules based on files in scope:
   - Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
   - PowerShell: `.claude/rules/powershell.md`
   - TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
   - C#: `.claude/rules/csharp.md`
   - GitHub Actions: `.claude/rules/ci-workflows.md`

The policy source is the rule source set under `scripts/harness-generation/sources/rules/`. The Claude rules `.claude/rules/*.md` and the Copilot instructions `.github/instructions/*.instructions.md` are generated outputs of `scripts/harness-generation/Invoke-HarnessGeneration.ps1`. Change a policy by editing its source and running the generator; do not edit a generated rule or instruction file by hand.

## Language-Specific Rules

Path-scoped language rules are loaded automatically from `.claude/rules/`:

- `.claude/rules/python.md` — Python toolchain and coding standards
- `.claude/rules/powershell.md` — PowerShell toolchain and coding standards
- `.claude/rules/typescript.md` — TypeScript toolchain and coding standards
- `.claude/rules/csharp.md` — C# toolchain and coding standards

Each rule file uses YAML frontmatter with a `paths:` field to scope activation to the relevant file extensions. Consult the applicable rule file when working with files matching its path pattern.

## Architecture

This repository uses a four-layer Claude Code runtime architecture that maps the existing Copilot orchestration model onto Claude-native primitives:

1. **Standing Instructions** — `CLAUDE.md` (this file, which imports `AGENTS.md`) and `.claude/rules/*.md` provide persistent policy context. `AGENTS.md` carries the repository-wide tone and shared guidance; `CLAUDE.md` carries the Claude policy-compliance order and architectural context. Rule files carry language-specific toolchain and coding standards, scoped by file path.

2. **Skills** — `.claude/skills/<name>/SKILL.md` files define reusable, user-invocable workflows. Skills are the primary entry point for direct-use operations such as orchestration, commit message generation, PR authoring, and research. Each skill declares its own `allowed-tools`, `context`, and `agent` routing in YAML frontmatter.

3. **Subagents** — `.claude/agents/*.md` files define named specialist personas. Each subagent declares its `tools` allowlist, `model`, preloaded `skills`, `hooks`, and `memory` scope in YAML frontmatter. Subagents are delegated to by the orchestrator or by skills that use `context: fork` with an `agent:` reference.

4. **Enforcement** — `.claude/settings.json` defines project-level `permissions` (allow/deny lists for tools, paths, and patterns). `.claude/hooks/` contains scripts invoked by `PreToolUse` and `SubagentStop` hooks to enforce dangerous-command blocking and completion-gate validation.

The `.claude/` directory is the standalone runtime surface for Claude Code. Skills, agents, and rules under `.claude/` are self-contained and do not require reading from `.github/` at runtime. The `.github/` directory contains the parallel Copilot-native customization surface.

The orchestration checkpoint path for this runtime is `artifacts/orchestration/orchestrator-state.json`. The main session reads `artifacts/orchestration/orchestrator-state.json` before worker delegation and updates the same file across phase transitions. Orchestrator-state checkpoint enforcement ahead of PR authoring is performed by a local `pwsh` PreToolUse hook (`.claude/hooks/enforce-pr-author-skill.ps1`), not a CI workflow.
