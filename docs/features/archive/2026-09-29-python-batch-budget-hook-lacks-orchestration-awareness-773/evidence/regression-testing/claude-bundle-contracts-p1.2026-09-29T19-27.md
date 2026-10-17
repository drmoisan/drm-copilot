# Claude Bundle Contract Suites After Phase 1 (P1-T16)

Timestamp: 2026-09-29T19-27
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 16 passed in 0.28s
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
KL-510: STATE-ONLY
Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
No output line contains "Bundle content differs from repo for:". Every other node PASSED.
