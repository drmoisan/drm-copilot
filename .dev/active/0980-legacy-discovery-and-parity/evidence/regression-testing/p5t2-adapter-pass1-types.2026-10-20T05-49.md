# p5t2-adapter-pass1-types

Timestamp: 2026-10-20T05-49
Command: poetry run pyright scripts/dev_tools/discovery/parity_report.py tests/scripts/dev_tools/discovery/test_parity_report.py
EXIT_CODE: 1
Output Summary: types, 1.933s; exact raw streams separately bound.

```text
.\tests\scripts\dev_tools\discovery\test_parity_report.py
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:50:53 - error: Argument of type "dict[str, list[dict[str, str]]]" cannot be assigned to parameter "artifact" of type "dict[str, object]" in function "build_parity_rows"
    "dict[str, list[dict[str, str]]]" is not assignable to "dict[str, object]"
      Type parameter "_VT@dict" is invariant, but "list[dict[str, str]]" is not the same as "object"
      Consider switching from "dict" to "Mapping" which is covariant in the value type (reportArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:230:62 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> str" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:230:69 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:232:40 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown, value: Unknown) -> None" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:232:47 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:232:53 - error: Type of parameter "value" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:232:74 - error: Argument type is partially unknown
    Argument corresponds to parameter "object" in function "append"
    Argument type is "tuple[Unknown, Unknown]" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:257:62 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> Literal['{}']" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:257:69 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:272:62 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> Literal['{}']" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:272:69 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:273:56 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown, value: Unknown) -> None" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:273:63 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:273:69 - error: Type of parameter "value" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:311:62 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> Literal['{}']" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:311:69 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:313:40 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown, text: Unknown) -> None" (reportUnknownArgumentType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:313:47 - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:313:53 - error: Type of parameter "text" is unknown (reportUnknownLambdaType)
  .\tests\scripts\dev_tools\discovery\test_parity_report.py:313:73 - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "append" (reportUnknownArgumentType)
20 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
