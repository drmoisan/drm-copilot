# P4-T5 provenance lint

Timestamp: 2026-10-19T07-26
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_filesystem_access.py:296:89
    |
295 | class CountedPin:
296 |     """Expose retained immutable pin data while counting identity inspections locally."""
    |                                                                                         ^
297 |
298 |     def __init__(self, source: RepositoryFile, visits: list[int]) -> None:
    |

Found 1 error.

```
