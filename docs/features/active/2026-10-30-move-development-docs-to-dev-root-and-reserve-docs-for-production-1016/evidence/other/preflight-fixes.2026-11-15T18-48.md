# Preflight Fixes — Stage B plan, confirming round after the OD-2 planner revision

Timestamp: 2026-11-15T18-48
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md
Command: env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>; MCP validate_orchestration_artifacts (artifact_type plan)
EXIT_CODE: 0
Output Summary: both validators pass after the fix below; the plan keeps 40 canonical tasks within the legacy 40/400 pair of this pre-cutoff plan stamp and its `## Size Justification` section. No substantive defect remains.

## Confirmation of the two defects of `preflight-fixes.2026-11-14T20-53.md`

1. [P3-T4] (CES-TEMPLATES-BYTE-IDENTICAL): resolved. `FT_BYTE_PAIRS` names the epic template bundle copy (`CES-TEMPLATES-BYTE-IDENTICAL` compares SHA-256 digests of `docs/features/templates/epic/epic.md` and its bundle copy) and the three plan template copies (`test_plan_templates_carry_premortem_skeleton` compares bytes). A search of `tests` and `extensions/drm-copilot/test` for `feature-templates` found no other byte or hash comparison: the `test-cadence-wording.Tests.ps1` template rows are wording checks and its byte rows cover no template; `DocumentationEstateOnboarding.Tests.ps1` reads bundle text for a digest scan only. The epic source holds a `docs/features/active/` comment, as the plan states. Member 11 of `REWRITE_EXCLUSIONS`, the `## Execution Preconditions` decision-file bullet, the `## Existing Tests Asserting Changed Behavior` row and the [P3-T4] acceptance are consistent.
2. [P3-T10] (preflight-fix-record sentence): resolved. Only `.claude/skills/atomic-plan-contract/SKILL.md` and its bundle copy carry the sentence ending "path under `docs/features/`."; the `.agents` and `.github` copies and their bundle copies carry only the `preflight-fix-record: <path>` bullet. No test and no ledger patch holds the sentence. `.claude/hooks/validate-executor-output.ps1` on this branch tests the `docs/features/` prefix only, and child 2 plan [P6-T6] routes that prefix test to the union. The task edits the sentence inside the `reduction: 0008` commit and records `UPDATED` or `NOT_PRESENT` per copy.
3. No stage B task cites resolver wiring for `Get-BlastRadius` or `derive_blast_radius`.

## Fixes (task text and preamble only; no task added, removed or reordered)

1. [P1-T3] and `## Existing Tests Asserting Changed Behavior` | missing test row for behavior an existing task owns (#1035 OD-P4 follow-through) | Child 2 spec OD-P4 (on the integration branch; not yet on this branch) keeps the no-root default of `Get-BlastRadius` and `derive_blast_radius` at `docs/features` with no resolver call, and stage B passes no root. Bare-folder cases such as the `Get-BlastRadius` case in `BlastRadius.Tests.ps1` that expects `docs/features/active/2026-08-07-parallel-blast-radius-447/**`, and the `test_compute_blast_radius.py` cases that expect `docs/features/active/empty-feature/**`, would be prefix-rewritten by the tool to `.dev/active/...` while the production default stays `docs/features`, so they would fail after the apply. The class definitions of [P1-T3] named no class for a no-root production default, so the executor could classify them `H` and stop. The fix widens class `A` to include that default (disposition `exclude`, unchanged), names the four derivation suites as [P1-T3] rows, and adds their disposition row. Classification: trivial under the #1016 round 1 precedent for a missing test row whose behavior an existing task already owns ([P1-T3] owns the classification and member 9 is derived from it); recorded here for orchestrator review.

## Observation (not a defect of this plan)

- After the flip, a caller that passes a bare folder name to `Get-BlastRadius` or `derive_blast_radius` still receives a `docs/features/active/<folder>/**` glob, because child 2 spec OD-P4 defers resolver wiring for blast radius. A qualified `.dev/active/<folder>` value passes through child 2's union prefix. The #1016 spec states no rule for the derivation default, so no stage B task is required; the deferred wiring belongs to a later item.

Each fix keeps the meaning of the acceptance it supports and was checked against the tonality and evidence rules the plan enforces.
