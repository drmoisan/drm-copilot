# P4-T7 Node bounded-candidate types

Timestamp: 2026-10-19T10-23
Command: `poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_node.py tests/discovery_runtime/analyzer/test_dependency_node.py tests/discovery_runtime/analyzer/test_dependency_node_limits.py`
EXIT_CODE: 1
Output Summary: Isolated development check; exact shared and owned bytes and raw diagnostics are bound in JSON.

```text
WORKSPACE\tests\discovery_runtime\analyzer\test_dependency_node_limits.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_dependency_node_limits.py:113:15 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "parse"
    Argument type is "dict[Unknown, Unknown] | object" (reportUnknownArgumentType)
1 error, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
