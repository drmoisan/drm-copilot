# Phase 3 Python Tests and Coverage — Issue #440 (F7)

Task: [P3-T7]

Timestamp: 2026-08-08T22-11

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test Result

```
31 passed in 4.10s
```

All 31 cases in the Phase 3 test file pass. Every case drives the invariant
through the public entry point `validate_parallel_orchestrator_state_text`; the
test file does not import
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` at all, so a
passing run is positive proof that the P3-T1 producer and the P3-T3 consumer are
bound at run time and not merely each internally correct.

## Coverage — SCOPED RUN VALUES (not the authoritative repository numbers)

The command runs a single test file, so the repository-wide headline percentages
below are measured from that one file and read very low by construction. They are
recorded here because the plan requires numeric values, and they are labelled
scoped-run values per plan note "Task P3-T7 runs pytest against a single test file
... Phase 3 figures must be labelled as scoped-run values when recorded". P5-T7
runs the full suite and is the authoritative Python number for the threshold and
delta comparison in P5-T8.

| Metric | Scoped-run value | Baseline (full suite, P0-T8) |
| --- | --- | --- |
| Repository line coverage | **3.07%** (419 of 13649 statements) | 91.82% (12432 of 13539) |
| Repository branch coverage | **3.44%** (174 of 5056 branches) | 83.80% (4190 of 5000) |

The `TOTAL` row printed by pytest-cov reads `3%`, which is the combined
statement-plus-branch metric (3.17%); the separated statement and branch figures
above were read from `coverage json` totals
(`percent_statements_covered`, `percent_branches_covered`), matching the method
the P0-T8 baseline artifact used.

**These scoped percentages are NOT a coverage regression.** They are the arithmetic
consequence of executing 31 tests instead of 3038 against the same denominator.

## Coverage — changed files (the numbers that carry information here)

| File | Line coverage | Branch coverage | Meets >= 85% / >= 75% |
| --- | --- | --- | --- |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (new, P3-T1) | **96.30%** (104 of 108 statements) | **91.07%** (51 of 56 branches) | yes / yes |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (edited, P3-T3) | 69.05% (58 of 84) — scoped-run only | 38.24% (13 of 34) — scoped-run only | see note |

Note on the edited validator: its scoped figures are low only because this one
test file exercises a narrow slice of it. Its P0-T8 baseline under the full suite
was 97% (84 statements, 2 missed), and the P3-T3 edit adds four lines of which the
`errors.extend(validate_cohort_barrier_ordering(state_map))` statement is executed
by all 31 tests here. P5-T7 measures its post-change full-suite figure.

The four uncovered statements in the new helper (`term-missing`: `133, 137,
141->131, 211, 324`) are defensive skips over malformed input that F3's own
invariants already report: a non-object `items[]` entry, an item with no usable
`issue_num`, a current-generation cohort row with an unusable `index` or
`item_keys`, and the unreachable guard where a cohort-assigned key has no item
record. None is a behavioral path this feature's acceptance criteria assert.

## Case Inventory (all P3-T2 required cases present)

| Plan-required case | Test |
| --- | --- |
| key-gated backward compatibility (no `conflict_edges`/`cohorts`) | `test_checkpoint_without_a_gating_key_emits_no_violation` (3 params: each key alone, then both) |
| same-cohort pair produces one structural violation | `test_same_cohort_conflicting_pair_reports_one_structural_violation` |
| cross-cohort later item started while earlier non-terminal | `test_cross_cohort_start_before_terminal_merge_reports_a_violation` |
| timestamp-ordering violation with both timestamps present | `test_merge_confirmed_after_later_start_reports_a_temporal_violation` |
| clean multi-cohort checkpoint yields zero barrier errors | `test_clean_multi_cohort_checkpoint_yields_no_barrier_errors`, `test_merge_confirmed_before_later_start_is_clean` |
| missing timestamps degrade to structural-plus-status | `test_absent_timestamps_degrade_to_structural_plus_status` (3 params), `test_non_string_timestamps_degrade_to_structural_plus_status` |
| multiple violated edges produce exactly one message each | `test_multiple_violated_edges_each_report_exactly_one_message` |
| every message equals the exact literal form | `test_violation_message_matches_the_exact_literal_form` (no interpolation), `expected_violation` used by all others |

Supporting cases beyond the required set: `ci_green` does not satisfy the barrier;
a start timestamp alone evidences a start; the earlier-cohort endpoint is named
first even when it is the edge's `b`; superseded-generation cohort rows are
ignored; `feature_folder` hint membership resolves; unresolved endpoint, self
edge, malformed `conflict_edges`, malformed `cohorts`, malformed
`recolor_generation`, malformed `items`, and an item outside the current coloring
each yield no barrier message; and validation does not mutate the checkpoint.

Output Summary: PASS. EXIT_CODE 0, `31 passed in 4.10s`, with every case exercised
through `validate_parallel_orchestrator_state_text` rather than by importing the
helper, which proves the producer/consumer seam is bound. SCOPED-RUN repository
coverage from this single test file is line 3.07% (419 of 13649 statements) and
branch 3.44% (174 of 5056 branches); these are expected-low scoped values, not a
regression, and P5-T7's full-suite run is the authoritative Python number
(baseline for comparison: line 91.82%, branch 83.80%). The new helper module
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` measures line
96.30% (104 of 108) and branch 91.07% (51 of 56), both above the uniform >= 85%
line and >= 75% branch thresholds; its four uncovered statements are defensive
skips over malformed input that F3's own invariants report.
