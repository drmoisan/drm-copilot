# Config and Historical BEFORE Tests (P3-T10)

Timestamp: 2026-09-27T15-30
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance] tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies
EXIT_CODE: 0
Output Summary: pytest exited 0 with "18 passed" and no FAILED or ERROR line. PASSED lines: all four B16 Part A cases (test_committed_conflict_tolerance_values and test_committed_conflict_tolerance_reads_cleanly for self-hosted and bundled); all four B18 BEFORE tests for each of the three runs (12 nodes); and the two B19 nodes, the byte-equal case for conflict_tolerance and the key-exhaustiveness case.

## Printed output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <host-path>
cachedir: .pytest_cache
rootdir: 
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 18 items

tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_values[self-hosted] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_values[bundled] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_reads_cleanly[self-hosted] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_reads_cleanly[bundled] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_radius_sizes_match_pins[epic-655-followups] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_radius_sizes_match_pins[backlog-2026-09-26] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_radius_sizes_match_pins[followups-2026-09-27] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_edges_match_pins[epic-655-followups] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_edges_match_pins[backlog-2026-09-26] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_edges_match_pins[followups-2026-09-27] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[epic-655-followups] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[backlog-2026-09-26] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[followups-2026-09-27] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[epic-655-followups] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[backlog-2026-09-26] PASSED
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[followups-2026-09-27] PASSED
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance] PASSED
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies PASSED

============================= 18 passed in 3.17s ==============================
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
