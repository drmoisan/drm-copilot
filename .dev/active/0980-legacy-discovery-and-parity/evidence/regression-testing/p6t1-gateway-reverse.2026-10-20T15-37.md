Timestamp: 2026-10-20T15-37
Command: `.venv/Scripts/python.exe -m pytest -o addopts= tests/discovery_runtime/test_doctor.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_gateway.py`
EXIT_CODE: 0
Output Summary: reverse; exit 0; elapsed 62.762 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 86 items

tests\discovery_runtime\test_doctor.py .................                 [ 19%]
tests\discovery_runtime\test_gateway_local.py .......................... [ 50%]
..                                                                       [ 52%]
tests\discovery_runtime\test_gateway.py ................................ [ 89%]
.........                                                                [100%]

======================== 86 passed in 62.04s (0:01:02) ========================

```
