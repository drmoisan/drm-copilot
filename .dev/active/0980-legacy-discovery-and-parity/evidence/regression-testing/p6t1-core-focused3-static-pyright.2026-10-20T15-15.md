# P6-T1 renderer pyright

Timestamp: 2026-10-20T15-15

Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/service.py packages/discovery-runtime/src/drm_copilot_discovery/operations.py packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py tests/discovery_runtime/test_service.py tests/discovery_runtime/test_service_publication.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 3.621 seconds.

```text
<WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py
  <WORKSPACE>\packages\discovery-runtime\src\drm_copilot_discovery\service.py:256:16 - error: Type "int" is not assignable to declared type "Literal[1, 2, 3]"
    Type "int" is not assignable to type "Literal[1, 2, 3]"
      "int" is not assignable to type "Literal[1]"
      "int" is not assignable to type "Literal[2]"
      "int" is not assignable to type "Literal[3]" (reportAssignmentType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

```
