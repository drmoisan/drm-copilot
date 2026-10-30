# P5-T1 graph7-pyright

Timestamp: 2026-10-20T03-45
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py tests/discovery_runtime/test_coverage_report.py tests/discovery_runtime/test_coverage_report_contract.py
EXIT_CODE: 1

Duration seconds: 2.460

```text
WORKSPACE\tests\discovery_runtime\test_coverage_report.py
  WORKSPACE\tests\discovery_runtime\test_coverage_report.py:302:11 - error: Argument of type "dict[str, object]" cannot be assigned to parameter "status" of type "str" in function "scenario"
    "dict[str, object]" is not assignable to "str" (reportArgumentType)
  WORKSPACE\tests\discovery_runtime\test_coverage_report.py:302:11 - error: Argument of type "dict[str, object]" cannot be assigned to parameter "expected" of type "str | None" in function "scenario"
    Type "dict[str, object]" is not assignable to type "str | None"
      "dict[str, object]" is not assignable to "str"
      "dict[str, object]" is not assignable to "None" (reportArgumentType)
  WORKSPACE\tests\discovery_runtime\test_coverage_report.py:302:11 - error: Argument of type "dict[str, object]" cannot be assigned to parameter "runs" of type "list[dict[str, object]] | None" in function "scenario"
    Type "dict[str, object]" is not assignable to type "list[dict[str, object]] | None"
      "dict[str, object]" is not assignable to "list[dict[str, object]]"
      "dict[str, object]" is not assignable to "None" (reportArgumentType)
  WORKSPACE\tests\discovery_runtime\test_coverage_report.py:342:13 - error: Argument missing for parameter "next_action" (reportCallIssue)
4 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
