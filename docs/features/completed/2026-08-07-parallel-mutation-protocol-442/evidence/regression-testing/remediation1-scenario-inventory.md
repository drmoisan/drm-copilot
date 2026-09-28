# Remediation Cycle 1 — Scenario Inventory (No Test Dropped, Renamed Away, or Weakened)

Timestamp: 2026-08-09T08-05

Task: [P4-T12]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Base for the "before" set: **`a9e2463c`** (read with `git show a9e2463c:<path>`)

## Check 1 — Enumerate the pre-remediation test names

Command: `git show a9e2463c:tests/scripts/dev_tools/test_parallel_mutation_protocol.py` and
`git show a9e2463c:tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`, each
scanned for `def test_<name>`
EXIT_CODE: 0

| Module at `a9e2463c` | `def test_` count |
| --- | --- |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` | 37 |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` | 18 |
| **Total unique names** | **55** |

## Check 2 — Enumerate the post-change test names

Command: the same scan over the post-change module set
EXIT_CODE: 0

| Module after this cycle | `def test_` count | Status |
| --- | --- | --- |
| `test_parallel_mutation_protocol.py` | 22 | EDIT (shed two relocated classes) |
| `test_parallel_mutation_protocol_properties.py` | 15 | EDIT (shed two relocated blocks; two tests rewritten) |
| `test_parallel_mutation_admission.py` | 11 | NEW |
| `test_parallel_mutation_recolor.py` | 13 | NEW |
| `test_parallel_mutation_contention_properties.py` | 2 | NEW |
| `test_parallel_mutation_pin_stability_properties.py` | 2 | NEW (see the recorded deviation below) |
| `test_parallel_mutation_cohort_invariant_binding.py` | 5 | NEW |
| `test_parallel_mutation_protocol_ops.py` | 24 | **UNCHANGED — byte-identical to `a9e2463c`** |
| `test_parallel_mutation_abandon_cli.py` | 19 | **UNCHANGED — byte-identical to `a9e2463c`** |
| **Total unique names** | **112** | |

Command: `git diff --numstat a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py`
EXIT_CODE: 0
Output Summary: **empty output** — both modules are byte-identical to `a9e2463c`, so their 43
names are untouched by this cycle.

## Check 3 — Per-name disposition of all 55 pre-remediation names

**51 of 55 names are present verbatim in the post-change set**, each classified `relocated` or
`unchanged` by where it now lives:

### `unchanged` — still in `test_parallel_mutation_protocol.py` (18 names)

`test_unstarted_states_are_all_f3_item_state_members`,
`test_pinned_state_is_an_f3_item_state_member`,
`test_abandon_disposition_is_an_f3_disposition_member`,
`test_item_record_rejects_an_invalid_key_or_enum_value`,
`test_recolor_result_generation_is_current_plus_one`,
`test_deferred_add_increments_the_generation`,
`test_unstarted_removal_increments_the_generation`,
`test_requeue_increments_the_generation`,
`test_no_conflict_admit_stamps_the_current_generation`,
`test_in_flight_removal_stamps_the_current_generation`,
`test_close_stamps_the_current_generation`,
`test_sequence_of_ops_ends_at_start_plus_recompute_count`,
`test_generation_is_monotonically_non_decreasing_across_a_sequence`,
`test_completion_fires_only_for_terminal_merge_statuses`,
`test_completion_fires_when_every_non_withdrawn_item_is_terminal`,
`test_a_withdrawn_item_is_exempt_from_the_gate`,
`test_one_outstanding_item_keeps_the_run_open`,
`test_an_item_with_a_default_merge_status_is_not_complete`,
`test_a_run_tracking_no_item_is_complete`,
`test_equal_assignments_and_generation_compare_equal`,
`test_a_different_generation_compares_unequal`,
`test_constructing_copies_the_caller_mapping`

### `unchanged` — still in `test_parallel_mutation_protocol_properties.py` (11 names)

`test_recolor_is_deterministic_for_equal_inputs`,
`test_input_order_does_not_change_the_result`,
`test_every_unstarted_vertex_is_assigned_exactly_one_cohort`,
`test_no_pinned_vertex_is_assigned_a_cohort`,
`test_generation_is_always_one_beyond_the_current`,
`test_no_two_items_in_one_cohort_share_a_conflict_edge`,
`test_removal_of_an_unstarted_item_always_recomputes_and_withdraws`,
`test_close_is_permitted_exactly_when_no_item_is_pinned`,
`test_completion_is_false_while_any_item_lacks_a_terminal_status`,
`test_completion_is_true_once_every_item_is_merged`,
`test_entry_constructors_are_deterministic_under_a_fixed_clock`,
`test_remove_entry_is_deterministic_for_every_unstarted_item`,
`test_no_engine_call_mutates_the_generated_run`

### `relocated` — moved to `test_parallel_mutation_admission.py` ([P4-T2], 8 names)

`test_conflict_only_with_an_in_flight_item_defers`,
`test_conflict_only_with_an_unstarted_item_admits` (fixture corrected so the conflicting unstarted
item sits OUTSIDE the current cohort),
`test_no_conflicts_admits_with_no_generation_change`,
`test_edge_direction_does_not_affect_the_decision`,
`test_candidate_key_is_recorded_on_the_decision`,
`test_admission_does_not_mutate_its_inputs`,
`test_admission_is_deterministic_for_equal_inputs`,
`test_empty_edge_list_admits`

### `relocated` — moved to `test_parallel_mutation_recolor.py` ([P4-T4], 6 names)

`test_recolor_assigns_no_pinned_item`,
`test_recolor_key_set_equals_the_unstarted_set_exactly`,
`test_applying_a_recolor_leaves_pinned_state_and_cohort_unchanged`,
`test_recolor_rejects_a_key_that_is_both_unstarted_and_pinned`,
`test_recolor_does_not_mutate_its_inputs`,
`test_recolor_result_mapping_is_read_only`

Every assertion of these six is preserved verbatim; only the added `current_cohort=` keyword
argument and the resulting Black wrapping differ.

### `relocated` — moved to `test_parallel_mutation_pin_stability_properties.py` ([P4-T9], 2 names)

`test_pinned_items_never_change_state_or_cohort_across_a_sequence`,
`test_a_pinned_item_is_never_a_removal_target_without_a_disposition`

Both assertions preserved; the two engine call sites were migrated to the spec 1.2 signatures and
the pinned-cohort baseline now uses `run.current_cohort` rather than a hard-coded 0, which is
strictly more general.

## Check 4 — The four names not present verbatim, each with its replacement

No name is dropped without a replacement. Three are the plan's authorized `replaced` entries; the
fourth is a `corrected (renamed)` entry whose rename is required by the correction the plan itself
mandates.

| Pre-remediation name | Disposition | Replacement |
| --- | --- | --- |
| `test_unstarted_conflict_is_placed_by_the_coloring_not_rejected` | **replaced** (authorized by [P4-T2]) | Split into **two** strictly stronger tests: `test_conflict_with_an_unstarted_current_cohort_member_defers` and `test_conflict_with_an_unstarted_item_outside_the_cohort_admits`, both in `test_parallel_mutation_admission.py`. The original asserted only that `recolor_unstarted` separates a contending pair; it never exercised the admit-without-recolor path that created the hazard. The pair now asserts the admission verdict on BOTH sides of the current-cohort distinction. |
| `test_cohort_indices_are_contiguous_from_zero` | **replaced** (authorized by [P4-T10]) | `test_cohort_indices_are_contiguous_from_the_computed_offset` in `test_parallel_mutation_protocol_properties.py`. STRICTLY STRONGER: retains the contiguity claim and adds the offset-value claim, so it fails if the offset is removed, re-based to zero, or made unconditional. |
| `test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring` | **replaced** (authorized by [P4-T10]) | `test_pinned_edges_leave_the_class_structure_but_shift_the_assignment` in `test_parallel_mutation_protocol_properties.py`. STRICTLY STRONGER: the old full-versus-induced EQUALITY assertion codified the C2 defect (it can only hold if the pinned constraint is discarded with the pinned vertices). The replacement asserts both halves — identical class STRUCTURE via partition comparison, AND the assignment shifted past the pinned index when an unstarted-to-pinned edge exists. |
| `test_admission_defers_exactly_when_a_pinned_neighbour_exists` | **corrected (renamed)** — [P4-T7] explicitly directs "Move ... into the new module and correct it" | `test_admission_defers_exactly_when_a_current_cohort_neighbour_exists` in `test_parallel_mutation_contention_properties.py`. Not a drop: the same per-seed property over the same generated corpus, with the expected outcome now derived from a neighbour in `pinned \| current_cohort_members` instead of `pinned` alone, still computed independently from the generated edge list rather than from the engine's return value. The rename follows necessarily from the corrected predicate; keeping the old name would have made the name false. |

**No assertion was removed or weakened anywhere.** The two rewritten tests each replaced one
assertion with a strictly stronger pair, and every relocated test kept its assertions verbatim.

## Recorded Deviation — a fifth new test module

The plan's `## Test-Module Relocation Arithmetic` enumerates four new modules and assigns the
relocated P3 property to `test_parallel_mutation_contention_properties.py` with a `<= 400` budget.
In execution, that module carrying P4 (with its full-map replay, per-step contention assertion,
offset-value assertion, and four corpus existentials), the corrected per-function admission
property, the self-contained generator, AND P3 measured **584 lines** after a full docstring
compression pass — **84 lines over the absolute 500-line cap** in
`.claude/rules/general-code-change.md`, which the plan restates as its own Constraint 7.

P3 cannot remain in `test_parallel_mutation_protocol_properties.py` either: that module is at
**500 lines exactly** after the relocations and the required call-site wrapping, so re-adding P3's
87 lines would breach the cap there too.

Because the plan forbids cross-test-module imports ("imports from no other test module"), P3
cannot share the contention module's generator from a different file. The resolution applies the
plan's own stated principle verbatim — "Each new property module is self-contained: it defines its
own seeded `random.Random(seed)` generator and imports from no other test module. That duplication
is deliberate and is the cost of the 500-line cap" — by placing P3 in a fifth self-contained
sibling module, `tests/scripts/dev_tools/test_parallel_mutation_pin_stability_properties.py`
(286 lines).

Nothing was dropped, renamed away, or weakened by this deviation: both P3 tests are present with
their original names and assertions, and every module is now under the cap. The deviation is
reported in the execution summary.

## Output Summary

Before: **55** unique test names across the two named modules. After: **112** unique names across
nine modules. **51 of 55** pre-remediation names are present verbatim, classified `relocated` or
`unchanged`. The remaining **4** are accounted for as **3 authorized `replaced` entries** (each
naming its strictly stronger replacement, with one splitting into two tests) and **1
`corrected (renamed)` entry** whose rename is required by the correction [P4-T7] mandates. **No
name is dropped without a replacement, and no assertion was removed or weakened.** The two
previously untouched modules (`_ops.py`, `_abandon_cli.py`) are byte-identical to `a9e2463c`.
