# Property P4 — Executed Proof That It Rejects All Three Reversions

Timestamp: 2026-08-09T07-45

Task: [P4-T8] (binding verification for the composed contention property)
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Property: `TestPropertyFourComposedContention::test_no_cohort_holds_a_conflicting_pair_across_admission_sequences`
Module: `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py`

P4's docstring states three binding relationships. Rather than assert them, each was
DEMONSTRATED by temporarily mutating the engine, running the property, and restoring the
engine. The engine was backed up before the first mutation and restored after each one; the
final state is byte-identical to the corrected engine and carries no mutation residue
(`grep -n "MUTATION" scripts/dev_tools/parallel_mutation_protocol.py` exits 1 with no match).

## Baseline — corrected engine

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py tests/scripts/dev_tools/test_parallel_mutation_pin_stability_properties.py -q`
EXIT_CODE: 0
Output Summary: `50 passed`.

## Reversion 1 — `decide_admission` reverted to the in-flight-only rule

Mutation: `blocking_keys = in_flight | current_cohort_members` replaced by
`blocking_keys = in_flight`.

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py -q`
EXIT_CODE: 1
Output Summary: `9 failed, 4 passed`. **P4 FAILED**, together with the per-function admission
property at seeds 34, 89, 144, 233 and four further seeds. The failing ids include:

```
FAILED ...::TestPropertyFourComposedContention::test_no_cohort_holds_a_conflicting_pair_across_admission_sequences
FAILED ...::TestPerFunctionAdmissionProperty::test_admission_defers_exactly_when_a_current_cohort_neighbour_exists[seed34]
```

Verdict: **P4 rejects the C1 reversion.**

## Reversion 2 — `recolor_unstarted`'s pinned-barrier offset REMOVED

Mutation: `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort` replaced by
`cohort_offset = 0` (the pre-fix re-index-from-zero behavior).

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py -q`
EXIT_CODE: 1
Output Summary: `6 failed, 20 passed`. **P4 FAILED**, together with the C2 regression test and all
four offset scenarios:

```
FAILED ...::TestPropertyFourComposedContention::test_no_cohort_holds_a_conflicting_pair_across_admission_sequences
FAILED ...::TestPinnedBarrierOffsetRegression::test_deferred_candidate_is_not_placed_in_the_pinned_cohort
FAILED ...::TestPinnedBarrierOffset::test_pinned_conflict_forces_an_index_above_current_cohort_at_zero
FAILED ...::TestPinnedBarrierOffset::test_pinned_conflict_forces_an_index_above_a_non_zero_current_cohort
FAILED ...::TestPinnedBarrierOffset::test_no_pinned_conflict_starts_exactly_at_current_cohort
FAILED ...::TestPinnedBarrierOffset::test_offset_is_uniform_so_conflicting_items_stay_distinct
```

Verdict: **P4 rejects the removed offset.**

## Reversion 3 — the offset made UNCONDITIONAL

Mutation: `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort` replaced by
`cohort_offset = current_cohort + 1`.

This is the reversion the contention assertion **alone cannot detect**, because an unconditional
shift also vacates the pinned index, so no two conflicting items share an index and a pure
contention check still passes. It is caught by the offset-value assertion, which recomputes
`crosses_pinned` independently and pins the exact base.

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py -q`
EXIT_CODE: 1
Output Summary: `3 failed, 23 passed`. **P4 FAILED**, together with the two scenarios that pin the
offset-not-applied branch:

```
FAILED ...::TestPropertyFourComposedContention::test_no_cohort_holds_a_conflicting_pair_across_admission_sequences
FAILED ...::TestPinnedBarrierOffset::test_no_pinned_conflict_starts_exactly_at_current_cohort
FAILED ...::TestPinnedBarrierOffset::test_pinned_free_run_at_zero_matches_the_pre_fix_assignment
```

Verdict: **P4 rejects the unconditional offset.** This confirms the offset-value assertion is
load-bearing and not redundant with the contention assertion.

## Restoration

Command: `git diff --numstat a9e2463c -- scripts/dev_tools/parallel_mutation_protocol.py`
EXIT_CODE: 0
Output Summary: `141 35` — the engine's diff against the pre-remediation commit reflects only
this cycle's intended corrections. `grep -n "MUTATION" scripts/dev_tools/parallel_mutation_protocol.py`
exits 1 with no match, so no mutation text remains. The re-run after restoration reports
`50 passed`.

## Non-Vacuity Assertions Present and Passing

P4 additionally asserts, and these assertions themselves pass on the corrected engine:

1. the generated current cohort is an independent set of the FULL conflict graph (per run);
2. at least one run in the corpus yields `ADMIT_CURRENT_COHORT`;
3. at least one run yields `DEFER_AND_RECOLOR`;
4. at least one run contains a conflict edge joining an unstarted key to a pinned key;
5. at least one run **both** contains NO unstarted-to-pinned conflict edge **AND** performs at
   least one recolor, so the offset-value assertion is evaluated on the offset-not-applied
   branch (the clause added by preflight delta REV-20).

Because clauses 4 and 5 are both satisfied by the corpus, the offset-value assertion is evaluated
on both the offset-applied and offset-not-applied branches, which is what makes reversion 3
fail deterministically rather than by chance.

Determinism: the corpus is the fixed 12-seed tuple `(1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233)`
driven by `random.Random(seed)`; `GeneratedRun.__str__` emits the seed, key set, pinned set,
cohort membership, `current_cohort`, and edge list into every assertion message, and the pytest
case ids name the seed, so any failure is reproducible from the report alone. `hypothesis` is not
imported and remains absent from the repository.
