# Absorption A — F3 Fixture Collision Repair (ADJ-1) — Issue #440 (F7)

Timestamp: 2026-08-08T22-24

Authorization: orchestrator adjudication ADJ-1, absorbed into Phase 4. Not a task in the approved
plan `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md`.

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py -q`

EXIT_CODE: 0

## Failing Tests Repaired (5)

In `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py`:

1. `test_invariant_15_accepts_a_normalized_edge`
2. `test_invariant_15_accepts_every_edge_reason[path_overlap]`
3. `test_invariant_15_accepts_every_edge_reason[module_overlap]`
4. `test_invariant_15_accepts_every_edge_reason[shared_surface_overlap]`
5. `test_invariant_15_accepts_every_edge_reason[contract_dependency]`

Pre-repair failure, verbatim from the run:

```
E       AssertionError: assert ['PARALLEL_CO...flicting 445'] == []
E         Left contains one more item: 'PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445'
```

Pre-repair result: `5 failed, 8 passed, 32 deselected`.

## Adjudication Applied

F7's structural reading is CORRECT and was NOT narrowed or weakened. A cohort is a colour class of the
conflict graph, so two conflicting endpoints sharing a current-generation cohort index run concurrently
by construction; `validate_cohort_barrier_ordering` correctly emits one
`PARALLEL_COHORT_BARRIER_VIOLATION` for that configuration. The F3 fixture was the incoherent artifact:
`build_valid_parallel_state()` places items 444 and 445 in ONE current-generation cohort
(`cohorts == [{"index": 0, "generation": 0, "item_keys": [444, 445]}]`), which is a coherent colouring
only while `conflict_edges` is empty. The five tests then inject an edge between exactly those two
endpoints, producing a genuinely invalid colouring.

The F7 Phase 3 helper `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` was NOT edited.

## Remedy — `state_with_edges` Helper, Before and After

Change confined to the `state_with_edges` helper in
`tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py`. The shared builder
`build_valid_parallel_state()` (defined in
`tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py`, consumed by many other tests)
was NOT modified.

### Before

```python
def state_with_edges(edges: object) -> dict[str, object]:
    """Return a valid checkpoint whose conflict-edge list is replaced."""

    state = build_valid_parallel_state()
    state["conflict_edges"] = edges
    return state
```

### After

```python
def state_with_edges(edges: object) -> dict[str, object]:
    """Return a valid checkpoint whose conflict-edge list is replaced.

    The builder places both items in one current-generation cohort, which is a
    coherent graph colouring only while the conflict-edge list is empty. A
    cohort is a colour class of the conflict graph, so two items sharing a
    current-generation cohort index run concurrently by construction; an edge
    injected between them is an invalid colouring and earns a cohort-barrier
    violation on top of whatever edge-shape condition the caller is exercising.
    Split the two items into distinct current-generation cohorts so an injected
    edge is properly coloured and each test observes only its own condition.

    Invariants 13 and 14 continue to hold: indices 0 and 1 are unique within
    the current generation, every non-withdrawn item appears in exactly one
    current-generation cohort, and ``current_cohort`` of 0 does not exceed the
    maximum current-generation index of 1.
    """

    state = build_valid_parallel_state()
    state["cohorts"] = [
        {"index": 0, "generation": 0, "item_keys": [444]},
        {"index": 1, "generation": 0, "item_keys": [445]},
    ]
    state["conflict_edges"] = edges
    return state
```

The functional delta is one added statement: the two conflicting endpoints now occupy DISTINCT
current-generation cohorts (444 at index 0, 445 at index 1).

## Invariant Preservation (13 and 14)

| Parallel-orchestration invariant | Status after the repair |
| --- | --- |
| 13 — current-generation `index` uniqueness | Holds. Indices 0 and 1 are distinct. |
| 13 — every non-withdrawn item in exactly one current-generation cohort | Holds. 444 appears only at index 0; 445 appears only at index 1; both cohorts carry `generation == 0 == recolor_generation`. |
| 14 — `current_cohort` bound | Holds. `current_cohort` is 0, which does not exceed the maximum current-generation index of 1. |

Empirically confirmed: `test_invariant_12_*`, `test_invariant_13_*`, and `test_invariant_14_*` in the
same file all pass, and no invariant-12/13/14 error appears in any invariant-15 test result.

## Layer 2 Non-Violation After the Repair

Neither reading of the F7 invariant fires for the repaired fixture, so an accepted edge yields `[]`:

- **Structural reading** — the endpoints no longer share a current-generation cohort index.
- **Temporal reading** — the builder's items carry no `merge_status` key and no lifecycle timestamps.
  An absent `merge_status` is treated as `not_started`, so the later endpoint (445) has not started, and
  with both timestamps absent the check degrades to structural-plus-status per Frozen Constant 1. No
  temporal violation is available to fire.

## No Assertion Weakened

| Check | Result |
| --- | --- |
| `git diff --stat` | `1 file changed, 20 insertions(+), 1 deletion(-)` |
| The single deletion line | `-    """Return a valid checkpoint whose conflict-edge list is replaced."""` — the old one-line docstring, replaced by the expanded docstring. No assertion, no test body, and no test name was deleted or altered. |
| `assert` occurrences at `HEAD` | 26 |
| `assert` occurrences after the repair | 26 |
| `skip` / `xfail` occurrences | 0 |

Every existing assertion is preserved verbatim. Nothing was loosened, deleted, or marked skip/xfail.

## Invariant-15 Rejection Tests Still Pass Unchanged

All eight rejection tests in the same file pass with no source change:
`test_invariant_15_rejects_non_list_conflict_edges`, `..._rejects_non_object_edge`,
`..._rejects_self_edge`, `..._rejects_unresolved_endpoint[a]`, `..._rejects_unresolved_endpoint[b]`,
`..._rejects_unnormalized_pair`, `..._rejects_duplicate_pair`, `..._rejects_unknown_edge_reason`.

Each asserts membership (`<message> in errors`) rather than list equality, so their assertions remain
valid regardless of whether an additional barrier message is also present — and they pass either way.

Post-repair result for the whole file: `45 passed`. File length 367 lines (under the 500-line limit).

## Output Summary

PASS. The five failing invariant-15 acceptance tests now pass without any assertion being weakened. The
root cause was the F3 fixture, not F7's helper: `build_valid_parallel_state()` seats items 444 and 445
in a single current-generation cohort, so injecting a conflict edge between them is a genuinely invalid
graph colouring that correctly earns one `PARALLEL_COHORT_BARRIER_VIOLATION`. The remedy is one added
statement inside the `state_with_edges` helper, which now seats 444 at current-generation cohort index 0
and 445 at index 1, keeping invariants 13 and 14 satisfied. The shared builder was not modified, and
F7's Phase 3 helper was not modified. `git diff` shows 20 insertions and 1 deletion, that deletion being
the helper's old one-line docstring; the `assert` count is unchanged at 26 and there are zero
skip/xfail markers. The whole file reports `45 passed`, including all eight invariant-15 rejection tests
unchanged.
