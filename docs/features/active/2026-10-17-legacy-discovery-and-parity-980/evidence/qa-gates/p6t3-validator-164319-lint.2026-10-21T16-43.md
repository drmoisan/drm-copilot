# P6-T3 compatibility subset lint

Timestamp: 2026-10-21T16-43

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m ruff check scripts/dev_tools/validate_discovery_artifacts.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.209 seconds; 0 passed nodes.

```text
E501 Line too long (89 > 88)
   --> tests\scripts\dev_tools\test_validate_discovery_artifacts_dispatch.py:372:89
    |
371 | def test_report_mixed_routes_refuse_before_callbacks() -> None:
372 |     """Assert fixed ValueError for mixed routes; return None without callbacks or I/O."""
    |                                                                                         ^
373 |     with pytest.raises(ValueError, match="separately"):
374 |         validator.report_arguments(
    |

Found 1 error.

```
