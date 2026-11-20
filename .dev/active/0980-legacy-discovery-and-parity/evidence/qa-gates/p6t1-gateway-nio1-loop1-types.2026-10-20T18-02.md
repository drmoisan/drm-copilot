Timestamp: 2026-10-20T18-02
Command: `.venv/Scripts/python.exe -m pyright packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py tests/discovery_runtime/test_gateway_boundaries.py`
EXIT_CODE: 1
Output Summary: nio1-loop1-types; 0 retained test IDs; elapsed 1.241 seconds.

```text
WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:340:12 - error: Type of "primitives" is unknown (reportUnknownMemberType)
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:340:19 - error: Cannot access attribute "primitives" for class "GuardedMutationWriter"
    Attribute "primitives" is unknown (reportAttributeAccessIssue)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
