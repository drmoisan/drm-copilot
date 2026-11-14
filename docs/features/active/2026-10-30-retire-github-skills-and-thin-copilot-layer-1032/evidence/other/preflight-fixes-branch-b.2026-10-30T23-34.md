# Preflight Fixes - Agents Branch B Plan

Timestamp: 2026-10-30T23-34
Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan-agents-branch-b.md
Mode: preparation-mode preflight (no task executed, no checkbox changed)

## Fixes

1. [P0-T3] | missing check step for an assigned assumption | The Upstream Assumptions table assigns UB-2 (`GithubAgentsTarget: no`) to P0-T3, but the task text named only the UB-3 and UB-4 checks. Added: read `GithubAgentsTarget` from the lexicographically greatest `<FEATURE>/evidence/baseline/phase0-upstream-child3.*.md`. The acceptance condition is unchanged.
2. [P1-T1] | evidence derivation not stated | `<E3 result file name>` is now derived mechanically: the file name of the E3 result path recorded in the lexicographically greatest `<FEATURE>/evidence/other/agents-branch-selection.*.md`. The asserted value is unchanged.
3. [P1-T3] | literal-formatting clarification | Several prompt `agent:` values (for example `'agent'`, `'prd_creator'`) and agent `name:` values (for example `"Task Researcher Instructions"`) are quoted in the tree. Added: values are compared after removing surrounding single or double quotes. The zero-unresolved assertion is unchanged; every current binding resolves under this comparison (checked against `.github/prompts/**/*.prompt.md` and the `handoffs:` blocks in `.github/agents/*.agent.md`).

## Validation

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`): ok.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: `plan validation passed`, exit 0.
