# Phase 3 QA Gate — Python parity and mergeable-path readers (issue #643)

Timestamp: 2026-09-07T16-24

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py -v`

EXIT_CODE: 0

Output Summary:

`94 passed in 0.19s`. No failures, no errors, no skips.

The parity module discovered the two fixtures added by [P3-T6] and reproduced
both the verdict and the reason sequence for each. The acceptance node ID is
present in the output:

```
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-mergeable-glob-still-contends] PASSED
```

The companion node IDs for the same pair of fixtures also passed:

- `test_conflict_fixture_reproduces_the_expected_verdict[conflict-mergeable-csproj-no-edge]`
- `test_conflict_fixture_reproduces_the_expected_reasons[conflict-mergeable-csproj-no-edge]`
- `test_conflict_fixture_reproduces_the_expected_verdict[conflict-mergeable-glob-still-contends]`
- `test_discovered_fixture_count_equals_the_json_file_count`

`test_blast_radius_mergeable_paths.py` passed in full, including
`test_conflicts_absent_key_and_empty_list_produce_identical_results`,
`test_validate_blast_radius_findings_are_identical_with_and_without_the_key`,
`test_derive_blast_radius_keeps_a_cited_csproj_in_paths`, and
`test_detect_escaped_paths_is_unaffected_by_the_key`.
