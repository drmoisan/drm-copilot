# p1t8-types-pass3

Timestamp: 2026-10-18T06-20
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Argument type is "_ObjectPairs | object | list[Unknown] | MappingNode | Node | SequenceNode" (reportUnknownArgumentType); 4 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T06:20:01.026474+00:00
Duration seconds: 7.186
Phase: P1-T8 strict parsing and immutable diagnostics; focused task verification.

## Captured output

```text
EXTERNAL_PATH
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
4 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
