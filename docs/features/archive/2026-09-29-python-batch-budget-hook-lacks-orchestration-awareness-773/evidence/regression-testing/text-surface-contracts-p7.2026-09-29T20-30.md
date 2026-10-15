# Text-Surface Contract Suites After Phase 7 (P7-T9)

Timestamp: 2026-09-29T20-30
Command: poetry run pytest -v tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 17 passed in 0.26s
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
KL-510: STATE-ONLY
Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
No output line contains "Bundle content differs from repo for:". Every other node PASSED.
Preceding mirror steps: P7-T7 (three Claude text files) `PAIR-SUMMARY pairs=3 unequal=0`; P7-T8 (three Copilot text files) `PAIR-SUMMARY pairs=3 unequal=0`.
