Timestamp: 2026-10-19T01-59
Command: poetry run pytest -o addopts='' tests/discovery_runtime/test_snapshot_loading.py tests/discovery_runtime/test_snapshot_loading_edges.py --cov=drm_copilot_discovery.snapshot_loading --cov-branch --cov-report=term-missing
EXIT_CODE: 1
Output Summary: Rejected invocation; test_snapshot_loading_edges.py does not exist. Pytest collected zero tests. Observed enclosing shell exit was 1; this is not accepted baseline evidence.
Corrected baseline: evidence/baseline/p4t1-loader-baseline.2026-10-19T01-53.md uses existing test_snapshot_imports.py and passed 44 tests.
