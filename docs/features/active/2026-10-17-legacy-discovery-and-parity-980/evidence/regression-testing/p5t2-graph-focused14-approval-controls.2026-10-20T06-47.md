# P5-T2 graph approval-controls

Timestamp: 2026-10-20T06-47

Command: `poetry run pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[intentionally-changed] tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[retired] tests/discovery_runtime/test_parity_metrics.py::test_multiple_clients_do_not_multiply_source_feature_identity`

EXIT_CODE: 0

Output Summary: PASS; 3.117 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 3 items

tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[intentionally-changed] PASSED [ 33%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[retired] PASSED [ 66%]
tests/discovery_runtime/test_parity_metrics.py::test_multiple_clients_do_not_multiply_source_feature_identity PASSED [100%]

============================== 3 passed in 1.58s ==============================
```
