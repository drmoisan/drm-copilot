# Final Python Regression: tests/scripts/dev_tools (P12-T2)

Timestamp: 2026-09-29T21-09
Command: poetry run pytest tests/scripts/dev_tools -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 5251 passed, 6 skipped in 19.69s (collected total 5258, equal to the P0-T23 total)
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
KL-510: STATE-ONLY
Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
No output line contains "Bundle content differs from repo for:". The only FAILED line is a member of the P0-T23 baseline failure set.
