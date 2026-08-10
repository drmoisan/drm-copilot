# `2026-08-07-parallel-cohort-scheduler` — User Story

- Issue: #445
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-08-07T13-00
- Epic: `parallel-orchestration` (child F2, wave 0)
- Spec: `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md`

## Story Statement

- As the `parallel-planner` surface (F4), I want a canonical `compute_cohorts` reference
  implementation that partitions items into deterministic Welsh-Powell cohorts from an
  already-computed conflict edge set, so that cohort seeding is reproducible and I never
  re-derive coloring logic ad hoc.
- As the `parallel-orchestrator` surface (F5), I want a `compute_concurrency_batches` slot-filling
  function that caps fan-out at `max_concurrency` in ascending item-key order, so that a large
  cohort executes in predictable, auditable batches.
- As a feature reviewer, I want cohort assignment to be a pure, tested function with a dedicated
  exception for malformed input, so that identical inputs verifiably produce identical schedules
  and defective F1 output fails fast instead of silently corrupting the schedule.

## Problem / Why

The `parallel` orchestration surface schedules thematically unrelated items concurrently based on
computed blast-radius contention rather than a hand-authored dependency graph. Scheduling requires
a deterministic mechanism that partitions items into batches that are safe to run at the same
time.

No such mechanism exists in the repository. The epic surface has
`scripts/dev_tools/epic_wave_computation.py`, which implements longest-path layering over a
**directed** dependency DAG. That formula does not apply here: the parallel surface's contention
relation `conflicts(a, b)` is **undirected** and symmetric, so layering is not the correct model.
The correct model (design §6) is graph coloring: a set of items may execute concurrently if and
only if it is an independent set in the undirected conflict graph, and each color class is a
cohort.

Without a canonical, tested reference implementation, cohort assignment would be re-derived ad hoc
by each consumer (the planner surface F4 and the orchestrator surface F5), which would break the
epic NFR that identical inputs must produce identical cohort assignments. Optimality is explicitly
not the objective; determinism and explainability are (design §13.3).

## Personas & Scenarios

- Persona: **`parallel-planner` (F4) — machine consumer.**
  - Prepares a batch of independent items, receives the conflict edge set computed by F1, and
    must seed the initial cohort table.
  - Cares about reproducibility: replanning the same item set must yield byte-identical cohorts
    regardless of the order items were admitted.
  - Constraint: its output is serialized by F3 into the checkpoint schema
    (`cohorts[] = { index, generation, item_keys[] }`), so the scheduler's output shape must map
    onto that record with integer keys surviving a JSON round trip.
- Persona: **`parallel-orchestrator` (F5) — machine consumer.**
  - Executes one cohort at a time and must fan out at most `max_concurrency` child orchestrations
    concurrently, regardless of cohort size.
  - Cares about a deterministic slot order so that a resumed or replayed run launches the same
    items in the same order.
- Persona: **Repository maintainer / feature reviewer — human consumer.**
  - Audits why two items were or were not scheduled together. Needs the coloring rule to be
    simple enough to verify by hand from the recorded conflict edges and the documented
    Welsh-Powell order.

- Scenario: **Deterministic cohort seeding.**
  - The planner has items `{443, 444, 445, 446}` and F1-computed conflict edges
    `[(443, 445), (443, 446)]` (reduced from the checkpoint's `{ a, b, reason }` records by
    dropping `reason`).
  - It calls `compute_cohorts([443, 444, 445, 446], [(443, 445), (443, 446)])`.
  - Vertex 443 has degree 2 and is colored first into cohort 0; 445 and 446 conflict with it and
    take cohort 1; 444 is isolated and joins cohort 0. Result: `[[443, 444], [445, 446]]`, with
    per-cohort keys ascending.
  - The planner re-runs with the items and edges supplied in a different order and with edge
    `(445, 443)` direction-flipped; the result is identical. The caller wraps each list with its
    positional `index` and the caller-owned `generation` for the checkpoint.
- Scenario: **Capped fan-out of a large cohort.**
  - A cohort of twelve items must execute at `max_concurrency = 4`.
  - The orchestrator calls `compute_concurrency_batches(cohort, 4)` and receives three batches of
    four, filled in ascending item-key order; with ten items it would receive batches of 4, 4,
    and 2. It launches one batch at a time.
- Scenario: **Defective upstream input fails fast.**
  - F1 emits an edge naming an item key that is not in the item set (or a self-loop `(445, 445)`).
  - `compute_cohorts` raises `ParallelCohortInputError` whose message names the offending value.
  - The planner surfaces the error instead of scheduling from a corrupt graph, honoring the
    epic's fail-closed principle.
- Scenario: **Recoloring after mid-run mutation (boundary, not delivered here).**
  - After an item is added or withdrawn, the F6 mutation protocol recolors only the
    not-yet-started subgraph: the caller passes the remaining item keys and the edges among them
    to `compute_cohorts`, excluding in-flight (pinned) items. The module itself carries no
    pinned-set parameter and no generation counter; the docstring states this composition
    pattern.

## Non-Goals

- Optimal or randomized coloring (DSatur with randomized ties, ILP, or similar). Design §13.3
  accepts greedy Welsh-Powell in exchange for determinism; cohort counts will be at or above the
  chromatic number.
- Computing blast radii or evaluating `conflicts(a, b)` — F1 (`parallel-blast-radius`) scope.
  This module consumes the already-computed edge set only.
- Pinned-set / recolor-generation mechanics — F6 scope. No pinned-set parameter; `generation`
  and `current_cohort` are caller-owned.
- Any modification of the atomic-plan contract
  (`.claude/skills/atomic-plan-contract/SKILL.md`).
- Any modification or refactor of the existing epic implementations, including
  `epic_wave_computation.py`; reuse is by near-verbatim adaptation into new files.
- A PowerShell counterpart under `.claude/lib/**`; research §7 verified no PowerShell surface
  recomputes coloring, so F2 ships Python only.
- Serializing cohorts into the manifest or checkpoint schema — F3 scope.
- Creating or modifying `quality-tiers.yml` — F1 research scope in the same wave.

## Acceptance Criteria

- [x] `scripts/dev_tools/parallel_cohort_computation.py` exists and exports
      `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]`
      implementing deterministic greedy coloring in Welsh-Powell order: vertices sorted by the
      composite key `(-degree, item_key)` ascending (descending distinct-neighbor degree, ties by
      ascending item key), each vertex assigned the lowest cohort index not used by any
      already-assigned neighbor.
- [x] The module accepts an already-computed conflict graph (item-key set plus undirected edge
      list) as input, does not compute blast radii, and never evaluates `conflicts(a, b)`; the
      module docstring records the one-line reduction from F3's
      `conflict_edges[] = { a, b, reason }` checkpoint records to the accepted
      `Iterable[tuple[int, int]]` shape.
- [x] Edge symmetry is guaranteed by internal normalization: an edge supplied as `(a, b)`, as
      `(b, a)`, or duplicated yields the same conflict, verified by a test asserting identical
      output for direction-flipped and duplicated edge lists.
- [x] `compute_cohorts` output satisfies the structural invariants: every cohort is an independent
      set of the input graph; each cohort's item keys are sorted ascending; the concatenation of
      all cohorts covers `item_keys` exactly once; empty input returns `[]`; all-isolated input
      returns one cohort; a complete graph on `n` vertices returns `n` singleton cohorts — each
      verified by a dedicated test with exact-output assertions.
- [x] `compute_concurrency_batches(cohort_item_keys: Sequence[int], max_concurrency: int) -> list[list[int]]`
      implements the slot-filling rule: it sorts the cohort's keys ascending itself, then chunks
      into consecutive batches of at most `max_concurrency`; tests cover the exact-multiple case
      (12 items at `max_concurrency = 4` → three batches of four), the remainder case (10 items at
      `max_concurrency = 4` → batches of 4, 4, 2), `max_concurrency = 1` (singleton batches), and
      `max_concurrency >= cohort size` (one batch), and assert that batch concatenation equals
      the ascending-sorted cohort.
- [x] Determinism is verified by explicit tests using fixed literal permutations: repeated
      invocation with identical input, permuted `item_keys`, and permuted plus direction-flipped
      `conflict_edges` all produce identical cohort assignments.
- [x] A dedicated tie-break test with equal-degree vertices verifies ascending item-key ordering
      (the test fails under an accidental descending tie-break), and a dedicated test shows
      Welsh-Powell degree ordering producing a different result than insertion order.
- [x] `ParallelCohortInputError(ValueError)` is the single dedicated exception, raised for all
      four malformed-input modes — unknown edge endpoint, self-loop, duplicate item key,
      non-positive `max_concurrency` — carrying an attribute identifying the offending value;
      tests assert the exception type per mode and that the message names the offending value.
- [x] Both public functions are pure: no file I/O, no network, no clock or RNG access, no
      mutation of input arguments; the module docstring documents that `generation` /
      `recolor_generation` and `current_cohort` are caller-owned, and that recoloring over a
      mutated set is performed by invoking `compute_cohorts` on the induced not-yet-started
      subgraph with in-flight items excluded by the caller (no pinned-set parameter).
- [x] The parity test suite exists at
      `tests/scripts/dev_tools/test_parallel_cohort_computation.py` (with
      `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` as the only permitted
      split fallback), in the manner of `tests/scripts/dev_tools/test_epic_wave_computation.py`:
      deterministic scenario tests with exact-output assertions, `pytest.raises` error paths, and
      replicable scenario fixtures; no PowerShell module is created (research §7 scope decision).
- [x] Line coverage >= 85% and branch coverage >= 75% for
      `scripts/dev_tools/parallel_cohort_computation.py`, measured by
      `poetry run pytest --cov --cov-branch`; Black, Ruff, and Pyright (strict) each pass with
      zero errors.
- [x] The change is additive only: no existing epic implementation (including
      `epic_wave_computation.py`) is modified or refactored; `quality-tiers.yml` is neither
      created nor modified; no new Python dependency is added (no `hypothesis`); both new files
      are each under 500 lines.
