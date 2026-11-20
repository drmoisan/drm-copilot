# p4t7-python-repair-focused1-types

Timestamp: 2026-10-19T10-30
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_python.py tests/discovery_runtime/analyzer/test_dependency_python.py
EXIT_CODE: 1
Output Summary: scoped types; duration 2.859 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
.\tests\discovery_runtime\analyzer\test_dependency_python.py
  .\tests\discovery_runtime\analyzer\test_dependency_python.py:15:5 - error: "_IniParser" is private and used outside of the module in which it is declared (reportPrivateUsage)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
