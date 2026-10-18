# p1t2-types-pass2

Timestamp: 2026-10-18T04-48
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:   EXTERNAL_PATH - error: Type of parameter "_" is unknown (reportUnknownLambdaType); 13 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T04:48:47.108465+00:00
Duration seconds: 7.592
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "str" is always an instance of "str" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "int" is always an instance of "int" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__init__"
    Argument type is "dict[Unknown, Unknown]" (reportUnknownArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__init__"
    Argument type is "dict[Unknown, Unknown]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of "registry" is partially unknown
    Type of "registry" is "Registry[Unknown]" (reportUnknownVariableType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "_anchors" in function "__init__"
    Argument type is "HashTrieMap[tuple[str, str], Anchor[Unknown]]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of "with_resources" is partially unknown
    Type of "with_resources" is "(pairs: Iterable[tuple[str, Resource[Unknown]]]) -> Registry[Unknown]" (reportUnknownMemberType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "argvalues" in function "__call__"
    Argument type is "tuple[(_: str) -> bytes, (_: Unknown) -> Literal[b"\xff"]]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "_" is unknown (reportUnknownLambdaType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(_: Unknown) -> Literal['/verified/python']" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "_" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(_: Unknown) -> None" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "_" is unknown (reportUnknownLambdaType)
13 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
