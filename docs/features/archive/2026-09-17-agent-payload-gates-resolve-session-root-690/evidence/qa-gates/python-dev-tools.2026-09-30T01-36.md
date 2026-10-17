# Python Regression tests/scripts/dev_tools (P13-T3)

Timestamp: 2026-09-30T01-36
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 1 failed, 5251 passed, 6 skipped (collected 5258 = P0-T38 total).
- Only FAILED line: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts (KL-510, case b, STATE-ONLY; member of the P0-T38 baseline failure set).
- Supersedes python-dev-tools.2026-09-30T01-25.md; the frozen-surface failure recorded there is resolved by P13-T2 (commit 8ae639e3).
