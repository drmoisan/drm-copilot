# Historical AFTER Tests, Python and Pester (P12-T7)

Timestamp: 2026-09-27T17-44
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_historical_runs.py ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
EXIT_CODE: 0
Output Summary: pytest exits 0 with "24 passed": a PASSED line for each of the eight B18 tests (four BEFORE, four AFTER) for all three runs, and no FAILED or ERROR line. Pester prints TotalCount=9, PassedCount=9, FailedCount=0; the three B24 It names (BEFORE edges, detection at tolerance 0, and AFTER edges and tolerated overlaps) pass for all three runs.

## pytest (exit 0)

```text
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_radius_sizes_match_pins[epic-655-followups] PASSED [  4%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_radius_sizes_match_pins[backlog-2026-09-26] PASSED [  8%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_radius_sizes_match_pins[followups-2026-09-27] PASSED [ 12%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_edges_match_pins[epic-655-followups] PASSED [ 16%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_edges_match_pins[backlog-2026-09-26] PASSED [ 20%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_edges_match_pins[followups-2026-09-27] PASSED [ 25%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[epic-655-followups] PASSED [ 29%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[backlog-2026-09-26] PASSED [ 33%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_strict_scheduling_equals_detection[followups-2026-09-27] PASSED [ 37%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[epic-655-followups] PASSED [ 41%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[backlog-2026-09-26] PASSED [ 45%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_before_cohorts_match_pins[followups-2026-09-27] PASSED [ 50%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_match_pins[epic-655-followups] PASSED [ 54%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_match_pins[backlog-2026-09-26] PASSED [ 58%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_match_pins[followups-2026-09-27] PASSED [ 62%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_tolerated_overlaps_match_pins[epic-655-followups] PASSED [ 66%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_tolerated_overlaps_match_pins[backlog-2026-09-26] PASSED [ 70%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_tolerated_overlaps_match_pins[followups-2026-09-27] PASSED [ 75%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_cohorts_match_pins[epic-655-followups] PASSED [ 79%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_cohorts_match_pins[backlog-2026-09-26] PASSED [ 83%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_cohorts_match_pins[followups-2026-09-27] PASSED [ 87%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_are_subset_of_before_edges[epic-655-followups] PASSED [ 91%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_are_subset_of_before_edges[backlog-2026-09-26] PASSED [ 95%]
tests/scripts/dev_tools/test_blast_radius_historical_runs.py::test_after_edges_are_subset_of_before_edges[followups-2026-09-27] PASSED [100%]
============================= 24 passed in 5.24s ==============================
```

## Pester (pester-counts, A2; ANSI colour codes removed; the absolute test path Pester prints is shown repository-relative)

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 9 tests in 110ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1'
Describing Blast-radius historical runs
  [+] reproduces the pinned BEFORE edges for epic-655-followups 1.57s (1.55s|21ms)
  [+] matches detection at tolerance 0 for epic-655-followups 4s (4s|1ms)
  [+] reproduces the pinned AFTER edges and tolerated overlaps for epic-655-followups 1.26s (1.26s|0ms)
  [+] reproduces the pinned BEFORE edges for backlog-2026-09-26 5.59s (5.59s|0ms)
  [+] matches detection at tolerance 0 for backlog-2026-09-26 17.46s (17.46s|0ms)
  [+] reproduces the pinned AFTER edges and tolerated overlaps for backlog-2026-09-26 5.79s (5.79s|0ms)
  [+] reproduces the pinned BEFORE edges for followups-2026-09-27 16.04s (16.04s|0ms)
  [+] matches detection at tolerance 0 for followups-2026-09-27 62.98s (62.98s|0ms)
  [+] reproduces the pinned AFTER edges and tolerated overlaps for followups-2026-09-27 17.35s (17.35s|0ms)
Tests completed in 132.97s
Tests Passed: 9, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=9
PassedCount=9
FailedCount=0
```

Pester exit code: 0 (the A1 runner uses set -eu, so a non-zero pwsh exit would have surfaced).

SCRATCH denotes the executor session scratchpad directory (outside the repository).
