# `2026-08-07-parallel-mutation-protocol` — User Story

- Issue: #442
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-08-07T11-11
- Work Mode: full-feature
- Spec: `docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md`

## Story Statement

- As a repository maintainer operating a live parallel run, I want to add a new issue or
  potential entry to the run with `/parallel-add`, so that newly arrived work is prepared,
  checked for conflicts against everything already running, and either joins the current cohort
  or is safely deferred — without abandoning and restarting the run.
- As a repository maintainer, I want to remove an item from a live run with
  `/parallel-remove`, so that withdrawn or superseded work exits the run cleanly, and so that
  removing an in-flight item forces me to choose explicitly between letting it finish on its
  own (`detach`) and destroying its work (`abandon`) — the system never guesses for me.
- As a repository maintainer running an `open`-mode standing queue, I want to terminate the run
  explicitly with `/parallel-close`, so that an open run has a deliberate, safe end point and
  cannot end while work is still in flight.
- As a reviewer auditing a parallel run after the fact, I want every membership change recorded
  in an append-only mutation log with a generation counter, so that a cohort table which
  changed mid-run is traceable rather than silently rewritten.
- As an operator of concurrent child orchestrations, I want in-flight items pinned so that no
  membership change can reschedule work that is already executing underneath itself.

## Problem / Why

The `parallel` orchestration surface (epic `parallel-orchestration`) schedules multiple
independent bugs and features into concurrent cohorts computed from blast-radius contention.
Unlike the epic surface, the item set is mutable mid-execution: items can be added to a live
run, removed from it, and an `open`-mode run must be explicitly terminable. The epic surface
has no analogue for dynamic membership, so this capability must be built new. Without it, a
parallel run's membership is frozen at plan time and any change requires abandoning the run.

Mutable membership also introduces an auditability requirement epics do not have: a cohort
table that changes must be traceable rather than silently rewritten.

## Personas & Scenarios

- Persona: repository maintainer (run operator)
  - Operates a live parallel run with several items in flight on isolated worktrees.
  - Cares about merge safety: a membership change must never invalidate the concurrency
    guarantee for work already executing.
  - Constraint: cannot pause in-flight child orchestrations to reshuffle the schedule; needs
    changes applied only to work that has not started.
  - Goal: keep the run current as priorities shift, without restarting it.

- Persona: reviewer / auditor
  - Reads the run's checkpoint and status projection after completion or after an incident.
  - Cares about explaining why the cohort table at the end differs from the cohort table at
    plan time.
  - Goal: reconstruct every membership change from the mutation log and its
    `recolor_generation` values.

- Scenario: adding an urgent item to a live run
  - A maintainer is mid-run with two items in flight. An urgent bug arrives.
  - The maintainer invokes `/parallel-add <issue>`. The item is prepared through the standard
    preparation-mode child run, which yields its declared blast radius.
  - Conflict edges are computed against every item, including the two in flight. The bug
    conflicts with neither, so it is admitted into the current cohort immediately; the cohort
    coloring is untouched and the generation counter does not change.
  - A second added item does conflict with an in-flight item, so it is deferred to a future
    cohort; the unstarted subgraph is recolored and the generation counter increments by one.
    Both decisions are visible as entries in the mutation log.

- Scenario: removing an in-flight item
  - A maintainer runs `/parallel-remove <item>` on an in-flight item. The command is rejected
    with a specific error because no disposition was supplied; nothing changes.
  - The maintainer decides the item's work is still wanted and re-runs with
    `--disposition detach`: the item finishes and merges on its own while the run stops
    tracking it.
  - For a different item whose work must be discarded, the maintainer re-runs with
    `--disposition abandon` plus the explicit confirmation marker. Without the marker, the
    abandon-gate hook denies the command with reason code `PARALLEL_ABANDON_BLOCKED`. With the
    marker, the PR is closed, the worktree is removed, and the item is marked `withdrawn`.

- Scenario: closing an open-mode run
  - An `open`-mode run has drained: nothing is in flight. The maintainer invokes
    `/parallel-close <slug>` and the run terminates, recorded in the mutation log.
  - Attempted earlier, while an item was still in flight, the same command was rejected and
    changed nothing.

## Acceptance Criteria

- [x] `/parallel-add` prepares a proposed item via a preparation-mode child orchestrator run reusing the `route_id: preparation` contract unchanged, computes conflict edges against all items including in-flight ones, and applies the admission decision: admit into the current cohort only when the candidate conflicts with no in-flight item; otherwise defer to a future cohort and recolor the unstarted subgraph.
- [x] `/parallel-remove` implements the design §8.4 state-dependent behavior table exactly: unstarted states (`proposed`, `admitted`, `prepared`, `scheduled`) mark `withdrawn`, drop the vertex, and recolor the unstarted subgraph; `in_flight` removal is rejected without an explicit `detach|abandon` disposition and no default is ever inferred; `merged` removal is rejected.
- [x] `--disposition detach` lets an in-flight item finish and merge on its own while the run stops tracking it; `--disposition abandon` closes the PR, removes the worktree, and marks the item `withdrawn`, and is executable only through the hook-gated CLI path.
- [x] `/parallel-close` terminates an `open`-mode run and is rejected while any item is `in_flight`.
- [x] The pinning invariant holds: in-flight items are never rescheduled by any mutation; recoloring is a pure function of `(remaining subgraph, pinned set)`; determinism under mutation against a live in-flight set is proven by unit and property-based tests.
- [x] Every add, remove, close, and drift-induced requeue appends exactly one `mutations[]` entry with `{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`; `recolor_generation` increments by exactly one on each recompute (deferred add, remove of an unstarted item, drift-induced requeue) and is stamped unchanged on non-recompute operations (no-conflict admission, `detach`, `abandon`, `close`); rejected operations append nothing.
- [x] Mode-dependent completion semantics hold: a `closed`-mode run completes when every non-withdrawn item is `merged` or `worktree_removed`; an `open`-mode run never auto-completes and terminates only via `/parallel-close`.
- [x] The abandon-gate hook denies any command carrying `--disposition abandon` without the explicit confirmation marker (reason code `PARALLEL_ABANDON_BLOCKED`) and allows it when the marker is present.
- [x] The mutation log and generation counter make a changed cohort table fully traceable: a reviewer can reconstruct the sequence of membership changes and recolors from `mutations[]` alone, and the validator rejects a log whose `recolor_generation` values are not monotonically non-decreasing.

## Non-Goals

- Modifying or refactoring any existing epic implementation (`enforce-epic-*` hooks, epic
  validators, epic skills or agents). The `parallel` surface is additive.
- Adding fields or enum values to the checkpoint schema. F3 (issue 444) owns the complete
  schema including `mutations[]`; F6 populates it.
- Cohort-barrier and worktree-removal enforcement hooks (F7, issue 440) and drift detection
  itself (F8, issue 446). F6 defines only the mutation-log append contract the drift-induced
  requeue uses.
- Reimplementing the Welsh-Powell coloring (F2, issue 445) or the `conflicts(a, b)` relation
  (F1, issue 447); F6 delegates to both.
- Key-level partitioning of shared surfaces and optimal graph coloring (epic non-goals).
- Opportunistic recompute after `abandon` of an in-flight item: a previously deferred item
  retains its deferred cohort assignment (spec, Recompute Boundary).
