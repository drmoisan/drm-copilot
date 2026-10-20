Timestamp: 2026-10-20T15-16
Command: `.venv/Scripts/python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/gateway.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py packages/discovery-runtime/src/drm_copilot_discovery/doctor.py tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py`
EXIT_CODE: 1
Output Summary: loop4-ruff; exit 1; elapsed 0.146 seconds.

```text
E501 Line too long (89 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\doctor.py:71:89
   |
70 |     def observe(self, path: str) -> None:
71 |         """Record real absence or bounded bytes; return None without selecting policy."""
   |                                                                                         ^
72 |         self.budget.work(1)
73 |         if self.reader.inspect(path).kind != "missing":
   |

Found 1 error.

```
