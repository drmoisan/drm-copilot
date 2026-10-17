# epic-wave-barrier-violations-lack-start-guard (Issue #659)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-wave-barrier-violations-lack-start-guard/ (Issue #659)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #659
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/659
- Last Updated: 2026-09-08
- Work Mode: minor-audit

## Consolidated Scope (2026-09-29)

Per the 2026-09-29 comment on #659, this issue absorbs #692 (closed as a duplicate; same root cause). Line references re-verified against origin/main `37096891`: `_validate_wave_barrier_ordering` is defined at `scripts/dev_tools/validate_epic_orchestrator_state.py:243`, the unguarded `status_violation` is computed at `:296`, and the error text is emitted at `:304`. The TypeScript port is `validateWaveBarrierOrdering` in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:241` (unguarded status check at `:276`, error text at `:285`).

Requirements absorbed from #692:

- A feature has started when it records a string `worktree_created_at`, or when its `merge_status` is anything other than `not_started`. A missing or non-string `merge_status` is treated as started (fail closed).
- Every existing violation for a started feature is kept: started while a dependency is unmerged, and started before a dependency's `merge_confirmed_at`.
- The Python module is the authority; the TypeScript port must return identical results and byte-identical error strings.
- The error text currently asserts that the feature "started" regardless of its state; it must be corrected so that it is accurate for every case in which it is emitted.

The earlier note under `## Proposed Fix / Validation Ideas` to keep the error string unchanged is superseded by the consolidation comment.

## Acceptance Criteria

- [x] AC-1: A dependent feature with `merge_status: not_started` and no `worktree_created_at`, whose dependency is not merged, produces no `EPIC_WAVE_BARRIER_VIOLATION` from `_validate_wave_barrier_ordering` in `scripts/dev_tools/validate_epic_orchestrator_state.py`.
- [x] AC-2: A dependent feature that has started (a `merge_status` other than `not_started`, a string `worktree_created_at`, or a missing or non-string `merge_status`) whose dependency is not merged still produces exactly one `EPIC_WAVE_BARRIER_VIOLATION` per violated edge.
- [x] AC-3: A started dependent whose `worktree_created_at` precedes its dependency's `merge_confirmed_at` still produces the violation, and a started dependent whose dependencies were all merged before it started produces none.
- [x] AC-4: The error text emitted at the former `scripts/dev_tools/validate_epic_orchestrator_state.py:304` site is corrected so it is accurate for each case in which it is emitted, retains the `EPIC_WAVE_BARRIER_VIOLATION: ` prefix, and names the dependent feature and the dependency; documentation that quotes the text (`.claude/skills/epic-orchestrate/SKILL.md` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`) is updated to match.
- [x] AC-5: `validateWaveBarrierOrdering` in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` applies the same start guard and emits byte-identical error strings to the Python authority across the AC-1 to AC-3 matrix, asserted by Jest tests.
- [x] AC-6: A regression case built from the epic #678 checkpoint shape (dependent `not_started` with no `worktree_created_at`, depending on an unmerged feature) and a kickoff-shaped checkpoint in which every feature is `not_started` both validate with zero `EPIC_WAVE_BARRIER_VIOLATION` errors, in Python and in TypeScript.
- [x] AC-7: The Python and TypeScript toolchains pass (format, lint, type check, tests) with line coverage >= 85% and branch coverage >= 75% on the changed modules, no changed file exceeds 500 lines, and changed-line coverage does not regress.

## Summary

`_validate_wave_barrier_ordering` in `scripts/dev_tools/validate_epic_orchestrator_state.py` applies no start guard: it emits `EPIC_WAVE_BARRIER_VIOLATION` for every dependency edge whose upstream `merge_status` is not `merged` or `worktree_removed`, regardless of whether the dependent feature has started. A freshly bootstrapped epic checkpoint therefore always reports one violation per edge.

## Environment

- OS/version: Windows 11 Pro 10.0.26200.
- Python version: 3.13 (Poetry environment).
- Command/flags used: `validate_orchestration_artifacts.py epic-orchestrator-state artifacts/orchestration/epic-orchestrator-state.json`.
- Data source or fixture: epic #655 checkpoint at kickoff (four `depends_on` edges).

## Steps to Reproduce

1. Bootstrap an epic checkpoint from a manifest with at least one `depends_on` edge; every feature is `not_started`.
2. Run the epic-orchestrator-state validator without `require_complete`.
3. Observe one `EPIC_WAVE_BARRIER_VIOLATION` per edge although no dependent has started.

## Expected Behavior

A wave-barrier violation is reported only when a dependent feature has started (`merge_status` beyond `not_started`) while an upstream dependency is not yet merged.

## Actual Behavior

Four violations at kickoff for epic #655, falling to zero only as dependencies merged. The SubagentStop gate does not run this check, so it is noise rather than a block, but it hides a real ordering violation among expected ones.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
EPIC_WAVE_BARRIER_VIOLATION x4 at kickoff (features 631, 632, 635, 637 all not_started)
```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Validator noise; a real violation would be indistinguishable from the expected ones until the end of the run.

## Suspected Cause / Notes

- The ordering check tests the upstream state only; it needs `dependent.merge_status != "not_started"` as a precondition.
- A TypeScript parity port may exist under `extensions/drm-copilot/src/lib/validate/`; apply the same guard there with byte-identical error strings.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: pytest cases for `not_started` dependent with unmerged upstream (no violation), started dependent with unmerged upstream (violation), started dependent with merged upstream (no violation).
- [x] Integration scenario to retest: validate a kickoff checkpoint and expect zero violations.
- [x] Manual verification notes: keep the error string unchanged for the true-violation case.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
