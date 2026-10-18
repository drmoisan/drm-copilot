# p3t6-replica-lint

Timestamp: 2026-10-18T18-49
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py packages/discovery-runtime/src/drm_copilot_discovery/references.py packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py tests/discovery_runtime/test_snapshot_export.py tests/discovery_runtime/test_snapshot_import.py tests/discovery_runtime/source_snapshot_test_support.py tests/discovery_runtime/test_snapshot_replica_resolution.py
EXIT_CODE: 1
Output Summary: [1m[94m56 |[0m         source_reference(imported);    [1m[94m|[0m; ; Found 1 error.

Working directory: .
Started: 2026-10-18T18:49:43.719900+00:00
Duration seconds: 0.828
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_snapshot_replica_resolution.py:54:89
   [1m[94m|[0m
[1m[94m52 |[0m         artifact=header, kind="source-snapshot-manifest", document=header.document
[1m[94m53 |[0m     )
[1m[94m54 |[0m     # Source contracts choose the deterministic proven copy; manifests require their own.
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m55 |[0m     reference = (
[1m[94m56 |[0m         source_reference(imported)
   [1m[94m|[0m

Found 1 error.
```
