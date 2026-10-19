# P4-T9 Shared Inputs focused5 types

Timestamp: 2026-10-19T13-09
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/extension_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py tests/discovery_runtime/test_extension_inputs.py tests/discovery_runtime/test_extension_input_limits.py tests/discovery_runtime/analyzer/test_emitter_extensions.py`
EXIT_CODE: 1
Output Summary: Isolated development gate; exact input and raw-output bindings are in the paired JSON.

```text
WORKSPACE\tests\discovery_runtime\test_extension_inputs.py
  WORKSPACE\tests\discovery_runtime\test_extension_inputs.py:383:5 - error: Type of "related" is partially unknown
    Type of "related" is "list[dict[str, str | list[Unknown] | None]]" (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\test_extension_inputs.py:392:59 - error: Argument type is partially unknown
    Argument corresponds to parameter "repositories" in function "capture_case"
    Argument type is "list[dict[str, str | list[Unknown] | None]]" (reportUnknownArgumentType)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
