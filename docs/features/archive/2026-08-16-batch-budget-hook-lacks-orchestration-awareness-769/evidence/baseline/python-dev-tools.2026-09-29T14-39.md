# Python dev_tools Regression Baseline (#769, P0-T21)

Timestamp: 2026-09-29T14-39
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 5251 passed, 6 skipped in 20.80s (collected total 5258)
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
Baseline failure set: the single KL-510 node above (assertion "Repo file missing from bundle: .claude\state\current-session-id"; KL-510: STATE-ONLY).
