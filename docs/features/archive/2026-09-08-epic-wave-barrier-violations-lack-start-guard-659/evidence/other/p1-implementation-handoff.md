# Phase 1 Implementation Handoff

Timestamp: 2026-09-30T10-20

Plan task: [P1-T1]

Handoff: tasks [P1-T2] to [P1-T16] are handed to the small-path implementation engineer, `atomic-executor`, applying `.claude/rules/python.md` and `.claude/rules/typescript.md` (plus the general code-change and unit-test rules read in [P0-T1]).

## Write set (plan section 2, items 1 to 11)

Production (3):

1. `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` (create, [P1-T7])
2. `scripts/dev_tools/validate_epic_orchestrator_state.py` (update, [P1-T8])
3. `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` (update, [P1-T9])

Tests and fixtures:

4. `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` (create, [P1-T2])
5. `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py` (create [P1-T3], update [P1-T12])
6. `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` (create, [P1-T4])
7. `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (update one literal, [P1-T10])
8. `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (update one literal, [P1-T11])
9. `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (skill digest literal and comment block, [P1-T15])

Documentation:

10. `.claude/skills/epic-orchestrate/SKILL.md` (update, [P1-T13])
11. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (verbatim copy, [P1-T14])

No other production file may be written. Evidence files are written only under this feature folder.

## Section 1 decisions carried into the handoff

- Start guard: a dependent is started when `worktree_created_at` is a string, or when `merge_status` is not the literal `"not_started"` (missing, `null`, or non-string counts as started). Evaluated once per dependent immediately after the existing `feature_folder` / `depends_on` skip; an unstarted dependent is skipped before its edge loop. The parallel `_has_started` is not reused.
- Dependency status term: Python `not isinstance(dep_merge_status, str) or dep_merge_status not in MERGED_STATUSES`; TypeScript `typeof depMergeStatus !== "string" || !MERGED_STATUSES.has(depMergeStatus)`.
- One error per violated edge; the status case takes precedence over the timing case.
  - Status: `EPIC_WAVE_BARRIER_VIOLATION: {folder} is treated as started while dependency {dependency} is not merged`
  - Timing: `EPIC_WAVE_BARRIER_VIOLATION: {folder} worktree_created_at precedes dependency {dependency} merge_confirmed_at`
- Python placement: new module `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` holds `NOT_STARTED_MERGE_STATUS`, `MERGED_STATUSES`, `feature_has_started`, `validate_wave_barrier_ordering`; the validator imports `MERGED_STATUSES` and `validate_wave_barrier_ordering`.
- TypeScript placement: in place in `epic-orchestrator-state-core.ts`; non-exported `hasStarted`; no new module; no `jest.config.cjs` edit.
- Shared parity fixture `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` read by both suites.
- Skill digest pin re-baselined in [P1-T15]; agent digest unchanged.
- Out of scope: `_parallel_orchestrator_state_drift.py`, `jest.config.cjs`, pack manifest, the `SubagentStop` sentence, the unhashable `merge_status` crash in `_validate_merge_status_enum` / `_validate_completion` (recorded by [P1-T16]).
- No property-based tests and no new dependency.

## Completion criterion

Every Phase 1 task ([P1-T1] to [P1-T16]) is checked in the plan with its acceptance met.
