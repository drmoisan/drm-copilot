# P4-T5 development types

Timestamp: 2026-10-19T07-17
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_syntax.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_syntax.py:38:16 - error: Unnecessary isinstance call; "tuple[str, ...]" is always an instance of "tuple[Unknown, ...]" (reportUnnecessaryIsInstance)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_syntax.py:39:17 - error: Unnecessary isinstance call; "frozenset[tuple[str, str]] | frozenset[str]" is always an instance of "frozenset[Unknown]" (reportUnnecessaryIsInstance)
WORKSPACE\tests\discovery_runtime\analyzer\test_registry_access.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_registry_access.py:273:5 - error: Type of "original" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_registry_access.py:274:9 - error: Expected type but received a string literal (reportGeneralTypeIssues)
  WORKSPACE\tests\discovery_runtime\analyzer\test_registry_access.py:291:16 - error: Return type is unknown (reportUnknownVariableType)
5 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
