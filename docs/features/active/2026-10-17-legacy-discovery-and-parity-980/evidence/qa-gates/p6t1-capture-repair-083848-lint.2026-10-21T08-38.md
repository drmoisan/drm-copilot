# P6-T1 publication repair lint

Timestamp: 2026-10-21T08-38

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py packages/discovery-runtime/src/drm_copilot_discovery/migration_capture.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_migration.py tests/discovery_runtime/test_migration_capture.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.222 seconds; 0 passed nodes.

```text
TC002 Move third-party import `drm_copilot_discovery.init_io.InitializationIO` into a type-checking block
  --> tests\discovery_runtime\test_service_migration.py:10:43
   |
 8 | from drm_copilot_discovery import migration_v1
 9 | from drm_copilot_discovery.catalog import V1_KINDS, schema_aliases
10 | from drm_copilot_discovery.init_io import InitializationIO
   |                                           ^^^^^^^^^^^^^^^^
11 | from drm_copilot_discovery.operations import OperationFailure
   |
help: Move into type-checking block

Found 1 error.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
