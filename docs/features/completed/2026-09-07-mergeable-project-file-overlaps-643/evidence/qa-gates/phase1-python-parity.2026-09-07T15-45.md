# Phase 1 gate — Python truth-table parity (issue #643, task [P1-T9])

- Timestamp: 2026-09-07T15:45Z
- Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/test_blast_radius_config.py tests/scripts/dev_tools/test_blast_radius_mandate_reads.py -v` (run from the worktree root)
- EXIT_CODE: 0

## Output Summary

All three suites pass: `59 passed in 0.16s`.

The two node IDs the acceptance condition names appear in the verbose output as passed:

```text
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[mergeable_paths] PASSED [ 10%]
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies PASSED [ 11%]
```

The first confirms the new key is byte-equal across both committed copies (Class 1 membership
added by [P1-T3]). The second confirms the key-partition registry classifies every top-level key
in both copies, so the new key is not silently unclassified.
