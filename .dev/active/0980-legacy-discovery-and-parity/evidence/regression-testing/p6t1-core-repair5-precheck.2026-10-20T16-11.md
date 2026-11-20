# P6-T1 core service precheck

Timestamp: 2026-10-20T16-10

Command: `poetry run pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read]`

EXIT_CODE: 0

Output Summary: PASS; 13.837 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 1 item

tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read] PASSED [100%]

============================= 1 passed in 12.23s ==============================

```
