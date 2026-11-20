# p3t6-prerequisite-tests3

Timestamp: 2026-10-18T17-47
Command: poetry run python SCRATCH/issue-980-p3t6-prerequisite-tests.py
EXIT_CODE: 0
Output Summary: 13.08s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[unbound]; 13.05s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-origin]; 32 passed in 159.51s (0:02:39); {"raw_coverage": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-coverage.2026-10-18T17-47.json"}

Working directory: .
Started: 2026-10-18T17:45:15.579946+00:00
Duration seconds: 160.788
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{"arguments": ["-o", "addopts=-ra", "tests/discovery_runtime/test_snapshot_export.py", "tests/discovery_runtime/test_snapshot_import.py", "-q", "-x", "--durations=5", "--cov=drm_copilot_discovery.transport_manifest", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:EXTERNAL_PATH"]}
................................                                         [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                         Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\transport_manifest.py     113      4     48      4    95%   117, 134, 149, 249
------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          113      4     48      4    95%
Coverage JSON written to file SCRATCH\issue-980-p3t6-prerequisite-coverage.json
============================= slowest 5 durations =============================
19.23s call     tests/discovery_runtime/test_snapshot_export.py::test_real_planner_accepts_exact_export_replicas_and_publishes_header_last
14.08s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-bytes]
13.15s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-pin]
13.08s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[unbound]
13.05s call     tests/discovery_runtime/test_snapshot_export.py::test_unbound_or_conflicting_copies_keep_duplicate_errors[changed-origin]
32 passed in 159.51s (0:02:39)
{"raw_coverage": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-coverage.2026-10-18T17-47.json"}
```
