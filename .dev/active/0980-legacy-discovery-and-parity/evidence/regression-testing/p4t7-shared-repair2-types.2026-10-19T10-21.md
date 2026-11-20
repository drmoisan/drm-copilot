# p4t7-shared-repair2-types

Timestamp: 2026-10-19T10-21
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_values.py tests/discovery_runtime/analyzer/test_dependency_inputs.py tests/discovery_runtime/analyzer/test_dependency_input_limits.py
EXIT_CODE: 1
Output Summary: scoped types; duration 2.491 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
.\tests\discovery_runtime\analyzer\test_dependency_input_limits.py
  .\tests\discovery_runtime\analyzer\test_dependency_input_limits.py:246:30 - error: "_version_term" is private and used outside of the module in which it is declared (reportPrivateUsage)
  .\tests\discovery_runtime\analyzer\test_dependency_input_limits.py:325:12 - error: "_reserve_text" is protected and used outside of the class in which it is declared (reportPrivateUsage)
  .\tests\discovery_runtime\analyzer\test_dependency_input_limits.py:329:16 - error: "_reserve_text" is protected and used outside of the class in which it is declared (reportPrivateUsage)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
