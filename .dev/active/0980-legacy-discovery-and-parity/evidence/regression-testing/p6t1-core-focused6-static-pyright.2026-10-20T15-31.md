# P6-T1 core service pyright

Timestamp: 2026-10-20T15-31

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/service.py packages/discovery-runtime/src/drm_copilot_discovery/operations.py packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py tests/discovery_runtime/test_service.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_boundaries.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.612 seconds.

```text
<WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:198:16 - error: Argument missing for parameter "next_action" (reportCallIssue)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:353:9 - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "any"
    Argument type is "Generator[Unknown | bool, None, None]" (reportUnknownArgumentType)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:353:50 - error: Operator ">" not supported for types "JsonValue" and "Literal[0]"
    Operator ">" not supported for types "str" and "Literal[0]" when expected type is "object"
    Operator ">" not supported for types "None" and "Literal[0]" when expected type is "object"
    Operator ">" not supported for types "JsonObject" and "Literal[0]" when expected type is "object"
    Operator ">" not supported for types "tuple[JsonValue, ...]" and "Literal[0]" when expected type is "object" (reportOperatorIssue)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:354:13 - error: Type of "row" is unknown (reportUnknownVariableType)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:354:20 - error: Object of type "None" cannot be used as iterable value (reportOptionalIterable)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:354:20 - error: "int" is not iterable
    "__iter__" method not defined (reportGeneralTypeIssues)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:354:20 - error: "float" is not iterable
    "__iter__" method not defined (reportGeneralTypeIssues)
  <WORKSPACE>\tests\discovery_runtime\test_service_boundaries.py:354:20 - error: "bool" is not iterable
    "__iter__" method not defined (reportGeneralTypeIssues)
8 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
