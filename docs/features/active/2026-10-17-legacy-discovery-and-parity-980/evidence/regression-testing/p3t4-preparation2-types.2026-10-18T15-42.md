# p3t4-preparation2-types

Timestamp: 2026-10-18T15-42
Command: python -m pyright
EXIT_CODE: 1
Output Summary:     Argument type is "dict[str, str | list[Unknown]]" (reportUnknownArgumentType); 11 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T15:42:11.431186+00:00
Duration seconds: 9.448
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "str" is always an instance of "str" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "JsonObject" is always an instance of "JsonObject" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Type of "append" is partially unknown
    Type of "append" is "(object: Unknown, /) -> None" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "dimensions" in function "open_question"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__new__"
    Argument type is "list[Unknown]" (reportUnknownArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "JsonObject" is always an instance of "JsonObject" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Type of "append" is partially unknown
    Type of "append" is "(object: Unknown, /) -> None" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Type of "insert" is partially unknown
    Type of "insert" is "(index: SupportsIndex, object: Unknown, /) -> None" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Return type, "tuple[Unknown, ...]", is partially unknown (reportUnknownVariableType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__new__"
    Argument type is "list[Unknown]" (reportUnknownArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "changes" in function "scenario_fields"
    Argument type is "dict[str, str | list[Unknown]]" (reportUnknownArgumentType)
11 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
