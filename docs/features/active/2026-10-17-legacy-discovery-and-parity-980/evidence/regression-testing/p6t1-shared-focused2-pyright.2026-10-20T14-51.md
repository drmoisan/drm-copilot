# P6-T1 renderer pyright

Timestamp: 2026-10-20T14-51

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py tests/discovery_runtime/test_service_request_rules.py tests/discovery_runtime/test_service_failures.py tests/schemas/discovery/test_v2_service_result_failures.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 3.013 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service_request_rules.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service_request_rules.py:279:28 - error: Argument of type "dict[str, JsonValue]" cannot be assigned to parameter "inputs" of type "dict[str, object]" in function "_conditions"
    "dict[str, JsonValue]" is not assignable to "dict[str, object]"
      Type parameter "_VT@dict" is invariant, but "JsonValue" is not the same as "object"
      Consider switching from "dict" to "Mapping" which is covariant in the value type (reportArgumentType)
<WORKSPACE>\tests\discovery_runtime\test_service_failures.py
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:238:9 - error: Type of "changes" is partially unknown
    Type of "changes" is "dict[str, str] | dict[str, list[Unknown]] | dict[str, tuple[str]] | dict[str, dict[Unknown, Unknown]]" (reportUnknownVariableType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:260:50 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(value: Unknown) -> None" (reportUnknownArgumentType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:260:57 - error: Type of parameter "value" is unknown (reportUnknownLambdaType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:260:77 - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "append" (reportUnknownArgumentType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:283:51 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(self: Unknown) -> None" (reportUnknownArgumentType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:283:58 - error: Type of parameter "self" is unknown (reportUnknownLambdaType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:283:77 - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "append" (reportUnknownArgumentType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:301:9 - error: Type of "value" is partially unknown
    Type of "value" is "dict[str, str] | dict[str, dict[str, dict[Unknown, Unknown]]] | dict[str, Any] | dict[str, object] | dict[int, str]" (reportUnknownVariableType)
  <WORKSPACE>\tests\discovery_runtime\test_service_failures.py:310:47 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "wire_object"
    Argument type is "dict[str, str] | dict[str, dict[str, dict[Unknown, Unknown]]] | dict[str, Any] | dict[str, object] | dict[int, str]" (reportUnknownArgumentType)
10 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
