# P5-T5 renderer pyright

Timestamp: 2026-10-20T12-26

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/gherkin.py tests/discovery_runtime/test_gherkin.py tests/discovery_runtime/test_acceptance_tags.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.413 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:265:28 - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "len"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:268:9 - error: Type of "tag" is unknown (reportUnknownVariableType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:269:17 - error: Argument type is unknown
    Argument corresponds to parameter "o" in function "__init__" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:275:47 - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "len"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
4 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
