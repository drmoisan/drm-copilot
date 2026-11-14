# Preflight Fixes (Stage B)

Timestamp: 2026-10-30T23-54
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md

Scope: trivial defects fixed in place in task text only. No task was added, removed or reordered. Substantive defects are returned to the planner in the preflight signal and are not listed here.

## Fixes

1. [P0-T3] | stale path (partial pathspec) | `src/migrate-development-docs-cli.ts` replaced with the full repository-relative path `extensions/drm-copilot/src/migrate-development-docs-cli.ts`.
2. [P5-T8] | stale path | `CHANGELOG.md` replaced with `extensions/drm-copilot/CHANGELOG.md`; the repository has no root `CHANGELOG.md` (verified with `git ls-files`).
3. [P8-T14] | literal inconsistency | OQ-13 has no `global_decisions` key and therefore no `BRANCH-OQ-13` line from [P1-T1]; the task now names the `DECISIONS` `decisions` entry count as the OQ-13 row value, so the thirteen-row table can be filled without a blank.
4. [P3-T4] | task text and acceptance disagreement | the task text allowed only `R100` or absence, while the acceptance counts `M` and inexact `R` lines; the task text now also allows an `A` line for an excluded file first added on this branch after `BASE` (this feature's plans), matching the acceptance condition. The asserted condition (zero `M` and zero inexact `R` lines for excluded files) is unchanged.
5. [P1-T4] | evidence kind | `digest-comparison.<timestamp>.md` moved from `evidence/other/` to `evidence/baseline/`, because spec "Acceptance Criteria" -> "Stage B" requires the fresh-dry-run digest equality to be recorded in a gate artifact under `<FEATURE>/evidence/baseline/`. The content asserted (both digests and `MATCH`) is unchanged.

## Validation

- Branch-current validator (`scripts.dev_tools.validate_orchestration_artifacts plan`): passed before the fixes.
- MCP validator (`validate_orchestration_artifacts`, `artifact_type: plan`): passed before the fixes; re-run after the fixes.
