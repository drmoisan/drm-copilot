# P6-T1 renderer pyright

Timestamp: 2026-10-20T15-14

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/service.py packages/discovery-runtime/src/drm_copilot_discovery/operations.py packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py tests/discovery_runtime/test_service.py tests/discovery_runtime/test_service_publication.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 4.224 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:243:23 - error: Argument of type "str | None" cannot be assigned to parameter "operation" of type "Operation | None" in function "_failure"
    Type "str | None" is not assignable to type "Operation | None"
      Type "str" is not assignable to type "Operation | None"
        "str" is not assignable to "None"
        "str" is not assignable to type "Literal['init']"
        "str" is not assignable to type "Literal['configure']"
        "str" is not assignable to type "Literal['profile']"
        "str" is not assignable to type "Literal['inventory']"
        "str" is not assignable to type "Literal['new-contract']"
    ... (reportArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:244:18 - error: Argument of type "str | None" cannot be assigned to parameter "mode" of type "Mode | None" in function "_failure"
    Type "str | None" is not assignable to type "Mode | None"
      Type "str" is not assignable to type "Mode | None"
        "str" is not assignable to "None"
        "str" is not assignable to type "Literal['structural']"
        "str" is not assignable to type "Literal['agent-output']"
        "str" is not assignable to type "Literal['discovery-complete']"
        "str" is not assignable to type "Literal['parity-complete']"
        "str" is not assignable to type "Literal['planning']" (reportArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:275:39 - error: Type of "code" is partially unknown
    Type of "code" is "Unknown | str" (reportUnknownMemberType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:275:39 - error: Argument type is partially unknown
    Argument corresponds to parameter "code" in function "_problem"
    Argument type is "Unknown | str" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:275:45 - error: Cannot access attribute "code" for class "ConfigurationError"
    Attribute "code" is unknown (reportAttributeAccessIssue)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:284:14 - error: Argument of type "int" cannot be assigned to parameter "code" of type "Literal[1, 2, 3]" in function "_failure"
    Type "int" is not assignable to type "Literal[1, 2, 3]"
      "int" is not assignable to type "Literal[1]"
      "int" is not assignable to type "Literal[2]"
      "int" is not assignable to type "Literal[3]" (reportArgumentType)
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py:278:14 - error: Argument of type "JsonValue" cannot be assigned to parameter "path" of type "str" in function "__init__"
    Type "JsonValue" is not assignable to type "str"
      "JsonObject" is not assignable to "str" (reportArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py:301:22 - error: Argument of type "str | JsonObject" cannot be assigned to parameter "path" of type "str" in function "__init__"
    Type "str | JsonObject" is not assignable to type "str"
      "JsonObject" is not assignable to "str" (reportArgumentType)
<WORKSPACE>\tests\discovery_runtime\test_service.py
  <WORKSPACE>\tests\discovery_runtime\test_service.py:259:46 - error: Argument of type "object" cannot be assigned to parameter "inputs" of type "dict[str, object] | None" in function "invoke"
    Type "object" is not assignable to type "dict[str, object] | None"
      "object" is not assignable to "dict[str, object]"
      "object" is not assignable to "None" (reportArgumentType)
  <WORKSPACE>\tests\discovery_runtime\test_service.py:277:46 - error: Argument of type "object" cannot be assigned to parameter "inputs" of type "dict[str, object] | None" in function "invoke"
    Type "object" is not assignable to type "dict[str, object] | None"
      "object" is not assignable to "dict[str, object]"
      "object" is not assignable to "None" (reportArgumentType)
<WORKSPACE>\tests\discovery_runtime\test_service_publication.py
  <WORKSPACE>\tests\discovery_runtime\test_service_publication.py:230:46 - error: Argument of type "dict[str, str]" cannot be assigned to parameter "inputs" of type "dict[str, object] | None" in function "invoke"
    Type "dict[str, str]" is not assignable to type "dict[str, object] | None"
      "dict[str, str]" is not assignable to "dict[str, object]"
        Type parameter "_VT@dict" is invariant, but "str" is not the same as "object"
        Consider switching from "dict" to "Mapping" which is covariant in the value type
      "dict[str, str]" is not assignable to "None" (reportArgumentType)
11 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
