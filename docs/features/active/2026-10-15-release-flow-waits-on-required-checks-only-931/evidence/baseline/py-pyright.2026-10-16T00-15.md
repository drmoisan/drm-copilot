# Python Type Baseline (Issue #931)

Timestamp: 2026-10-16T00-15
Command: poetry run pyright tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
EXIT_CODE: 0
Output Summary: PASS. Pyright printed `0 errors, 0 warnings, 0 informations`.

Output:

```
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

The version notice is informational and does not affect the result.
