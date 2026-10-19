# P4-T5 development lint

Timestamp: 2026-10-19T07-17
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_access.py:158:89
    |
156 |             item.path,
157 |             "API spellings are candidates only; custom types, aliases, conditional "
158 |             "compilation, runtime targets and platform applicability remain unresolved.",
    |                                                                                         ^
159 |             analyzer=surface.identifier,
160 |             blocking=False,
    |

Found 1 error.

```
