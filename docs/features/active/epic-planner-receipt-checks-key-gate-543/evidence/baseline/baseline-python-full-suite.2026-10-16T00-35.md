# Baseline Python Full Suite (P0-T12)

Timestamp: 2026-10-16T00-35
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0
Output Summary:
- Result line: 7093 passed, 6 skipped, 1 deselected in 55.31s
- Failed: 0
- Deselected: 1 (tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts; known local-only failure #510, covered by CI)
- Skipped: 6 (all in tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py, parametrized cases that declare no accessor expectation)
- Failed: none
