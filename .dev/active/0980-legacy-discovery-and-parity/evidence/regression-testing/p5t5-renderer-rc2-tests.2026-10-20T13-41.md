# P5-T5 renderer tests

Timestamp: 2026-10-20T13-41

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.gherkin,drm_copilot_discovery.acceptance_render_text -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_acceptance_render_limits.py::test_exhausted_trace_bytes_reject_before_serialization_or_partial_bundle`

EXIT_CODE: 0

Output Summary: PASS; 2.013 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 1 item

tests/discovery_runtime/test_acceptance_render_limits.py::test_exhausted_trace_bytes_reject_before_serialization_or_partial_bundle PASSED [100%]

============================== 1 passed in 0.20s ==============================

```
