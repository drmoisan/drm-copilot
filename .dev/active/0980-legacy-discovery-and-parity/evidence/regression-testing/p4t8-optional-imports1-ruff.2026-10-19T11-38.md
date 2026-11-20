# p4t8-optional-imports1 ruff

Timestamp: 2026-10-19T11-38
Command: .\.venv\Scripts\python.exe -m ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/__init__.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_office.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_patterns.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_syntax.py tests/discovery_runtime/analyzer/test_optional_adapter.py tests/discovery_runtime/analyzer/test_optional_limits.py
EXIT_CODE: 0
Output Summary: scoped ruff, 0.12 seconds; source changed=True. Separate exact raw streams qualify sanitized presentation.

```text

Fixed 2 errors:
- packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_syntax.py:
    1 × I001 (unsorted-imports)
- tests\discovery_runtime\analyzer\test_optional_limits.py:
    1 × I001 (unsorted-imports)

Found 2 errors (2 fixed, 0 remaining).
```
