# Parallel drift-gate TypeScript parity divergence (Potential)

- Date captured: 2026-08-09
- Author: atomic-executor (remediation cycle 1, feature 2026-08-07-parallel-drift-detection-446, issue #446)
- Status: Draft

## Problem / Why

The Layer-2 retrospective drift gate exists only in the Python validator. The TypeScript parity port
of the parallel-orchestrator checkpoint validator carries no equivalent dispatch, so the two runtimes
report different error sets for the same checkpoint.

**The missing Layer-2 drift-gate dispatch.** `scripts/dev_tools/validate_parallel_orchestrator_state.py`
imports `validate_drift_gate` from `scripts/dev_tools/_parallel_orchestrator_state_drift.py` (import at
line 38) and dispatches it at line 325, immediately after `_validate_collections` and immediately
before the F7 extension-seam block. The TypeScript core
`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` has no counterpart:
its dispatch list ends with the key-gated `drift_events` shape check
(`if ("drift_events" in state)` at line 203, calling `validateDriftEvents`) followed by
`validateReceiptArrays`, with no drift-gate call at all.

**The divergent error set.** For a checkpoint whose latest drift event for an item is unresolved while
that item's `merge_status` is in `{pr_open, ci_green, merged, worktree_removed}`, the Python validator
emits one `PARALLEL_DRIFT_GATE_VIOLATION:` error per offending item, and the TypeScript core emits
**nothing**. The divergence is one-directional and complete for this invariant: TypeScript never
produces a `PARALLEL_DRIFT_GATE_VIOLATION:` string under any input. It is not an error-text formatting
difference of the kind recorded in
`docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`; it is an absent check.

Consequence: any consumer that validates a parallel checkpoint through the TypeScript surface — the
MCP tool path — sees a checkpoint carrying a merged-while-drifted item as valid, while the same
checkpoint validated through the Python CLI is rejected. The retrospective backstop that makes the
per-call `PreToolUse` deterrent non-bypassable is therefore only present on one of the two surfaces.

**Insertion point when this is remediated.** One dispatch call belongs in
`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`, placed beside the
existing key-gated `drift_events` dispatch at line 203 and **outside** the comment-delimited
`BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` /
`END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` block at lines 307-314. That block is
reserved for F7's cohort-barrier invariant by `.claude/rules/parallel-orchestration.md` `## F7 Seam`;
adding an unrelated call inside it would contend with F7's assigned edit.

**Python is authoritative in the interim.** Until the port lands, the Python validator is the single
authority on the Layer-2 drift gate. Any workflow that must enforce the gate has to validate through
the Python CLI path (`scripts/dev_tools/validate_orchestration_artifacts.py` with
`parallel-orchestrator-state`), not through the TypeScript MCP surface. This matches the enforcement
note in `.claude/rules/parallel-orchestration.md` that the Python validator remains authoritative for
per-record correctness where the TypeScript surface implements a narrower check.

## Proposed Behavior

The TypeScript core should reproduce the Layer-2 drift gate with the same semantics and the same error
strings as `validate_drift_gate`:

- One `PARALLEL_DRIFT_GATE_VIOLATION:` error per item whose latest drift event is unresolved while its
  `merge_status` is in `{pr_open, ci_green, merged, worktree_removed}`.
- Key-gated and additive: a checkpoint with no `drift_events` key produces zero new errors, so the
  change is backward compatible with every existing checkpoint shape.
- An item resting at `blocked_drift` produces no error, so the gate stays compatible with the state
  the halt path writes.
- The same latest-event selection rule (greatest `at`, ties broken by append order) and the same two
  resolution disjuncts, including the canonical `yyyy-MM-ddTHH-mm` timestamp contract both runtimes
  now require on disjunct (b).

The port must not extend any enum or add any schema field; `.claude/rules/parallel-orchestration.md`
`## Enum Ownership` binds the wave-4 features to consume, never extend.

## Acceptance Criteria (early draft)

- [ ] `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` dispatches a
      Layer-2 drift-gate check beside the existing key-gated `drift_events` dispatch and outside the
      F7 extension seam.
- [ ] The TypeScript check emits `PARALLEL_DRIFT_GATE_VIOLATION:` error strings byte-identical to the
      Python validator's for the same checkpoint.
- [ ] The port reproduces the canonical-timestamp contract of disjunct (b), so a non-conforming
      `computed_at` or `at` on either side leaves the item unresolved in both runtimes.
- [ ] A cross-runtime parity fixture set covers the unresolved-while-merged case, the
      `blocked_drift` exemption, the no-`drift_events` backward-compatibility case, and the
      widened-radius and re-recorded-radius resolution disjuncts.
- [ ] `.claude/rules/parallel-orchestration.md` is amended to record the closed divergence, at spec
      review rather than at implementation time.

## Constraints & Risks

- **This entry is documentation-only.** No code change accompanies it. Issue #446's remediation cycle
  1 explicitly places any TypeScript change, including this parity port, out of scope, and likewise
  forbids editing `.claude/rules/**`. The reviewer required a durable
  `docs/features/potential/` record instead, following the precedent this entry mirrors.
- Disjunct (a) needs the path-subsumption predicate. Porting that matcher to TypeScript risks the
  divergent-matcher failure mode the drift-detection feature exists to prevent, so the port should
  reuse an existing shared TypeScript path-subsumption implementation if one exists rather than
  author a sixth copy of the semantics. If none exists, the scope of this work grows to include one,
  and that should be settled at spec review.
- Wave-4 concurrency: F6 (issue #442) and F7 (issue #440) are executing against the same integration
  branch, and F7 owns an appendable seam in both the Python module and the TypeScript core. This work
  must not land inside either seam, and should be scheduled after the wave-4 children merge to avoid
  contending over the same files.
- Changing the TypeScript validator's output is a behaviour change for every MCP consumer that
  asserts an exact error count or error set, so the fix must be scoped and reviewed independently
  rather than folded into an unrelated change.

## Test Conditions to Consider

- [ ] Unit coverage: unresolved latest event against each of the four gated `merge_status` values;
      an item at `blocked_drift`; an item with no drift event; a checkpoint with no `drift_events`
      key.
- [ ] Unit coverage for both resolution disjuncts, including the canonical-timestamp rejection cases
      (colon-bearing, truncated, and non-string `computed_at` and `at`).
- [ ] Cross-runtime parity: the same constructed documents validated through both the Python
      validator and the TypeScript core, asserting equal error sets, in the style of the existing
      96-of-96 parity verification recorded in `.claude/rules/parallel-orchestration.md`.
- [ ] Integration: the MCP `validate_orchestration_artifacts` tool with
      `artifact_type: "parallel-orchestrator-state"` rejects a merged-while-drifted checkpoint.
- [ ] CLI parity example: `validate_orchestration_artifacts.py parallel-orchestrator-state` and the
      MCP surface produce the same verdict for one shared fixture.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
