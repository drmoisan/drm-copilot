# P4-T7 .NET parser scoped gate

Timestamp: 2026-10-19T10-05
Command: poetry run ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_dotnet.py tests/discovery_runtime/analyzer/test_dependency_dotnet.py
EXIT_CODE: 0

Path rendering uses WORKSPACE and SCRATCH tokens; exact streams are preserved by hash.

```text

Fixed 1 error:
- tests\discovery_runtime\analyzer\test_dependency_dotnet.py:
    1 × I001 (unsorted-imports)

Found 1 error (1 fixed, 0 remaining).

```
