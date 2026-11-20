# Isolation: Python Reversed File Order (Issue #984)

Timestamp: 2026-10-20T14-46
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py -v (one process)
EXIT_CODE: 0
Output Summary: order used: test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_pack_manifest_dependency_scan.py (reverse of the forward run); 33 passed, 0 failed (exit 0). Loop pass 3 (restart after self-review comment and variant-read fixes in the Python test support).
