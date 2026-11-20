# P4-T7 .NET FR2 scoped repair gate

Timestamp: 2026-10-19T10-27
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_dotnet.py tests/discovery_runtime/analyzer/test_dependency_dotnet.py
EXIT_CODE: 0

WORKSPACE/SCRATCH are path tokens. Output control characters are JSON-escaped below; original streams are separately hash-bound. New evidence uses explicit LF.

```json
{
  "stdout": "0 errors, 0 warnings, 0 informations\nWARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).\r\nPlease install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`\r\n\r\n",
  "stderr": ""
}
```
