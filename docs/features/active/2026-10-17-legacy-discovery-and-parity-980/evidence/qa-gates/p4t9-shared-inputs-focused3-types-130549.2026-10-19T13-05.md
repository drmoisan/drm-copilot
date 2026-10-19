# P4-T9 Shared Inputs focused3 types

Timestamp: 2026-10-19T13-05
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/extension_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py tests/discovery_runtime/test_extension_inputs.py tests/discovery_runtime/test_extension_input_limits.py tests/discovery_runtime/analyzer/test_emitter_extensions.py`
EXIT_CODE: 1
Output Summary: Isolated development gate; exact input and raw-output bindings are in the paired JSON.

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:138:16 - error: Unnecessary isinstance call; "str" is always an instance of "str" (reportUnnecessaryIsInstance)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:146:16 - error: Unnecessary isinstance call; "JsonObject" is always an instance of "JsonObject" (reportUnnecessaryIsInstance)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\extension_inputs.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\extension_inputs.py:298:16 - error: Unnecessary isinstance call; "RepositoryFile" is always an instance of "RepositoryFile" (reportUnnecessaryIsInstance)
WORKSPACE\tests\discovery_runtime\test_extension_inputs.py
  WORKSPACE\tests\discovery_runtime\test_extension_inputs.py:167:5 - error: Type of "analyzers" is partially unknown
    Type of "analyzers" is "dict[str, list[str] | dict[Unknown, Unknown]]" (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\test_extension_inputs.py:173:56 - error: Argument type is partially unknown
    Argument corresponds to parameter "analyzers" in function "capture_case"
    Argument type is "dict[str, list[str] | dict[Unknown, Unknown]]" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_extension_inputs.py:179:54 - error: Argument type is partially unknown
    Argument corresponds to parameter "analyzers" in function "capture_case"
    Argument type is "dict[str, list[str] | dict[Unknown, Unknown]]" (reportUnknownArgumentType)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
