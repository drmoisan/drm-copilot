# p2t7-ruff-pass4

Timestamp: 2026-10-18T09-48
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py tests/discovery_runtime/test_dimension_rules.py tests/discovery_runtime/test_acceptance_rules.py tests/discovery_runtime/test_acceptance_scope.py
EXIT_CODE: 1
Output Summary: [1m[94m167 |[0m         snapshot_profile, snapshot_catalog, required_modes=["online", "offline"];     [1m[94m|[0m; ; Found 2 errors.

Working directory: .
Started: 2026-10-18T09:48:29.817691+00:00
Duration seconds: 0.822
Phase: P2-T7 dimension and acceptance obligations; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_acceptance_scope.py:157:89
    [1m[94m|[0m
[1m[94m155 |[0m     assert len(result.ready) == 2
[1m[94m156 |[0m     assert [f.message for f in result.findings] == [
[1m[94m157 |[0m         "Missing ready criterion/client/platform/mode: browser-only/browser/browser/online."
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m158 |[0m     ]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_acceptance_scope.py:165:89
    [1m[94m|[0m
[1m[94m163 |[0m     snapshot_catalog: SchemaCatalog,
[1m[94m164 |[0m ) -> None:
[1m[94m165 |[0m     """Missing applicability requires new supported criteria rather than widening proof."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m166 |[0m     profile = profile_with(
[1m[94m167 |[0m         snapshot_profile, snapshot_catalog, required_modes=["online", "offline"]
    [1m[94m|[0m

Found 2 errors.
```
