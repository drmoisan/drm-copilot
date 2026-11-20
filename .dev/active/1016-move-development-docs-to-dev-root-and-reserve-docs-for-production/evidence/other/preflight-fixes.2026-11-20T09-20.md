# Preflight Fixes (stage B, revision of 2026-11-20)

Timestamp: 2026-11-20T09-20
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned to the planner; they are not recorded here)

## Fixes

1. `## Terms and Defined Sets`, `FROZEN_SURFACES` | stale fact in a definition | The sentence "both are harness-generator outputs" was replaced. `config/harness-parity-matrix.json` records `claude:agent:epic-orchestrator` as `generated` (from `scripts/harness-generation/sources/agents/epic-orchestrator.json`) and `claude:skill:epic-orchestrate` as `native`. The new text states that the agent is a generator output, that the skill is a `native` entry whose `.agents` copy and bundle copies the existing glob `**/skills/epic-orchestrate/SKILL.md` covers, and that both, together with the agent's generator family, belong to `REWRITE_EXCLUSIONS` member 8. No asserted value, task, file set or exclusion glob changed.

## Validation

Command: env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: plan validation passed (run before and after the fix).
