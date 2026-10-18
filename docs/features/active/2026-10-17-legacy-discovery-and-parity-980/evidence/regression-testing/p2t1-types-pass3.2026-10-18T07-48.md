# p2t1-types-pass3

Timestamp: 2026-10-18T07-48
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:       "str" is not assignable to type "Literal['yaml']" (reportArgumentType); 10 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T07:48:38.463468+00:00
Duration seconds: 8.069
Phase: P2-T1 immutable snapshots and injected read boundaries; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "bytes" is always an instance of "bytes" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "bytes" is always an instance of "bytes" (reportUnnecessaryIsInstance)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "bytes" is always an instance of "bytes" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "JsonObject" is always an instance of "JsonObject" (reportUnnecessaryIsInstance)
EXTERNAL_PATH
  EXTERNAL_PATH - error: "entry" is possibly unbound (reportPossiblyUnboundVariable)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "bytes" is always an instance of "bytes" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "format" of type "Literal['json', 'yaml']" in function "validate_document"
    Type "str" is not assignable to type "Literal['json', 'yaml']"
      "str" is not assignable to type "Literal['json']"
      "str" is not assignable to type "Literal['yaml']" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "format" of type "Literal['json', 'yaml']" in function "__init__"
    Type "str" is not assignable to type "Literal['json', 'yaml']"
      "str" is not assignable to type "Literal['json']"
      "str" is not assignable to type "Literal['yaml']" (reportArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "format" of type "Literal['json', 'yaml']" in function "parse_document"
    Type "str" is not assignable to type "Literal['json', 'yaml']"
      "str" is not assignable to type "Literal['json']"
      "str" is not assignable to type "Literal['yaml']" (reportArgumentType)
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "format" of type "Literal['json', 'yaml']" in function "validate_document"
    Type "str" is not assignable to type "Literal['json', 'yaml']"
      "str" is not assignable to type "Literal['json']"
      "str" is not assignable to type "Literal['yaml']" (reportArgumentType)
10 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
