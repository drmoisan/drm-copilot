# Drift Tests Fail Before the Helper Exists (P2-T4, expect-fail)

Timestamp: 2026-09-27T15-21
Command: poetry run pytest -v tests/scripts/dev_tools/test_parallel_drift_scheduling.py
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: pytest exited 2 with "collected 0 items / 1 error". The collection error is ModuleNotFoundError naming the missing drift helper module scripts.dev_tools._parallel_drift_scheduling. This is the expected fail-before state; the helper module is created by P2-T5.

## Printed output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <host-path>
cachedir: .pytest_cache
rootdir: 
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 0 items / 1 error

=================================== ERRORS ====================================
_ ERROR collecting tests/scripts/dev_tools/test_parallel_drift_scheduling.py __
ImportError while importing test module 'tests\scripts\dev_tools\test_parallel_drift_scheduling.py'.
Hint: make sure your test modules/packages have valid Python names.
Traceback:
..\..\..\..\..\AppData\Local\Programs\Python\Python313\Lib\importlib\__init__.py:88: in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\scripts\dev_tools\test_parallel_drift_scheduling.py:21: in <module>
    from scripts.dev_tools._parallel_drift_scheduling import (
E   ModuleNotFoundError: No module named 'scripts.dev_tools._parallel_drift_scheduling'
=========================== short test summary info ===========================
ERROR tests/scripts/dev_tools/test_parallel_drift_scheduling.py
!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!
============================== 1 error in 0.13s ===============================
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
