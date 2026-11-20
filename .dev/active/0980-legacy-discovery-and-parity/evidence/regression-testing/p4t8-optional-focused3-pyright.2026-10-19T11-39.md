# p4t8-optional-focused3 pyright

Timestamp: 2026-10-19T11-39
Command: .\.venv\Scripts\python.exe -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/__init__.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_office.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_patterns.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_syntax.py tests/discovery_runtime/analyzer/test_optional_adapter.py tests/discovery_runtime/analyzer/test_optional_limits.py
EXIT_CODE: 1
Output Summary: scoped pyright, 1.016 seconds; source changed=False. Separate exact raw streams qualify sanitized presentation.

```text
.\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py
  .\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py:436:16 - error: Unnecessary isinstance call; "InventoryCapture" is always an instance of "InventoryCapture" (reportUnnecessaryIsInstance)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
