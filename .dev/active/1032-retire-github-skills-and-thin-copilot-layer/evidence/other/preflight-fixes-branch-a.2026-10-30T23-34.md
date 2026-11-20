# Preflight Fixes — Agents Branch A Plan

Timestamp: 2026-10-30T23-34
Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan-agents-branch-a.md

## Fixes

1. [P1-T3] | literal-formatting (validator-blind) | Added "comparing binding and `name:` values after removing surrounding single or double quotes". Reason: prompt `agent:` values are quoted in the tree (for example `agent: 'prd_creator'` in `.github/prompts/breakdown-feature-prd.prompt.md`) and several `name:` values are quoted (for example `name: "prd_creator"` in `.github/agents/prd.agent.md`, `name: 'Thinking Beast Mode'`); a literal comparison would report resolvable bindings as unresolved. The asserted outcome (zero unresolved bindings) is unchanged.
2. [P2-T4] | evidence derivation (validator-blind; executor must not select the comparison base) | Stated the derivation of "changed since the main plan's self-review": `git diff --name-status` from the commit that added the self-review path recorded by P0-T2 to `HEAD`, together with `git status --porcelain`. The asserted outcome (no file outside `config/harness-parity-matrix.json` and `<FEATURE>/` changed) is unchanged.

## Validation

- MCP `validate_orchestration_artifacts` (`plan`): ok before the fixes.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: passed after the fixes (see return).
