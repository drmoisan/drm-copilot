# AGENTS.md

Hand-authored standing guidance for every agent that works in this repository. Codex reads this file natively, and `CLAUDE.md` imports it with `@AGENTS.md` and adds Claude-only instructions. Edit this file directly; no tool generates it. Its bundle copy, `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`, is kept byte-identical.

## Tone Policy

Use a strictly professional, factual, and neutral tone in all responses and in every authored file.

- Be concise, direct, and literal.
- Do not use jokes, humor, metaphors, playful analogies, banter, emojis, GIF references, sarcasm, or conversational filler.
- Do not use motivational hype, celebratory phrasing, or grandiose narration.
- If a sentence could read as casual, playful, or informal, rewrite it in neutral business language.

The full tone rules are stated in `.agents/skills/tonality/SKILL.md` for Codex, `.claude/rules/tonality.md` for Claude Code, and `.github/instructions/tonality.instructions.md` for GitHub Copilot.

## Policy Rule Skills

Before changing code or tests in a Codex session, read these rule skills in order:

1. `.agents/skills/general-code-change/SKILL.md` — baseline code change rules.
2. `.agents/skills/general-unit-test/SKILL.md` — baseline unit test rules.
3. The language rule skill for the files in scope: `.agents/skills/python/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/typescript/SKILL.md`, or `.agents/skills/csharp/SKILL.md`; for GitHub Actions workflows, `.agents/skills/ci-workflows/SKILL.md`.

The Codex rule skills, the Claude rules under `.claude/rules/`, and the Copilot instructions under `.github/instructions/` state the same policies for their tools. Their source is the rule source set under `scripts/harness-generation/sources/rules/`.

## Mandatory Toolchain Loop

Run the toolchain of each language in scope in a fixed order: formatting, linting, type checking where the language has a type checker, the architecture-boundary and contract checks the repository defines, and testing. `.agents/skills/general-code-change/SKILL.md` names the stages and the tool for each language.

**Restart from step 1** whenever a step fails or rewrites a file, and finish only after one clean pass of every step.

This loop is the phase-gate and final-QA requirement; integration tests run in CI for phase gates and the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## File Size Limit

The file-size tiers for production code, test code, and reusable script files are stated in `## File Size Limit` of `.agents/skills/general-code-change/SKILL.md`. Legacy files above the hard limit are listed in `config/file-size-baseline.json`.

## Harness Sources and Generated Files

The repository keeps one customization surface per tool: `.agents/skills/` and `.codex/` for Codex, `.claude/` for Claude Code, and `.github/` for GitHub Copilot. Each surface has a bundle copy under `extensions/drm-copilot/resources/` that the extension pushes down to destination repositories.

Surfaces that two tools share are generated from one source by `scripts/harness-generation/Invoke-HarnessGeneration.ps1`, and `config/harness-parity-matrix.json` records which file is generated, shared, or native to one tool. Change a generated file by editing its source and running the generator; a hand edit to a generated file is reported as drift by `-Check`.

## Codex Epic Planning and Model Routing

The Codex main session has no default orchestrator agent. Use the native skills
as explicit entry points:

- `epic-plan` delegates master scoping and complete preparation through preflight
  to the `epic-planner` agent.
- `epic-run` executes a prepared epic from the committed
  `docs/features/epics/<slug>/epic-kickoff.md` artifact.
- `epic-orchestrate` executes a valid manually authored epic manifest.

The ordinary `orchestrator` must not invoke either epic persona. Both epic
personas delegate to child orchestrators, so epic entry requires main-session
provenance and is enforced by Codex hooks and completion validators.

Production-file count selects the engineer/orchestrator topology. C1-C4
complexity, execution context, and the monotonic orchestration ceiling select an
exact generated Codex agent profile through `codex-model-routing`. The canonical
policy is `config/orchestration-routing.json`; deterministic topology receipts,
exact model slugs, and model-routing receipts must be persisted before
delegation. Silent model fallback is prohibited.

Planning and execution use separate durable checkpoints:

- `artifacts/orchestration/epic-planner-state.json`
- `artifacts/orchestration/epic-orchestrator-state.json`
