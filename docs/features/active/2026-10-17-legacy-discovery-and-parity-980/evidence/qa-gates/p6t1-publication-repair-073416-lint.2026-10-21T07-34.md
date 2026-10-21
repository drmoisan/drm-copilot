# P6-T1 publication repair lint

Timestamp: 2026-10-21T07-34

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_migration.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.222 seconds; 0 passed nodes.

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_service_migration.py:99:89
    |
 97 |     assert not result.ok and result.findings and not result.artifacts
 98 |     assert io.disk.store.files == before and io.writer_calls == 0
 99 |     # Unknown identities stop in dispatch; registered bodies retain real schema findings.
    |                                                                                         ^
100 |     if schema_case == "unknown":
101 |         assert result.exit_code == 2 and result.findings[0].code == "SERVICE_KIND"
    |

Found 1 error.

```
