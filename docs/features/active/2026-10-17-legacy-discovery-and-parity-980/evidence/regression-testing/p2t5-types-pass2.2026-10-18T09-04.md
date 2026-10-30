# p2t5-types-pass2

Timestamp: 2026-10-18T09-04
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     "None" is not assignable to "str" (reportArgumentType); 11 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T09:04:39.792989+00:00
Duration seconds: 8.043
Phase: P2-T5 scoped decisions and supersession; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Type of "item" is unknown (reportUnknownVariableType)
  EXTERNAL_PATH - error: Object of type "None" cannot be used as iterable value (reportOptionalIterable)
  EXTERNAL_PATH - error: "int" is not iterable
    "__iter__" method not defined (reportGeneralTypeIssues)
  EXTERNAL_PATH - error: "float" is not iterable
    "__iter__" method not defined (reportGeneralTypeIssues)
  EXTERNAL_PATH - error: "bool" is not iterable
    "__iter__" method not defined (reportGeneralTypeIssues)
  EXTERNAL_PATH - error: Type of "superseded" is partially unknown
    Type of "superseded" is "set[Unknown | tuple[str, str]]" (reportUnknownVariableType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "selectors" in function "__init__"
    Argument type is "tuple[frozenset[Unknown], ...]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "selectors" in function "__init__"
    Argument type is "tuple[*tuple[frozenset[Unknown], ...], frozenset[str]]" (reportUnknownArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "fields" in function "question"
    Argument type is "str | dict[str, object] | object | list[Unknown]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument of type "None" cannot be assigned to parameter "identifier" of type "str" in function "decision"
    "None" is not assignable to "str" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "None" cannot be assigned to parameter "status" of type "str" in function "decision"
    "None" is not assignable to "str" (reportArgumentType)
11 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
