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
103 |     """Supply memory io and a naive clock; return None after typed effect-free failure."""
    |                                                                                         ^^
104 |     before = dict(service_io.disk.store.files)
105 |     read_calls = list(service_io.disk.store.calls)
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_context_guards.py:203:89
    |
201 |     service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
202 | ) -> None:
203 |     """Use memory io and patcher to change authenticated actor; return None, no writes."""
    |                                                                                         ^^
204 |     before = dict(service_io.disk.store.files)
205 |     authorize = MemoryService.authorize
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_service_context_guards.py:213:89
    |
211 |         baseline: CapturedWorkspace | None,
212 |     ) -> ServiceAuthority:
213 |         """Authorize typed provider/request/capture; return changed actor after capture."""
    |                                                                                         ^^^
214 |         authority = authorize(provider, request, baseline=baseline)
215 |         # A new identity after capture cannot inherit the original actor's authority.
    |

Found 3 errors.

```
