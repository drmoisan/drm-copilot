# p4t7-integration-focused5-types

Timestamp: 2026-10-19T10-48
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependencies.py tests/discovery_runtime/analyzer/test_dependencies.py tests/discovery_runtime/analyzer/test_dependency_projection_limits.py
EXIT_CODE: 1
Output Summary: scoped types; duration 2.132 seconds. Separate exact stdout/stderr hashes and SCRATCH-relative locations qualify sanitized presentation.

```text
.\tests\discovery_runtime\analyzer\test_dependency_projection_limits.py
  .\tests\discovery_runtime\analyzer\test_dependency_projection_limits.py:240:29 - error: "pinned_matches" is not exported from module "drm_copilot_discovery.analyzer.dependencies" (reportPrivateImportUsage)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
