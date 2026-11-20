# P4-T2 adapter-types

Timestamp: 2026-10-19T03-43
Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py tests/discovery_runtime/analyzer/test_dotnet_projects.py`
EXIT_CODE: 1
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
WORKSPACE\tests\discovery_runtime\analyzer\test_dotnet_projects.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_dotnet_projects.py:197:16 - error: Unnecessary "cast" call; type is already "JsonObject" (reportUnnecessaryCast)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
