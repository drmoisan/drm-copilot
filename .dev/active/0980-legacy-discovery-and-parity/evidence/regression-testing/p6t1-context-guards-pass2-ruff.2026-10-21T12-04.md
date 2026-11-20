# P6-T1 core service ruff

Timestamp: 2026-10-21T12-04

Command: `WORKSPACE\.venv\Scripts\python.exe -m ruff check tests/discovery_runtime/test_service_context_guards.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 0.207 seconds.

```text
E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_context_guards.py:103:89
    |
101 |     service_io: MemoryService,
102 | ) -> None:
103 |     """Use memory io and a naive clock; return None after a typed, effect-free failure."""
    |                                                                                         ^^
104 |     before = dict(service_io.disk.store.files)
105 |     read_calls = list(service_io.disk.store.calls)
    |

Found 1 error.

```
