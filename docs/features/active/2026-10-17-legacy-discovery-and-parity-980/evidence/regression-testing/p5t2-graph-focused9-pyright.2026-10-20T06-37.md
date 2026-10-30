# P5-T2 graph pyright

Timestamp: 2026-10-20T06-37

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_parity_report.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_report_models.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 2.365 seconds.

```text
<WORKSPACE>\tests\discovery_runtime\test_parity_report.py
  <WORKSPACE>\tests\discovery_runtime\test_parity_report.py:280:31 - error: "record_identity" is not exported from module "drm_copilot_discovery.parity_metrics" (reportPrivateImportUsage)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
