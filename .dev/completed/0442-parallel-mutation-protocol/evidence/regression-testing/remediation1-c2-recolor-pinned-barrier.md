# C2 Regression — Recolor Pinned-Barrier Offset

Timestamp: 2026-08-09T06-51

Task: [P2-T4] `[expect-fail]`
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
Test module: `tests/scripts/dev_tools/test_parallel_mutation_recolor.py`
Test id: `TestPinnedBarrierOffsetRegression::test_deferred_candidate_is_not_placed_in_the_pinned_cohort`

## Fail-Before

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_recolor.py -v`
EXIT_CODE: 1

Required outcome for this `[expect-fail]` task is `EXIT_CODE: 1` with the assertion reporting
`cohort_assignments[300] == 0`. **The observed exit code is 1 and the observed assertion is
`assert 0 != 0`, i.e. `cohort_assignments[300] == 0`, so the required outcome is met.** The non-zero
exit is the success condition for this task and does not restart any toolchain loop.

Output Summary: `1 failed in 0.10s` (1 collected, 1 failed, 0 passed). The failure is an
`AssertionError`, **not a `TypeError`**, so the demonstration is BEHAVIORAL against the shipped
four-argument implementation rather than an artifact of a signature change. Verbatim assertion
output:

```
>       assert result.cohort_assignments[300] != pinned_cohort_index
E       assert 0 != 0
```

The observed pre-fix assignment mapping in full, captured by calling the shipped engine directly
with the same arguments:

```
cohort_assignments = {200: 0, 300: 0}
generation = 8
```

Both unstarted items — the untouched `scheduled` member 200 and the just-deferred candidate 300 —
collapsed into cohort index **0**, which is the pinned items' own index in this fixture. The
deferred candidate was returned to the very pinned item it conflicts with. The generation did
increment correctly to 8 (`current_generation + 1` from 7), which confirms the defect is confined to
WHICH index is assigned, not to the generation arithmetic.

## Reproduction Premise

- Item **100** is `in_flight` and occupies cohort index **0**, which is the current cohort. Its
  durable occupancy of that index follows from the cohort barrier: `current_cohort` increments only
  on durable confirmation that every cohort-`N` item is `merged` or `worktree_removed`
  (`.claude/skills/parallel-orchestrate/SKILL.md`, the `**Cohort barrier.**` paragraph), and an
  `in_flight` item is neither, so `current_cohort` cannot advance while any item runs.
- Items **200** (`scheduled`) and **300** (the candidate just deferred) are unstarted.
- The only conflict edge is **`(100, 300)`** — candidate-to-pinned, which is exactly the edge the
  induced-subgraph comprehension drops because one endpoint (100) is not in `unstarted_items`.
- Call under test: `recolor_unstarted([200, 300], [(100, 300)], frozenset({100}), 7)`.
- Mechanism of the defect: with the sole edge dropped, 200 and 300 are both isolated vertices. F2's
  `compute_cohorts` documents that a key appearing in no edge lands in cohort 0, so both are
  assigned index 0. Index 0 is the pinned items' index, so 300 co-schedules with 100.
- Corrected expectation: `cohort_assignments[300]` must NOT be the pinned items' index 0. Under the
  pinned-barrier offset, `crosses_pinned` is true (edge `(100, 300)` joins unstarted 300 to pinned
  100), so `cohort_offset = current_cohort + 1 = 1` and every unstarted item is placed at index 1 or
  above.

## Ordering

**[P2-T2] ran first** — the C1 admission demonstration against
`tests/scripts/dev_tools/test_parallel_mutation_admission.py`, recorded in
`<FEATURE>/evidence/regression-testing/remediation1-c1-admission-cohort-independence.md` with
`EXIT_CODE: 1` and the observed `ADMIT_CURRENT_COHORT` outcome. This run is executed against its
OWN module in isolation (`test_parallel_mutation_recolor.py` only, one collected test), so neither
failure can be mistaken for the other. **No engine change has yet been made** at the time of this
run: `git status --porcelain -- scripts/` reports no modification to any production file. The next
step is [P2-T5], which runs the whole suite once with both regressions red.

## Pass-After

Timestamp: 2026-08-09T08-10

Task: [P4-T13]

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py -v`
EXIT_CODE: 0
Output Summary: **43 passed**, 0 failed. The C2 regression test
`TestPinnedBarrierOffsetRegression::test_deferred_candidate_is_not_placed_in_the_pinned_cohort`
now PASSES against the corrected engine, with its assertion unchanged in substance — still
`cohort_assignments[300] != pinned_cohort_index` where `pinned_cohort_index` is 0. The only change
between the fail-before and pass-after runs is the added required keyword argument
`current_cohort=pinned_cohort_index` ([P4-T3]); no assertion was weakened, added, or removed. Under
the corrected engine `crosses_pinned` is true for edge `(100, 300)`, so `cohort_offset` becomes 1
and key 300 no longer occupies the pinned index 0.

Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. Every call site recorded PENDING-PHASE-4 by
[P3-T8] is migrated.

## Binding

Which reversion re-fails which test, each demonstrated by execution in
`<FEATURE>/evidence/regression-testing/remediation1-property-p4-binding.md`:

- **Removing `recolor_unstarted`'s pinned-barrier offset** re-fails this C2 regression test, all
  four `TestPinnedBarrierOffset` scenarios
  (`test_pinned_conflict_forces_an_index_above_current_cohort_at_zero`,
  `test_pinned_conflict_forces_an_index_above_a_non_zero_current_cohort`,
  `test_no_pinned_conflict_starts_exactly_at_current_cohort`,
  `test_offset_is_uniform_so_conflicting_items_stay_distinct`), and **property P4**. Measured:
  `6 failed, 20 passed`.
- **Making the offset unconditional** re-fails property P4,
  `test_no_pinned_conflict_starts_exactly_at_current_cohort`, and
  `test_pinned_free_run_at_zero_matches_the_pre_fix_assignment`. Measured: `3 failed, 23 passed`.
  This reversion is the one a pure contention assertion cannot detect; it is caught by the
  offset-value assertion.
- **Reverting `decide_admission` to the in-flight-only rule** re-fails the C1 regression test and
  property P4. Measured: `9 failed, 4 passed`.
