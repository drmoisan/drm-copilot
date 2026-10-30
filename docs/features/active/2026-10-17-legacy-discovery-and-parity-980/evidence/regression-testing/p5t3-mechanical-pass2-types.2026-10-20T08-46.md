# p5t3-mechanical-pass2-types

Timestamp: 2026-10-20T08-46
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/validation.py packages/discovery-runtime/src/drm_copilot_discovery/validation_operation.py tests/discovery_runtime/test_parity_report_projection.py tests/discovery_runtime/test_agent_output.py
EXIT_CODE: 1
Output Summary: types, 2.184s; exact raw streams separately bound.

```text
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

.\packages\discovery-runtime\src\drm_copilot_discovery\validation.py
  .\packages\discovery-runtime\src\drm_copilot_discovery\validation.py:31:56 - error: "_findings" is private and used outside of the module in which it is declared (reportPrivateUsage)
  .\packages\discovery-runtime\src\drm_copilot_discovery\validation.py:31:67 - error: "_Validation" is private and used outside of the module in which it is declared (reportPrivateUsage)
.\packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py
  .\packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py:45:7 - error: Class "_Validation" is not accessed (reportUnusedClass)
3 errors, 0 warnings, 0 informations
```
