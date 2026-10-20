# P5-T4 generation pyright

Timestamp: 2026-10-20T10-50

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.614 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation.py:145:18 - error: Argument of type "str" cannot be assigned to parameter "kind" of type "AcceptanceKind" in function "__init__"
    Type "str" is not assignable to type "AcceptanceKind"
      "str" is not assignable to type "Literal['legacy-characterization']"
      "str" is not assignable to type "Literal['target-acceptance']" (reportArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation.py:328:42 - error: Argument of type "str | None" cannot be assigned to parameter "key" of type "str" in function "get"
    Type "str | None" is not assignable to type "str"
      "None" is not assignable to "str" (reportArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation.py:366:25 - error: Argument of type "JsonValue" cannot be assigned to parameter "obj" of type "Sized" in function "len"
    Type "JsonValue" is not assignable to type "Sized"
      "float" is incompatible with protocol "Sized"
        "__len__" is not present (reportArgumentType)
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:157:30 - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "len"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:158:27 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "check"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:160:13 - error: Type of "item" is unknown (reportUnknownVariableType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:161:13 - error: Type of "parts" is partially unknown
    Type of "parts" is "Unknown | tuple[Unknown]" (reportUnknownVariableType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:162:21 - error: Argument type is partially unknown
    Argument corresponds to parameter "o" in function "__init__"
    Argument type is "Unknown | tuple[Unknown]" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:162:48 - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "len"
    Argument type is "tuple[Unknown, ...] | tuple[Unknown]" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:165:17 - error: Type of "part" is unknown (reportUnknownVariableType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:166:25 - error: Argument type is unknown
    Argument corresponds to parameter "o" in function "__init__" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:171:16 - error: Return type, "tuple[Unknown, ...]", is partially unknown (reportUnknownVariableType)
<WORKSPACE>\tests\discovery_runtime\test_acceptance_decisions.py
  <WORKSPACE>\tests\discovery_runtime\test_acceptance_decisions.py:293:31 - error: "validate_acceptance" is not exported from module "drm_copilot_discovery.acceptance_generation_context" (reportPrivateImportUsage)
13 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
