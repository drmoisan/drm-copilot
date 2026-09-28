# Remediation Cycle 1 — Whole-Suite Regression Isolation (Both Defects Red)

Timestamp: 2026-08-09T06-54

Task: [P2-T5] `[expect-fail]`
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1

## Primary Run

Command: `poetry run pytest -q`
EXIT_CODE: 1

Required outcome for this `[expect-fail]` task is `EXIT_CODE: 1` with exactly two failing test ids —
the [P2-T1] test and the [P2-T3] test — and no other failure. **The observed exit code is 1 with
exactly those two failing ids and no others, so the required outcome is met.** The non-zero exit is
the success condition for this task and does not restart any toolchain loop.

Output Summary: **`2 failed, 3386 passed in 4.42s`**. Total collected 3388; 3386 passed; 2 failed;
0 errors. The 3386 passing count reproduces the Phase 0 baseline passing count
(`remediation1-baseline-py-test-coverage.md`: 3386 passed) exactly, so **no pre-existing test was
broken** by authoring the two regression modules.

Full list of failing test ids:

```
FAILED tests/scripts/dev_tools/test_parallel_mutation_admission.py::TestCohortIndependenceRegression::test_conflict_with_an_unstarted_current_cohort_member_defers
FAILED tests/scripts/dev_tools/test_parallel_mutation_recolor.py::TestPinnedBarrierOffsetRegression::test_deferred_candidate_is_not_placed_in_the_pinned_cohort
```

The first is the [P2-T1] C1 test; the second is the [P2-T3] C2 test. **No third failing id appears.**
Both failures are `AssertionError`, so both are behavioral demonstrations against the shipped
implementation.

## Isolation Checks

### No existing test file deleted and no assertion removed

Command: `git diff a9e2463c --stat -- tests/`
EXIT_CODE: 0
Output Summary: **empty output**. No tracked file under `tests/` is modified or deleted relative to
`a9e2463c`, so no existing test file was deleted and no assertion was removed. The only change under
`tests/` is the addition of two untracked files, confirmed by:

Command: `git status --porcelain -- tests/`
EXIT_CODE: 0
Output Summary:
```
?? tests/scripts/dev_tools/test_parallel_mutation_admission.py
?? tests/scripts/dev_tools/test_parallel_mutation_recolor.py
```
Two additions, zero modifications, zero deletions.

### The 500-line ops module is unchanged

Command: `git diff --numstat a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`
EXIT_CODE: 0
Output Summary: **empty output** — no added and no removed line, so
`tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` reports no change against
`a9e2463c` and remains byte-identical at exactly 500 lines. (Base `a9e2463c` is the correct base for
this check; `c939b5b8` would report the whole file as a `500 0` addition because the path is absent
from that commit.)

## Ordering

The fixed and executed sequence is **[P2-T2] -> [P2-T4] -> [P2-T5]**:

1. **[P2-T2]** ran the C1 demonstration alone against
   `tests/scripts/dev_tools/test_parallel_mutation_admission.py`. `EXIT_CODE: 1`, observed outcome
   `ADMIT_CURRENT_COHORT`. Recorded in
   `<FEATURE>/evidence/regression-testing/remediation1-c1-admission-cohort-independence.md`.
2. **[P2-T4]** ran the C2 demonstration alone against
   `tests/scripts/dev_tools/test_parallel_mutation_recolor.py`. `EXIT_CODE: 1`, observed assignment
   `{200: 0, 300: 0}` with `cohort_assignments[300] == 0`. Recorded in
   `<FEATURE>/evidence/regression-testing/remediation1-c2-recolor-pinned-barrier.md`.
3. **[P2-T5]** (this run) ran the whole suite once with both regressions red, proving the two
   failures are isolated to the two new tests and that nothing else regressed.

No engine change has been made at the time of this run. Phase 3 begins the engine corrections.
