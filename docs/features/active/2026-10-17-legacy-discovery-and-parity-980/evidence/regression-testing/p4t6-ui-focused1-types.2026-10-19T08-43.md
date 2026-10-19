# p4t6-ui-focused1-types

Timestamp: 2026-10-19T08-43
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/ui_callbacks.py tests/discovery_runtime/analyzer/test_ui_callbacks.py tests/discovery_runtime/analyzer/test_ui_callback_limits.py
EXIT_CODE: 1
Output Summary: FAIL scoped UI stage types; duration 2.127 seconds. Exact bytes and original command output are in the paired JSON.

```text
.\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\ui_callbacks.py
  .\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\ui_callbacks.py:439:16 - error: Unnecessary isinstance call; "InventoryCapture" is always an instance of "InventoryCapture" (reportUnnecessaryIsInstance)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
