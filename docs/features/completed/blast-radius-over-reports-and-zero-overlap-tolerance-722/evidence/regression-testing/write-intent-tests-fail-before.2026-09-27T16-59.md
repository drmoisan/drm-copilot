# Write-Intent Tests Fail Before the Module Exists (P8-T4, expect-fail)

Timestamp: 2026-09-27T16-59
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_write_intent.py
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: pytest exited 2 with one collection error. The error is ModuleNotFoundError: No module named 'scripts.dev_tools._blast_radius_write_intent', raised by the test module's direct import of the write-intent module, which P8-T5 creates. Zero tests were collected. This is the expected fail-before outcome.

## Output (tail)

```text
collecting ... collected 0 items / 1 error
=================================== ERRORS ====================================
_ ERROR collecting tests/scripts/dev_tools/test_blast_radius_write_intent.py __
ImportError while importing test module '...\tests\scripts\dev_tools\test_blast_radius_write_intent.py'.
Hint: make sure your test modules/packages have valid Python names.
Traceback:
...\Lib\importlib\__init__.py:88: in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
tests\scripts\dev_tools\test_blast_radius_write_intent.py:25: in <module>
    from scripts.dev_tools._blast_radius_write_intent import (
E   ModuleNotFoundError: No module named 'scripts.dev_tools._blast_radius_write_intent'
=========================== short test summary info ===========================
ERROR tests/scripts/dev_tools/test_blast_radius_write_intent.py
!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!
============================== 1 error in 0.13s ===============================
```

Host path prefixes are elided with "..." so the artifact carries no absolute path.
