# Preflight Fixes - Remediation Plan Cycle 1

Timestamp: 2026-11-07T17-44
Plan: docs/features/active/2026-10-30-docs-authoring-workflow-1037/remediation-plan.2026-11-07T17-30.md

Single-pass preflight over every phase, task and prose region of the plan. One trivial defect was found and fixed in place in task text; no substantive defect was found. No task was added, removed or reordered.

## Fix 1 - [P1-T2]

- Defect class: unsatisfiable literal scope whose intent is unambiguous (validator-blind; stale premise about the file).
- Observation: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is not sorted as a whole on either parent. An ordinal adjacent-pair check (SCRATCH/issue_1037_inversions.py) reports 96 inversions at the merge base, and both the branch head and the integration tip are likewise unsorted (ordinal and case-folded). The task text described "the file's existing ascending path order" and the acceptance asserted "its entries are in ascending order", which no resolution can satisfy.
- Intent preserved: the task itself states the intended placement (`enforce-docs-role-write-scope.ps1` precedes `enforce-epic-merge-gate-review.ps1`); both sides insert after `.claude/hooks/enforce-docs-complete-gate-target.ps1`.
- Change made: the task text now reads "the file's existing path order (both sides insert after `.claude/hooks/enforce-docs-complete-gate-target.ps1`) ... in ascending order"; the acceptance now asserts that the resolved paths are the union of both parents' paths with each parent's relative order preserved, and that the two entries sit in ascending order between `.claude/hooks/enforce-docs-complete-gate-target.ps1` and `.claude/hooks/enforce-epic-wave-barrier.ps1`. The JSON parse, CR-byte, conflict-marker and exactly-once conditions are unchanged.

## Checks with no defect

- Integration tip fetched: `origin/epic/documentation-estate-tooling-integration` is the expected tip named in the delegation; `git merge-tree --write-tree` reports exactly one conflict, in the Claude `core.json`; the Codex `core.json` auto-merges.
- Committed intersection of the branch and base file lists: the two `pack-manifests/core.json` files only; no dependency manifest (`pyproject.toml`, `poetry.lock`, `package*.json`) changed on the base.
- The base tip's `.claude/lib/docs/Invoke-DocsCommand.ps1` carries the same nine dispatch rows; the `It` named in [P1-T3] exists and is the only row-count assertion in the file.
- `keeps the three routing copies byte-identical` exists in `docs-authoring-roles.Registration.Tests.ps1`; `test/lib/push-down/claude-pack-manifest-completeness.test.ts` exists in `extensions/drm-copilot/`; main plan [P5-T1] names 23 paths and [P6-T6] names twenty modules.
- Spec AC 12 and user-story AC 9 are already checked; spec AC 9 and user-story AC 7 carry the "without modification" clause; [P3-T3]'s no-checkbox-change condition is consistent with the scope.
- Baselines `pester-coverage.*.md` and `contract-tests.*.md` exist and record zero failures, so the zero-failure gates are consistent with the baselines.
- The `r[g]f` and `fore[c]ast` patterns match no file in the feature folder.
