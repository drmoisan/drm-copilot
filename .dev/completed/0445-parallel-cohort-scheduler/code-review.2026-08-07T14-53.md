# Code Review — 2026-08-07-parallel-cohort-scheduler-445

- **Timestamp:** 2026-08-07T14-53
- **Branch:** `feature/parallel-cohort-scheduler-445`
- **Base:** `epic/parallel-orchestration-integration` (merge base `8703d777`)
- **Files reviewed:** 3 new code files (965 lines total), read in full
- **Verdict:** **APPROVE** — 0 Blocking, 4 Advisory

## Files Under Review

| File | Lines | Kind |
|---|---|---|
| `scripts/dev_tools/parallel_cohort_computation.py` | 468 | New production module |
| `tests/scripts/dev_tools/test_parallel_cohort_computation.py` | 310 | New test file (coloring) |
| `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` | 187 | New test file (errors + slot filling) |

No pre-existing file is modified anywhere in the branch diff.

## Design Assessment

### Structure and separation of concerns

The module decomposes cleanly into a validation layer, a graph-construction layer, an ordering
layer, and an assignment layer, each in its own `_prefixed` helper with a single responsibility:

| Function | Lines | Responsibility |
|---|---|---|
| `_validate_item_keys` | 129-167 | Materialize keys, reject duplicates |
| `_validate_edge` | 170-213 | Reject self-loops and unknown endpoints |
| `_build_adjacency` | 216-263 | Normalize direction and duplicates into `dict[int, set[int]]` |
| `_welsh_powell_order` | 266-296 | Produce the deterministic visit order |
| `_assign_cohort_indices` | 299-347 | Greedy lowest-free-index coloring |
| `compute_cohorts` | 350-416 | Compose the above; emit sorted cohort lists |
| `compute_concurrency_batches` | 419-468 | Independent slot-filling rule |

`compute_cohorts` reads as a four-line pipeline (`:397-400`) followed by result assembly. This is
the simplest structure that expresses the algorithm and matches the
"Simplicity first" priority in `.claude/rules/general-code-change.md`. No god function, no deep
nesting — maximum nesting depth in the file is 3.

The public surface is exactly what `spec.md` "API / CLI Surface" specifies: two functions and one
exception. Everything else is private. `compute_concurrency_batches` is correctly independent of
`compute_cohorts` rather than folded into it, since `max_concurrency` caps fan-out orthogonally to
cohort membership.

### Function-versus-class judgment

`.claude/rules/python.md` says to create a standalone function when the operation is pure,
stateless, and a simple transformation. Both public operations are exactly that, and the module
docstring states "This module holds no state and persists nothing." Using module-level functions
rather than a `CohortScheduler` class is the correct call here — there is no state or invariant that
must travel together, and a class would add ceremony without a seam. The one class,
`ParallelCohortInputError`, exists because it genuinely carries data (`offending_value`) with
behavior (`ValueError` catchability).

### Error handling

Strong. Four failure modes, each with a distinct literal message that names the offending value, and
a typed `offending_value` attribute whose per-mode type is documented on the class
(`:84-99`). Notable good decisions:

- **`ValueError` subclass** (`:65`) so existing `except ValueError` handlers keep working. Pinned by
  `test_parallel_cohort_input_error_is_catchable_as_value_error`.
- **Validation strictly before work.** `compute_cohorts` runs `_validate_item_keys` then
  `_build_adjacency` (which validates each edge as it consumes it) before any ordering or coloring,
  satisfying the spec's "All validation runs before any coloring work."
- **Self-loop checked before endpoint membership** (`:191-201`), with an explicit comment justifying
  the ordering: a self-edge is an upstream F1 defect and reporting it as such is more actionable
  than reporting a possibly-unknown endpoint on the same edge. This is precisely the kind of
  "why the ordering matters" comment `.claude/rules/self-explanatory-code-commenting.md` requires.
- **Duplicates rejected rather than silently deduplicated** (`:131-133`), with the reason stated:
  duplicates break the uniqueness assumption behind the total-order sort key. This is fail-fast
  reasoning tied to a real invariant rather than defensive boilerplate.

No `except` clause appears anywhere in the module, so there is no opportunity for a silent swallow.

### Algorithmic correctness

Traced by hand and confirmed against execution:

- **Normalization by construction.** Storing neighbors as `set[int]` and writing each edge to both
  endpoints (`:260-261`) makes direction and repetition irrelevant without any explicit dedup pass.
  Degree is then `len(adjacency[key])` — distinct neighbors after normalization, exactly as
  `spec.md` requires. This is a genuinely elegant reduction: one data-structure choice discharges
  three separate spec obligations (symmetry, dedup, degree definition).
- **Isolated vertices preserved.** `adjacency` is seeded from `item_keys` (`:252`) rather than
  inferred from edges, so a key appearing in no edge survives with an empty neighbor set and lands
  in cohort 0. The comment at `:250-251` states this rationale.
- **No index holes.** Greedy lowest-free-index guarantees that if a vertex takes index `k`, indices
  `0..k-1` were each held by one of its neighbors. Every index up to `max` is therefore populated,
  which is what makes the `cohort_count = max(...) + 1` allocation at `:407-408` safe and ensures no
  empty inner list is ever returned. This invariant is not stated in the code; see Advisory A-4.
- **Empty-graph short-circuit** (`:404-405`) prevents `max()` on an empty sequence, with a comment
  explaining exactly that.

### Determinism engineering

This is the strongest aspect of the change. The determinism guard is concentrated in one place —
the composite sort key at `:293-296` — and the code says so explicitly:

> "That is the single load-bearing determinism guard: the visit order depends on the graph alone,
> never on the caller's iteration order and never on Python's sort stability."

Two details deserve credit:

1. `sorted(adjacency, ...)` sorts the **mapping's key view**, not the caller's `item_keys` list.
   Sorting the caller's list would have produced identical output here, but sorting the key view
   removes the last syntactic path by which arrival order could ever leak in during future edits.
   The comment at `:291-292` shows this was deliberate.
2. The `neighbor_indices` set comprehension (`:332-336`) is the one place a set is iterated, and the
   comment above it (`:330-331`) explains why that is safe — the result is a set consumed only by a
   membership test. A reviewer does not have to re-derive that argument.

Both ordered outputs pass through `sorted(...)`: cohort membership at `:413` and batch contents at
`:461`. The `compute_concurrency_batches` docstring makes the reason explicit: "The cohort's keys
are sorted ascending inside this function rather than trusting the caller's ordering, so determinism
does not depend on caller discipline." Sorting a copy via `sorted()` rather than `.sort()` also
preserves the no-mutation contract.

### Documentation quality

The module docstring (`:1-55`) is unusually load-bearing and earns its length. It records five
distinct boundary contracts that downstream epic children (F1, F3, F4, F6) will need to cite:

- the input reduction `[(e["a"], e["b"]) for e in conflict_edges]` from F3's checkpoint record shape,
  with the reason the record shape is *not* accepted (it would invert the F3→F2 dependency);
- the contention-relation boundary (no blast radii, never evaluates `conflicts(a, b)`);
- caller ownership of `generation` / `recolor_generation` and `current_cohort`;
- the pinned-set boundary and the induced-subgraph composition pattern that replaces it;
- the purity contract.

Every function and helper carries a Google-style docstring with `Args:`, `Returns:`, `Raises:`, and
`Side Effects:`. The `Side Effects:` sections are used substantively — for example
`_validate_item_keys` states "The input iterable is read but not mutated," which is a real contract
statement rather than filler.

Docstrings are also honest about scope. `_validate_item_keys` notes that its returned list preserves
supplied order "only for error reporting; the coloring order is derived from the sort key, never
from this list's order" — pre-empting the exact misreading a future maintainer might make.

## Test Review

16 test functions across two files; 38 test cases after parametrization; all pass in 0.06s.

### Scenario coverage against the spec's nine required groups

| Spec group | Covered by | Status |
|---|---|---|
| 1. Empty / single / all-isolated | `..._empty_input_returns_no_cohorts`, `..._single_vertex_returns_one_singleton_cohort`, `..._all_isolated_vertices_share_one_cohort` | Covered |
| 2. Complete graph → n singletons | `..._complete_graph_returns_one_singleton_cohort_per_vertex` | Covered |
| 3. Welsh-Powell vs insertion order | `..._uses_degree_order_not_the_supplied_item_key_order` | Covered, discriminating (verified below) |
| 4. Ascending tie-break | `..._breaks_degree_ties_by_ascending_item_key` | Covered, discriminating (verified below) |
| 5. Determinism under fixed permutations | `..._repeated_invocation...`, `..._permuted_item_keys`, `..._permuted_and_flipped_edges` | Covered |
| 6. Edge symmetry / dedup | `..._treats_a_reversed_edge_as_the_same_conflict`, `..._collapses_duplicated_edges_into_one_conflict` | Covered |
| 7. Structural invariants | `..._never_places_two_conflicting_items_in_one_cohort`, `..._covers_every_item_key_exactly_once`, `..._emits_each_cohort_sorted_ascending` | Covered |
| 8. Slot filling boundaries | `SLOT_FILLING_CASES` × 2 tests (6 params each) | Covered |
| 9. Malformed input × 4 modes | `MALFORMED_GRAPH_CASES` (3), `..._rejects_non_positive_max_concurrency` (3 params), plus 2 message tests | Covered, one positional gap (A-1) |

Beyond the spec's nine groups, the suite adds two non-mutation tests covering both public functions.

### Discrimination check — the two fixtures that matter

The executor claimed it verified empirically that the `[P1-T10]` and `[P1-T11]` fixtures would fail
under the wrong ordering. This reviewer did not accept that claim. An independent reference colorer
was written with four selectable orderings — correct Welsh-Powell ascending, Welsh-Powell with a
**descending** tie-break, pure **insertion**-order greedy, and degree-only sort **relying on sort
stability** — and each fixture was run through all four:

```
=== [P1-T10] Welsh-Powell fixture (crown + pendant) ===
       welsh_asc: [[701, 702, 703], [704, 705, 706, 707]]  -> PASSES the assertion
      welsh_desc: [[701, 704], [705, 706, 707], [702, 703]] -> FAILS the assertion
       insertion: [[701, 704], [702, 705, 707], [703, 706]] -> FAILS the assertion
   degree_stable: [[701, 704], [702, 705, 707], [703, 706]] -> FAILS the assertion

=== [P1-T11] tie-break fixture (five-cycle) ===
       welsh_asc: [[901, 903], [902, 904], [905]]  -> PASSES the assertion
      welsh_desc: [[903, 905], [902, 904], [901]]  -> FAILS the assertion
       insertion: [[901, 903], [902, 904], [905]]  -> PASSES the assertion
   degree_stable: [[901, 903], [902, 904], [905]]  -> PASSES the assertion
```

**Both fixtures genuinely discriminate, and neither is a rubber stamp.**

- `[P1-T10]` is the stronger fixture than its task required: it rejects insertion-order greedy
  (its stated purpose), **and** it independently rejects a descending tie-break **and** a
  degree-only stable sort. Three wrong implementations die on this one assertion.
- `[P1-T11]` rejects the descending tie-break, which is exactly and only what `[P1-T11]` and
  acceptance criterion 7 require of it. It does not discriminate against insertion order — but that
  is not its job, and `[P1-T10]` covers that axis. The two fixtures are complementary rather than
  redundant.

The docstrings' claims about the wrong-ordering outputs are literally accurate. The `[P1-T10]`
docstring predicts insertion-order greedy yields `[[701, 704], [702, 705, 707], [703, 706]]`; the
reference colorer produces exactly that. The `[P1-T11]` docstring predicts a descending tie-break
yields `[[903, 905], [902, 904], [901]]`; the reference colorer produces exactly that. Neither
docstring overstates what its fixture proves.

For contrast, the complete-graph fixture was run through the same matrix as a control and, as
expected, does **not** discriminate against insertion order or a stable sort — correctly, since it
is a graph-shape test, not an ordering test, and makes no ordering claim.

### Test-quality checks

- **Fixed literal permutations, no RNG.** The determinism tests use hard-coded lists
  (`[447, 444, 446, 443, 445]` at `:164`, `[(446, 445), (447, 444), (446, 443), (445, 443)]` at
  `:178`). No `random`, no `shuffle`, no generated `permutations`. The only occurrence of the word
  "random" in either file is inside a docstring explaining why randomness was avoided (`:160-161`).
  `itertools.combinations` is imported but used only to *assert* the independent-set property
  (`:235`), never to generate input.
- **Exact-output assertions.** Every coloring test asserts a full `list[list[int]]` literal rather
  than a property like `len(cohorts) == 2`. No weakened assertions, no `assert result is not None`,
  no overbroad `pytest.raises(Exception)` — every error test names `ParallelCohortInputError`
  specifically and additionally asserts both the message content and the `offending_value`
  attribute.
- **No temp files, no sleeps, no external dependencies.** Confirmed by grep over both files.
- **Actionable failure messages.** The invariant tests attach f-string context, e.g. `:236-239`
  names the offending cohort index and the conflicting pair, and `:274` names which cohort is
  unordered. This satisfies `.claude/rules/general-unit-test.md` "Assertions must produce clear,
  actionable failure messages."
- **Arrange–Act–Assert.** Consistently followed, with blank-line separation between phases.
- **Independence.** Shared fixtures are module-level immutable-by-convention lists of `int`; no test
  mutates them, and the non-mutation tests build their own local copies before calling. Tests can
  run in any order.

### Mutation probe

To test the suite's durability rather than just its pass rate, one targeted mutant was applied and
reverted:

| Mutant | Location | Result |
|---|---|---|
| Validate only the second edge endpoint (`for endpoint in (second,)`) | `:206` | **SURVIVED** — 38/38 passed |

This is Advisory A-1. Under that mutant, an unknown key in the first position produces
`KeyError: 999` instead of `ParallelCohortInputError`. The production code is correct; the suite
simply does not pin the first-position case. The module was restored with `git checkout --` and
re-verified clean (`git status --porcelain` empty; 38/38 passing against the real implementation,
which raises the correct `ParallelCohortInputError` for `(999, 443)`).

## Findings

### Blocking (0)

None.

### Advisory (4)

**A-1 — Add an unknown-endpoint case with the unknown key in the first tuple position.**
`test_parallel_cohort_computation_errors.py:108-113`. Empirically demonstrated to leave a surviving
mutant (see Mutation probe). One additional `pytest.param` closes it. Rule:
`.claude/rules/general-unit-test.md` scenario completeness.

**A-2 — Remove the duplicated `batches == expected` assertion.**
`test_parallel_cohort_computation_errors.py:104`. The concatenation test re-asserts the exact
layout already pinned by `test_compute_concurrency_batches_matches_the_expected_batch_layout`
(`:80-88`) over the same parametrized matrix. Rule: `.claude/rules/python.md` "One behavior per
test." Cosmetic.

**A-3 — `test_module_public_surface_is_importable` bundles three assertions.**
`test_parallel_cohort_computation.py:21-26` asserts callability of both functions and the exception
hierarchy in one test. This is a legitimate smoke test and its three assertions describe a single
"public surface exists" behavior, so it is borderline rather than a clear violation. Noted for
completeness; no change required.

**A-4 — The no-empty-cohort invariant is relied upon but not documented.**
`parallel_cohort_computation.py:407-408` allocates `max(...) + 1` cohort slots and fills them at
`:413-414`, which is only safe because greedy lowest-free-index assignment cannot skip an index. The
`compute_cohorts` docstring documents coverage and independence but not this density property.
Suggest one sentence in the docstring or a comment above `:407`, since a future change to the
assignment strategy would silently start returning empty inner lists. Rule:
`.claude/rules/self-explanatory-code-commenting.md` "Key invariants/constraints."

## Strengths Worth Preserving

Recorded so a future maintainer does not "simplify" them away:

1. **`sorted(adjacency, ...)` rather than `sorted(item_keys, ...)`** at `:293`. Functionally
   equivalent today; structurally safer against future edits. The comment explains why.
2. **`set[int]` adjacency as the normalization mechanism.** One data-structure choice discharges
   edge symmetry, edge dedup, and the distinct-neighbor degree definition simultaneously.
3. **The comment at `:330-331`** pre-emptively justifying that the one set-iteration site is
   order-insensitive. This is the single point a determinism reviewer would challenge, and it is
   answered in place.
4. **Sorting inside `compute_concurrency_batches`** rather than trusting caller ordering, with the
   rationale stated in the docstring. Determinism does not depend on caller discipline.
5. **The `[P1-T10]` fixture's over-delivery** — it discriminates against three distinct wrong
   orderings, not just the one its task required.

## Verdict

**APPROVE.** The module is well-factored, correct, pure, and deterministic by construction rather
than by convention. Documentation is contract-oriented and load-bearing for downstream epic
children. The test suite is genuinely discriminating on the two axes that matter, verified
independently rather than taken on trust. The four Advisory items are refinements; none blocks
merge.
