Timestamp: 2026-10-20T16-13
Command: `.venv/Scripts/python.exe -m pyright packages/discovery-runtime/src/drm_copilot_discovery/gateway.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py packages/discovery-runtime/src/drm_copilot_discovery/doctor.py tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py tests/discovery_runtime/gateway_test_support.py tests/discovery_runtime/test_gateway_boundaries.py`
EXIT_CODE: 1
Output Summary: repair3-types; exit 1; elapsed 1.301 seconds.

```text
WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:162:61 - error: Argument type is partially unknown
    Argument corresponds to parameter "name" in function "setattr"
    Argument type is "(_: Unknown) -> Literal['/trusted/git']" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:162:68 - error: Type of parameter "_" is unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:166:9 - error: Argument type is partially unknown
    Argument corresponds to parameter "name" in function "setattr"
    Argument type is "(*args: Unknown, **kwargs: Unknown) -> MemoryProcess" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:166:17 - error: Type of parameter "args" is partially unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_gateway_boundaries.py:166:25 - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
5 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
