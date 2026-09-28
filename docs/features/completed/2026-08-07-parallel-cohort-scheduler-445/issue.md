# parallel-cohort-scheduler (Issue #445)

- Date captured: 2026-08-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-cohort-scheduler/ (Issue #445)
- Epic: `parallel-orchestration` (child F2, wave 0)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` section 6

- Issue: #445
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/445
- Last Updated: 2026-08-07
- Work Mode: full-feature

## Problem / Why

The `parallel` orchestration surface schedules thematically unrelated items concurrently based on
computed blast-radius contention rather than a hand-authored dependency graph. Scheduling requires a
deterministic mechanism that partitions items into batches that are safe to run at the same time.

No such mechanism exists in the repository. The epic surface has `scripts/dev_tools/epic_wave_computation.py`,
which implements longest-path layering over a **directed** dependency DAG. That formula does not apply
here: the parallel surface's contention relation `conflicts(a, b)` is **undirected** and symmetric, so
layering is not the correct model.

Without a canonical, tested reference implementation, cohort assignment would be re-derived ad hoc by
each consumer (the planner surface F4 and the orchestrator surface F5), which would break the epic NFR
that identical inputs must produce identical cohort assignments.

## Proposed Behavior

Provide `scripts/dev_tools/parallel_cohort_computation.py` as the canonical, tested reference
implementation of parallel cohort scheduling.

Scheduling model (design section 6): build an undirected conflict graph `G` whose vertices are items and
whose edges are the `conflicts` relation. A set of items may execute concurrently if and only if it is an
**independent set** in `G`. Partitioning the vertices into a sequence of independent sets is graph
coloring, and each color class is a **cohort**.

The module must implement:

1. **Deterministic greedy coloring in Welsh-Powell order.** Vertices are sorted by descending degree,
   with ties broken by ascending item key. Each vertex is assigned the lowest cohort index not used by
   any already-assigned neighbor.
2. **`max_concurrency` slot filling.** `max_concurrency` caps fan-out independently of cohort size. A
   cohort of twelve executes at `max_concurrency` at a time, with slots filled in ascending item-key
   order.
3. **Conflict-graph input contract.** The module accepts an already-computed conflict graph or edge set.
   It does not compute blast radii; that is the responsibility of the F1 `parallel-blast-radius` feature.

The module mirrors `scripts/dev_tools/epic_wave_computation.py` in shape, testing approach, and
error-handling conventions: a pure function over a caller-supplied mapping, no file I/O, a dedicated
exception type for malformed input, and Google-style docstrings.

## Acceptance Criteria (early draft)

- [ ] `scripts/dev_tools/parallel_cohort_computation.py` exists and implements deterministic greedy
      coloring in Welsh-Powell order (descending degree, ties by ascending item key).
- [ ] The module accepts an already-computed conflict graph or edge set as input and does not compute
      blast radii.
- [ ] `max_concurrency` slot filling is implemented: fan-out is capped independently of cohort size, with
      slots filled in ascending item-key order.
- [ ] Identical inputs produce identical cohort assignments across repeated invocations.
- [ ] A parity test exists in the manner of the existing `epic_wave_computation.py` tests.
- [ ] Line coverage >= 85% and branch coverage >= 75% for the new module.
- [ ] No existing epic implementation is modified or refactored (additive only).

## Constraints & Risks

- **Optimality is explicitly not the objective.** Design section 13.3 accepts that greedy coloring is not
  optimal and that cohort counts will be at or above the chromatic number. Substituting an optimal or
  randomized coloring algorithm violates the accepted design.
- **Determinism is an epic NFR.** Identical inputs must produce identical cohort assignments. Any
  iteration over an unordered container must be explicitly ordered before use.
- **Additive only.** `epic_wave_computation.py` and the other epic implementations must not be modified
  or refactored into a shared abstraction.
- **Boundary with F1.** The `conflicts(a, b)` contention relation and the blast-radius model belong to
  F1 (`parallel-blast-radius`), prepared concurrently. The input contract must be defined explicitly so
  F1's output and this module's input agree; F3 serializes both into the checkpoint schema.
- File-size limit of 500 lines per production and test file applies.

## Test Conditions to Consider

- [ ] Empty graph; single vertex; all-isolated vertices (one cohort).
- [ ] Complete graph (every vertex in its own cohort).
- [ ] Welsh-Powell ordering: a graph where degree ordering changes the result versus insertion order.
- [ ] Tie-breaking: equal-degree vertices ordered by ascending item key.
- [ ] Determinism: repeated invocations and permuted input orderings produce identical assignments.
- [ ] `max_concurrency` slot filling for a cohort larger than `max_concurrency`, including exact-multiple
      and remainder cases.
- [ ] `max_concurrency` values of 1 and values exceeding the cohort size.
- [ ] Malformed input: an edge referencing an unknown item key; a self-loop; a non-positive
      `max_concurrency`.
- [ ] Symmetry: an edge supplied in either direction yields the same conflict.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-cohort-scheduler/` folder from the template
