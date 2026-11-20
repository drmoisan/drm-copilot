# P5-T2 helper-proof2-types

Timestamp: 2026-10-20T05-57

Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py tests/discovery_runtime/test_parity_report.py scripts/dev_tools/discovery/parity_report.py tests/scripts/dev_tools/discovery/test_parity_report.py

EXIT_CODE: 1

Output Summary: Exact scoped stage completed in 2.021s; raw bytes are retained in the JSON receipt.

```text
WORKSPACE\tests\discovery_runtime\test_parity_report.py
  WORKSPACE\tests\discovery_runtime\test_parity_report.py:137:30 - error: "render_pretty_json" is not exported from module "drm_copilot_discovery.parity_report" (reportPrivateImportUsage)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
