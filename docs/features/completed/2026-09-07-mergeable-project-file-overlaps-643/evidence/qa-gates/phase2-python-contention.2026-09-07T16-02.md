# Phase 2 gate — Python contention filter (issue #643, task [P2-T5])

- Timestamp: 2026-09-07T16:02Z
- Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_mandate_reads.py -v` (run from the worktree root)
- EXIT_CODE: 0

## Output Summary

All five suites pass: `163 passed in 0.36s`. The existing parity, conflicts, and mandate-read
suites are unchanged by the filter, which is the symmetry the exclusion is required to preserve.

The four node IDs the acceptance condition names appear in the verbose output as passed:

```text
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_conflicts_yields_no_edge_for_a_csproj_only_overlap PASSED [  6%]
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_conflicts_still_contends_for_a_declared_glob_entry PASSED [  7%]
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_validate_blast_radius_findings_are_identical_with_and_without_the_key PASSED [  9%]
tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py::test_recompute_conflicts_reports_no_pair_for_a_csproj_only_observed_overlap PASSED [ 48%]
```

They cover, in order: the no-edge verdict for a project-file-only overlap; the declared glob that
still contends; the identity of V1/V2/V3 findings with and without the key; and the inheritance of
the exclusion by drift recomputation through the real, unmocked relation.
