# p3t6-prerequisite-r1-test

Timestamp: 2026-10-18T17-50
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last -q -x --durations=3
EXIT_CODE: 0
Output Summary: 0.31s setup    tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last; ; (1 durations < 0.005s hidden.  Use -vv to show these durations.); 1 passed in 9.42s

Working directory: .
Started: 2026-10-18T17:50:32.113854+00:00
Duration seconds: 10.607
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
.                                                                        [100%]
============================= slowest 3 durations =============================
8.97s call     tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last
0.31s setup    tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last

(1 durations < 0.005s hidden.  Use -vv to show these durations.)
1 passed in 9.42s
```
