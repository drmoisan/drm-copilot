# Python Parity Baseline (P0-T37)

Timestamp: 2026-09-29T23-11
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 1
ExpectedExitCode: 1
KL-510: STATE-ONLY
Output Summary:
- 1 failed, 16 passed in 0.29s
- Every node other than test_bundled_claude_payload_contains_all_repo_runtime_contracts is PASSED (16 nodes).
- KL-510 node FAILED with the assertion message: "AssertionError: Repo file missing from bundle: .claude\state\current-session-id" (first two path components `.claude` and `state`).
- No output line contains "Bundle content differs from repo for:".
