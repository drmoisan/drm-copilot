# p1t10-pyright-pass6

Timestamp: 2026-10-18T06-59
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Type of "invalid" is "bool | str | int | list[Unknown]" (reportUnknownVariableType); 1 error, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T06:59:23.029965+00:00
Duration seconds: 7.404
Phase: P1-T10 immutable profile, inherited gates and explicit compatibility; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Type of "invalid" is partially unknown
    Type of "invalid" is "bool | str | int | list[Unknown]" (reportUnknownVariableType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
