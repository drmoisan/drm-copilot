# p3t6-correction-regression

Timestamp: 2026-10-18T18-32
Command: poetry run pytest -o addopts=-ra -q tests/discovery_runtime/test_references.py::test_transport_entries_resolve_their_declared_repository tests/discovery_runtime/test_references.py::test_imported_reference_uses_origin_and_feature_alias_without_hash_rules tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors tests/discovery_runtime/test_snapshot_export.py::test_ordinary_same_byte_duplicates_are_not_transport_replicas tests/discovery_runtime/test_reference_uniqueness.py::test_duplicate_artifact_ids_block_resolution_even_with_a_path --junitxml=SCRATCH\issue-980-p3t6-correction.xml
EXIT_CODE: 0
Output Summary: ...........                                                              [100%]; 11 passed in 43.73s

Working directory: .
Started: 2026-10-18T18:31:58.845126+00:00
Duration seconds: 44.871
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
...........                                                              [100%]
11 passed in 43.73s
```
