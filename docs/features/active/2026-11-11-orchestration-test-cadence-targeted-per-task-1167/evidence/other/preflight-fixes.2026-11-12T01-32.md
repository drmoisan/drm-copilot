# Preflight Fixes (Round 2)

Timestamp: 2026-11-12T01-32
Plan: docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/plan.2026-11-11T19-25.md
Command: env -u VIRTUAL_ENV poetry -C <item worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan-path>
EXIT_CODE: 0
Output Summary: plan validation passed before and after the fixes below (branch Python CLI, G1 to G13); the installed MCP validator also returned ok. A scratch snapshot of the plan taken before the fixes is held under SCRATCH.

## Fixes

1. [P1-T5] | anchor clarification | the Copilot executor clause now states that the `If the repo policy requires a toolchain loop` bullet of `### 3.4 Verification (mandatory before check-off)` is replaced in all four Copilot executors. That token is one of the seven `TCW-SWEEP-SURFACES` tokens of [P1-T9], which has no exclusions, and the bullet is present in all four files and their bundles, so the existing sweep assertion already required its removal. No task or assertion changed.
2. [P1-T5] | citation correction | the `Required toolchain for <language> tasks:` label is cited in `### 7.1 <Language> policy and toolchain gates` of the three language executors, where it sits, rather than read as part of `### 3.4`. No task or assertion changed.
3. [P1-T5] | citation correction | the unchanged `PREFLIGHT VALIDATION GATE` list is attributed to the two execute prompts; `.github/codex/resume-hard-lock.prompt.md` has no such list. No task or assertion changed.
