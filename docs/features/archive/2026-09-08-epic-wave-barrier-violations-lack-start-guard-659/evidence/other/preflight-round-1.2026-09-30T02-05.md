# Preflight Round 1

- Timestamp: 2026-09-30T02-05
- Plan: docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md (commit e485e794)
- Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
- Result: PREFLIGHT: REVISIONS REQUIRED
- Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Defects Reported

- D1 (blocking): editing `.claude/skills/epic-orchestrate/SKILL.md` breaks the frozen digest pin in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:149-150`, enforced by `test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest`; the plan neither updates nor runs it.
- D2 (blocking): `origin/main` moved from merge-base `37096891` to `72d7ebbf`; unscoped diffs against `origin/main` list 479 unrelated files. Orchestrator direction: anchor with `git diff --merge-base origin/main` except for the upstream-drift check.
- D3: Windows lcov `SF:` paths use backslashes; normalize before matching.
- D4: the old-text absence `git grep` skips the untracked helper module; add `--untracked` and the helper path.
- D5: `feature_has_started` predicate rows underspecified; exact literals supplied.
- D6: Jest `it.each` titles underspecified; exact form supplied.
- D7: AC-1 names a function the plan relocates; record an `AC-1 locus:` line in the end-state task.

## Next Action

Revision delegated to atomic-planner; the same plan file is updated in place.
