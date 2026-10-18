# p1t11-lint-pass1

Timestamp: 2026-10-18T07-23
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/path_models.py packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py tests/discovery_runtime/test_path_policy.py tests/discovery_runtime/test_path_resolution.py tests/discovery_runtime/test_path_collisions.py
EXIT_CODE: 1
Output Summary: [1m[94m105 |[0m         profile.production_roots;     [1m[94m|[0m; ; Found 5 errors.

Working directory: .
Started: 2026-10-18T07:23:36.385971+00:00
Duration seconds: 0.770
Phase: P1-T11 portable path policy and injected metadata; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:300:89
    [1m[94m|[0m
[1m[94m298 |[0m         identities = {parent.identity}
[1m[94m299 |[0m         parts = path.split("/")
[1m[94m300 |[0m         # Walk exact components so no lexical prefix or platform normalization grants access.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m301 |[0m         for index, part in enumerate(parts):
[1m[94m302 |[0m             current = "/".join(parts[: index + 1])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:387:89
    [1m[94m|[0m
[1m[94m385 |[0m             expected[path] = kind
[1m[94m386 |[0m         resolved: list[ResolvedPath] = []
[1m[94m387 |[0m         # Stable ordering makes missing/invalid root diagnostics independent of input order.
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m388 |[0m         for path, kind in sorted(expected.items()):
[1m[94m389 |[0m             result = self._walk(path, allow_missing=True)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:398:89
    [1m[94m|[0m
[1m[94m397 |[0m     def resolve_read(self, path: str, *, allow_missing: bool = False) -> ResolvedPath:
[1m[94m398 |[0m         """Resolve only configured input/artifact scope, optionally recording absence."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m399 |[0m         relative_path(path)
[1m[94m400 |[0m         directories = self._input_directories + tuple(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_path_collisions.py:139:89
    [1m[94m|[0m
[1m[94m137 |[0m )
[1m[94m138 |[0m def test_profile_input_aliases_fail_before_any_metadata_read(roots: list[str]) -> None:
[1m[94m139 |[0m     """Portable collision checks include differently named leaves under alias parents."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m140 |[0m     document = profile_document()
[1m[94m141 |[0m     document["production_roots"] = roots
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_path_resolution.py:103:89
    [1m[94m|[0m
[1m[94m101 |[0m     """Supply a complete memory-only profile layout with ordinary files/parents."""
[1m[94m102 |[0m     filesystem = MemoryPaths(workspace)
[1m[94m103 |[0m     # Inputs preserve their declared kind; no directory names are inferred by the policy.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m104 |[0m     for directory in (
[1m[94m105 |[0m         profile.production_roots
    [1m[94m|[0m

Found 5 errors.
```
