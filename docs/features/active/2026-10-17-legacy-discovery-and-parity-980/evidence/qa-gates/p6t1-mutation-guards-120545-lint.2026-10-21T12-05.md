# P6-T1 mutation guards lint

Timestamp: 2026-10-21T12-05

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m ruff check tests/discovery_runtime/test_service_mutation_guards.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.225 seconds; 0 passed nodes.

```text
TC001 Move application import `tests.discovery_runtime.test_service.MemoryService` into a type-checking block
  --> tests\discovery_runtime\test_service_mutation_guards.py:33:50
   |
32 | from tests.discovery_runtime.test_decision_rules import decision
33 | from tests.discovery_runtime.test_service import MemoryService
   |                                                  ^^^^^^^^^^^^^
34 | from tests.discovery_runtime.test_service import (
35 |     initialization_catalog as initialization_catalog,
   |
help: Move into type-checking block

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_service_mutation_guards.py:217:13
    |
215 |         handler = cast(
216 |             "Callable[[OperationContext], CapturedWorkspace]",
217 |             getattr(service_mutations, "_authored"),
    |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
218 |         )
219 |     elif boundary == "transport":
    |
help: Replace `getattr` with attribute access

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_service_mutation_guards.py:222:13
    |
220 |         handler = cast(
221 |             "Callable[[OperationContext], DiscoveryResult]",
222 |             getattr(service_mutations, "_transport"),
    |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
223 |         )
224 |     else:
    |
help: Replace `getattr` with attribute access

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_service_mutation_guards.py:296:9
    |
294 |     update = cast(
295 |         "Callable[[OperationContext], tuple[MutationChange, ...]]",
296 |         getattr(service_mutations, "_update"),
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
297 |     )
298 |     changes = update(current)
    |
help: Replace `getattr` with attribute access

Found 4 errors.
[*] 3 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
