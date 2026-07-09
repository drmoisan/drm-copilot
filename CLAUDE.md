---
description: Standing instructions for Claude Code sessions in this repository.
---

# CLAUDE.md

## Tone Policy

Use a strictly professional, factual, and neutral tone in all responses.

- Be concise, direct, and literal.
- Do not use jokes, humor, metaphors, playful analogies, banter, emojis, GIF references, sarcasm, or conversational filler.
- Do not use motivational hype, celebratory phrasing, or grandiose narration.
- If a sentence could read as casual, playful, or informal, rewrite it in neutral business language.

The full tone policy is defined in `.github/copilot-instructions.md` and `.github/instructions/tonality.instructions.md`. Those files are authoritative.

## Policy Compliance Reading Order

Before performing any code or test changes, read the following policy files in this order:

1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules
4. Language-specific policies based on files in scope:
   - Python: `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`
   - PowerShell: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`
   - TypeScript: `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`
   - C#: `.github/instructions/csharp-code-change.instructions.md`, `.github/instructions/csharp-unit-test.instructions.md`
   - GitHub Actions: `.github/instructions/github-actions.instructions.md`

These files are the canonical policy source. Do not modify them. `.claude/` files mirror or reference their content.

## Language-Specific Rules

Path-scoped language rules are loaded automatically from `.claude/rules/`:

- `.claude/rules/python.md` — Python toolchain and coding standards
- `.claude/rules/powershell.md` — PowerShell toolchain and coding standards
- `.claude/rules/typescript.md` — TypeScript toolchain and coding standards
- `.claude/rules/csharp.md` — C# toolchain and coding standards

Each rule file uses YAML frontmatter with a `paths:` field to scope activation to the relevant file extensions. Consult the applicable rule file when working with files matching its path pattern.

## Architecture

This repository uses a four-layer Claude Code runtime architecture that maps the existing Copilot orchestration model onto Claude-native primitives:

1. **Standing Instructions** — `CLAUDE.md` (this file) and `.claude/rules/*.md` provide persistent policy context. `CLAUDE.md` carries repository-wide tone, policy-compliance order, and architectural context. Rule files carry language-specific toolchain and coding standards, scoped by file path.

2. **Skills** — `.claude/skills/<name>/SKILL.md` files define reusable, user-invocable workflows. Skills are the primary entry point for direct-use operations such as orchestration, commit message generation, PR authoring, and research. Each skill declares its own `allowed-tools`, `context`, and `agent` routing in YAML frontmatter.

3. **Subagents** — `.claude/agents/*.md` files define named specialist personas. Each subagent declares its `tools` allowlist, `model`, preloaded `skills`, `hooks`, and `memory` scope in YAML frontmatter. Subagents are delegated to by the orchestrator or by skills that use `context: fork` with an `agent:` reference.

4. **Enforcement** — `.claude/settings.json` defines project-level `permissions` (allow/deny lists for tools, paths, and patterns). `.claude/hooks/` contains scripts invoked by `PreToolUse` and `SubagentStop` hooks to enforce dangerous-command blocking and completion-gate validation.

The `.claude/` directory is the standalone runtime surface for Claude Code. Skills, agents, and rules under `.claude/` are self-contained and do not require reading from `.github/` at runtime. The `.github/` directory contains the parallel Copilot-native customization surface.

The orchestration checkpoint path for this runtime is `artifacts/orchestration/orchestrator-state.json`. The main session reads `artifacts/orchestration/orchestrator-state.json` before worker delegation and updates the same file across phase transitions. Orchestrator-state checkpoint enforcement ahead of PR authoring is performed by a local `pwsh` PreToolUse hook (`.claude/hooks/enforce-pr-author-skill.ps1`), not a CI workflow.
