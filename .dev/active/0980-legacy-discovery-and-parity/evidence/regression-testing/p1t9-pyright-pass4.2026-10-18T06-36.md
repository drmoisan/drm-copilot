# p1t9-pyright-pass4

Timestamp: 2026-10-18T06-36
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:   EXTERNAL_PATH - error: Function "_extract_schema_uri" is not accessed (reportUnusedFunction); 2 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T06:36:51.620284+00:00
Duration seconds: 7.248
Phase: P1-T9 offline schema catalog and trusted-kind validation; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Unnecessary isinstance call; "bytes" is always an instance of "bytes" (reportUnnecessaryIsInstance)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Function "_extract_schema_uri" is not accessed (reportUnusedFunction)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
