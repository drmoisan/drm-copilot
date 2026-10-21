# P6-T1 publication repair types

Timestamp: 2026-10-21T08-43

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pyright packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py packages/discovery-runtime/src/drm_copilot_discovery/migration_capture.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_migration.py tests/discovery_runtime/test_migration_capture.py`

EXIT_CODE: 1

Output Summary: FAIL; 1.423 seconds; 0 passed nodes.

```text
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

WORKSPACE\tests\discovery_runtime\test_service_migration.py
  WORKSPACE\tests\discovery_runtime\test_service_migration.py:64:5 - error: Type of "document" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\test_service_migration.py:64:16 - error: Type of "to_dict" is unknown (reportUnknownMemberType)
  WORKSPACE\tests\discovery_runtime\test_service_migration.py:64:42 - error: Cannot access attribute "to_dict" for class "JsonObject"
    Attribute "to_dict" is unknown (reportAttributeAccessIssue)
  WORKSPACE\tests\discovery_runtime\test_service_migration.py:77:30 - error: Argument type is unknown
    Argument corresponds to parameter "value" in function "canonical_json" (reportUnknownArgumentType)
4 errors, 0 warnings, 0 informations

```
