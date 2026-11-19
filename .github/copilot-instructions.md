# Copilot-only instructions

- Shared standing instructions, including the tone policy, live in `AGENTS.md`, which GitHub Copilot reads; this file does not repeat them.
- Shared skills live in `.agents/skills/<name>/SKILL.md`, which GitHub Copilot reads natively.
- Path-scoped Copilot instructions live in `.github/instructions/*.instructions.md` and are generated from their shared rule sources.
- Direct-use prompts live natively in `.github/prompts`, and the handoff-bearing Copilot agents live natively in `.github/agents`; neither has a shared equivalent.
- Copilot hook registrations live natively in `.github/hooks`.
