# C1 Regression — Admission Cohort Independence (finding R1 / B1 / D1)

Timestamp: 2026-08-09T06-48

Task: [P2-T2] `[expect-fail]`
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
Test module: `tests/scripts/dev_tools/test_parallel_mutation_admission.py`
Test id: `TestCohortIndependenceRegression::test_conflict_with_an_unstarted_current_cohort_member_defers`

## Fail-Before

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py -v`
EXIT_CODE: 1

Required outcome for this `[expect-fail]` task is `EXIT_CODE: 1` with the assertion reporting
`AdmissionOutcome.ADMIT_CURRENT_COHORT`. **The observed exit code is 1 and the observed outcome is
`ADMIT_CURRENT_COHORT`, so the required outcome is met.** The non-zero exit is the success
condition for this task and does not restart any toolchain loop.

Output Summary: `1 failed in 0.09s` (1 collected, 1 failed, 0 passed). The failure is an
`AssertionError`, not a `TypeError`, so the demonstration is BEHAVIORAL against the shipped
three-argument implementation rather than an artifact of a signature change. Verbatim assertion
output:

```
>       assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR
E       AssertionError: assert <AdmissionOutcome.ADMIT_CURRENT_COHORT: 'admit_current_cohort'> is <AdmissionOutcome.DEFER_AND_RECOLOR: 'defer_and_recolor'>
E        +  where <AdmissionOutcome.ADMIT_CURRENT_COHORT: 'admit_current_cohort'> = AdmissionDecision(candidate=300, outcome=<AdmissionOutcome.ADMIT_CURRENT_COHORT: 'admit_current_cohort'>).outcome
E        +  and   <AdmissionOutcome.DEFER_AND_RECOLOR: 'defer_and_recolor'> = AdmissionOutcome.DEFER_AND_RECOLOR
```

The shipped engine returned `AdmissionDecision(candidate=300, outcome=ADMIT_CURRENT_COHORT)`, so
candidate 300 would have been written into the current cohort at unchanged generation alongside the
conflicting item 200.

## Reproduction Premise

- Item **100** is `in_flight` — the pinned set is `frozenset({100})`.
- Item **200** is `scheduled`: a member of the current cohort but **not yet launched**. Its
  durability in that state follows from `max_concurrency` capping simultaneously in-flight items
  independently of cohort size, with each freed slot refilled from the SAME current cohort in
  ascending item-key order — `.claude/skills/parallel-orchestrate/SKILL.md` section
  `## Cohort Barrier and Max-Concurrency Slot Filling`.
- Candidate **300** conflicts with **200 only**. The sole conflict edge is `(200, 300)`. The
  candidate conflicts with nothing that is in flight.
- Call under test: `decide_admission(300, [(200, 300)], frozenset({100}))`.
- Corrected expectation: `AdmissionOutcome.DEFER_AND_RECOLOR` with `triggers_recompute is True`,
  because admitting 300 would place two contending items in one cohort for the next
  `max_concurrency` batch to launch concurrently on overlapping blast radius.

## Ordering

This demonstration is executed FIRST, before any engine change has been made, and before the C2
demonstration. The next demonstration is **[P2-T4]**, which exercises `recolor_unstarted` against
its own module in isolation so neither failure can be mistaken for the other. **No engine change
has yet been made** at the time of this run: `git status --porcelain -- scripts/` reports no
modification to any production file, and the only file this cycle has added under `tests/` at this
point is the C1 regression module itself.

## Pass-After

Timestamp: 2026-08-09T08-10

Task: [P4-T13]

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py -v`
EXIT_CODE: 0
Output Summary: **43 passed**, 0 failed. The C1 regression test
`TestCohortIndependenceRegression::test_conflict_with_an_unstarted_current_cohort_member_defers`
now PASSES against the corrected engine, with its assertion unchanged in substance — still
`AdmissionOutcome.DEFER_AND_RECOLOR` with `triggers_recompute is True`. The only change to the test
between the fail-before and pass-after runs is the added required keyword argument
`current_cohort_members=frozenset({100, 200})` ([P4-T1]); no assertion was weakened, added, or
removed.

Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations`. Every call site recorded PENDING-PHASE-4 by
[P3-T8] is migrated. One Pyright error surfaced on the first run of this gate — an invariant-`list`
argument-type error at
`tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py:320`, where
`list(UNSTARTED_KEYS)` narrowed to `list[Literal[444, 445]]` — and was fixed by annotating the
local as `unstarted: list[int]`. The re-run is the zero-error result recorded here.

## Binding

Which reversion re-fails which test, each demonstrated by execution in
`<FEATURE>/evidence/regression-testing/remediation1-property-p4-binding.md`:

- **Reverting `decide_admission` to the in-flight-only rule** re-fails the C1 regression test
  (`test_conflict_with_an_unstarted_current_cohort_member_defers`), the corrected per-function
  admission property
  (`test_admission_defers_exactly_when_a_current_cohort_neighbour_exists`, at seeds 34, 89, 144,
  233 among others), and **property P4**
  (`test_no_cohort_holds_a_conflicting_pair_across_admission_sequences`). Measured: `9 failed,
  4 passed`.
- **Removing `recolor_unstarted`'s offset** re-fails the C2 regression test, all four
  pinned-barrier offset scenarios, and property P4. Measured: `6 failed, 20 passed`.
- **Making the offset unconditional** re-fails property P4,
  `test_no_pinned_conflict_starts_exactly_at_current_cohort`, and
  `test_pinned_free_run_at_zero_matches_the_pre_fix_assignment`. Measured: `3 failed, 23 passed`.
