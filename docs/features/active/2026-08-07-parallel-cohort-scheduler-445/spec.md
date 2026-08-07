# 2026-08-07-parallel-cohort-scheduler — Spec

- **Issue:** #445
- **Parent (optional):** Epic `parallel-orchestration` (child F2, wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T13-00
- **Status:** Ready for planning
- **Version:** 1.0
- **Design source:** `docs/research/2026-08-07-parallel-orchestration-design-research.md` §6 (authoritative scope); §5.4, §8.1, §11, §12, §13.3 (context)
- **Research:** `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/research/2026-08-07T12-30-parallel-cohort-scheduler-research.md`

## Overview

The `parallel` orchestration surface schedules thematically unrelated items concurrently based on
computed blast-radius contention rather than a hand-authored dependency graph. Scheduling requires a
deterministic mechanism that partitions items into batches that are safe to run at the same time.

No such mechanism exists in the repository. The epic surface has
`scripts/dev_tools/epic_wave_computation.py`, which implements longest-path layering over a
**directed** dependency DAG. That formula does not apply here: the parallel surface's contention
relation `conflicts(a, b)` is **undirected** and symmetric, so layering is not the correct model.

Without a canonical, tested reference implementation, cohort assignment would be re-derived ad hoc
by each consumer (the planner surface F4 and the orchestrator surface F5), which would break the
epic NFR that identical inputs must produce identical cohort assignments.

This feature delivers `scripts/dev_tools/parallel_cohort_computation.py`: the canonical, tested
reference implementation of deterministic greedy graph coloring in Welsh-Powell order, plus the
`max_concurrency` slot-filling rule. Optimality is not the objective; determinism and
explainability are (design §13.3).

## Behavior

### Scheduling model (design §6)

Build an undirected conflict graph `G` whose vertices are items and whose edges are the
`conflicts` relation. A set of items may execute concurrently if and only if it is an
**independent set** in `G`. Scheduling therefore partitions the vertices into a sequence of
independent sets — graph coloring — and each color class is a **cohort**. Cohort index = color.

### Welsh-Powell ordering rule (precise)

1. Normalize edges first: deduplicate `(a, b)` / `(b, a)` pairs and repeated edges, so each
   undirected conflict is counted once.
2. Compute each vertex's degree as the number of **distinct** neighbors after normalization.
3. Sort vertices by the composite key `(-degree, item_key)` ascending — that is, descending
   degree with ties broken by **ascending item key**. Because item keys are unique, this key is a
   total order: the sort outcome is independent of input iteration order and of Python sort
   stability. Sorting by `-degree` alone and relying on a stable sort to break ties is
   non-compliant, because it leaks input order into equal-degree groups.

### Greedy assignment rule (precise)

Visit vertices in the Welsh-Powell order above. Assign each vertex the smallest non-negative
integer (cohort index) not present in the set of cohort indices already assigned to its
neighbors. Consequences the implementation and tests must uphold:

- Isolated vertices and the first-visited vertex always receive cohort 0.
- Every cohort is an independent set of `G` by construction.
- The concatenation of all cohorts covers the input `item_keys` exactly once.
- Empty input yields an empty result. An all-isolated input yields one cohort containing every
  key. A complete graph on `n` vertices yields `n` singleton cohorts.

### `max_concurrency` slot-filling rule (precise)

`max_concurrency` caps fan-out independently of cohort size. Within one cohort, slots are filled
in **ascending item-key order**: sort the cohort's item keys ascending, then chunk into
consecutive batches of at most `max_concurrency` items. The function sorts its own input rather
than trusting caller ordering, so determinism does not depend on caller discipline.

- A cohort of twelve with `max_concurrency = 4` yields three batches of four.
- A remainder case (ten items, `max_concurrency = 4`) yields batches of sizes 4, 4, 2 — every
  batch is size `max_concurrency` except a possibly smaller final batch.
- `max_concurrency >= len(cohort)` yields exactly one batch (the whole cohort).
- `max_concurrency = 1` yields singleton batches in ascending key order.
- `max_concurrency = len(cohort)` (exact divide, single batch) yields one full batch; more
  generally, when `max_concurrency` divides the cohort size evenly, every batch has exactly
  `max_concurrency` items.
- Concatenating the batches equals the ascending-sorted cohort.

## Inputs / Outputs

### Input contract (boundary with F1 — hard requirement)

F1 (`parallel-blast-radius`, prepared concurrently in the same wave) owns the `conflicts(a, b)`
contention relation and the blast-radius model. **This module accepts an already-computed conflict
graph as an explicit item-key set plus undirected edge list. It must not compute blast radii and
must never evaluate `conflicts(a, b)` itself.**

Concrete public signatures (research §2, Candidate B — accepted):

```python
def compute_cohorts(
    item_keys: Iterable[int],
    conflict_edges: Iterable[tuple[int, int]],
) -> list[list[int]]: ...


def compute_concurrency_batches(
    cohort_item_keys: Sequence[int],
    max_concurrency: int,
) -> list[list[int]]: ...
```

Contract details:

- **Item keys are `int`.** Design §11 fixes `issue_num` as the primary key. Typing keys as `int`
  also closes two determinism hazards (mixed-type comparison `TypeError`; lexicographic string
  ordering where `"10" < "9"`). No generic key-type parameter is provided.
- **Edges are unordered pairs.** An edge supplied as `(a, b)` or `(b, a)`, or supplied more than
  once, denotes the same single conflict. The module normalizes internally; symmetry is guaranteed
  by construction, not by caller discipline.
- **Isolated vertices are explicit.** Any key in `item_keys` that appears in no edge is an
  isolated vertex and lands in cohort 0. This is why the key set is a separate parameter rather
  than being inferred from the edge list.
- **Every edge endpoint must be a member of `item_keys`**; an unknown endpoint is malformed input
  (see Error Handling).
- **JSON-representability (boundary with F3).** F3 serializes both this module's input and output
  into the checkpoint schema (design §12). The array-based shape survives a JSON round trip with
  integer keys intact (`item_keys: [443, 444, 445]`, `conflict_edges: [[443, 445]]`), which an
  integer-keyed mapping would not (JSON object keys are strings).
- **Reduction from the checkpoint record.** F3's checkpoint stores
  `conflict_edges[] = { a, b, reason }`. This module accepts the normalized reduction, not the
  dict shape: callers perform `[(e["a"], e["b"]) for e in conflict_edges]`. `reason` is audit
  metadata with no effect on coloring; accepting the dict shape would couple F2 to F3's schema,
  inverting the epic dependency direction (F3 depends on F2). The module docstring must record
  this reduction explicitly so F1/F3/F4 planners can cite it.

### Output contract (mapping to design §12)

`compute_cohorts` returns `list[list[int]]`: an ordered list of cohorts, where list position is
the cohort index and each cohort's item keys are sorted ascending. This is exactly the shape F3
serializes as `cohorts[] = { index, generation, item_keys[] }` — the caller wraps each inner list
with its positional `index` and the current generation. The docstring documents the one-line
derivation of the alternative `item_key -> cohort_index` mapping; the module does not return both
shapes.

`compute_concurrency_batches` returns `list[list[int]]`: ascending-ordered batches per the
slot-filling rule above.

**Caller-owned fields (module boundary):**

- `generation` is the caller-owned `recolor_generation` counter (design §8.6, §12), owned by the
  orchestrator/mutation-protocol surfaces (F5/F6). This module never produces, increments, or
  accepts a generation value.
- `current_cohort` (design §12) is caller-owned execution state, not a module output.

### Purity invariants

Both functions are pure: no file I/O, no network, no clock or RNG access, no mutation of input
arguments. Identical input — including permuted-equivalent input — produces identical output.

## API / CLI Surface

- Public surface: the two functions above plus one exception class,
  `ParallelCohortInputError`. No CLI entry point, no configuration keys, no environment
  variables, no logging.
- Module shape mirrors `scripts/dev_tools/epic_wave_computation.py`: `from __future__ import
  annotations`; collections-ABC imports under `TYPE_CHECKING`; Google-style docstrings on the
  module, the exception, each public function, and any internal helper; intent comments per
  `.claude/rules/self-explanatory-code-commenting.md`.
- Pinned-set boundary (design §8.1; research §6): **no pinned-set parameter.** The pinning
  invariant belongs to F6. Recoloring over a mutated set is achieved compositionally: the caller
  invokes `compute_cohorts` on the induced subgraph of not-yet-started `item_keys` and the edges
  among them, excluding in-flight (pinned) items. The module docstring must state this boundary.
  If F6 later needs a parameter, an optional keyword parameter with a default is a non-breaking
  extension.

## Data & State

- The module holds no state and persists nothing. It is a pure transformation from
  `(item_keys, conflict_edges)` to a cohort list, and from `(cohort_item_keys, max_concurrency)`
  to a batch list.
- Serialization of inputs and outputs into the manifest and checkpoint is F3 scope.

## Determinism Requirement and Enumerated Hazards

Determinism under permuted input ordering is a stated epic NFR: identical inputs — including
permuted `item_keys` and permuted or direction-flipped `conflict_edges` — must produce identical
cohort assignments across repeated invocations. The implementation must guard against these
enumerated hazards (research §4):

1. **Vertex order derived from input iteration order.** Sorting by the total-order key
   `(-degree, item_key)` is the single load-bearing guard. Never sort by insertion order; never
   rely on sort stability to break ties.
2. **Set iteration.** Adjacency stored as `set[int]` is safe for the min-excluded-index
   computation (order-insensitive set membership) but must never be iterated to produce an
   ordered result. Any place a set or dict feeds an ordered output must pass through
   `sorted(...)` first — including the final per-cohort key lists.
3. **Dict insertion order.** Python dicts preserve insertion order; building the result by
   iterating an insertion-ordered structure silently encodes input order. Emit cohort membership
   sorted ascending explicitly.
4. **Mixed-type or duplicate item keys.** Closed by the `int`-key contract; duplicate keys break
   the uniqueness assumption behind the total order and are rejected as malformed input.
5. **Tie-break direction.** An accidental descending tie-break is also deterministic but wrong.
   A dedicated test with equal-degree vertices must verify ascending item-key tie-breaking.

## Error Handling

One dedicated exception class, mirroring the `EpicWaveCycleError(ValueError)` precedent:

- **`ParallelCohortInputError(ValueError)`** — raised for every malformed-input mode, with a
  specific literal message per mode and an attribute identifying the offending value (mirroring
  `EpicWaveCycleError.feature_folder`).

| Failure mode | Raised by | Message content |
| --- | --- | --- |
| Edge endpoint not in `item_keys` | `compute_cohorts` | Names the unknown key and the offending edge |
| Self-loop (`a == b`) | `compute_cohorts` | Names the self-conflicting key |
| Duplicate key in `item_keys` | `compute_cohorts` | Names the duplicated key |
| Non-positive `max_concurrency` (`< 1`) | `compute_concurrency_batches` | States the invalid value and the `>= 1` requirement |

A self-loop is malformed rather than "item serializes alone" because `conflicts(a, b)` is defined
over distinct items (design §5.4); a self-edge can only be produced by an F1 defect, and failing
fast surfaces that defect (fail-closed, epic Shared Design item 7). Keep exception messages simple
and stable: the epic-wave TypeScript mirror pins message text verbatim, so a future mirror of this
module would do the same.

## Constraints & Risks

- **Optimality is explicitly not the objective; determinism and explainability are.** Design
  §13.3 accepts that greedy Welsh-Powell coloring is not optimal and that cohort counts will be
  at or above the chromatic number. Substituting an optimal or randomized coloring algorithm
  violates the accepted design.
- **Determinism is an epic NFR.** Identical inputs must produce identical cohort assignments,
  including under permuted input orderings. Any iteration over an unordered container must be
  explicitly ordered before use.
- **Additive only.** `epic_wave_computation.py` and the other epic implementations must not be
  modified or refactored into a shared abstraction. Reuse is by near-verbatim adaptation into the
  new file.
- **Boundary with F1.** The `conflicts(a, b)` relation and the blast-radius model belong to F1
  (`parallel-blast-radius`), prepared concurrently. This module consumes the already-computed
  edge set only. F3 serializes both sides into the checkpoint schema, so the contract must be
  JSON-representable (satisfied by the array-based input and output shapes above).
- **The surface is named `parallel` throughout**; module name `parallel_cohort_computation.py`
  is fixed by the epic.
- **File-size limit:** 500 lines per production and test file.
- **No new Python dependencies.** `hypothesis` is not in `pyproject.toml` and must not be added;
  T4 classification does not require property-based tests.
- **F2 must not create or modify `quality-tiers.yml`.** Resolving that missing file is F1
  research scope in the same wave; touching it here would create the shared-surface conflict this
  epic is designed to prevent.
- **`.claude/skills/atomic-plan-contract/SKILL.md` is not modified** (epic non-goal).

## Non-Goals

- **Optimal or randomized coloring.** Design §13.3 accepts greedy Welsh-Powell in exchange for
  determinism; cohort counts will be at or above the chromatic number. DSatur with randomized
  ties, ILP, and similar approaches are out of scope.
- **Computing blast radii or evaluating `conflicts(a, b)`.** F1 scope. This module consumes the
  computed edge set only.
- **Pinned-set / recolor-generation mechanics.** F6 scope (design §8.1, §8.6). No pinned-set
  parameter, no generation counter. The docstring states the induced-subgraph composition pattern
  by which callers satisfy the pinning invariant.
- **A PowerShell counterpart (`.claude/lib/**` module).** Research §7 verified empirically that
  `epic_wave_computation.py` has no PowerShell counterpart and that no PowerShell surface
  recomputes coloring (F7's barrier hook reads the checkpoint's already-computed cohort table).
  F2 ships Python only; "parity test" means a deterministic pytest suite with exact-output
  scenario assertions, structured so a future mirror can replicate the same scenario fixtures.
- **Modifying the atomic-plan contract** (`.claude/skills/atomic-plan-contract/SKILL.md`).
- **Modifying or refactoring the existing epic implementations**, including
  `epic_wave_computation.py`.
- **Creating `quality-tiers.yml`** (F1 scope).
- **Serializing cohorts into the manifest or checkpoint** (F3 scope).

## Implementation Strategy

- **Scope of change (additive only):**
  - New: `scripts/dev_tools/parallel_cohort_computation.py` — exception
    `ParallelCohortInputError(ValueError)`, functions `compute_cohorts` and
    `compute_concurrency_batches`, internal helpers as needed. Estimated 250–350 lines including
    mandatory docstrings and intent comments; under the 500-line limit.
  - New: `tests/scripts/dev_tools/test_parallel_cohort_computation.py` (see Test Obligations).
  - No other file is created or modified.
- **Dependency changes:** none. Standard library only.
- **Logging/telemetry:** none; pure computation module.
- **Rollout:** none required; the module has no consumers until F3/F4/F5 land.
- **Coverage wiring:** automatic — `pyproject.toml` sets
  `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, so the new module is inside the
  coverage denominator without configuration changes. Pyright runs in `strict` mode over
  `scripts`.

## Test Obligations

**Quality tier: T4 (dev tooling)**, per research §8: no `quality-tiers.yml` exists at the repo
root; the prose classification in `.claude/rules/quality-tiers.md` places `scripts/dev_tools/**`
under T4 ("build scripts, dev tooling"), consistent with the precedent modules. Consequences:

- Uniform gates apply: Black format pass; Ruff zero errors; Pyright strict zero errors; **line
  coverage >= 85% and branch coverage >= 75%** for the new module.
- No property-based tests required (T1/T2 only) and no mutation score required (T1 only). The
  determinism NFR is covered by explicit permutation tests using fixed literal permutations, not
  seeded RNG.

**Test file layout:**

- Primary: `tests/scripts/dev_tools/test_parallel_cohort_computation.py`, single file, mirroring
  the structure and style of `tests/scripts/dev_tools/test_epic_wave_computation.py`
  (deterministic scenario tests, exact-output assertions, `pytest.raises` error paths, a test
  asserting the exception message names the offending value). Use `pytest.mark.parametrize` to
  compress the malformed-input and `max_concurrency` boundary matrices.
- Pre-approved fallback if the file approaches 500 lines: split into
  `tests/scripts/dev_tools/test_parallel_cohort_computation.py` (coloring: ordering, tie-breaks,
  determinism, graph shapes) and
  `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` (malformed input plus
  slot-filling boundaries). The executor must not improvise a different layout.

**Required test scenarios** (from `issue.md` test conditions, completed against research §4/§10):

1. Empty graph returns `[]`; single vertex; all-isolated vertices produce one cohort.
2. Complete graph on `n` vertices produces `n` singleton cohorts.
3. Welsh-Powell ordering: a graph where degree ordering changes the result versus insertion
   order.
4. Tie-breaking: equal-degree vertices ordered by ascending item key (a test that fails under an
   accidental descending tie-break).
5. Determinism: repeated invocation with identical input; permuted `item_keys`; permuted and
   direction-flipped `conflict_edges` — all produce identical output (fixed literal
   permutations).
6. Symmetry: an edge supplied in either direction, or duplicated, yields the same conflict and
   identical output.
7. Independent-set and coverage invariants: no cohort contains two adjacent vertices;
   concatenated cohorts cover `item_keys` exactly once; per-cohort keys ascending.
8. Slot filling: exact-multiple case (12 items, `max_concurrency = 4` → 4/4/4); remainder case
   (10 items, `max_concurrency = 4` → 4/4/2); `max_concurrency = 1` (singletons);
   `max_concurrency >= cohort size` (one batch); output concatenation equals the sorted cohort.
9. Malformed input: unknown edge endpoint; self-loop; duplicate item key; non-positive
   `max_concurrency` (0 and a negative value) — each raises `ParallelCohortInputError`, and at
   least one test per mode asserts the message names the offending value.

## Acceptance Criteria

- [ ] `scripts/dev_tools/parallel_cohort_computation.py` exists and exports
      `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]`
      implementing deterministic greedy coloring in Welsh-Powell order: vertices sorted by the
      composite key `(-degree, item_key)` ascending (descending distinct-neighbor degree, ties by
      ascending item key), each vertex assigned the lowest cohort index not used by any
      already-assigned neighbor.
- [ ] The module accepts an already-computed conflict graph (item-key set plus undirected edge
      list) as input, does not compute blast radii, and never evaluates `conflicts(a, b)`; the
      module docstring records the one-line reduction from F3's
      `conflict_edges[] = { a, b, reason }` checkpoint records to the accepted
      `Iterable[tuple[int, int]]` shape.
- [ ] Edge symmetry is guaranteed by internal normalization: an edge supplied as `(a, b)`, as
      `(b, a)`, or duplicated yields the same conflict, verified by a test asserting identical
      output for direction-flipped and duplicated edge lists.
- [ ] `compute_cohorts` output satisfies the structural invariants: every cohort is an independent
      set of the input graph; each cohort's item keys are sorted ascending; the concatenation of
      all cohorts covers `item_keys` exactly once; empty input returns `[]`; all-isolated input
      returns one cohort; a complete graph on `n` vertices returns `n` singleton cohorts — each
      verified by a dedicated test with exact-output assertions.
- [ ] `compute_concurrency_batches(cohort_item_keys: Sequence[int], max_concurrency: int) -> list[list[int]]`
      implements the slot-filling rule: it sorts the cohort's keys ascending itself, then chunks
      into consecutive batches of at most `max_concurrency`; tests cover the exact-multiple case
      (12 items at `max_concurrency = 4` → three batches of four), the remainder case (10 items at
      `max_concurrency = 4` → batches of 4, 4, 2), `max_concurrency = 1` (singleton batches), and
      `max_concurrency >= cohort size` (one batch), and assert that batch concatenation equals
      the ascending-sorted cohort.
- [ ] Determinism is verified by explicit tests using fixed literal permutations: repeated
      invocation with identical input, permuted `item_keys`, and permuted plus direction-flipped
      `conflict_edges` all produce identical cohort assignments.
- [ ] A dedicated tie-break test with equal-degree vertices verifies ascending item-key ordering
      (the test fails under an accidental descending tie-break), and a dedicated test shows
      Welsh-Powell degree ordering producing a different result than insertion order.
- [ ] `ParallelCohortInputError(ValueError)` is the single dedicated exception, raised for all
      four malformed-input modes — unknown edge endpoint, self-loop, duplicate item key,
      non-positive `max_concurrency` — carrying an attribute identifying the offending value;
      tests assert the exception type per mode and that the message names the offending value.
- [ ] Both public functions are pure: no file I/O, no network, no clock or RNG access, no
      mutation of input arguments; the module docstring documents that `generation` /
      `recolor_generation` and `current_cohort` are caller-owned, and that recoloring over a
      mutated set is performed by invoking `compute_cohorts` on the induced not-yet-started
      subgraph with in-flight items excluded by the caller (no pinned-set parameter).
- [ ] The parity test suite exists at
      `tests/scripts/dev_tools/test_parallel_cohort_computation.py` (with
      `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` as the only permitted
      split fallback), in the manner of `tests/scripts/dev_tools/test_epic_wave_computation.py`:
      deterministic scenario tests with exact-output assertions, `pytest.raises` error paths, and
      replicable scenario fixtures; no PowerShell module is created (research §7 scope decision).
- [ ] Line coverage >= 85% and branch coverage >= 75% for
      `scripts/dev_tools/parallel_cohort_computation.py`, measured by
      `poetry run pytest --cov --cov-branch`; Black, Ruff, and Pyright (strict) each pass with
      zero errors.
- [ ] The change is additive only: no existing epic implementation (including
      `epic_wave_computation.py`) is modified or refactored; `quality-tiers.yml` is neither
      created nor modified; no new Python dependency is added (no `hypothesis`); both new files
      are each under 500 lines.

## Definition of Done

- [ ] All Acceptance Criteria above are checked off with evidence (test names or toolchain
      output) recorded by the executor.
- [ ] Behavior matches the Welsh-Powell, slot-filling, determinism, and error-handling rules in
      this spec exactly.
- [ ] Tests added at the specified path(s); edge cases and error handling covered.
- [ ] Toolchain pass completed in a single clean pass (format → lint → type-check → test).
- [ ] No file outside the two named new files is created or modified.
