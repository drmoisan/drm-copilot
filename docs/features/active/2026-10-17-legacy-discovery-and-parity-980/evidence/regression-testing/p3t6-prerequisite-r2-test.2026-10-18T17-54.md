# p3t6-prerequisite-r2-test

Timestamp: 2026-10-18T17-54
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last -q -x --durations=3
EXIT_CODE: 0
Output Summary: 0.30s setup    tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last; ; (1 durations < 0.005s hidden.  Use -vv to show these durations.); 1 passed in 9.84s

Working directory: .
Started: 2026-10-18T17:54:42.695723+00:00
Duration seconds: 11.001
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
.                                                                        [100%]
============================= slowest 3 durations =============================
9.40s call     tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last
0.30s setup    tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last

(1 durations < 0.005s hidden.  Use -vv to show these durations.)
1 passed in 9.84s
```
