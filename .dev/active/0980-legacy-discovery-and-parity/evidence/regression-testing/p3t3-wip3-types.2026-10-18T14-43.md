# p3t3-wip3-types

Timestamp: 2026-10-18T14-43
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     "str" is not assignable to "bool" (reportArgumentType); 3 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T14:43:25.529432+00:00
Duration seconds: 9.034
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "str" is always an instance of "str" (reportUnnecessaryIsInstance)
  EXTERNAL_PATH - error: Unnecessary isinstance call; "bytes" is always an instance of "bytes" (reportUnnecessaryIsInstance)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "controlled" of type "bool" in function "select_configuration"
    "str" is not assignable to "bool" (reportArgumentType)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
