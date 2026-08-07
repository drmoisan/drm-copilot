# parallel-mutation-protocol (Potential)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-08-07-parallel-mutation-protocol-442/ (Issue #442)
- Epic: parallel-orchestration (child feature F6, wave 4)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (sections 8 and 9)
- Epic manifest: `docs/features/epics/parallel-orchestration/epic.md`

## Problem / Why

The `parallel` orchestration surface (epic `parallel-orchestration`) schedules multiple
independent bugs and features into concurrent cohorts computed from blast-radius contention.
Unlike the epic surface, the item set is mutable mid-execution: items can be added to a live
run, removed from it, and an `open`-mode run must be explicitly terminable. The epic surface
has no analogue for dynamic membership, so this capability must be built new. Without it, a
parallel run's membership is frozen at plan time and any change requires abandoning the run.

Mutable membership also introduces an auditability requirement epics do not have: a cohort
table that changes must be traceable rather than silently rewritten.

## Proposed Behavior

Deliver dynamic membership for a live parallel run (design section 8, plus the abandon gate
from section 9):

- **`/parallel-add <issue|potential-entry>`** (section 8.3): the item enters `proposed`; it is
  prepared via a preparation-mode child `Agent(orchestrator)` run reusing the existing
  `route_id: preparation` contract unchanged, which yields the declared blast radius; conflict
  edges are computed against all items including in-flight ones; the admission decision admits
  the item into the current cohort when it conflicts with no in-flight item, otherwise defers
  it to a future cohort and recolors the unstarted subgraph.
- **`/parallel-remove <item> [--disposition detach|abandon]`** (section 8.4) with the exact
  state-dependent behavior table: `proposed`/`admitted`/`prepared`/`scheduled` mark
  `withdrawn`, drop the vertex, and recolor the unstarted subgraph; `in_flight` is rejected
  unless `--disposition` is supplied; `detach` lets the item finish and merge on its own while
  the run stops tracking it; `abandon` closes the PR, removes the worktree, and marks
  `withdrawn` (destructive, hook-gated); `merged` is rejected because the change is already in
  `main`.
- **`/parallel-close <slug>`** (section 8.5): terminates an `open`-mode run; rejected while
  any item is `in_flight`.
- **The pinning invariant** (section 8.1): in-flight items are pinned; scheduling is
  recomputed only over the not-yet-started subgraph; recoloring stays a pure function of
  `(remaining subgraph, pinned set)`.
- **The item lifecycle** (section 8.2): `proposed -> admitted -> prepared -> scheduled ->
  in_flight -> merged`, with `withdrawn`/`blocked` exits.
- **The mutation log** (section 8.6): every add, remove, close, and drift-induced requeue
  appends to `mutations[]`; `recolor_generation` increments on each recompute.
- **Mode-dependent completion semantics** (section 8.7): `closed` completes when every
  non-withdrawn item is `merged` or `worktree_removed`; `open` terminates only via
  `/parallel-close`.
- **The abandon gate** (section 9): a hook denying `--disposition abandon` without an explicit
  confirmation marker. Assigned to this feature rather than F7 because it enforces the
  disposition contract this feature defines.

## Acceptance Criteria (early draft)

- [ ] `/parallel-add` prepares a proposed item via a preparation-mode child orchestrator run, computes conflict edges against all items including in-flight ones, and applies the admission decision (admit into current cohort only when no in-flight conflict; otherwise defer and recolor the unstarted subgraph).
- [ ] `/parallel-remove` implements the section 8.4 state-dependent behavior table exactly, including rejection of `in_flight` removal without an explicit `detach|abandon` disposition and rejection of `merged` removal.
- [ ] `/parallel-close` terminates an `open`-mode run and is rejected while any item is `in_flight`.
- [ ] The pinning invariant holds: in-flight items are never rescheduled; recoloring is a pure function of `(remaining subgraph, pinned set)`; tests prove determinism under mutation against a live in-flight set.
- [ ] Every add, remove, close, and drift-induced requeue appends a `mutations[]` entry with `{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`, and `recolor_generation` increments on each recompute.
- [ ] Mode-dependent completion semantics: `closed` fires the completion gate when every non-withdrawn item is `merged` or `worktree_removed`; `open` never auto-completes.
- [ ] An abandon-gate hook denies `--disposition abandon` without an explicit confirmation marker.

## Constraints & Risks

- Wave-4 contention: this feature executes concurrently with F7 (`parallel-enforcement-hooks`)
  and F8 (`parallel-drift-detection`); all three extend
  `.claude/skills/parallel-orchestrate/SKILL.md` and, to a lesser degree,
  `validate_parallel_orchestrator_state.py`. Edits must be confined to a distinct, explicitly
  named new section of those files without reflowing or reordering existing sections.
- F3 owns the complete checkpoint schema including `mutations[]`; this feature populates that
  structure and must not add schema fields.
- Additive only: existing epic implementations must not be modified or refactored.
- In-flight removal must never infer a default disposition (accepted decision, design
  section 3).
- The surface is named `parallel` throughout.
- Risk: the pinning invariant and `recolor_generation` accounting must hold against a live,
  concurrently mutating set of in-flight items; this has no in-repository prior art.

## Test Conditions to Consider

- [ ] Unit coverage: admission decision (no-conflict admit, in-flight-conflict defer), removal behavior per lifecycle state, disposition rejection paths, close rejection while in-flight, mutation-log append shape, recolor-generation increment, mode-dependent completion.
- [ ] Property/determinism tests: recoloring is a pure function of `(remaining subgraph, pinned set)`; identical inputs yield identical cohort assignments; pinned items never move.
- [ ] Hook tests: abandon gate denies without the confirmation marker and permits with it.
- [ ] Integration scenarios: add during an active cohort with and without in-flight conflicts; remove at each lifecycle state; close on `open`-mode runs.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create active feature folder from the template (docs/features/active/2026-08-07-parallel-mutation-protocol-442/)
