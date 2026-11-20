# P4-T6 first-behavior types

Timestamp: 2026-10-19T08-51
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py tests/discovery_runtime/analyzer/test_test_references.py tests/discovery_runtime/analyzer/test_test_reference_syntax.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py:59:5 - error: Type of "values" is partially unknown
    Type of "values" is "dict[Unknown, Unknown]" (reportUnknownVariableType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py:104:5 - error: Type of "components" is partially unknown
    Type of "components" is "list[Unknown]" (reportUnknownVariableType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py:105:5 - error: Type of "findings" is partially unknown
    Type of "findings" is "list[Unknown]" (reportUnknownVariableType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py:106:5 - error: Type of "relationships" is partially unknown
    Type of "relationships" is "list[Unknown]" (reportUnknownVariableType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py:107:5 - error: Type of "diagnostics" is partially unknown
    Type of "diagnostics" is "list[Unknown]" (reportUnknownVariableType)
WORKSPACE\tests\discovery_runtime\analyzer\test_test_references.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_test_references.py:450:40 - error: "_Output" is private and used outside of the module in which it is declared (reportPrivateUsage)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
