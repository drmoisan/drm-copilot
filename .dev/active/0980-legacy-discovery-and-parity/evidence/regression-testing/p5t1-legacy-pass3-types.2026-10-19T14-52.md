# p5t1-legacy-pass3-types

Timestamp: 2026-10-19T14-52
Command: poetry run pyright scripts/dev_tools/discovery/coverage_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py
EXIT_CODE: 1
Output Summary: scoped types; duration 1.924 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
.\tests\scripts\dev_tools\discovery\test_coverage_report.py
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:238:64 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> str" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:238:71 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:240:42 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown, value: Unknown) -> None" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:240:49 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:240:55 - error: Type of parameter "value" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:240:76 - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "append" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:269:64 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> Literal['{}']" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:269:71 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:271:42 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown, value: Unknown) -> None" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:271:49 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:271:55 - error: Type of parameter "value" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:271:76 - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "append" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:309:19 - error: Argument of type "(value: str) -> list[str]" cannot be assigned to parameter "validator" of type "ArtifactValidator | None" in function "main"
    Type "(value: str) -> list[str]" is not assignable to type "ArtifactValidator | None"
      Type "(value: str) -> list[str]" is not assignable to type "(text: str) -> list[str]"
        Parameter name mismatch: "text" versus "value"
      "FunctionType" is not assignable to "None" (reportArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:343:64 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> Literal['{}']" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:343:71 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:361:48 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> None" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:361:55 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:361:74 - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "append" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:383:64 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> Literal['{}']" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_coverage_report.py:383:71 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
20 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
