# p1t8-types-pass2

Timestamp: 2026-10-18T06-19
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Type of "dispose" is "() -> Unknown" (reportUnknownMemberType); 14 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T06:19:00.584046+00:00
Duration seconds: 7.215
Phase: P1-T8 strict parsing and immutable diagnostics; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "int | float | bool | JsonObject" is always an instance of "str | int | float | JsonObject" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "str" is always an instance of "str" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "JsonObject" is always an instance of "JsonObject" (reportUnnecessaryIsInstance)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Type of "event" is unknown (reportUnknownVariableType)
  EXTERNAL_PATH - error: Type of "parse" is partially unknown
    Type of "parse" is "(stream: Unknown, Loader: type[Loader] | type[BaseLoader] | type[FullLoader] | type[SafeLoader] | type[UnsafeLoader] | type[CLoader] | type[CBaseLoader] | type[CFullLoader] | type[CSafeLoader] | type[CUnsafeLoader] = ...) -> Unknown" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Type of "construct_object" is partially unknown
    Type of "construct_object" is "(node: Unknown, deep: bool = False) -> Unknown" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "scalar"
    Argument type is "object | list[Unknown] | SequenceNode" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "id"
    Argument type is "_ObjectPairs | MappingNode | object | list[Unknown] | SequenceNode" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "id"
    Argument type is "_ObjectPairs | object | list[Unknown] | MappingNode | Node | SequenceNode" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "obj" in function "id"
    Argument type is "_ObjectPairs | object | list[Unknown] | MappingNode | Node | SequenceNode" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of "decoded" is partially unknown
    Type of "decoded" is "object | Unknown" (reportUnknownVariableType)
  EXTERNAL_PATH - error: Type of "compose" is partially unknown
    Type of "compose" is "(stream: Unknown, Loader: type[Loader] | type[BaseLoader] | type[FullLoader] | type[SafeLoader] | type[UnsafeLoader] | type[CLoader] | type[CBaseLoader] | type[CFullLoader] | type[CSafeLoader] | type[CUnsafeLoader] = ...) -> Unknown" (reportUnknownMemberType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "visit"
    Argument type is "object | Unknown" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of "dispose" is partially unknown
    Type of "dispose" is "() -> Unknown" (reportUnknownMemberType)
14 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
