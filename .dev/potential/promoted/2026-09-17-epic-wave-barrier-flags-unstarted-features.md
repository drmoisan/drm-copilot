# epic-wave-barrier-flags-unstarted-features (Issue #692)

- Date captured: 2026-09-18
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-wave-barrier-flags-unstarted-features/ (Issue #692)

- Issue: #692
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/692
- Last Updated: 2026-09-18
## Summary

The epic wave-barrier check reports `EPIC_WAVE_BARRIER_VIOLATION` for a child feature that has
not started. The check evaluates every feature that declares `depends_on`, with no guard for
whether the feature has begun, and its message asserts that the feature "started" regardless.

The consequence is that **no mid-epic checkpoint can pass plain validation**. Any epic whose later
wave has not launched yet — which is the normal state for most of an epic's life — fails
`validate_orchestration_artifacts` with `artifact_type: epic-orchestrator-state`. The validator
therefore gives no signal during exactly the period it is most useful.

## Reproduction

Observed 2026-09-18 on epic #678 (`worktree-scoped-state-resolution`):

- `#674` (`2026-09-13-taskmaster-push-down-and-resume-674`) has `merge_status: not_started` and no
  `worktree_created_at`. It depends on `#673`, which has not merged.
- Validation fails with exactly one error:
  `EPIC_WAVE_BARRIER_VIOLATION: 2026-09-13-taskmaster-push-down-and-resume-674 started before dependency 2026-09-13-false-approval-elimination-pr-author-model-routing-673 merged`
- `#674` has not started. The error text is false.

The epic orchestrator reported the same behaviour independently while running the epic.

## Root cause

Two implementations carry the same defect and must be fixed together, since the Python module is
the authority and the TypeScript MCP surface must stay in parity with it:

- `scripts/dev_tools/validate_epic_orchestrator_state.py` (the barrier function, ~lines 262-310)
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` (~lines 239-290)

Both loop over every feature with a `depends_on` list and raise a violation when a dependency is
not in `MERGED_STATUSES`:

```text
status_violation = dep_merge_status not in MERGED_STATUSES
```

That condition is evaluated even when the dependent feature has no `worktree_created_at` and a
`merge_status` of `not_started`. The separate timing check already reads `worktree_created_at`, and
correctly does nothing when it is absent; only the status check is unguarded.

## Proposed Fix

Evaluate the barrier only for a feature that has started. A feature has started when it records a
`worktree_created_at`, or when its `merge_status` is anything other than the not-yet-started
states. A feature that has not started cannot have violated a barrier, so it produces no error.

Keep every existing violation for a feature that has started:

- started while a dependency is unmerged — still a violation;
- started before a dependency's `merge_confirmed_at` — still a violation.

Apply the change identically in both implementations.

## Acceptance Criteria (early draft)

- [ ] A `not_started` feature with no `worktree_created_at` whose dependency is unmerged produces no
      `EPIC_WAVE_BARRIER_VIOLATION`.
- [ ] A started feature whose dependency is unmerged still produces the violation.
- [ ] A started feature whose `worktree_created_at` precedes its dependency's `merge_confirmed_at`
      still produces the violation.
- [ ] The Python and TypeScript validators return identical results across the matrix, asserted by
      the existing parity arrangement or a new parity case.
- [ ] Regression case built from the epic #678 checkpoint shape above.

## Constraints & Risks

- The barrier is a safety check against starting a wave early. The guard must not suppress a
  violation for a feature that has in fact started; a missing `worktree_created_at` on a started
  feature should be treated as started, not as unstarted, so the check fails closed.
- Python is the authority; the TypeScript surface must not diverge from it.

## Next Step

- [x] Promote to GitHub issue
