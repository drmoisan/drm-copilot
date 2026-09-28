# Scheduling Tests Pass (P1-T12)

Timestamp: 2026-09-27T15-18
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_scheduling.py tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py
EXIT_CODE: 0
Output Summary: pytest exited 0 with "46 passed" and no FAILED or ERROR line. Every B10 test name has a PASSED line: the fifteen unparametrized tests, all 14 reader-rejection cases, and all 5 scheduling-fixture cases (34 nodes). Every B11 property has a PASSED line for each of its three truth-table cases (12 nodes). The B11 properties are exhaustive checks over a fixed domain rather than hypothesis tests; see FEATURE/evidence/other/property-test-framework-deviation.2026-09-27T15-17.md. This run is against the final Phase 1 file state (after the P1-T14 fixes), so it supersedes the earlier P1-T12 run.

## Printed output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <host-path>
cachedir: .pytest_cache
rootdir: 
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 46 items

tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_shared_surface_overlap_is_hard_at_every_tolerance PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_contract_dependency_is_hard PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_cost_same_file_weight_for_equal_concrete_entries PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_cost_append_only_is_evaluated_before_same_file PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_cost_possible_overlap_for_directory_prefix PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_cost_module_weight_times_shared_modules PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_cost_mergeable_paths_contribute_zero PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_benefit_is_minimum_band_duration PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_benefit_uses_default_band_for_missing_band PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_edge_rule_integer_inequality_boundary PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_recorded_reason_is_first_canonical_kind PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_absent_key_reads_as_strict PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[non-object] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[percent-negative] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[percent-float] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[percent-string] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[percent-bool] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[weight-zero] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[weight-bool] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[weight-float] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[weight-unknown-name] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[weight-missing-name] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[band-duration-zero] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[band-missing-name] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[default-band-out-of-range] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_conflict_tolerance_reader_rejects_invalid_shape[append-only-not-list] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-452-shared-surface-hard] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-452-directory-prefix-weighted] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-452-negative-controls] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-soft-pair-tolerated] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-absent-key-strict] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_452_scheduling_fixtures_embed_radii PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_strict_identity_over_existing_conflict_fixtures PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_edges_and_tolerated_overlaps_are_sorted_by_pair PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_edge_implies_conflict[committed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_edge_implies_conflict[unit] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_edge_implies_conflict[skewed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_tolerance_zero_equals_conflict[committed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_tolerance_zero_equals_conflict[unit] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_tolerance_zero_equals_conflict[skewed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_monotone_in_tolerance[committed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_monotone_in_tolerance[unit] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_monotone_in_tolerance[skewed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_symmetric_decision[committed] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_symmetric_decision[unit] PASSED
tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py::test_property_symmetric_decision[skewed] PASSED

============================= 46 passed in 3.96s ==============================
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
