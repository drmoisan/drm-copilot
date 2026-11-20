# Code Review — 2026-08-07-parallel-mutation-protocol-442 (Remediation Cycle 1 Exit Gate)

- **Timestamp:** 2026-08-09T03-58
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Scope:** full branch diff `c939b5b8` → `fc10a471`, with the remediation cycle
  `a9e2463c` → `fc10a471` reviewed in detail
- **Prior review:** `code-review.2026-08-09T00-19.md`

## Summary

The cycle's central change is small and well-targeted: two lines of decision logic
(`parallel_mutation_protocol.py:183` and `:327`), two signature changes, and a substantial
strengthening of the test surface (five new test modules, 1636 net new test lines). The API
changes are made in the safest available shape — both new parameters are required and keyword-only,
so neither defect can be reintroduced by omission or by positional transposition. Documentation
was updated at every consumer.

**Blocking correctness concerns: none.** Two Partial items and six Advisory items, all recorded in
`policy-audit.2026-08-09T03-58.md`.

## Correctness

### The two corrections are minimal and the right shape

`decide_admission` (`parallel_mutation_protocol.py:121-197`) changes exactly one expression:

```python
blocking_keys = in_flight | current_cohort_members
```

`in_flight` is deliberately retained as a separate parameter rather than folded into
`current_cohort_members`. The docstring at `:156-165` argues this preserves a real semantic
distinction — one set is the pinning set, the other is cohort membership — and that conflating them
in the signature would lose it. I agree: `in_flight` is consumed elsewhere in the engine
(`decide_removal`, `decide_close`) with pinning semantics, and a single merged parameter would make
the call sites at `parallel-add/SKILL.md` ambiguous about which set the caller must derive. The
union is formed at exactly one point, in the function body, where it is visible.

`recolor_unstarted` (`:200-341`) is a three-part change: the guard at `:292-297`, the predicate at
`:302-306`, and the offset at `:327` plus its application at `:332-336`. The ordering of the
predicate before the induced restriction is the whole correctness argument, and it is made
textually obvious rather than depending on a reader tracking data flow.

### Keyword-only placement is load-bearing, not decoration

Both new parameters are required and keyword-only. The docstrings say why, and both reasons are
substantive:

- `current_cohort_members` (`:156-165`): "a default would silently restore the defective
  in-flight-only rule, and keyword-only placement makes it impossible to pass a different set
  positionally."
- `current_cohort` (`:258-262`): "a default would silently restore the defective
  re-index-from-zero behavior, and keyword-only placement prevents a silent transposition with
  `current_generation`, the other `int` parameter."

The transposition argument is the stronger one. `recolor_unstarted(items, edges, pinned, 4, 0)`
versus `(items, edges, pinned, 0, 4)` would both type-check and both produce a plausible-looking
result; only the keyword requirement makes the mistake impossible. This is the correct design
response to a defect class that ships silently.

### The negative-index guard is well-placed

`:292-297` rejects `current_cohort < 0` with F2's existing `ParallelCohortInputError` rather than a
new exception type, citing F3 invariant 12's non-negative-index requirement. Reusing F2's error
type is right — the failure is an invalid coloring input, and inventing an F6 exception for it
would grow the public error surface for no benefit. The check sits before `compute_cohorts` so a
negative base fails fast rather than producing an unwritable assignment.

### The `crosses_pinned` predicate is a duplicate-free single derivation

The engine computes it once at `:302-306`. The three test modules each recompute it independently
(`test_parallel_mutation_contention_properties.py:73-96`,
`test_parallel_mutation_protocol_properties.py:164-181`), which is correct for a test oracle —
deriving the expectation from the engine's own output would make the offset assertion vacuous, and
the docstring at `:76-79` says so explicitly.

### Op-classification duplication is eliminated, not merely asserted away

The prior review's Partial was three tuples copied at two sites. The fix imports F3's originals
(`_parallel_mutation_models.py:73-80`, `_parallel_orchestrator_state_mutations.py:73-80`) and
deletes both copies, which is the stronger of the two remedies the prior review offered — an
equality assertion would still permit two objects to exist and drift between test runs, whereas
identity by import makes divergence impossible by construction.

The binding tests use `is` rather than `==`
(`test_parallel_mutation_protocol.py:135-167`), so they assert object identity, and a parametrized
guard at `:172` names the three deleted copy constants (`ITEM_SCOPED_OPS`,
`OPS_WITH_NULL_PRIOR_STATE`, `OPS_WITH_NULL_NEW_STATE`) so a reintroduced copy fails. That is the
correct pair: identity for the current state, name-absence for the regression.

### The FR9 amendment matches the code

I read `_parallel_orchestrator_state_mode_completion.py:1-59` and `:249-289` against the amended
`spec.md:266-278`. Every clause of the amended text corresponds to executed logic:

| Amended spec clause | Code |
|---|---|
| "two signals ... a `mutations[]` `op == 'close'` record and an empty current-generation cohort set" | `close_positions` gate at `:281-283`; `_has_schedulable_work` at `:287-288` |
| "In `open` mode the close record must additionally be terminal" | `_validate_open_mode_termination` at `:285` |
| "does not fire on a healthy in-progress checkpoint" | early `return []` when no close recorded, `:282-283` |
| "nor on an idle `open` run whose items have all merged" | same gate; documented at `:38-43` |
| "Closed-mode completion itself is guarded by F3's own invariant 20 ... which F6 deliberately does not duplicate" | `_validate_closed_mode_completion` reached only when both signals present, `:289` |

The amendment describes the implementation rather than the implementation approximating the
requirement. Amending the requirement here is legitimate: the two-signal form is a genuinely
additive invariant over the schema F3 actually carries (no completion field exists and F6 may add
none), and the conjunction is load-bearing rather than padding — the prior review verified that
requiring the close record alone would break the landed F3 test at
`test_validate_parallel_orchestrator_state_completion.py:110`. This is not a requirement bent to
match a weak implementation.

## Test Quality

### The two rewritten tests are strictly stronger

I read both against their `a9e2463c` predecessors.

`test_cohort_indices_are_contiguous_from_zero` → `test_cohort_indices_are_contiguous_from_the_computed_offset`
(`test_parallel_mutation_protocol_properties.py:291-314`). The old test asserted
`indices == set(range(len(indices)))`. The new one asserts
`indices == set(range(offset, offset + len(indices)))` **and** `min(indices) == offset`, where
`offset` comes from the independent `expected_offset()` derivation. It keeps the contiguity claim
and adds an offset-value claim. Strictly stronger.

`test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring` →
`test_pinned_edges_leave_the_class_structure_but_shift_the_assignment` (`:335-387`). The old test
asserted `run.recolor() == from_induced` — full result equality between the full-edge and
induced-edge calls. That assertion **codified the defect**: it can hold only if the pinned edges are
discarded constraint-and-all. The replacement splits the claim into the part that is still true and
the part that changed:

- `_classes(from_full) == _classes(from_induced)` — partition comparison, so a uniform shift cannot
  change it. This preserves the substantive original content (F2 receives the same induced
  subgraph).
- `full_base == run.expected_offset()`, `min(from_induced) == run.current_cohort`, and
  `crosses_pinned() ⟹ full_base > current_cohort` — the three assertions the old equality forbade.

The `_classes` helper (`:219-236`) is the right abstraction here: comparing grouped key sets
compares partitions rather than labels, which is exactly what "the class structure is unchanged"
means. One narrowing worth noting: the old full-`RecolorResult` equality also implied `generation`
equality, which the new test does not assert. Generation is separately and completely covered by
`test_generation_is_always_one_beyond_the_current` at `:282-289`, so nothing is lost — recorded as
Advisory A3 in the policy audit, not a defect.

### The `corrected (renamed)` disposition is legitimate

`test_admission_defers_exactly_when_a_pinned_neighbour_exists` →
`test_admission_defers_exactly_when_a_current_cohort_neighbour_exists`
(`test_parallel_mutation_contention_properties.py:247-280`).

Both are biconditional agreement properties over the same generated corpus, with the expectation
derived independently from the edge list. The only change is the blocking set:
`run.pinned` → `run.pinned | run.current_cohort_members`. Because the property is a biconditional,
widening the blocking set strengthens it in both directions — it now catches both under-deferral
against the wider set and over-deferral. My reversion 1 experiment confirms the strengthening is
real: four seeds of this test fail under the in-flight-only rule.

The rename is required, not cosmetic. Keeping the old name would have made the name false, which is
worse than renaming. This is a correct disposition, not a weakened assertion hidden behind a rename.

### The generated corpus models production faithfully

`GeneratedRun` in the contention module (`:99-220`) builds `current_cohort_members` by scanning keys
in a seed-derived order and admitting a key only when it is disjoint from what is already admitted
(`:153-159`) — the shape F2's coloring produces. `pinned` is then drawn as a **subset** of that
cohort (`:161-165`), mirroring production, where every pinned item occupies the cohort at
`current_cohort`. Without that constraint the property would test a fixture no coloring could have
produced, which is exactly what the per-run non-vacuity assertion at `:467-471` guards.

`current_cohort` is drawn from 0..4 (`:169`) and keys start at 100 (`:134`), so no assertion can
pass by assuming a zero base or zero-based keys.

### The F3 validator binding is proof by execution

`test_parallel_mutation_cohort_invariant_binding.py` is the strongest artifact in the cycle. It
constructs a complete parallel-orchestrator checkpoint from the recolor's **actual return value**
and runs F3's landed `validate_parallel_orchestrator_state_text` over it, asserting `errors == []`.
That is materially better than asserting that invariants 13 and 14 "remain satisfiable."

Two details raise its quality above the obvious:

1. `build_cohorts` (`:74-103`) seeds `by_index` with the pinned members *before* merging the
   returned keys, so the merge obligation is performed by the same helper that the positive cases
   exercise — the test cannot pass while silently taking a different path.
2. `TestMergeObligationIsNecessary` (`:273-326`) guards its own fixture precondition at `:299-301`
   (`min(assignments.values()) == current_cohort`), so if a future change made the offset
   unconditional, the necessity test would fail on its precondition rather than silently degenerate
   into the offset-applied case and pass for the wrong reason. That is careful test design.

### The C1 and C2 regression tests reproduce the findings exactly

`test_parallel_mutation_admission.py:66-88` is the prior audit's R1 reproduction verbatim: 100
`in_flight`, 200 `scheduled` in the current cohort, candidate 300 conflicting with 200 only.
`test_parallel_mutation_recolor.py:66-99` is the C2 scenario: pinned 100 at index 0, unstarted
{200, 300}, sole edge `(100, 300)` — the edge the induced subgraph drops. Both docstrings state
"the expectation is the CORRECTED one, so this test fails against the pre-fix engine and must never
be weakened to accommodate it," which is the right marker to leave for a future maintainer.

Both class docstrings also explicitly scope what they do **not** assert (`admission.py:58-61`
defers cohort indices to the recolor module; `recolor.py:52-56` defers the admission verdict to the
admission module). That separation keeps a failure attributable to one function.

## Design and Maintainability

### The five-module test split is a reasonable response to the 500-line cap

The plan budgeted four new modules; execution needed five because the contention module measured
584 lines. The alternative — sharing a generator across modules — is forbidden by the plan's own
self-containment rule, which exists so that a property module's corpus cannot be silently changed
by an edit to a different file. Duplicating the generator is the cost of that rule, and it is the
right trade: three near-identical `GeneratedRun` classes are more maintainable than one shared
fixture whose semantics differ per consumer.

The duplication is acknowledged rather than hidden
(`test_parallel_mutation_contention_properties.py:16-19`: "This module is deliberately
SELF-CONTAINED ... The duplication is the cost of the repository's 500-line cap").

### Documentation is updated at every consumer, with the merge obligation stated three times

The merge obligation is the one part of the corrected contract the engine cannot enforce — it is a
consumer responsibility. Stating it in all three consuming skills plus the `RecolorResult`
docstring is proportionate, and each statement cites the concrete enforcement point
(`_parallel_state_structures.py:282-305`) rather than gesturing at "F3 invariant 13."

The `parallel-orchestrate/SKILL.md` addition also records both design corrections and their
rationale inline (`:492-503`), so a future reader of the skill does not need the spec to understand
why admission checks the whole cohort.

### Docstring accuracy

The `recolor_unstarted` docstring at `:214-225` is unusually good for this class of change: it
states plainly that "the pinning guarantee has two parts and the induced subgraph delivers only the
first," names what the induced restriction does and does not accomplish, and then says how the
second part is honoured. That framing is what makes the code reviewable without reconstructing the
defect from scratch.

The module-level docstring at `:39-46` was updated to match, and the `AdmissionOutcome` enum
docstring at `_parallel_mutation_models.py:120-133` was updated on both members. I found no
docstring left describing the pre-1.2 behavior in any Python file.

### Loops and branches carry intent comments

Every comprehension and loop introduced by this cycle has an intent comment immediately above it,
per `.claude/rules/self-explanatory-code-commenting.md`: the predicate at `:299-301`, the induced
restriction at `:308-312`, the offset at `:321-326`, the mapping derivation at `:330-331`, and the
edge scan at `:185-187`. The offset comment explains the decision criteria for both branches and
the injectivity rationale, which is the substantive part.

## Partial Findings

### P1 (NEW) — spec 1.2 left three pre-1.2 formulations in place

`spec.md:457` (`## Non-Negotiable Constraints` item 1), `:694`, and `:695` still carry the
two-argument recolor formulation and the in-flight-only admission wording. The normative-section
occurrence at `:457` is the one that matters: it contradicts amended FR4 at `:176`. Three one-line
documentation edits. Full detail in `policy-audit.2026-08-09T03-58.md` § Finding P1.

### P2 (carried, reduced) — S603 comment format

`parallel_mutation_abandon_cli.py:152-154`. The inert-directive half of the prior finding is
resolved; the verbatim-format half is deviated with a measured rationale (95 characters against an
88-character limit, with the call expression's length fixed by a test monkeypatch seam). Every
substantive requirement of the rule is met. Not a merge gate. Full detail in
`policy-audit.2026-08-09T03-58.md` § Finding P2.

## Advisory

- **A2** — `test_parallel_mutation_protocol_ops.py` and `test_parallel_mutation_protocol_properties.py`
  are both at exactly 500 lines. The next edit to either forces a split. Worth noting for whoever
  touches them next; not a defect now.
- **A3** — the rewritten pinned-edges test no longer asserts `generation` equality (covered
  elsewhere). Net strictly stronger.
- **A4** — the F6 op-classification imports form a second, comment-separated block from the same
  package rather than merging into the existing group. Ruff has `I` selected and passes, because
  isort treats a comment-separated block as its own section. Stylistic; the comment explaining *why*
  the constants are imported has real value and justifies the separation.
- **A6** — a `blocked` item may sit outside every current-generation cohort under F3 invariant 13,
  so the cohort map is not a total partition of `items[]`. Not a contention hazard (a `blocked` item
  does not execute), but a reader reasoning about "every item has a cohort" should know.

## Best-Practice Checklist

| Practice | Assessment |
|---|---|
| Simplicity first | Two changed expressions, one new guard. No new abstraction introduced. |
| Reusability | Op-classification duplication eliminated by import. F2's error type reused for the negative-index guard. |
| Extensibility | Both new parameters keyword-only, so future parameters can be added without breaking callers. |
| Separation of concerns | The engine decides and never applies; coloring stays in F2; the offset is applied entirely inside F6. Admission verdicts and cohort indices are asserted in separate test modules. |
| Fail fast | `UnknownItemError` on pinned/unstarted overlap; `ParallelCohortInputError` on a negative base. Neither is silently coerced. |
| Naming | `crosses_pinned`, `cohort_offset`, `blocking_keys`, `current_cohort_members` — all descriptive and unabbreviated. |
| Public API compatibility | Two breaking signature changes, both required by the corrections. All four in-repo callers (three skills, one engine docstring) updated; both changes recorded as deliberate divergences in `spec.md` § Design corrections. |
| Dependencies | None added. `hypothesis` remains absent. |
| I/O boundaries | Engine is pure: no file I/O, no network, no RNG, no wall clock, no argument mutation. Asserted by `test_no_engine_call_mutates_the_generated_run` and `test_recolor_does_not_mutate_its_inputs`. |
| Docstrings and comments | Mandatory sections present on every function and class; intent comments on every loop, comprehension, and non-trivial branch; no numbered notes. |
| File size | All files <= 500 lines. |
| Determinism | Injected clock seam (required parameter, no default); seeded `random.Random` with the seed in every message and case id; no sleeps or retries. |
