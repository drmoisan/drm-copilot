# Converted standing guidance

Merged standing-guidance sources:
- `general-code-change.md`
- `general-unit-test.md`
- `tonality.md`
- `AGENTS.md`

## Source: `general-code-change.md`

# Converted standing guidance

Applied rewrites:
- None

---
paths:
  - "**"
description: Cross-language code change policy. Applies to all files.
---

# General Code Change Policy

This rule file summarizes the cross-language code change policy for this repository.

## Design Principles

Apply these priorities in order when designing or changing code:

1. **Simplicity first** — Prefer the simplest design that works and is readable. Avoid cleverness and deep indirection.
2. **Reusability** — Factor out logic that is clearly reusable. Avoid copy-paste; share behavior via composition or helper methods.
3. **Extensibility** — Design public APIs so they can be extended without breaking callers. Prefer keyword-style parameters with defaults. Prefer composition over inheritance. Use interfaces/abstract types/protocols to support multiple implementations.
4. **Separation of concerns** — Keep pure logic (transforms, calculations, parsing) separate from I/O (disk, network, DB), UI/CLI, and framework-specific glue.

## Classes, Functions, and APIs

- Create a class when: there is a clear domain concept with data + behavior, state and invariants must travel together, multiple implementations behind an interface are expected, or a multi-step workflow shares context.
- Create a standalone function when: the operation is pure, stateless, and simple; it is a small helper that does not naturally belong on a domain class; or it is a simple transformation from inputs to outputs.
- Keep methods small and focused. Avoid god objects.
- Use interfaces/abstract types/protocols when multiple implementations are likely.

## Mandatory Toolchain Loop

Run the full toolchain in this exact order and repeat until all steps pass in a single pass:

1. **Formatting** (e.g., Black, Prettier, CSharpier, Invoke-Formatter)
2. **Linting** (e.g., Ruff, ESLint, PSScriptAnalyzer, .NET analyzers)
3. **Type checking** (e.g., Pyright, TSC, nullable analysis; skip for PowerShell)
4. **Testing** (e.g., Pytest, Jest, MSTest, Pester)

**Restart from step 1** if any step fails or auto-fixes any files. Do not stop the loop until all four steps complete without errors in a single pass.

## File Size Limit

- No production code, test code, or reusable script file may exceed **500 lines**.
- Exceptions: temporary throwaway scripts created and deleted within an agent session; raw text fixtures for language-processing test data; Markdown documentation files.

## Error Handling and Logging

- **Fail fast and explicitly**: raise or return clear, specific errors when invariants are violated.
- Do not silently ignore errors. Do not use broad catch-all handlers unless you immediately re-raise or propagate with added context.
- Use the project's established logging pattern. Log at appropriate levels (`debug`, `info`, `warning`, `error`).
- Enforce invariants at construction/initialization time.
- Use assertions only for internal sanity checks, not user-facing error handling.

## Naming

- Names must be descriptive. Abbreviations are acceptable only when they are standard (`id`, `url`, `db`).
- Language-specific conventions: `snake_case` for Python functions/variables, `PascalCase` for Python classes, `camelCase` for TypeScript/C# locals, `PascalCase` for TypeScript/C# types and public members.

## Public APIs and Compatibility

- Prefer keyword-style parameters with defaults.
- Prefer composition over inheritance when possible.
- Avoid breaking public APIs. If a breaking change is necessary, update all callers in-repo and call it out clearly in the change description.

## Dependencies

- Use only libraries already approved in the project unless explicitly told to add more.
- If adding a dependency is unavoidable, choose a well-maintained, widely used package and document why it is required.

## I/O Boundaries

- Isolate I/O (disk, network, APIs) into specific classes or modules.
- Core domain logic must be testable without touching the network or filesystem.
- Use of temporary files within tests is strictly prohibited.

## Source: `general-unit-test.md`

# Converted standing guidance

Applied rewrites:
- None

---
paths:
  - "**"
description: Cross-language unit test policy. Applies to all files.
---

# General Unit Test Policy

This rule file summarizes the cross-language unit test policy for this repository.

## Core Principles

Every unit test must satisfy all five of these properties:

1. **Independence** — Tests must be able to run in any order without impacting each other.
2. **Isolation** — Each unit test targets a single function, method, or unit of behavior so failures clearly identify the faulty unit.
3. **Fast execution** — Tests must be fast enough to support frequent runs and rapid feedback loops.
4. **Determinism** — Given the same inputs and environment, tests must produce the same results. Avoid flakiness.
5. **Readability and maintainability** — Test names, structure, and assertions must be clear and easy to understand.

## Coverage Requirements

- **Repository-wide line coverage must remain >= 80%.**
- **Any new module, class, or method must target >= 90% coverage.**
- Code changes or refactors must not reduce coverage for the lines that were changed.
- Coverage is a supporting metric, not the sole quality gate. Untested critical behavior is not acceptable even if the overall percentage looks good.
- Configure coverage tooling to exclude test files (e.g., `tests/`) so metrics reflect application code, not tests.

## Scenario Completeness

For each unit or behavior, tests must cover:

- Positive flows with valid inputs
- Negative flows for invalid or missing inputs
- Edge cases and boundary conditions
- Error-handling behavior
- Concurrency behavior when relevant
- State transitions for stateful components

## Test Structure — Arrange–Act–Assert

Organize each test into three sections:

- **Arrange** — set up inputs, environment, and dependencies
- **Act** — execute the behavior under test
- **Assert** — verify outcomes via assertions

Assertions must produce clear, actionable failure messages.

## External Dependencies

- Unit tests must not depend on external services (databases, networks, remote APIs, external processes).
- Use mocks, stubs, or fakes to isolate the unit under test when code interacts with external systems.
- **Creation and use of temporary files in tests is strictly prohibited.**
- Tests must not rely on mutable global state or external configuration that can change between runs.

## Documentation

- Each test must clearly communicate its purpose via a descriptive name and/or a short docstring or comment summarizing the scenario and expected outcome.
- Group related tests logically within the same file or test class.

## Source: `tonality.md`

# Converted standing guidance

Applied rewrites:
- None

---
paths:
  - "**"
description: Required communication tone policy. Applies to all files and responses.
---

# Tonality Policy

This rule file summarizes the required tone policy for all agent-authored content in this repository.

## Required Professional Tone

All written output must use a professional tone. Professional tone means:

- Clear, direct, and factual language.
- Neutral businesslike phrasing.
- Measured statements that match the available evidence.
- Concise explanations that prioritize clarity over personality.
- Respectful wording, even when reporting defects, regressions, or disagreements.

Preferred characteristics: specific rather than vague; literal rather than theatrical; calm rather than excited; precise rather than promotional.

## Humor and Joking — Prohibited

Do not use jokes, banter, playful remarks, sarcasm, puns, or comedic phrasing.

This prohibition includes:
- Lighthearted commentary intended to entertain.
- Winking or self-aware jokes about tools, code, bugs, or the development process.
- Casual filler that weakens a formal or operational message.
- Mocking, teasing, or exaggerated "fun" framing, even when mild.

When deciding between a playful sentence and a plain sentence, use the plain sentence.

## Hyperbole — Prohibited

Do not use hyperbolic, inflated, or sensational language. Avoid:

- Claims that something is perfect, flawless, amazing, incredible, revolutionary, or world-class (unless directly quoting an authoritative source and clearly marking it as a quotation).
- Overstated certainty that goes beyond the verified evidence.
- Dramatic framing that overstates urgency, difficulty, simplicity, risk, or impact.

Use measured alternatives: replace absolute praise with evidence-based descriptions; replace dramatic warnings with specific risks and consequences; replace sweeping claims with concrete observations.

## Metaphors — Tightly Restricted

Metaphor, analogy, and figurative language are not the default style. They may be used only when ALL of the following are true:

1. The metaphor is strictly utilitarian.
2. It is required to explain a technical concept that would otherwise be less clear.
3. It improves accuracy or comprehension for the intended audience.
4. It is brief, literal in effect, and not decorative.

If a concept can be explained clearly without metaphor, do not use metaphor.

## Evidence-First Wording

Match the strength of the wording to the strength of the evidence:

- If something was verified, say it was verified and state how.
- If something is likely but unconfirmed, say that it is likely or appears to be the case.
- If something is unknown, say that it is unknown.
- Do not imply certainty, completion, safety, or correctness without support.

## Difficult Messages

When reporting failures, defects, or policy violations:
- State the issue directly.
- Describe the impact without dramatizing it.
- Identify the next corrective action when available.
- Avoid blame-oriented or emotionally charged wording.

When giving recommendations:
- Prefer imperative, concrete language.
- Explain the rationale briefly when it is not obvious.
- Avoid motivational language, sales language, or celebratory phrasing.

## Final Rule

When tone is uncertain, choose the more restrained phrasing. The repository default is professionalism, clarity, and accuracy — not entertainment, flourish, or hype.

## Source: `AGENTS.md`

# Converted standing guidance

Applied rewrites:
- Rewrite merged standing-guidance source paths to the native AGENTS.md target.
- Rewrite GitHub Copilot standing guidance paths to AGENTS.md.
- Rewrite GitHub Copilot path-scoped instructions to shared skill paths.
- Rewrite Claude settings paths to Codex config paths.
- Rewrite Claude rule paths to shared skill paths.
- Rewrite Claude rules-directory references to the native skill root.
- Rewrite Claude skill-directory references to the native skill root.
- Rewrite Claude agent-directory references to the native agent root.
- Rewrite Claude hook-directory references to the native hook root.

---
description: Standing instructions for Claude Code sessions in this repository.
---

# AGENTS.md

## Tone Policy

Use a strictly professional, factual, and neutral tone in all responses.

- Be concise, direct, and literal.
- Do not use jokes, humor, metaphors, playful analogies, banter, emojis, GIF references, sarcasm, or conversational filler.
- Do not use motivational hype, celebratory phrasing, or grandiose narration.
- If a sentence could read as casual, playful, or informal, rewrite it in neutral business language.

The full tone policy is defined in `AGENTS.md` and `.agents/skills/tonality/SKILL.md`. Those files are authoritative.

## Policy Compliance Reading Order

Before performing any code or test changes, read the following policy files in this order:

1. `AGENTS.md` — repository tone and communication policy
2. `.agents/skills/general-code-change/SKILL.md` — baseline code change rules
3. `.agents/skills/general-unit-test/SKILL.md` — baseline unit test rules
4. Language-specific policies based on files in scope:
   - Python: `.agents/skills/python-code-change/SKILL.md`, `.agents/skills/python-unit-test/SKILL.md`
   - PowerShell: `.agents/skills/powershell-code-change/SKILL.md`, `.agents/skills/powershell-unit-test/SKILL.md`
   - TypeScript: `.agents/skills/typescript-code-change/SKILL.md`, `.agents/skills/typescript-unit-test/SKILL.md`
   - C#: `.agents/skills/csharp-code-change/SKILL.md`, `.agents/skills/csharp-unit-test/SKILL.md`
   - GitHub Actions: `.agents/skills/github-actions/SKILL.md`

These files are the canonical policy source. Do not modify them. `.claude/` files mirror or reference their content.

## Language-Specific Rules

Path-scoped language rules are loaded automatically from `.agents/skills/`:

- `.agents/skills/python/SKILL.md` — Python toolchain and coding standards
- `.agents/skills/powershell/SKILL.md` — PowerShell toolchain and coding standards
- `.agents/skills/typescript/SKILL.md` — TypeScript toolchain and coding standards
- `.agents/skills/csharp/SKILL.md` — C# toolchain and coding standards

Each rule file uses YAML frontmatter with a `paths:` field to scope activation to the relevant file extensions. Consult the applicable rule file when working with files matching its path pattern.

## Architecture

This repository uses a four-layer Claude Code runtime architecture that maps the existing Copilot orchestration model onto Claude-native primitives:

1. **Standing Instructions** — `AGENTS.md` (this file) and `.agents/skills/*.md` provide persistent policy context. `AGENTS.md` carries repository-wide tone, policy-compliance order, and architectural context. Rule files carry language-specific toolchain and coding standards, scoped by file path.

2. **Skills** — `.agents/skills/<name>/SKILL.md` files define reusable, user-invocable workflows. Skills are the primary entry point for direct-use operations such as orchestration, commit message generation, PR authoring, and research. Each skill declares its own `allowed-tools`, `context`, and `agent` routing in YAML frontmatter.

3. **Subagents** — `.codex/agents/*.md` files define named specialist personas. Each subagent declares its `tools` allowlist, `model`, preloaded `skills`, `hooks`, and `memory` scope in YAML frontmatter. Subagents are delegated to by the orchestrator or by skills that use `context: fork` with an `agent:` reference.

4. **Enforcement** — `.codex/config.toml` defines project-level `permissions` (allow/deny lists for tools, paths, and patterns). `.codex/hooks/` contains scripts invoked by `PreToolUse` and `SubagentStop` hooks to enforce dangerous-command blocking and completion-gate validation.

The `.claude/` directory is the standalone runtime surface for Claude Code. Skills, agents, and rules under `.claude/` are self-contained and do not require reading from `.github/` at runtime. The `.github/` directory contains the parallel Copilot-native customization surface.

The orchestration checkpoint path for this runtime is `artifacts/orchestration/orchestrator-state.json`. The main session reads `artifacts/orchestration/orchestrator-state.json` before worker delegation and updates the same file across phase transitions.

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
