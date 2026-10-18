# P3-T6 test fixture split

Timestamp: 2026-10-18T18-00
Status: Authorized before file creation; P3-T6 remains unchecked.

The approved plan permits same-component splits needed to keep production, tests and reusable scripts within 500 physical lines. The existing export suite is 455 lines at prerequisite checkpoint a4abf7737f656ad49cc39b5ab588d1352dc48cd4.

Authorize one additional worker-owned path: tests/discovery_runtime/source_snapshot_test_support.py. Move only the transport_case, unit_transport and changed_header fixture builders and add fresh export/import fixture builders there. Keep behavioral assertions in the prescribed test_snapshot_export.py and test_snapshot_import.py suites. Fixtures remain isolated and memory-backed; no temporary-file, process or network dependencies are permitted in unit tests.

No extra production module or independent outcome is authorized. Preserve all prerequisite behavior, original task baseline 27753e5f8b9a6cd1d85b9d1d28d2999800af209a, exact prior-file exceptions, and current-source coverage and final verification obligations. Record any further file split before editing.

The Python specialist owns this helper and the existing authorized task paths. The atomic executor independently verifies the resulting scope and task evidence. Progress remains 29/84 tasks and 11/66 acceptance criteria.
