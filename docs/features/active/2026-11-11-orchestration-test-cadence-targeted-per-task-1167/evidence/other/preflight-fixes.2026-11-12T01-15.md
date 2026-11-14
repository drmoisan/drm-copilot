# Preflight Fixes

Timestamp: 2026-11-12T01-15
Plan: docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/plan.2026-11-11T19-25.md
Command: env -u VIRTUAL_ENV poetry -C <item worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan-path>
EXIT_CODE: 0
Output Summary: plan validation passed before and after the fixes below (branch Python CLI, G1 to G13).

## Fixes

1. `## Terms and Standing Rules`, Commits bullet | omitted format requirement | added that the orchestrator's single commit carries the subject token `reduction: 0011`, which `## Entry Format` of `docs/engineering/process-reductions/README.md` requires of a reduction's commit. No task or assertion changed.
2. [P1-T10] | clarification of an existing rule | the revert-block clause now names the four bundle-only csharp-legacy variants of [P1-T4] and every `.agents` or `.github` skill copy that differs from its `.claude` skill as non-identical sources. `Get-ProcessReductionDerivedSource` in `scripts/dev-tools/ProcessReductionChain.psm1` treats such paths as sources, so they already required blocks under the existing wording. No task or assertion changed.
