# Text-Surface Contract Suites (#769, P6-T14)

Timestamp: 2026-09-29T14-39
Command: poetry run pytest -v tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 17 passed
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
Assertion message: "Repo file missing from bundle: .claude\state\current-session-id"
No output line contains "Bundle content differs from repo for:".
KL-510: STATE-ONLY
Every other node PASSED.
