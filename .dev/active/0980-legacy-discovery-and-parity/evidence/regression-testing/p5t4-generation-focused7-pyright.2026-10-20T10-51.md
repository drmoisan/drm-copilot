# P5-T4 generation pyright

Timestamp: 2026-10-20T10-51

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.614 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:163:48 - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "len"
    Argument type is "tuple[Unknown, ...] | tuple[object]" (reportUnknownArgumentType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
