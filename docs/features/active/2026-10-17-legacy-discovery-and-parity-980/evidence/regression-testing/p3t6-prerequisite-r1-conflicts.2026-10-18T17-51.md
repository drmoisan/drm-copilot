# p3t6-prerequisite-r1-conflicts

Timestamp: 2026-10-18T17-51
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors tests/discovery_runtime/test_snapshot_export.py::test_ordinary_same_byte_duplicates_are_not_transport_replicas -q -x --durations=3
EXIT_CODE: 0
Output Summary: 6.23s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-header]; 6.16s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-origin]; 5.37s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-bytes]; 6 passed in 33.20s

Working directory: .
Started: 2026-10-18T17:51:06.172863+00:00
Duration seconds: 34.509
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
......                                                                   [100%]
============================= slowest 3 durations =============================
6.23s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-header]
6.16s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-origin]
5.37s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-bytes]
6 passed in 33.20s
```
