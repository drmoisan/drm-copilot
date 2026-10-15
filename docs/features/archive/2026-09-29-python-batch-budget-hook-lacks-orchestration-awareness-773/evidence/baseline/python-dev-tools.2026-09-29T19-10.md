# Python Regression Baseline: tests/scripts/dev_tools (P0-T23)

Timestamp: 2026-09-29T19-10
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 5251 passed, 6 skipped in 20.74s (collected total 5258)
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
KL-510: STATE-ONLY
Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
No output line contains "Bundle content differs from repo for:". Baseline failure set: the KL-510 node only.
