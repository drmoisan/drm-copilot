# P5-T5 renderer pyright

Timestamp: 2026-10-20T12-25

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/gherkin.py tests/discovery_runtime/test_gherkin.py tests/discovery_runtime/test_acceptance_tags.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.413 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:276:14 - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__new__"
    Argument type is "list[Unknown]" (reportUnknownArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:276:21 - error: Argument of type "set[JsonValue]" cannot be assigned to parameter "iterable" of type "Iterable[SupportsRichComparisonT@sorted]" in function "sorted"
    "set[JsonValue]" is not assignable to "Iterable[SupportsRichComparisonT@sorted]"
      Type parameter "_T_co@Iterable" is covariant, but "JsonValue" is not a subtype of "SupportsRichComparisonT@sorted"
        Type "JsonValue" is not assignable to type "SupportsRichComparison"
          Type "JsonValue" is not assignable to type "SupportsRichComparison"
            Type "JsonObject" is not assignable to type "SupportsRichComparison" (reportArgumentType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:278:12 - error: Type "dict[str, JsonValue]" is not assignable to return type "dict[str, object]"
    "dict[str, JsonValue]" is not assignable to "dict[str, object]"
      Type parameter "_VT@dict" is invariant, but "JsonValue" is not the same as "object"
      Consider switching from "dict" to "Mapping" which is covariant in the value type (reportReturnType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:346:9 - error: Type of "statements" is partially unknown
    Type of "statements" is "tuple[Unknown, ...] | tuple[str]" (reportUnknownVariableType)
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\gherkin.py:348:43 - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__new__"
    Argument type is "tuple[Unknown, ...] | tuple[str]" (reportUnknownArgumentType)
<WORKSPACE>\tests\discovery_runtime\test_gherkin.py
  <WORKSPACE>\tests\discovery_runtime\test_gherkin.py:357:33 - error: "json" is not exported from module "drm_copilot_discovery.gherkin" (reportPrivateImportUsage)
6 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
