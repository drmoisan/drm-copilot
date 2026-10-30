# P5-T1 models5-pyright

Timestamp: 2026-10-19T15-05
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_report_models.py scripts/dev_tools/discovery/coverage_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py
EXIT_CODE: 1

Duration seconds: 2.139

```text
WORKSPACE\tests\discovery_runtime\test_report_models.py
  WORKSPACE\tests\discovery_runtime\test_report_models.py:87:16 - error: Cannot assign to attribute "document" for class "DiscoveryReport"
    Attribute "document" is read-only (reportAttributeAccessIssue)
  WORKSPACE\tests\discovery_runtime\test_report_models.py:280:5 - error: Type of "value" is partially unknown
    Type of "value" is "dict[str, object | list[Unknown]]" (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\test_report_models.py:285:29 - error: Argument type is partially unknown
    Argument corresponds to parameter "artifact" in function "build_coverage_rows"
    Argument type is "dict[str, object | list[Unknown]]" (reportUnknownArgumentType)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
