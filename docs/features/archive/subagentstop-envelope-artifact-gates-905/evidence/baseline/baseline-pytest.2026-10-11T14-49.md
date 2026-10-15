# Baseline pytest content and parity suites ([P0-T26], issue #905)

Timestamp: 2026-10-11T14-49
Command: poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py
EXIT_CODE: 0
Output Summary: 22 passed in 0.36s; no failures. BASELINE-PYTEST-FAILED is empty.

Final summary line: `22 passed in 0.36s`
BASELINE-PYTEST-FAILED: NONE

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 22 items

tests\scripts\dev_tools\test_claude_planning_integrity_contracts.py .... [ 18%]
..                                                                       [ 27%]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .... [ 45%]
..........                                                               [ 90%]
tests\scripts\dev_tools\test_push_down_claude_pack_manifest_completeness.py . [ 95%]
.                                                                        [100%]

============================= 22 passed in 0.36s ==============================
```
