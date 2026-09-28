# Part A Strict Identity and #452 Cases, Python (P7-T1)

Timestamp: 2026-09-27T16-46
Command: poetry run pytest -v <the thirteen B28 node IDs listed below>
EXIT_CODE: 0
Output Summary: PASS. pytest exited 0 with "13 passed" and a PASSED line for every B28 node: the five scheduling-fixture decision nodes (scheduling-452-shared-surface-hard, scheduling-452-directory-prefix-weighted, scheduling-452-negative-controls, scheduling-soft-pair-tolerated, scheduling-absent-key-strict), test_452_scheduling_fixtures_embed_radii, test_strict_identity_over_existing_conflict_fixtures, and the historical-run nodes test_before_strict_scheduling_equals_detection and test_before_cohorts_match_pins for epic-655-followups, backlog-2026-09-26, and followups-2026-09-27.

## Printed output

```text
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-452-shared-surface-hard] PASSED [  7%]
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-452-directory-prefix-weighted] PASSED [ 15%]
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-452-negative-controls] PASSED [ 23%]
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-soft-pair-tolerated] PASSED [ 30%]
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_scheduling_fixture_reproduces_expected_decisions[scheduling-absent-key-strict] PASSED [ 38%]
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_452_scheduling_fixtures_embed_radii PASSED [ 46%]
tests/scripts/dev_tools/test_blast_radius_scheduling.py::test_strict_identity_over_existing_conflict_fixtures PASSED [ 53%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[epic-655-followups] PASSED [ 61%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[backlog-2026-09-26] PASSED [ 69%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[followups-2026-09-27] PASSED [ 76%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[epic-655-followups] PASSED [ 84%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[backlog-2026-09-26] PASSED [ 92%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[followups-2026-09-27] PASSED [100%]
============================= 13 passed in 2.68s ==============================
```
