# Scope check ([P2-T6], remediation cycle 1)

Timestamp: 2026-11-14T01-19
Command: `git -C <worktree> diff --name-only <CycleStartHead>` and `git -C <worktree> status --porcelain` (CycleStartHead from `evidence/remediation-baseline/python-static.2026-11-14T00-51.md`)
EXIT_CODE: 0
Output Summary: 22 paths differ from CycleStartHead (committed or modified) and 5 further paths are untracked. Every path is in the allowed set: the two validators, the two corpus test files, the four new fixtures, `FEATURE/spec.md`, this plan, or a file under `FEATURE/evidence/`. No PowerShell file, bundle mirror, pack manifest, or `jest.config.cjs` changed. `FEATURE/user-story.md` is unchanged at this point; P2-T7 may change it.

## Paths and classification

| Path (FEATURE = docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161) | Class |
|---|---|
| `scripts/dev_tools/validate_epic_planner_state.py` | validator |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts` | validator |
| `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` | corpus test file |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts` | corpus test file |
| `tests/fixtures/epic_planner_state_planner_worktrees/recorded-at-byte-order-mark.json` | new fixture |
| `tests/fixtures/epic_planner_state_planner_worktrees/recorded-at-unit-separator.json` | new fixture |
| `tests/fixtures/epic_planner_state_planner_worktrees/recorded-at-next-line.json` | new fixture |
| `tests/fixtures/epic_planner_state_planner_worktrees/blank-recorded-at-ascii-controls.json` | new fixture |
| `FEATURE/spec.md` | spec |
| `FEATURE/remediation-plan.2026-11-14T00-34.md` (committed, plus the uncommitted check-off edits shown as ` M`) | this plan |
| `FEATURE/evidence/other/preflight-fixes.2026-11-14T00-50.md` | evidence |
| `FEATURE/evidence/other/task-check.P1-T1.2026-11-14T01-00.md`, `task-check.P1-T3.2026-11-14T01-03.md`, `task-check.P1-T4.2026-11-14T01-05.md`, `task-check.P1-T5.2026-11-14T01-05.md` | evidence |
| `FEATURE/evidence/regression-testing/recorded-at-fail-before.2026-11-14T01-01.md` | evidence |
| `FEATURE/evidence/remediation-baseline/python-static.2026-11-14T00-51.md`, `typescript-static.2026-11-14T00-52.md`, `pytest-gate.2026-11-14T00-57.md`, `pytest-gate.2026-11-14T00-58.md`, `jest-gate.2026-11-14T00-59.md` | evidence |
| `FEATURE/evidence/qa-gates/phase-gate.P1.2026-11-14T01-12.md` | evidence |
| Untracked: `FEATURE/evidence/qa-gates/python-static.2026-11-14T01-13.md`, `typescript-static.2026-11-14T01-14.md`, `pytest-gate.2026-11-14T01-17.md`, `jest-gate.2026-11-14T01-18.md`, `coverage-delta.2026-11-14T01-19.md` | evidence |
