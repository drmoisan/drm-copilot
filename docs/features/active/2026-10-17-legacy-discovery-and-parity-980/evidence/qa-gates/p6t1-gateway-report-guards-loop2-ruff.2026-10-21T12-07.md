Timestamp: 2026-10-21T12-07
Command: `.venv/Scripts/python.exe -m ruff check tests/discovery_runtime/test_service_report_guards.py`
EXIT_CODE: 1
Output Summary: report-guards-loop2-ruff; 0 retained test IDs; elapsed 0.130 seconds.

```text
TC001 Move application import `tests.discovery_runtime.test_service.MemoryService` into a type-checking block
  --> tests\discovery_runtime\test_service_report_guards.py:21:50
   |
19 | from drm_copilot_discovery.service_reports import project, report_findings
20 |
21 | from tests.discovery_runtime.test_service import MemoryService
   |                                                  ^^^^^^^^^^^^^
22 | from tests.discovery_runtime.test_service import (
23 |     initialization_catalog as initialization_catalog,
   |
help: Move into type-checking block

B008 Do not perform function call `JsonObject` in argument defaults; instead, perform the call within the function, or read the default from a module-level singleton variable
  --> tests\discovery_runtime\test_service_report_guards.py:45:26
   |
43 |     *,
44 |     operation: Operation = "coverage-report",
45 |     inputs: JsonObject = JsonObject(()),
   |                          ^^^^^^^^^^^^^^
46 |     write: bool = False,
47 | ) -> OperationContext:
   |

Found 2 errors.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
