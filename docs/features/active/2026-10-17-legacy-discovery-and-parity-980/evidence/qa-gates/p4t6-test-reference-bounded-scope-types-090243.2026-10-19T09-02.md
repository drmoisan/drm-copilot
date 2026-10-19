# P4-T6 bounded-scope types

Timestamp: 2026-10-19T09-02
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py tests/discovery_runtime/analyzer/test_test_references.py tests/discovery_runtime/analyzer/test_test_reference_syntax.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
WORKSPACE\tests\discovery_runtime\analyzer\test_test_reference_syntax.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_test_reference_syntax.py:260:30 - error: "within_roots" is not exported from module "drm_copilot_discovery.analyzer.test_references" (reportPrivateImportUsage)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
