# p3t6-api-pyright-checked1

Timestamp: 2026-10-18T18-09
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:   EXTERNAL_PATH - error: Argument missing for parameter "next_action" (reportCallIssue); 2 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T18:09:05.898784+00:00
Duration seconds: 10.183
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary "cast" call; type is already "str" (reportUnnecessaryCast)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument missing for parameter "next_action" (reportCallIssue)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
