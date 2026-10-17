# Final Python dev_tools Regression (#769, P10-T2)

Timestamp: 2026-09-29T14-39
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 5251 passed, 6 skipped (collected total 5258, equal to the P0-T21 total)
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
The only FAILED line is the KL-510 node, a member of the P0-T21 baseline failure set (KL-510: STATE-ONLY).
