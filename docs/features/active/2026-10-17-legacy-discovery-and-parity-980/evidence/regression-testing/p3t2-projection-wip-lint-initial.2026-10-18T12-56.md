# p3t2-projection-wip-lint-initial

Timestamp: 2026-10-18T12-56
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py
EXIT_CODE: 1
Output Summary: [1m[94m209 |[0m     identity = (;     [1m[94m|[0m; ; Found 2 errors.

Working directory: .
Started: 2026-10-18T12:56:28.665153+00:00
Duration seconds: 0.754
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py:98:89
    [1m[94m|[0m
[1m[94m 97 |[0m     def artifact_paths(self) -> JsonObject:
[1m[94m 98 |[0m         """Project exact configured destinations, leaving semantic checks to ProfileV2."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m 99 |[0m         paths: dict[str, JsonValue] = {
[1m[94m100 |[0m             "root": self.artifact_root,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py:207:89
    [1m[94m|[0m
[1m[94m206 |[0m def require_compatible(request: InitializationRequest, profile: ProfileV2) -> None:
[1m[94m207 |[0m     """Preserve existing settings only when identity and explicitly requested roots agree."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m208 |[0m     paths = request.artifact_paths()
[1m[94m209 |[0m     identity = (
    [1m[94m|[0m

Found 2 errors.
```
