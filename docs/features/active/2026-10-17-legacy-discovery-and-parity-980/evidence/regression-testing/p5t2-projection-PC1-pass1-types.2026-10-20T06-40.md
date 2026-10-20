# p5t2-projection-PC1-pass1-types

Timestamp: 2026-10-20T06-40
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/validation.py tests/discovery_runtime/test_parity_report_projection.py tests/discovery_runtime/test_validation_modes.py
EXIT_CODE: 1
Output Summary: types, 2.296s; exact raw streams separately bound.

```text
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

.\tests\discovery_runtime\test_parity_report_projection.py
  .\tests\discovery_runtime\test_parity_report_projection.py:119:58 - error: "unavailable_parity_summary" is not exported from module "drm_copilot_discovery.validation" (reportPrivateImportUsage)
1 error, 0 warnings, 0 informations
```
