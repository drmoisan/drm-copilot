# p4t9-core-focused3 ruff

Timestamp: 2026-10-19T13-04

Command: .\.venv\Scripts\python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py

EXIT_CODE: 1

Output Summary: Scoped ruff; elapsed 0.106 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:236:89
    |
235 |     def read(self, path: str, kind: str) -> tuple[SnapshotFile, JsonObject]:
236 |         """Validate bounded retained bytes for path/kind; return file and trusted document.
    |                                                                                         ^^^
237 |
238 |         Rejects reuse, missing files and unsupported schemas with fixed diagnostics.
    |

Found 1 error.
```
