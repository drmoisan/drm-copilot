# P5-T2 original verification conflict control

Timestamp: 2026-10-20T06-34

Command: `poetry run python <SCRATCH>/p5t2-graph-conflict-probe.py`

EXIT_CODE: 1

Output Summary: Isolated original-code control; source unchanged. Original bytes match the recorded pre-correction SHA.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 1 item

tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes0] FAILED [100%]

================================== FAILURES ===================================
_ test_present_optional_or_contradictory_claims_remain_independent[changes0] __
tests\discovery_runtime\test_parity_metrics.py:478: in test_present_optional_or_contradictory_claims_remain_independent
    assert counts["conflicting"] == 1 and counts["verified"] == 0
E   assert (0 == 1)
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes0]
============================== 1 failed in 1.24s ==============================
```
