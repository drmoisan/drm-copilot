# p4t9-core-focused9 pyright

Timestamp: 2026-10-19T13-23

Command: .\.venv\Scripts\python.exe -m pyright packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py

EXIT_CODE: 1

Output Summary: Scoped pyright; elapsed 1.054 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
.\tests\discovery_runtime\test_extension_results.py
  .\tests\discovery_runtime\test_extension_results.py:480:57 - error: "_check_link_work" is private and used outside of the module in which it is declared (reportPrivateUsage)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
