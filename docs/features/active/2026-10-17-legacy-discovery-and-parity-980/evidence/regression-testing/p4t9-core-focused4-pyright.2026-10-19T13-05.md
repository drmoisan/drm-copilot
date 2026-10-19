# p4t9-core-focused4 pyright

Timestamp: 2026-10-19T13-05

Command: .\.venv\Scripts\python.exe -m pyright packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py

EXIT_CODE: 1

Output Summary: Scoped pyright; elapsed 1.073 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
.\tests\discovery_runtime\test_extension_inventory_merge.py
  .\tests\discovery_runtime\test_extension_inventory_merge.py:243:47 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(*args: Unknown, **kwargs: Unknown) -> tuple[ValidatedExtension, ...]" (reportUnknownArgumentType)
  .\tests\discovery_runtime\test_extension_inventory_merge.py:243:55 - error: Type of parameter "args" is partially unknown (reportUnknownLambdaType)
  .\tests\discovery_runtime\test_extension_inventory_merge.py:243:63 - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
