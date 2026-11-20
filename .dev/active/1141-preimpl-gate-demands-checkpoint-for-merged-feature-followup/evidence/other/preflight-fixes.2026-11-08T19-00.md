# Preflight Fixes

Timestamp: 2026-11-08T19-00
Plan: docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141/plan.2026-11-08T13-26.md

## Fixes

1. [P1-T1] | literal clarity (row form) | The sibling-prefix row `docs/features/active/2026-09-25-child-a-901-x/y.md` now states that it uses the `-F` commit form. A Write of a path under `docs/features/active/` is not classified as implementation by `Test-ImplementationPath` (via `Test-FeatureDocumentationOrEvidencePath`), so a Write-form row would be allowed before and after the fix and could not assert `deny`. The intent (the folder rows use the `-F` form) was already stated; the edit removes the ambiguity.
2. [P4-T2] | changed existing behavior without named asserting tests | Added the two existing tests that assert the edited `.claude/skills/orchestrate/SKILL.md` text, each with its disposition: `test_orchestrate_skill_carries_matching_child_side_statement` (caps the `## Epic Mode Bounded Return` body at 10 non-blank lines via `CHILD_SIDE_MAX_BODY_LINES`; the body has 6 today, so the pointer paragraph must fit in 4) and `test_orchestration_skills_carry_the_linkage_and_current_mirrors` (byte equality with the bundle mirror). The acceptance condition is unchanged.

## Validation

- Branch-current Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exited 0 before and after the fixes.
