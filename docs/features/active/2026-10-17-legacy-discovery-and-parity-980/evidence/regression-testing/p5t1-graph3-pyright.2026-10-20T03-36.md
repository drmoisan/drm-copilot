# P5-T1 graph3-pyright

Timestamp: 2026-10-20T03-36
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py
EXIT_CODE: 1

Duration seconds: 2.106

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py:141:9 - error: No overloads for "update" match the provided arguments
    Argument types: (int, int, int) (reportCallIssue)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py:237:16 - error: Type "tuple[dict[Literal['total', 'inventoried', 'unselected', 'missing_ledger', 'conflicting_ledger', 'inspected', 'inspection_blocked', 'uninspected', 'dispositioned', 'undispositioned', 'blocked', 'excluded', 'excluded_valid', 'feature_linked', 'runtime_required', 'runtime_undetermined', 'runtime_supported', 'with_update_evidence'], int], dict[str, JsonObject]]" is not assignable to return type "tuple[dict[str, int], dict[str, JsonObject]]"
    "dict[Literal['total', 'inventoried', 'unselected', 'missing_ledger', 'conflicting_ledger', 'inspected', 'inspection_blocked', 'uninspected', 'dispositioned', 'undispositioned', 'blocked', 'excluded', 'excluded_valid', 'feature_linked', 'runtime_required', 'runtime_undetermined', 'runtime_supported', 'with_update_evidence'], int]" is not assignable to "dict[str, int]"
      Type parameter "_KT@dict" is invariant, but "Literal['total', 'inventoried', 'unselected', 'missing_ledger', 'conflicting_ledger', 'inspected', 'inspection_blocked', 'uninspected', 'dispositioned', 'undispositioned', 'blocked', 'excluded', 'excluded_valid', 'feature_linked', 'runtime_required', 'runtime_undetermined', 'runtime_supported', 'with_update_evidence']" is not the same as "str" (reportReturnType)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
