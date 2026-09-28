# Drift and Validator Tests (P2-T7)

Timestamp: 2026-09-27T15-25
Command: poetry run pytest -v tests/scripts/dev_tools/test_parallel_drift_scheduling.py tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py; poetry run pytest -v tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py; poetry run pytest -v tests/scripts/dev_tools -k drift
EXIT_CODE: 0
Output Summary: All three runs exited 0. Run 1 printed "13 passed": a PASSED line for each of the 8 B13 tests and each of the 5 B14 tests, with no FAILED or ERROR line. Run 2 (block B45, the existing drift conflicts module, unmodified) printed "16 passed": a PASSED line for every one of the 16 nodes the module collects, no FAILED or ERROR line. Run 3 printed "216 passed, 4909 deselected" with 0 FAILED lines; the P0-T18 baseline failure set is empty, so the acceptance holds.

## Run 1 — B13 and B14 tests

```text
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_tolerated_pair_within_tolerance_is_not_reported PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_tolerated_pair_that_becomes_hard_is_reported PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_tolerated_pair_exceeding_tolerance_is_reported PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_tolerance_zero_output_equals_conflict_only_output PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_unevaluable_peer_radius_counts_as_edge PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_existing_edge_pairs_normalize_order PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_missing_band_uses_default_band PASSED
tests/scripts/dev_tools/test_parallel_drift_scheduling.py::test_observed_decision_uses_the_injected_relation PASSED
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py::test_orchestrator_state_accepts_tolerated_edge_fields PASSED
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py::test_planner_state_accepts_tolerated_edge_fields PASSED
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py::test_orchestrator_state_accepts_tolerated_overlaps_list PASSED
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py::test_planner_state_accepts_tolerated_overlaps_list PASSED
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py::test_out_of_enum_reason_is_still_rejected PASSED
============================= 13 passed in 0.10s ==============================
```

## Run 2 — block B45 (existing drift conflicts module, unmodified)

```text
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_reports_nothing_when_no_new_conflict_appears PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_reports_the_one_newly_conflicting_pair PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_skips_a_pair_already_recorded_as_an_edge[edge0] PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_skips_a_pair_already_recorded_as_an_edge[edge1] PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_treats_an_unevaluable_peer_radius_as_conflicting PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_treats_a_missing_peer_radius_as_conflicting PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_ignores_peers_that_are_not_in_flight PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_builds_the_substituted_radius_from_observed_paths PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_ignores_an_unreadable_existing_edge PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_rejects_a_malformed_item_key PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_rejects_malformed_scalar_arguments[0-2026-08-08T10-00] PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_rejects_malformed_scalar_arguments[446-] PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_uses_the_real_relation_without_mocking PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_reports_no_pair_for_a_csproj_only_observed_overlap PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recomputed_pair_feeds_halt_selection_and_yields_later_started_item PASSED
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_the_detection_and_halt_path_is_deterministic_across_repeated_calls PASSED
============================= 16 passed in 0.07s ==============================
```

The monkeypatched-relation cases (for example the first two above) pass, which confirms that the
drift module's patched conflicts attribute still governs the scheduling-rule decision.

## Run 3 — drift-selected tests

```text
==================== 216 passed, 4909 deselected in 0.91s =====================
```

| Signal (run 3, full output in SCRATCH/p2-t7c.out) | Count |
| --- | --- |
| lines containing " PASSED" | 216 |
| lines containing " FAILED" or " ERROR" | 0 |

## Arrangement correction during this task

The first run of the B14 module failed two orchestrator cases with
"PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445", because the shared
builder places both items in one cohort and an edge between them is an invalid coloring. The two
orchestrator edge cases now use the existing split-cohort builder state_with_edges of the orchestrator
structures test module (read-only import). No production code changed for this; the runs above are
after the correction.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
