# Upstream Contract Re-Verification — F2 `compute_cohorts` Coloring Entry Point ([P1-T5])

Timestamp: 2026-08-08T21-48

Command: `Grep '^def |^class |^__all__|ParallelCohortInputError' scripts/dev_tools/parallel_cohort_computation.py`
EXIT_CODE: 0

Command: `Read scripts/dev_tools/parallel_cohort_computation.py` (lines 266-420)
EXIT_CODE: 0

Command: `wc -l scripts/dev_tools/parallel_cohort_computation.py` → 468 lines (cap 500)
EXIT_CODE: 0

## Exact Signature

```python
def compute_cohorts(
    item_keys: Iterable[int],
    conflict_edges: Iterable[tuple[int, int]],
) -> list[list[int]]:
```

(`scripts/dev_tools/parallel_cohort_computation.py:350-353`.)

| Element | Expected | Landed | Verdict |
| --- | --- | --- | --- |
| Name | `compute_cohorts` | `compute_cohorts` (line 350) | no divergence |
| Param 1 | `item_keys: Iterable[int]` | `item_keys: Iterable[int]` (line 351) | no divergence |
| Param 2 | `conflict_edges: Iterable[tuple[int, int]]` | identical (line 352) | no divergence |
| Return | `list[list[int]]` | `list[list[int]]` (line 353) | no divergence |
| Key type | `int`, not `str` | `int` throughout | no divergence |

## Documented Determinism Contract

The docstring at lines 356-362 states verbatim: "Vertices are visited in Welsh-Powell
order — sorted by the composite key `(-degree, item_key)` ascending, that is
descending distinct-neighbor degree with ties broken by ascending item key — and each
vertex is assigned the lowest cohort index not already held by one of its neighbors."

Confirmed in the implementation:

- `_welsh_powell_order` (line 266) returns
  `sorted(adjacency, key=lambda item_key: (-len(adjacency[item_key]), item_key))`
  (lines 293-296) — exactly the composite key `(-degree, item_key)` ascending. Its
  docstring at lines 269-274 records this as "the single load-bearing determinism
  guard", explicitly rejecting reliance on sort stability.
- `_assign_cohort_indices` (line 299) scans upward from index 0 for the first index
  not held by an assigned neighbor (lines 341-345), so every index class is an
  independent set (docstring lines 313-315).
- Cohort membership is filled by walking `sorted(cohort_index_by_key)` (line 413),
  never insertion order, so each inner list is ascending regardless of caller input
  order.

Verdict: no divergence.

## Return Shape

`list[list[int]]` — the COHORT LIST. Docstring lines 380-385: "The cohorts, where list
position is the cohort index and each inner list holds that cohort's item keys sorted
ascending. Empty input returns `[]`. Every cohort is an independent set of the conflict
graph, and the concatenation of all cohorts covers `item_keys` exactly once."

It is NOT a mapping return shape. Verdict: no divergence.

## The One-Line Mapping Derivation

The docstring itself prescribes the caller-side derivation at lines 364-367: "The
alternative `item_key -> cohort_index` view is derived in one line from the returned
list: `{key: index for index, cohort in enumerate(cohorts) for key in cohort}`. This
function returns the cohort-list shape only."

This is byte-identical to the derivation the plan specifies for [P2-T3].
Verdict: no divergence.

## Sibling Function Is Not the Coloring Entry Point

`compute_concurrency_batches` exists at line 419 with the signature beginning
`compute_concurrency_batches(cohort_item_keys: Sequence[int], ...)`. It is a
concurrency-batching helper, NOT the coloring entry point. F6 does not call it.
Verdict: no divergence.

## Input Validation and Error Type

`ParallelCohortInputError(ValueError)` is declared at line 65. The `compute_cohorts`
`Raises:` section (lines 388-390) states: "If `item_keys` contains a duplicate key, or
if any edge is a self-loop or names an endpoint outside `item_keys`. All validation
runs before any coloring work."

Confirmed: `_validate_item_keys` (line 129) raises on a duplicate key (line 160);
`_validate_edge` (line 170) raises on a self-loop (line 196) and on an endpoint
outside the known key set (line 208); `compute_cohorts` calls both through
`_validate_item_keys` (line 397) and `_build_adjacency` (line 398) before any
ordering or assignment work. Verdict: no divergence.

## Purity

Docstring `Side Effects:` at lines 392-394: "None. This function is pure: no file I/O,
no network, no clock or RNG access, and no mutation of either input argument." Neither
helper mutates its arguments (`_welsh_powell_order` line 288, `_assign_cohort_indices`
line 321). Verdict: no divergence.

## Recorded Delegation Statement (required by the task text)

**`recolor_unstarted` ([P2-T3]) DELEGATES to `compute_cohorts` and derives the
`item_key -> cohort_index` mapping view from the returned `list[list[int]]` cohort
list using the one-line comprehension
`{key: index for index, cohort in enumerate(cohorts) for key in cohort}`.
F6 reimplements NO part of the coloring, NO part of the Welsh-Powell vertex ordering,
and NO part of the `(-degree, item_key)` tie-break. F6 does not call
`compute_concurrency_batches`.**

`recolor_unstarted`'s own work is confined to (a) taking the induced subgraph of
unstarted items — dropping every edge with an endpoint outside `unstarted_items`,
which is the mechanism that excludes pinned vertices from the coloring input — (b)
delegating to `compute_cohorts`, (c) deriving the mapping in one line, and (d)
returning `current_generation + 1` as the result generation.

## Output Summary

Overall verdict: **NO DIVERGENCE.** The landed entry point is
`compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]])
-> list[list[int]]` at `scripts/dev_tools/parallel_cohort_computation.py:350`, with
`int` keys, the `list[list[int]]` cohort-list return shape, the documented Welsh-Powell
`(-degree, item_key)` determinism contract, the docstring-prescribed one-line mapping
derivation, `ParallelCohortInputError` on duplicate keys and invalid edges, and a
documented purity guarantee. `compute_concurrency_batches` is confirmed present and
confirmed NOT the coloring entry point. The delegation statement for [P2-T3] is
recorded. The Phase 1 stop rule is NOT triggered.
